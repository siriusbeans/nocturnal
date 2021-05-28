module.exports = {
  mocha: {
    timeout: 3600000
  },
  rpc: {
    host: "localhost",
    port: 8545
  },
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "50",
      gas: 112100011,
      gasPrice: 1
    },
    testnet: {
      host: "localhost",
      port: 8545,
      network_id: "50",
      gas: 112100011,
      gasPrice: 20000000000
    },
  },
  compilers: {
     solc: {
       version: "0.8.0"
     }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 1000000
    }
  }
};
