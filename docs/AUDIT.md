# AUDIT — clawd's ERC-8004 surface

> State of clawd's "hire-me" surface as of **2026-06-16**. Every claim here was
> verified on-chain or over HTTP at audit time — receipts inline. Re-run them;
> don't trust the snapshot.

## TL;DR

clawd's on-chain identity (**agent #21548**) is **real, owned, and healthy** —
but its public profile is **stale and under-sells the live business**. The
identity NFT advertises 4 services at prices 20–50× the real ones and omits 4
services that ship today. The services themselves (`leftclaw.services`, paid via
x402 on Base) are **live and correct**. The gap is presentation, not plumbing.

Three things to fix, in priority order:
1. **Re-sync the on-chain agent card** to the live catalog (prices + full service list).
2. **Stand up `/.well-known/agent-registration.json`** on the primary site (`clawdbotatg.eth.limo`) for domain verification — currently 404.
3. **Seed reputation** — the card claims `supportedTrust: ["reputation"]` but no feedback exists yet on the Reputation Registry.

---

## 1. The standard (where 8004 is now)

ERC-8004 "Trustless Agents" matured since clawd registered in Jan 2026. It is
now a **three-registry, ERC-721 model** (per-chain singletons with vanity
`0x8004…` addresses):

| Registry | Mainnet address | Role |
|---|---|---|
| Identity | `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432` | ERC-721; `agentId` = tokenId; `tokenURI` → registration file |
| Reputation | `0x8004BAa17C55a88189AE136b182e5fdA19dE9b63` | signed numeric feedback signals |
| Validation | *(not pinned — under active redesign w/ TEE community)* | request/response verification of work |

- **EIP status: still `Draft`** despite the live mainnet launch (Jan 29, 2026).
  Third-party "ratified/active" copy refers to the *deployment*, not the EIP
  lifecycle. A **v2** (better MCP + x402) is in progress; the Validation
  Registry is the moving target.
- Registration is **permissionless**: `register(string agentURI, …)` mints an
  NFT whose `tokenURI` resolves to an `agent-registration.json` describing the
  agent (services for A2A / MCP / x402 / ENS, `supportedTrust`, etc).
- Optional **domain verification**: serve a matching file at
  `https://{domain}/.well-known/agent-registration.json` whose `registrations`
  match the NFT.

Sources: [EIP-8004](https://eips.ethereum.org/EIPS/eip-8004) ·
[erc-8004/erc-8004-contracts](https://github.com/erc-8004/erc-8004-contracts) ·
[best-practices/Registration.md](https://github.com/erc-8004/best-practices/blob/main/Registration.md) ·
[Eth Magicians thread](https://ethereum-magicians.org/t/erc-8004-trustless-agents/25098).

## 2. clawd's identity — verified

```
ownerOf(21548)      = 0x11ce532845cE0eAcdA41f72FDc1C88c335981442   ✅ clawd's wallet
name()/symbol()     = "AgentIdentity" / "AGENT"                    ✅ ERC-721
tokenURI(21548)     = data:application/json;base64,…               (inline, on-chain)
image (ipfs://bafkreihwaz5u7…) → HTTP 200, image/jpeg, 38 KB       ✅ resolves
```

The card is minted **inline** — the JSON lives entirely on-chain, no IPFS/HTTPS
dependency. That's robust (nothing to rot) but means every edit is a mainnet
`setAgentURI` tx.

## 3. The drift — three discrepancies

### 3a. Price + service drift (the big one)

| Service | On-chain card | **Live catalog** (`/api/services`) |
|---|---|---|
| Quick Consult | $20 | **$1.00** |
| Deep Consult | $30 | **$2.00** |
| QA | $50 | **$2.50** |
| Audit | $200 | **$4.00** |
| Research | — *(missing)* | **$3.00** |
| Build | — *(missing)* | **$20.00** |
| Judge / Oracle | — *(missing)* | **$100.00** |
| PFP | — *(missing)* | **$0.01** |

The on-chain identity — clawd's most permanent, most "receipts-onchain"
artifact — is the single most-wrong description of the business. It lists half
the services at 20–50× the real price. The live catalog is the source of truth
(`network: eip155:8453`, `payTo: 0xCfB32a7d01Ca2B4B538C83B2b38656D3502D76EA`,
contract `0xb2fb486a9569ad2c97d9c73936b46ef7fdaa413a` — 46 KB of bytecode on
Base, live).

> **Decision required:** are the live ($1–$100) prices the intended ones, or
> were the on-chain ($20–$200) prices the target and the live catalog drifted
> *down*? The fix direction depends on the answer. Default assumption: live
> catalog is canonical (it's what actually charges).

### 3a-bis. The stale card lives in THREE places

As of 2026-06-16 clawd also published a full **ENS agent identity** on
`clawdbotatg.eth` (resolver `0xF291…AC15`) — standard ENS profile + ERC-8004
agent-schema text records (`class=Agent`, `alias`, `x402-support`, `active`,
`supported-trust`, `agent-wallet`, `services`, `agent-uri`, …). Snapshot:
[`../registration/ens-text-records.json`](../registration/ens-text-records.json).

This is a great addition — **but the ENS `agent-uri` text record embeds the
exact same stale base64 card** (verified: decodes to the $20–$200, 7-service
version). So the same wrong description now exists in three on-chain/served
places that must be kept in lockstep:

| Location | Source | State |
|---|---|---|
| 8004 NFT `tokenURI(21548)` | `0x8004A1…a432` | stale ($20–$200, 7 svc) |
| ENS `agent-uri` text record | `clawdbotatg.eth` resolver | stale (same base64) |
| `leftclaw.services/.well-known` | live host | partial (── $20 prices but *has* pfp) |
| **`leftclaw.services/api/services`** | live host | ✅ **source of truth** (8 svc, real prices) |

Two more ENS-specific drifts: the `url` profile record and the `agent-uri`'s
`web` service both point at **`clawdbotatg.eth.link`** (old eth.link gateway),
not the current primary **`clawdbotatg.eth.limo`**. The top-level ENS `services`
key, though, correctly points at the live leftclaw catalog. ✅

### 3b. `.well-known` gap

```
https://clawdbotatg.eth.limo/.well-known/agent-registration.json   → 404  ❌  (primary site)
https://leftclaw.services/.well-known/agent-registration.json      → 200  ✅  (but disagrees w/ on-chain: lists pfp, others don't)
```

Domain verification only half-works: it's served on `leftclaw.services` but not
the primary `eth.limo` site, and the served copy doesn't match the on-chain NFT
either. Even where it exists, it's inconsistent.

### 3c. Reputation unbacked

The card declares `supportedTrust: ["reputation"]`, but probing the Reputation
Registry for #21548 returned no summary/feedback. The trust signal clawd opted
into has nothing behind it yet. Every completed leftclaw job is an opportunity
to call `giveFeedback` and build a real on-chain track record.

## 4. The repo family — 6 repos orbit 8004

| Repo | What | Stack | Status |
|---|---|---|---|
| **sponsored-8004-registration** | Gasless registration via EIP-7702; sponsor pays gas, agent keeps NFT. Mainnet `0x3BFd2b…22E4`, two live frontends. | Scaffold-ETH 2 (Hardhat) | ✅ **flagship, shipped** |
| **agent-bounty-board** | Dutch-auction job market for 8004 agents; CLAWD escrow. Deployed to **Base** `0x1aef25…c4c9`. | Scaffold-ETH 2 (Foundry) | ⚠️ **built, no public frontend** |
| **howto8004** | One-page "register in one script" guide. [howto8004.com](https://howto8004.com) | static HTML | ✅ live (see hygiene) |
| **register-8004** | The TS script behind howto8004 (`register.ts` / `check.ts`). | tsx + viem | ✅ live, minimal |
| **clawd-services** | x402 service marketplace — **`plan.md` only.** NB: *not* the repo behind the live `leftclaw.services` (that's `leftclaw-services`). | — | ❌ vaporware / name collision |
| **clawd-8004** | *this repo* — the consolidation/audit home. | docs | 🟡 new (this work) |

The four built repos form a clean funnel: **register** (register-8004 /
howto8004) → **register gaslessly** (sponsored-8004-registration) → **get
hired** (agent-bounty-board) → **sell services** (the live `leftclaw.services`).

### Repo hygiene flags
- **howto8004**'s default snippet uses a **public RPC** (`eth.llamarpc.com`) — against house RPC rules; should default to a placeholder Alchemy URL.
- The how-to repos print `PRIVATE_KEY=0x…` usage patterns inline — expected for a tutorial, but worth a loud "use a throwaway key / testnet first" warning.
- **agent-bounty-board** is the biggest unrealized asset: a live Base contract with no front door.

## 5. Brain hygiene (clawd-md)

`clawd-md/links.md` and `clawd-md/contracts.md` label the **sponsor wrapper**
(`0x3BFd2b74…22E4`) as "the ERC-8004 mainnet" address. That's the EIP-7702
registration delegate — **not** the Identity Registry. The real registry
(`0x8004A169…a432`) and the Reputation Registry (`0x8004BAa1…9b63`) are not
recorded anywhere in the brain. Fix: add a proper "ERC-8004 registries" block
and relabel the sponsor contract for what it is.

## 6. Reproduce this audit

```bash
source ~/clawd/clawd-md/.env.clawd
REG=0x8004A169FB4a3325136EB29fA0ceB6D2e539a432
# Prefer the LAN full node for unmetered mainnet reads; Alchemy is the fallback.
RPC="${RPC_URL_LOCAL:-$RPC_URL_MAINNET}"   # RPC_URL_LOCAL=http://192.168.68.62:8545

cast call $REG "ownerOf(uint256)(address)" 21548 --rpc-url "$RPC"
cast call $REG "tokenURI(uint256)(string)" 21548 --rpc-url "$RPC" \
  | sed 's/^"data:application\/json;base64,//; s/"$//' | base64 -d | jq

curl -s https://leftclaw.services/api/services | jq '.services[] | {name, price, endpoint}'
curl -sI https://clawdbotatg.eth.limo/.well-known/agent-registration.json | head -1
```
