// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessControl} from 'src/primitives/access-control/IAccessControl.sol';

contract App {
    IAccessControl _accessControl; // Owner, admins, moderators, permissions.
    string _metadataURI; // Name, description, logo, other attribiutes like category/topic, etc.
    address _treasury; // Can also be defined as a permission in the AC... and allow multiple revenue recipients!

    // Option 1:
    // Use extraData with key/value pairs to store primitives (bad to enumerate)

    // Option 2:
    // Use arrays like address[] graphs - but then you don't know which graph is which (you just know the app uses them)

    /**
     * AC, metadata and treasury are enough fields for now.
     * Let's even forget about if we will put primitives here as a way to "flag that they are being used by" the app.
     *
     * And let's focus on the most important thing: how primitives will give revenue to Apps?
     * Which also answers a more general important question: how primitives will know about Apps or have reference to Apps?
     */

    /*
        How primitives will give revenue to Apps?
        -----------------------------------------

        1. What do we mean by "give revenue to an App"?
           What do we want from "the revenue"?
           How do we want it to work?
           (Describe the use case as an example)

            Example #1:
                To write into an App's Graph or Feed, you need to pay a fee. Like a subscription for usage rights or
                even every time you write to it.

            Example #2:
                There is a shared Feed, let's say all apps can write to it.                
                But when you do a paid action through a publication (collect, mint, tip, etc.) there is a revenue share
                that goes to the app where the action is occurring, and another share that goes to the app that where
                the content was originally published.

                Example:
                1) AppA was used to create a post with a paid action (Collect).
                2) AppB was used to Collect and pay for this action
                3) Referral % is taken from the payment:
                    a) part goes to AppA
                    b) part goes to AppB
            
            Example #3:
                There is a Graph that is shared by some apps.
                There are users who use Orb and enable PayToFollow (Subscription) feature.
                Orb requires to pay a revenue % from the users.
                This looks like a User Follow rule.

        2. What should we know or have to do Example #2?
            - We need to know which App was used to post the content.
            - We need to know which App was used to do the paid action.
            - We need to know the revenue share % for each.
        
        3. Where is the paid action happening?
            Examples:
            - Collect: random contract? which somehow linked to the particular post, so the UIs can see there's a collect there?
            - 

    */

    /*
        Seems like having a "Source App" concept is important for most of the primitive actions.
        I.e. which App was used to create the content or do the action.

        Where this should be stored?

        How App can be determined? (that it's not faked)
   */
}
