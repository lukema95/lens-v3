// Tokenization will happen in a collection/tokenizer contract

// This tokenizer contract will only allow to tokenize if you are following... and will allow you to set a token recipient

// Tokenizer ofc will allow you to burn if you hold the asset (but how to make this unfollow...)
// No burn, you need to unwrap and unfollow. Or burn, but after you unfollowed.
// But not burning with the follower set, because it cannot unfollow for you.

// Tokenizer should be queried to check ownership of tokens if they want to be used to follow with that token

// Tokenizer should be attached to the graph somehow (so there is only one tokenizer per graph)

// When you hold the token, but you are not the follower on it... how do you do make it unfollow?

contract TokenizationGraphModule {
    address _tokenizer;

    function initialize(bytes calldata data) external;

    function processFollow(
        address accountToFollow,
        bytes calldata data
    ) external {
        if (graph.isFollowing(msg.sender, ) 
    }

    // TODO: Should this exist? Maybe not, so it cannot prevent the unfollow...
    // Maybe the function should exist but not being called by `unfollow` but by the user in a separate tx later.
    // We could even do wrappers for this, given that all the accounts are smart contracts
    function processUnfollow(
        address accountToUnfollow,
        bytes calldata data
    ) external;
}

// Modules should be thought as inheritable, so storage should use "diamond pattern" and then you can compose any
// plugins into the module and deploy it.

contract MyJustDeployedOneClickModule is Tokenizable, SingleEdge, BlahBlah {

}

contract Tokenizable {

    // name storage slot will be `keccak256("eipblahblah.diamond.whatever.lens.tokenizable.name")`
}


/*

GRAPH (<<<< msg.sender)


TOKENIZER
A) Tokenize:
  1. Check if the msg.sender is following the given account
  2. Mint the token to recepient provided by msg.sender

B) 


USER (is msg.sender, and also is a smart account with DE)

1. User sets Tokenizer as DE in his smart account with OnlyModifyGraph permission


*/
