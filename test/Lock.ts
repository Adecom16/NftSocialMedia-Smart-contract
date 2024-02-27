import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe('NFTSocialMediaPlatform', function () {
  let NFTSocialMediaPlatform;
  // let NFTSocialMediaPlatform;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    NFTSocialMediaPlatform = await ethers.getContractFactory('NFTSocialMediaPlatform');
    [owner, addr1, addr2] = await ethers.getSigners();

    NFTSocialMediaPlatform = await NFTSocialMediaPlatform.deploy();
    // await NFTSocialMediaPlatform.deployed();
  });

  describe('register', function () {
    it('should register a new user', async function () {
      await NFTSocialMediaPlatform.connect(addr1).register('user1');
      // expect(await NFTSocialMediaPlatform.users(addr1.address)).to.deep.equal({
      //   username: 'user1',
      //   registered: true
      // });
    });

    it('should revert if user is already registered', async function () {
      await NFTSocialMediaPlatform.connect(addr1).register('user1');
      await expect(NFTSocialMediaPlatform.connect(addr1).register('user2')).to.be.revertedWith(
        'User already registered'
      );
    });
  });

  describe('createNFT', function () {
    it('should create a new NFT', async function () {
      await NFTSocialMediaPlatform.connect(addr1).createNFT('metadataURI');
      const tokenIdCounter = await NFTSocialMediaPlatform.tokenIdCounter();
      expect(await NFTSocialMediaPlatform.nfts(tokenIdCounter)).to.deep.equal({
        owner: addr1.address,
        metadataURI: 'metadataURI',
        likes: 0
      });
    });
  });

  describe('moderateContent', function () {
    it('should moderate content by owner', async function () {
      await NFTSocialMediaPlatform.connect(addr1).createNFT('metadataURI');
      const tokenIdCounter = await NFTSocialMediaPlatform.tokenIdCounter();
      await expect(NFTSocialMediaPlatform.moderateContent(tokenIdCounter)).to.emit(
        NFTSocialMediaPlatform,
        'ContentModerated'
      );
    });

    it('should revert if called by non-owner', async function () {
      await expect(NFTSocialMediaPlatform.connect(addr1).moderateContent(1)).to.be.revertedWith(
        'Only contract owner can perform this action'
      );
    });
  });

  describe('likeNFT', function () {
    it('should allow a user to like an NFT', async function () {
      await NFTSocialMediaPlatform.connect(addr1).createNFT('metadataURI');
      const tokenIdCounter = await NFTSocialMediaPlatform.tokenIdCounter();
      await NFTSocialMediaPlatform.connect(addr2).likeNFT(tokenIdCounter);
      expect(await NFTSocialMediaPlatform.nfts(tokenIdCounter)).to.deep.equal({
        owner: addr1.address,
        metadataURI: 'metadataURI',
        likes: 1
      });
    });

    it('should revert if an already liked NFT is liked again', async function () {
      await NFTSocialMediaPlatform.connect(addr1).createNFT('metadataURI');
      const tokenIdCounter = await NFTSocialMediaPlatform.tokenIdCounter();
      await NFTSocialMediaPlatform.connect(addr2).likeNFT(tokenIdCounter);
      await expect(NFTSocialMediaPlatform.connect(addr2).likeNFT(tokenIdCounter)).to.be.revertedWith(
        'Already liked'
      );
    });
  });


});
