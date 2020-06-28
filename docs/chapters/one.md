
# Michelson tutorial
## Chapter one
This chapter is an introduction to Michelson smart contracts structure and conventions.

##### 1. Understanding the stack

Michelson is a *low-level* programming language, which means that it doesn't offer all the features of *high-level* programming languages you may be used to, like JavaScript or C++. For example, there are no variables in Michelson. 

Every time you write code in Michelson, you must keep something in mind called "**the stack**". You can imagine the stack as a game of Jenga: it is a collection of elements that you pile up on top of each other, the goal of "Michelson Jenga" being to remove all the pieces except for a specific one that must remain at the end. In order to play, you will be given a list of *instructions* that can manipulate the pieces of the game: you can remove them, change their position, add some more on top, check if two pieces are the same to remove them, etc., but one false move and the stack collapses (which we call *failing*).  

As there are no variables, the position of the elements in the stack is crucial: the instructions you use will operate on the elements according to their positions.

##### 2. Structure of a Smart Contract

A smart contract in Michelson displays a simple structure with 3 parts:
1. A part indicating the type of the storage
2. A part indicating the type of the parameter
3. The code to be executed on incoming transactions 

For every incoming transaction, there will be only one parameter. However, the parameter can be, for example, a pair that contains 2 elements. Likewise, the storage is made of a single variable, which can also be a pair, a map, etc. that contains multiple values.

Here is an example of a very simple smart contract (which doesn't modify its storage):


```Michelson
storage unit ;
parameter unit ;
code {
    DROP ;
    PUSH unit Unit ;
    NIL operation ;
    PAIR
}
```

    storage unit;
    parameter unit;
    code { DROP ; PUSH unit Unit ; NIL operation ; PAIR };

The smart contract removes the pair containing the parameter and the storage from the top of the stack, pushes a unit, an empty list of operation and pair them before returning them.

A smart contract in Michelson always has to return a pair containing a list of operations to be run at the end of the execution and the new storage.

When you are ready to run the smart contract, you can open a new cell and type the following command:


```Michelson
RUN %default Unit Unit ;
```

    RUN: use %default; drop all; push (Unit, Unit);
      DROP: pop (Unit, Unit);
      PUSH: push Unit;
      NIL: push [];
      PAIR: pop [], Unit; push ([], Unit);




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Unit</pre></td><td><pre style="text-align: left;">unit</pre></td></tr>
</tbody>
</table>



**RUN** starts the execution of the smart contract, **%default** targets the default entry point of the smart contract (the only one there is at the moment), the first **Unit** is the parameter and the second **Unit** is the storage.

##### 3. Operation codes

The *code* part of the Michelson contract consists of a serie of instructions that the contract will perform every time it is called. These instructions are run top to bottom and may or may not be followed by parameters. In general, for the operation codes that accept parameters, these parameters indicate the position of the element to manipulate in the stack, the type of value associated to the newly created element or the value itself.  
Note that every instruction ends when a semi-colon is inserted (however, you can omit it for the last instruction (generally `PAIR`).

Let's have a look at the instructions introduced earlier:

**`DROP`**: this instruction gets rid of the first element on top of the stack.

**`PUSH`**: this instruction is the opposite of the `DROP` instruction and adds an element on top of the stack.   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;You must specify the type and the value, for example `PUSH string "hello"` or `PUSH int 3`.

**`NIL`**: like `PUSH`, `NIL` introduces a new element on top of the stack. This element is a list.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;After the opcode, you must specify the type of values the list will contain (lists can only contain one single type).  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;As we need a list of operations to end the execution of the smart contract, we add an empty list of operations.

**`PAIR`**: finally, as the contract is expecting a pair containing a list of instructions and the new storage, we must create this pair.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The `PAIR` opcode takes the two elements on top of the stack and put them together in a pair.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The first one will be in the left position of the pair, the second one in the right position.

##### 4. Running the contract step-by-step

This notebook allows you to run the smart contract step-by-step and visualize the state of the stack at every step!

In order to use this feature, there are 3 instructions you must remember. These instructions are only used in the context of these notebooks and are NOT Michelson instructions:

- **`BEGIN`**: use it to start the execution of the contract. You must also specify the parameter and the storage as in : `BEGIN param storage`.  
- **`DUMP`**: add it to display the current state of the stack.  
- **`COMMIT`**: use it to end the execution of the contract and return the list/storage pair.

Let's rewrite the example above and use these three instructions.  

First, we set up the storage and parameter types:


```Michelson
storage unit ;
parameter unit ;
```

    storage unit;
    parameter unit;

Then, we start the execution of the smart contract with the **`BEGIN`** instruction followed by the parameter and the storage:


```Michelson
BEGIN Unit Unit ;
```




<table>
<thead>
<tr><th>value                                              </th><th>type                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair Unit Unit</pre></td><td><pre style="text-align: left;">pair unit unit</pre></td></tr>
</tbody>
</table>



In this example, we are not going to use the storage or the parameter that are automatically pushed onto the stack at the beginning of the execution.  

The **`DROP`** instruction removes the element on top of the stack. Its syntax will be explained in details in the next chapter:


```Michelson
DROP ;
```

The **`DUMP`** instruction is specific to these Jupyter notebooks (it is not a Michelson instruction) and it will simply print the current state of the stack:


```Michelson
DUMP ; ## The stack is empty now as we removed the only element that was there
```




stack is empty



Next, we are going to insert a new element in the stack.  

The **`PUSH`** instruction pushes a new element on top of the stack. When using it, you must specify the type of the element and its value, for example you can have `PUSH Unit unit`, `PUSH int 3`, `PUSH string "Hello world"`, etc. Make sure the value you choose is of the type you need:


```Michelson
PUSH unit Unit ;
```




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Unit</pre></td><td><pre style="text-align: left;">unit</pre></td></tr>
</tbody>
</table>



Every contract written in Michelson must return a pair value containing two things: a list of operations to be executed when the current execution ends and the new storage.  

In case you don't want to execute any operation at the end of your code, you still have to return an empty list of transactions. This is what **`NIL operation`** does. It pushes an empty list of the type mentioned after `NIL` on top of the stack:


```Michelson
NIL operation ;
```




<table>
<thead>
<tr><th>value                                  </th><th>type                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">[]</pre></td><td><pre style="text-align: left;">list operation</pre></td></tr>
</tbody>
</table>




```Michelson
DUMP ;
```




<table>
<thead>
<tr><th>value                                    </th><th>type                                               </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">[]</pre>  </td><td><pre style="text-align: left;">list operation</pre></td></tr>
<tr><td><pre style="text-align: left;">Unit</pre></td><td><pre style="text-align: left;">unit</pre>          </td></tr>
</tbody>
</table>



As mentioned above, our smart contract must return a pair containing a list and the storage. We now have these two elements in the stack, so we can use the **`PAIR`** instruction to put them together in a pair. Please note that the order of the elements is important: the one in first position will be the left value in the newly created pair, the one in second position will be the right value:


```Michelson
PAIR ;
```




<table>
<thead>
<tr><th>value                                            </th><th>type                                                           </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair {} Unit</pre></td><td><pre style="text-align: left;">pair (list operation) unit</pre></td></tr>
</tbody>
</table>



After the pair is created, we can manually end the execution of the contract using the Jupyter notebook specific instruction **`COMMIT`**:


```Michelson
COMMIT ;
```




<table>
<thead>
<tr><th>value                                    </th><th>type                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Unit</pre></td><td><pre style="text-align: left;">unit</pre></td></tr>
</tbody>
</table>



### Exercice
Write a smart contract in the cell below that saves a new string into the storage:


```Michelson
## Your code here
```

<details>
    <summary>Solution</summary>
    <p>Copy-paste the solution in the cell above to compile it!</p>
    <br />
    <div>
        storage string ;
        parameter unit ;
        code {
            DROP ;
            PUSH string "Welcome to the Michelson tutorials :)" ;
            NIL operation ;
            PAIR
        };
        RUN %default Unit "nothing" ;
    </div>
</details>
