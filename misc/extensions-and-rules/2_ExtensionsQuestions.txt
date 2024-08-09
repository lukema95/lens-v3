The goal of this exercise is to show several different approaches to Primitives Extensions architecture.

The sample is based on Community Primitive.

The goal is to have 2 extensions & 1 rule, simultaneously.

One Rule:

- Pay 1 ETH to join the community

Two Extensions:

- Tokenize membership as ERC-721 (example: Burn should make the member leave a community)
- Admin Extension:
  - Admins can add members forcefully and for free (overrides the Pay 1 ETH rule, overrides account == msg.sender)
  - Admins can remove a member forcefully (overrides account == msg.sender check)
