
# Michelson tutorial
## Chapter three
This chapter introduces conditional structures, fail operators and some useful macros to use in your Michelson code.

It is always crucial in your smart contracts to compare values with each other. You may want to make sure that your users send the values your contract is expecting, that a value exists, that the amount sent by your users is sufficient or that the initiator of the transaction has the right to access some part of your code.  

Like a lot of other languages, Michelson offers conditional structures that will allow you to compare values together and execute code depending on the result of the comparison of these values.  

As you may expect, the instructions involved in these comparisons will look a lot like what you will find in high-level programming languages, with some very specific constraints and considerations due to the low-level nature of Michelson.  

In this chapter, we are not going to write a full functional smart contract but manipulate the stack by sending instructions. You will notice that some code snippets start with the **`DROP`** instruction which function will simply be to remove the element created by the previous instruction from the stack and start with a clean stack. It is not involved in the functionalities that are presented.  

As usual, let's declare the storage and parameter type and initialize the smart contract:


```Michelson
storage int ;
parameter int ;
```

    storage int;
    parameter int;


```Michelson
BEGIN 3 4 ;
```




<table>
<thead>
<tr><th>value                                        </th><th>type                                             </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair 3 4</pre></td><td><pre style="text-align: left;">pair int int</pre></td></tr>
</tbody>
</table>



Now it's time to play with our stack!  
The following line is more of a refresher about basic instructions to extract the parameter and the storage.  
Notice the keyword after **`CAR`** and **`CDR`**? It is an *annotation*, you can use it to track different values in the stack and see how they move:


```Michelson
DUP ; CAR @param ; SWAP ; CDR @storage ; DUMP ;
```

    DUP: push (3, 4);
    CAR: pop (3, 4); push 3;
    SWAP: pop 3, (3, 4); push 3; push (3, 4);
    CDR: pop (3, 4); push 4;




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th><th>name                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">4</pre></td><td><pre style="text-align: left;">int</pre></td><td><pre style="text-align: left;">@storage</pre></td></tr>
<tr><td><pre style="text-align: left;">3</pre></td><td><pre style="text-align: left;">int</pre></td><td><pre style="text-align: left;">@param</pre>  </td></tr>
</tbody>
</table>



Let's introduce our first comparison instruction!  
**`COMPARE`** is an instruction that compares numeric values (integer or natural numbers) and returns a value between -1 and 1. This is how it works:
1. **`COMPARE`** takes the two elements currently at the top out of the stack. These two elements **must** be both of a comparable type.
2. The two elements are compared against each other. The comparison will yield one of the three values below:
    - If the two elements are equal, the result is `int 0`.
    - If the first element is greater than the second one, the result is `int 1`.
    - If the second element is greater than the first one, the result is `int -1`.
3. The result is pushed onto the stack.  

Observe the effect of **`COMPARE`** below. After the instruction is run, the two integer values that were in the stack are gone and an element of type `int` containing the value `1` is present (`1` indicates that `4` is greater than `3`, which is the case):


```Michelson
COMPARE ; DUMP ;
```




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



In the next snippet, we clean up our stack to start from fresh!  
Let's check what happens when the values we used above are reversed. Remember that the values are stacked one above the other, so pushing `4` then `3` means that `4` is the second element and `3` the first:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 3 ; COMPARE ;
```

    DROP: pop 1;
    PUSH: push 4;
    PUSH: push 3;
    COMPARE: pop 3, 4; push -1;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">-1</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



The result is `-1`, which indicates that the first element is less than the second one.  

Now, you may be wondering: "getting `1`, `0` or `-1` from the comparison is cool, but what to do with that value?" This is exactly what we are going to see! We can use the value returned by **`COMPARE`** and get a boolean value out of it.  
The **`EQ`** instruction checks the value on top of the stack. If the value is equal to `int 0`, **`EQ`** returns `true`. Otherwise, it returns `false`. This is exactly what we need to verify whether our two values are equal or not:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 3 ;
COMPARE ; EQ ;
```

    DROP: pop -1;
    PUSH: push 4;
    PUSH: push 3;
    COMPARE: pop 3, 4; push -1;
    EQ: pop -1; push False;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



Let's detail the different steps of the code snippet above:  
1. We add an element on top of the stack of type `int` with the value `4`.
2. We add another element on top of the previous one of type `int` with the value `3`.
3. We use the **`COMPARE`** instruction. It removes the two elements on the stack. `3` is less than `4`, so **`COMPARE`** returns `int -1` and pushes this new value on our empty stack.
4. **`EQ`** checks the first (and only) element in the stack. It is not equal to `0`, so it returns false.

Now let's see what happens if we use two equal values:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 4 ;
COMPARE ; EQ ;
```

    DROP: pop False;
    PUSH: push 4;
    PUSH: push 4;
    COMPARE: pop 4, 4; push 0;
    EQ: pop 0; push True;




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">True</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



As expected, **`COMPARE`** returns `0` because the two values are identical and **`EQ`** turns the `0` in the stack into the boolean value `true`.  

What about checking if the two values are NOT equal? There is an instruction for that too! You can use **`NEQ`** in the same way to return `false` if the two values are equal or `true` if they are not equal:


```Michelson
DROP ;
PUSH int 3 ; PUSH int 4 ;
COMPARE ; NEQ ;
```

    DROP: pop True;
    PUSH: push 3;
    PUSH: push 4;
    COMPARE: pop 4, 3; push 1;
    NEQ: pop 1; push True;




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">True</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



There are a few other instructions you can use like **`EQ`** or **`NEQ`** to check the value returned by **`COMPARE`**:
1. **`LT`**: checks if the value is less than `0`, **`COMPARE`** returns `-1` if the first element is less than the second, using **`LT`** will return `true` if **`COMPARE`** returns `-1`.
2. **`GT`**: checks if the value is greater than `0`, **`COMPARE`** returns `1` if the first element is greater than the second, using **`GT`** will return `true` if **`COMPARE`** returns `1`.
3. **`LE`**: checks if the value is equal or less than `0`, **`COMPARE`** returns `0` or `-1` if the first element is equal or less than the second, using **`LE`** will return `true` if **`COMPARE`** returns `0` or `-1`.
4. **`GE`**: checks if the value is equal or greater than `0`, **`COMPARE`** returns `0` or `1` if the first element is equal or greater than the second, using **`GE`** will return `true` if **`COMPARE`** returns `0` or `1`.  

Writing two instructions one after the other and remembering that **`COMPARE`** will return `-1`, `0` or `1` that you can then use with another instruction can seem a bit tedious. Michelson knows you want to do more and write less, so it provides useful macros that group instructions together in one single instruction 😉  
For example, instead of writing **`COMPARE ; EQ ;`**, you can use **`CMPEQ`**:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 4 ;
CMPEQ ;
```

    DROP: pop True;
    PUSH: push 4;
    PUSH: push 4;
    COMPARE: pop 4, 4; push 0;
    EQ: pop 0; push True;




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">True</pre></td><td><pre style="text-align: left;">bool</pre></td></tr>
</tbody>
</table>



As you can see, it does exactly the same thing as two code snippets above. You can use any of these macros by using the **`CMP`** prefix followed by one of the instructions listed above: **`CMPEQ`**, **`CMPNEQ`**, **`CMPLT`**, **`CMPGT`**, **`CMPLE`**, **`CMPGE`**.  

Now, let's get things a little further. What about running a piece of code only if a **`CMP{EQ|NEQ|LT|GT|LE|GE}`** instruction returns true or false? In a lot of other programming languages, the **`IF`** keyword is used to check if a condition is met and run code accordingly. This is also the case in Michelson. However, when using **`IF`** in Michelson, you have to keep in mind that you *must* have a boolean value in the top element of the stack. Michelson doesn't take shortcuts and only boolean values evaluate to `true` or `false`.  

Here is an example (remember that we have `true` on top of the stack from the previous example):


```Michelson
IF 
    { PUSH string "Is true" } 
    { PUSH string "Is false"}
```

    IF: pop True;
      PUSH: push Is true;




<table>
<thead>
<tr><th>value                                         </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Is true"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



This is obviously a very naive example, but it showcases well what the **`IF`** instruction does in Michelson: it takes the element of type `bool` from the top of the stack and evaluates it. If the element is `true`, it will execute the code in the first block delimited by curly braces. If the element is `false`, it will execute the code in the second block.  

Here is a full example to follow what happens step-by-step:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 4 ; 
COMPARE ;
EQ ;
IF 
    { PUSH string "It's equal :)" } 
    { PUSH string "It is not equal :("}
```

    DROP: pop Is true;
    PUSH: push 4;
    PUSH: push 4;
    COMPARE: pop 4, 4; push 0;
    EQ: pop 0; push True;
    IF: pop True;
      PUSH: push It's equal :);




<table>
<thead>
<tr><th>value                                               </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"It&#x27;s equal :)"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



Let's detail the magic happening in the code above:
1. **`PUSH int 4 ; PUSH int 4 ;`**: pushes 2 integers with the same value on top of the stack.
2. **`COMPARE`**: checks if the values are equal or not and returns the result as an integer with a value between `-1` and `1`.
3. **`EQ`**: checks the value at the top of the stack and verifies if it is equal to `0`. If it is, it returns `true`, otherwise, it returns `false`.
4. **`IF`**: checks the boolean value on top of the stack and runs specific code accordingly. If the value is `true`, the first block between curly braces is run. If it is `false`, the second one is run.  

You already know by now that Michelson doesn't want you to type a long series of instructions just to check if two integers are of the same value 😜 You remember how it was possible to crush **`COMPARE`** and **`EQ`** together to get **`CMPEQ`**? It is also possible with **`COMPARE`**, **`EQ`** and **`IF`**!  

Let's see how that would work:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 4 ; 
IFCMPEQ 
    { PUSH string "It's equal :)" } 
    { PUSH string "It is not equal :("}
```

    DROP: pop It's equal :);
    PUSH: push 4;
    PUSH: push 4;
    COMPARE: pop 4, 4; push 0;
    EQ: pop 0; push True;
    IF: pop True;
      PUSH: push It's equal :);




<table>
<thead>
<tr><th>value                                               </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"It&#x27;s equal :)"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



You must admit that this is a lot shorter and simpler! After pushing the two integers on top of the stack, we use the **`IFCMPEQ`** instruction to check if the two values are equal and run some code according to the result. You can also use any of the following combinations: **`IFCMP{EQ|NEQ|LT|GT|LE|GE}`**.  

We have been using integers since the beginning to demonstrate how comparisons and conditionals work in Michelson, but you can actually use any comparable type of value. For example, you can also verify whether two strings are the same:


```Michelson
DROP ;
PUSH string "hello world" ; PUSH string "hello world" ; 
IFCMPEQ 
    { PUSH string "It's the same string :)" } 
    { PUSH string "It is not the same string :("}
```

    DROP: pop It's equal :);
    PUSH: push hello world;
    PUSH: push hello world;
    COMPARE: pop hello world, hello world; push 0;
    EQ: pop 0; push True;
    IF: pop True;
      PUSH: push It's the same string :);




<table>
<thead>
<tr><th>value                                                         </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"It&#x27;s the same string :)"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



In a real-world smart contract, you want to protect the data saved into the storage from attackers or from undesirable behaviors. If you create the next big token on Tezos, you must make sure the funds stored in your contract are safe. In some cases, you want a kind of "circuit breaker" that will just abort the current execution of the contract if something unexpected or undesirable happens. This will be the job of the **`FAIL`** instruction.  

Every time your contract will meet a **`FAIL`** instruction, it will drop everything it is doing and go directly to the end. Nothing is returned (more accurately, a `unit` is returned, which is nothing in practice), nothing is changed:


```Michelson
DROP ;
PUSH int 4 ; PUSH int 5 ;
IFCMPEQ
    { PUSH string "Same number!" }
    { FAIL }
```

    DROP: pop It's the same string :);
    PUSH: push 4;
    PUSH: push 5;
    COMPARE: pop 5, 4; push 1;
    EQ: pop 1; push False;
    IF: pop False;
      UNIT: push Unit;
      FAILWITH: pop Unit;

    MichelsonRuntimeError: Unit
    at IF -> FAILWITH

You can see that **`IFCMPEQ`** is going to check whether `4` is equal to `5`. As it is not the case, the second code block will be executed, the one containing **`FAIL`**. The contract raises a `MichelsonRuntimeError` followed by the unit returned after **`FAIL`**. The execution is stopped and nothing happens.  

The **`IF`** instruction allows to check the result of the comparison of two values of the same type. However, in Michelson, we also have a special type of value called an `option`. This value can be `(Some value)` if there is a value or `None` if there is no value. In some cases, you are going to make operations that will push an option on top of the stack. You want then to verify if the option has a value (`Some`) or is empty (`None`).  
To this purpose, you can use a special instruction: **`IF_NONE`**. **`IF_NONE`** takes the top element of the stack out (it must be of type `option` though) and will execute the first code block if the value is equal to `None`. Otherwise, it will exectute the second code block. Note that if the value is equal to `(Some value)`, the `value` between parentheses will be pushed on to the stack.  

Here is what happens if the value on top of the stack is **`None`**:


```Michelson
DROP ;
PUSH (option string) None ;
IF_NONE 
    { PUSH string "No value!" }
    { FAIL }
```

    DROP: pop 4;
    PUSH: push None;
    IF_NONE: pop None;
      PUSH: push No value!;




<table>
<thead>
<tr><th>value                                           </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"No value!"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



Now this is what happens if there is **`(Some value)`** on top of the stack:


```Michelson
DROP ;
PUSH (option string) (Some "hello world") ;
IF_NONE 
    { FAIL }
    { }
```

    DROP: pop No value!;
    PUSH: push ('hello world',);
    IF_NONE: pop ('hello world',); push hello world;




<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"hello world"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



You can now see that the string that was wrapped in the `(Some value)` is at the top of the stack.  

What if I told you that there is another shortcut to check the value present at the top of the stack? The **`ASSERT`** instruction!  
**`ASSERT`** expects a boolean value and under the hood, it is a macro for **`IF { } { FAIL }`**. You probably understand this last code by now: if the boolean value is `true`, the code will just continue its execution. If it is `false`, it will fail and return nothing.  
Here is a simple example:


```Michelson
DROP ;
PUSH bool True ;
ASSERT ;
```

    DROP: pop hello world;
    PUSH: push True;
    IF: pop True;

As you can see, the contract pushes a boolean value equal to `true` on top of the stack. **`ASSERT`** will then check this value and because it is `true`, the contract doesn't fail and continue its execution.  

Now we can take the power of **`ASSERT`** even further and extend its capabilities with other macros. Just like **`IF`**, you can use comparison instructions if you want to use other types but booleans.  
Let's check how **`ASSERT_CMPEQ`** would work:


```Michelson
PUSH int 4 ; PUSH int 5 ;
ASSERT_CMPEQ ;
```

    PUSH: push 4;
    PUSH: push 5;
    COMPARE: pop 5, 4; push 1;
    EQ: pop 1; push False;
    IF: pop False;
      UNIT: push Unit;
      FAILWITH: pop Unit;

    MichelsonRuntimeError: Unit
    at IF -> FAILWITH

The code above pushes two integers on top of the stack, compares them against each other and returns `-1`, `0` or `1`, checks if the returned value is equal to zero or not and returns a boolean value, then finally, checks if the boolean value is `true` or `false`.  

Now if you use two values that are actually equal, you will see no runtime error:


```Michelson
PUSH int 5 ; PUSH int 5 ;
ASSERT_CMPEQ ;
```

    PUSH: push 5;
    PUSH: push 5;
    COMPARE: pop 5, 5; push 0;
    EQ: pop 0; push True;
    IF: pop True;

To finish with this chapter packed with new information, let's see another way of making your contracts fail.  
Until now, we have used the **`FAIL`** instruction. If you remember, it stops everything and returns nothing or more precisely, it returns a unit. Actually, **`FAIL`** is also a macro and replaces `UNIT ; FAILWITH ;`. The **`FAILWITH`** instruction is also going to make your contract fail but it will return whatever value is at the top of the stack at this moment. This can be a good solution if you would like to return an error message!  

Check the example below:


```Michelson
PUSH bool False ;
IF
    { PUSH string "Is true!" }
    { PUSH string "Is false!" ; FAILWITH } ;
DUMP ;
```

    PUSH: push False;
    IF: pop False;
      PUSH: push Is false!;
      FAILWITH: pop Is false!;

    MichelsonRuntimeError: Is false!
    at IF -> FAILWITH

As you can see in the red runtime error box, the error message *Is false!* has been returned instead of *Unit* as it was the case in the previous error messages.  

#### Recap

This chapter was a bit lengthy but it introduces fundamental concepts to write Michelson smart contracts: comparisons, conditions and fails.  
With these tools, you can write safer, more robust and more complex contracts that can analyze the data you feed them, run specific code according to the data they receive and fail if they encounter an unexpected situation. Sure, it seems trivial to compare `5` and `4` or to push `true` before running `IF`, but in a real-life scenario, you may want to compare the balance of your users with their withdrawal request before sending them money or verify if a certain user is allowed to withdraw money from a certain account!


```Michelson

```
