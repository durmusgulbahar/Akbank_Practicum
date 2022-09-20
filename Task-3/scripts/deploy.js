const { ethers } = require("hardhat");


async function main(){

    const tokenAddress = "Token address that you will change this whichever you want."

    const crowdFund = await ethers.getContractFactory("CrowdFund");
    const deployedCrowdFund = await crowdFund.deploy(tokenAddress);

    await deployedCrowdFund.deployed();

    console.log(`CrowdFund contract Address : ${deployedCrowdFund.address}`);
    
}

main().catch(error => {
    console.error;
    process.exitCode = 1;
})

