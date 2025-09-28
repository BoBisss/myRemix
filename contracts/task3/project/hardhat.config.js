require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    nftDeployer: 0,
    erc20Deployer: 1,
    auctionDeployer: 2
  }
};
