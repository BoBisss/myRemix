// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./NFTAuction.sol";

contract NFTAuctionFactory { 
    event AuctionCreated(address indexed auction, uint256 indexed tokenId);
    address[] public auctions;
    mapping(uint256 => address) public auctionMap;

    function creatAuction(uint256 _tokenId) external returns (address){
        
        NFTAuction nftAuction = new NFTAuction();
        nftAuction.initialize();
        address nftAddress = address(nftAuction);
        auctions.push(nftAddress);
        auctionMap[_tokenId] = nftAddress;
        emit AuctionCreated(nftAddress, _tokenId);
        return nftAddress;
    }

    function getAuctions()external view returns (address[] memory){
        return auctions;
    }

    function getAuction(uint256 _tokenId) external view returns (address){
        return auctionMap[_tokenId];
    }


}