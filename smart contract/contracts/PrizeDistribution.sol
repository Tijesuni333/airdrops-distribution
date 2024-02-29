// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../contracts/VRFv2Consumer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PrizeDistribution is VRFConsumerBaseV2, Ownable{
    
    struct Participant {
        bool registered;
        uint256 entryCount;        
        bool hasClaimed;
    }


    event Registered(address indexed user);
    event EntryEarned(address indexed user, uint256 entryCount);
    event PrizeClaimed(address indexed user, uint256 amount);
    
    IERC20 public prizeToken; 
    uint256 public totalEntries;
    uint256 public maxEntriesPerUser;
    uint256 public prizeAmount;
    uint256 public winnerCount;
    
    mapping(address => Participant) public participants;


   constructor(address _vrfCoordinator, address _prizeToken) VRFConsumerBaseV2(_vrfCoordinator)Ownable(msg.sender){
     prizeToken = IERC20(_prizeToken);
    }

    function participate() external {
        participation[msg.sender]++;
    }

    function register() external {
        require(!participants[msg.sender].registered, "Already registered");
        
        participants[msg.sender] = Participant(true, 0, false);  
        emit Registered(msg.sender);
    }

    function earnEntry() external {
        Participant storage participant = participants[msg.sender];
        require(participant.registered, "User not registered");
        require(participant.entryCount < maxEntriesPerUser, "Max entries reached");

        participant.entryCount++;
        totalEntries++;

        emit EntryEarned(msg.sender, participant.entryCount);
    }

    function triggerPrize() external onlyOwner {
        // Use Chainlink VRF to select winners
        uint256 requestId = requestRandomWords();
        fulfillRandomWords(requestId);
    }  

    function claimPrize() external {
        require(!hasClaimed[msg.sender], "Prize already claimed");

        uint256 userParticipation = participation[msg.sender];
        require(userParticipation > 0, "No participation");

        // Use Chainlink VRF to get random number
        uint256 requestId = requestRandomWords();

        // Callback receives random number
        fulfillRandomWords(requestId, userParticipation); 

        hasClaimed[msg.sender] = true;
    }


    function fulfillRandomWords(uint256 _requestId, uint256 _userParticipation) internal override {
        require(_userParticipation > 0, "No participation");
        
        uint256 randomNumber = randomResult();
        uint256 prizeAmount = (randomNumber % 100) * prizeToken.balanceOf(address(this)) / 100;
        require(prizeToken.transfer(msg.sender, prizeAmount), "Transfer failed");

        emit PrizeClaimed(msg.sender, prizeAmount);
    }

    function setPrizeAmount(uint256 amount) external onlyOwner {
        require(prizeToken.approve(address(this), amount), "Approval failed");
        prizeAmount = amount;
        require(prizeToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }


}