pragma solidity ^0.5.0;

import { ERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts/math/Math.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";

// I need to understand how to dynamically calculate dailylimit everytime;
contract Controller is Initializable {

  using SafeMath for uint256;

  address public parent;
  address public child;
  uint256 public dailyLimitGeneral;
  uint256 public dailyLimitConcrete;
  uint256 public spentSoFar;
  // uint256 constant now;
  // uint256 constant 1 days;
  uint256 dayBegining;
  uint256 dayEnding;
  IERC20 public tokenInstance;
  bool frozen;
  event DailyLimitGeneralChanged(uint256 previousLimit, uint256 newLimit);
  event DailyLimitConcreteChanged(uint256 previousLimit, uint256 newLimit);
  event AdditionalSpendingForTodayApproved(address childAddress, uint256 amount);
  event SpendingHappend(address from, address to, uint256 balance);

  modifier isParent(){
    require(
      msg.sender == parent, "Only parents can perform this operation");
      _;
    )
  }
  modifier isChild(){
    require(
      msg.sender == child, "Only child can perform this operation");
      _;
    )
  }
  function initialize(address _parent, address _child, uint256 _dailyLimit, address _token) public initializer {
      parent = _parent;
      child = _child;
      dailyLimit = _dailyLimit;
      tokenInstance = _token;
  }
  function() external payable{}

  function startNewDay(){
    uint256 newDayBegining = dayEnding + 1 minutes;
    uint256 newDayEnding = dayEnding + 1 days;
    dayBegining = newDayBegining;
    dayEnding = newDayEnding;
  }
  function changeDailyLimitGeneral(uint256 _newDailyLimit) public isParent {
      require(_newDailyLimit !< 0, 'No need to set negative limit; 0 is enough');
      uint256 previousLimit = dailyLimit;
      dailyLimit = _newDailyLimit;
      emit DailyLimitChanged(previousLimit, _newDailyLimit);
  }
  function approveAdditionalSpendingForToday(uint256 amount) public isParent return (bool) {
      uint256 balance = tokenInstance.balanceOf(address(this));
      require(amount != 0, 'Null not allowed');
      require(balance > amount, 'You approved additional spending for today, but there is not enough balance for `spend` to occur');
      dailyLimitConcrete.add(amount);
      event AdditionalSpendingForTodayApproved(address childAddress, uint256 amount);
  }
  function spend(uint256 amount, address destination) public isChild, isParent {
      uint256 balance = tokenInstance.balanceOf(address(this));
      require(balance >= amount , 'Not enough balance');
      require(spentSoFar <= dailyLimitConcrete, 'Approval of additional resources should be requested');
      bool success = tokenInstance.safeTransfer(destination, balance);
      if(success){
        emit SpendingHappend(address(this), destination, balance);
      }
      else revert;
  }

}