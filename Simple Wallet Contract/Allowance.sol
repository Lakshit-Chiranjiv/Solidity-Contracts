// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable {
    // address payable public owner;

    // constructor(){
    //     owner = payable(msg.sender);
    // }

    // modifier onlyOwner() {
    //     require(msg.sender == owner,"Only owner can withdraw ether!!");
    //     _;
    // }

    using SafeMath for uint;

    event AllowanceChanged(address indexed _whose,address indexed _byWhom,uint _oldAllowance,uint _newAllowance);

    mapping(address => uint) public allowance;

    function addAllowance(address _who,uint _amount) public onlyOwner {
        emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who].add(_amount));
        allowance[_who] = allowance[_who].add(_amount);
    }

    modifier ownerOrAllowed(_amount) {
        //owner function comes from the ownable smart contract and it returns the owner address
        require(msg.sender==owner()  || allowance[msg.sender] >= _amount,"Not allowed to withdraw");
        _;
    }

    function reduceAllowance(address _who,uint _amount) internal {
        emit AllowanceChanged(_who,msg.sender,allowance[_who],allowance[_who].sub(_amount));
        allowance[_who] = allowance[_who].sub(_amount);
    }
}