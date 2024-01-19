// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Fuji

import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.6.0/utils/Base64.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract Runners is ERC721, ERC721URIStorage, VRFConsumerBaseV2  {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // VRF
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */          

    // Fuji coordinator
    // https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;
    bytes32 keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;

    // past requests Ids.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256[] public lastRandomWords;

    // Your subscription ID.
    uint64 public s_subscriptionId;

    //Runners NFT
    Counters.Counter public tokenIdCounter;
    string[] commands_image = [
        "https://ipfs.io/ipfs/QmQbTc847r4QtdDw56Vk8qHe8EiyMYwAsfrP37k9vSjiME/1.jpg",
        "https://ipfs.io/ipfs/QmQbTc847r4QtdDw56Vk8qHe8EiyMYwAsfrP37k9vSjiME/2.jpg",
        "https://ipfs.io/ipfs/QmQbTc847r4QtdDw56Vk8qHe8EiyMYwAsfrP37k9vSjiME/3.jpg",
        "https://ipfs.io/ipfs/QmQbTc847r4QtdDw56Vk8qHe8EiyMYwAsfrP37k9vSjiME/4.jpg",
        "https://ipfs.io/ipfs/QmQbTc847r4QtdDw56Vk8qHe8EiyMYwAsfrP37k9vSjiME/5.jpg"
    ];
    string[] commands_name = [
        "Mystic",
        "Stars",
        "Flames",
        "Guardians",
        "Wizard"
    ];

    struct Runner {
        string image;
        string name;
        uint256 distance;
        uint256 round;
    }
    Runner[] public runners;
    mapping(uint256 => uint256) public request_runner; /* requestId --> tokenId*/


    constructor(uint64 subscriptionId) ERC721("Runners", "RUN")
        VRFConsumerBaseV2(vrfCoordinator)        
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        safeMint(msg.sender,0);
    }

    function safeMint(address to, uint256 charId) public {
        uint8 aux = uint8 (charId);
        require( (aux >= 0) && (aux <= 4), "invalid charId");
        string memory yourCommandImage = commands_image[charId];

        runners.push(Runner(yourCommandImage,commands_name[aux],0,0));

        uint256 tokenId = tokenIdCounter.current();
        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', runners[tokenId].name, '",'
                        '"description": "Chainlink runner",',
                        '"image": "', runners[tokenId].image, '",'
                        '"attributes": [',
                            '{"trait_type": "distance",',
                            '"value": ', runners[tokenId].distance.toString(),'}',
                            ',{"trait_type": "round",',
                            '"value": ', runners[tokenId].round.toString(),'}',
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, finalTokenURI);
    }


    function run(uint256 tokenId) external returns (uint256 requestId) {

        require (tokenId < tokenIdCounter.current(), "tokenId not exists");

        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        request_runner[requestId] = tokenId;
        return requestId;      
    }

    function fulfillRandomWords(
        uint256 _requestId, /* requestId */
        uint256[] memory _randomWords
    ) internal override {
        require (tokenIdCounter.current() >= 0, "You must mint a NFT");
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        lastRandomWords = _randomWords;

        uint aux = (lastRandomWords[0] % 10 + 1) * 10;
        uint256 tokenId = request_runner[_requestId];
        runners[tokenId].distance += aux;
        runners[tokenId].round ++;

        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', runners[tokenId].name, '",'
                        '"description": "Chainlink runner",',
                        '"image": "', runners[tokenId].image, '",'
                        '"attributes": [',
                            '{"trait_type": "distance",',
                            '"value": ', runners[tokenId].distance.toString(),'}',
                            ',{"trait_type": "round",',
                            '"value": ', runners[tokenId].round.toString(),'}',
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
        _setTokenURI(tokenId, finalTokenURI);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {

    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}