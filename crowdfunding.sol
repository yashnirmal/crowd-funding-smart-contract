//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


struct Campaign{
    string name;
    string description;
    address payable recipient;
    mapping(address=>uint) contributors;
    uint totalContributors;
    bool compeleted;
    uint deadline;
    uint raisedAmount;
    uint expectedTargetAmount;
}

contract CrowdFunding{

    address public manager;

    // index => campaign struct
    mapping(uint=>Campaign) public campaigns;
    uint public totalCampaigns;

    constructor(){
        manager = msg.sender;
        totalCampaigns = 0;
    }

    modifier onlyManager(){
        require(msg.sender == manager);
        _;
    }


    // only manager can create a new campaign 
    function createCampaign(string memory _name,string memory _description,address payable _recipient,uint _deadline,uint _expectedTargetAmount) public onlyManager{
        // storage keyword is used bcz we have used mapping in structure
        Campaign storage camp = campaigns[totalCampaigns];
        totalCampaigns++;      
        camp.name = _name;
        camp.description =_description;
        camp.recipient = _recipient;  
        camp.deadline = block.timestamp + _deadline*1 days;
        camp.raisedAmount=0;
        camp.compeleted = false;
        camp.totalContributors = 0;
        camp.expectedTargetAmount = _expectedTargetAmount*1 ether;
    }

    function contribute(uint index) public payable {
        require(campaigns[index].compeleted == false);
        require(block.timestamp <= campaigns[index].deadline);
        if(campaigns[index].contributors[msg.sender]==0){
            campaigns[index].totalContributors++;
        }
        campaigns[index].contributors[msg.sender] += msg.value;
        campaigns[index].raisedAmount += msg.value;
    }

    function totalFundsCollected() public view returns(uint){
        return address(this).balance;
    }

    function totalFundsCollectedForACampaign(uint index) public view returns(uint){
        return campaigns[index].raisedAmount;
    }

    function sendMoneyToRecipient(uint index) public payable onlyManager {
        require(block.timestamp >= campaigns[index].deadline);
        campaigns[index].recipient.transfer(campaigns[index].raisedAmount);
        campaigns[index].compeleted = true;
    }

}
