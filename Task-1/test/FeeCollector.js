const { expect } = require("chai");
const { ethers } = require("hardhat");

let App;
let owner;
let acc1;

describe("Fee Collector Contract", function () {
    it("Contract should be deployed", async function () {

        const feeCollector = await ethers.getContractFactory("FeeCollector");
        App = await feeCollector.deploy();

        await App.deployed();
        [owner,acc1] = await ethers.getSigners();
        console.log(
            `Fee collector deployed to ${App.address}`
        );
        
    })




    it("Only owner can use withdraw() function ", async function(){
        await expect(
            App.connect(acc1).withdraw(owner.address, 1)
          ).to.be.revertedWith("Only owner can use this function.");
    })


})