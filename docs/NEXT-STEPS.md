# NEXT STEPS — getting clawd's 8004 presence to an A

> Snapshot 2026-06-18. Current grade **B+ (GPA 3.3)**, baseline was C+ (2.1).
> Full rubric + receipts: [`../SCORECARD.md`](../SCORECARD.md).

## Where we are

| # | Dimension | Grade | State |
|---|---|:---:|---|
| 1 | Registered & self-owned | A+ | done |
| 2 | x402 payments | A | done |
| 3 | Card accuracy | A | ✅ re-signed 2026-06-17 |
| 4 | Consistency (3 surfaces) | A | ✅ NFT == ENS == .well-known |
| 5 | Domain verification | A | ✅ live on eth.limo (HTTP 200) |
| 6 | **Reputation** | **F** | **← the only real gap to an A** |
| 7 | Interop (skill + x402) | A− | ✅ surfaced on the card |
| 8 | Explorer presence | C | minor (5% weight) |

**The math:** #6 is F at 15% weight = a flat zero. F→B → ~3.8 (**A−**); F→A → ~3.9 (**A**). Everything else is already A−/A except explorer.

---

## #6 Reputation — the main job (PAUSED, resume here)

### What's already done
- **The rail is built:** [`../tools/leave-feedback.html`](../tools/leave-feedback.html) — a client connects the wallet they paid with, picks ★1–5 + service, signs one `giveFeedback(21548,…)` tx on the **mainnet** Reputation Registry `0x8004BAa1…9b63`. Warns on clawd-owned wallets; reads back `getSummary`. Round-tripped against the real ABI from the reference impl.
- **The constraint is understood:** ERC-8004 feedback is **client-attested** — `msg.sender` is the rater. clawd can't rate itself (self-feedback filters out in `getSummary`). Real reputation = real clients attesting from their own wallets.
- **Cross-chain reality:** clients pay USDC on **Base**; the Reputation Registry is on **mainnet**. Decision locked: **attest on mainnet** (canonical), accept the gas friction.

### What we found on-chain (Base USDC payment history, pulled 2026-06-18)
Real activity exists — it is NOT zero. But it's a mix; chain data alone can't separate genuine third-party clients from clawd's own test wallets.

- **payTo `0x11ce…1442`:** 26 payments from **18 distinct wallets** (0.0001–10 USDC).
- **catalog contract `0xb2fb486a…413a`:** 25 payments from **5 wallets** — the biggest real amounts: **41, 21, 20.4 USDC**.
- **Identified (excluded as attesters):**
  - `0x9008d19f…ab41` (10 USDC) = **CoW Protocol settlement contract** (a DEX swap, not a client).
  - `0xdca4e95c…cd0b` = **clawdhead.eth** (clawd's own family wallet — self-dealing).
  - `0xcfb32a7d…76ea` (115 USDC, 17×) = the **x402 facilitator/settlement** address (infrastructure).
- **Most promising real-client candidates** (meaningful $, no ENS, need owner to confirm they're third parties): `0x8d6fb6c5…e22d` (41), `0x9f01f827…bf55` (21), `0x287820cb…1d3c` (20.4 USDC).

> Re-pull anytime: Alchemy key is in `~/clawd/clawd-md/.env.clawd` (`ALCHEMY_API_KEY`,
> works from this box's IP). Query `alchemy_getAssetTransfers` for USDC
> (`0x8335…2913`) `toAddress` = payTo / catalog contract. **Never commit the key.**

### OPEN QUESTION FOR AUSTIN (blocks the next move)
Among the real payers — especially the 41/21/20 USDC catalog clients and the
0.25–1.5 USDC payTo ones — **which are genuine third-party clients** (vs. your own
test wallets)? Only you know. This decides whether we do targeted backfill outreach
or go pure-forward.

### Next actions (once the question is answered)
1. **Wire the rate-link into leftclaw job-completion** (durable, honest accrual) —
   every finished job hands the client a one-click rate-link. leftclaw is a separate
   repo → **route through its own Claude Code session**; write a handoff spec like
   [`TASK-clawd-landing-ipfs-wellknown.md`](TASK-clawd-landing-ipfs-wellknown.md).
2. **Host `leave-feedback.html`** somewhere shareable (it's local-only now) +
   prep per-client links for any confirmed real clients to attest → fastest path to
   non-zero on-chain feedback.
3. After the first real attestations land, **re-score #6** and recompute the GPA.

---

## Loose ends (small, optional)

- **#3-cosmetic — finish `eth.link → eth.limo`:** the ENS `url` text record still
  reads `eth.link`. The **"Just sign step 3"** button in
  [`../tools/update-identity.html`](../tools/update-identity.html) fixes it in one
  signature. Not graded, just tidy.
- **#8 Explorer (C→B):** confirm #21548 is indexed on 8004scan; open a PR to add
  clawd to `awesome-erc8004`. Low weight (5%) but easy points.
- **Durable `.well-known` fix (already handed off):** the IPFS re-pin gotcha — see
  [`TASK-clawd-landing-ipfs-wellknown.md`](TASK-clawd-landing-ipfs-wellknown.md).
  Current pin serves fine; this just prevents a future `yarn ipfs` from regressing.

---

## How to resume
Re-read this file + `SCORECARD.md`. The single highest-leverage move is **#6**:
answer the open question above, then build the leftclaw job-completion wiring
(durable) and/or host the feedback tool for backfill (fast). Target after first
real attestations: **A− / A**.
