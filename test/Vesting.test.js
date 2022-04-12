const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
const {
    BN, // Big Number support
    constants, // Common constants, like the zero address and largest integers
    expectEvent, // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
    time,
  } = require("@openzeppelin/test-helpers");

describe("Vesting", function () {
    it("Should get deployed", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,"1000000000000000000000000");
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);

    });
    it("Total supply should equal owner balance", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,"1000000000000000000000000");
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });
    it("Transfer token to vesting address", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,"1000000000000000000000000");
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
      await token.transfer(vesting.address, "12000000000000000000000");
    });

    
    it("Add Vesting schedule for advisor", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,"1000000000000000000000000");
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
      await token.transfer(vesting.address, "12000000000000000000000");
      await vesting.createVestingSchedule(addr1.address,0,1649773074,5184000,669000,86400,669,false);
      await time.increase(parseInt(time.duration.weeks('4')));
      await expectRevert(vesting.connect(owner).release(addr1.address), "no token in cliff period");
    });

    it("Add Vesting schedule for advisor", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,"1000000000000000000000000");
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
      await token.transfer(vesting.address, "12000000000000000000000");
      await vesting.createVestingSchedule(addr1.address,0,(parseInt(await time.latest()) + 100).toString(),5184000,669000,86400,669,false);
      
      await time.increase(parseInt(time.duration.days('62')));
      await vesting.connect(owner).release(addr1.address);
      expect(await token.balanceOf(addr1.address)).to.equal("1000");
   
    }); 
});
