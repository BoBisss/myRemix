const { ethers } = require("hardhat");
const {expect} = require("chai");

describe("testFactory", () => {
  let nftAuctionFactory;          // 1. 先声明

  before("create nftAuctionFactory", async () => {
    const NFTAuctionFactory = await ethers.getContractFactory("NFTAuctionFactory");
    nftAuctionFactory = await NFTAuctionFactory.deploy();
    await nftAuctionFactory.waitForDeployment(); // 2. 正确等待
    console.log("部署成功，地址:", await nftAuctionFactory.getAddress()); // 3. 拿地址
  });

  it("create one nftAuction", async () => {
    const iface = nftAuctionFactory.interface;          // ① 拿接口

    for (let i = 1; i < 10; i++) {
        const tx = await nftAuctionFactory.creatAuction(i);
        const rc = await tx.wait();
        // ① 只解析**能解析**的日志
        const events = rc.logs
        .filter(log => log.address === nftAuctionFactory.target)   // 可选：只扫工厂地址
        .map(log => iface.parseLog(log))
        .filter(Boolean); // 去掉解析失败的 null
        const event  = events.find(e => e.name === "AuctionCreated");

        // ③ 取地址
        const addr = event.args.auction;   // 或 event.args[0]
        expect(addr).to.equal(await nftAuctionFactory.getAuction(i));
    }
    });

  it("print auctions", async () => {
    const list = await nftAuctionFactory.getAuctions();
    console.log("拍卖列表:", list);
});
});