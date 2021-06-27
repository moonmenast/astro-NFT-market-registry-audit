const { ethers, upgrades } = require("hardhat");

async function main() {
    const MarketV1 = await ethers.getContractFactory("StarRegistryV1");
    console.log("deploying proxy,MarketPlaceV1,proxy admin");
    const MarketV1Proxy = await upgrades.deployProxy(MarketV1,["AST address here",],{initializer:"initialize"}); //add BSCmain-net AST address here/currently set to testnet token address
    console.log("MarketProxy deployed to:"+MarketV1Proxy.address)
}

main().then(()=>process.exit(0)).
catch(error=>{
    console.error(error)
    process.exit(1)
})