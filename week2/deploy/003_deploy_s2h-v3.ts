import {ethers, upgrades} from 'hardhat'
import {DeployFunction} from 'hardhat-deploy/types'
import storage from '../utils/storage'
import { HardhatRuntimeEnvironment } from 'hardhat/types'

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment ) {
  const config = await storage.readProxyConfig()
  const Six2HeroV3 = await ethers.getContractFactory('Six2HeroV3')
  const s2h = await upgrades.upgradeProxy(config[hre.network.name].proxy, Six2HeroV3, {kind: 'transparent'})
  await s2h.deployed()
  const implementation=await upgrades.erc1967.getImplementationAddress(s2h.address)
  config[hre.network.name].Six2HeroV3 =implementation
  await storage.writeProxyConfig(config)
}
export default func
func.id = 'Six2HeroV3'
func.tags = ['Six2HeroV3']
