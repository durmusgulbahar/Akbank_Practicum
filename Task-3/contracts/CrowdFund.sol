// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFund{

    /*
    @dev People can start campaign to collect fund.     
    */
    struct Campaign{
        address creator; // Creator of campaign
        uint goal;       // Goal token/money of the campaign
        uint32 startAt;  // Campaign started date. In unix timestamp format.
        uint32 endAt;    // Campaign end date. In unix timestamp format
        uint pledged;    // Total amount of pledged token.
        bool claimed;    // Amount of claimed token/money through campaign.
    }


    IERC20 public immutable token;              // Token that campaigns accept. Immutable means can not change.
    uint public count;                          // Every time created a campaign counts increase.
    mapping(uint => Campaign) public campaigns; // Unique ID for each campaign.
    mapping(uint=>mapping(address=>uint)) public pledgedAmount; // Amount of token user funded for each campaign
                                                                //campaign ID => address(user) => amountOfToken
   
   
    
    //  The indexed parameters for logged events will 
    //  allow you to search for these events using the indexed parameters as filters

    //  Events created for inform the front end of the application and fetching and filtering data.

    event Launch(uint indexed id,address indexed creator, uint goal,  uint32 startAt, uint32 endAt); 

    event Cancel(uint indexed id, address indexed creator);

    event Pledge(uint indexed id, address indexed pledger, uint amount);

    event Unpledge(uint indexed id, address indexed pledger, uint amount);

    event Claim(uint indexed id, address claimer, uint claimedAmount);

    event Refund(uint indexed id, address refundedAddress, uint refundAmount);



    constructor(address _tokenAddress){
       token = IERC20(_tokenAddress);  // We created the object of the existed token that Campaigns will accept.
    }
   

    /*
    @dev Launch the campaign with requirements, 
    @param _goal - Goal amount of token/money.
    @param _startAt - Start date of campaign
    @param _endAt - Finish date of campaign
    */
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
       
        //Controls the requirements.
        require(_startAt >= block.timestamp,"Start time is not valid."); 
        require(_endAt > _startAt, "End date must be after the startAt");
        require(_endAt <= block.timestamp + 90 days,"Max campaign time is 90 days.");
        require(_goal >0 , "Goal must be greater than 0");


        campaigns[count] = Campaign({  // Created a Campaign and added to "campaigns" mapping.
            creator : msg.sender,
            goal : _goal,
            startAt : _startAt,
            endAt : _endAt,
            pledged : 0,
            claimed : false
        });

        count += 1;

        emit Launch(count, msg.sender, _goal , _startAt, _endAt);
    }

    /*
    @dev Creator can cancel the campaign before it started.
    @param _id - Campaign ID.
    */
    function cancel(uint _id) external {

        Campaign memory campaign = campaigns[_id]; //We create a copy of the campaign to access its attributes.

        require(msg.sender == campaign.creator,"Only creator can cancel");
        require(block.timestamp < campaign.startAt, "Campaign has started already");

        delete campaigns[_id];
        emit Cancel(_id, msg.sender);

    }

    /*
    @dev People funds the campaign
    @param _id - Campaign ID
    @param _amount - Funded amount of token/money
    */
    function pledge(uint _id,uint _amount) external{

        Campaign storage campaign = campaigns[_id]; // We used "storage" because we need to update existed
                                                    // campaign, If we need to just read we can use "memory"
        require(block.timestamp >= campaign.startAt,"Campaign not started");
        require(block.timestamp <= campaign.endAt ,"Campaign has ended");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;

        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }
    

    /*
    @dev People can withdraw their funded token to the campaign
    */
    function unpledge(uint _id,uint _amount) external{

        Campaign storage campaign = campaigns[_id]; 

        uint pledgedAmountOfUser = pledgedAmount[_id][msg.sender]; 
        
        require(pledgedAmountOfUser >=_amount, "'amount' must be greater than pledged");
        require(block.timestamp <= campaigns[_id].endAt,"Campaign is ended");

        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        
        emit Unpledge(_id, msg.sender, _amount);


    }

    /*
    @dev If campaign finished successfully, owner will claim the funds.
    @param _id - Campaign ID
    */
    function claim(uint _id) external {
         
         Campaign storage campaign = campaigns[_id];

         require(msg.sender == campaign.creator,"Only campaign creator can claim");
         require(block.timestamp > campaign.endAt,"Campaign is not ended");
         require(campaign.pledged >= campaign.goal, "Pledged < goal");
         require(!campaign.claimed, "Campaign has already claimed");

         campaign.claimed = true;
         token.transfer(msg.sender, campaign.pledged);

         emit Claim(_id, msg.sender, campaign.pledged);
    }

    /*
    @dev If campaign couldn't reach the goal during campaign time, pays back to the pledgers/funders
    @param _id - Campaign ID.
    */
    function refund(uint _id) external{
        
        Campaign storage campaign = campaigns[_id];

        require(block.timestamp > campaign.endAt,"Campaign is not finished yet.");
        require(campaign.goal <= campaign.pledged,"pledged < goal");

        uint balance = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);

        emit Refund(_id, msg.sender, balance);
    }


}
