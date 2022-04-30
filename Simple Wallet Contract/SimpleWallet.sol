// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimpleWallet {

    address payable public owner;

    constructor(){
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Only owner can withdraw ether!!");
        _;
    }

    //function to transfer/withdraw ether from contract to a given account
    function withdrawEther(address payable _to,uint _amount) public payable onlyOwner{
        _to.transfer(_amount);
    }

    //fallback function to receive ether to contract
    receive() external payable{

    }
}