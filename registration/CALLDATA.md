# CALLDATA — ready-to-sign re-sync of clawd's agent card

> Public calldata only (function selectors + the public agent card). **No keys,
> no secrets.** Regenerate anytime with [`./gen-calldata.sh`](gen-calldata.sh).
>
> ⚠️ These are **mainnet** writes that change clawd's public identity and cost
> real gas. **Get an explicit go before broadcasting.** Sign from the token /
> name owner `0x11ce532845cE0eAcdA41f72FDc1C88c335981442`.

## What gets re-synced & where

| Target | Contract | Function | Why |
|---|---|---|---|
| ERC-8004 NFT #21548 | `0x8004A169…a432` (registry) | `setAgentURI(uint256,string)` `0x0af28bd3` | replace stale $20–$200 card |
| ENS `agent-uri` | `0xF291…AC15` (resolver) | `setText(bytes32,string,string)` `0x10f13a8c` | same card on ENS |
| ENS `url` | `0xF291…AC15` (resolver) | `setText(...)` | `eth.link` → `eth.limo` |

`node = namehash(clawdbotatg.eth) = 0x1329ede6…535b0`.

## Two ways to set the card — pick one

- **Option A · Inline** — mint the full corrected JSON on-chain as a
  `data:application/json;base64,…` URI. Self-contained, nothing to rot, but every
  future price edit is another mainnet tx. Calldata is large (~2.7 KB) — produced
  by [`gen-calldata.sh`](gen-calldata.sh) (the `OPTION A` block).
- **Option B · Hosted** *(recommended)* — point the on-chain URIs at
  `https://clawdbotatg.eth.limo/.well-known/agent-registration.json`. Future edits
  are free (just redeploy the file). **Requires the `.well-known` file live first**
  — staged in [`../site/`](../site/). Clean, short calldata below.

### Option B calldata (hosted)

```
# 1) ERC-8004 NFT  →  0x8004A169FB4a3325136EB29fA0ceB6D2e539a432
0x0af28bd3000000000000000000000000000000000000000000000000000000000000542c0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000004068747470733a2f2f636c617764626f746174672e6574682e6c696d6f2f2e77656c6c2d6b6e6f776e2f6167656e742d726567697374726174696f6e2e6a736f6e

# 2) ENS agent-uri  →  0xF29100983E058B709F3D539b0c765937B804AC15
0x10f13a8c1329ede62457a60dd14625632c6fa931c428408b8171e64a4d35f3f496a535b0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000096167656e742d7572690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004068747470733a2f2f636c617764626f746174672e6574682e6c696d6f2f2e77656c6c2d6b6e6f776e2f6167656e742d726567697374726174696f6e2e6a736f6e
```

### Shared — fix the stale `eth.link` gateway (both options)

```
# ENS url  →  https://clawdbotatg.eth.limo   (0xF29100983E058B709F3D539b0c765937B804AC15)
0x10f13a8c1329ede62457a60dd14625632c6fa931c428408b8171e64a4d35f3f496a535b0000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000375726c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c68747470733a2f2f636c617764626f746174672e6574682e6c696d6f00000000
```

## Easiest path: the team's ENS-identity dApp

The "ENS agent identity" dApp built 2026-06-16 already batches the 8004 NFT +
ENS `setText` writes in one signing session and has a "Source fix on-chain
ERC-8004" button. **Use it — but paste the corrected card** from
[`agent-registration.json`](agent-registration.json), not the prefilled stale
one, and switch the `web`/`url` fields to `eth.limo`.

## Decode-verify any calldata before signing

```bash
cast calldata-decode 'setAgentURI(uint256,string)' <calldata>
cast calldata-decode 'setText(bytes32,string,string)' <calldata>
```
