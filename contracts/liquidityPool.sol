// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract LiquidityPool is ERC20 {
    mapping(address=>uint) public balances;
    mapping(address=>uint) public rewards;
    mapping(address=>uint) public borrowedAmount;
    mapping(address=>uint) private lastRewardUpdate;
    mapping(address=>uint) private lastRewardClaim;

    
     uint lockPeriod= 1 seconds;
    uint public totalLiquidity;
    address public owner;
    uint public rewardRate;
    uint public colleteralFactor;
   

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event Borrow(address indexed user, uint amount);
    event Repay(address indexed user, uint amount);
    event RewardClaimed(address indexed user, uint reward);
    event Liquidate(address indexed user, uint colleteralSeized);

    constructor(uint _totalLiquidity, uint _rewardRate, uint _colleteralFactor) ERC20("Magma Token", "MT"){
       require(_colleteralFactor <= 100, "number has to be appropriate");
       totalLiquidity = _totalLiquidity;
       rewardRate = _rewardRate;
       colleteralFactor = _colleteralFactor;
      
       owner = msg.sender;
       _mint(msg.sender, totalLiquidity);
    }


    modifier onlyOwner() {
        require(msg.sender==owner, "only owner has access");
        _;
    }

    function deposit(uint amount) public {
        require(amount>0, "amount must be greater than 0");
        updateReward(msg.sender);
        balances[msg.sender] += amount;
        totalLiquidity += amount;
        _transfer(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }


    function withdraw(uint amount) public  {
        require(balances[msg.sender] >= amount, "amount must be appropriate");
        require(borrowedAmount[msg.sender] == 0, "amount must be appropriate");
        updateReward(msg.sender);
        balances[msg.sender] -= amount;
        totalLiquidity -= amount;
        _transfer(address(this), msg.sender, amount);
         emit Withdraw(msg.sender, amount);

    }


    function borrow(uint amount) public  {
        uint maxBorrow = (balances[msg.sender] * colleteralFactor)/100;
        require(amount > 0 && amount<= maxBorrow, "Invalid borrow amount");
        require(amount<= totalLiquidity, "amount must be less than or equal to total liquidity");
        updateReward(msg.sender);
        borrowedAmount[msg.sender] += amount;
        totalLiquidity -= amount;
        _transfer(address(this), msg.sender, amount);
        emit Borrow(msg.sender, amount);

        


    }

    function repay(uint amount) public  {
        require(borrowedAmount[msg.sender] >= amount, "Repay amount exceeds borrowed amount");
        updateReward(msg.sender);
        borrowedAmount[msg.sender] -= amount;
        totalLiquidity += amount;
        _transfer(msg.sender, address(this), amount);
        emit Repay(msg.sender, amount);


    }

    function updateReward(address account) internal  {
       uint elapsedTime = block.timestamp - lastRewardUpdate[account];
       if (elapsedTime>0 && balances[account] > 0) {
        rewards[account] += (balances[account] * rewardRate * elapsedTime)/1;
       }
       lastRewardUpdate[account] = block.timestamp;

    }

        function claimReward() public  {
             updateReward(msg.sender);

        uint timeSinceLastClaim = block.timestamp - lastRewardClaim[msg.sender];
        require(timeSinceLastClaim >= lockPeriod, "Rewards are locked for 6 months");

        uint reward = rewards[msg.sender];
        require(reward > 0, "No reward to claim");

        rewards[msg.sender] = 0;
        lastRewardClaim[msg.sender] = block.timestamp; 
        _mint(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
            
        

    }

        function liquidate(address user) public onlyOwner  {
            uint colleteralValue = balances[user];
            uint borrowValue = borrowedAmount[user];
        require(borrowValue > colleteralValue, "Cannot liquidate");
        uint collateralSeized = balances[user];
        balances[user] = 0;
        borrowedAmount[user] = 0;
        totalLiquidity += collateralSeized;
        _transfer(address(this), owner, collateralSeized);

        emit Liquidate(user, collateralSeized);
        }


}
