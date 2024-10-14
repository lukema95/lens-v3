# Access Control (Role Based implementation example)

Here first we describe a specific example Access Control implementation that we use on Lens Protocol by default, and afterwards we describe the generic interface (because one can write any implementation they want, as long as they follow the interface - it can be RoleBased, AddressBased, Permissionless, JustOwnerAdmin, etc).

## What is Access Control and why do we need it?

Access Control is a flexible permissions system, which basically says WHO can do WHAT.
We based our Lens Access Control implementation on Role-Based Access Control (RBAC) model, which is a widely used model.

## How does it work?

RoleBased Access Control record in Lens has three things that answer three simple questions:

- Who can do it? (RoleID)
- What can they do? (ResourceID)
- Can they do it? (AccessPermission)

Here is a more detailed examples of the three things:

1. RoleID: Owner, Admin, Moderator, CM, Relayer, RestrictedSigner, etc...
2. ResourceID (RID) - SET_METADATA, SET_RULES, DELETE_POSTS, etc...
3. AccessPermission: GRANTED / DENIED / UNDEFINED

## Example:

So if you want to grant MODERATOR role the ability to DELETE_POSTS on your app Feed, you would go to the Access Control that the Feed is using and set the following record:

```json
[
    {
        RoleID: MODERATOR,
        ResourceID: DELETE_POSTS,
        AccessPermission: GRANTED
    }
]
```

To grant 0xALICE a MODERATOR role, one just does `grantRole(0xALICE, MODERATOR)` - and Alice becomes a moderator and can delete posts on the app Feed.

## Scoping and location (Global vs Local)

Also our Access Control implementation supports Scoping, which means you can set things globally (e.g. for all of your feeds), but also you can set things locally (e.g. for a specific feed at 0xCOFFEE). This is useful if you want to use a single Access Control with Roles already set up, for a multiple primitives, and don't clone or create multiple Access Control instances.

We call this: **ResourceLocation**

### Scoping Example:

Our app has 3 feeds: Global Feed, Community Feed, Exclusive Club Feed.
We can use a single Access Control instance to control everything:

1. We define the roles we want: ADMIN, MODERATOR, CLUB_MEMBER
2. We set the scoped permissions for MODERATOR role:

```json
   Global_Scope: [{
        RoleID: MODERATOR,
        ResourceID: DELETE_POSTS,
        AccessPermission: GRANTED
   }],
   Exclusive_Club_Scope: [{
        RoleID: MODERATOR,
        ResourceID: DELETE_POSTS,
        AccessPermission: DENIED
   },
   {
        RoleID: VIP_MEMBER,
        ResourceID: DELETE_POSTS,
        AccessPermission: GRANTED
   }]
```

This means our MODERATORs can delete posts in the Global Feed and in the Community Feed, but it is specifically denied to do so in the Exclusive Club Feed, because the moderation is done by the VIP club members themselves (who are also only granted a SCOPED permission to DELETE_POSTS on the Exclusive Club Feed, but not granted on Global or Community feeds).

Why do we have Scoping? Because you can have a single set of ROLES in your Access Control, and you can see and change all the permissions in one place, in one contract.

## Roles assignment to addresses

_Okay, we have Roles, but how do we know who has which role?_

Our Access Control implementation supports `grantRole()` and `revokeRole()` functions.
This means you can grant a MODERATOR role to 0xB0B, and ADMIN role to 0xALICE, and so on.

So, you can create an ADMIN role, assign a set of permissions for it (DELETE_POSTS, TRANSFER_OWNERSHIP, etc)
and then grant this role to 0xALICE, 0xBOB, 0xCHARLIE, etc. - making them ADMINs.

Then do the same for MODERATOR role, granting it to a bunch of people etc.

This is what our RoleBased Access Control implementation does.

## Wildcards

It is not decided fully yet, but we think it will be useful to declare some standards for a wildcard, for example:
RoleID 0 means "Everyone", ResourceID 0 means "All", and Permission 0 means "Undefined".

With this, setting broad permissions like OWNER can be as simple as that:

```json
{
    RoleID: OWNER,
    ResourceID: 0,
    AccessPermission: GRANTED
}
```

This would mean that the OWNER can do anything.

## Generic Interface & Usage

After Access Control is set up, using it in the primitives is extremely simple:

```
hasAccess(address, scope/location, resourse): bool
```

So to check if 0xALICE can DELETE_POSTS on Exclusive_Club_Feed, you need to call:

```
deletePost() {
    require(hasAccess(0xALICE, Exclusive_Club_Feed, DELETE_POSTS));
    // delete the post
}
```

## Recap and the Generic Interface

1. Everything you want to give permission to is what we call a "Resource".

2. Resources are identified by a "Resource ID".

3. A Resource lives at a certain contract address, what we call "Resource Location".

---

The Access Control inteface defines a single function which only purpose is to answer YES/NO to the following question:

"Does this `account` has access to the `resourceId` at `resourceLocation` ?"

For example:

"Does `0xBEEF` has access to `SET_RULES` at `(Feed at) 0xC0FFEE` ?"

Which is basically asking...

"Can `0xBEEF` `set rules` on the primitive at `0xC0FFEE` ?"

The answer will be as simple as a boolean: `true` (YES) or `false` (NO).

---

This function is defined like this:

```
interface IAccessControl {

    function hasAccess(address account, address resourceLocation, uint256 resourceId) external view returns (bool);

}
```

And this is the only interface used by the contracts that depends on the Access Control, as the only thing they care
is to have this function to query access.

---

## P.S. Naming Options

Some people say that the naming might be confusing, so here is a little bit different naming proposal, which might not be an industry standard, but it might be more easy to understand:

- `RoleID` -> `Role` (OWNER, ADMIN, MODERATOR, etc)
- `ResourceID` -> `Permission` (CAN_DO_THIS, DELETE_POSTS, SET_RULES, etc)
- `AccessPermission` -> `Access` (GRANTED, DENIED, UNDEFINED)
- `ResourceLocation` -> `Location` or `Scope` (0xVIP_FEED, 0xGLOBAL_FEED, etc)

<!-- ------------------------------------  -->

Owner - Admin[] (Primitive AC)

---

Signers restricted will be baked in into the rule... with labels

<!-- Or we have Owner+Admin[]+Singers[] AC for the primitives that use restricted things? -->

---

Owner + Managers (Account AC)

---

Factory deployed Primitives will not allow to set random ACs

---

- `RoleID` -> `Role`
- `ResourceID` -> `Permission`
- `AccessPermission` -> `Access`
- `ResourceLocation` -> `ContractAddress`

<!-- ------------------------------------  -->
