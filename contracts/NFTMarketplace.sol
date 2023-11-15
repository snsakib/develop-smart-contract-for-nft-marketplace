//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;
    address payable contractOwner;
    uint256 public listingPrice = 10000000 wei;

    struct NFT {
        uint256 id;
        address payable contractAddress;
        address payable owner;
        uint256 price;
        bool isListed;
    }

    event NFTListed(
        uint256 indexed id,
        address contractAddress,
        address owner,
        uint256 price,
        bool isListed
    );

    mapping(uint256 => NFT) private _idToNFT;

    constructor() ERC721("EducativeNFT", "EDUNFT") {
        contractOwner = payable(msg.sender);
    }

    function mintNFT(string memory tokenURI, uint256 price) public payable {
        _nftIds.increment();
        uint256 newNftId = _nftIds.current();

        _safeMint(msg.sender, newNftId);
        _setTokenURI(newNftId, tokenURI);

        approve(address(this), newNftId);

        (bool transferFeeSuccess, ) = payable(contractOwner).call{
            value: listingPrice
        }("");

        require(
            transferFeeSuccess,
            "Failed to transfer listing fee to the owner"
        );

        _idToNFT[newNftId] = NFT(
            newNftId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        emit NFTListed(newNftId, address(this), msg.sender, price, true);
    }

    function getAllNFTs() public view returns (NFT[] memory) {
        uint256 totalItemCount = _nftIds.current();
        NFT[] memory items = new NFT[](totalItemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            NFT storage currentItem = _idToNFT[i + 1];
            items[i] = currentItem;
        }
        return items;
    }

    function getMyNFTs() public view returns (NFT[] memory) {
        uint256 totalItemCount = _nftIds.current();
        uint256 itemCount = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToNFT[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        NFT[] memory items = new NFT[](itemCount);
        uint256 itemIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (_idToNFT[i + 1].owner == msg.sender) {
                NFT storage currentItem = _idToNFT[i + 1];
                items[itemIndex] = currentItem;
                itemIndex += 1;
            }
        }

        return items;
    }
}
