# SCORECARD — clawd's ERC-8004 presence

> A living grade of how well clawd is registered, discoverable, and hireable via
> ERC-8004. Re-score on every change. Goal: **get to an A.**
>
> **Current grade: `C+` (GPA 2.1 / 4.3)**  ·  **Target: `A` (GPA ≥ 3.7)**
> **Last scored: 2026-06-16** · method + receipts in [`docs/AUDIT.md`](docs/AUDIT.md)

## How to read this

Each dimension is graded `A+…F` (A+=4.3, A=4.0, A-=3.7, B=3.0, C=2.0, D=1.0,
F=0.0) and weighted. The weighted GPA is the overall grade. Update the **Grade**
column + the **Revision log** whenever a fix lands, and recompute.

## The rubric

| # | Dimension | Weight | Grade | Notes |
|---|---|---:|:---:|---|
| 1 | **Registered & self-owned** | 15% | **A+** | #21548 on `0x8004A1…a432`, `ownerOf` = clawd's wallet. Verified. Nothing to do. |
| 2 | **x402 payment integration** | 20% | **A** | `POST /api/audit` → HTTP **402** verified. 8 live services, USDC on Base. |
| 3 | **Card accuracy / freshness** | 15% | **D** | On-chain card lists 4 of 8 services at **20–50× wrong prices**. |
| 4 | **Consistency across surfaces** | 10% | **D** | 8004 NFT, ENS `agent-uri`, `.well-known` all carry the *same stale card*; live catalog is the only truth. |
| 5 | **Domain verification (`.well-known`)** | 10% | **D** | 404 on primary `eth.limo`; divergent on leftclaw. (PR [clawd-landing#2](https://github.com/clawdbotatg/clawd-landing/pull/2) staged.) |
| 6 | **Reputation / track record** | 15% | **F** | Declares `supportedTrust: reputation` with **zero** on-chain feedback. |
| 7 | **Agent-to-agent interop (A2A / MCP)** | 10% | **C** | No A2A AgentCard or MCP service entry — machines can't auto-discover skills. `catalog` endpoint partly covers it. |
| 8 | **Explorer / ecosystem presence** | 5% | **C** | Not confirmed on 8004scan at the obvious path; not in `awesome-erc8004`. |

**Weighted GPA = 2.1 → `C+`.**

> The story in one line: **the business is an A; the on-chain identity makes it
> look like a C.** Foundation (registered, self-owned, real x402 payments) is
> excellent and rare. The discoverable *profile* is stale, inconsistent, and
> unverified. The gap is the grade — and it's almost entirely fixable.

## Is the pitch true?

> *"A platform where you pay to have software written, build apps, audit
> contracts — all via x402, discoverable via 8004."*

- **Product half — TRUE & verified.** build/consult/audit/research/judge are live and x402-payable. ✅
- **Discovery half — HALF-true.** You're registered and findable, but the discovered card undersells and misprices the platform, isn't domain-verified, and has no reputation. ⚠️

## Path to an A — checklist (each item raises a dimension)

Ordered by impact. Tags: 🟢 SAFE (done in-repo) · 🟡 NEEDS-GO (sign/deploy) · status mirrors [`docs/PLAN.md`](docs/PLAN.md).

- [x] 🟢 Corrected card built + calldata staged → raises #3/#4 once signed — *done in repo*
- [x] 🟢 `.well-known` file added to the site repo (PR #2) → raises #5 once merged+deployed
- [ ] 🟡 **Re-sign the card** (8004 NFT + ENS `agent-uri` + `url`→eth.limo) → **#3 D→A, #4 D→A**
- [ ] 🟡 **Deploy `.well-known`** (merge PR #2 → `yarn ipfs` → contenthash bump) → **#5 D→A**
- [ ] 🟡 **Seed reputation** — wire `giveFeedback` into leftclaw job completion; backfill past jobs → **#6 F→B then A** *(biggest single lever)*
- [ ] 🟢→🟡 **Add A2A + MCP service entries** to the card (then re-sign) → **#7 C→A−**
- [ ] 🟡 **Confirm explorer indexing** (8004scan + PR to `awesome-erc8004`) → **#8 C→B**
- [ ] 🟡 *(stretch)* add `crypto-economic` / `tee-attestation` to `trustModels` → **#6 ceiling**

**Projected GPA after the first five items: ~3.9 → `A−`/`A`.**

## Revision log

| Date | Overall | What changed |
|---|:---:|---|
| 2026-06-16 | **C+** (2.1) | Baseline. Audit complete; corrected card + calldata + `.well-known` PR staged. Nothing signed/deployed yet. |

<!-- When a fix lands: update the relevant Grade cell, add a row here, recompute the GPA, and check the box above. -->
