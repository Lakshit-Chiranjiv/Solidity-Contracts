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

    string public tokenName = "TestICOToken";
    string public tokenSymbol = "TESTICO";
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

    function totalSupply() public view override returns(uint){
        return totalTokenSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return tokenBalance[tokenOwner];
    }

    function transfer(address to, uint tokens) public virtual override returns (bool success){
        require(to != msg.sender,"cannot transfer to self");
        require(tokenBalance[msg.sender] >= tokens,"not enough balance");
        tokenBalance[to] += tokens;
        tokenBalance[msg.sender] -= tokens;
        emit Transfer(msg.sender,to,tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns (bool success){
        require(spender != msg.sender,"cannot approve self");
        require(tokenBalance[msg.sender] >= tokens,"not enough balance");
        require(tokens>0,"tokens should be greater than zero");
        allowedMap[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint tokensAllowed){
        return allowedMap[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){
        require(to != from,"cannot receive the transfer amount in the same account");
        require(allowedMap[from][to]>=tokens,"not allowed for this much tokens");
        require(tokenBalance[from]>=tokens,"not enough balance");
        tokenBalance[from] -= tokens;
        tokenBalance[to] += tokens;
        return true;
    }


}

contract icoContract is MyToken{

    address public icoManager;
    address payable public icoDeposit;

    uint icoTokenPrice = 0.2 ether;
    uint public icoCap = 200 ether;

    uint public collectedAmount;

    uint public icoStartTime = block.timestamp;
    uint public icoEndTime = block.timestamp + 300;

    uint icoTokenTradeTime = icoEndTime + 180;

    uint public icoMaxInvestment = 5 ether;
    uint public icoMinInvestment = 0.2 ether;

    enum icoState{beforeStart,afterEnd,running,halted}

    icoState public icoCurrentState;

    event Invest(address investor,uint value,uint tokens);


    constructor(address payable deposit){
        icoDeposit = deposit;
        icoManager = msg.sender;
        icoCurrentState = icoState.beforeStart;
    }

    modifier onlyManagerAccess(){
        require(msg.sender == icoManager,"only manager can call this function");
        _;
    }

    function haltICO() public onlyManagerAccess{
        icoCurrentState = icoState.halted;
    }

    function resumeICO() public onlyManagerAccess{
        icoCurrentState = icoState.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyManagerAccess{
        icoDeposit = newDeposit;
    }

    function getICOState() public view returns(string memory state){
        if(icoCurrentState == icoState.halted)
            return "halted";
        else if(block.timestamp < icoStartTime)
            return "before start";
        else if(block.timestamp > icoEndTime)
            return "already ended";
        else
            return "running"; 
    }

    function getICOStateAsState() public view returns(icoState){
        if(icoCurrentState == icoState.halted)
            return icoState.halted;
        else if(block.timestamp < icoStartTime)
            return icoState.beforeStart;
        else if(block.timestamp > icoEndTime)
            return icoState.afterEnd;
        else
            return icoState.running; 
    }

    function investinICO() payable public returns(bool){
        icoCurrentState = getICOStateAsState();
        require(icoCurrentState == icoState.running,"ico is not running now");
        require(msg.value > icoMinInvestment && msg.value < icoMaxInvestment,"invest is not within range");

        collectedAmount += msg.value;

        uint noOfTokens = msg.value/icoTokenPrice;

        tokenBalance[msg.sender] += noOfTokens;
        tokenBalance[tokenFounder] -= noOfTokens;

        icoDeposit.transfer(msg.value);

        emit Invest(msg.sender,msg.value,noOfTokens);
        return true;

    }

    function burnICOTokens() public onlyManagerAccess returns(bool){
        icoCurrentState = getICOStateAsState();
        require(icoCurrentState == icoState.afterEnd,"ico has not yet ended");
        tokenBalance[tokenFounder] = 0;
        return true;
    }

    function transfer(address to,uint tokens) public override returns(bool success){
        require(block.timestamp > icoTokenTradeTime,"token trade time hasn't yet started");
        super.transfer(to,tokens);
        return true;
    }

    function transferFrom(address from,address to,uint tokens) public override returns(bool success){
        require(block.timestamp > icoTokenTradeTime,"token trade time hasn't yet started");
        MyToken.transferFrom(from,to,tokens);
        return true;
    }

    receive() external payable{
        investinICO();
    }

}