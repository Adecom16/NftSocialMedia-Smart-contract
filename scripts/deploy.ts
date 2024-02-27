import { ethers } from "hardhat";

async function main() {


  const NFTSocialMediaPlatform = await ethers.deployContract("NFTSocialMediaPlatform");

  await NFTSocialMediaPlatform.waitForDeployment();

  console.log(
    `NFTSocialMediaPlatformdeployed to ${NFTSocialMediaPlatform.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
