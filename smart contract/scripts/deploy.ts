import { ethers } from "hardhat";

async function main() {


  const PrizeDistribution = await ethers.deployContract("PrizeDistribution");
  await PrizeDistribution.waitForDeployment();
  
  const RewardToken= await ethers.deployContract("RewardToken");
  await RewardToken.waitForDeployment();

  const VRFv2Consumer=await ethers.deployContract("VRFv2Consumer");
  await VRFv2Consumer.waitForDeployment();



  console.log(
    `PrizeDistribution deployed to ${PrizeDistribution.target}
    RewardToken deployed ${RewardToken.target}
    VRFv2Consumer deployed ${VRFv2Consumer.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
