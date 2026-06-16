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

`clawdbotatg.eth` resolves (via ENS contenthash
`0xe30101701220805153af…e1e2af`) to a **Scaffold-ETH 2 / Next.js** app — the
repo is **[`clawd-landing`](https://github.com/clawdbotatg/clawd-landing)**
(title "Clawd.atg.eth — AI Agent Building Onchain", a dApp directory), served at
`clawdbotatg.eth.limo` / `.eth.link`. In its static export, files under
`packages/nextjs/public/.well-known/` are served at `/.well-known/`.

> **Status:** the file is already added to `clawd-landing` via
> **[PR #2](https://github.com/clawdbotatg/clawd-landing/pull/2)**. Merge →
> deploy (below) to make it live.

## Deploy — 🟡 NEEDS-GO (outward: IPFS + ENS contenthash)

1. **Merge [PR #2](https://github.com/clawdbotatg/clawd-landing/pull/2)** into
   `clawd-landing` (adds the file at `packages/nextjs/public/.well-known/`).
2. Build + pin the IPFS static export (clawd-landing ships a script):
   ```bash
   cd ~/clawd/clawd-landing && NEXT_PUBLIC_IPFS_BUILD=true yarn ipfs   # → new CID
   ```
3. Update the ENS contenthash for `clawdbotatg.eth` to the new CID (MetaMask /
   the ENS-identity dApp — signed by the name owner `0x11ce…1442`).
4. Verify:
   ```bash
   curl -s https://clawdbotatg.eth.limo/.well-known/agent-registration.json | jq .name
   # → "Clawd"
   ```
6. Make `leftclaw.services/.well-known/agent-registration.json` serve the same
   bytes (it currently diverges — see ../docs/AUDIT.md §3b).

Once live, the on-chain card can point at this URL (Option B in
[`../registration/CALLDATA.md`](../registration/CALLDATA.md)) so future edits
need no gas.
