const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("NFTMarketplace", function () {
  async function deploySmartContractFixture() {
    const [owner, user1, user2] = await ethers.getSigners();

    const nftMarketplace = await ethers.deployContract("NFTMarketplace");
    await nftMarketplace.waitForDeployment();

    const listingPrice = await nftMarketplace.listingPrice();

    return { nftMarketplace, owner, user1, user2, listingPrice };
  }

  describe("mintNFT", function () {
    it("Should mint a new NFT", async () => {
      const { nftMarketplace, user1, listingPrice } = await loadFixture(
        deploySmartContractFixture
      );

      // Mint a new NFT
      await nftMarketplace
        .connect(user1)
        .mintNFT("NFT_URI", 100000000, { value: listingPrice });

      // Check if the NFT has been minted successfully
      const allNFTs = await nftMarketplace.getAllNFTs();
      expect(allNFTs.length).to.equal(1);
      expect(allNFTs[0].owner).to.equal(user1.address);
    });
  });

  describe("getAllNFTs", function () {
    it("Should return all NFTs", async () => {
      const { nftMarketplace, user1, user2, listingPrice } = await loadFixture(
        deploySmartContractFixture
      );

      // Mint a couple of NFTs
      await nftMarketplace
        .connect(user1)
        .mintNFT("NFT1_URI", 200000000, { value: listingPrice });
      await nftMarketplace
        .connect(user2)
        .mintNFT("NFT2_URI", 300000000, { value: listingPrice });

      // Check if getAllNFTs returns the correct number of NFTs
      const allNFTs = await nftMarketplace.getAllNFTs();
      expect(allNFTs.length).to.equal(2);
    });
  });

  describe("getMyNFTs", function () {
    it("Should return NFTs owned by the caller", async () => {
      const { nftMarketplace, user1, user2, listingPrice } = await loadFixture(
        deploySmartContractFixture
      );

      // Mint NFTs for different users
      await nftMarketplace
        .connect(user1)
        .mintNFT("NFT1_URI", 200000000, { value: listingPrice });
      await nftMarketplace
        .connect(user2)
        .mintNFT("NFT2_URI", 300000000, { value: listingPrice });
      await nftMarketplace
        .connect(user1)
        .mintNFT("NFT3_URI", 400000000, { value: listingPrice });

      // Check if getMyNFTs returns the correct number of NFTs for user1
      const user1NFTs = await nftMarketplace.connect(user1).getMyNFTs();
      expect(user1NFTs.length).to.equal(2);
      expect(user1NFTs[0].owner).to.equal(user1.address);
      expect(user1NFTs[1].owner).to.equal(user1.address);
    });
  });

  describe("buyNFT", function () {
    it("Should allow a user to buy an NFT", async () => {
      const { nftMarketplace, user1, user2, listingPrice } = await loadFixture(
        deploySmartContractFixture
      );

      // Mint an NFT
      await nftMarketplace
        .connect(user1)
        .mintNFT("NFT_URI", 500000000, { value: listingPrice });

      // Get the ID of the minted NFT
      const allNFTs = await nftMarketplace.getAllNFTs();
      const nftId = allNFTs[0].id;

      // User2 buys the NFT
      await nftMarketplace.connect(user2).buyNFT(nftId, { value: 500000000 });

      // Check if the NFT has been transferred successfully
      const user2NFTs = await nftMarketplace.connect(user2).getMyNFTs();
      expect(user2NFTs.length).to.equal(1);
      expect(user2NFTs[0].owner).to.equal(user2.address);
    });
  });
});
