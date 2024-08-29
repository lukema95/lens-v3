import * as hre from "hardhat";
import { getWallet } from "./utils";
import { ethers } from "ethers";

// Address of the contract to interact with
const CONTRACT_ADDRESS = "0x72e44ad874cDA3583513915FA27042cD754710a7";
if (!CONTRACT_ADDRESS)
  throw "⛔️ Provide address of the contract to interact with!";

// An example of a script to interact with the contract
export default async function () {
  console.log(`Running script to interact with contract ${CONTRACT_ADDRESS}`);

  // Load compiled contract info
  const contractArtifact = await hre.artifacts.readArtifact("UsernameFactory");

  // Initialize contract instance for interaction
  const contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    contractArtifact.abi,
    getWallet() // Interact with the contract on behalf of this wallet
  );

  // Run contract write function
  const transaction = await contract.deploy__Immutable_NoRules(
    "vic",
    ethers.getAddress("0xF0d751e78325c4596CD585178a1604b34a3263cd")
  );
  console.log(
    `Transaction hash of deploying new Username Primitive: ${transaction.hash}`
  );

  // Wait until transaction is processed
  await transaction.wait();
}
