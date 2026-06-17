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

---

## Part 2 — `.well-known` + contenthash (not in this tool yet)

Domain verification needs an IPFS deploy, which isn't a pure wallet click:

1. Merge [clawd-landing#2](https://github.com/clawdbotatg/clawd-landing/pull/2).
2. `cd ~/clawd/clawd-landing && NEXT_PUBLIC_IPFS_BUILD=true yarn ipfs` → new CID.
3. Set the `clawdbotatg.eth` contenthash to that CID (MetaMask / ENS app).

Once we have the CID, a "Set contenthash" button can be added here so step 3 is
also one click. See [`../site/README.md`](../site/README.md).
