const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new  once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setTx = await greeter.set("Hola, mundo!");

    // wait until the transaction is mined
    await setTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
