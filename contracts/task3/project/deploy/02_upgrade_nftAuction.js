
const fs = require('fs');
const { ethers } = require('hardhat');
const path = require('path');
module.exports = async({deployments}) => {
    const [,,auctionDeployer] = await ethers.getSigners();
    const {save} = deployments;
    const storePath = await path.resolve(__dirname, "./.cache/ft_auction.json")
    const {proxyAddr,impAddr,abi} = JSON.parse(fs.readFileSync(storePath));

    const NFTAuctionV2 = await ethers.getContractFactory("NFTAuctionV2",auctionDeployer);
    const NFTAuctionV2Proxy = await upgrades.upgradeProxy(proxyAddr, NFTAuctionV2);
    await NFTAuctionV2Proxy.waitForDeployment();

    console.log("NFTAuctionV2Proxy deployed to:", await NFTAuctionV2Proxy.getAddress());
    
    save("NFTAuctionV2", {
        address: await NFTAuctionV2Proxy.getAddress(),
        implementation: await upgrades.erc1967.getImplementationAddress(proxyAddr),
        abi: NFTAuctionV2.interface.format("json"),
    });
    console.log(">>> 升级完成");

}

module.exports.tags = ["upgrade_nftAuction"];