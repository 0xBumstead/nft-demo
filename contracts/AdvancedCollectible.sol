// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    uint256 public tokenCounter;
    bytes32 public keyhash;
    uint256 public fee;
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => address) public requestIdToSender;
    event requestedCollectible(bytes32 indexed requestId, address requester);
    event breedAssigned(uint256 indexed tokenId, Breed breed);

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        bytes32 _keyhash,
        uint256 _fee
    )
        public
        VRFConsumerBase(_vrfCoordinator, _linkToken)
        ERC721("Dogie", "DOG")
    {
        tokenCounter = 0;
        keyhash = _keyhash;
        fee = _fee;
    }

    function createCollectible() public returns (bytes32) {
        bytes32 _requestId = requestRandomness(keyhash, fee);
        requestIdToSender[_requestId] = msg.sender;
        emit requestedCollectible(_requestId, msg.sender);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomNumber)
        internal
        override
    {
        Breed breed = Breed(_randomNumber % 3);
        uint256 _newTokenId = tokenCounter;
        tokenIdToBreed[_newTokenId] = breed;
        emit breedAssigned(_newTokenId, breed);
        address _owner = requestIdToSender[_requestId];
        _safeMint(_owner, _newTokenId);
        //_setTokenURI(_newTokenId, _tokenURI);
        tokenCounter = tokenCounter + 1;
    }

    function setTokenURI(uint256 _tokenId, string memory _tokenURI) public {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: caller is not owner or approved"
        );
        _setTokenURI(_tokenId, _tokenURI);
    }
}
