require('dotenv').config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const infuraProjectId = process.env.INFURA_PROJECT_ID;

module.exports = {
  networks: {
    development: {
      protocol: 'http',
      host: 'localhost',
      port: 8545,
      gas: 5000000,
      gasPrice: 5e9,
      networkId: '*',
    },
    ropsten: {
      provider: () => {return new HDWalletProvider(process.env.DEV_MNEMONIC, "https://ropsten.infura.io/v3/" + infuraProjectId, 0, 2)},
      network_id: 3,       // Ropsten's id
      gas: 5500000,        // Ropsten has a lower block limit than mainnet
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: false
    },
  },
};
