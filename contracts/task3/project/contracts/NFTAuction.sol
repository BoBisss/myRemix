// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract NFTAuction is Initializable{
    // 结构体
    struct Auction {
        // 卖家
        address seller;
        // 拍卖持续时间
        uint256 duration;
        // 起始价格
        uint256 startPrice;
        // 开始时间
        uint256 startTime;
        // 是否结束
        bool ended;
        // 最高出价者
        address highestBidder;
        // 最高价格
        uint256 highestBid;
        // NFT合约地址
        address nftContract;
        // NFT ID
        uint256 tokenId;
        // 参与竞价的资产类型 0x 地址表示eth，其他地址表示erc20
        // 0x0000000000000000000000000000000000000000 表示eth
        address tokenAddress;
    }

    // 状态变量
    mapping(uint256 => Auction) public auctions;
    // 下一个拍卖ID
    uint256 public nextAuctionId;
    // 管理员地址
    address public admin;

    mapping(address => AggregatorV3Interface) public priceFeeds;

    function initialize() public initializer {
        admin = msg.sender;
        // priceFeeds[address(0)] = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function getChainlinkDataFeedLatestAnswer(address addr) public view returns (int) {
        AggregatorV3Interface dataFeed = priceFeeds[addr];
        // prettier-ignore
        (
            uint80 roundId ,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function setPriceFeed(address _token, address _priceFeed) public {
        require(msg.sender == admin, "Only admin can set price feed");
        priceFeeds[_token] = AggregatorV3Interface(_priceFeed);
    }

    function createAuction(
        uint256 _duration,
        uint256 _startPrice,
        address _nftContract,
        uint256 _tokenId
    ) public {
        // require(admin == msg.sender, "Only admin can create auction");
        require(_duration > 3, "Duration must be greater than 3 seconds");
        require(_startPrice >= 1e18, "Start price must be greater than 0");
        require(_nftContract != address(0), "NFT contract address cannot be zero");
        require(_tokenId > 0, "Token ID must be greater than 0");
        // 创建一个拍卖
        Auction memory auction = Auction({
            seller: msg.sender,
            duration: _duration,
            startPrice: _startPrice,
            startTime: block.timestamp,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            nftContract: _nftContract,
            tokenId: _tokenId,
            tokenAddress: address(0)
        });
        auctions[nextAuctionId] = auction;
        nextAuctionId++;
    }

    function bid(uint256 _auctionId, address _tokenAddress,uint256 amount) public payable {
        Auction storage auction = auctions[_auctionId];
        require(!auction.ended, "Auction has ended");
        require(block.timestamp < auction.startTime + auction.duration, "Auction has ended");

        //统一货币
        uint payValue;
        if (_tokenAddress == address(0)){
             payValue = msg.value * uint256(getChainlinkDataFeedLatestAnswer(address(0)));
             amount = msg.value;
        }else{
             payValue = amount * uint256(getChainlinkDataFeedLatestAnswer(_tokenAddress));
        }
        uint startPrice = auction.startPrice * uint256(getChainlinkDataFeedLatestAnswer(address(0)));
        uint highestBid = auction.highestBid * uint256(getChainlinkDataFeedLatestAnswer(auction.tokenAddress));

        require(payValue > highestBid, "Bid must be higher than the current highestBid");
        require(payValue > startPrice, "Bid must be higher than the start price");
        
        //如果是erc20接收
        if (_tokenAddress != address(0)) {
            IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        }

        //如果已经有人竞价则退回
        if(auction.highestBid > 0){
            if (auction.tokenAddress == address(0)){
                payable(auction.highestBidder).transfer(auction.highestBid);
            }else{
                IERC20(auction.tokenAddress).transfer(auction.highestBidder, auction.highestBid);
            }
        }

        //更新数据
        auction.highestBidder = msg.sender;
        auction.highestBid = amount;
        auction.tokenAddress = _tokenAddress;
    }

    //结束拍卖
    function endAuction(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        require(auction.seller == msg.sender, "Only seller can end auction");
        require(!auction.ended, "Auction has already ended");
        require(block.timestamp >= auction.startTime + auction.duration, "Auction has not ended yet");

        //转移nft
        IERC721(auction.nftContract).transferFrom(auction.seller, auction.highestBidder, auction.tokenId);

        //结束拍卖
        auction.ended = true;
    }
    //获取拍卖信息
    function getAuctionInfo(uint256 _auctionId) public view returns (Auction memory) {
        return auctions[_auctionId];
    }
}
