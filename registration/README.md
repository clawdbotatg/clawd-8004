# registration/ — clawd's ERC-8004 agent card

The on-chain identity for **agent #21548** on the canonical Identity Registry
`0x8004A169FB4a3325136EB29fA0ceB6D2e539a432` (Ethereum mainnet, namespace
`eip155:1`). The registry is an ERC-721; clawd's wallet
`0x11ce532845cE0eAcdA41f72FDc1C88c335981442` holds the token.

| File | What |
|---|---|
| [`agent-registration.json`](agent-registration.json) | **The corrected, canonical card.** Source of truth — regenerated from the live [`leftclaw.services/api/services`](https://leftclaw.services/api/services) catalog. This is what #21548 *should* advertise. |
| [`current-onchain-card.json`](current-onchain-card.json) | Snapshot of what #21548 advertises **right now** (stale). Kept for diffing. |

## Why they differ

The live card is **stale**: it lists 4 services at prices 20–50× the real
ones ($20/$30/$50/$200 vs. the live $1/$2/$2.50/$4) and is missing four
services that ship today (`research`, `build`, `judge`, `pfp`). Full analysis
in [`../docs/AUDIT.md`](../docs/AUDIT.md). The corrected card fixes prices,
adds the missing endpoints, and points `web` at the live `eth.limo` host.

## Verify the current on-chain card yourself

```bash
source ~/clawd/clawd-md/.env.clawd
REG=0x8004A169FB4a3325136EB29fA0ceB6D2e539a432
RPC="${RPC_URL_LOCAL:-$RPC_URL_MAINNET}"   # LAN full node first (192.168.68.62:8545), Alchemy fallback
# owner (should be clawd's wallet)
cast call $REG "ownerOf(uint256)(address)" 21548 --rpc-url "$RPC"
# decode the inline data: URI to JSON
cast call $REG "tokenURI(uint256)(string)" 21548 --rpc-url "$RPC" \
  | sed 's/^"data:application\/json;base64,//; s/"$//' | base64 -d | jq
```

## Pushing the corrected card — STAGED, do not run blind

The card is minted **inline** (a `data:application/json;base64,…` URI), so the
update is a single `setAgentURI(uint256,string)` call from clawd's wallet on
**mainnet** — it costs real gas and changes clawd's public identity. **Get an
explicit go before broadcasting.** Two open decisions first (see
[`../docs/PLAN.md`](../docs/PLAN.md)):

1. **Confirm pricing.** The corrected card mirrors the *live* (cheaper) prices.
   If the higher on-chain prices were the intended ones, fix the live catalog
   instead and regenerate this card.
2. **Hosted vs. inline.** Inline = self-contained, no off-chain dependency, but
   every edit is a mainnet tx. Pointing `tokenURI` at
   `https://clawdbotatg.eth.limo/.well-known/agent-registration.json` makes
   future edits free — at the cost of a live-host dependency. Recommendation in
   the plan.

When cleared, the call is (pseudocode — exact encoding of the inline URI is
prepared at enact time):

```bash
# DATA_URI = "data:application/json;base64,$(base64 -w0 agent-registration.json)"
cast send $REG "setAgentURI(uint256,string)" 21548 "$DATA_URI" \
  --rpc-url "$RPC_URL_MAINNET" --account <clawd-wallet>   # NEVER inline the key
```
