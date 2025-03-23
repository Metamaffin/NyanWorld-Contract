# NyanWorld Smart Contract
A simple ERC721-based smart contract for registering, bidding, and voting on "Nyan" NFTs with charity donation features.

## Overview
- **Language**: Solidity ^0.8.0
- **Framework**: OpenZeppelin Upgradeable (UUPS)
- **Features**:
  - Mint NFTs for Nyans with names and tags
  - Auction system with 10% charity fee
  - Voting mechanism to choose a winner
- **Tested**: Deployed and verified on Remix (Remix VM / Sepolia testnet)

## Deployment
Deployed successfully on Remix. Initial Nyan ("にゃんこ！") minted and functions (`registerNyan`, `bid`, `vote`) tested.

## License
MIT License

## Dependencies
- OpenZeppelin Contracts Upgradeable: https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable
