require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

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

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.5.17",
};


const INFURA_API_KEY = process.env.INFURA_API_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (INFURA_API_KEY != undefined && PRIVATE_KEY != undefined) {
  module.exports.networks.kovan = {
    url: `https://kovan.infura.io/v3/${INFURA_API_KEY}`,
    accounts: [PRIVATE_KEY],
    timeout: 20000
  };

  module.exports.networks.rinkeby = {
    url: `https://rinkeby.infura.io/v3/${INFURA_API_KEY}`,
    accounts: [PRIVATE_KEY],
    timeout: 20000
  };

  module.exports.networks.ropsten = {
    url: `https://ropsten.infura.io/v3/${INFURA_API_KEY}`,
    accounts: [PRIVATE_KEY],
    timeout: 20000
  };

  module.exports.networks.mainnet = {
    url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
    accounts: [PRIVATE_KEY],
    timeout: 20000
  };
}
