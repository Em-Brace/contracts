pragma solidity ^0.5.0;

import { ERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts/math/Math.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";

// I need to understand how to dynamically calculate dailylimit everytime;
contract Controller is Initializable {

  struct Transaction {
    uint256 timestamp;
    uint256 amount;
  }

  using SafeMath for uint256;

  address public parent;
  address public child;
  uint256 public _dailyLimit;
  uint256 initialBeginning;
  uint256 initialEnding;
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
  // maybe this should not be modifier in order for request for additionalSpending to occur automatically;
  modifier isUnderDailyLimit(){
    require(
      checkTodaysSpending() < _dailyLimit, "Daily limit is exceeded"
    )
  }
  function initialize(address _parent, address _child, uint256 _dailyLimit, address _token, uint256 _beginning) public initializer{
      parent = _parent;
      child = _child;
      dailyLimit = _dailyLimit;
      tokenInstance = _token;
      beginning = _beginning;
      ending = beginning.add(1 days);
  }
  function() external payable{}

  function clearStaleTransactions(uint 256 todaysBeginning, uint256 todaysEnding){
    for(uint256 i = 0; i < transactions.length; i++){
      if(transactions[i].timestamp >= todaysBeginning && transactions[i].timestamp <= todaysEnding) delete transactions[i];
    }
  }
  function getTodaysBeginning(uint256 currentTimestamp) public returns (uint256){
    uint256 currentDay = (currentTimestamp - currentTimestamp.mod(1 days)).divide(initialBeginning);
    return currentDay;
  }
  function checkTodaysSpending() public returns (uint256){
    uint256 from = getTodaysBeginning(now);
    uint256 to = from.add(1 days);
    uint256 spending = 0;
    for(uint256 i = 0; i < transactions.length; i++){
      if(transactions[i].timestamp >= from && transactions[i].timestamp <= to){
        limit.add(transactions[i].amount);
      }
    }
    return spending;
  }
  function changeDailyLimitGeneral(uint256 _newDailyLimit) public isParent{
      require(_newDailyLimit !< 0, 'No need to set negative limit; 0 is enough');
      uint256 previousLimit = dailyLimit;
      dailyLimit = _newDailyLimit;
      emit DailyLimitChanged(previousLimit, _newDailyLimit);
  }
  // function approveAdditionalSpendingForToday(uint256 amount) public isParent return (bool) {
  //     uint256 balance = tokenInstance.balanceOf(address(this));
  //     require(amount != 0, 'Null not allowed');
  //     require(balance > amount, 'You approved additional spending for today, but there is not enough balance for `spend` to occur');
  //     dailyLimitConcrete.add(amount);
  //     event AdditionalSpendingForTodayApproved(address childAddress, uint256 amount);
  // }
  function spend(uint256 amount, address destination) public isChild, isParent{
      this.clearStaleTransactions();
      uint256 balance = tokenInstance.balanceOf(address(this));
      require(balance >= amount , 'Not enough balance');
      require(spentSoFar <= dailyLimitConcrete, 'Approval of additional resources should be requested');
      spentSoFar.add(amount);
      bool success = tokenInstance.safeTransfer(destination, balance);
      if(success){
        emit SpendingHappend(address(this), destination, balance);
      }
      else revert;    
  }

}