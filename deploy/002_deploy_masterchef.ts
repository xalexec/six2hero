import {HardhatRuntimeEnvironment} from 'hardhat/types'
import {DeployFunction} from 'hardhat-deploy/types'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployer} = await hre.getNamedAccounts()
  const {deploy} = hre.deployments

  await deploy('MasterChef', {
    from: deployer,
    args: [],
    log: true,
    autoMine: true, // speed up deployment on local network (ganache, hardhat), no effect on live networks
  })
}
export default func
func.id = 'MasterChef' // id required to prevent reexecution
func.tags = ['MasterChef']
