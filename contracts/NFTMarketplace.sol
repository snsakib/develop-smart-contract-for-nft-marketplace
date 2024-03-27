//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketplace is ERC721URIStorage {
    uint256 private _nftIds;
    address payable contractOwner;
    uint256 public listingPrice = 10000000 wei;
    
    constructor() ERC721("EducativeNFT", "EDUNFT") {
        contractOwner = payable(msg.sender);
    }
}
