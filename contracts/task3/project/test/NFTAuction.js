const {ethers, getNamedAccounts, deployments} = require("hardhat");
const {expect} = require("chai");

describe("NFTAuctionTest", () => { 
    let nftDeployer, erc20Deployer, auctionDeployer, buyer;
    let erc20;
    let ERC20Addr;
    let NFTAddr;
    let nft;
    let ethAggregatorAddress;
    let erc20AggregatorAddress;
    let NFTAuction;

    before(async () => {
        [nftDeployer, erc20Deployer, auctionDeployer, buyer] = await ethers.getSigners();
        console.log("nftDeployer:", nftDeployer,"erc20Deployer:", erc20Deployer,"auctionDeployer:", auctionDeployer, "buyer:", buyer);
        
    });


    it("deploy the AggregatorV3", async () => { 
        const AggregatorV3Factory = await ethers.getContractFactory("AggreagatorV3",nftDeployer);
        const ethAggregator = await AggregatorV3Factory.deploy();
        const erc20Aggregator = await AggregatorV3Factory.deploy();
        await ethAggregator.waitForDeployment();
        await erc20Aggregator.waitForDeployment();
        ethAggregatorAddress = await ethAggregator.getAddress();
        erc20AggregatorAddress = await erc20Aggregator.getAddress();
        
        // 设置并验证ETH聚合器的值
        console.log("Setting ETH aggregator answer to 1700_00000000");
        await ethAggregator.setAnswer(17_00000000);
        const ethAnswerAfterSet = await ethAggregator.answer();
        console.log("ETH aggregator answer after set:", ethAnswerAfterSet.toString());

        console.log("Setting erc20 aggregator answer to 100_00000000");
        await erc20Aggregator.setAnswer(100_00000000);
        const erc20AnswerAfterSet = await erc20Aggregator.answer();
        console.log("erc20 aggregator answer after set:", erc20AnswerAfterSet.toString());
    })
    
    it("deploy the erc20", async () => { 
        console.log("erc20Deployer:", erc20Deployer);
        const ERC20Factory = await ethers.getContractFactory("MyERC20",erc20Deployer);
        erc20 = await ERC20Factory.deploy();
        await erc20.waitForDeployment();
        ERC20Addr = await erc20.getAddress()
        console.log("erc20 address:", ERC20Addr);
    });
    it("deploy the nft", async () => { 
        console.log("nftDeployer:", nftDeployer);
        const nftFactory = await ethers.getContractFactory("MyNFT",nftDeployer)
        nft = await nftFactory.deploy();
        await nft.waitForDeployment();
        NFTAddr = await nft.getAddress();
        console.log("nft address:", NFTAddr);
        for (let i = 0; i < 10; i++) { 
            await nft.mint(nftDeployer.address,i + 1);
        }

    });

    it("deploy the NFTAuction", async () => { 
        await deployments.fixture("deploy_NFTAuction");
        const AuctionProxy = await deployments.get("NFTAuctionInfo")
        //创建合约实例
        NFTAuction = await ethers.getContractAt("NFTAuction", AuctionProxy.address);
        console.log("again get NFTAuction address:", await AuctionProxy.implementation);

        // //授权nft
        await nft.connect(nftDeployer).setApprovalForAll(AuctionProxy.address,true);
        //转移NFT
        // IERC721(nft).safeTransferFrom(nftDeployer, address(this), _tokenId);

        //创建拍卖
        await NFTAuction.connect(nftDeployer).createAuction(
            10,
            ethers.parseEther("1"),
            NFTAddr,
            1
        );
        console.log("createAuction success::",await NFTAuction.auctions(0));
        //设置预言机
        // 设置预言机
        await NFTAuction.connect(auctionDeployer).setPriceFeed(ERC20Addr, erc20AggregatorAddress);
        await NFTAuction.connect(auctionDeployer).setPriceFeed(ethers.ZeroAddress, ethAggregatorAddress);

        console.log("setPriceFeed success::", await NFTAuction.getChainlinkDataFeedLatestAnswer(ethers.ZeroAddress));
        console.log("setPriceFeed success::", await NFTAuction.getChainlinkDataFeedLatestAnswer(ERC20Addr));
        
        //开始竞价
        await NFTAuction.connect(buyer).bid(
             0,                                    // auctionId
            ethers.ZeroAddress,                   // bidToken (ETH)
            ethers.parseEther("1.1"),               // amount
            { value: ethers.parseEther("1.1") }     // payable 附加以太
        );
        //竞价成功
        const auctionData = await NFTAuction.getAuctionInfo(0);
        console.log("buy1 bid success::", auctionData);
        console.log("buyer.address::", buyer.address);

        console.log("auctionData.highestBidder::", auctionData.highestBidder);
        expect(auctionData.highestBidder).to.equal(buyer.address);
        expect(auctionData.highestBid).to.equal(ethers.parseEther("1.1"));
        expect(auctionData.tokenAddress).to.equal(ethers.ZeroAddress);

        
        //第二次竞价erc20
        let tx = await erc20.connect(erc20Deployer).approve(AuctionProxy.address,ethers.MaxUint256);
        await tx.wait();
        await NFTAuction.connect(erc20Deployer).bid(0,ERC20Addr,await erc20.parse(2));
        const auctionDataAfterSecondBid = await NFTAuction.getAuctionInfo(0);
    
        console.log("buy2 bid success::", auctionDataAfterSecondBid);
        expect(auctionDataAfterSecondBid.highestBidder).to.equal(erc20Deployer.address);
        console.log("auctionDataAfterSecondBid.highestBid::", auctionDataAfterSecondBid.highestBid);
        console.log("erc20.parse(2)::", erc20.parse(2));
        expect(auctionDataAfterSecondBid.highestBid).to.equal(await erc20.parse(2));
        expect(auctionDataAfterSecondBid.tokenAddress).to.equal(ERC20Addr);
        await new Promise(resolve => setTimeout(resolve, 5000));

        //结束拍卖
        await NFTAuction.connect(nftDeployer).endAuction(0);
        console.log("endAuction success::", await NFTAuction.auctions(0));

        expect((await NFTAuction.auctions(0))[4]).to.equal(true); // ended field
        const nftOwner = await nft.ownerOf(1)
        expect(nftOwner).to.equal(erc20Deployer.address);
    });

    it("upgrate the NFTAuction", async () => { 
        const auctionV1 = await NFTAuction.getAuctionInfo(0);
        await deployments.fixture("upgrade_nftAuction");
        const {address} = await deployments.get("NFTAuctionV2")
        //获取新版实例
        const nftAuction = await ethers.getContractAt("NFTAuctionV2", address);
        await nftAuction.initializeV2();
        const version = await nftAuction.getVersion()
        const auctionV2 = await nftAuction.getAuctionInfo(0);
        expect(version).to.equal(2);
        // 深度比较，同时把 BigNumber 统一转成字符串
        expect(auctionV1.map(bn => bn.toString()))
        .to.deep.equal(auctionV2.map(bn => bn.toString()));
    });
})