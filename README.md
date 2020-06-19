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
- _BALANCE_, _AMOUNT_, _NOW_
- _TRANSFER_TOKENS_, _ADDRESS_, _CONTRACT_

### 6- Boolean and cryptographic operations

- Boolean types
- _AND_, _OR_, _XOR_, _NOT_

### 7- Operations on strings and lists

- string type
- _CONCAT_, _SLICE_, _SIZE_, _COMPARE_
- list type
- *CONS*, *NIL*, *IF_CONS*, *SIZE*

### 8- Pairs: constructing/deconstructing, nested pairs, right/left balanced trees & comparable pairs

- pair type
- *PAIR*, *CAR*, *CDR*, *COMPARE*, *SET_C[AD]R*, *MAP_C[AD]R*
- Nested pair macros

### 9- Cast types, compare, pack/unpack bytes

### 10- Operation on maps & sets, big_maps

- map, big map and set types
- difference between map and big map
- operations on sets: *EMPTY_SET*, *MEM*, *UPDATE*, *SIZE*
- operations on maps: *EMPTY_MAP*, *GET*, *UPDATE*, *SIZE*
- operations on big maps: *EMPTY_BIG_MAP*, *GET*, *MEM*, *UPDATE*

### 11- Iterating collections with ITER, LOOP, MAP & SET macros

- definitions and examples

### 12- Union type, entrypoints, handling parameters, implementing enum

- or (l) (r)
- use of *or* for entrypoints

### 13- Address & contract types, entrypoint address, SELF, SENDER, SOURCE

### 14- Internal operations: delegation, origination, transaction

### 15- Lambdas, partial application
