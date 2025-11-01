// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./AuthoDoxNFT.sol";
import "@openzeppelin/contracts@4.9.0/access/Ownable.sol";

contract AuthoDoxRegistry is Ownable {

    error ContentAlreadyRegistered(string contentCid);
    error OnlyOwner();

    AuthoDoxNFT public immutable nftContract;

    struct ProofMetadata {
        string promptCid;
        string contentCid;
        string metadataUri;
        string optionalChatLink;
        address author;
        uint256 timestamp;
    }

    mapping(uint256 => ProofMetadata) public proofData;
    mapping(string => bool) public contentCidRegistered;

    constructor(address _nftContractAddress) Ownable() {
        nftContract = AuthoDoxNFT(_nftContractAddress);
    }

    function registerProof(
        string memory _promptCid,
        string memory _contentCid,
        string memory _metadataUri,
        string memory _optionalChatLink
    ) public {
        if (contentCidRegistered[_contentCid]) {
            revert ContentAlreadyRegistered(_contentCid);
        }

        uint256 newTokenId = nftContract.safeMint(msg.sender);

        proofData[newTokenId] = ProofMetadata({
            promptCid: _promptCid,
            contentCid: _contentCid,
            metadataUri: _metadataUri,
            optionalChatLink: _optionalChatLink,
            author: msg.sender,
            timestamp: block.timestamp
        });

        contentCidRegistered[_contentCid] = true;

        emit ProofRegistered(newTokenId, msg.sender, _promptCid, _contentCid, _metadataUri, _optionalChatLink, block.timestamp);
    }

    event ProofRegistered(
        uint256 indexed tokenId,
        address indexed author,
        string promptCid,
        string contentCid,
        string metadataUri,
        string optionalChatLink,
        uint256 timestamp
    );

    function transferNftContractOwnership(address _newOwner) public {
         if (msg.sender != owner()) {
             revert OnlyOwner();
         }
         nftContract.transferOwnership(_newOwner);
         emit NftContractOwnershipTransferred(_newOwner);
    }

     event NftContractOwnershipTransferred(address indexed newOwner);
}