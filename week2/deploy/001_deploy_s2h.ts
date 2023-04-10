import {ethers, upgrades} from 'hardhat'
import {DeployFunction} from 'hardhat-deploy/types'
import storage from '../utils/storage'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const Six2Hero = await ethers.getContractFactory('Six2Hero')
  const s2h = await upgrades.deployProxy(Six2Hero, ['Six2Hero', 'S2H'], {kind: 'transparent'})
  await s2h.deployed()
  console.log(s2h.address, ' s2h(proxy) address')
  const config = await storage.readProxyConfig()
  const proxy = s2h.address
  const proxyAdmin=await upgrades.erc1967.getAdminAddress(s2h.address)
  const implementation=await upgrades.erc1967.getImplementationAddress(s2h.address)
  if(!config[hre.network.name]){config[hre.network.name]={}}
  config[hre.network.name].proxy =proxy
  config[hre.network.name].admin =proxyAdmin
  config[hre.network.name].Six2Hero =implementation

  storage.writeProxyConfig(config)
  console.log(await upgrades.erc1967.getImplementationAddress(s2h.address), ' getImplementationAddress')
  console.log(await upgrades.erc1967.getAdminAddress(s2h.address), ' getAdminAddress')
  // Upgrading
  // const Six2Hero = await ethers.getContractFactory('Six2Hero')
  // const upgraded = await upgrades.upgradeProxy(s2h.address, Six2Hero)
}
export default func
func.id = 'Six2Hero'
func.tags = ['Six2Hero']
