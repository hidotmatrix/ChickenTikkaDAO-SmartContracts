require("@nomiclabs/hardhat-ethers");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version:"0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
        details: { yul: false },
      },
    },
  },
  networks: {
    mumbai: {
      allowUnlimitedContractSize: true,
      url: process.env.ALCHEMY_POLYGON_MUMBAI_API_URL_HTTP,
      chainId: 80001,
      accounts: [process.env.DEPLOYER_PRIV_KEY],
    },
  },

};