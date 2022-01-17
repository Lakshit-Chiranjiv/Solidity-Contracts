// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC721 {
    function transfer(address, uint) external;

    function transferFrom(
        address,
        address,
        uint
    ) external;
}

contract NFTAuctionContract{

    address payable public nftSeller;

    bool public started;
    bool public ended;
    uint public endTime;

    uint public highestBid;
    address public highestBidder;

    mapping(address => uint) public bidsMap;

    event AuctionStarted();
    event AuctionEnded(address highestBidder,uint highestBid);
    event MadeBid(address indexed sender,uint amount);
    event Withdrawn(address indexed bidder,uint amount);

    IERC721 public nft;
    uint public nftId;

    constructor(){
        nftSeller = payable(msg.sender);
 
    }

    modifier OnlySeller(){
        require(msg.sender == nftSeller,"only seller can do this");
        _;
    }

    function startAuction(IERC721 _nft,uint _nftId,uint basePrice) OnlySeller external{
        require(!started,"auction is already started");
        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender,address(this),nftId);
        started = true;
        endTime = block.timestamp + 600;
        highestBid = basePrice;
        emit AuctionStarted();
    }

    function endAuction() OnlySeller external{
        require(started,"auction has not yet started");
        require(!ended,"auction has already ended");
        require(endTime <= block.timestamp,"its not yet time to end the auction");
        ended = true;

        if(highestBidder != address(0)){
            nft.transfer(highestBidder,nftId);
            (bool sent, bytes memory data) = nftSeller.call{value : highestBid}("");
            require(sent,"could not pay seller");
        }
        else{
            nft.transfer(nftSeller,nftId);
        }
        emit AuctionStarted();
    }

    function makeBid() external payable{
        require(started,"auction has not yet started");
        require(!ended,"auction has already ended");
        require(msg.value > highestBid,"need a price greater than previous highest bid");

        if(highestBidder != address(0))
            bidsMap[highestBidder] += highestBid;

        highestBid = msg.value;
        highestBidder = msg.sender; 
        emit MadeBid(msg.sender,highestBid);
    }

    function withdrawAmount() external payable{
        uint balance = bidsMap[msg.sender];
        bidsMap[msg.sender] = 0;
        (bool sent, bytes memory data) = payable(msg.sender).call{value : balance}("");
        require(sent,"could not withdraw amount");

        emit Withdrawn(msg.sender,balance);
    }
}