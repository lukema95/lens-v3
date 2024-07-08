1. A primitive should have a single address (plus its ownership address, but the entry point should be only one)
2. We want to achieve:

- Rules that should apply
- Admins that can avoid CERTAIN rules (a particular case, is avoiding them all!)

Example for usernames.
Rule 0 (default rule): msg.sender == account
Rule 1: Length
Rule 2: Price
Rule 3: Charset

Case:
Admin can mint username without paying, but still forced to comply with charset and length

Is Admin minting this to himself? Or linking a username to a user?
(What if we don't have NFTs usernames and just simple username => account.)

---

We are in charge of two things with respect of primitives:

1. Set the interfaces.
2. Write the implementation of those primitive interfaces that will allow "one-click" contract infra from the developer portal.

Then, for everyone that do not need the "one-click" approach, everyone that is OK with writing contracts, we already provoided the interfaces (1.)
so they can just write code. Same way as in V1 and V2 we just provided interfaces and they needed to write contracts from scratch.

Here we are just providing a default implementation that allows "Lens contracts as a Service".

So, be careful with the interfaces :)

---

QUESTION!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Should this "CORE" primitive codes be... Libraries?
Then can be imported by guys that write their own contracts and they don't need to override functions, just use them.
