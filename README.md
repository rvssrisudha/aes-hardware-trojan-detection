# AES-128 Hardware Trojan Insertion & Power-Based Detection

## Overview

This project demonstrates controlled insertion of a stealth hardware Trojan into a pipelined AES-128 cryptographic core and its detection using post-synthesis power analysis.

A plaintext-triggered payload was integrated at the final round stage of AES to manipulate the 10th round key, enabling cryptographic key extraction. Detection was performed using averaged and time-based dynamic power analysis with industry-standard Synopsys tools.

The work models realistic stealth Trojan behavior and validates non-invasive detection via power profiling.

---

## System Architecture
<img width="170" height="296" alt="image" src="https://github.com/user-attachments/assets/d6ac4a33-5bef-420e-b21f-5808ea18f097" />
<img width="192" height="262" alt="image" src="https://github.com/user-attachments/assets/09d474cc-aa48-4b59-93e9-d6425d34bae1" /> 

- 10-round pipelined AES-128 core  
- Dedicated key expansion module  
- Round-based transformation pipeline  
- Trojan insertion at final round input stage  

---

## Trojan Model

### Trigger Mechanism
- Activated when a specific 128-bit plaintext appears three times  
- Counter-based sequential detection  
- Persistent activation after trigger  

### Payload Mechanism
- Overrides final round data path using bitwise injection  
- Produces predictable corrupted ciphertext  
- Enables recovery of 10th round key  
- Original AES key reconstructed via reverse key expansion (Python)  

---

## Experimental Flow
RTL (Clean + Trojan)
↓
Synopsys Design Compiler
↓
Gate-Level Netlist
↓
VCS Simulation → VCD Activity
↓
PrimePower (Averaged Dynamic Power)
PrimeTime (Time-Based Power)

---

## Power Analysis Results

### Averaged Dynamic Power (PrimePower)

| Design | Dynamic Power |
|--------|---------------|
| Clean AES | 160145.58 µW |
| Trojan Activated | 160174.52 µW |

Measured Difference: **28.94 µW**

---

### Time-Based Power (PrimeTime)

| Design | Power |
|--------|--------|
| Clean AES | 0.1266 W |
| Trojan Activated | 0.1267 W |

Measured Difference: **100 µW**

---

## Key Observations

- Functional outputs remain correct during normal operation  
- Power profiles nearly identical under non-trigger conditions  
- Detectable power anomaly observed only during Trojan activation  
- Demonstrates stealth behavior consistent with hardware security literature  

---

## Repository Structure
rtl/

├── common/

├── aes_clean/

└── aes_trojan/

tb/

scripts/

results/

docs/


---

## Tools & Technologies

- SystemVerilog  
- Synopsys Design Compiler  
- Synopsys VCS  
- Synopsys PrimePower  
- Synopsys PrimeTime  
- TCL scripting  
- Python (Key reconstruction)  

---

## Technical Significance

- Demonstrates controlled RTL-level Trojan insertion  
- Shows ASIC flow from RTL → Netlist → Power Analysis  
- Validates power-based detection threshold  
- Bridges cryptographic security and hardware verification
  
