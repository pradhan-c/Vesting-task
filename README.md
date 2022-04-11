Deployment to rinkeby Test Network
Token Address: 0x6D34E2e9770F89BCcfaCb6d6258a2fcD33AF1Fe2
Vesting Address: 0xF6330C1285dd927813FF893bC3a893708C974c0F

Create a Token Vesting Smart contract with the following Role and features:
1.) Add 3 Roles (Advisor, Partnerships, Mentors)
2.) Dynamic TGE (Token Generation Event) for every role. % of Tokens to be released right after vesting
3.) There should be a cliff of some duration added by the admin. No releasing of tokens for a few weeks or a few months.
4.) The Vesting should be a linear vesting approach which means it should release some amounts of tokens every day to be claimed by users based upon the allocations decided by the admin.

Example:
Create a Token Vesting Contract with 5% TGE for Advisors, 0 % TGE for Partnerships and 7% TGE for Mentors with 2 months cliff and 22  months linear vesting for all roles

# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
