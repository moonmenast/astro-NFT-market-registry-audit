require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const privateKey = "5a1e04f625ca11d4074a18213010842cab29219db8d8e27ada2f43c9ad53948a"; // add metamask privateKey here
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork:"BSCTest",//change to BSCMain when deploying
  networks:{
    BSCTest:{
      url:"https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts:[privateKey]
    },
    BSCMain:{
      url:"https://bsc-dataseed.binance.org/",
      accounts:[privateKey]
    }
  },
  solidity: "0.6.12",
};

