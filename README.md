# Using the scripts

## Setup

### 1. Setup your environment for working with your user number

At the beginning of the session, you will be issued a user number from 1 to 25. Run the following command:

```bash
source set-user <your-user-number>
```

For example, if your user number is 1:

```bash
source set-user 1
```

If you don't do this, most of the scripts won't work at all.

## Scripts

### `gen-hot`

Generates a new hot-key pair for your user number. **Overwrites existing key files if run more than once.**

### `authorize-hot`

Authorizes the generated hot-key for your user number to sign off on votes. Requires `gen-hot` to have been run.

### `update-gov-actions`

Fetches current active governance actions and writes them to `gov-actions.json`.

### `show-committee`

Shows the state of all active constitutional committee members.

### `show-env`

Shows the environment variables related to your user number.

### `show-membership`

Shows only the state of your user number's membership in the constitutional committee.

### `show-utxo`

Shows the utxo (balance) in your user number's payment address.

### `vote`

Casts a vote for a governance action. See [How to vote](#how-to-vote)

## How to vote

### 1. Run all necessary prerequisites

You must run `gen-hot` and `authorize-hot` before you can vote. Note there will be a delay after running `authorize-hot`
before you can vote. You can check by running `show-membership`. If the output says `MemberAuthorized`, you can vote.

### 2. Find out the Tx ID and Action Index of the governance action you want to vote for.

All governance actions are identified by:

1. The ID of the transaction in which they were proposed.
2. The index of the action within that transaction, starting from 0.

Run `update-gov-actions` to update the list of active governance actions in `gov-actions.json`.
Open this file, find the action you want to vote for and take note of the fields in the `actionId`
property (namely, `govActionIx` and `txId`).

### 3. Prepare the rationale for your vote.

After deciding how you want to vote, make a copy of `metadata-template.json` in one of two ways:

1. Create a new JSON file on your laptop and copy in the contents of `metadata-template.json`
2. Open https://jsoneditoronline.org/ and paste the contents of `metadata-template.json` into the left panel.

Ignoring everything inside `"@context"`, write up your rationale inside the empty double quotes for the `comment` field
under `body`. Note that you cannot add newlines to the text here.

Save the file:

1. If you created the file locally and are editing with a text editor, just save it.
2. If you used the only JSON editor, click "save" > "save to disk" and save it somewhere you can find it later (e.g. your desktop).

Add the file to IPFS either by:

1. By dragging it into the IPFS Desktop user interface.
2. using the ipfs CLI command `ipfs add <filename>`

Make note of the content ID (CID) of the file after it has been added.

Run the `vote` script as follows:

```bash
vote <txId from step 2> <govActionIx from step 2> <cid from step 3> <yes, no, or abstain>
```

For example, if the `txId` from step 2 is `270198c6d25e45a1f3ea19b0d6136b93b8cbdb39d7935b8ace341bb4eb499fc3`, the `govActionIx` from
step 2 is `0`, the CID from step 3 is `QmbaU4oz7rDgfukZWPgGNN772sEW41XLobF9bg7LcAuQEC`, and you want to vote `yes`, the command you would run is:

```bash
vote 270198c6d25e45a1f3ea19b0d6136b93b8cbdb39d7935b8ace341bb4eb499fc3 0 QmbaU4oz7rDgfukZWPgGNN772sEW41XLobF9bg7LcAuQEC yes
```
