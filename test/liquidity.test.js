// test/liquidity_pool.js

const LiquidityPool = artifacts.require("LiquidityPool");

contract("LiquidityPool", accounts => {
  const [owner, user1, user2] = accounts;

  let liquidityPool;

  before(async () => {
    liquidityPool = await LiquidityPool.deployed();
  });

  it("should deposit tokens", async () => {
    const depositAmount = web3.utils.toWei("100", "ether");
    
    // Mint tokens to user1 before depositing
    await liquidityPool.transfer(user1, depositAmount, { from: owner });

    await liquidityPool.deposit(depositAmount, { from: user1 });

    const balance = await liquidityPool.balances(user1);
    assert.equal(balance.toString(), depositAmount, "Deposit amount not credited correctly");
  });

  it("should allow withdrawal of tokens", async () => {
    const withdrawAmount = web3.utils.toWei("50", "ether");
    
    await liquidityPool.withdraw(withdrawAmount, { from: user1 });

    const balance = await liquidityPool.balances(user1);
    const expectedBalance = web3.utils.toWei("50", "ether");
    assert.equal(balance.toString(), expectedBalance, "Withdrawal amount not debited correctly");
  });

  
});
