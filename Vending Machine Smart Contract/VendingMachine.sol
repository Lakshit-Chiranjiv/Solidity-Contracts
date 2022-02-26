// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract VendingMachine{
    
    address payable public owner;
    uint public Chocolate_price;
    address payable public machineAddress;
    mapping(address=>uint) chocolates;
    uint machineBalance;

    constructor(address payable _machineAddress){
        owner = payable(msg.sender);
        Chocolate_price = 2 ether;
        machineAddress = payable(_machineAddress);
        chocolates[machineAddress] = 20;
    }

}