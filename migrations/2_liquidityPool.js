// migrations/2_deploy_liquidity_pool.js

const LiquidityPool = artifacts.require("LiquidityPool");

module.exports = function (deployer) {
  const initialLiquidity = web3.utils.toWei("1000", "ether"); // Example initial liquidity
  const rewardRate = 5; // Example reward rate
  const collateralFactor = 50; // 50%

  deployer.deploy(LiquidityPool, initialLiquidity, rewardRate, collateralFactor);
};
