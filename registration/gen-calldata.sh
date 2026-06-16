#!/usr/bin/env bash
# Generate ready-to-sign calldata to re-sync clawd's ERC-8004 / ENS agent card.
# Produces ONLY public calldata (function selectors + the public agent card).
# No private keys, no secrets. Safe to commit and to share.
#
# Usage:  ./gen-calldata.sh         # prints calldata for both inline & hosted options
# Needs:  foundry `cast` on PATH (or ~/.foundry/bin/cast)
set -euo pipefail
cd "$(dirname "$0")"

CAST="$(command -v cast || echo "$HOME/.foundry/bin/cast")"

# --- constants (all public) ---
REGISTRY=0x8004A169FB4a3325136EB29fA0ceB6D2e539a432            # ERC-8004 Identity Registry (mainnet)
RESOLVER=0xF29100983E058B709F3D539b0c765937B804AC15            # clawdbotatg.eth resolver
NODE="$($CAST namehash clawdbotatg.eth)"                       # public ENS namehash, recomputed (not hardcoded)
AGENT_ID=21548
HOSTED_URL="https://clawdbotatg.eth.limo/.well-known/agent-registration.json"
LIMO="https://clawdbotatg.eth.limo"

# --- build the inline data: URI from the corrected card (minified) ---
MIN="$(python3 -c 'import json,sys;print(json.dumps(json.load(open("agent-registration.json")),separators=(",",":")))')"
B64="$(printf '%s' "$MIN" | base64 | tr -d '\n')"
DATA_URI="data:application/json;base64,${B64}"

echo "############################################################"
echo "# corrected card (minified, ${#MIN} bytes):"
echo "$MIN"
echo
echo "############################################################"
echo "# OPTION A — INLINE (self-contained, every future edit = a tx)"
echo "############################################################"
echo "## 1) ERC-8004 NFT  ->  $REGISTRY  (mainnet)  signer: token owner 0x11ce…1442"
echo "to:       $REGISTRY"
echo "calldata: $($CAST calldata 'setAgentURI(uint256,string)' $AGENT_ID "$DATA_URI")"
echo
echo "## 2) ENS agent-uri ->  $RESOLVER  (mainnet)  signer: name owner"
echo "to:       $RESOLVER"
echo "calldata: $($CAST calldata 'setText(bytes32,string,string)' $NODE 'agent-uri' "$DATA_URI")"
echo

echo "############################################################"
echo "# OPTION B — HOSTED (points at eth.limo; future edits are free)"
echo "#   requires the .well-known file to be live first (see ../site/)"
echo "############################################################"
echo "## 1) ERC-8004 NFT  ->  $REGISTRY"
echo "to:       $REGISTRY"
echo "calldata: $($CAST calldata 'setAgentURI(uint256,string)' $AGENT_ID "$HOSTED_URL")"
echo
echo "## 2) ENS agent-uri ->  $RESOLVER"
echo "to:       $RESOLVER"
echo "calldata: $($CAST calldata 'setText(bytes32,string,string)' $NODE 'agent-uri' "$HOSTED_URL")"
echo

echo "############################################################"
echo "# SHARED — fix the stale eth.link gateway on the ENS 'url' record"
echo "############################################################"
echo "## ENS url -> $LIMO   ($RESOLVER)"
echo "to:       $RESOLVER"
echo "calldata: $($CAST calldata 'setText(bytes32,string,string)' $NODE 'url' "$LIMO")"
