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
  uint256 beginning;
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
  // modifier canSpend(){
  //   require(

  //   )
  // }
  function initialize(address _parent, address _child, uint256 _dailyLimit, address _token, uint256 _beginning) public initializer {
      parent = _parent;
      child = _child;
      dailyLimit = _dailyLimit;
      tokenInstance = _token;
      beginning = _beginning;
  }
  function() external payable{}

  function clearStaleTransactions(uint 256 beginning, uint256 ending){
    for(uint256 i = 0; i < transactions.length; i++){
      if(transactions[i].timestamp >= beginning && transactions[i].timestamp <= ending) delete transactions[i];
    }
  }
  function changeDailyLimitGeneral(uint256 _newDailyLimit) public isParent {
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
  function spend(uint256 amount, address destination) public isChild, isParent {
      // if()
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
    function spend(uint256 amount, address destination) public isChild, isParent {

  }

}