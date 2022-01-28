// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//Decentralized Lottery Application
contract LotteryApp{

    address payable public manager;
    address payable[] public people_participated;
    address public currentWinner;
    address public previousWinner;

    event Participated(address participant);
    event AmountTransferred(address transferredFrom,address transferredTo,uint amount);

    constructor(){
        manager = payable(msg.sender);
    }

    modifier OnlyManager(){
        require(msg.sender == manager,"only manager can call this function");
        _;
    } 

    function getContractBalance() OnlyManager public view returns(uint) {
        return address(this).balance;
    }

    function getNumOfParticipations() public view returns(uint) {
        return people_participated.length;
    }

    function participate() payable public{
        require(manager != msg.sender,"manager cannot participate");
        require(msg.value == 2 ether,"participation ticket is worth 2 ether");
        people_participated.push(payable(msg.sender));
        emit AmountTransferred(msg.sender,address(this),msg.value);
        emit Participated(msg.sender);
    }

    receive() external payable{
        participate();
    }

    function getRandomArrayIndex() internal view returns(uint){
        uint randomNum = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, people_participated.length)));
        uint randomIndex = randomNum % people_participated.length;
        return randomIndex;
    }

    function selectWinner() OnlyManager payable public returns(address){
        require(people_participated.length >= 3,"minimum 3 participants required");
        uint randomWinnerIndex = getRandomArrayIndex();
        currentWinner = people_participated[randomWinnerIndex];
        uint managerEarning = 1 ether;
        uint winnerReward = address(this).balance - (1 ether) ;
        (bool sent1, bytes memory data1) = payable(manager).call{value : managerEarning}("");
        require(sent1,"could not send earning to manager");
        (bool sent2, bytes memory data2) = payable(currentWinner).call{value : winnerReward}("");
        require(sent2,"could not send reward to winner");
        
        people_participated = new address payable[](0);
        previousWinner = currentWinner;
        currentWinner = address(0);
        return previousWinner;
    } 

    function getManagerBalance() OnlyManager view public returns(uint){
        return manager.balance;
    } 


}