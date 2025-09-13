// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract myERC20{
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private immutable owner;

    modifier OnlyOwner{
        require(owner == msg.sender,"only owner can operate the function");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
    }

    function _mint(address account, uint256 value) external  OnlyOwner{
        _balances[account] += value;
        _totalSupply += value;
        _totalSupply += _totalSupply;
    }

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

     
    function balanceOf(address account) external view returns (uint256){
        return _balances[account];
    }

    
    function transfer(address to, uint256 value) external returns (bool){
        require(_balances[msg.sender] > value,"The balance is insufficient");
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address form, address spender) external view returns (uint256){
        return _allowances[form][spender];
    }

    
    function approve(address spender, uint256 value) external returns (bool){
        require(_balances[msg.sender] > value,"The balance is insufficient");
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool){
        require(_allowances[msg.sender][from] >= value, "allowance not enough");
        _balances[from] -= value;
        _balances[to] += value;
        _allowances[msg.sender][from] -= value;
        emit Transfer(from, to, value);
        return true;

    }
}