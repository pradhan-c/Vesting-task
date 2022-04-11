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
      const vesting = await Vesting.deploy(token.address,addr1.address,addr2.address, (parseInt(await time.latest()) + 100).toString(), true ,owner.address);
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });

    it("Transfer Token to Vesting Contract", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,addr1.address,addr2.address, (parseInt(await time.latest()) + 100).toString(), true ,owner.address);
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
      await token.transfer(vesting.address, "12000000000000000000000");
    });


    it("Cliff period release should revert", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,addr1.address,addr2.address, (parseInt(await time.latest()) + 100).toString(), true ,owner.address);
      await vesting.deployed();
      const ownerBalance = await token.balanceOf(owner.address);
    expect(await token.totalSupply()).to.equal(ownerBalance);
      await token.transfer(vesting.address, "12000000000000000000000");
      await time.increase(parseInt(time.duration.weeks('4')));
      await expectRevert(vesting.connect(owner).release(), "release: No tokens are due!");

    });
    it("the first day realease amount should be eaqual to", async function () {
      const [owner,addr1,addr2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory("Token");
      const token = await Token.deploy("PillowToken","PILW","1000000000000000000000000");
      await token.deployed();
      const Vesting = await ethers.getContractFactory("Vesting");
      const vesting = await Vesting.deploy(token.address,addr1.address,addr2.address, (parseInt(await time.latest()) + 100).toString(), true ,owner.address);
      await vesting.deployed();
      await token.transfer(vesting.address, "12000000000000000000000");
      await time.increase(parseInt(time.duration.days('62')));
      await vesting.connect(owner).release();
     
      expect(await token.balanceOf(addr2.address)).to.equal("10463378176382660687");
      expect(await token.balanceOf(addr1.address)).to.equal("7473841554559043347");
     

      

    });
    


    




    
});
