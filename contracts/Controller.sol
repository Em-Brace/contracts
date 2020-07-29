pragma solidity ^0.5.0;

import { ERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts/math/Math.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";

contract Controller is Initializable {

  using SafeMath for uint256;
  struct Transaction {
    uint256 timestamp;
    uint256 amount;
  }
  address public parent;
  address public child;
  uint256 public dailyLimit;
  Transaction[] public transactions;
  IERC20 public tokenInstance;
  event DailyLimitChanged(uint256 previousLimit, uint256 newLimit);
  event AdditionalSpendingForTodayApproved(address childAddress, uint256 amount);
  event SpendingHappend(address from, address to, uint256 balance);

  modifier isParent(){
    require(
      msg.sender == parent, "Only parents can perform this operation"
    );
    _;
  }
  modifier isChild(){
    require(
      msg.sender == child, "Only child can perform this operation"
    );
    _;
  }
  // might not be modifier, in order to implement delayed transactions and parents signature when limit in violated ( all in one transaction )
  // modifier isBelowDailyLimit(){
  //   require(
  //     todaysSpending() < dailyLimit, "Daily limit is exceeded"
  //   );
  //   _;
  // }
  function initialize(address _parent, address _child, uint256 _dailyLimit, address _token, uint256 _beginning) public initializer{
      parent = _parent;
      child = _child;
      dailyLimit = _dailyLimit;
      tokenInstance = _token;
  }
  function() external payable{}

  function todayExcact() public view returns (uint256){
      return now;
  }
  function todaysBeginning() public view returns (uint256){
      return now - (now % 1 days);
  }
  function todaysEnding() public view returns (uint256){
      return this.todaysBeginning() + 1 days;
  }
  function todaysSpending() public view returns (uint256){
      uint256 beginning = this.todaysBeginning();
      uint256 ending = this.todaysEnding();
      uint256 spending = 0;
      for(uint256 i = 0; i < transactions.length; i++){
        if(transactions[i].timestamp >= beginning && transactions[i].timestamp <= ending){
          spending += (transactions[i].amount);
        }
      }
      return spending;
  }
  function clearNonTodaysSpending() internal returns (bool){
      uint256 beginning = this.todaysBeginning();
      uint256 ending = this.todaysEnding();
      for(uint256 i = 0; i < transactions.length; i++){
        if(transactions[i].timestamp >= beginning && transactions[i].timestamp <= ending) {
            delete transactions[i];   
        }
      }
  }
  function spend(uint256 amount, address destination) public isChild isParent returns (bool){
      this.clearNonTodaysSpending();
      uint256 balance = tokenInstance.balanceOf(address(this));
      require(balance >= amount , 'Not enough balance');
      require(this.todaysSpending() >= amount)
      bool success = tokenInstance.safeTransfer(destination, balance);
      if(success){
        emit SpendingHappend(address(this), destination, balance);
        Transaction storage latest = new Transaction({timestamp: now, amount: amount});
        transactions.push(latest)
      }
      else return false;    
  }

}