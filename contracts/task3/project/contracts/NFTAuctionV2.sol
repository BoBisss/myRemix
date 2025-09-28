// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./NFTAuction.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFTAuctionV2 is NFTAuction{
    uint256 public auctionVersion;

    function initializeV2() public reinitializer(2) {
        auctionVersion = 2;
    }
    function getVersion() public view returns (uint256) {
        return auctionVersion;
    }
}
