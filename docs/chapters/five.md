
# Michelson tutorial
## Chapter five  

In this new installment of our tutorials, we are going to talk about money!  
One of the main advantages of smart contracts is that they are "programmable money": they let you store, manipulate and send tezzies in a predictable way. Smart contracts can work as middle men and verify that a set of conditions is met before initiating a transaction, sending a certain amount of tezzies or doing any other modification.  

In the previous tutorials, we encountered a couple of instructions that push useful information about the smart contract and its context onto the stack: you may remember **`NOW`** that adds the current timestamp on top of the stack. This is not the only one. Michelson provides a few instructions that give you access to a lot of information. In this chapter, we are going to focus on the ones that are related to the financial aspect of smart contracts: **`BALANCE`**, **`AMOUNT`**, **`TRANFER_TOKENS`**. You will also get a refresher about `mutez` operations. At the end of the chapter, you will have everything you need to know in order to handle financial operations in your smart contracts 🤑

### Plan of the tutorial
1. <a href="#section1" style="text-decoration:none">`mutez` and `mutez` operations</a>
2. <a href="#section2" style="text-decoration:none">**`BALANCE`**, **`AMOUNT`** and **`NOW`**</a>
3. <a href="#section3" style="text-decoration:none">Address, contract and token transfer</a>

##### 1. `mutez` and `mutez` operations

The `mutez` (or *micro-tez*) type is a special type that allows you to manipulate financial values in your smart contracts. `mutez` are indivisible and always positive (as exposed below, a few restrictions are set to avoid negative values of `mutez`). It may seem a little strange at the beginning, but `mutez` values are NOT tezzies, they only represent a financial value. If you write `PUSH mutez 1000`, this doesn't mean you added 1,000 microtez out of thin air in your smart contract. You merely create a value of a certain type to easily manipulate other values.  

You can use different arithmetic operations for values of type `mutez`: **`ADD`**, **`SUB`**, **`MUL`**, **`EDIV`** with a few restrictions:

- **`ADD`** only works with two values of type `mutez`
- **`SUB`** only works with two values of type `mutez` AND fails if the result of the subtraction is negative
- **`MUL`** only works with one value of type `mutez` and one value of type `nat`, the result is of type `mutez`
- **`EDIV`** only works with one value of type `mutez` and one value of type `nat`, the result is of type `option`, `None` in case of a division by zero, `Some ((pair quotient remainder))` including a pair containing the quotient on the left and the remainder on the right  

In addition to these operations, it is also possible to compare two values of type `mutez`. Like any other value, this comparison yields an `int` between `-1` and `1`.  

Now let's see some examples:

We initialize a simple contract to test these operations:


```Michelson
storage mutez ;
parameter unit ;
BEGIN Unit 1000 ;
```

    storage mutez;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, 1000);




<table>
<thead>
<tr><th>value                                              </th><th>type                                                </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair Unit 1000</pre></td><td><pre style="text-align: left;">pair unit mutez</pre></td></tr>
</tbody>
</table>



Now let's separate the storage and push a new value of type `mutez` (nothing new here):


```Michelson
CDR @storage ;
PUSH mutez 2000 ;
DUMP ;
```

    CDR: pop (Unit, 1000); push 1000;
    PUSH: push 2000;




<table>
<thead>
<tr><th>value                                    </th><th>type                                      </th><th>name                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">2000</pre></td><td><pre style="text-align: left;">mutez</pre></td><td>                                             </td></tr>
<tr><td><pre style="text-align: left;">1000</pre></td><td><pre style="text-align: left;">mutez</pre></td><td><pre style="text-align: left;">@storage</pre></td></tr>
</tbody>
</table>



With the **`ADD`** instruction, we can remove the two values of type `mutez` from the stack, add them together and push the result back to the stack:


```Michelson
ADD ;
```




<table>
<thead>
<tr><th>value                                    </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">3000</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



After adding values together, let's try to subtract one from another! We push a new value of type `mutez` and use the one already present in the stack to demonstrate **`SUB`**:


```Michelson
PUSH mutez 500 ;
SWAP ;
SUB ;
```

    PUSH: push 500;
    SWAP: pop 500, 3000; push 500; push 3000;
    SUB: pop 3000, 500; push 2500;




<table>
<thead>
<tr><th>value                                    </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">2500</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



Did you notice the **`SWAP`** instruction? You must make sure that the two elements are in the right order. If you try `mutez 500 - mutez 3000`, the contract will fail because `mutez` values cannot be negative.  

Next, we can multiply `mutez` values with `nat` values (to ensure positive results). In this situation, the order of the values doesn't matter, so no need to swap them:


```Michelson
PUSH nat 4 ;
MUL ;
```

    PUSH: push 4;
    MUL: pop 4, 2500; push 10000;




<table>
<thead>
<tr><th>value                                     </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">10000</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



As you can see, the value returned by **`MUL`** is also of type `mutez`.  

As it was the case for the other numeric values, using **`EDIV`** with `mutez` is also a bit more complex. If you remember from the previous chapter, the result of **`EDIV`** is an option. If you try a division by zero, the option will have the value `None`. Otherwise, it has a value of type `pair` that contains the quotient on the left and the remainder on the right.  

We can write a small piece of code that tries to divide the value on top of the stack by the value we've just pushed. If this value is `0`, the contract fails. Otherwise, it extracts the quotient and the remainder and rearrange them in this order in the stack:


```Michelson
PUSH nat 10 ;
SWAP ;
EDIV ;
IF_NONE
    { PUSH string "DivisionByZero" ; FAILWITH }
    {
        DUP ;
        CAR @quotient ;
        SWAP ;
        CDR @remainder ;
        SWAP ;
    } ;
DUMP ;
```

    PUSH: push 10;
    SWAP: pop 10, 10000; push 10; push 10000;
    EDIV: pop 10000, 10; push ((1000, 0),);
    IF_NONE: pop ((1000, 0),); push (1000, 0);
      DUP: push (1000, 0);
      CAR: pop (1000, 0); push 1000;
      SWAP: pop 1000, (1000, 0); push 1000; push (1000, 0);
      CDR: pop (1000, 0); push 0;
      SWAP: pop 0, 1000; push 0; push 1000;




<table>
<thead>
<tr><th>value                                    </th><th>type                                      </th><th>name                                           </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1000</pre></td><td><pre style="text-align: left;">mutez</pre></td><td><pre style="text-align: left;">@quotient</pre> </td></tr>
<tr><td><pre style="text-align: left;">0</pre>   </td><td><pre style="text-align: left;">mutez</pre></td><td><pre style="text-align: left;">@remainder</pre></td></tr>
</tbody>
</table>



The two values we get on the stack are exactly the expected ones: `10000 / 10 = 1000` with a remainder of `0`.  

Lastly, we can compare two values of type `mutez` and check if one is equal, greater or less than the other one. This will be particularly useful when you want to verify that users send the correct amount of tezzies required by your contract:


```Michelson
PUSH mutez 500 ;
COMPARE ;
EQ ;
```

    PUSH: push 500;
    COMPARE: pop 500, 1000; push -1;
    EQ: pop -1; push False;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



We're adding here an extra step to check if the newly added value in the stack is equal to the one already present. As they are not equal, `False` is pushed onto the stack. Obviously, you can use any of the instructions we studied in Chapter three outside of **`EQ`**.

##### 2. <span id="section2">**`BALANCE`**, **`AMOUNT`** and **`NOW`**</span>

Michelson provides a few instructions that are very useful to check the context of execution.  

Every time a smart contract runs, a few "variables" are available about data related to the current execution. For example, every transaction sent to a smart contract has an amount of tezzies attached to it (even if this is amount may be `0`). You may want to have access to this amount, for example, to check if the users sent enough tezzies for the service they requested or to update their token balance.  
You can easily add this piece of information to the stack by using **`AMOUNT`**. The **`AMOUNT`** instruction will simply push a new element on top of the stack of type `mutez` whose value is equal to the amount sent along the transaction.

Here are two examples to showcase what you can do with the **`AMOUNT`** instruction:


```Michelson
storage mutez ;
parameter unit ;
code {
    CDR ;
    AMOUNT ;
    DUP ;
    DUG 2 ;
    IFCMPGT
        { NIL operation ; PAIR }
        { FAIL }
} ;

RUN %default Unit 100 ;
```

    storage mutez;
    parameter unit;
    code { CDR ; AMOUNT ; DUP ; DUG 2 ; { { COMPARE ; GT } ; IF { NIL operation ; PAIR } { { UNIT ; FAILWITH } } } };
    RUN: use %default; drop all; push (Unit, 100);
    CDR: pop (Unit, 100); push 100;
    AMOUNT: push 0;
    DUP: push 0;
    DUG: pop 0; protect 2 item(s); push 0; restore 2 item(s);
    COMPARE: pop 0, 100; push -1;
    GT: pop -1; push False;
    IF: pop False;
    UNIT: push Unit;
    FAILWITH: pop Unit;

    MichelsonRuntimeError: Unit
    at RUN -> IF -> FAILWITH

The contract fails as expected. Indeed, there is no tezzie attached to this transaction, so the value contained in **`AMOUNT`** is not greater than the one in the storage.  
Because this environment is detached from the blockchain, you have to specify yourself the value you want to give to `amount` and use a non-Michelson instruction that works only in the context of these notebooks: **`PATCH`**. Here is how it works:


```Michelson
storage mutez ;
parameter unit ;
code {
    PATCH AMOUNT 200 ;
    CDR ;
    AMOUNT ;
    DUP ;
    DUG 2 ;
    IFCMPGT
        { NIL operation ; PAIR }
        { FAIL }
} ;

RUN %default Unit 100 ;
```

    storage mutez;
    parameter unit;
    code { PATCH AMOUNT 200 ; CDR ; AMOUNT ; DUP ; DUG 2 ; { { COMPARE ; GT } ; IF { NIL operation ; PAIR } { { UNIT ; FAILWITH } } } };
    RUN: use %default; drop all; push (Unit, 100);
    PATCH: set AMOUNT=200;
    CDR: pop (Unit, 100); push 100;
    AMOUNT: push 200;
    DUP: push 200;
    DUG: pop 200; protect 2 item(s); push 200; restore 2 item(s);
    COMPARE: pop 200, 100; push 1;
    GT: pop 1; push True;
    IF: pop True;
    NIL: push [];
    PAIR: pop [], 200; push ([], 200);




<table>
<thead>
<tr><th>value                                   </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">200</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



You can see that the newly returned storage is `mutez 200` as expected, because `200` is greater than `100`.  

Other scenario: you create a smart contract and you want to prevent people from sending any tezzie. To do so, you must check if the amount is equal to `0` before proceeding and if it is not the case, the contract fails:


```Michelson
storage mutez ;
parameter unit ;
code {
    PATCH AMOUNT ;
    DROP ;
    AMOUNT ;
    PUSH mutez 0 ;
    IFCMPNEQ
        { FAIL }
        { 
            AMOUNT ;
            NIL operation ;
            PAIR
        }
} ;

RUN %default Unit 100 ;
```

    storage mutez;
    parameter unit;
    code { PATCH AMOUNT ; DROP ; AMOUNT ; PUSH mutez 0 ; { { COMPARE ; NEQ } ; IF { { UNIT ; FAILWITH } } { AMOUNT ; NIL operation ; PAIR } } };
    RUN: use %default; drop all; push (Unit, 100);
    PATCH: unset AMOUNT;
    DROP: pop (Unit, 100);
    AMOUNT: push 0;
    PUSH: push 0;
    COMPARE: pop 0, 0; push 0;
    NEQ: pop 0; push False;
    IF: pop False;
    AMOUNT: push 0;
    NIL: push [];
    PAIR: pop [], 0; push ([], 0);




<table>
<thead>
<tr><th>value                                 </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



You can also use `PATCH AMOUNT` with no value, which will be `0` by default. We then use the **`IFCMPNEQ`** instruction to check if the value on top of the stack (the `0` we pushed just before) is not equal to the one below (the amount). Be careful to push a value of type `mutez` for the comparison.  
If the result of the comparison is true (i.e the amount is not equal to `0`), the contract fails. Otherwise, we pushed the amount again (remember that every instruction starting with **`IF`** removes the value(s) on top of the stack) and end the execution by saving the amount in the storage.

::: warning NOTE
in a real-life scenario, you wouldn't need to push **`AMOUNT`** again if you expect the amount to be equal to `0`, you can go with `PUSH mutez 0` instead. The example above demonstrates that you have access to the value in mutez attached to the transaction at every step of the execution of the contract.
:::

In some cases, you would like to know the current balance of the contract before running a piece of code. For example, one of your users requests to withdraw his/her share in the smart contract and you need to make sure there are enough funds before initiating the transaction. You may also want to block entering transactions if the balance of the contract reaches a certain limit.  

In these cases, you can use **`BALANCE`**. Just like **`AMOUNT`**, **`BALANCE`** is an instruction that pushes a new value on top of the stack containing the current balance of the smart contract in `mutez`.

Let's write a smart contract that keeps track in the storage of the last transaction sent after making sure the current balance doesn't exceed a certain limit:


```Michelson
storage mutez ;
parameter unit ;
code {
    DROP ;
    PATCH AMOUNT 10000000 ; ## manual setting of amount
    PATCH BALANCE 25700000 ; ## manual setting of balance
    AMOUNT ;
    BALANCE ;
    ADD ;
    DUP ;
    PUSH mutez 100000000 ; # 100 tez
    IFCMPGT
        { NIL operation ; PAIR }
        { PUSH string "BalanceExceeded" ; FAILWITH }
} ;

RUN %default Unit 1000 ;
```

    storage mutez;
    parameter unit;
    code { DROP ; PATCH AMOUNT 10000000 ; PATCH BALANCE 25700000 ; AMOUNT ; BALANCE ; ADD ; DUP ; PUSH mutez 100000000 ; { { COMPARE ; GT } ; IF { NIL operation ; PAIR } { PUSH string "BalanceExceeded" ; FAILWITH } } };
    RUN: use %default; drop all; push (Unit, 1000);
    DROP: pop (Unit, 1000);
    PATCH: set AMOUNT=10000000;
    PATCH: set BALANCE=25700000;
    AMOUNT: push 10000000;
    BALANCE: push 25700000;
    ADD: pop 25700000, 10000000; push 35700000;
    DUP: push 35700000;
    PUSH: push 100000000;
    COMPARE: pop 100000000, 35700000; push 1;
    GT: pop 1; push True;
    IF: pop True;
    NIL: push [];
    PAIR: pop [], 35700000; push ([], 35700000);




<table>
<thead>
<tr><th>value                                        </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">35700000</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



This is a very simple smart contract that does one simple thing: it adds the incoming amount to the balance, compares the result with the limit we manually introduce (with `PUSH mutez 100000000 ;`), if the limit is greater than the addition of the amount and the balance, everything is fine, we save the amount in the storage and end the execution. However, if the limit is exceeded, we throw an error with the **`FAIL`** instruction.

If you try to change the values (for example adding a `0` to the balance), you can make the contract fail to test that it works properly.

We already introduced **`NOW`** in the previous chapters. The instruction pushes the current timestamp onto the stack. This is a very useful feature for time-related actions: for example, we can make a smart contract fail if a transaction comes before a certain period ended since the last transaction:


```Michelson
storage timestamp ;
parameter unit ;
code {
    CDR ;
    PUSH int 3600 ; ## 60 sec * 60 min = 1 hour interval
    ADD ;
    PATCH NOW 1592381823 ;
    NOW ;
    IFCMPGE
        { NOW ; NIL operation ; PAIR }
        { PUSH string "InvalidInterval" ; FAILWITH }
} ;

RUN %default Unit 1592379223 ;
```

    storage timestamp;
    parameter unit;
    code { CDR ; PUSH int 3600 ; ADD ; NOW ; { { COMPARE ; GE } ; IF { NOW ; NIL operation ; PAIR } { PUSH string "InvalidInterval" ; FAILWITH } } };
    RUN: use %default; drop all; push (Unit, 1592379223);
    CDR: pop (Unit, 1592379223); push 1592379223;
    PUSH: push 3600;
    ADD: pop 3600, 1592379223; push 1592382823;
    NOW: push 1592456946;
    COMPARE: pop 1592456946, 1592382823; push 1;
    GE: pop 1; push True;
    IF: pop True;
    NOW: push 1592456946;
    NIL: push [];
    PAIR: pop [], 1592456946; push ([], 1592456946);




<table>
<thead>
<tr><th>value                                          </th><th>type                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1592456946</pre></td><td><pre style="text-align: left;">timestamp</pre></td></tr>
</tbody>
</table>



As you can see, the contract stores the timestamp of the last successful execution. When a transaction comes, it adds 3,600 seconds to that timestamp and compares it to the current timestamp. If one hour has passed, the new timestamp is saved into the storage. Otherwise, an error is raised and the contract fails.  

In the contract, we use `PATCH NOW 1592381823` in order to force a certain value for our **`NOW`** instruction and see the contract fail. If you comment out this line (just add `##` at the very beginning of the line) and run the contract again, you can see that it passes now, because there is more than one hour between `NOW` and the timestamp in the storage. The value returned by **`NOW`** is then saved into the storage.

##### 3. <span id="section3">Address, contract and token transfer</span>

One of the many features of smart contracts is their ability to transfer money. You can send tezzies to a smart contract, you can send them from the smart contract to an address and you can even exchange tezzies between smart contracts! You can let anyone transfer money in and out but you can also enforce certain rules that dictate who can make transfers and how these transfers can happen. After reading this section, you will know everything you need to manage tezzies in your smart contracts!

Let's start from the beginning, with the `address` type. `address` is a type in Michelson reserved for addresses. It can be used both for implicit account (starting with *tz1*, *tz2* or *tz3*) and smart contract (starting with *KT1*) addresses. You can type an address as a string when you want, for example, to add it onto the stack:


```Michelson
storage address ;
parameter unit ;
code {
    DROP ;
    PUSH address "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ;
    NIL operation ;
    PAIR
} ;

RUN %default Unit "" ;
```

    storage address;
    parameter unit;
    code { DROP ; PUSH address "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ; NIL operation ; PAIR };
    RUN: use %default; drop all; push (Unit, '');
    DROP: pop (Unit, '');
    PUSH: push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    NIL: push [];
    PAIR: pop [], tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb; push ([], 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb');




<table>
<thead>
<tr><th>value                                                                      </th><th>type                                        </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"</pre></td><td><pre style="text-align: left;">address</pre></td></tr>
</tbody>
</table>



Be aware that the `address` type does not ensure that the address is a valid address, only that the string follows the address format.

If you want to ensure that the address is valid, you can use the `contract (param)` type. This type guarantees that the address is a valid, existing account with a parameter of type `param`. In case of an implicit account, `param` is equal to `unit`. As it is impossible to "push" a value of type `contract` onto the stack, you have to start with a value of type `address` and cast it to a value of type `contract`. Let's see an example before detailing what happens:


```Michelson
storage (contract unit) ;
parameter unit ;
code {
    DROP ;
    PUSH address "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ;
    CONTRACT unit ;
    IF_NONE
        { FAIL }
        { NIL operation ; PAIR }
} ;

RUN %default Unit "" ;
```

    storage (contract unit);
    parameter unit;
    code { DROP ; PUSH address "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ; CONTRACT unit ; IF_NONE { { UNIT ; FAILWITH } } { NIL operation ; PAIR } };
    RUN: use %default; drop all; push (Unit, '');
    DROP: pop (Unit, '');
    PUSH: push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    CONTRACT: pop tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb; skip check; push ('tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default',);
    IF_NONE: pop ('tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default',); push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default;
    NIL: push [];
    PAIR: pop [], tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default; push ([], 'tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default');




<table>
<thead>
<tr><th>value                                                                              </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default"</pre></td><td><pre style="text-align: left;">contract unit</pre></td></tr>
</tbody>
</table>



In this example, we convert a value of type `address` to a value of type `contract` and save the result in the storage. Several steps are necessary to achieve it:
1. We remove the first element of the stack with **`DROP`**.
2. We add the address on top of the stack with **`PUSH`**.
3. We use a special instruction called **`CONTRACT`** to cast the address to a contract value. Note that we provide a parameter of type `unit` indicating that the resulting value will be an implicit account.
4. Two things may happen at this point: if the address is invalid or doesn't exist, **`CONTRACT`** returns the value `None` of type option. We can use it to make the contract fail. If the address is valid and exists, **`CONTRACT`** returns the value `(Some (contract param))` of type option that we unwrap in the second branch of the conditional structure to get the value of type `(contract unit)`. This value is then saved in the storage.

In a real-life scenario, you wouldn't probably go through all these steps just to save the result in the storage. This operation can be particularly useful when you want to send tokens from a contract. Michelson provides an instruction that allows you to withdraw tezzies from the contract balance and send them to an implicit account or another contract: **`TRANSFER_TOKENS`**. The use of this instruction is not difficult by itself but you have to make sure to get its necessary parameters in the right order in the stack before calling it. Let's see an example first to observe what **`TRANSFER_TOKENS`** does:


```Michelson
storage unit ;
parameter unit ;
BEGIN Unit Unit ;
PATCH BALANCE 10000000 ;
DROP ;
```

    storage unit;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, Unit);
    PATCH: set BALANCE=10000000;
    DROP: pop (Unit, Unit);

This initializes the storage and the parameter before dropping the first element of the stack. We also add 10 tez to the balance so we have something to send to the receiver's address.


```Michelson
PUSH address "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ;
CONTRACT unit ;
DUMP ;
```

    PUSH: push tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb;
    CONTRACT: pop tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb; skip check; push ('tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default',);




<table>
<thead>
<tr><th>value                                                                                   </th><th>type                                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default"</pre></td><td><pre style="text-align: left;">option (contract unit)</pre></td></tr>
</tbody>
</table>



Like in the previous contract, we push the receiver's address to the stack and convert it to a `(contract unit)` type.


```Michelson
IF_NONE
    { PUSH string "InvalidAddress" ; FAILWITH }
    { } ;
DUMP ;
```




<table>
<thead>
<tr><th>value                                                                              </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default"</pre></td><td><pre style="text-align: left;">contract unit</pre></td></tr>
</tbody>
</table>



**`IF_NONE`** verifies that the **`CONTRACT`** instruction succeeded and that a value has been returned. In this case, the value is the address where we will send the tezzies, of type `(contract unit)`.


```Michelson
PUSH mutez 5000000 ;
DUMP ;
```




<table>
<thead>
<tr><th>value                                                                              </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">5000000</pre>                                       </td><td><pre style="text-align: left;">mutez</pre>        </td></tr>
<tr><td><pre style="text-align: left;">"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default"</pre></td><td><pre style="text-align: left;">contract unit</pre></td></tr>
</tbody>
</table>



We then push the amount we want to send to the receiver's address.


```Michelson
PUSH unit Unit ;
DUMP ;
```




<table>
<thead>
<tr><th>value                                                                              </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Unit</pre>                                          </td><td><pre style="text-align: left;">unit</pre>         </td></tr>
<tr><td><pre style="text-align: left;">5000000</pre>                                       </td><td><pre style="text-align: left;">mutez</pre>        </td></tr>
<tr><td><pre style="text-align: left;">"tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb%default"</pre></td><td><pre style="text-align: left;">contract unit</pre></td></tr>
</tbody>
</table>



Because we are sending an amount to an implicit account, the expected parameter of the value of type `(contract unit)` is `unit`, so we just need to provide an element of type `unit` to the **`TRANFER_TOKENS`** instruction.  
Note that the three parameters necessary to transfer tokens are now on top of the stack and in the right order:
1. The parameter expected for the address (`unit` for implicit accounts)
2. The amount to be sent in `mutez`
3. The receiver's address converted to a value of type `(contract param)`


```Michelson
TRANSFER_TOKENS ;
DUMP ;
```




<table>
<thead>
<tr><th>value  </th><th>type                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">amount: &#x27;5000000&#x27;
entrypoint: default
kind: transaction
parameters: Unit
target: tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb</pre>        </td><td><pre style="text-align: left;">operation</pre></td></tr>
</tbody>
</table>



Calling the **`TRANSFER_TOKENS`** instruction forges a new operation. Remember that contract executions in Michelson are self-contained: they do not communicate with the outside. The execution goes from its beginning to its end and only then it is possible to send new transactions.  
You can see that the value we now have on top of the stack is of type `operation` and contains all the information we previously added to the stack: the amount to be sent, the entrypoint to call (`default` by default or in case of a transaction to an implicit account), the operation kind, the parameters (`unit` for transactions to implicit accounts) and the target address. The only thing left now is to add this operation to the list of operations returned at the end of the contract.


```Michelson
NIL operation ;
SWAP ;
CONS ;
DUMP ;
```

    NIL: push [];
    SWAP: pop [], <send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>; push []; push <send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>;
    CONS: pop <send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>, []; push ['<send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>'];




<table>
<thead>
<tr><th>value  </th><th>type                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">- amount: &#x27;5000000&#x27;
  entrypoint: default
  kind: transaction
  parameters: Unit
  target: tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb</pre>        </td><td><pre style="text-align: left;">list operation</pre></td></tr>
</tbody>
</table>



Are you excited about finally using that list of operations we have been returning empty so far? 😅  

In order to include the operation into the list of operations, you add an empty list as usual with `NIL operation`, you use **`SWAP`** because the element to add to the list must be just above in the stack and you call the **`CONS`** instruction which prepends the value to the list. Now you can return the pair with the list of operations and the storage:


```Michelson
UNIT ;
SWAP ;
PAIR ;
COMMIT ;
```

    UNIT: push Unit;
    SWAP: pop Unit, ['<send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>']; push Unit; push ['<send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>'];
    PAIR: pop ['<send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>'], Unit; push (['<send 5000000 to tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb>'], Unit);
    COMMIT:




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Unit</pre></td><td><pre style="text-align: left;">unit</pre></td></tr>
</tbody>
</table><br><table>
<thead>
<tr><th>kind                                            </th><th>target                                                                   </th><th>amount                                      </th><th>entrypoint                                  </th><th>parameters                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">transaction</pre></td><td><pre style="text-align: left;">tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb</pre></td><td><pre style="text-align: left;">5000000</pre></td><td><pre style="text-align: left;">default</pre></td><td><pre style="text-align: left;">Unit</pre></td></tr>
</tbody>
</table>



Nothing groundbreaking here, we push a new `unit` on top of the stack, we use **`SWAP`** because the list of operations must be on the left of the pair and then **`PAIR`**.

### Recap

This tutorial has been full of a lot of new information! You learned how to use smart contracts for financial purposes by manipulating values of type `mutez`, accessing different financial values like the amount sent with a transaction or the balance of the contract, protecting the contract funds with more access control features and transferring funds held in the smart contract to an external address. These operations are crucial in the Tezos ecosystem and they must be clearly understood in order to ensure the safety of your smart contracts.

### Exercices

1. Write a smart contract that transfers the amount sent with a transaction to an address of your choice. Make sure the amount is not equal to zero before creating the transaction.


```Michelson
## Write and run your code here
```

<details>
    <summary>Solution (one of the many possible)</summary>
    <p>Copy-paste the solution in the cell above to compile it!</p>
    <br />
    <div>
        storage unit ;<br />
        parameter unit ;<br />
        code {<br />
            &emsp;&emsp;DROP ;<br />
            &emsp;&emsp;PATCH AMOUNT 5670000 ;<br />
            &emsp;&emsp;AMOUNT ;<br />
            &emsp;&emsp;PUSH mutez 0 ;<br />
            &emsp;&emsp;IFCMPEQ<br />
                &emsp;&emsp;&emsp;&emsp;{ FAIL }<br />
                &emsp;&emsp;&emsp;&emsp;{<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;PUSH address "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ;<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;CONTRACT unit ;<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;IF_NONE<br />
                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{ FAIL }<br />
                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;AMOUNT ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;UNIT ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;TRANSFER_TOKENS ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;NIL operation ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SWAP ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;CONS ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;UNIT ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SWAP ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;PAIR<br />
                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;}<br />
                &emsp;&emsp;&emsp;&emsp;}<br />
        } ;<br /><br />
        RUN %default Unit Unit ;
    </div>
</details>

2. Write a smart contract that divides the amount received in half, checks if the contract balance is over 100 tez and send half of the amount to the address saved in the storage (expert level 🤓). As usual, check if the amount is greater than zero before proceeding.


```Michelson
## Write and run your code here
```

<details>
    <summary>Solution (one of the many possible)</summary>
    <p>Copy-paste the solution in the cell above to compile it!</p>
    <p>You can change the value in `PATCH AMOUNT` and `PATCH BALANCE` to see if the contract fails when it is supposed to!</p>
    <br />
    <div>
        storage address ;<br />
        parameter unit ;<br />
        code {<br />
            &emsp;&emsp;PATCH BALANCE 101000000 ;<br />
            &emsp;&emsp;PATCH AMOUNT 9000000 ;<br />
            &emsp;&emsp;CDR ;<br />
            &emsp;&emsp;PUSH mutez 100000000 ;<br />
            &emsp;&emsp;BALANCE ;<br />
            &emsp;&emsp;IFCMPLT<br />
                &emsp;&emsp;&emsp;&emsp;{ PUSH string "INSUFFICIENT_BALANCE" ; FAILWITH }<br />
                &emsp;&emsp;&emsp;&emsp;{<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;PUSH mutez 0 ;<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;AMOUNT ;<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;IFCMPEQ<br />
                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{ PUSH string "INSUFFICIENT_AMOUNT" ; FAILWITH }<br />
                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;PUSH nat 2 ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;AMOUNT ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;EDIV ;<br />
                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;IF_NONE<br />
                                &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{ FAIL }<br />
                                &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{<br />
                                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;CAR ;<br />
                                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;DIP { DUP } ;<br />
                                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SWAP ;<br />
                                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;CONTRACT unit ;<br />
                                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;IF_NONE<br />
                                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{ FAIL }<br />
                                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SWAP ;<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;UNIT ;<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;TRANSFER_TOKENS ;<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;NIL operation ;<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;SWAP ;<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;CONS ;<br />
                                            &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;PAIR<br />
                                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;}<br />
                                &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;}<br />
                        &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;}<br />
                &emsp;&emsp;&emsp;&emsp;}<br />
        } ;<br /><br />
RUN %default Unit "tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb" ;
    </div>
</details>


```Michelson

```
