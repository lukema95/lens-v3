import deployFactories from './deployFactories';
import { deployPrimitives, deployAccessControl } from './deployAux';
import { deployRules } from './deployRules';

export default async function deploy() {
  const { lensFactory, accessControlFactory } = await deployFactories();
  await deployPrimitives(lensFactory);
  await deployAccessControl(accessControlFactory);
  await deployRules();
}
