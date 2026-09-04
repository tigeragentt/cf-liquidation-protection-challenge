# cf-liquidation-protection-challenge
Automated Liquidation Protection Challenge
using CRE Confidential Workflows

Tokens:
- virtual ETH - vETH - [0x89F0DF6D4629D494D599E03505C323537C24667a](https://etherscan.io/address/0x89F0DF6D4629D494D599E03505C323537C24667a)

- virtual USD - vUSD - [0xC96c007023Ae2a23D097D5D95d4b91D6a501Da0b](https://etherscan.io/address/0xC96c007023Ae2a23D097D5D95d4b91D6a501Da0b)

# The challenge

Build a Confidential Workflow that protects a virtual ETH-collateral/USDC-debt position during simulated market movements.

The workflow must:

* Avoid liquidation.  
* Preserve the benefit of keeping the loan open.  
* Use emergency capital efficiently.  
* Keep sensitive protection rules and credentials private.

### Private workflow inputs
The following should remain inside the Confidential Workflow:

* Health-factor trigger for intervention.  
* Target health factor after intervention.  
* Maximum USDC repayment allowed.  
* Maximum additional ETH collateral allowed.  
* Choice and priority of protection actions.  
* Safety margin applied during volatile markets.  
* Cooldown between interventions.  
* Full-repayment or emergency-exit threshold.  
* Wallet authorization or signing credentials.  
* Private RPC or API credentials.

For example, a participant might privately configure:

```
Intervene when health factor < 1.08
Restore health factor to 1.18
Repay no more than 15% of the original debt
Add collateral only if repayment is insufficient
Wait at least two price intervals between non-critical actions
```

These values should not appear in the public contract, repository, workflow logs or configuration files.

The final transaction remains public. 
Observers will see when the workflow acts and how much it repays or adds, so they may infer parts of the strategy. 

> The confidentiality objective is to protect the inputs and decision logic before execution—not to make public-chain actions invisible.

## Organizer Setup
Deploy a liquidation challenge contract on Sepolia that:
- Creates an identical virtual position for every participant.
- Create virtual assets, to use like ETH as collateral and USDC as debt, example: vETH and vUSD.
- Calculates an Aave-style health factor.
- Supports virtual `repay USDC` and `add ETH collateral` actions.
- Tracks liquidations, capital usage, interventions and time-weighted debt.
- Emits all actions and results onchain.
- No real collateral or debt tokens are required. Participants need only enough Sepolia ETH for gas.

Example virtual position:
* `0.01 ETH` collateral.  
* ETH price of `$2,000`.  
* `$12.80 USDC` debt.  
* 80% liquidation threshold.  
* Starting health factor of `1.25`.  
* Fixed virtual emergency ETH and USDC allowances.

Organizer manually submits ETH price updates during synchronized rounds.


### **Market scenarios examples**

| Scenario | Example ETH price path | Expected behavior |
| ----- | ----- | ----- |
| Gradual decline | $2,000 → $1,850 → $1,750 → $1,650 → $1,550 | Make a proportionate intervention before liquidation. |
| Sudden crash | $2,000 → $1,700 → $1,625 → $1,450 | React quickly at the first dangerous update. |
| Temporary wick | $2,000 → $1,750 → $1,620 → $1,900 | Hold or intervene minimally rather than closing unnecessarily. |
| Two-stage decline | $2,000 → $1,750 → $1,650 → $1,650 → $1,500 | Create sufficient protection or perform an efficient second intervention. |
| Safe volatility | $2,000 → $1,800 → $1,950 → $1,750 → $2,050 | Avoid unnecessary interventions. |

### **Winner metric**

Each scenario produces a score out of 100:

| Component | Weight | Measurement |
| ----- | ----- | ----- |
| Liquidation protection | 40 | Whether the position survives the scenario. |
| Loan continuity | 20 | Time-weighted percentage of the original debt kept open. |
| Capital efficiency | 15 | Emergency ETH and USDC consumed. |
| Confidentiality | 15 | Protection of private inputs, credentials and execution policy. |
| Intervention discipline | 10 | Avoiding unnecessary, excessive or repeated actions. |


#### **Loan continuity**

```
Loan Continuity =
    Sum of (Debt During Interval × Interval Duration)
    -------------------------------------------------
       Initial Debt × Total Scenario Duration
```

#### **Confidentiality scoring**

| Requirement | Points |
| ----- | ----- |
| Trigger and target health factors remain private | 3 |
| Capital limits and action-selection policy remain private | 3 |
| Credentials are stored and used only as protected secrets | 3 |
| No private inputs appear in logs, errors or public configuration | 3 |
| Confidential execution evidence or an execution receipt is provided | 3 |


### **Selecting the winner**

1. Run every workflow through all market scenarios.  
2. Calculate the score for each scenario.  
3. Add the confidentiality assessment.  
4. Average the scenario scores.  
5. Highest overall score wins.  
6. Use the worst scenario score as the first tie-breaker.  
7. Use the least emergency capital consumed as the second tie-breaker.

All participants receive identical positions, prices, timing and virtual capital allowances. 

The Sepolia contract provides an auditable record of inputs, actions and outcomes.
