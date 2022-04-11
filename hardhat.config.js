require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const Alchemy_API_Key = "https://eth-rinkeby.alchemyapi.io/v2/V7iV6ebgBome-U9BnFiL01Jhss1R0oId"
const Private_Key = "e7bc9bf6e1fe20f7888b54c496ac8f67da1ba0826d46a5e515b83c410a67c97b";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks:{
    rinkeby: {
      url : `https://eth-rinkeby.alchemyapi.io/v2/V7iV6ebgBome-U9BnFiL01Jhss1R0oId`,
      accounts : [`0x${Private_Key}`]
      
    }
  }
};
