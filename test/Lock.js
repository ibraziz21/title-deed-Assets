const {expect} = require('chai')
const {ethers} = require('ethers')
const { user } = require('pg/lib/defaults')

describe("Setting Approvers",function(){
  beforeEach(async function () {
    [Owner, Approver1, Approver2] = await hre.ethers.getSigners()
    const NFTContract = await hre.ethers.getContractFactory('titleNFT');
    dNFTs = await NFTContract.deploy()
  })
  it("Contract owner should be able to set approvers", async function(){
    await dNFTs.deployed()

    await dNFTs.setApprover(Approver1.address)
    expect((await dNFTs.approver(Approver1.address))).to.equal(true)

  
})
})
describe("Approvals and minting NFTs",function(){
  beforeEach(async function () {
    [Owner, Approver1, Approver2, user1] = await hre.ethers.getSigners()
    const NFTContract = await hre.ethers.getContractFactory('titleNFT');
    dNFTs = await NFTContract.deploy()
    await dNFTs.deployed()
    await dNFTs.setApprover(Approver1.address)
  })
  it("Users can be able to seek for NFT mint approval", async function(){
    await dNFTs.connect(user1).seekTokenizationApproval("Macchiaveli", "Mvita", 10)
    const structs = (await dNFTs.getDetails(1))
    expect(await structs.nftOwner).to.equal(user1.address)
})
it("Approver can grant approval and nft minted to user", async function () {
  await dNFTs.connect(user1).seekTokenizationApproval("Macchiaveli", "Mvita", 10)
  await dNFTs.connect(Approver1).approveAndMintNFT(1, true)

  expect(await dNFTs.ownerOf(1)).to.equal(user1.address)
})
})
