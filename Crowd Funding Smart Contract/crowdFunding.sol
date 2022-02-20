// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0; 

//Decentralized Crowd Funding Application
contract CrowdFundingApp{

    address payable public manager;
    uint public minimumDonation;
    uint public targetAmount;
    uint public deadLine;
    uint public raisedAmount;
    uint public noOfContributors;
    mapping(address => uint) donators;

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint=>Request) public requests;
    uint public numRequests;

    constructor(uint targetAmt,uint duration){
        manager = payable(msg.sender);
        targetAmount = targetAmt * (1 ether);
        deadLine = block.timestamp + duration;
        minimumDonation = 1 ether;
    }

    modifier onlyManager(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }

    function makeDonation() public payable{
        require(block.timestamp < deadLine,"crowdFunding has ended");
        require(msg.value >= minimumDonation,"min donation is 1 ether");
        if(donators[msg.sender] == 0){
            donators[msg.sender] = msg.value;
            noOfContributors++;
        }
        else{
            donators[msg.sender] += msg.value;
        }
        raisedAmount += msg.value;
    }

    function getContractBalance() public view returns(uint){
        return (address(this).balance)/(1 ether);
    }

    function fundingTimeLeft() public view returns(uint){
        return deadLine - block.timestamp;
    }

    function refundUser() public{
        require(block.timestamp>deadLine && raisedAmount<targetAmount,"you can't refund");
        require(donators[msg.sender]>0,"you didn't donated");
        address payable user = payable(msg.sender);
        (bool sent, bytes memory data1) = payable(user).call{value : donators[user]}("");
        require(sent,"could not refund");
        donators[user] = 0;
    }

    function createRequest(string memory desc,address payable recpt,uint val) onlyManager public{
        Request storage req = requests[numRequests];
        numRequests++;
        req.description = desc;
        req.recipient = recpt;
        req.value = val;
        req.completed = false;
        req.noOfVoters = 0;
    }

    function voteForRequest(uint reqNo) public{
        require(donators[msg.sender]>0,"you are not a donator so you can't vote");
        Request storage req = requests[reqNo];
        require(req.voters[msg.sender]==false,"you have already voted for this request");
        req.voters[msg.sender] = true;
        req.noOfContributors++;
    }

    function grantFunds(uint reqNo) public{
        require(targetAmount <= raisedAmount,"target amount not raised yet");
        Request storage req = requests[reqNo];
        require(req.completed == false,"request has already been granted funds");
        require(req.noOfVoters >= noOfContributors,"majority vote is not there");
        (bool sent, bytes memory data1) = payable(req.recipient).call{value : req.value}("");
        require(sent,"could not grant fund");
        req.completed = true;
    }


    //fallback function
    receive() external payable
    {
        makeDonation();
    }

}
