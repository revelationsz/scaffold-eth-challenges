pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier isComplete{
    require(!exampleExternalContract.completed(),"contract already completed");
      _;
  }
  
  receive() external payable {
    stake();
  }

  uint256 deadline = block.timestamp + 72 hours;
  mapping (address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  bool public withdrawbool = false;

  event Stake(address addy, uint256 balance);

  function stake() public payable {
  require(block.timestamp < deadline, "cant stake after execution");
  if(balances[msg.sender] == 0)  balances[msg.sender] = msg.value;
  else balances[msg.sender] += msg.value;

  emit Stake(msg.sender, msg.value);
 }
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

function execute() public payable isComplete() {
  if(deadline <= block.timestamp){
    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      withdrawbool = true;
    }
  }


}
  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

function withdraw(address payable test ) public payable isComplete() { 
     require(block.timestamp > deadline);
     require(withdrawbool);
     require(balances[msg.sender] > 0);

    uint256 ball = balances[msg.sender];
    balances[msg.sender] = 0;
    test.transfer(ball); 

}

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw(address payable)` function lets users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) { 
      if(deadline<block.timestamp) return 0;
      else return deadline - block.timestamp;
  }

  function showBool() public view returns (bool) { 
    return withdrawbool;
    }

  // Add the `receive()` special function that receives eth and calls stake()


}
