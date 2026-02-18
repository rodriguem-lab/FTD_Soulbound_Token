# FTD_Soulbound_Token

FTD Soulbound Token (SBT)
Overview

Implementation of a Soulbound Token (SBT) used as a non-transferable academic credential for the FTD Master program.

Each student receives one non-transferable ERC-721 token issued by the institution.

Features

ERC-721 based

Non-transferable (Soulbound behavior)

One token per address

Batch minting

Revocation possible

Metadata stored on IPFS

Optional multi-signature governance (Safe)

Smart Contract

Solidity ^0.8.20

OpenZeppelin v5

Network: Ethereum (Sepolia testnet)

Main functions:

mint(address student)

mintBatch(address[] students)

revoke(uint256 tokenId)

setCohortURI(string newURI)

Transfers are disabled at the contract level.

Metadata Architecture

Each cohort has:

Cohort image → uploaded to IPFS

Metadata JSON → uploaded to IPFS

Contract tokenURI() returns metadata CID

Example metadata:

{
  "name": "FTD Master 2026 - Soulbound Credential",
  "image": "ipfs://CID_IMAGE"
}

Deployment Guide

Upload image to IPFS

Create metadata.json

Deploy contract in Remix

Insert program name & cohort year

(Optional) Transfer ownership to Safe

Mint tokens

Verification

A credential can be verified by:

Checking the student's wallet address

Confirming presence of the SBT

Verifying the issuer address

Governance Option

Ownership can be transferred to a Safe multi-signature wallet for institutional control.
Soulbound Token implementation for FTD Master cohort 
