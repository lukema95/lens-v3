import * as hre from 'hardhat';
import {
  getWallet,
  parseLensContractDeployedEventsFromReceipt,
  getAddressFromEvents,
  verifyPrimitive,
} from './utils';
import { ethers, ZeroAddress } from 'ethers';

const metadataURI = 'https://ipfs.io/ipfs/QmZ';

const emptySourceStamp = {
  source: ZeroAddress,
  nonce: 0,
  deadline: 0,
  signature: '0x',
};

interface AppInitialProperties {
  graph: string;
  feeds: string[];
  username: string;
  groups: string[];
  defaultFeed: string;
  signers: string[];
  paymaster: string;
  treasury: string;
}

export default async function () {
  await deployPrimitives('0x1812224a23133A52929368A2F16aeA7FED64e384');
  await deployAccessControl('0xEFc75361dB437bD18E04192Cf90A952F3f425Abb');
}

export async function deployPrimitives(lensFactoryAddress: string) {
  console.log(`Running script to interact with LensFactory at ${lensFactoryAddress}`);

  // Load compiled contract info
  const lensFactoryArtifact = await hre.artifacts.readArtifact('LensFactory');

  // Initialize contract instance for interaction
  const lensFactory = new ethers.Contract(
    lensFactoryAddress,
    lensFactoryArtifact.abi,
    getWallet() // Interact with the contract on behalf of this wallet
  );

  const account = await deployAccount(lensFactory);
  const feed = await deployFeed(lensFactory);
  const group = await deployGroup(lensFactory);
  const graph = await deployGraph(lensFactory);
  const username = await deployUsername(lensFactory);

  const initialProperties: AppInitialProperties = {
    graph,
    feeds: [feed],
    username,
    groups: [group],
    defaultFeed: feed,
    signers: [],
    paymaster: ZeroAddress,
    treasury: ZeroAddress,
  };
  const app = await deployApp(lensFactory, initialProperties);
}

async function deployAccount(lensFactory: ethers.Contract): Promise<string> {
  const transaction = await lensFactory.deployAccount(
    metadataURI,
    getWallet().address,
    [],
    [],
    emptySourceStamp
  );

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const accountAddress = getAddressFromEvents(events, 'account');

  await verifyPrimitive('Account', accountAddress, [
    getWallet().address,
    metadataURI,
    [],
    [],
    emptySourceStamp,
  ]);

  return accountAddress;
}

async function deployFeed(lensFactory: ethers.Contract): Promise<string> {
  const transaction = await lensFactory.deployFeed(metadataURI, getWallet().address, [], [], []);

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const feedAddress = getAddressFromEvents(events, 'feed');
  const accessControlAddress = getAddressFromEvents(events, 'access-control');

  await verifyPrimitive('Feed', feedAddress, [metadataURI, accessControlAddress]);

  return feedAddress;
}

async function deployGroup(lensFactory: ethers.Contract): Promise<string> {
  const transaction = await lensFactory.deployGroup(metadataURI, getWallet().address, [], [], []);

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const groupAddress = getAddressFromEvents(events, 'group');
  const accessControlAddress = getAddressFromEvents(events, 'access-control');

  await verifyPrimitive('Group', groupAddress, [metadataURI, accessControlAddress]);

  return groupAddress;
}

async function deployGraph(lensFactory: ethers.Contract): Promise<string> {
  const transaction = await lensFactory.deployGraph(metadataURI, getWallet().address, [], [], []);

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const graphAddress = getAddressFromEvents(events, 'graph');
  const accessControlAddress = getAddressFromEvents(events, 'access-control');

  await verifyPrimitive('Graph', graphAddress, [metadataURI, accessControlAddress]);

  return graphAddress;
}

async function deployUsername(lensFactory: ethers.Contract): Promise<string> {
  const namespace = 'lens';
  const nftName = 'nftName';
  const nftSymbol = 'nftSymbol';

  const transaction = await lensFactory.deployUsername(
    namespace,
    metadataURI,
    getWallet().address,
    [],
    [],
    [],
    nftName,
    nftSymbol
  );

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const usernameAddress = getAddressFromEvents(events, 'username');
  const accessControlAddress = getAddressFromEvents(events, 'access-control');
  const lensUsernameTokenURIProviderAddress = getAddressFromEvents(
    events,
    'username-token-uri-provider'
  );

  await verifyPrimitive('Username', usernameAddress, [
    namespace,
    metadataURI,
    accessControlAddress,
    nftName,
    nftSymbol,
    lensUsernameTokenURIProviderAddress,
  ]);

  return usernameAddress;
}

async function deployApp(
  lensFactory: ethers.Contract,
  initialProperties: AppInitialProperties
): Promise<string> {
  const transaction = await lensFactory.deployApp(
    metadataURI,
    false,
    getWallet().address,
    [],
    initialProperties,
    []
  );

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const appAddress = getAddressFromEvents(events, 'app');
  const accessControlAddress = getAddressFromEvents(events, 'access-control');

  await verifyPrimitive('App', appAddress, [metadataURI, accessControlAddress]);

  return appAddress;
}

export async function deployAccessControl(accessControlFactoryAddress: string) {
  const accessControlFactoryArtifact = await hre.artifacts.readArtifact('AccessControlFactory');

  const accessControlFactory = new ethers.Contract(
    accessControlFactoryAddress,
    accessControlFactoryArtifact.abi,
    getWallet()
  );

  const transaction = await accessControlFactory.deployOwnerAdminOnlyAccessControl(
    getWallet().address
  );

  const txReceipt = (await transaction.wait()) as ethers.TransactionReceipt;
  const events = parseLensContractDeployedEventsFromReceipt(txReceipt);
  const accessControlAddress = getAddressFromEvents(events, 'access-control');

  await verifyPrimitive('OwnerAdminOnlyAccessControl', accessControlAddress, [getWallet().address]);

  return accessControlAddress;
}
