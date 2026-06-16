# PLAN — make clawd's 8004 profile professional & ready for service

> Goal: a customer who finds clawd via its ERC-8004 identity sees **one coherent,
> trustworthy, hireable offering** — accurate prices, verifiable identity, a real
> track record. Plumbing is done; this closes the presentation gap.

Each step is tagged:
- **🟢 SAFE** — docs/data/local; no outward or on-chain effect. Enacted in this repo.
- **🟡 NEEDS-GO** — outward-facing or on-chain (real gas, public identity, live sites). Prepared here; **requires explicit go before firing.**
- **🔵 DECISION** — needs a human call before the dependent step can run.

---

## Phase 0 — Document the surface  🟢 DONE (this repo)

- [x] Audit on-chain identity #21548 + the three drift bugs → [`AUDIT.md`](AUDIT.md)
- [x] Map the full hire funnel (identity → services → governance → tooling) → [`SURFACE.md`](SURFACE.md)
- [x] Produce the corrected canonical agent card → [`../registration/agent-registration.json`](../registration/agent-registration.json)
- [x] Snapshot the stale on-chain card for diffing → [`../registration/current-onchain-card.json`](../registration/current-onchain-card.json)

## Phase 1 — Decide the canonical truth  🔵 DECISION

1. **Pricing.** Live catalog charges $0.01–$100; the on-chain card claims
   $20–$200 for 4 services. **Which is canonical?**
   - *If live prices are right* (default assumption) → regenerate the card from
     the catalog (already done) and push it.
   - *If the higher prices were intended* → fix `leftclaw.services` first, then
     regenerate. Don't ship an identity that undercuts the intended business.
2. **Inline vs. hosted card.** Keep the JSON minted inline (self-contained, but
   every edit is a mainnet tx) **or** point `tokenURI` at
   `https://clawdbotatg.eth.limo/.well-known/agent-registration.json` (free
   future edits, adds a host dependency).
   - **Recommendation:** go **hosted**, with the inline JSON kept as a fallback
     snapshot in this repo. Future price changes then need no gas, and the
     `.well-known` file (Phase 3) becomes the single source of truth.

## Phase 2 — Re-sync the stale card EVERYWHERE  🟡 NEEDS-GO

*Depends on Phase 1.* The same stale card lives in **three** places that must
move together. Prepared in [`../registration/README.md`](../registration/README.md).

- [ ] Confirm pricing + inline-vs-hosted (Phase 1)
- [ ] **8004 NFT:** `setAgentURI(21548, <corrected card>)` on `0x8004A1…a432` (mainnet, clawd's wallet)
- [ ] **ENS `agent-uri`:** `setText(node, "agent-uri", <corrected card>)` on resolver `0xF291…AC15`
- [ ] **ENS `url` + card `web`:** change `clawdbotatg.eth.link` → `clawdbotatg.eth.limo`
- [ ] **`.well-known`:** regenerate (Phase 3) so it matches
- [ ] **Get go** before any broadcast (real gas; changes clawd's public identity)
- [ ] Verify all four agree: `tokenURI(21548)` == ENS `agent-uri` == `.well-known` == live catalog

> Both on-chain writes (8004 NFT + ENS `setText`) can be batched in one signing
> session — the "ENS agent identity" dApp the team built today already offers a
> one-tx flow plus a "Source fix on-chain ERC-8004" button that rewrites the
> embedded service URLs. Use it, but feed it the **corrected** card, not the
> prefilled stale one.

## Phase 3 — Domain verification on the primary site  🟡 NEEDS-GO

`clawdbotatg.eth.limo/.well-known/agent-registration.json` is **404** today.
- [ ] Add the corrected `agent-registration.json` to the site repo behind
      `clawdbotatg.eth` at path `/.well-known/agent-registration.json`
- [ ] Re-deploy the site (IPFS via BGIPFS → ENS contenthash)
- [ ] Make `leftclaw.services/.well-known/…` match it (it currently diverges)
- [ ] Verify all three agree: on-chain card == eth.limo == leftclaw

## Phase 4 — Seed reputation  🟡 NEEDS-GO

The card claims `supportedTrust: ["reputation"]` with nothing behind it.
- [ ] After each completed leftclaw job, write `giveFeedback(...)` to the
      Reputation Registry `0x8004BAa1…9b63` for #21548 (or have the client do it)
- [ ] Backfill a few real past jobs if records exist
- [ ] Surface the on-chain rating on `clawdbotatg.eth.limo` ("verified track record")

## Phase 5 — Launch the unrealized asset  🟡 NEEDS-GO

**agent-bounty-board** has a live Base contract (`0x1aef25…c4c9`) and a full
SE-2 app but **no public frontend**. Biggest "built but dark" item.
- [ ] Decide if it's part of the professional offering or archived
- [ ] If yes: deploy its frontend (IPFS/Vercel) and link it from the surface

## Phase 6 — Hygiene  🟢 SAFE / 🟡 small

- [ ] **brain:** add an "ERC-8004 registries" block to `clawd-md/contracts.md`
      with the real Identity (`0x8004A1…a432`) + Reputation (`0x8004BA…9b63`)
      addresses, and relabel `0x3BFd2b…22E4` as the **EIP-7702 sponsor delegate**
      (it is mislabeled as "the ERC-8004 mainnet address"). 🟢
- [ ] **howto8004:** swap the default `eth.llamarpc.com` public RPC in the
      snippet for an Alchemy placeholder; add a "throwaway key / testnet first"
      warning next to the `PRIVATE_KEY=0x…` examples. 🟡 (touches a live repo)

---

## Sequence at a glance

```
Phase 0 (done) ─▶ Phase 1 DECISION ─▶ Phase 2 push card ─▶ Phase 3 .well-known ─▶ Phase 4 reputation
                       │                                                              
                       └─▶ Phase 5 (independent) · Phase 6 hygiene (anytime)
```

**Smallest high-integrity slice if you want one move:** Phase 1 decision →
Phase 2 (re-sync the on-chain card). That alone turns the most-wrong, most-
permanent description of the business into an accurate one.
