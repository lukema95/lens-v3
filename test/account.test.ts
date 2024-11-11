import { expect } from 'chai';
import * as hre from 'hardhat';
import { Contract, Wallet } from 'zksync-ethers';
import { ZeroAddress } from 'ethers';
import {
  getWallet,
  deployContract,
  LOCAL_RICH_WALLETS,
  parseLensContractDeployedEventsFromReceipt,
  getAddressFromEvents,
} from '../deploy/utils';
import { deployUsername } from '../deploy/deployAux';
import * as ethers from 'ethers';

describe('Account', function () {
  let accountContract: Contract;
  let accountFactoryContract: Contract;
  let feedFactoryContract: Contract;
  let feedContract: Contract;
  let usernameContract: Contract;
  let lensFactory: Contract;
  let ownerWallet: Wallet;
  let managerWallet: Wallet;
  let usernameAccountOwnerWallet: Wallet;
  let usernameFactoryContract: Contract;
  let username: string;

  const metadataURI = 'https://ipfs.io/ipfs/QmZ';

  const emptySourceStamp = {
    source: ZeroAddress,
    nonce: 0,
    deadline: 0,
    signature: '0x',
  };

  before(async function () {
    ownerWallet = getWallet(LOCAL_RICH_WALLETS[0].privateKey);
    managerWallet = getWallet(LOCAL_RICH_WALLETS[1].privateKey);
    usernameAccountOwnerWallet = getWallet(LOCAL_RICH_WALLETS[2].privateKey);

    accountFactoryContract = await deployContract(
      'contracts/factories/AccountFactory.sol:AccountFactory',
      [],
      {
        wallet: ownerWallet,
        silent: true,
        noVerify: true,
      }
    );

    feedFactoryContract = await deployContract(
      'contracts/factories/FeedFactory.sol:FeedFactory',
      [],
      {
        wallet: ownerWallet,
        silent: true,
        noVerify: true,
      }
    );

    usernameFactoryContract = await deployContract(
      'contracts/factories/UsernameFactory.sol:UsernameFactory',
      [],
      {
        wallet: ownerWallet,
        silent: true,
        noVerify: true,
      }
    );

    lensFactory = await deployContract(
      'LensFactory',
      [
        await accountFactoryContract.getAddress(),
        ethers.ZeroAddress, // App
        ethers.ZeroAddress, // Group
        await feedFactoryContract.getAddress(), // Feed
        ethers.ZeroAddress, // Graph
        await usernameFactoryContract.getAddress(),
      ],
      {
        wallet: ownerWallet,
        silent: true,
        noVerify: true,
      }
    );
    console.log(`LensFactory deployed: ${await lensFactory.getAddress()}`);

    username = await deployUsername(lensFactory, true);
    console.log(`Username deployed: ${username}`);

    const usernameArtifact = await hre.artifacts.readArtifact('Username');

    usernameContract = new ethers.Contract(
      username,
      usernameArtifact.abi,
      ownerWallet // Interact with the contract on behalf of this wallet
    );

    const transaction = await lensFactory.deployAccount(
      metadataURI,
      ownerWallet.address,
      [managerWallet.address],
      [
        {
          canExecuteTransactions: true,
          canTransferTokens: true,
          canTransferNative: true,
          canSetMetadataURI: true,
        },
      ],
      emptySourceStamp
    );

    const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
    const events = parseLensContractDeployedEventsFromReceipt(txReceipt);

    const accountArtifact = await hre.artifacts.readArtifact('Account');
    const accountAddress = getAddressFromEvents(events, 'account');

    accountContract = new ethers.Contract(
      accountAddress,
      accountArtifact.abi,
      ownerWallet // Interact with the contract on behalf of this wallet
    );

    const transaction2 = await lensFactory.deployFeed(metadataURI, ownerWallet.address, [], [], []);

    const txReceipt2 = (await transaction2.wait()) as ethers.TransactionReceipt;
    const events2 = parseLensContractDeployedEventsFromReceipt(txReceipt2);

    const feedArtifact = await hre.artifacts.readArtifact('Feed');
    const feedAddress = getAddressFromEvents(events2, 'feed');

    feedContract = new ethers.Contract(
      feedAddress,
      feedArtifact.abi,
      ownerWallet // Interact with the contract on behalf of this wallet
    );
  });

  it('Should make a post from Account (via owner tx)', async function () {
    console.log(`Account contract address: ${await accountContract.getAddress()}`);

    const postTx = (await feedContract.createPost.populateTransaction(
      {
        author: await accountContract.getAddress(),
        contentURI: 'Post from SmartAccount (by owner)',
        repostedPostId: 0,
        quotedPostId: 0,
        repliedPostId: 0,
        rules: [],
        feedRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        repostedPostRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        quotedPostRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        repliedPostRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        extraData: [],
      },
      emptySourceStamp
    )) as ethers.ContractTransaction;

    const tx = await accountContract.executeTransaction(postTx.to, 0, postTx.data);
    const txReceipt = (await tx.wait()) as ethers.TransactionReceipt;

    console.log(`Transaction to Account sent from: ${txReceipt.from}`);

    const eventInterface = feedContract.interface;

    // Parse event logs
    const events = txReceipt.logs.map((log) => {
      try {
        // console.log('Log:', log);
        const decodedLog = eventInterface.decodeEventLog(
          'Lens_Feed_PostCreated',
          log.data,
          log.topics
        );
        return decodedLog[0];
      } catch (e) {
        return null;
      }
    });

    const postId = events.filter((e) => e !== null)[0];

    const post = await feedContract.getPost(postId);

    console.log(`Post: "${post.contentURI}" by ${post.author}`);
  });

  it('Should make a post from Account (via accountManager tx)', async function () {
    console.log(`Account contract address: ${await accountContract.getAddress()}`);

    const postTx = (await feedContract.createPost.populateTransaction(
      {
        author: await accountContract.getAddress(),
        contentURI: 'Post from SmartAccount (by AccountManager)',
        repostedPostId: 0,
        quotedPostId: 0,
        repliedPostId: 0,
        rules: [],
        feedRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        repostedPostRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        quotedPostRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        repliedPostRulesData: {
          dataForRequiredRules: [],
          dataForAnyOfRules: [],
        },
        extraData: [],
      },
      emptySourceStamp
    )) as ethers.ContractTransaction;

    const tx = await (accountContract.connect(managerWallet) as Contract).executeTransaction(
      postTx.to,
      0,
      postTx.data
    );
    const txReceipt = (await tx.wait()) as ethers.TransactionReceipt;

    console.log(`Transaction to Account sent from: ${txReceipt.from}`);

    const eventInterface = feedContract.interface;

    // Parse event logs
    const events = txReceipt.logs.map((log) => {
      try {
        // console.log('Log:', log);
        const decodedLog = eventInterface.decodeEventLog(
          'Lens_Feed_PostCreated',
          log.data,
          log.topics
        );
        return decodedLog[0];
      } catch (e) {
        return null;
      }
    });

    const postId = events.filter((e) => e !== null)[0];

    const post = await feedContract.getPost(postId);

    console.log(`Post: "${post.contentURI}" by ${post.author}`);
  });

  it('Should create an account with a username', async function () {
    const tx = await lensFactory.createAccountWithUsernameFree(
      'someMetadata',
      ownerWallet.address,
      [managerWallet.address],
      [
        {
          canExecuteTransactions: true,
          canTransferTokens: true,
          canTransferNative: true,
          canSetMetadataURI: true,
        },
      ],
      username,
      'testusername2',
      { dataForRequiredRules: [], dataForAnyOfRules: [] },
      { dataForRequiredRules: [], dataForAnyOfRules: [] },
      emptySourceStamp,
      emptySourceStamp,
      emptySourceStamp
    );

    const txReceipt = (await tx.wait()) as ethers.TransactionReceipt;

    const eventInterface = accountFactoryContract.interface;

    // Parse event logs
    const events = txReceipt.logs.map((log) => {
      try {
        // console.log('Log:', log);
        const decodedLog = eventInterface.decodeEventLog(
          'Lens_AccountFactory_Deployment',
          log.data,
          log.topics
        );
        return decodedLog[0];
      } catch (e) {
        return null;
      }
    });

    const accountAddress = events.filter((e) => e !== null)[0];

    console.log(`Account with username created at: ${accountAddress}`);

    const accountOf = await usernameContract.accountOf('testusername');
    console.log(`Account of 'testusername': ${accountOf}`);

    const usernameOf = await usernameContract.usernameOf(accountAddress);
    console.log(`Username of ${accountAddress} account: ${usernameOf}`);
  });
});
