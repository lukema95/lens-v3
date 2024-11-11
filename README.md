```
                                              @@@@@@@@@
                                        @@@@@@@@@@@@@@@@@@@@@
                                    @@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
              @@@@@@@@@@@       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@
        @@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@
      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@              @@@@@@@@@@@@@@              @@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@          @@@@@@@   @@@@@@@@@         @@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@
  @@@@@@@@@@@@@@@@@@@@@@  @@        @@@@@@@@  @@@@@@   @       @@@@@@@@   @@@@@@@@@@@@@@@@@@@@@@
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

# Lens Protocol V3

## Setup

### 1. Clone the Repository

```
git clone git@github.com:lens-protocol/core.git
```

### 2. Install dependencies

```
yarn
```

### 3. Compile

```
npx hardhat compile
```

### 4. Test

The test coverage is still in progress, and mostly not present in this version of the codebase.

### 5. Deploy

Fill the .env with your private key, your .env should look like this:

```
WALLET_PRIVATE_KEY=0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
```

Make sure your wallet has enough GRASS on Lens Testnet Network to deploy the contracts.

Run the following command, which deploys the full protocol with all present Rules & Actions, and also the Global Feed, Graph, and Username primitives.

```
yarn run deploy
```

## Project Structure

The `contracts/` directory is dived into four main directories: `core/`, `dashboard/`, `rules/`, and `actions/`. In the future, each directory might live under its own repository; during this early stages of Lens Protocol V3 development they coexist in the same one.

### Core

Contains the main contracts that make up the base Lens Protocol. These contracts are envisioned as non-opinionated and flexible, allowing for a wide range of use cases.

### Dashboard

Contains the Lens Dashboard's bespoke contracts. These contracts are opinionated and are designed to achieve the best experience while using the Lens Dashboard.

### Rules

Contains contracts implementing Lens Rules.

### Actions

Contains contracts implementing Lens Actions.
