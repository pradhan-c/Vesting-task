// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  // We get the contract to deploy
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer account :${deployer.address}`);
  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy(
    "PillowToken",
    "PILW",
    "100000000000000000000000"
  );
  await token.deployed();
  const Vesting = await ethers.getContractFactory("Vesting");
  const vesting = await Vesting.deploy(
    token.address,
    "0xa5CB971Fb04f350a2dED9671e1178C076b0c3878",
    "0x459D9A1Fd935238405a9875393390d4Bc6701381",
    "1649658263",
    true,
    deployer.address
  );
  await vesting.deployed();
  console.log(`Token Address: ${token.address}`);
  console.log(`Vesting Address: ${vesting.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
