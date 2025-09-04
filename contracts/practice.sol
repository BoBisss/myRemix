// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

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