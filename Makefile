-include

.PHONY: all deploy test script FundMe FundFundMe WithdrawFundMe cast send snapshot coverage forge anvil

help:
		@echo "Usage:"
		@echo "	make deploy [ARGS=...]\n		example: make deploy ARGS=\"--network sepolia\""
		@echo ""
		@echo " make fund [ARGS=...]\n	example: make deploy ARGS=\"--network sepolia\""

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

clean:; forge clean

remove:; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && rm -rf cache && touch .gitmodules && git add . && git commit -m "modules"

install:; forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install Cyfrin/foundry-devops@o.0.11 --no-commit

update:; forge update

build:; forge build

# test on temporary local anvil spun by foundry.
test:; forge test

snapshot:; forge snapshot

format:; forge fmt

anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://127.0.0.1:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network goerli,$(ARGS)),--network goerli)
	NETWORK_ARGS := --rpc-url $(GOERLI_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# first need to start anvil into different terminal.
test-anvil:
	@make deploy && forge test --rpc-url http://127.0.0.1:8545

test-sepolia:
	@forge test --rpc-url $(SEPOLIA_RPC_URL)

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

fund:
	@forge script script/Interactions.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe $(NETWORK_ARGS)
