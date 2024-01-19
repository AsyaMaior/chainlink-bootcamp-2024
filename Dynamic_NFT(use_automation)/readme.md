# Dynamic Photo Album NFT

You can mint an NFT that will automatically rotate photos after an interval of time. To mint call function `safeMint(address to)`.

Rotation interval set during deploy: 120 seconds.

[Subscription](https://automation.chain.link/sepolia/107428927110495343608235338654281955894599870807659658128836521779514061709034) must be activated for photos to be rotated. If subscription is paused you can create a new subscription.

Only the last nft is automatically rotated. To change the image on previous NFTs call the function `rotatePhoto(uint256 _tokenId)`.

Smart contract on [etherscan](https://sepolia.etherscan.io/address/0x4568805637138d96f8863894024904a683db62da)

[Photo Album Space Chainlink Bootcamp 2024 Collection](https://testnets.opensea.io/collection/photo-album-space-chainlink-bootcamp-2024) on OpenSea.

To store NFT images and `json` used [Pinata](https://www.pinata.cloud/)
