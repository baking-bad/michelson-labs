
# Michelson tutorial
## Chapter six

Booleans may look simple but they are a very important part of a smart contract. As we learned in the previous chapters, a few instructions return a boolean value after comparing multiple values or evaluing a single one (for example **`EQ`**), which makes booleans an essential part of your smart contracts.

In addition to booleans, cryptograhic operations are also at the foundation of a blockchain: every transaction on the Tezos blockchain includes the encrypting of a private key to sign the transaction and the decrypting of that signature with a public key. Michelson offers different solutions to encrypt and decrypt values right from the contract, which can be very useful in particular cases.

- Boolean types
- _AND_, _OR_, _XOR_, _NOT_
- Cryptographic primitives (*HASH_KEY*, *BLAKE2B*, *SHA256*, *SHA512*, *CHECK_SIGNATURE*, *COMPARE*)

##### 1. Boolean type and operations on booleans

*Boolean* must be the simplest type out there as it accepts only two values: `True` or `False`. However, don't let its simplicity fool you because there is a lot of power in it. After all, the distinction between true or false values (or `0` and `1`) is what powers the computer you are reading this tutorial on.

There are 4 operations you can use on booleans that we will present below with examples, let's start with the first one, **`AND`**:


```Michelson
storage unit ;
parameter unit ;
BEGIN Unit Unit ;
DROP ;
```

    storage unit;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, Unit);
    DROP: pop (Unit, Unit);


```Michelson
PUSH bool True ;
PUSH bool True ;
AND @first_result ;
PUSH bool True ;
PUSH bool False ;
AND @second_result ;
PUSH bool False ;
PUSH bool False ;
AND @third_result ;
DUMP ;
```

    PUSH: push True;
    PUSH: push True;
    AND: pop True, True; push True;
    PUSH: push True;
    PUSH: push False;
    AND: pop False, True; push False;
    PUSH: push False;
    PUSH: push False;
    AND: pop False, False; push False;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th><th>name                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@third_result</pre> </td></tr>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@second_result</pre></td></tr>
<tr><td><pre style="text-align: left;">True</pre> </td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@first_result</pre> </td></tr>
</tbody>
</table>



If you already know a programming language, you know what **`AND`** is! The instruction compares two boolean values, if one of them is false, it returns `False`, if they are both true, it returns `True`. Note that, as usual, the instruction works on the top two elements of the stack (unless used with **`DIP`** of course).

If you are looking for an instruction that returns `True` if at least one on the boolean value is `True`, you should use **`OR`**:


```Michelson
DROP_ALL ; ## cleans up the stack
PUSH bool True ;
PUSH bool True ;
OR @first_result ;
PUSH bool True ;
PUSH bool False ;
OR @second_result ;
PUSH bool False ;
PUSH bool False ;
OR @third_result ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push True;
    PUSH: push True;
    OR: pop True, True; push True;
    PUSH: push True;
    PUSH: push False;
    OR: pop False, True; push True;
    PUSH: push False;
    PUSH: push False;
    OR: pop False, False; push False;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th><th>name                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@third_result</pre> </td></tr>
<tr><td><pre style="text-align: left;">True</pre> </td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@second_result</pre></td></tr>
<tr><td><pre style="text-align: left;">True</pre> </td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@first_result</pre> </td></tr>
</tbody>
</table>



The **`OR`** instruction only returns `False` if both boolean values are `False`, otherwise, it returns `True` if at least one of the values is `True`.

Next, Michelson offers the _"exclusive OR"_ instruction, **`XOR`**. This one is pretty rare and you won't probably use it as often. In a nutshell, it yields `True` only if the two boolean values are different, otherwise, it yields `False` if they are the same (whether they are both `True` or `False`). Here is an example:


```Michelson
DROP_ALL ; ## cleans up the stack
PUSH bool True ;
PUSH bool True ;
XOR @first_result ;
PUSH bool True ;
PUSH bool False ;
XOR @second_result ;
PUSH bool False ;
PUSH bool False ;
XOR @third_result ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push True;
    PUSH: push True;
    XOR: pop True, True; push False;
    PUSH: push True;
    PUSH: push False;
    XOR: pop False, True; push True;
    PUSH: push False;
    PUSH: push False;
    XOR: pop False, False; push False;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th><th>name                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@third_result</pre> </td></tr>
<tr><td><pre style="text-align: left;">True</pre> </td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@second_result</pre></td></tr>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@first_result</pre> </td></tr>
</tbody>
</table>



As you can see, `True` ^ `True` yields `False`, `False` ^ `False` yields also `False` and `True` ^ `False` yields `True`.

The last operation in this list is **`NOT`**. If you are familiar with programming languages, you probably guessed what it does, it flips the value of the boolean: `True` becomes `False` and `False` becomes `True`. Unlike the instructions above, **`NOT`** only requires one element on top of the stack:


```Michelson
DROP_ALL ; ## cleans up the stack
PUSH bool True ;
NOT @first_result ;
PUSH bool False ;
NOT @second_result ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push True;
    NOT: pop True; push False;
    PUSH: push False;
    NOT: pop False; push True;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th><th>name                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">True</pre> </td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@second_result</pre></td></tr>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@first_result</pre> </td></tr>
</tbody>
</table>



##### 2. Cryptographic operations

Michelson provides three different types for cryptographic values and a few instructions to work with them and other values. It is important to understand the difference between these values as they play essential roles in the blockchain. Here are the three types you can find in smart contracts:
- `key`: represents a public key
- `key_hash`: represents the hash of a public key
- `signature`: represents a cryptographic signature

The `key` type is the one that must be the most familiar to you, it is the type assigned to public keys (that generally begin with *edpk*):


```Michelson
DROP_ALL ;
PUSH key "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn" ;
```

    DROP_ALL: drop all;
    PUSH: push edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn;




<table>
<thead>
<tr><th>value                                                                                        </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn"</pre></td><td><pre style="text-align: left;">key</pre></td></tr>
</tbody>
</table>



The key hash is the result of hashing a public key. There may be different situations in which the hash of a key is preferrable to the key itself, for example to use it as key in a map. Hashing the public key also yields a key hash that's used as a standard for public keys on Tezos:


```Michelson
HASH_KEY ; ## expected value: tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb
```




<table>
<thead>
<tr><th>value                                                                      </th><th>type                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"</pre></td><td><pre style="text-align: left;">key_hash</pre></td></tr>
</tbody>
</table>



::: warning NOTE
it is not possible to calculate the public key from its hash.
:::

In some situations, your dapp may want to interact with a smart contract on behalf of its users. The contract can verify that a certain action has been approved by a user by checking a value in bytes and its signature against the user's address. The **`CHECK_SIGNATURE`** opcode allows you to verify that a series of bytes has produced a provided signature after being signed by a certain address. The example below illustrates it:


```Michelson
DROP_ALL ;
PUSH bytes 0x05010000000568656c6c6f ;
PUSH signature "edsigtnzKd51CDomKVMFBoU8SzFZgNqRkYUaQH4DLUg8Lsimz98DFB82uiHAkdvx29DDqHxPf1noQ8noWpKMZoxTCsfprrbs4Xo" ;
PUSH key "edpktz4xg6csJnJ5vcmMb2H37sWXyBDcoAp3XrBvjRaTSQ1zmZTeRQ" ;
CHECK_SIGNATURE ;
```

    DROP_ALL: drop all;
    PUSH: push 05010000000568656c6c6f;
    PUSH: push edsigtnzKd51CDomKVMFBoU8SzFZgNqRkYUaQH4DLUg8Lsimz98DFB82uiHAkdvx29DDqHxPf1noQ8noWpKMZoxTCsfprrbs4Xo;
    PUSH: push edpktz4xg6csJnJ5vcmMb2H37sWXyBDcoAp3XrBvjRaTSQ1zmZTeRQ;
    CHECK_SIGNATURE: pop edpktz4xg6csJnJ5vcmMb2H37sWXyBDcoAp3XrBvjRaTSQ1zmZTeRQ, edsigtnzKd51CDomKVMFBoU8SzFZgNqRkYUaQH4DLUg8Lsimz98DFB82uiHAkdvx29DDqHxPf1noQ8noWpKMZoxTCsfprrbs4Xo, 05010000000568656c6c6f; push True;




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">True</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



To understand these four lines of code, you have to imagine what happened before the transaction hit the contract: a user A wants to perform a certain action in a smart contract that he is the only one allowed to do. However, this action is going to be relayed by a user B. The user A signs the transaction but asks the user B to send it. When the transaction arrives at the smart contract, the **`CHECK_SIGNATURE`** instruction is able to verify that the provided signature has been produced by the provided address. This is a powerful pattern for relayed transactions.

Next, the **`COMPARE`** instruction allows you to compare two key hashes together. You can then use **`EQ`** or a macro to verify if the two hashes are the same.

This first contract compares two provided keys:


```Michelson
storage int ;
parameter key ;
code {
    CAR ;
    HASH_KEY ;
    PUSH key "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn";
    HASH_KEY ;
    COMPARE ;
    NIL operation ;
    PAIR ;
} ;

RUN %default "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn" 2 ;
```

    storage int;
    parameter key;
    code { CAR ; HASH_KEY ; PUSH key "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn" ; HASH_KEY ; COMPARE ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn', 2);
    CAR: pop ('edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn', 2); push edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn;
    HASH_KEY: pop edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn; push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    PUSH: push edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn;
    HASH_KEY: pop edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn; push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    COMPARE: pop tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb, tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb; push 0;
    NIL: push [];
    PAIR: pop [], 0; push ([], 0);




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



This second contract compares two key hashes and stores whether they are identical or not:


```Michelson
storage bool ;
parameter key ;
code {
    CAR ;
    HASH_KEY ;
    PUSH key "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn";
    HASH_KEY ;
    CMPEQ ;
    NIL operation ;
    PAIR ;
} ;

RUN %default "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn" False ;
```

    storage bool;
    parameter key;
    code { CAR ; HASH_KEY ; PUSH key "edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn" ; HASH_KEY ; { COMPARE ; EQ } ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn', False);
    CAR: pop ('edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn', False); push edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn;
    HASH_KEY: pop edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn; push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    PUSH: push edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn;
    HASH_KEY: pop edpkvGfYw3LyB1UcCahKQk4rF2tvbMUk8GFiTuMjL75uGXrpvKXhjn; push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    COMPARE: pop tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb, tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb; push 0;
    EQ: pop 0; push True;
    NIL: push [];
    PAIR: pop [], True; push ([], True);




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">True</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



Michelson also provides different opcodes for cryptographic operations to create hashes with different algorithms like SHA256, SHA512 and BLAKE2B. These instructions take a serie of bytes and output the result as bytes:


```Michelson
storage unit ;
parameter unit ;
BEGIN Unit Unit ;
DROP ;

PUSH bytes 0x05010000000b68656c6c6f20776f726c64 ;
BLAKE2B @blake2b ;
PUSH bytes 0x05010000000b68656c6c6f20776f726c64 ;
SHA256 @sha256 ;
PUSH bytes 0x05010000000b68656c6c6f20776f726c64 ;
SHA512 @sha512 ;
DUMP ;
```

    storage unit;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, Unit);
    DROP: pop (Unit, Unit);
    PUSH: push 05010000000b68656c6c6f20776f726c64;
    BLAKE2B: pop 05010000000b68656c6c6f20776f726c64; push c091fd2fae2e946144b61bd11582b6cee68675a8f3780a9018e542671d4d0f30;
    PUSH: push 05010000000b68656c6c6f20776f726c64;
    SHA256: pop 05010000000b68656c6c6f20776f726c64; push 4dc9a42063f0304879a107dea7975a0ca4b7eac54a41adeb476302399b311bcd;
    PUSH: push 05010000000b68656c6c6f20776f726c64;
    SHA512: pop 05010000000b68656c6c6f20776f726c64; push b59b50052ad3e5a1c5a164ba55a9fdd07d5387e8bf6a3e3e71aa462b649fc06e4dafa55f65b484011cac4a35bdaba7f69f0ffb4d1347e0962ae9c380e67ab8fe;




<table>
<thead>
<tr><th>value                                                                                                                                                                  </th><th>type                                      </th><th>name                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0xb59b50052ad3e5a1c5a164ba55a9fdd07d5387e8bf6a3e3e71aa462b649fc06e4dafa55f65b484011cac4a35bdaba7f69f0ffb4d1347e0962ae9c380e67ab8fe</pre></td><td><pre style="text-align: left;">bytes</pre></td><td><pre style="text-align: left;">@sha512</pre> </td></tr>
<tr><td><pre style="text-align: left;">0x4dc9a42063f0304879a107dea7975a0ca4b7eac54a41adeb476302399b311bcd</pre>                                                                </td><td><pre style="text-align: left;">bytes</pre></td><td><pre style="text-align: left;">@sha256</pre> </td></tr>
<tr><td><pre style="text-align: left;">0xc091fd2fae2e946144b61bd11582b6cee68675a8f3780a9018e542671d4d0f30</pre>                                                                </td><td><pre style="text-align: left;">bytes</pre></td><td><pre style="text-align: left;">@blake2b</pre></td></tr>
</tbody>
</table>




```Michelson

```
