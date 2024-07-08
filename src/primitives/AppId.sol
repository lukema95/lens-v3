// TODO: Implement some kind of App ID registry!

struct App {
    uint256 id;
    string name;
    address owner;
    address[] signers; // or maybe better a mapping address=>bool
    address treasury;
}

/**
 *
 * Approach #1: We have a global AppRegistry which holds all the apps' information and emit all the events.
 * The App ID is just an incremental uint256.
 * This App ID is stored on many of the primitives operations, for example, when you create a post you pass the App ID
 * and you pass a signature of the post (supposed to be signed by a valid signer from the given App).
 * Then, if the primitive do not care about the App ID, it just ignores it. But pritmives that care can set a Global Rule
 * that queries the AppRegistry, checks the App ID is valid, exists, and verifies the signature.
 * Even when the primitive do not care about this verification, it makes sense to store the App ID, because it can be
 * useful for other primitives or actions. For example, a collect action can query the App ID, then get the treasury
 * for this App from the Registry, and send revenue streams there.
 *
 * Approach #2: Pretty much the same logic of storing without validating, and then validating when needed (by Rules or
 * other contracts and Primitives). The main difference is that instead of having an AppRegistry that holds all apps,
 * and an App ID as uint256, the proposal is having an something like an Application primitive with its own interface.
 * Then, the App and its ID becomes an address, and this address can be called folllowing the App interface to query
 * all the data that before was being queried in the AppRegistry.
 * App being a contract allows it to be a profile or to do things in the name of the app by executing stuff itself.
 */

/*
// json storage

 >> 1. pass extraData(name, value)
    2. store value at "name" somehow
    3. anyone can go to post and as for "name" to get the value (or get 0 or "" or smth if not set)

mapping(uint256 postId => mapping(bytes32 (name) => bytes? value))
*/

/*
Tasks:
        0. Implement Diamond Storage library that can be used in primitives
        1. Refactor all primitives to have Diamond Storage instead of normal one
        2. Add postExtraData shit and other extraDatas to other primitives where applicable
        3. Think about and implement Application Primitive if Approach #2 is taken
        4. Write simple deployment scripts (to test Diamond Proxy pattern) for all primitives
        5. Write all the events for every primitive
        6. Try to implement events via global EventSender contract
        7. Finish Graph, Community, Username primitives which, in theory, do not have open questions anymore
            a) Close most of the TODOs
            b) Polish code a bit so it makes sense
        8. Solve Feed primitive questions:
            a) Do we have types on-chain or not? For example Post only, vs Root, Mirror, Quote, Reply, etc    
            b) Single Post function or dedicated comment/quote/etc functions
            c) Solve the app id stuff
            d) Solve the potential multi-author stuff

*/
