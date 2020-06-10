## Notebooks Tutorial Plan

### 1- Working with the stack, basic kernel helpers

- Typology conventions
- Basic structure of Michelson contract
- Initial state
- _PUSH_ instruction
- Final state
- Notebook how-to and instructions: _BEGIN_, _DUMP_, _COMMIT_

### 2- Advanced stack usage, stack-protecting instructions, types

- More instructions (_DIP_, _DUP_, _CAR_/_CDR_, _SWAP_, _CONCAT_, _PAIR_, _DIG_, etc.)
- Introduction to types in Michelson

### 3- Conditional execution, fail operators, useful macros

- Conditionals (_IF_, _IF_NONE_, _IFCMP_)
- _ASSERT_
- Macros
  - _CMP{EQ|NEQ|LT|GT|LE|GE}_
  - _IFCMP{EQ|NEQ|LT|GT|LE|GE}_
- _FAIL_

### 4- Arithmetic (int, nat) operations, handling optionals

- _ADD_, _SUB_, _MUL_, _EDIV_, _NEG_, _ISNAT_, _NAT_, _ABS_
- _SOME_, _NONE_, _IF_NONE_

### 5- Working with mutez & timestamps, BALANCE, AMOUNT, NOW

- mutez type
- _ADD_, _SUB_, _MUL_, _EDIV_, _COMPARE_
- _BALANCE_, _AMOUNT_
- _TRANSFER_TOKENS_, _ADDRESS_, _CONTRACT_

### 6- Boolean and cryptographic operations

- Boolean types
- _AND_, _OR_, _XOR_, _NOT_

### 7- Operations on strings and lists

- string type
- _CONCAT_, _SLICE_, _SIZE_, _COMPARE_

### 8- Pairs: constructing/deconstructing, right/left balanced trees & comparable pairs

### 9- Cast types, compare, pack/unpack bytes

### 10- Operation on maps & sets, big_maps

### 11- Iterating collections with ITER, LOOP, MAP & SET macros

### 12- Union type, entrypoints, handling parameters, implementing enum

### 13- Address & contract types, entrypoint address, SELF, SENDER, SOURCE

### 14- Internal operations: delegation, origination, transaction

### 15- Lambdas, partial application
