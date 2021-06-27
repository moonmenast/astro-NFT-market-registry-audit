
async function main() {
    const MarketV2 = await ethers.getContractFactory("StarRegistryV2");
    let marketV2 = await upgrades.upgradeProxy("address-here",MarketV2);
    console.log(marketV2.address)

}

main().then(()=>process.exit(0)).
catch(error=>{
    console.error(error)
    process.exit(1)
})