/*
    1. Core Primitive implementation is in "internal" functions (which are marked as public, but not added as facets)
        a) this doesn't include ANY checks or rules or anything
    2. Public facing functions (external) are very simple wrappers as:
        a) _doCoreStuff() then doRulesCheck()
    3. The basic ownership rule (msg.sender == account) is the default rule:
        a) either in the RuleCombinator ON by default
        b) or just added by the deployer during the creation of primitive (can be disabled by some flag if not needed)
    4. If we want to build an extension, we override or create a new function that is calling the "internal" Primitive code and applies the new or existing rules
        a) checkAdmin() => _doCoreStuff() => doRulesCheck()
        b) checkAdmin() => _doCoreStuff() => doAdminRulesCheck() (new rules for the admin, set in the Admin Extension)
*/
