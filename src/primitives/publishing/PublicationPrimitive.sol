// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PublicationPrimitive {
    // struct UnopinionatedButAmorfousPost {
    //     bytes data;
    //     uint256 timestamp;
    // }

    // struct Post {
    //     address[] authors;
    //     string contentURI;
    //     bytes extraData; // Think of a good name
    //     uint256 pointedPostId;
    //     uint256 timestamp;
    // }

    struct Post {
        address author;
        string contentURI;
        bytes extraData; // Think of a good name
        uint256 pointedPostId;
        uint256 timestamp;
    }

    Post[] _posts;

    // Then, the contentURI will have some standrad like
    //
    /**
     * ```Yes, the other day I've seen this idea
     *    <quotedPostIds[0]>
     *    and it related me to this other thought that Vitalik said
     *    <quotedPostIds[2]>
     *    which is also similar to what I wrote back in 2019
`    *    <quotedPostIds[1]>```
     *
     */
    // contentURI = {
    //     "content": "whatever"
    // }
    // metadataURI = {
    //     "metadata": "whatever"
    // }

    // contentURI = {
    //     "content": "whatever",
    //     "metadata": "whatever",
    //     "otherShit": "whatever"
    // }
    // metadataURI = {
    //     "content": "whatever",
    //     "metadata": "whatever",
    //     "otherShit": "whatever"
    // }

    /**
      Rendering of posts on the UIs (some examples):
      ----------------------------------------------

      Classic-Post: {
        contentURI: Required,
        metadataURI: Optional,
        quotedPostIds: No,
        parentPostIds: No,
      },
      Classic-Quote: {
        contentURI: Required (but no <quotedPostIds> tags present - so it displays a quote below the post, not in-place)
        metadataURI: Optional,
        quotedPostIds: Single value,
        parentPostIds: No,
      },
      Article: {
        contentURI: Required,
        metadataURI: Optional,
        quotedPostIds: One or more,
        parentPostIds: No,
      },
      Re-Post (aka Mirror): {
        contentURI: No,
        metadataURI: Optional,
        quotedPostIds: Single value,
        parentPostIds: No,
      },
      Classic-Reply/Comment: {
        contentURI: Required,
        metadataURI: Optional,
        quotedPostIds: No,
        parentPostIds: Single value,
      },
      Thread-Merger-Reply/Comment: {
        contentURI: Optional,
        metadataURI: Optional,
        quotedPostIds: Optional,
        parentPostIds: Multiple values,
      },
     */

    /*
        FeedPrimitive = PublicationSystem + FollowGraph

        ?

        [[[[[[[[[[[GOOD QUESTION FOR TOMORROW::::]]]]]]]]]]]

        How to link PublicationSystem to a FollowGraph?
        1. Should the PublicationSystem point to a FollowGraph(s)?
        2. Or should the FollowGraph point to a PublicationSystem(s)?
        3. Or should they both be pointing (connected) to each other?
        4. Or should there be a separate contract (Feeds?) that connects them?
        --
        5. Or every post should link to a FollowGraph(s)?

        Another thing:

        1. What about the multiple authors? >> extradata
        2. What about the apps (like source/origin)? >> extradata
    */

    /*

    Use-cases/Examples:
    -------------------

    Yogi wants to build Twitter:
    - We want to have accounts
    - We want usernames
    - We want a FollowGraph so these accounts can connect
    - We want a place to publish posts (PublicationSystem)

    Sasi sees Yogi is succesful and wants to build Instagram:
    - He can let the same accounts be used
    - He could use the same usernames as Twitter, or give the user the option to choose a different one
      * On twitter you can be 0xWagmi, but on Instagram you want to be RedCherries
      * As a consequence, he creates new app-level usernames space

    - He can use the same FollowGraph as Twitter, or create a new one
      * Sasi realizes that most of guys want to follow tech&politics content on Twitter, but want to follow friends&family on Instagram
      * As a consequence, he creates a new FollowGraph
      * Instagram UI can leverage the Twitter FollowGraph to suggest people to follow, because they still share the same accounts

    - Josh built StreamMe
      * It has multiple graphs - ordinary followers and paid subscribers
      * Some posts are shown to followers publically
      * Some posts are shown to paid subscribers only (content is encoded)

      * An NordVPN comes and wants to make a Promo across Streamers accounts with following conditions:
        - A Streamer must have >1M public followers
        - A Streamer must have >10.000 paid subscribers (so make sure its not bots)
        - If the condition is met - the Streamer can Mirror the NordVPN on your feed and get $100 (mirror can be done only once)

  NordVPN PromoContract:
    - Where do we find the PublicationSystem contract & FollowGraphs contracts so Streamers cannot cheat with their own custom contracts?
      * When you create a PromoContract - you can select the PublicationSystem and an array of FollowGraphs contracts for it
    - Where to get the amount of followers of Account X?
    - Where to get the amount of paid subscribers of Account X?
    - How to verify that the Account X posted and it is a Mirror?

  Approach 1: ReferenceModule - money is paid automatically during Posting
  Approach 2: First you post an ad, then you submit a proof-of-posting & proof-of-following to PromoContract and get paid













   */

    function post(
        uint256 postId, // for edits, but we should think if makes sense to do an editPost function instead
        string memory contentURI, // can be just called `uri`, or `metadataURI` or `contentMetadataURI` lol
        string memory metadataURI,
        uint256[] quotedPostIds,
        uint256[] parentPostIds,
        bytes[] memory extraDatas
    ) external returns (uint256) {
        if (pointedPostId > _posts.length) {
            revert("Post does not exist");
        }
        if (
            bytes(contentURI).length == 0 &&
            pointedPostId == 0 &&
            extraData.length == 0
        ) {
            revert(
                "Post must either have content, point to another post or have extra data"
            );
        }
        _posts.push(
            Post({
                author: msg.sender,
                contentURI: contentURI,
                extraData: extraData,
                pointedPostId: pointedPostId,
                timestamp: block.timestamp
            })
        );
        return _posts.length;
    }

    // One big issue with Lens V1 and V2 design:
    // 1- Modules weren't swappable. So if you chose to put degrees of separation, you could not get rid of them after.
    //    This is suuuuper rigid and annoying/bad UX.
    // 2- Modules are not automatically inhertied by replies. So I depend on the guy that is replying to my post to
    //    honour the same settings that I have (UIs can force this, but people can go to contracts anyways).

    /**
     * What is the difference between:
     *
     * Content: "Yes, you are correct!"
     * Pointer: struct { postId: 1, chainId: 1, pubSystem: 0x1234 }
     *
     * And:
     *
     * Content: "Yes, you are correct!
     *           <link: evm://1/0x1234/1>" <-- This could be an https link, but this a standard way we can defined to link to evm things directly so we don't
     *                                         have to rely on external services (like the UI that that product is using, or whatever).
     * (No pointer data structure)
     */

    /**
     * 1. Is possible to point to a post outside of the current PublicationSystem?
     * 2. If yes - do we verify if the pointed post exists?
     * 3. If yes - how???
     * 4. If yes - how do we handle the pointing? Should we have a global postId that has a chainId & pubSystem address in it?
     *
     * Possible answer is - we don't verify it and upper layers (UI's, indexers, API, etc) do that :-D
     * But then we cannot do some contracts shit with it:
     *  - Like what?
     *     * Like verified paying for mirroring?
     *     * Like verified things in Reference modules?
     *     * Like blocking someone from commenting?
     *     * Like verified referrals?
     */

    /**
     * How to differentiate between different types of posts?
     * -----------------------------------------------
     *
     * Post does not have a pointed Post => Original/Root
     * Post has a pointer, but does not have content => Mirror/Repost
     * Post has a pointed Post and content => Comment/Reply/Quote
     *
     * How to differentiate betweet Comment and Quote? Maybe just something in the contentURI?
     * The issue is that it won't be queried on-chain for modules.
     *
     * So maybe we need something passed by the client to differentiate between them. => extraData
     */
}

/*
    1. I want to make a post that announces my new NFT Game.
       And I want to reward anyone who writes about this game and gives a link to the original announcement (not in the comments, but on their "timeline").
       Can be different pubSystem (but it has unified interface with IPubSystem and maybe it's registered or smth).
       I also want to pay different amount based on the amount of followers that person has (like $0.01 per 1 follower).
    How do I do that?

    It can be a separate contract that should check for:
     - The PubSystem is whitelisted by the OG poster (so he can reward only InstaLens, Orb, Tape, and GlobalLens)
     - The post exists on that PubSystem (this means we should be able to verify EXISTENCE on-chain)
     - The post links to NFT game (this means we should be able to verify LINKING on-chain)
     - The post is not a comment (this means we should be able to verify TYPE on-chain)
     - Count the followers (where?? If there are several FollowGraphs???)
     - Payout the reward


*/

/*
---

You reply with an existing comment.

This is pushed at into the pointed-post-ID array.

So, the UI then shows "@vicnaum replied with an existing comment"

This in the UI is like a redirection to the original thread of comments

But also if you are in the original comment, you can see something like "see all places where this comment has been used"
and then you can discover other comment related threads.

--------------------------

Vitalik posts (post id = 1)

Victor replies to Vitalik (post id = 2), Josh replies to Vitalik (post id = 3). Victor and Josh comments make the same point.

Vitalik replies to Victor (post id = 4), Vitalik replies to Josh using the same comment he used for Victor (post id = 5, quote of post #4) <-- If this would literally still be post #4 but with an extra parent, would be interesting...

Now I want to comment on this last Vitalik thing. But, I want to comment on both, because they are the same thing. So I want to continue both threads. It would be nice if they are the same thread...

*/
