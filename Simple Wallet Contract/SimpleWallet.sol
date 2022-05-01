// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Allowance.sol";

contract SimpleWallet is Allowance {

    event MoneyWithdrawn(address indexed _by,uint _amount);
    event MoneyReceived(address indexed _by,uint _amount);

    //function to transfer/withdraw ether from contract to a given account
    //owner can withdraw unlimited amount and someone else can only withdraw allowed amount
    function withdrawEther(address payable _to,uint _amount) public payable ownerOrAllowed(_amount){
        require(_amount <= address(this).balance,"Not enough balance in wallet contract");
        if(msg.sender != owner())
            reduceAllowance(msg.sender,_amount);
        emit MoneyWithdrawn(msg.sender,_amount);
        _to.transfer(_amount);
    }

    //this function is part of Ownable contract through which we can set no one as the owner of contract
    //overridden as we don't need it
    function renounceOwnership() public override view onlyOwner {
        revert("Can't renounce ownership here !!");
    }

    //fallback function to receive ether to contract
    receive() external payable{
        emit MoneyReceived(msg.sender,msg.value);
    }
}