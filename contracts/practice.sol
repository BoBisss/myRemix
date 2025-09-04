// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

// ✅ 创建一个名为Voting的合约，包含以下功能：
// 一个mapping来存储候选人的得票数
// 一个vote函数，允许用户投票给某个候选人
// 一个getVotes函数，返回某个候选人的得票数
// 一个resetVotes函数，重置所有候选人的得票数

contract Voting{
    mapping(address => uint256) internal votes;
    address[] internal users;

    function vote(address addr)external {
        if (votes[addr] == 0) {
            users.push(addr);
        }
        votes[addr] += 1;
    }

    function getVotes(address addr) external view returns (uint256){
        return votes[addr];
    }

    function resetVotes()external {
        for (uint256 i = 0; i < users.length; i++) {
            delete votes[users[i]];
        }
    }
    
}