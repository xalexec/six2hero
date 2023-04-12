import {Wallet, utils} from "ethers"
import {MerkleTree} from 'merkletreejs'

function generatMerkTree() {
  const tokens = [
    {
      address: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
      amount: 10,
      price: utils.parseUnits('0.05', 18),
    }, {
      address: "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
      amount: 1,
      price: utils.parseUnits('0.05', 18),
    }, {
      address: "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
      amount: 1,
      price: utils.parseUnits('0.05', 18),
    }, {
      address: "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
      amount: 1,
      price: utils.parseUnits('0.08', 18),
    }
  ]
  // leaf, merkletree, proof
  const leaf = tokens.map(x => utils.solidityKeccak256([
    "address", "uint256", "uint256"
  ], [x.address, x.amount, x.price]))
  const merkletree = new MerkleTree(leaf, utils.keccak256, {sortPairs: true})
  const proof = {}
  for (let index = 0; index < tokens.length; index++) {
    const token = tokens[index];
    const tree = leaf[index];
    proof[token.address] = merkletree.getHexProof(tree)
  }
  const root = merkletree.getHexRoot()
  console.log({leaf, merkletree: merkletree.toString(), proof, root})
}
async function generatSign() {
  const wallet = new Wallet('0xbf8ddfcce149ad403b535ea05bf0e1b17a6e717cb300efaaa214f72c572979d1')
  const address = await wallet.getAddress()
  const message = utils.solidityKeccak256([
    "address", "uint256", "uint256"
  ], [
    '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4', 10,
    utils.parseUnits('0.05', 18)
  ])
  const signature = await wallet.signMessage(utils.arrayify(message))
  const {r, s, v} = utils.splitSignature(signature)
  console.log({
    r,
    s,
    v,
    address,
    message,
    signature
  })
}
generatMerkTree()
generatSign()
