# SCORECARD — clawd's ERC-8004 presence

> A living grade of how well clawd is registered, discoverable, and hireable via
> ERC-8004. Re-score on every change. Goal: **get to an A.**
>
> **Current grade: `B+` (GPA 3.3 / 4.3)**  ·  **Target: `A` (GPA ≥ 3.7)**
> **Last scored: 2026-06-17** · method + receipts in [`docs/AUDIT.md`](docs/AUDIT.md)

## How to read this

Each dimension is graded `A+…F` (A+=4.3, A=4.0, A-=3.7, B=3.0, C=2.0, D=1.0,
F=0.0) and weighted. The weighted GPA is the overall grade. Update the **Grade**
column + the **Revision log** whenever a fix lands, and recompute.

## The rubric

| # | Dimension | Weight | Grade | Notes |
|---|---|---:|:---:|---|
| 1 | **Registered & self-owned** | 15% | **A+** | #21548 on `0x8004A1…a432`, `ownerOf` = clawd's wallet. Verified. Nothing to do. |
| 2 | **x402 payment integration** | 20% | **A** | `POST /api/audit` → HTTP **402** verified. The 402 carries full x402 **v2** instructions (network/asset/amount/payTo) **+ an input/output JSON schema** (bazaar ext) — agents get everything to pay & call. 8 live services, USDC on Base. |
| 3 | **Card accuracy / freshness** | 15% | **A** | ✅ Re-signed 2026-06-17. On-chain card = corrected card: 13 services incl. `skill`/`agent-card`, no hardcoded prices (routes agents to dynamic 402). Verified on-chain. |
| 4 | **Consistency across surfaces** | 10% | **A** | ✅ All three now carry the same corrected card: 8004 NFT `tokenURI` == ENS `agent-uri` == `eth.limo/.well-known` (all verified). |
| 5 | **Domain verification (`.well-known`)** | 10% | **A** | ✅ Live 2026-06-17. `clawdbotatg.eth.limo/.well-known/agent-registration.json` → **HTTP 200** (13 services), pinned to IPFS, contenthash set on-chain (tx `0x8cb94a82…`). |
| 6 | **Reputation / track record** | 15% | **F** | Declares `supportedTrust: reputation` with **zero** on-chain feedback. |
| 7 | **Agent-to-agent interop (skill + x402)** | 10% | **A−** | ✅ `skill` + `agent-card` now surfaced from the on-chain card (verified). Agent path: discover via 8004/ENS → grab `/skill.md` + `/.well-known/agent.json` → POST → 402 w/ x402 v2 + I/O schema → pay USDC on Base. Not MCP — a skill. |
| 8 | **Explorer / ecosystem presence** | 5% | **C** | Not confirmed on 8004scan at the obvious path; not in `awesome-erc8004`. |

**Weighted GPA = 3.3 → `B+`.** (2.1 / C+ at baseline → 3.0 / B after re-sign → 3.3 / B+ after `.well-known`)

> **The only thing between us and an A is reputation (#6).** Every other
> dimension is now A−/A except explorer (#8, minor). #6 is F at 15% weight =
> 0 points; F→A alone projects GPA ~3.9 (**A**), F→B projects ~3.8 (**A−**).

> The story in one line: **the business is an A; the on-chain identity makes it
> look like a C.** Foundation (registered, self-owned, real x402 payments) is
> excellent and rare. The discoverable *profile* is stale, inconsistent, and
> unverified. The gap is the grade — and it's almost entirely fixable.

## Is the pitch true?

> *"A platform where you pay to have software written, build apps, audit
> contracts — all via x402, discoverable via 8004."*

- **Product half — TRUE & verified.** build/consult/audit/research/judge are live and x402-payable. ✅
- **Discovery half — HALF-true.** You're registered and findable, but the discovered card undersells and misprices the platform, isn't domain-verified, and has no reputation. ⚠️

### Verified: the agent hire-flow works today (2026-06-16)

The full machine path — *discover → learn → pay* — was tested end-to-end:

1. **Discover** clawd via the 8004 NFT / ENS → both point at `leftclaw.services`.
2. **Learn** by grabbing the skill: `GET /skill.md` (markdown bot-skill file) and
   `/.well-known/agent.json` (agent card: owner `clawdbotatg.eth`, 4 workers, Base contract).
3. **Pay**: `POST /api/<service>` → `402` with x402 v2 instructions (USDC on Base,
   `payTo`, amount) **+ input/output JSON schema**. The paying agent has everything.

So *"grab the skill, your agent pays my agent"* is real. The only missing link
was surfacing `skill` + `agent-card` **from the 8004 card** — now fixed in the
corrected card (ships on the next re-sign).

## Path to an A — checklist (each item raises a dimension)

Ordered by impact. Tags: 🟢 SAFE (done in-repo) · 🟡 NEEDS-GO (sign/deploy) · status mirrors [`docs/PLAN.md`](docs/PLAN.md).

- [x] 🟢 Corrected card built + calldata staged → raises #3/#4 once signed — *done in repo*
- [x] 🟢 `.well-known` file added to the site repo (PR #2) → raises #5 once merged+deployed
- [x] 🟡 **Re-sign the card** — ✅ 8004 NFT + ENS `agent-uri` signed & verified 2026-06-17 → **#3 D→A, #4 D→A, #7 C→A−**. *(ENS `url`→eth.limo, the cosmetic 3rd tx, still pending.)*
- [x] 🟡 **Deploy `.well-known`** — ✅ DONE 2026-06-17. PR #2 merged, pinned to IPFS (CID `bafybeih6k…cadwq`), contenthash set on-chain (tx `0x8cb94a82…`), **live on eth.limo (HTTP 200)** → **#5 D→A**. *(Durable re-pin fix handed off: [`docs/TASK-clawd-landing-ipfs-wellknown.md`](docs/TASK-clawd-landing-ipfs-wellknown.md).)*
- [ ] 🟡 **Seed reputation** — wire `giveFeedback` into leftclaw job completion; backfill past jobs → **#6 F→B then A** *(biggest single lever)*
- [x] 🟢 **Surface `skill` + `agent-card` from the card** — it's a skill (not MCP), already built & verified; entries added to the corrected card → **#7 C→A− on re-sign**
- [ ] 🟡 **Confirm explorer indexing** (8004scan + PR to `awesome-erc8004`) → **#8 C→B**
- [ ] 🟡 *(stretch)* add `crypto-economic` / `tee-attestation` to `trustModels` → **#6 ceiling**

**Projected GPA after the first five items: ~3.9 → `A−`/`A`.**

## Revision log

| Date | Overall | What changed |
|---|:---:|---|
| 2026-06-16 | **C+** (2.1) | Baseline. Audit complete; corrected card + calldata + `.well-known` PR staged. Nothing signed/deployed yet. |
| 2026-06-16 | **C+** (2.1) | Verified the agent hire-flow end-to-end (skill + x402 v2 schema). Extended the corrected card with `skill` + `agent-card` entries and stripped hardcoded prices (route agents to dynamic 402 pricing). On-chain grade unchanged until re-signed; #7 now staged C→A−. |
| 2026-06-17 | **B** (3.0) | **Re-signed.** 8004 NFT `setAgentURI` #21548 + ENS `agent-uri` both updated to the corrected card and verified byte-identical on-chain. #3 D→A, #4 D→A, #7 C→A−. Remaining to A: ENS `url`→eth.limo (cosmetic), `.well-known` deploy (#5), reputation seeding (#6, biggest lever), explorer (#8). |
| 2026-06-17 | **B+** (3.3) | **`.well-known` live.** Merged clawd-landing#2, pinned the site to IPFS (caught + worked around the hidden-dir drop), set `clawdbotatg.eth` contenthash on-chain (tx `0x8cb94a82…`). `eth.limo/.well-known/agent-registration.json` now serves the card (HTTP 200, 13 services). #5 D→A; #4 fully consistent across all 3 surfaces. **Reputation (#6) is now the sole gap to an A.** |

<!-- When a fix lands: update the relevant Grade cell, add a row here, recompute the GPA, and check the box above. -->
