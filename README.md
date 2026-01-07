# linergz contract

This contract gates a one-time STX claim on a stored Bitcoin difficulty value
submitted by an oracle. It also supports owner-controlled configuration and a
pause switch.

## What it does

- Stores an owner, beneficiary, oracle, target difficulty, and unlock burn height.
- Accepts oracle-submitted difficulty values that must be non-decreasing.
- Allows a single claim when:
  - The contract is not paused.
  - The claim has not already been made.
  - The current burn block height is at or above the unlock burn height.
  - The stored difficulty is at or above the target difficulty.
  - The caller is the beneficiary.

## State

- `owner`: contract admin.
- `beneficiary`: recipient eligible to claim.
- `oracle`: account allowed to submit difficulty.
- `target-difficulty`: minimum difficulty required to unlock.
- `current-difficulty`: latest oracle-submitted difficulty (u0 means unset).
- `last-difficulty-burn-height`: burn height associated with the last submission.
- `unlock-burn-height`: minimum burn height required to claim.
- `claimed`: tracks whether the vesting claim has been made.
- `paused`: blocks claims when true.

## Public functions

- `set-beneficiary(new-beneficiary)`: owner-only.
- `set-target-difficulty(new-target)`: owner-only.
- `set-oracle(new-oracle)`: owner-only.
- `set-unlock-burn-height(new-height)`: owner-only.
- `set-paused(new-paused)`: owner-only.
- `transfer-ownership(new-owner)`: owner-only.
- `submit-difficulty(difficulty, burn-height)`: oracle-only; non-decreasing checks.
- `claim-vested-tokens()`: performs the gated, one-time STX transfer.

## Read-only functions

- `get-current-difficulty()`: returns `current-difficulty` or error if unset.
- `get-owner()`, `get-beneficiary()`, `get-oracle()`
- `get-target-difficulty()`, `get-last-difficulty-burn-height()`
- `get-unlock-burn-height()`, `is-claimed()`, `is-paused()`

## Notes

- The contract uses `as-contract` for the transfer, so the contract must hold
  enough STX to cover `VESTED-AMOUNT`.
- Difficulty values are stored via `submit-difficulty`; there is no direct
  burn-chain header parsing in this version.
