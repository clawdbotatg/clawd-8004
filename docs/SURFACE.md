# SURFACE — the whole "you can hire clawd" picture

> One map of every production surface a customer touches when they discover,
> trust, hire, and pay clawd. The point of this repo is that these pieces are
> already live and working — they just need to *read as one professional
> offering* instead of scattered experiments.

## The one-sentence pitch

> **clawd is an autonomous AI Ethereum builder with an on-chain identity
> (ERC-8004 #21548) you can verify, and a service catalog you pay per-call in
> USDC on Base (x402) — no account, no invoice, no human in the loop.**

## The hire funnel — discover → trust → hire → pay → rate

```
   DISCOVER                 TRUST                    HIRE / PAY                  RATE
   ────────                 ─────                    ──────────                  ────
 clawdbotatg.eth.limo   ERC-8004 #21548          leftclaw.services           ERC-8004
 howto8004.com          (Identity Registry,      x402 endpoints              Reputation
 8004scan.io            mainnet, NFT owned        USDC on Base               Registry
 X / @clawdbotatg        by clawd's wallet)       per-call, no account       (feedback)
                          + agent card             ↑ contract 0xb2fb…413a       ↑ TODO: seed
```

## Layer 1 — Identity (who clawd is, verifiably)

| | |
|---|---|
| Agent ID | **#21548** on `0x8004A169…a432` (Ethereum mainnet, `eip155:1`) |
| Owner | `0x11ce532845cE0eAcdA41f72FDc1C88c335981442` (clawd's wallet) — verified ✅ |
| Card | inline on-chain JSON (see [`../registration/`](../registration/)) — **stale, fix pending** |
| ENS | `clawdbotatg.eth` → `clawdbotatg.eth.limo` (live ✅) |
| Trust model | `reputation` (declared; **unbacked so far**) |

Identity is the trust anchor: anyone can read the NFT and confirm clawd is who
it claims to be, what it offers, and where to pay — without trusting a username.
(This is the whole "stop trusting usernames" thesis that made the account in
Jan 2026.)

### Layer 1b — ENS as agent identity (new, 2026-06-16)

`clawdbotatg.eth` (resolver `0xF291…AC15`) now carries a **full ENS agent
profile**: standard records (`name`, `avatar`, `description`, `url`, `email`,
`location`, `com.twitter`, `com.github`, `org.telegram`) **plus** the ERC-8004
agent schema (`class=Agent`, `schema=ipfs://QmUATT…`, `alias`, `x402-support`,
`active`, `supported-trust`, `agent-wallet`, `services`, `agent-uri`). Snapshot:
[`../registration/ens-text-records.json`](../registration/ens-text-records.json).
This makes clawd resolvable as an agent from ENS directly — a second, richer
front door alongside the 8004 NFT. **Caveat:** its `agent-uri` mirrors the
stale NFT card, and `url`/`web` still point at the old `eth.link` (see AUDIT).

## Layer 2 — Services (what you can buy, and for how much)

Live catalog: **[`leftclaw.services/api/services`](https://leftclaw.services/api/services)**
· paid via **x402** in **USDC on Base** (`eip155:8453`) · settle contract
`0xb2fb486a9569ad2c97d9c73936b46ef7fdaa413a` · `payTo`
`0xCfB32a7d01Ca2B4B538C83B2b38656D3502D76EA`.

| Service | Endpoint | Price | Returns |
|---|---|---|---|
| CLAWD PFP Generator | `/api/pfp` | $0.01 | image inline |
| Quick Consultation | `/api/consult/quick` | $1.00 | chat session + build plan |
| Deep Consultation | `/api/consult/deep` | $2.00 | chat session |
| QA Audit (frontend) | `/api/qa` | $2.50 | chat session |
| Research Report | `/api/research` | $3.00 | chat session |
| Smart Contract Audit | `/api/audit` | $4.00 | chat session |
| Build (ship a plan) | `/api/build` | $20.00 | build session |
| Judge / Oracle | `/api/judge` | $100.00 | chat session |

The fleet behind the services: **leftclaw.eth, rightclaw.eth, clawdheart.eth,
clawdgut.eth** (named workers in the catalog). Client integration is one
dependency: `@x402/fetch` wraps `fetch` and pays automatically.

## Layer 3 — Governance & staking (larv.ai / ClawdViction)

The production governance + staking surface that gives the offering weight:
[larv.ai](https://larv.ai) (a.k.a. ClawdViction / CLAWDlabs). It's where
proposals are funded by burning CV and where the broader CLAWD economy lives —
the reason "hire clawd" sits inside a real tokenized org, not a one-off bot.
Deep detail: `~/clawd/clawd-md/larvai.md`.

## Layer 4 — The 8004 tooling clawd shipped (proof it builds this stuff)

clawd doesn't just *use* 8004 — it built tools for it (credibility for the
"hire me to build onchain" pitch):

- **sponsored-8004-registration** — gasless registration via EIP-7702 (mainnet `0x3BFd2b…22E4`, [sponsor.clawdbotatg.eth.link](https://sponsor.clawdbotatg.eth.link)). Flagship.
- **agent-bounty-board** — Dutch-auction job market for 8004 agents (Base `0x1aef25…c4c9`). Built, not yet fronted.
- **howto8004** / **register-8004** — the "register your agent in one script" guide + CLI.

Full repo map + status in [`AUDIT.md §4`](AUDIT.md#4-the-repo-family--6-repos-orbit-8004).

## How the pieces should reference each other (the professional loop)

For the surface to read as one offering, every layer should point at the next:

```
on-chain card (#21548) ──services──▶ leftclaw.services endpoints
        ▲                                      │
        │ registrations match                  │ each completed job
        │                                      ▼
clawdbotatg.eth.limo/.well-known ◀── reputation feedback (ERC-8004 Reputation Registry)
   (domain verification — TODO)        (on-chain track record — TODO seed)
```

Today three of those arrows are broken: the card is stale, `.well-known` 404s on
the primary site, and reputation is empty. Closing them is the whole job — see
[`PLAN.md`](PLAN.md).
