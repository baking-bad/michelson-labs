
# Michelson tutorial
## Chapter four  

Among all operations that you can execute in a smart contract, arithmetic operations are probably the most common ones, but also the simplest ones. After all, computers in general were created to provide an easy way to do arithmetic operations that started to become too complex.  

Within your smart contract, you may want to add or subtract tokens to the balance of your users or you may want to multiply or divide different values. As you will understand it when reading what follows, it will be extremely easy in Michelson. You only have two conditions to remember before trying any operation: first, you must make sure that you have two elements on top of the stack. Second, you must verify that these two elements are of comparable types and of types that work together.  

Unlike programming languages that you may already be familiar with, Michelson doesn't use arithmetic operators you know like **+**, **-**, __*__ or **/**. Everything is "instruction-based" and you will have to use instructions that modify the stack to make operations.

##### 1. Available types for arithmetic operations

As you may have already guessed, Michelson allows us to work with `int` and `nat` for arithmetic operations. An operation of two `int` will yield an `int` and an operation of two`nat` will yield a `nat`. These two types can be used together for addition, subtraction, multiplication and division but as long there is an `int` in your operation, the result will also be an `int`. For example, `int + nat = int`.  

In addition to `int` and `nat`, you can use other types for arithmetic operations, for example `mutez` and `timestamp`. Here is a table that sums up all the possible combinations and the type of the result:  

| Value type 	| Available operation 	| Value type 	| Result type 	|
|:----------:	|:-------------------:	|:----------:	|:-----------:	|
|     int    	|   ADD/SUB/MUL/EDIV  	|     int    	|     int     	|
|     nat    	|   ADD/SUB/MUL/EDIV  	|     nat    	|     nat     	|
|     int    	|   ADD/SUB/MUL/EDIV  	|     nat    	|     int     	|
|  timestamp 	|       ADD/SUB       	|     int    	|  timestamp  	|
|  timestamp 	|         SUB         	|  timestamp 	|     int     	|
|    mutez   	|       ADD/SUB       	|    mutez   	|    mutez    	|
|    mutez   	|       MUL/EDIV      	|     nat    	|    mutez    	|

A few considerations to keep in mind regarding the table above:  
- Be always very mindful about the return type when you put `int` and `nat` together. You may spend some time scratching your head and wondering why you are not getting the type you are expecting because you overlooked the types you are using in your operation.
- A few operations are available for types outside of `int` and `nat`, but they are somehow limited (for logical reasons). For example, it wouldn't make any sense to multiply timestamps with other values or multiply `mutez` together.
- Other limitations are set in place for safety purposes: limiting the possible operations on `mutez` prevents negative balances or integer overflow.

##### 2. The **`ADD`** instruction

The first instruction we are going to play with is the **`ADD`** instruction. As its name suggests, it takes two values and add them together. If you refer to the table above, you can observe that it is one of the most widely available instruction throughout the different types. **`ADD`** also allows you to use different types of values, keeping in mind that the return type is always fix.  

Let's check some examples and see how it works:


```Michelson
## We quickly initialize a contract environment to manipulate different values on the stack
storage unit ;
parameter unit ;
BEGIN Unit Unit ;
DROP ;
```

    storage unit;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, Unit);
    DROP: pop (Unit, Unit);

In this first example, we push 2 `int` on to the stack and add them.  
As you can see, the return value is of type `int` and is the result of `5 + 5`.


```Michelson
PUSH int 5 ;
PUSH int 5 ;
ADD ;
```

    PUSH: push 5;
    PUSH: push 5;
    ADD: pop 5, 5; push 10;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">10</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



Now we have a value of type `int` on top of the stack. Let's push a value of type `nat` and see what happens:


```Michelson
PUSH nat 5 ;
ADD ;
```

    PUSH: push 5;
    ADD: pop 5, 10; push 15;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">15</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



As expected, `int 10 + nat 5` equals `int 15`. The addition of `int` and `nat` always yields an `int` (*for logical reasons, the result of something like `int -20 + nat 5` cannot be a `nat` value*).  

In the next snippet, you will see a new instruction, **`NOW`**. We will come back to it in a later chapter, just know for now that it pushes the current timestamp on top of the stack. We can then use the timestamp to demonstrate how **`ADD`** works with values of this type:


```Michelson
NOW ;
ADD ;
```

    NOW: push 1592111017;
    ADD: pop 1592111017, 15; push 1592111032;




<table>
<thead>
<tr><th>value                                          </th><th>type                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1592111032</pre></td><td><pre style="text-align: left;">timestamp</pre></td></tr>
</tbody>
</table>



According to the day and time you are running this code block, the timestamp will be different. However, you should clearly see that the initial value has been incremented with `15`, which was the value we had in our stack when we pushed the timestamp. You can also push a value and add it to the existing timestamp:


```Michelson
PUSH int 500 ;
ADD ;
```

    PUSH: push 500;
    ADD: pop 500, 1592111032; push 1592111532;




<table>
<thead>
<tr><th>value                                          </th><th>type                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1592111532</pre></td><td><pre style="text-align: left;">timestamp</pre></td></tr>
</tbody>
</table>



Let's clean our stack and see how adding `mutez` together works. As in the previous examples, we just push two values on top of the stack and add them. This yields a result in `mutez`:


```Michelson
DROP ;
PUSH mutez 50 ;
PUSH mutez 20 ;
ADD ;
```

    DROP: pop 1592111532;
    PUSH: push 50;
    PUSH: push 20;
    ADD: pop 20, 50; push 70;




<table>
<thead>
<tr><th>value                                  </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">70</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



Keep in mind that `mutez` values are NOT tezzies but a *representation* of their value. When writing `PUSH mutez 50`, you are not manipulating tezzies, only their representation. There are specific instructions we will study later that tell the contract to send actual tezzies.

##### 3. The **`SUB`** instruction

After adding different amounts comes a time when you have to subtract 😅 The **`SUB`** instruction works very similarly to the **`ADD`** instruction outside of a few exceptions we are going to study here.  

First, let's start with a simple example:


```Michelson
DROP ; ## let's start with a clean stack
PUSH int 3 ;
PUSH int 5 ;
SUB ;
```

    DROP: pop 70;
    PUSH: push 3;
    PUSH: push 5;
    SUB: pop 5, 3; push 2;




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">2</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



In this example, you can see that we push `3` to the stack, then `5` before subtracting `3` from `5`.  
In a subtraction, the order of the elements is essential, this is why you have to remember the right order of the elements in the stack: `5 - 3` is not going to yield the same result as `3 - 5`!  
Let's see what would happen if we push the values in the reverse order:


```Michelson
DROP ;
PUSH int 5 ;
PUSH int 3 ;
SUB ;
```

    DROP: pop 2;
    PUSH: push 5;
    PUSH: push 3;
    SUB: pop 3, 5; push -2;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">-2</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



As you can see, you get now `-2`. This may be what you want, as integers can have negative values.  

**`SUB`** is going to work a little differently for `nat` values:


```Michelson
DROP ;
PUSH nat 5 ;
PUSH nat 3 ;
SUB @first_value ;
PUSH nat 3 ;
PUSH nat 5 ;
SUB @second_value ;
DUMP ;
```

    DROP: pop -2;
    PUSH: push 5;
    PUSH: push 3;
    SUB: pop 3, 5; push -2;
    PUSH: push 3;
    PUSH: push 5;
    SUB: pop 5, 3; push 2;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th><th>name                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">2</pre> </td><td><pre style="text-align: left;">int</pre></td><td><pre style="text-align: left;">@second_value</pre></td></tr>
<tr><td><pre style="text-align: left;">-2</pre></td><td><pre style="text-align: left;">int</pre></td><td><pre style="text-align: left;">@first_value</pre> </td></tr>
</tbody>
</table>



Something very interesting happens here, can you spot it? We started with `nat` values and we end up with `int` values! The result of the subtraction of 2 `nat` values is always an `int` as there is a possibility for a negative number. Now, an `int` value may not be what you want. Maybe you are updating a `nat` value in your storage and you need a `nat` value to put it back in the storage. In this case, you can use the **`ABS`** instruction. **`ABS`** turns an `int` value into a `nat` value. As usual, make sure that the top element of the stack is of type `int` before using it:


```Michelson
ABS @second_value ;
SWAP ;
ABS @first_value ;
DUMP ;
```

    ABS: pop 2; push 2;
    SWAP: pop 2, -2; push 2; push -2;
    ABS: pop -2; push 2;




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th><th>name                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">2</pre></td><td><pre style="text-align: left;">nat</pre></td><td><pre style="text-align: left;">@first_value</pre> </td></tr>
<tr><td><pre style="text-align: left;">2</pre></td><td><pre style="text-align: left;">nat</pre></td><td><pre style="text-align: left;">@second_value</pre></td></tr>
</tbody>
</table>



You can also use **`SUB`** with timestamps. In this case, you can only subtract `int` values from timestamps that represent the number of seconds to subtract, for example:


```Michelson
DROP_ALL ; ## DROP_ALL is a non-Michelson instruction used in these notebooks to reset the stack to zero
PUSH int 100 ;
NOW ;
SUB ;
```

    DROP_ALL: drop all;
    PUSH: push 100;
    NOW: push 1592111022;
    SUB: pop 1592111022, 100; push 1592110922;




<table>
<thead>
<tr><th>value                                          </th><th>type                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1592110922</pre></td><td><pre style="text-align: left;">timestamp</pre></td></tr>
</tbody>
</table>



In the steps of the execution, you can observe that the current timestamp is pushed onto the stack before `100` is subtracted from it.  
If you wish, you can also subtract one timestamp from another to get the difference in seconds between both of them:


```Michelson
DROP ;
PUSH int 100 ;
NOW ;
SUB ;
NOW ;
SUB ;
```

    DROP: pop 1592110922;
    PUSH: push 100;
    NOW: push 1592111024;
    SUB: pop 1592111024, 100; push 1592110924;
    NOW: push 1592111024;
    SUB: pop 1592111024, 1592110924; push 100;




<table>
<thead>
<tr><th>value                                   </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">100</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



In a first time, we push `int 100` onto the stack, then the current timestamp and we subtract `100` from the timestamp. Next, we push another timestamp onto the stack and subtract the first created timestamp from the second one. The result should be `100` because the operation is so fast the timestamp doesn't really have time to update the second time we push it.  

As you would expect, it is also possible to subtract mutez from one another to get the difference between the two amounts:


```Michelson
DROP ;
PUSH mutez 25 ;
PUSH mutez 50 ;
SUB ;
```

    DROP: pop 100;
    PUSH: push 25;
    PUSH: push 50;
    SUB: pop 50, 25; push 25;




<table>
<thead>
<tr><th>value                                  </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">25</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



Once again, be careful of the order you push the elements onto the stack, for safety purposes, negative amounts of `mutez` are not allowed and the contract will fail if it happens:


```Michelson
DROP ;
PUSH mutez 50 ;
PUSH mutez 25 ;
SUB ;
```

    DROP: pop 25;
    PUSH: push 50;
    PUSH: push 25;
    SUB: pop 25, 50;

    MichelsonRuntimeError: expected non-negative val
    at SUB

##### 4. The **`MUL`** instruction

Multiplications are far less common throughout Michelson types than addition or subtraction. For timestamps, they just don't make sense. For `mutez`, they are possible only under a certain condition. You can use it for `int` and `nat` values. The syntax is the same as addition and subtraction and this time, you can relax about the order of the elements 😊


```Michelson
DROP ;
PUSH int 5 ;
PUSH int 4 ;
MUL ;
```

    DROP: pop 25;
    PUSH: push 5;
    PUSH: push 4;
    MUL: pop 4, 5; push 20;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">20</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>




```Michelson
DROP ;
PUSH nat 3 ;
PUSH nat 10 ;
MUL ;
```

    DROP: pop 20;
    PUSH: push 3;
    PUSH: push 10;
    MUL: pop 10, 3; push 30;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">30</pre></td><td><pre style="text-align: left;">nat</pre></td></tr>
</tbody>
</table>



As it is also the case for addition and subtraction, the multiplication of `int` and `nat` values together yields a new `int`:


```Michelson
DROP ;
PUSH int 5 ;
PUSH nat 3 ;
MUL ;
```

    DROP: pop 30;
    PUSH: push 5;
    PUSH: push 3;
    MUL: pop 3, 5; push 15;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">15</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



Finally, you can multiply `mutez` values with `nat` values:


```Michelson
DROP ;
PUSH mutez 500 ;
PUSH nat 5 ;
MUL ;
```

    DROP: pop 15;
    PUSH: push 500;
    PUSH: push 5;
    MUL: pop 5, 500; push 2500;




<table>
<thead>
<tr><th>value                                    </th><th>type                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">2500</pre></td><td><pre style="text-align: left;">mutez</pre></td></tr>
</tbody>
</table>



##### 5. The **`EDIV`** instruction

Division in Michelson is a little more technical than the other arithmetic operations and requires more explanation.  

Michelson performs what is called a [Euclidean division](https://en.wikipedia.org/wiki/Euclidean_division), hence the **E**(uclidean)**DIV**(ision) name. In a nutshell, a Euclidean division divides two numbers together and returns a result (formally known as the *quotient*) and a *remainder* (there are no float numbers in Michelson). If there is a pizza with 9 slices and 4 people who want pizza, a Euclidean division of the pizza will distribute 2 slices to everyone (total 8 slices) with 1 slice left.  

Keeping in mind this example, let's observe how the division and its result would look like in Michelson:


```Michelson
DROP ;
PUSH int 4 ;
PUSH int 9 ;
EDIV ;
```

    DROP: pop 2500;
    PUSH: push 4;
    PUSH: push 9;
    EDIV: pop 9, 4; push ((2, 1),);




<table>
<thead>
<tr><th>value                                               </th><th>type                                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some (Pair 2 1)</pre></td><td><pre style="text-align: left;">option (pair int nat)</pre></td></tr>
</tbody>
</table>



Now that's a surprise! The other arithmetic operations above only yield numbers but this one gives us a pretty complex result back! The result of **`EDIV`** is an option that contains a pair with the quotient (the result of the division) on the left and the remainder on the right. The quotient is of type `int` and the remainder is of type `nat` (unsurprisingly, the remainder cannot be a negative number).

Outside of `int` and `nat`, you can use **`EDIV`** with `mutez` values, only if the divisor is of type `nat`:


```Michelson
DROP ;
PUSH nat 5 ;
PUSH mutez 500 ;
EDIV ;
```

    DROP: pop ((2, 1),);
    PUSH: push 5;
    PUSH: push 500;
    EDIV: pop 500, 5; push ((100, 0),);




<table>
<thead>
<tr><th>value                                                 </th><th>type                                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some (Pair 100 0)</pre></td><td><pre style="text-align: left;">option (pair mutez mutez)</pre></td></tr>
</tbody>
</table>



The example above is also great to demonstrate that the pair result can contain a `0` as the remainder of the division.

##### 6. Other operations on numeric values

Outside of arithmetic operations, you can use other operations to manipulate numeric values in Michelson. We've already talked about **`ABS`** earlier that turns an `int` value into a `nat`. Here is a refresher:


```Michelson
DROP ;
PUSH int 5 ;
ABS ;
PUSH int -6 ;
ABS ;
DUMP ;
```

    DROP: pop ((100, 0),);
    PUSH: push 5;
    ABS: pop 5; push 5;
    PUSH: push -6;
    ABS: pop -6; push 6;




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">6</pre></td><td><pre style="text-align: left;">nat</pre></td></tr>
<tr><td><pre style="text-align: left;">5</pre></td><td><pre style="text-align: left;">nat</pre></td></tr>
</tbody>
</table>



You can use **`NEG`** to turn a positive value into a negative one. The result will logically be an `int` even if the value you give is a `nat`:


```Michelson
DROP_ALL ;
PUSH int 5 ;
NEG ;
PUSH nat 5 ;
NEG ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push 5;
    NEG: pop 5; push -5;
    PUSH: push 5;
    NEG: pop 5; push -5;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">-5</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
<tr><td><pre style="text-align: left;">-5</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



Sometimes, you may want to flip the type of a number from `nat` to `int` the same way **`ABS`** turns an `int` into a `nat`. In this case, you can use the **`INT`** instruction:  
::: warning NOTE
you may have noticed by now that Michelson is case-sensitive, writing `int` and `INT` is completely different, as is writing `pair`, `Pair` and `PAIR`. Types are always written in lowercase (`pair`), values are written with their first character uppercase (`Pair`) and instructions are all uppercase (`PAIR`).
:::


```Michelson
DROP_ALL ;
PUSH nat 5 ;
INT ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push 5;
    INT: pop 5; push 5;




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">5</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



Michelson offers also a practical shortcut to check if an `int` is positive and turn it into a `nat`: **`ISNAT`**. The instruction takes a value of type `int` and returns `None` if the `int` is less than `0` or `(Some nat)` if the `int` is greater than `0`:


```Michelson
DROP ;
PUSH int 5 ;
ISNAT ;
PUSH int -4 ;
ISNAT ;
DUMP ;
```

    DROP: pop 5;
    PUSH: push 5;
    ISNAT: pop 5; push (5,);
    PUSH: push -4;
    ISNAT: pop -4; push None;




<table>
<thead>
<tr><th>value                                      </th><th>type                                           </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">None</pre>  </td><td><pre style="text-align: left;">option nat</pre></td></tr>
<tr><td><pre style="text-align: left;">Some 5</pre></td><td><pre style="text-align: left;">option nat</pre></td></tr>
</tbody>
</table>



### Exercises:

1. Write a series of 4 arithmetic operations that use the value returned by the previous operation:


```Michelson
## Your code here
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
            &emsp;&emsp;PUSH int 50 ;<br />
            &emsp;&emsp;PUSH nat 40 ;<br />
            &emsp;&emsp;ADD ;<br />
            &emsp;&emsp;PUSH int 10 ;<br />
            &emsp;&emsp;SUB ;<br />
            &emsp;&emsp;ABS ;<br />
            &emsp;&emsp;PUSH mutez 50 ;<br />
            &emsp;&emsp;MUL ;<br />
            &emsp;&emsp;## The code below is just some cleaning steps to return the contract properly<br />
            &emsp;&emsp;DROP ;<br />
            &emsp;&emsp;UNIT ;<br />
            &emsp;&emsp;NIL operation ;<br />
            &emsp;&emsp;PAIR<br />
        } ;<br />
        RUN %default Unit Unit ;
    </div>
</details>

2. Using instructions from this tutorial and the previous one, devise a smart contract that divides two numbers, fails in case of a division by zero and saves the quotient in the storage otherwise:


```Michelson
## Your code here
```

<details>
    <summary>Solution</summary>
    <p>Copy-paste the solution in the cell above to compile it!</p>
    <br />
    <div>
        storage int ;<br />
        parameter int ;<br />
        code {<br />
            &emsp;&emsp;CAR ;<br />
            &emsp;&emsp;PUSH int 2 ;<br />
            &emsp;&emsp;EDIV ;<br />
            &emsp;&emsp;IF_NONE<br />
                &emsp;&emsp;&emsp;&emsp;{ FAIL }<br />
                &emsp;&emsp;&emsp;&emsp;{ CDR ; INT } ;<br />
            &emsp;&emsp;NIL operation ;<br />
            &emsp;&emsp;PAIR ;<br />
        } ;<br />
        RUN %default 6 0;
    </div>
</details>
