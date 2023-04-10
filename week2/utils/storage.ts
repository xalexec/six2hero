import { writeFile, readFile } from 'fs/promises'

class Storage {
  proxyConfig: string
  constructor(path = 'proxy-config.json') {
    this.proxyConfig = path
  }

  async readProxyConfig():Promise<any>  {
    const data = await readFile(this.proxyConfig)
    return JSON.parse(data.toString())
  }

  async writeProxyConfig(data: any) {
    console.log(JSON.stringify(data, null, 2))
    await writeFile(this.proxyConfig, JSON.stringify(data, null, 2))
  }
}

export default new Storage()
