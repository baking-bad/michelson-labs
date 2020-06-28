
# Michelson tutorial
## Chapter two
This chapter introduces types in Michelson, advanced stack usage and stack protection instructions

##### 1. Types in Michelson

Michelson is a strongly typed language with no type inference, which means that you must always indicate which type you are using to the compiler. The compiler will then check that all the values used in the contract are correctly typed.  
For example, if you write `PUSH int 3 ; PUSH string "hello" ; ADD ;`, the compiler will throw an error as you cannot add an integer and a string together:


```Michelson
## THIS DOESN'T WORK!
storage unit ;
parameter unit ;
code {
    DROP ;
    PUSH int 3 ;
    PUSH string "Hello";
    ADD ;
    NIL operation ;
    PAIR
} ;
RUN %default Unit Unit ;
```

    storage unit;
    parameter unit;
    code { DROP ; PUSH int 3 ; PUSH string "Hello" ; ADD ; NIL operation ; PAIR };
    RUN: use %default; drop all; push (Unit, Unit);
    DROP: pop (Unit, Unit);
    PUSH: push 3;
    PUSH: push Hello;
    ADD: pop Hello, 3;

    MichelsonRuntimeError: unsupported argument types String and Int
    at RUN -> ADD

It is also worth pointing out that the values you use on the stack are immutable, which means that you cannot "modify" them, you must remove them, add them or concatenate them together to change them.

You can find below a list of the most common types in Michelson:
- Core data types:  
  - __int__ (positive and negative numbers) 
  - __nat__ (positive numbers) 
  - __string__ (one or multiple characters) 
  - __bytes__
  - __pair__ (a pair of two values)
  - __bool__ (boolean value)
  - __unit__ (a placeholder type when no value or parameter is required)
  - __option__ (optional value with 2 possible values: _SOME (type)_ and _NONE_)
  - __list__ (a list of ordered values of the same type)
  - __set__ (a list of unordered unique values of the same type)
  - __map__ (a list of key/value pairs)
  - __big_map__ (a lazily deserialized list of key/value pairs, used for large amounts of data)
- Domain specific data types:
  - __timestamp__ (dates in ISO 8601 format)
  - __mutez__ (Tezos tokens type)
  - __address__ (Tezos addresses)
  - __operation__ (internal operation emitted by a contract)
  - __key__ (public cryptographic key)

Some of these types are called [__comparable types__](https://tezos.gitlab.io/whitedoc/michelson.html#full-grammar) which means that the comparison of two values of these types will yield an _integer_ that you can then use to know if they are equal or if one is lower or higher than the other.  
For example, *int*, *nat*, *string*, *bytes*, *mutez*, *bool*, *timestamp* and *address* are all comparable types.  

::: warning NOTE
Be aware of the syntax for types of values that contain other values: for example `(option value)` for option, `(map key value)` for maps, `(pair left_value right_value)` for pairs, etc.
:::

##### 2. Advanced stack usage

It is time to play with the stack!  

In order to manipulate the stack, you are going to use *instructions*. Instructions are generally short words that will create an effect on the stack. For example, you can use an instruction to push another element on top of the stack, an instruction to duplicate an element, an instruction to change the element position, etc.  

We are going to start with simple instructions for simple operations and write a smart contract that accepts a *unit* parameter, has a *string* in the storage and modifies the string in the storage.  

> *Note: we will use the terms "instruction" and "opcode" interchangeably throughout these tutorials. They both refer to the short words used to manipulate the stack in Michelson.*

###### - Inline code


```Michelson
storage string ;
parameter unit ;
code {
    DUP ;
    CAR ;
    SWAP ;
    CDR ;
    PUSH string "world" ;
    SWAP ;
    CONCAT;
    DIP { DROP } ;
    NIL operation ;
    PAIR
}
```

    storage string;
    parameter unit;
    code { DUP ; CAR ; SWAP ; CDR ; PUSH string "world" ; SWAP ; CONCAT ; DIP { DROP } ; NIL operation ; PAIR };


```Michelson
RUN %default Unit "Hello " ;
```

    RUN: use %default; drop all; push (Unit, 'Hello ');
      DUP: push (Unit, 'Hello ');
      CAR: pop (Unit, 'Hello '); push Unit;
      SWAP: pop Unit, (Unit, 'Hello '); push Unit; push (Unit, 'Hello ');
      CDR: pop (Unit, 'Hello '); push Hello ;
      PUSH: push world;
      SWAP: pop world, Hello ; push world; push Hello ;
      CONCAT: pop Hello ; pop world; push Hello world;
      DIP: protect 1 item(s);
        DROP: pop Unit;
        restore 1 item(s);
      NIL: push [];
      PAIR: pop [], Hello world; push ([], 'Hello world');




<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello world"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



###### - Step-by-step execution

Every Michelson contract starts with two lines that indicate the type of the storage and the parameter.  

For this example, we want to create a storage that will keep a string and a parameter that will receive a unit:


```Michelson
storage string ;
parameter unit ;
```

    storage string;
    parameter unit;

We start the step-by-step execution by initializing the storage of the smart contract and the received parameter:


```Michelson
BEGIN Unit "Hello " ;
```




<table>
<thead>
<tr><th>value                                                  </th><th>type                                                 </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair Unit "Hello "</pre></td><td><pre style="text-align: left;">pair unit string</pre></td></tr>
</tbody>
</table>



The first thing we want to do is duplicating the passed parameter.  

To **dup**licate an element of the stack, we use the **`DUP`** opcode. **`DUP`** takes the element at the top of the stack, copies it and pushes it above.  

*In a real-world example, this would be an extra step that wouldn't be necessary, but the goal here is to showcase different instructions and how they work together :)*


```Michelson
DUP ; DUMP ;
```




<table>
<thead>
<tr><th>value                                                  </th><th>type                                                 </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair Unit "Hello "</pre></td><td><pre style="text-align: left;">pair unit string</pre></td></tr>
<tr><td><pre style="text-align: left;">Pair Unit "Hello "</pre></td><td><pre style="text-align: left;">pair unit string</pre></td></tr>
</tbody>
</table>



The element at the top of the stack is now a `pair`. A pair is a type of value that contains 2 values, one on the left and one on the right. Michelson provides instructions to extract these values so we can manipulate them. The first one is **`CAR`** that takes a pair at the top of the stack and returns the value on the left side. Note that the value on the right is taken out of the stack and lost:


```Michelson
CAR ; DUMP ;
```




<table>
<thead>
<tr><th>value                                                  </th><th>type                                                 </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Unit</pre>              </td><td><pre style="text-align: left;">unit</pre>            </td></tr>
<tr><td><pre style="text-align: left;">Pair Unit "Hello "</pre></td><td><pre style="text-align: left;">pair unit string</pre></td></tr>
</tbody>
</table>



The execution of the contract code always goes from top to bottom, so you may be wondering how to access the pair at the bottom of the stack, if this is the one you want to work with now?  

Fortunately, Michelson provides opcodes to change the order of the elements on the stack. The first one we encounter, **`SWAP`** switches the position of the two elements on top of the stack: the element at index 0 goes to index 1 and the element at index 1 goes to index 0:


```Michelson
SWAP ; DUMP ;
```




<table>
<thead>
<tr><th>value                                                  </th><th>type                                                 </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair Unit "Hello "</pre></td><td><pre style="text-align: left;">pair unit string</pre></td></tr>
<tr><td><pre style="text-align: left;">Unit</pre>              </td><td><pre style="text-align: left;">unit</pre>            </td></tr>
</tbody>
</table>



In the second to last example, we introduced the **`CAR`** instruction which extract the left part of a pair.  

To extract the right part of the element on top of the stack, you can use **`CDR`**. As for **`CAR`**, the left part of the pair will be removed from the stack and lost:


```Michelson
CDR ; DUMP ;
```




<table>
<thead>
<tr><th>value                                        </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello "</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">Unit</pre>    </td><td><pre style="text-align: left;">unit</pre>  </td></tr>
</tbody>
</table>



You can now see above that the stack consists of the string _"Hello "_ and a unit.  

Let's continue and add a string on top of the stack with the **`PUSH`** instruction:


```Michelson
PUSH string "world" ; DUMP ;
```




<table>
<thead>
<tr><th>value                                        </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"world"</pre> </td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">"Hello "</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">Unit</pre>    </td><td><pre style="text-align: left;">unit</pre>  </td></tr>
</tbody>
</table>



We should put the two strings on top of the stack in the right order so we can store _"Hello world"_. We use the **`SWAP`** instruction for that:


```Michelson
SWAP ; DUMP ;
```




<table>
<thead>
<tr><th>value                                        </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello "</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">"world"</pre> </td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">Unit</pre>    </td><td><pre style="text-align: left;">unit</pre>  </td></tr>
</tbody>
</table>



Once in the right order, we want to put the two strings together to write "Hello world".  

Michelson provides an instruction that just does that: **`CONCAT`**. It takes the two strings at the top of the stack, removes them, puts them together and adds a single string back.  

As usual, you must be sure there are two values of type `string` on top of the stack. **`CONCAT`** will not work with integers, booleans, etc. and it will raise an error at compilation time:


```Michelson
CONCAT ; DUMP ;
```




<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello world"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">Unit</pre>         </td><td><pre style="text-align: left;">unit</pre>  </td></tr>
</tbody>
</table>



The next line introduces two important instructions.  

We now have two elements in the stack: a string at *index 0* and a unit at *index 1*. We only want to keep the string and we want to get rid of the unit. We could use **`SWAP`** to put the unit on the top of the stack and remove it, but let's keep things interesting and use another approach.  

Michelson provides an instruction that will bypass the element at the indicated position and work on the element just below. This instruction is **`DIP n`** (*n* being the position of the element to bypass).  

Regarding the positions you may use after **`DIP`**, there are two situations that require a special attention:  
- **`DIP 0`**: This is equivalent to not using the instruction at all (there is no element at the zero position)!
- **`DIP 1`**: This is equivalent to using **`DIP`** without an element position number, it will bypass the first element of the stack and work on the second one.  

The **`DIP`** instruction is followed by a piece of code that will be executed on the element *below* the element that was bypassed. This piece of code is surrounded by curly braces.  

After we bypassed the element in the first position, we want to remove the element at the second position (the *unit*). Michelson provides the **`DROP n`** instruction that just does that: it removes the element at the *n* position. As for **`DIP`**, there are two cases you want to keep in mind:
- **`DROP 0`**: This will fail as you will try to remove an element that doesn't exist (there is nothing at the zero position of the stack).
- **`DROP 1`**: This is equivalent to using **`DROP`** without an element position number, it will simply remove the element at the top of the stack.  

To sum up, the next instruction, `DIP { DROP }`, will bypass the first element of the stack (`DIP`) and remove the following element (`DROP`).


```Michelson
DIP { DROP } ; DUMP ;
```

    DIP: protect 1 item(s);
      DROP: pop Unit;
      restore 1 item(s);




<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello world"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



Now there is a single string in our stack. It is time to wrap things up and return the final pair.  

First, we create an empty list of operations with **`NIL operation`**:


```Michelson
NIL operation ; DUMP ;
```




<table>
<thead>
<tr><th>value                                             </th><th>type                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">[]</pre>           </td><td><pre style="text-align: left;">list operation</pre></td></tr>
<tr><td><pre style="text-align: left;">"Hello world"</pre></td><td><pre style="text-align: left;">string</pre>        </td></tr>
</tbody>
</table>



Then, we put the two elements of the stack in a pair:


```Michelson
PAIR ;
```




<table>
<thead>
<tr><th>value                                                     </th><th>type                                                             </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair {} "Hello world"</pre></td><td><pre style="text-align: left;">pair (list operation) string</pre></td></tr>
</tbody>
</table>



Finally, we use the **`COMMIT`** instruction provided by this Jupyter notebook to return the pair containing the empty list of operations and the new storage:


```Michelson
COMMIT ;
```




<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello world"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



### Exercises:

1. Write a smart contract that puts two new strings in the stack and concatenates them.


```Michelson
## Your code here
```

<details>
    <summary>Solution</summary>
    <p>Copy-paste the solution in the cell above to compile it!</p>
    <br />
    <div>
        storage string ;<br />
        parameter unit ;<br />
        code {<br />
            &emsp;&emsp;DROP ;<br />
            &emsp;&emsp;PUSH string "world!" ;<br />
            &emsp;&emsp;PUSH string "Hello " ;<br />
            &emsp;&emsp;CONCAT ;<br /><br />
            &emsp;&emsp;NIL operation ;<br />
            &emsp;&emsp;PAIR<br />
        };<br />
        RUN %default Unit "nothing" ;
    </div>
</details>

2. Using the **`ADD`** instruction to add two integers together (like **`CONCAT`** concatenates two strings), write a smart contract with an integer in the storage and an integer in the parameter that adds these two values before storing the result in the storage.


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
            &emsp;&emsp;DUP ;<br />
            &emsp;&emsp;CDR ;<br />
            &emsp;&emsp;SWAP ;<br />
            &emsp;&emsp;CAR ;<br />
            &emsp;&emsp;ADD ;<br />
            &emsp;&emsp;NIL operation ;<br />
            &emsp;&emsp;PAIR<br />
            };<br />
            RUN %default 3 4 ;
    </div>
</details>


```Michelson

```
