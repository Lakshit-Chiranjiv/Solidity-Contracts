// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface ERC20TokenInterface{
    function totalSupply() external view returns (uint); 
    function balanceOf(address tokenOwner) external view returns (uint balance); 
    function transfer(address to, uint tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
} 

contract MyToken is ERC20TokenInterface{

    string public tokenName = "Lakshitoken";
    string public tokenSymbol = "LCS";
    string public decimal = "0";

    uint public totalTokenSupply;
    address public tokenFounder;

    mapping(address=>uint) public tokenBalance;
    mapping(address=>mapping(address=>uint)) public allowedMap;

    constructor(){
        totalTokenSupply = 100000;
        tokenFounder = msg.sender;
        tokenBalance[tokenFounder] = totalTokenSupply;
    } 

    function totalSupply() external view override returns(uint){
        return totalTokenSupply;
    }

    function balanceOf(address tokenOwner) external view override returns (uint balance){
        return tokenBalance[tokenOwner];
    }

    function transfer(address to, uint tokens) external override returns (bool success){
        require(to != msg.sender,"cannot transfer to self");
        require(tokenBalance[msg.sender] >= tokens,"not enough balance");
        tokenBalance[to] += tokens;
        tokenBalance[msg.sender] -= tokens;
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    function approve(address spender, uint tokens) external override returns (bool success){
        require(spender != msg.sender,"cannot approve self");
        require(tokenBalance[msg.sender] >= tokens,"not enough balance");
        require(tokens>0,"tokens should be greater than zero");
        allowedMap[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) external view override returns (uint tokensAllowed){
        return allowedMap[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) external override returns (bool success){
        require(to != from,"cannot receive the transfer amount in the same account");
        require(allowedMap[from][to]>=tokens,"not allowed for this much tokens");
        require(tokenBalance[from]>=tokens,"not enough balance");
        tokenBalance[from] -= tokens;
        tokenBalance[to] += tokens;
        return true;
    }


}