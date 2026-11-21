# CRYPT-BOUND
**Zero-Knowledge / Commit-Reveal Tactical JRPG**  
*Built for the JRPG Crypto Browser Games Jam*

## Overview
**CRYPT-BOUND** is a browser-based, turn-based tactical JRPG roguelite where cryptographic commit-reveal mechanics directly drive combat strategy.

Every floor, you battle a dungeon guardian whose next move is cryptographically locked via a salted hash commitment (`hash(move + salt)`) before you select your action:
- **Strike** beats **Arcane Counter** (Critical Hit)
- **Aegis Guard** beats **Strike** (Critical Hit)
- **Arcane Counter** beats **Aegis Guard** (Critical Hit)
- **Matching Actions** trigger a **Clash** (both sides take 10 chip damage)

Clearing a floor deterministically forges a **Cryptographic Relic** from the run's turn entropy, permanently boosting your attack power.

## How the Crypto Integration Works
- **Gameplay-First Verification:** Commit-reveal verification IS the core combat loop. At the start of each turn, the boss commits `hash(move + salt)`. Once you lock in your move, the salt is revealed and verified against the initial commitment.
- **Zero-Friction Judge Mode:** Automatically generates an ephemeral in-browser burner session address (`0x...`) and runs real-time `SHA-256` commit-reveal proofs via the Web Crypto API—requiring zero wallet popups, zero gas, and zero real funds.
- **On-Chain Smart Contract (`contracts/CryptBoundArena.sol`):** EVM-compatible Solidity verifier that validates `keccak256(abi.encodePacked(revealedBossAction, salt)) == bossCommit` and records forged Relics on-chain.

## Tech Stack
- **Frontend & Engine:** HTML5 Canvas, Vanilla JavaScript, CSS3
- **Audio:** Native Web Audio API procedural chiptune synthesizer
- **Cryptography & Smart Contracts:** Web Crypto API (`SHA-256`) & Solidity `^0.8.24`

## Hackathon Disclosures
- **Third-Party Game Assets:** None. All in-game sprites, animations, UI, and chiptune sound effects are 100% procedurally generated in code during the jam window.
- **AI Tools Used:** AI assistance (Gemini) was used during the jam for brainstorming the commit-reveal combat loop, structuring the Solidity contract and frontend prototype, drafting documentation, and generating the project logo crest.
