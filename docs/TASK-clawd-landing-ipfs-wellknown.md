# TASK (for the clawd-landing Claude Code session) — make `yarn ipfs` keep `.well-known`

> **Hand this whole file to a Claude Code session running in `~/clawd/clawd-landing`.**
> It is self-contained. clawd policy: clawd-landing source is edited *through its
> own CC session*, not from here — this doc is the spec, not a patch.

## One-line problem

`yarn ipfs` builds + pins the static site to IPFS, but the pin **silently omits
the `.well-known/` directory**, so `clawdbotatg.eth.limo/.well-known/agent-registration.json`
404s even though the site root works. That file is clawd's ERC-8004 domain
verification — it must be served at exactly that path.

## Why (root cause, verified 2026-06-17)

The `ipfs` script (`packages/nextjs/package.json`) ends with `yarn bgipfs upload out`.
Chain: `bgipfs` → **`ipfs-uploader@0.0.11`** → kubo `globSource(dir, "**/*")`.

In `node_modules/ipfs-uploader/dist/NodeUploader.js` (~line 68):

```js
source = globSource(input.dirPath, input.pattern ?? "**/*");
```

kubo-rpc-client's `globSource` defaults to **`dot:false`** and explicitly skips any
path whose basename starts with `.` unless `options.hidden === true`
(`kubo-rpc-client/dist/src/lib/glob-source.js` lines 24 & 29). So `.well-known/`
— a dot-directory — is dropped at **upload** time (not build time; the file is
correctly present in `out/.well-known/`).

**Proof:** first pin `bafybeiajs7…wr3jm` served `/` (HTTP 200) but
`/.well-known/agent-registration.json` → `404 no link named ".well-known"`.
After forcing `{ hidden: true }` and re-pinning → `bafybeih6k44…cadwq` serves
`/.well-known/agent-registration.json` → **HTTP 200** (13 services). The one-char
option is the entire fix; it was applied by hand to `node_modules` for the
2026-06-17 deploy, which is **ephemeral** — the next `yarn install`/`yarn ipfs`
regresses it.

## The durable fix — `yarn patch` (recommended)

Repo is **Yarn 3.2.3 (Berry), `nodeLinker: node-modules`**, no existing
`resolutions`/patches. Berry's native `yarn patch` writes a committed patch under
`.yarn/patches/` and a root `resolutions` entry that re-applies on every install.

```bash
cd ~/clawd/clawd-landing

# 1. Open the dep for patching — prints a temp dir to edit:
yarn patch ipfs-uploader
#   -> e.g. "/private/var/folders/…/ipfs-uploader" ; note the path

# 2. In that temp dir, edit dist/NodeUploader.js — add the hidden option:
#      source = globSource(input.dirPath, input.pattern ?? "**/*", { hidden: true });
#    (There may be a similar globSource call in S3Uploader.js / PinataUploader —
#     ours uses NodeUploader, that one is enough. Patch only what's needed.)

# 3. Commit the patch (writes .yarn/patches/…patch + a root resolutions entry):
yarn patch-commit -s "<temp dir from step 1>"

# 4. Verify the resolution landed in the ROOT package.json, e.g.:
#      "resolutions": {
#        "ipfs-uploader@npm:0.0.11": "patch:ipfs-uploader@npm%3A0.0.11#./.yarn/patches/ipfs-uploader-npm-0.0.11-<hash>.patch"
#      }

# 5. Reinstall so the patch is the resolved copy, then confirm it stuck:
yarn install
grep -n "hidden: true" node_modules/ipfs-uploader/dist/NodeUploader.js   # must print the line
```

Sanity first: `find node_modules -path '*ipfs-uploader/package.json' | xargs grep '"version"'`
should show a **single** `0.0.11` (one hoisted copy → the resolution covers
bgipfs's usage too). If duplicates exist, pin them all.

## Verify end-to-end (don't trust the build — fetch the file)

```bash
cd ~/clawd/clawd-landing
NEXT_PUBLIC_IPFS_BUILD=true yarn ipfs                 # build + pin; capture the new CID
CID=<new cid from the output>
curl -sL "https://$CID.ipfs.community.bgipfs.com/.well-known/agent-registration.json" \
  | python3 -c "import sys,json;d=json.load(sys.stdin);print('OK',d['name'],len(d['services']),'services')"
# Expect: OK Clawd 13 services   (NOT a 404 / 'no link named .well-known')
```

Only after that 200 is the deploy real. Then set the `clawdbotatg.eth` contenthash
to the new CID (the clawd-8004 `tools/update-identity.html` step-4 button does this;
update its `NEW_CID`/`NEW_CONTENTHASH` constants to the new CID — contenthash =
`0xe301` + the CIDv1 bytes; round-trip it).

## Fallback (if `yarn patch` is fighting you)

Replace the upload step with a tiny repo-owned script that calls kubo-rpc-client
directly with the hidden option (bgipfs's upload endpoint is treated as a kubo RPC
URL by NodeUploader, so this reproduces it):

```js
// packages/nextjs/scripts/ipfs-upload.mjs
import { create, globSource } from "kubo-rpc-client";
const client = create({ url: "https://upload.bgipfs.com" });
let root;
for await (const f of client.addAll(globSource("out", "**/*", { hidden: true }),
           { wrapWithDirectory: true, cidVersion: 1 })) root = f;   // last entry = wrapping dir
console.log("CID:", root.cid.toString());
```
…and point the `ipfs` script's upload half at `node scripts/ipfs-upload.mjs`.
(Less preferred — it re-implements bgipfs's tested path; the one-line patch is
smaller surface area.)

## Acceptance criteria

- [ ] `yarn install` from clean leaves `{ hidden: true }` in the resolved
      `ipfs-uploader` (patch is committed + referenced in root `resolutions`).
- [ ] A fresh `yarn ipfs` produces a CID whose
      `/.well-known/agent-registration.json` returns **HTTP 200** with the 13-service card.
- [ ] The patch file + `package.json` + `yarn.lock` are committed (git identity
      `clawdbotatg` / `clawd@buidlguidl.com`, HTTPS).

## Pointers

- The served card is `packages/nextjs/public/.well-known/agent-registration.json`
  (added via PR #2, merged). Canonical source of truth lives in clawd-8004
  `registration/agent-registration.json` — keep them byte-identical.
- Background + the manual one-off that shipped 2026-06-17: clawd-8004
  `tools/README.md` (Part 2) and `SCORECARD.md` (#5).
