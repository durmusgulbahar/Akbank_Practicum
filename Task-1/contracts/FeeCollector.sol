// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract FeeCollector{

    address public owner;
    uint256 public balance;

    constructor(){
        owner = msg.sender;
       
    }


    /*
    @dev Controls the if msg.sender is "owner"
    */
    modifier onlyOwner{
        require(msg.sender == owner, "Only owner can use this function.");
        _;
    }


    /*
    @dev "owner" sends contract's ethers to any address.
    @params _to -> address that will received ethers
    @params _amount -> amount of sending ethers
    */
    function withdraw(address payable _to , uint256 _amount) public payable onlyOwner{
        require(_amount <= balance, "Insufficient balance");
        _to.transfer(_amount);
    }

    /*
    @dev returns the balance of the contract. Created for tests.
    */
    function getBalance() public view returns(uint256){
        return balance;
    }


    /*
    @dev Contract accept the ethers and deposit balance.
    */
    receive() payable external{

        balance += msg.value;
    }

}