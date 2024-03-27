//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {
    uint256 private _nftIds;
    address payable contractOwner;
    uint256 public listingPrice = 10000000 wei;

    struct NFT {
        uint256 id;
        address payable contractAddress;
        address payable owner;
        uint256 price;
    }

    event NFTListed(
        uint256 indexed id,
        address contractAddress,
        address owner,
        uint256 price
    );

    mapping(uint256 => NFT) private _idToNFT;

    constructor() ERC721("EducativeNFT", "EDUNFT") {
        contractOwner = payable(msg.sender);
    }

    function mintNFT(string memory tokenURI, uint256 price) public payable {
        _nftIds++;
        uint256 newNftId = _nftIds;

        _safeMint(msg.sender, newNftId);
        _setTokenURI(newNftId, tokenURI);

        _idToNFT[newNftId] = NFT(
            newNftId,
            payable(address(this)),
            payable(msg.sender),
            price
        );

        (bool transferFeeSuccess, ) = payable(contractOwner).call{
            value: listingPrice
        }("");

        require(
            transferFeeSuccess,
            "Failed to transfer listing fee to the owner"
        );

        emit NFTListed(newNftId, address(this), msg.sender, price);
    }

    function getAllNFTs() public view returns (NFT[] memory) {
        uint256 totalItemCount = _nftIds;
        NFT[] memory items = new NFT[](totalItemCount);

        for (uint256 i = 0; i < totalItemCount; i++) {
            NFT storage currentItem = _idToNFT[i + 1];
            items[i] = currentItem;
        }

        return items;
    }
}
