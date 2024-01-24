# Runners NFT contract

Contract deployed on Avalanche Fuji Testnet: [view on testnet.snowtrace.io](https://testnet.snowtrace.io/address/0x02E0CDc64f273804760A9b5c3E336463EE3c3F7E)

Collection on opensea: [view](https://testnets.opensea.io/collection/runners-453)

Player can mint NFT by calling the function `safeMint(address to, uint256 charId)`, where `charId` is one of the 5 commands: "Mystic", "Stars", "Flames", "Guardians", "Wizard".

To make a move, call the function `run(uint256 tokenId)`. The move will randomly change player's distance and round using the ChainLink VRF service.

ChainLink VRF uses a subscription: [1192](https://vrf.chain.link/fuji/1192)

To store NFT images used [Pinata](https://www.pinata.cloud/). JSON URI is stored onchain.
