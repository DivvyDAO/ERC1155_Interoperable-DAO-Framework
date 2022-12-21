const Upgrade = artifacts.require("Upgrade");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Upgrade", function (/* accounts */) {
  it("should assert true", async function () {
    await Upgrade.deployed();
    return assert.isTrue(true);
  });
});
