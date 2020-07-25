pragma solidity ^0.6.0;

import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";

contract Controller is Initializable {

  using SafeMath for uint256;

  address public parent;
  address public child;
  uint256 public dailyLimit;

  function initialize(address _parent, address _child, uint256 _dailyLimit) public initializer {
      parent = _parent;
      child = _child;
      dailyLimit = _dailyLimit;
  }
  function changeDailyLimit(uint256 _newDailyLimit) public returns (bool){
      dailyLimit = _newDailyLimit;
  }
  // function increase(uint256 amount) public {
  //     value += amount;
  // }
}