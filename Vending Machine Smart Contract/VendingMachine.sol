// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract VendingMachine{
    
    address payable public owner;
    uint public Chocolate_price;
    mapping(address=>uint) public chocolates;
    uint machineBalance;

    constructor(){
        owner = payable(msg.sender);
        Chocolate_price = 2 ether;
        chocolates[address(this)] = 20;
    }

    function getAvailableChocolates() public view returns(uint){
        return chocolates[address(this)];
    }

    modifier onlyMachineOwner() {
        require(msg.sender == owner,"only owner can call this function");
        _;
    }

    function reStockMachine(uint stockChocolates) onlyMachineOwner public {
        chocolates[address(this)] += stockChocolates;
    }

    function buyChocolates(uint numOfChocolates) public payable{
        require(msg.value == (2*numOfChocolates)* 1 ether,"each chocolate costs 2 ether");
        require(chocolates[address(this)] >= numOfChocolates,"these many chocolates are not available");
        machineBalance += msg.value;
        chocolates[msg.sender] += numOfChocolates;
        chocolates[address(this)] -= numOfChocolates;
    }

    function receive() external payable{

    }

    function checkMachineBalance() onlyMachineOwner public view returns(uint){
        return (machineBalance/1 ether);
    }

    function debitFundFromMachine() onlyMachineOwner public payable{
        require(machineBalance > 0,"no ethers in machine yet");
        (bool sent, bytes memory data) = payable(owner).call{value : machineBalance}("");
        require(sent,"could not fund the owner");
        machineBalance = 0;
    }

}