## Notebooks Tutorial Plan

### Working with the stack, basic kernel helpers

- Basic structure of Michelson contract
- Initial state
- _PUSH_ instruction
- Final state
- Notebook how-to and instructions: _BEGIN_, _DUMP_, _COMMIT_

### Advanced stack usage, stack-protecting instructions, types

- More instructions (_DIP_, _DUP_, _CAR_/_CDR_, _SWAP_, _CONCAT_, _PAIR_, _DIG_, etc.)
- Introduction to types in Michelson

### Conditional execution, fail operators, useful macros

- Conditionals (_IF_, _IF_LEFT_/_IF_RIGHT_, _IF_NONE_, _IF_CMP_)
- _ASSERT_
- Macros
  - _CMP{EQ|NEQ|LT|GT|LE|GE}_
  - _IFCMP{EQ|NEQ|LT|GT|LE|GE}_

### Arithmetic (int, nat) operations, handling optionals

### Working with mutez & timestamps, BALANCE, AMOUNT, NOW

### Boolean and cryptographic operations

### Operations on strings and lists

### Pairs: constructing/deconstructing, right/left balanced trees & comparable pairs

### Cast types, compare, pack/unpack bytes

### Operation on maps & sets, big_maps

### Iterating collections with ITER, LOOP, MAP & SET macros

### Union type, entrypoints, handling parameters, implementing enum

### Address & contract types, entrypoint address, SELF, SENDER, SOURCE

### Internal operations: delegation, origination, transaction

### Lambdas, partial application
