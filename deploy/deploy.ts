import { deployContract, getWallet, verifyLensFactoryDeployedPrimitive } from './utils';

export default async function () {
  // username factory
  const usernameFactory_artifactName = 'UsernameFactory';
  const usernameFactory_args: any[] = [];

  const usernameFactory = await deployContract(usernameFactory_artifactName, usernameFactory_args);

  console.log(`\n✔ UsernameFactory deployed at ${await usernameFactory.getAddress()}`);

  // graph factory
  const graphFactory_artifactName = 'GraphFactory';
  const graphFactory_args: any[] = [];

  const graphFactory = await deployContract(graphFactory_artifactName, graphFactory_args);

  console.log(`\n✔ GraphFactory deployed at ${await graphFactory.getAddress()}`);

  // feed factory
  const feedFactory_artifactName = 'FeedFactory';
  const feedFactory_args: any[] = [];

  const feedFactory = await deployContract(feedFactory_artifactName, feedFactory_args);

  console.log(`\n✔ FeedFactory deployed at ${await feedFactory.getAddress()}`);

  // group factory
  const groupFactory_artifactName = 'GroupFactory';
  const groupFactory_args: any[] = [];

  const groupFactory = await deployContract(groupFactory_artifactName, groupFactory_args);

  console.log(`\n✔ GroupFactory deployed at ${await groupFactory.getAddress()}`);

  // account factory
  const accountFactory_artifactName = 'AccountFactory';
  const accountFactory_args: any[] = [];

  const accountFactory = await deployContract(accountFactory_artifactName, accountFactory_args);

  console.log(`\n✔ AccountFactory deployed at ${await accountFactory.getAddress()}`);

  // app factory
  const appFactory_artifactName = 'AppFactory';
  const appFactory_args: any[] = [];

  const appFactory = await deployContract(appFactory_artifactName, appFactory_args);

  console.log(`\n✔ AppFactory deployed at ${await appFactory.getAddress()}`);

  // lens factory
  const lensFactory_artifactName = 'LensFactory';
  const lensFactory_args = [
    await accountFactory.getAddress(),
    await appFactory.getAddress(),
    await groupFactory.getAddress(),
    await feedFactory.getAddress(),
    await graphFactory.getAddress(),
    await usernameFactory.getAddress(),
  ];

  const lensFactory = await deployContract(lensFactory_artifactName, lensFactory_args);

  console.log(`\n✔ LensFactory deployed at ${await lensFactory.getAddress()}`);

  // deploy global feed
  console.log('Deploying Global Feed...');
  const metadataURI = 'https://ipfs.io/ipfs/TezTUri';
  const ownerAddress = getWallet().address;
  const admins: string[] = [];
  const rules: any[] = [];
  const extraData: any[] = [];
  const feedDeploymentTx = await lensFactory.deployFeed(
    metadataURI,
    ownerAddress,
    admins,
    rules,
    extraData
  );
  const globalFeedAddress = await verifyLensFactoryDeployedPrimitive({
    tx: feedDeploymentTx,
    lensContractArtifactName: 'Feed',
    metadataURIConstructorParam: metadataURI,
  });

  // deploy global graph
  console.log('Deploying Global Graph...');
  const graphDeploymentTx = await lensFactory.deployGraph(
    metadataURI,
    ownerAddress,
    admins,
    rules,
    extraData
  );
  const globalGraphAddress = await verifyLensFactoryDeployedPrimitive({
    tx: graphDeploymentTx,
    lensContractArtifactName: 'Graph',
    metadataURIConstructorParam: metadataURI,
  });

  // TODO: Make this to be written into a file
  console.log('\n\n--- Indexer file ---\n\n');
  console.log('# CONTRACTS');
  console.log(`GRAPH_FACTORY="${await graphFactory.getAddress()}"`);
  console.log(`GLOBAL_GRAPH="${globalGraphAddress}"`);
  console.log('');
  console.log(`ACCOUNT_FACTORY="${await accountFactory.getAddress()}"`);
  console.log('');
  console.log(`APP_FACTORY="${await appFactory.getAddress()}"`);
  console.log('');
  console.log(`USERNAME_FACTORY="${await usernameFactory.getAddress()}"`);
  console.log('');
  console.log(`FEED_FACTORY="${await feedFactory.getAddress()}"`);
  console.log(`GLOBAL_FEED="${globalFeedAddress}"`);
  console.log('');
  console.log(`LENS_FACTORY="${await lensFactory.getAddress()}"`);
  console.log('');
  console.log(`GROUP_FACTORY="${await groupFactory.getAddress()}"`);
}
