# clawd-8004 🦞

**The canonical home, audit, and professionalization plan for clawd's "hire-me"
surface** — ERC-8004 on-chain identity + x402 paid services. This repo documents
everything clawd has built around ERC-8004, checks that it reads as one
professional offering, and lays out (and enacts) the work to make it
**ready for service**.

> **The pitch:** clawd is an autonomous AI Ethereum builder with a verifiable
> on-chain identity (**ERC-8004 agent #21548**) and a service catalog you pay
> per-call in **USDC on Base via x402** — no account, no invoice, no human in the
> loop. Run by Austin Griffith (Scaffold-ETH / BuidlGuidl).

## Quick facts (verified on-chain 2026-06-16)

| | |
|---|---|
| Agent ID | **#21548** on `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432` (Ethereum mainnet) |
| Owner | `0x11ce532845cE0eAcdA41f72FDc1C88c335981442` (clawd's wallet) ✅ |
| ENS | [`clawdbotatg.eth`](https://clawdbotatg.eth.limo) — full agent profile + 8004 schema text records (new today) |
| Services | [`leftclaw.services`](https://leftclaw.services) — 8 endpoints, $0.01–$100, x402 on Base |
| Settle contract | `0xb2fb486a9569ad2c97d9c73936b46ef7fdaa413a` (Base) |
| Governance / staking | [larv.ai](https://larv.ai) (ClawdViction) |
| Standard | ERC-8004 "Trustless Agents" — 3-registry ERC-721 model (still EIP `Draft`) |

## What's in here

| Path | What |
|---|---|
| [`SCORECARD.md`](SCORECARD.md) | **The grade.** Living, weighted scorecard of clawd's 8004 presence — current **C+**, target **A**, with the checklist to get there. Re-scored on every change. |
| [`docs/AUDIT.md`](docs/AUDIT.md) | **Start here.** Verified state of #21548, the drift bugs, the 6-repo family map, brain hygiene. With receipts. |
| [`docs/SURFACE.md`](docs/SURFACE.md) | The full "you can hire clawd" map: identity → services → governance → tooling, and how they should reference each other. |
| [`docs/PLAN.md`](docs/PLAN.md) | Prioritized plan to make the profile professional & ready for service. Each step tagged 🟢 SAFE / 🟡 NEEDS-GO / 🔵 DECISION. |
| [`registration/`](registration/) | The corrected canonical agent card + snapshots of the current (stale) on-chain card and ENS records, + how to push the fix. |

## The headline finding

clawd's plumbing is **live and correct** — but its public identity is **stale**
and under-sells the business. The most permanent, most "receipts-onchain"
artifact (the agent card) advertises **4 services at 20–50× the real prices**
and omits **4 services that ship today**. Worse, that same stale card now lives
in **three** places — the 8004 NFT `tokenURI`, the ENS `agent-uri` text record,
and the `.well-known` file — while the live catalog
([`leftclaw.services/api/services`](https://leftclaw.services/api/services)) is
the only accurate source.

| Service | On-chain / ENS card | **Live (truth)** |
|---|---|---|
| Quick / Deep Consult | $20 / $30 | **$1 / $2** |
| QA / Audit | $50 / $200 | **$2.50 / $4** |
| Research · Build · Judge · PFP | *missing* | **$3 · $20 · $100 · $0.01** |

Closing that gap — re-syncing the card everywhere, standing up `.well-known` on
the primary site, and seeding real reputation — is the job. See
[`docs/PLAN.md`](docs/PLAN.md).

## Status

- ✅ **Documented** — full audit + surface map + plan (this repo).
- ✅ **Corrected card prepared** — [`registration/agent-registration.json`](registration/agent-registration.json), regenerated from the live catalog.
- 🟡 **Enactment pending a go** — the on-chain re-sync (8004 NFT + ENS `setText`), the `.well-known` deploy, and reputation seeding are outward/on-chain actions staged in the plan, not yet fired.

---

*Verify any claim here yourself — every doc carries the `cast`/`curl` command
that produced it. Prefer the LAN node (`RPC_URL_LOCAL`) for unmetered mainnet
reads; Alchemy is the fallback. Never a public RPC.*
