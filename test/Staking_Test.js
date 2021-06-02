

var WethToken = artifacts.require("WethToken");
const NocturnalFinance = artifacts.require("./NocturnalFinance.sol");
const NoctStaking = artifacts.require("./NoctStaking.sol");

contract("Staking", (accounts) => {
    it("Staking exists", () => {
        return NoctStaking.deployed().then(async function (
            instance
        ) {
            assert.equal(
                typeof instance,
                "object",
                "Contract instance does not exist"
            );
        });
    });

    it("can stake", () => {
        return WethToken.new().then(async function (token
        ) {
            return NocturnalFinance.new( {from: accounts[0]}).then(async function (fin
            ) {
                await fin.initNocturnal(9, accounts[0],  {from: accounts[0]});
                await fin.initNocturnal(10, accounts[0],  {from: accounts[0]});
                await fin.initNocturnal(12, token.address,  {from: accounts[0]});
                return NoctStaking.new(fin.address).then(async function (
                    instance
                ) {
                    await token.mint(accounts[0], 10000,  {from: accounts[0]});
                    await token.approve(instance.address, 10000,  {from: accounts[0]});
                    await instance.stake(10000,  {from: accounts[0]});
                    var balance = await instance.balanceOf(accounts[0]);
                    assert.equal(
                        balance.toString(),
                        "10000",
                        "incorrect sNOCT balance"
                    );
                });
            });
        });
    });

    it("can withdraw", () => {
        return WethToken.new().then(async function (token
        ) {
            return NocturnalFinance.new( {from: accounts[0]}).then(async function (fin
            ) {
                await fin.initNocturnal(9, accounts[0],  {from: accounts[0]});
                await fin.initNocturnal(10, accounts[0],  {from: accounts[0]});
                await fin.initNocturnal(12, token.address,  {from: accounts[0]});
                return NoctStaking.new(fin.address).then(async function (
                    instance
                ) {
                    await token.mint(accounts[0], 10000,  {from: accounts[0]});
                    await token.approve(instance.address, 10000,  {from: accounts[0]});
                    await instance.stake(10000,  {from: accounts[0]});
                    await instance.withdraw(10000,  {from: accounts[0]});
                    var balance = await instance.balanceOf(accounts[0]);
                    assert.equal(
                        balance.toString(),
                        "0",
                        "incorrect sNOCT balance"
                    );
                });
            });
        });
    });
});