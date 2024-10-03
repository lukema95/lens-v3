import { deployContract } from './utils';

export default async function () {
  // username factory
  const usernameFactory_artifactName = 'UsernameFactory';
  const usernameFactory_args: any[] = [];

  const usernameFactory = await deployContract(usernameFactory_artifactName, usernameFactory_args, {
    noVerify: false,
  });

  console.log(`\n✔ UsernameFactory deployed at ${await usernameFactory.getAddress()}`);

  // graph factory
  const graphFactory_artifactName = 'GraphFactory';
  const graphFactory_args: any[] = [];

  const graphFactory = await deployContract(graphFactory_artifactName, graphFactory_args, {
    noVerify: false,
  });

  console.log(`\n✔ GraphFactory deployed at ${await graphFactory.getAddress()}`);

  // feed factory
  const feedFactory_artifactName = 'FeedFactory';
  const feedFactory_args: any[] = [];

  const feedFactory = await deployContract(feedFactory_artifactName, feedFactory_args, {
    noVerify: false,
  });

  console.log(`\n✔ FeedFactory deployed at ${await feedFactory.getAddress()}`);

  // community factory
  const communityFactory_artifactName = 'CommunityFactory';
  const communityFactory_args: any[] = [];

  const communityFactory = await deployContract(
    communityFactory_artifactName,
    communityFactory_args,
    {
      noVerify: false,
    }
  );

  console.log(`\n✔ CommunityFactory deployed at ${await communityFactory.getAddress()}`);

  // app factory
  const appFactory_artifactName = 'AppFactory';
  const appFactory_args: any[] = [];

  const appFactory = await deployContract(appFactory_artifactName, appFactory_args, {
    noVerify: false,
  });

  console.log(`\n✔ AppFactory deployed at ${await appFactory.getAddress()}`);

  // lens factory
  const lensFactory_artifactName = 'LensFactory';
  const lensFactory_args = [
    await appFactory.getAddress(),
    await communityFactory.getAddress(),
    await feedFactory.getAddress(),
    await graphFactory.getAddress(),
    await usernameFactory.getAddress(),
  ];

  const lensFactory = await deployContract(lensFactory_artifactName, lensFactory_args, {
    noVerify: false,
  });

  console.log(`\n✔ LensFactory deployed at ${await lensFactory.getAddress()}`);

  // TODO: Make this to be written into a file
  console.log('\n\n--- Indexer file ---\n\n');
  console.log('# CONTRACTS');
  console.log('GRAPH_FACTORY=', await graphFactory.getAddress());
  console.log('GLOBAL_GRAPH=', '0x0000000000000000000000000000000000000000'); // TODO
  console.log('');
  console.log('ACCOUNT_FACTORY=', '0x0000000000000000000000000000000000000000'); // TODO
  console.log('');
  console.log('APP_FACTORY=', await appFactory.getAddress());
  console.log('');
  console.log('USERNAME_FACTORY=', await usernameFactory.getAddress());
  console.log('');
  console.log('FEED_FACTORY=', await feedFactory.getAddress());
  console.log('GLOBAL_FEED=', '0x0000000000000000000000000000000000000000'); // TODO
  console.log('');
  console.log('LENS_FACTORY=', await lensFactory.getAddress());
  console.log('');
  console.log('COMMUNITY_FACTORY=', await communityFactory.getAddress());
}
