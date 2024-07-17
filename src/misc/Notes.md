Profiles:

- Addresses are profiles
- We will create smart contracts for profiles, that are safe, and can transfer ownership and other desired features
- People can still use their EOAs as profiles, directly, at its own risk
- We can charge to create this contract profiles, if you don't go through us, we wont sponsor your gasless txs
- You still will pay for your username. Without username you will look odd, and/or apps wont allow you to login
- [You will be a first-class citizen at the protocol level always, but not at the app level]
- Profile guardian should be embed in the profile contract, opted-in at onboarding time, choosing cooldown time
- Social recovery should be implemented too, also opt-in at onboarding time
- Profile managers are also part of the profile contracts
- Profile contracts should use a Beacon proxy pattern with opt-in versioning. Meaning that the users should be notified
  about a new profile version, and they can choose to opt-in into upgrading to this new version, or stay in current one
- Profile contracts can be upgraded or implemented as DIDs later

---

Graph questions:

- We will have many graphs, potentially one per application.
- The issue is, one application could be controlling the follow action, to avoid a noisy graph.
  So they are basically curating it, not allowing bots to follow, or will only allow KYCed users to follow.
- So basically, if we let it fully open, people or other apps can always follow through the contracts, bypassing
  apps verification steps.
- So we thought of adding a write permission, so it requires a signature from some of the creators of the graph to
  perform the follow. But not for removing it (as the follower owns the edge on that graph)
- [Maybe even setting a Follow Module should be accepted by this application]
- Of course people can choose to have an open graph fully permissionless, with no write permissions required.
- The draback here is that the graph of course becomes gated. But because it is public, in theory anyone can still use
  it in read-only mode, and complemenet it with their own graph.

- Do we want to maintain the tokenization feature as we had in Lens V2?

- Follow to be a pre-compile OPCODE for the follow and assign a fixed gas price for it? So we can bulk follow and it is
  not so expensive.

---

==> Graph Modules (global to the module)
==> Follow Modules (particular to the foolowed node)
==> Switching Follow-Module can go through a Graph Module (to control which modules are supported on this graph)

==> Yes, we want tokenization. But ideally we should build it on-top, and don't spend time on it right now.
Maybe the tokenization contract can be set in the graph too, so it has the legitimacy of controlling the asstes.
Like a two-way dependency between the tokenization contract and the graph contract.

==> We should talk with zkSync about the pre-compile
The boostrap network idea is cool. Cloning a graph.

---

==> Ok with the addresses approach, but we should explore if there is something we could add to the EOA default code
so it has some good/safe properties by default, instead of just being an EOA.
