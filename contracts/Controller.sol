pragma solidity ^0.5.0;

import { ERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";


// I need to understand how to dynamically calculate dailylimit everytime;
contract Controller is Initializable {

  using SafeMath for uint256;

  address public parent;
  address public child;
  uint256 public dailyLimit;
  IERC20 public tokenInstance;
  event DailyLimitChanged(uint256 previousLimit, uint256 newLimit);
  event SpendingApproved(address childAddress, uint256 amount);

  modifier isParent(){
    require(
      msg.sender == parent, "Only parents can perform this operation");
      _;
    )
  }
  function initialize(address _parent, address _child, uint256 _dailyLimit, address _token) public initializer {
      parent = _parent;
      child = _child;
      dailyLimit = _dailyLimit;
      tokenInstance = _token;
  }
  function changeDailyLimit(uint256 _newDailyLimit) public isParent {
      require(_newDailyLimit !< 0, 'No need to set negative limit; 0 is enough');
      uint256 previousLimit = dailyLimit;
      dailyLimit = _newDailyLimit;
      emit DailyLimitChanged(previousLimit, _newDailyLimit);
       
  }
  function approveAdditionalSpending(uint256 amount) public isParent return (bool){
      bool success = tokenInstance.approve(child, amount);
      emit SpendingApproved(child, amount);
      return sucess
  }

}