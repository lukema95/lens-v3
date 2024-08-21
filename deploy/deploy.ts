import { deployContract } from "./utils";

import { ethers } from "ethers";

export default async function () {
  // access control (permissionless)
  const acessControl_artifactName = "PermissionlessAccessControl";
  const acessControl_args: any[] = [];

  const acessControl = await deployContract(
    acessControl_artifactName,
    acessControl_args,
    {
      noVerify: false,
    }
  );

  const acessControl_address = await acessControl.getAddress();

  console.log(
    `\n✔ PermissionlessAccessControl deployed at ${acessControl_address}`
  );

  // username factory
  const usernameFactory_artifactName = "UsernameFactory";
  const usernameFactory_args = [acessControl_address];

  const usernameFactory = await deployContract(
    usernameFactory_artifactName,
    usernameFactory_args,
    {
      noVerify: false,
    }
  );

  console.log(
    `\n✔ UsernameFactory deployed at ${await usernameFactory.getAddress()}`
  );

  // graph factory
  const graphFactory_artifactName = "GraphFactory";
  const graphFactory_args = [acessControl_address];

  const graphFactory = await deployContract(
    graphFactory_artifactName,
    graphFactory_args,
    {
      noVerify: false,
    }
  );

  console.log(
    `\n✔ GraphFactory deployed at ${await graphFactory.getAddress()}`
  );

  // feed factory
  const feedFactory_artifactName = "FeedFactory";
  const feedFactory_args = [acessControl_address];

  const feedFactory = await deployContract(
    feedFactory_artifactName,
    feedFactory_args,
    {
      noVerify: false,
    }
  );

  console.log(`\n✔ FeedFactory deployed at ${await feedFactory.getAddress()}`);

  // community factory
  const communityFactory_artifactName = "CommunityFactory";
  const communityFactory_args = [acessControl_address];

  const communityFactory = await deployContract(
    communityFactory_artifactName,
    communityFactory_args,
    {
      noVerify: false,
    }
  );

  console.log(
    `\n✔ CommunityFactory deployed at ${await communityFactory.getAddress()}`
  );

  // app factory
  const appFactory_artifactName = "AppFactory";
  const appFactory_args = [acessControl_address];

  const appFactory = await deployContract(
    appFactory_artifactName,
    appFactory_args,
    {
      noVerify: false,
    }
  );

  console.log(`\n✔ AppFactory deployed at ${await appFactory.getAddress()}`);
}
