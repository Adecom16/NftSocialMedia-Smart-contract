import { ethers } from "hardhat";

async function main() {


  const NFTSocialMediaFactory = await ethers.deployContract("NFTSocialMediaFactory");

  await NFTSocialMediaFactory.waitForDeployment();

  console.log(
    `NFTSocialMediaFactory deployed to ${NFTSocialMediaFactory.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
