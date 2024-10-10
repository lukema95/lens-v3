import { expect } from 'chai';
import { Contract, Wallet } from 'zksync-ethers';
import { getWallet, deployContract, LOCAL_RICH_WALLETS } from '../deploy/utils';
import * as ethers from 'ethers';

describe('Account', function () {
  let accountContract: Contract;
  let accessControlContract: Contract;
  let feedContract: Contract;
  let ownerWallet: Wallet;
  let managerWallet: Wallet;

  before(async function () {
    ownerWallet = getWallet(LOCAL_RICH_WALLETS[0].privateKey);
    managerWallet = getWallet(LOCAL_RICH_WALLETS[1].privateKey);

    accountContract = await deployContract(
      'contracts/primitives/account/Account.sol:Account',
      [await ownerWallet.getAddress(), 'someMetadata', [await managerWallet.getAddress()]],
      { wallet: ownerWallet, silent: true }
    );

    accessControlContract = await deployContract(
      'OwnerOnlyAccessControl',
      [await ownerWallet.getAddress()],
      { wallet: ownerWallet, silent: true }
    );

    feedContract = await deployContract(
      'Feed',
      ['feedMetadata', await accessControlContract.getAddress()],
      { wallet: ownerWallet, silent: true }
    );
  });

  it('Should make a post from Account (via owner tx)', async function () {
    console.log(`Account contract address: ${await accountContract.getAddress()}`);

    const postTx = (await feedContract.createPost.populateTransaction({
      author: await accountContract.getAddress(),
      source: '0x0000000000000000000000000000000000000000',
      contentURI: 'Post from SmartAccount (by owner)',
      quotedPostId: 0,
      parentPostId: 0,
      rules: [],
      feedRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      changeRulesQuotePostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      changeRulesParentPostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      quotesPostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      parentsPostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      extraData: [],
    })) as ethers.ContractTransaction;

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

    const postTx = (await feedContract.createPost.populateTransaction({
      author: await accountContract.getAddress(),
      source: '0x0000000000000000000000000000000000000000',
      contentURI: 'Post from SmartAccount (by AccountManager)',
      quotedPostId: 0,
      parentPostId: 0,
      rules: [],
      feedRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      changeRulesQuotePostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      changeRulesParentPostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      quotesPostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      parentsPostRulesData: {
        dataForRequiredRules: [],
        dataForAnyOfRules: [],
      },
      extraData: [],
    })) as ethers.ContractTransaction;

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
});
