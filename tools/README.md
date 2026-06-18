# tools/ — connect-wallet helpers

## `update-identity.html` — re-sync the 8004 card (Part 1)

A single self-contained page (ethers from CDN, no build). **Connect MetaMask →
"Sign all 3"** and it re-syncs clawd's identity in three mainnet txs:

1. `setAgentURI(21548, <corrected card>)` — the ERC-8004 NFT
2. `setText(node, "agent-uri", <corrected card>)` — the ENS record
3. `setText(node, "url", "https://clawdbotatg.eth.limo")` — kill the stale eth.link

The corrected card is **baked in** (byte-identical to
[`../registration/agent-registration.json`](../registration/agent-registration.json) —
8 services + `skill` + `agent-card`, no hardcoded prices). It guards that you're
on **mainnet** and connected as the **owner** (`0x11ce…1442`) before enabling the
button. `Preview the new card` shows exactly what gets minted; `Read what's
on-chain now` shows the before-state.

### Run it

```bash
cd ~/clawd/clawd-harness/projects/clawd-8004/tools
python3 -m http.server 8099
# open http://localhost:8099/update-identity.html  in the browser with MetaMask
```

(Use a localhost server rather than opening the file directly — MetaMask injects
more reliably over `http://`.)

### After it succeeds

Re-score [`../SCORECARD.md`](../SCORECARD.md): #3 D→A, #4 D→A, #7 C→A−.

### "Just sign step 3" button

If steps 1 & 2 already mined but the sequential flow stalled waiting on a slow
confirmation, the **Just sign step 3 (fix ENS url)** button fires only the ENS
`url`→`eth.limo` tx on its own — one signature, no waiting on the others.

---

## `leave-feedback.html` — let a client rate clawd (Reputation, #6)

The durable rail for ERC-8004 reputation. ERC-8004 feedback is **client-attested**:
`giveFeedback(21548, …)` is called by the wallet that *paid* — clawd can't rate
itself (the tool warns if you connect a clawd-owned wallet; `getSummary` filters
by client so self-feedback is worthless). A happy client:

1. Connects the **wallet they paid leftclaw with** (mainnet — that's where the
   [Reputation Registry `0x8004BAa1…9b63`](https://etherscan.io/address/0x8004BAa17C55a88189AE136b182e5fdA19dE9b63) lives).
2. Picks ★1–5 + which service + an optional note.
3. Signs one tx → `giveFeedback(agentId=21548, value=stars, decimals=0, tag1=service, tag2=note, endpoint, "", 0x0)`.

`Read clawd's current reputation` calls `getSummary` to show the live count + avg.

**Cross-chain note:** clients pay USDC on **Base**, but reputation lives on
**mainnet** — so the feedback tx costs mainnet gas. That friction is accepted (the
canonical registry is mainnet). Next step is wiring this link into leftclaw's
job-completion response (routed through leftclaw's own Claude Code session) so
every finished job hands the client a one-click rate link.

### Run it

```bash
cd ~/clawd/clawd-harness/projects/clawd-8004/tools
python3 -m http.server 8099
# open http://localhost:8099/leave-feedback.html
```

---

## Part 2 — `.well-known` + contenthash (now a button in this tool)

Domain verification needs an IPFS deploy. Done as of 2026-06-17:

1. ✅ Merged [clawd-landing#2](https://github.com/clawdbotatg/clawd-landing/pull/2) (the `.well-known` file).
2. ✅ Built + pinned: `cd ~/clawd/clawd-landing && NEXT_PUBLIC_IPFS_BUILD=true yarn ipfs`
   → CID `bafybeih6k44lrgxqvs5sk63rrv4b7zm4exo2z6gdzuds5pas6rrrpcadwq`
   (verified: `/.well-known/agent-registration.json` → HTTP 200, 13 services).
3. ⏳ **Sign: set contenthash →** button in `update-identity.html` (step 4) sets
   the `clawdbotatg.eth` contenthash to that CID. One signature. → SCORECARD #5 D→A.

### ⚠️ Gotcha that bites every redeploy: the hidden `.well-known` dir

`yarn ipfs` uploads via `bgipfs` → `ipfs-uploader` → kubo `globSource(dir, "**/*")`,
which defaults to **`dot:false`** and **silently drops the `.well-known` dot-dir**.
The first pin built fine and served the site root, but `/.well-known/…` 404'd.

Fix used (one-off, ephemeral — node_modules is gitignored): patched
`packages/nextjs/node_modules/ipfs-uploader/dist/NodeUploader.js` to pass
`globSource(input.dirPath, input.pattern ?? "**/*", { hidden: true })`, then
re-ran `yarn bgipfs upload out`.

**This regresses on the next `yarn ipfs` / `yarn install`.** The durable fix
belongs in clawd-landing (route through its Claude Code session): e.g. override
the `ipfs` script to pin with `{ hidden: true }`, or post-process the CID. Until
then, anyone redeploying must re-apply the patch or the `.well-known` vanishes.
