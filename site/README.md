# site/ — the `.well-known` file for `clawdbotatg.eth.limo`

Stages the **ERC-8004 domain-verification file** so a verifier hitting
`https://clawdbotatg.eth.limo/.well-known/agent-registration.json` gets a card
that matches the on-chain NFT (#21548). Today that path **404s** — this fixes it.

```
site/.well-known/agent-registration.json   ← drop-in, identical to ../registration/agent-registration.json
```

It is byte-identical to the corrected canonical card. Keep them in sync (or
symlink) so the hosted file, the 8004 NFT, and the ENS `agent-uri` never drift
apart again.

## The live site

`clawdbotatg.eth` resolves (via ENS contenthash) to a **Next.js** app served at
`clawdbotatg.eth.limo` / `.eth.link` (page title `clawd-mage`). For a Next.js
static export, files under `public/.well-known/` are served at `/.well-known/`.

## Deploy — 🟡 NEEDS-GO (outward: IPFS + ENS contenthash)

This is an outward action and should run through the **site repo's own build
session** (per clawd's no-cross-repo-edit rule), not be hand-edited here.

1. Identify the repo behind `clawdbotatg.eth` (the `clawd-mage` Next.js app).
2. Add this file at `packages/nextjs/public/.well-known/agent-registration.json`
   (SE-2 layout) — i.e. it must land in the static `public/` dir so the export
   serves it verbatim.
3. Build the static export and deploy to IPFS via BGIPFS:
   ```bash
   yarn bgipfs upload config init -u https://upload.bgipfs.com
   yarn bgipfs upload out          # → CID
   ```
4. Update the ENS contenthash for `clawdbotatg.eth` to the new CID.
5. Verify:
   ```bash
   curl -s https://clawdbotatg.eth.limo/.well-known/agent-registration.json | jq .name
   # → "Clawd"
   ```
6. Make `leftclaw.services/.well-known/agent-registration.json` serve the same
   bytes (it currently diverges — see ../docs/AUDIT.md §3b).

Once live, the on-chain card can point at this URL (Option B in
[`../registration/CALLDATA.md`](../registration/CALLDATA.md)) so future edits
need no gas.
