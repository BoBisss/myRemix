// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BeggingContract{
    //控制捐赠时间
    uint256 public startTime;
    uint256 public endTime;
    //捐赠记录
    mapping(address => uint256) public records;
    //拥有者
    address private immutable owner = msg.sender;
    // 所有捐过款的地址
    address[] public  donors;                  

    event Donation(address addr,uint256 value);

    modifier onlyOwner{
        require(owner == msg.sender,"only owner can use function");
        _;
    }
    modifier onlyWhileOpen {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "not open");
        _;
    }
    
    function donate()external payable onlyWhileOpen returns (bool){
        require(msg.value > 0,"no eth");
        if (records[msg.sender] == 0) donors.push(msg.sender);
        records[msg.sender] += msg.value;
        emit Donation(msg.sender, msg.value);
        return true;
    }

    function withdraw()external onlyOwner returns (bool){
        uint256 banlance = address(this).balance;
        payable(owner).transfer(banlance);
        return true;
    }

    function setPeriod(uint256 _start, uint256 _end) external onlyOwner {
        require(_end > _start, "bad period");
        startTime = _start;
        endTime   = _end;
    }

    function getDonation(address addr)external view returns (uint256){
        return records[addr];
    }
    struct Rank {
        address addr;
        uint256 amount;
    }
    function rankings() external view returns (Rank[3] memory top) {
        uint256 len = donors.length;

        // 先清空
        for (uint256 i = 0; i < 3; ++i) {
            top[i].addr   = address(0);
            top[i].amount = 0;
        }

        // 对每一个捐赠者重新维护前三
        for (uint256 i = 0; i < len; ++i) {
            address d = donors[i];
            uint256 v = records[d];

            if (v > top[0].amount) {
                top[2] = top[1];
                top[1] = top[0];
                top[0] = Rank(d, v);
            } else if (v > top[1].amount) {
                top[2] = top[1];
                top[1] = Rank(d, v);
            } else if (v > top[2].amount) {
                top[2] = Rank(d, v);
            }
        }
    }

}