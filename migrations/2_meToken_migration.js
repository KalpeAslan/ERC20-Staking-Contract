const Migrations = artifacts.require('MeToken')

module.exports = function (deployer) {
    deployer.deploy(Migrations, "21000000000000000000000");
}