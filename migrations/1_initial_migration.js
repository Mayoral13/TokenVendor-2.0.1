const Vendor = artifacts.require("TokenVendor");
module.exports = async function (deployer) {
  await deployer.deploy(Vendor);

  
};
