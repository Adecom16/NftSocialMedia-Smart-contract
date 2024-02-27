require("dotenv").config();

import "@nomicfoundation/hardhat-toolbox";

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: process.env.ALCHEMY_API_KEY,
      accounts: [process.env.ACCOUNT_PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.POLYGON_API_KEY,
  },
};
