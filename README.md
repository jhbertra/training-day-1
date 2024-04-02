# Using the scripts

## Setup

### 1. Add the project directory to your PATH

The first thing to do, as a small ease-of-use improvement, is to run the following command:

```bash
PATH="$PATH:$(pwd)"
```

If you don't do this, you will have to add `./` in front of the filenames of the scripts when
running them. For example, to run the `list-proposals` script:

```bash
# Without running PATH="$PATH:$(pwd)"
./list-proposals.sh

# After running PATH="$PATH:$(pwd)"
list-proposals.sh
```

### 2. Setup your environment for working with your user number

At the beginning of the session, you will be issued a user number from 1 to 25. Run the following command:

```bash
source set-user.sh <your-user-number>
```

For example, if your user number is 1:

```bash
source set-user.sh 1
```

If you don't do this, most of the scripts won't work at all.

## Scripts

### `gen-hot.sh`

Generates a new hot-key pair for your user number. **Overwrites existing key files if run more than once.**

### `authorize-hot.sh`

Authorizes the generated hot-key for your user number to sign off on votes. Requires `gen-hot.sh` to have been run.

### `list-proposals.sh`

Shows all active governance actions which can be voted on.

### `show-committee.sh`

Shows the state of all active constitutional committee members.

### `show-membership.sh`

Shows only the state of your user number's membership in the constitutional committee.

### `show-utxo.sh`

Shows the utxo (balance) in your user number's payment address.

### `vote.sh`

Casts a vote for a governance action. See [How to vote](#how-to-vote)

## How to vote

### 1. Run all necessary prerequisites

You must run `gen-hot.sh` and `authorize-hot.sh` before you can vote. Note there will be a delay after running `authorize-hot.sh`
before you can vote. You can check by running `show-membership.sh`. If the output says `MemberAuthorized`, you can vote.

### 2. Find out the Tx ID and Action Index of the governance action you want to vote for.

All governance actions are identified by:

1. The ID of the transaction in which they were proposed.
2. The index of the action within that transaction, starting from 0.

If you run `list-proposals.sh` you will see a list of all governance actions. Find theaction you want to vote for
and take note of the fields in the `actionId` property (namely, `govActionIx` and `txId`).

### 3. Prepare the rationale for your vote.

After deciding how you want to vote, make a copy of `metadata-template.json` on the laptop on which you installed IPFS.
Ignoring everything under `"@context"`, write up your rationale inside the empty double quotes for `title`, `abstract`, `motivation`, and `rationale` fields
under `body`. Note that you cannot add newlines to the text here.

Save the file, and add it to IPFS via the IPFS Desktop user interface. Make note of the content ID (CID) of the file after it has been added.

Copy the full contents of the file into https://json-ld.org/playground/ where it says "Enter your JSON-LD markup here...".

Open the "Canonized" tab in the output panel below and copy what it says into a new file in the "user-<your-user-number>-files" folder for
your user number in the Demeter workspace. Call it `rationale.nq`

Run the `vote.sh` script as follows:

```bash
vote.sh <txId from step 2> <govActionIx from step 2> ipfs://<cid from step 3> user-<your-user-number>-files/rationale.nq <yes, no, or abstain>
```

For example, if the `txId` from step 2 is `270198c6d25e45a1f3ea19b0d6136b93b8cbdb39d7935b8ace341bb4eb499fc3`, the `govActionIx` from
step 2 is `0`, the CID from step 3 is `QmbaU4oz7rDgfukZWPgGNN772sEW41XLobF9bg7LcAuQEC`, and your user number is `4`, and you want to vote
`yes`, the command you would run is:

```bash
vote.sh 270198c6d25e45a1f3ea19b0d6136b93b8cbdb39d7935b8ace341bb4eb499fc3 0 ipfs://QmbaU4oz7rDgfukZWPgGNN772sEW41XLobF9bg7LcAuQEC user-4-files/rationale.nq yes
```
