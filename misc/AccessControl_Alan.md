Some definitions:

Everything you want to give permission to is what we call a "Resource".

Resources are identified by a "Resource ID".

A Resource lives at a certain contract address, what we call "Resource Location".

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
