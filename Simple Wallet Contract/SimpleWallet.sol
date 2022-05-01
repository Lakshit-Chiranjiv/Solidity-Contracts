// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Allowance is Ownable {
    // address payable public owner;

    // constructor(){
    //     owner = payable(msg.sender);
    // }

    // modifier onlyOwner() {
    //     require(msg.sender == owner,"Only owner can withdraw ether!!");
    //     _;
    // }

    event AllowanceChanged(address indexed _whose,address indexed _byWhom,uint _oldAllowance,uint _newAllowance);

    mapping(address => uint) public allowance;

    function addAllowance(address _who,uint _amount) public onlyOwner {
        emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who]+_amount);
        allowance[_who] += _amount;
    }

    modifier ownerOrAllowed(_amount) {
        //isOwner function comes from the ownable smart contract and it checks if msg.sender is owner or not
        require(isOwner() || allowance[msg.sender] >= _amount,"Not allowed to withdraw");
        _;
    }

    function reduceAllowance(address _who,uint _amount) internal {
        emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who]-_amount);
        allowance[_who] -= _amount;
    }
}

contract SimpleWallet is Allowance {

    //function to transfer/withdraw ether from contract to a given account
    //owner can withdraw unlimited amount and someone else can only withdraw allowed amount
    function withdrawEther(address payable _to,uint _amount) public payable ownerOrAllowed(_amount){
        require(_amount <= address(this).balance,"Not enough balance in wallet contract");
        if(!isOwner())
            reduceAllowance(msg.sender,_amount);
        _to.transfer(_amount);
    }

    //fallback function to receive ether to contract
    receive() external payable{

    }
}