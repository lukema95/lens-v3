import { deployContract } from "./utils";

import { ethers } from "ethers";

// An example of a basic deploy script
// It will deploy a Greeter contract to selected network
// as well as verify it on Block Explorer if possible for the network
export default async function () {
  const contractArtifactName = "UsernameFactory";

  const constructorArguments = [
    ethers.getAddress("0xF0d751e78325c4596CD585178a1604b34a3263cd"),
  ];

  await deployContract(contractArtifactName, constructorArguments, {
    noVerify: false,
  });

  // await deployContract("PermissionlessAccessControl", []);
}
