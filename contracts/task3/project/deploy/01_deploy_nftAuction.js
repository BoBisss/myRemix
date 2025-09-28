const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

module.exports = async({getNamedAccounts, deployments}) => { 

    const [,,auctionDeployer] = await ethers.getSigners();
    const {save} = deployments;
    const NFTAuction = await ethers.getContractFactory("NFTAuction",auctionDeployer);
    const NFTAuctionProxy = await upgrades.deployProxy(NFTAuction, [], { initializer: 'initialize' });
    await NFTAuctionProxy.waitForDeployment();
    const proxyAddr = await NFTAuctionProxy.getAddress();
    console.log("NFTAuctionProxy deployed to:", proxyAddr);
    const impAddr = await upgrades.erc1967.getImplementationAddress(proxyAddr);
    console.log("NFTAuction implementation deployed to:", impAddr);
    console.log(">>> 准备 save NFTAuctionInfo");
    const storePath = path.resolve(__dirname, "./.cache/ft_auction.json")
    fs.writeFileSync(storePath, JSON.stringify({
        proxyAddr,
        impAddr,
        abi: NFTAuctionProxy.interface.format("json"),
    }));
    await save("NFTAuctionInfo",{
        admin:auctionDeployer,
        implementation: impAddr,
        address: proxyAddr,
        abi: NFTAuctionProxy.interface.format("json")
    })
    console.log(">>> save 完成");

}

module.exports.tags = ["deploy_NFTAuction"]