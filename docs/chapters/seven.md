
# Michelson tutorial
## Chapter seven

This new chapter will be the occasion to work a little more in-depth with two data types that are pretty important on a smart contract: strings and lists.

In most projects that you will work on, you will probably have to manipulate strings. Whether you want to save some data provided by your users or compare inputs, strings are an essential component of smart contracts. Unlike other smart contract languages whose developers have been asking for these features for years (for example Solidity), Michelson offers string manipulation functions out of the box. Although still limited compared to other lhigh level languages, these functions will still provide enough flexibility to get the job done.

Once you have strings in your smart contract, what about storing them somewhere? Lists could be the perfect place to put them! Michelson offers different possibilities in terms of storage for multiple pieces of data and lists are one of them. Before choosing a list for your needs, you must know more about what make them different and how they work. This will have no more secret for you at the end of this tutorial!

- string type
- _CONCAT_, _SLICE_, _SIZE_, _COMPARE_
- list type
- *CONS*, *NIL*, *IF_CONS*, *SIZE*

##### 1. Strings and string manipulations

We have already worked with strings in the previous chapters, so you should already be familiar with this type. Strings are a series of characters delimited by double-quotes and including only the characters present in the English alphabet (and the escape character in [certain circumstances](https://tezos.gitlab.io/whitedoc/michelson.html#constants)). Strings are comparable values that can be added to contract from different sources: they can come from the parameter, the storage or the **`PUSH`** instruction.

Once the string is present in the stack, you can work with it!  
First, you can check the length of the string with the **`SIZE`** opcode:


```Michelson
storage nat ;
parameter string ;
code {
    CAR ;
    SIZE ;
    NIL operation ;
    PAIR
};

RUN %default "tezos" 0;
```

    storage nat;
    parameter string;
    code { CAR ; SIZE ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('tezos', 0);
    CAR: pop ('tezos', 0); push tezos;
    SIZE: pop tezos; push 5;
    NIL: push [];
    PAIR: pop [], 5; push ([], 5);




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">5</pre></td><td><pre style="text-align: left;">nat</pre></td></tr>
</tbody>
</table>



As expected, the length of the string *"Tezos"* is `5`. Note that the length is returned as a `nat` because negative length are not possible.  
Knowing the length of a string can be useful if you want to limit the size of the strings savec into your contract. Let's write an example that will reject string parameters if their length exceeds `5`:


```Michelson
storage string ;
parameter string ;
code {
    CAR ;
    DUP ;
    SIZE ;
    PUSH nat 5 ;
    IFCMPLT
        { FAIL }
        {
            NIL operation ;
            PAIR
        }
} ;

RUN %default "tezos" "" ;
```

    storage string;
    parameter string;
    code { CAR ; DUP ; SIZE ; PUSH nat 5 ; { { COMPARE ; LT } ; IF { { UNIT ; FAILWITH } } { NIL operation ; PAIR } } };
    RUN: use %default; drop all; push ('tezos', '');
    CAR: pop ('tezos', ''); push tezos;
    DUP: push tezos;
    SIZE: pop tezos; push 5;
    PUSH: push 5;
    COMPARE: pop 5, 5; push 0;
    LT: pop 0; push False;
    IF: pop False;
    NIL: push [];
    PAIR: pop [], tezos; push ([], 'tezos');




<table>
<thead>
<tr><th>value                                       </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"tezos"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



If you add another character to "tezos", you will see the contract fail 😊

One of the most common actions on strings is concatenation. Michelson provides an instruction that allows you to put two separate strings together: **`CONCAT`**. This is how it works:


```Michelson
storage string ;
parameter string ;
code {
    CAR ;
    PUSH string "Hello " ;
    CONCAT ;
    NIL operation ;
    PAIR
} ;

RUN %default "Tezos" "" ;
```

    storage string;
    parameter string;
    code { CAR ; PUSH string "Hello " ; CONCAT ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('Tezos', '');
    CAR: pop ('Tezos', ''); push Tezos;
    PUSH: push Hello ;
    CONCAT: pop Hello ; pop Tezos; push Hello Tezos;
    NIL: push [];
    PAIR: pop [], Hello Tezos; push ([], 'Hello Tezos');




<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello Tezos"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



This smart contract does a very simple thing: it takes a string as a parameter and put it together with "Hello " before saving it in the storage. When using **`CONCAT`**, just make sure you have two strings on top of the stack and that they are in the right order, the element 1 will be the first one in the new string and element 2 will be the second one.

If you want to concatenate multiple strings, you just have to add them to the stack and concatenate the **`CONCAT`** instructions!


```Michelson
storage string ;
parameter string ;
code {
    CAR ;
    PUSH string "Tezos " ;
    PUSH string "Hello " ;
    CONCAT ;
    CONCAT ;
    NIL operation ;
    PAIR
} ;

RUN %default "World" "" ;
```

    storage string;
    parameter string;
    code { CAR ; PUSH string "Tezos " ; PUSH string "Hello " ; CONCAT ; CONCAT ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('World', '');
    CAR: pop ('World', ''); push World;
    PUSH: push Tezos ;
    PUSH: push Hello ;
    CONCAT: pop Hello ; pop Tezos ; push Hello Tezos ;
    CONCAT: pop Hello Tezos ; pop World; push Hello Tezos World;
    NIL: push [];
    PAIR: pop [], Hello Tezos World; push ([], 'Hello Tezos World');




<table>
<thead>
<tr><th>value                                                   </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello Tezos World"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



The opposite action is **`SLICE`**: instead of putting two strings together, we are cutting one in pieces! This instruction takes three parameters: the starting point for the slice, the character length you want to slice and the string. Let's observe a few examples:


```Michelson
storage unit ;
parameter unit ;
BEGIN Unit Unit ;
DROP ;
## Pushes a string and extract the first 6 characters
PUSH @string_to_slice string "BakingBad" ;
PUSH @length nat 6 ; ## length
PUSH @offset nat 0 ; ## offset
DUMP ;
```

    storage unit;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, Unit);
    DROP: pop (Unit, Unit);
    PUSH: push BakingBad;
    PUSH: push 6;
    PUSH: push 0;




<table>
<thead>
<tr><th>value                                           </th><th>type                                       </th><th>name                                                 </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre>          </td><td><pre style="text-align: left;">nat</pre>   </td><td><pre style="text-align: left;">@offset</pre>         </td></tr>
<tr><td><pre style="text-align: left;">6</pre>          </td><td><pre style="text-align: left;">nat</pre>   </td><td><pre style="text-align: left;">@length</pre>         </td></tr>
<tr><td><pre style="text-align: left;">"BakingBad"</pre></td><td><pre style="text-align: left;">string</pre></td><td><pre style="text-align: left;">@string_to_slice</pre></td></tr>
</tbody>
</table>



This is how the stack looks like before the slicing begins...


```Michelson
SLICE ;
```




<table>
<thead>
<tr><th>value                                             </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some "Baking"</pre></td><td><pre style="text-align: left;">option string</pre></td></tr>
</tbody>
</table>



You probably notice that the result of **`SLICE`** is wrapped in an `option` value. If the offset or the length you set go beyond the bounds of the string, the opcode returns `None`:


```Michelson
DROP ;
PUSH string "BakingBad" ;
PUSH nat 6 ; ## length
PUSH nat 6 ; ## offset
SLICE ;
```

    DROP: pop ('Baking',);
    PUSH: push BakingBad;
    PUSH: push 6;
    PUSH: push 6;
    SLICE: pop 6, 6, BakingBad; push None;




<table>
<thead>
<tr><th>value                                    </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">None</pre></td><td><pre style="text-align: left;">option string</pre></td></tr>
</tbody>
</table>



Obviously, you are not limited to extract slices of strings from the first character, you can start at whichever position you like, keeping in mind the bounds of the string:


```Michelson
DROP ;
PUSH string "BakingBadIsAwesome" ;
PUSH nat 7 ; ## length
PUSH nat 11 ; ## offset
SLICE ;
```

    DROP: pop None;
    PUSH: push BakingBadIsAwesome;
    PUSH: push 7;
    PUSH: push 11;
    SLICE: pop 11, 7, BakingBadIsAwesome; push ('Awesome',);




<table>
<thead>
<tr><th>value                                              </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some "Awesome"</pre></td><td><pre style="text-align: left;">option string</pre></td></tr>
</tbody>
</table>



Slicing a string in two pieces is going to ask for a little extra work but it is totally possible. Here is how to do it:


```Michelson
DROP ;
PUSH string "BakingBadIsAwesome" ; ## Push the string to slice in two
DUP ; ## Duplicate the string
PUSH nat 9 ; ## The length of the first piece
PUSH nat 0 ; ## The offset of the first piece
SLICE ; ## Extract the first piece of the string
SWAP ; ## Get the duplicated original string on top of the stack
PUSH nat 9 ; ## The lenght of the second piece
PUSH nat 9 ; ## The offset of the second piece
SLICE ; ## Extract the second piece of the string
SWAP ; ## Put the pieces in the right order
DUMP ;
```

    DROP: pop ('Awesome',);
    PUSH: push BakingBadIsAwesome;
    DUP: push BakingBadIsAwesome;
    PUSH: push 9;
    PUSH: push 0;
    SLICE: pop 0, 9, BakingBadIsAwesome; push ('BakingBad',);
    SWAP: pop ('BakingBad',), BakingBadIsAwesome; push ('BakingBad',); push BakingBadIsAwesome;
    PUSH: push 9;
    PUSH: push 9;
    SLICE: pop 9, 9, BakingBadIsAwesome; push ('IsAwesome',);
    SWAP: pop ('IsAwesome',), ('BakingBad',); push ('IsAwesome',); push ('BakingBad',);




<table>
<thead>
<tr><th>value                                                </th><th>type                                              </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some "BakingBad"</pre></td><td><pre style="text-align: left;">option string</pre></td></tr>
<tr><td><pre style="text-align: left;">Some "IsAwesome"</pre></td><td><pre style="text-align: left;">option string</pre></td></tr>
</tbody>
</table>



The last instruction in our tool box for strings in Michelson is **`COMPARE`**. As it does it for other types, the instruction compares two strings. You can then use it with the usual macros to check if two strings are the same or are different:


```Michelson
DROP_ALL ;
PUSH string "tezos" ;
PUSH string "tezos" ;
CMPEQ @first_example ;
PUSH string "bakingbad" ;
PUSH string "BakingBad" ;
CMPEQ @second_example ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push tezos;
    PUSH: push tezos;
    COMPARE: pop tezos, tezos; push 0;
    EQ: pop 0; push True;
    PUSH: push bakingbad;
    PUSH: push BakingBad;
    COMPARE: pop BakingBad, bakingbad; push -1;
    EQ: pop -1; push False;




<table>
<thead>
<tr><th>value                                     </th><th>type                                     </th><th>name                                                </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">False</pre></td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@second_example</pre></td></tr>
<tr><td><pre style="text-align: left;">True</pre> </td><td><pre style="text-align: left;">bool</pre></td><td><pre style="text-align: left;">@first_example</pre> </td></tr>
</tbody>
</table>



As you can see, **`COMPARE`** is case-sensitive, so it is very important to verify this won't produce false negative results.

##### 2. Working with lists

After manipulating strings, you may want to save them in the storage of the smart contract. Michelson offers different solutions for that, for example sets and maps, but you may prefer a *list*. A list is a special structure that contains different values of the same type. One of its characteristics is that a list is *immutable*, meaning that when you want to add an element to a list, you actually create a new list made of the new element in the first position (which we call the *head*) and the elements of the previous list starting at the second position (the previous list is called the *tail*). Lists are also ordered, which means that their elements are in a specific order.

You probably remember how to create an empty list from the contracts we already wrote so far, with `NIL "type"`. The **`NIL`** instruction creates a new empty list that will accept elements of the type you specified. For example, **`NIL operation`** is a list that accepts elements of type `operation`. Once you created an empty list, you can easily add an element with the **`CONS`** instruction. First, you push the element onto the stack, next to the list before using **`CONS`**:


```Michelson
storage (list string) ;
parameter string ;
code {
    CAR ;
    NIL string ;
    SWAP ;
    CONS ;
    NIL operation ;
    PAIR ;
} ;

RUN %default "tezos" {};
```

    storage (list string);
    parameter string;
    code { CAR ; NIL string ; SWAP ; CONS ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('tezos', []);
    CAR: pop ('tezos', []); push tezos;
    NIL: push [];
    SWAP: pop [], tezos; push []; push tezos;
    CONS: pop tezos, []; push ['tezos'];
    NIL: push [];
    PAIR: pop [], ['tezos']; push ([], ['tezos']);




<table>
<thead>
<tr><th>value                                           </th><th>type                                            </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ "tezos" }</pre></td><td><pre style="text-align: left;">list string</pre></td></tr>
</tbody>
</table>



If you wish, you can also push an existing list onto the stack like so:


```Michelson
storage (list string) ;
parameter string ;
code {
    PUSH (list string) {"baking"; "bad"} ;
    NIL operation ;
    PAIR ;
} ;

RUN %default "tezos" {};
```

    storage (list string);
    parameter string;
    code { PUSH (list string) { "baking" ; "bad" } ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('tezos', []);
    PUSH: push ['baking', 'bad'];
    NIL: push [];
    PAIR: pop [], ['baking', 'bad']; push ([], ['baking', 'bad']);




<table>
<thead>
<tr><th>value                                                    </th><th>type                                            </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ "baking" ; "bad" }</pre></td><td><pre style="text-align: left;">list string</pre></td></tr>
</tbody>
</table>



After the list has been added to the stack, you can add new elements at the beginning (*the head*):


```Michelson
storage (list string) ;
parameter string ;
code {
    CAR;
    PUSH (list string) {"baking"; "bad"} ;
    SWAP ;
    CONS ;
    NIL operation ;
    PAIR ;
} ;

RUN %default "tezos" {};
```

    storage (list string);
    parameter string;
    code { CAR ; PUSH (list string) { "baking" ; "bad" } ; SWAP ; CONS ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('tezos', []);
    CAR: pop ('tezos', []); push tezos;
    PUSH: push ['baking', 'bad'];
    SWAP: pop ['baking', 'bad'], tezos; push ['baking', 'bad']; push tezos;
    CONS: pop tezos, ['baking', 'bad']; push ['tezos', 'baking', 'bad'];
    NIL: push [];
    PAIR: pop [], ['tezos', 'baking', 'bad']; push ([], ['tezos', 'baking', 'bad']);




<table>
<thead>
<tr><th>value                                                              </th><th>type                                            </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ "tezos" ; "baking" ; "bad" }</pre></td><td><pre style="text-align: left;">list string</pre></td></tr>
</tbody>
</table>



Sometimes, you may want to check a list and implement different behaviors if the list is empty or not. In this case, you can use **`IF_CONS`** which verifies if there is a head to the provided list. Like the other **`IF`** instructions, you need to create two branches, the first one will be executed if **`IF_CONS`** returns `true` and the second one will be executed if it returns `false`:


```Michelson
storage (list string) ;
parameter string ;
code {
    DUP ;
    CAR ;
    SWAP ;
    CDR ;
    IF_CONS
        { FAIL }
        { NIL string ; SWAP ; CONS } ;
    NIL operation ;
    PAIR ;
} ;

RUN %default "tezos" {} ;
## RUN %default "tezos" { "test" } ;
```

    storage (list string);
    parameter string;
    code { DUP ; CAR ; SWAP ; CDR ; IF_CONS { { UNIT ; FAILWITH } } { NIL string ; SWAP ; CONS } ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ('tezos', []);
    DUP: push ('tezos', []);
    CAR: pop ('tezos', []); push tezos;
    SWAP: pop tezos, ('tezos', []); push tezos; push ('tezos', []);
    CDR: pop ('tezos', []); push [];
    IF_CONS: pop [];
    NIL: push [];
    SWAP: pop [], tezos; push []; push tezos;
    CONS: pop tezos, []; push ['tezos'];
    NIL: push [];
    PAIR: pop [], ['tezos']; push ([], ['tezos']);




<table>
<thead>
<tr><th>value                                           </th><th>type                                            </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ "tezos" }</pre></td><td><pre style="text-align: left;">list string</pre></td></tr>
</tbody>
</table>



Be careful as **`IF_CONS`** is going to remove the list you are checking. You should duplicate it with **`DUP`** first or if you are checking for an empty string like in this example, you can just push another empty string.  
If you comment the first `RUN` and comment out the second, you will see the expected behavior of the contract as it fails when the list in the storage is not empty.

Another useful instruction to check lists is **`SIZE`** which returns the number of elements in a list as a `nat` (as usual, the number of elements cannot be negative):


```Michelson
storage nat ;
parameter (list int) ;
code {
    CAR ;
    SIZE ;
    NIL operation ;
    PAIR ;
} ;

RUN %default { 7 ; 4 ; 6 } 0 ;
```

    storage nat;
    parameter (list int);
    code { CAR ; SIZE ; NIL operation ; PAIR };
    RUN: use %default; drop all; push ([7, 4, 6], 0);
    CAR: pop ([7, 4, 6], 0); push [7, 4, 6];
    SIZE: pop [7, 4, 6]; push 3;
    NIL: push [];
    PAIR: pop [], 3; push ([], 3);




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">3</pre></td><td><pre style="text-align: left;">nat</pre></td></tr>
</tbody>
</table>



This is a very simple contract that saves in its storage the length of a list. Try to add or remove elements in the list to see it work 😊

One of the powers of list is that they are *iterable*, it means that you can go through the elements one by one, either to check them or modify them. Michelson offers two instructions to loop through lists: **`ITER`** and **`MAP`**. Although they work in a very similar way, they yield very different results. Let's start with **`ITER`**. One of the best ways to understand what it does is to see it in action:


```Michelson
storage int ;
parameter (list int) ;
BEGIN { 7 ; 9 ; 3 } 0;
CAR ; DUMP ;
```

    storage int;
    parameter (list int);
    BEGIN: use %default; drop all; push ([7, 9, 3], 0);
    CAR: pop ([7, 9, 3], 0); push [7, 9, 3];




<table>
<thead>
<tr><th>value                                             </th><th>type                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ 7 ; 9 ; 3 }</pre></td><td><pre style="text-align: left;">list int</pre></td></tr>
</tbody>
</table>



This part is simple, we create a new contract and use a list of `int` as a parameter before extracting the list and putting it on top of the stack. Now comes **`ITER`**:


```Michelson
ITER {} ;
DUMP ;
```




<table>
<thead>
<tr><th>value                                 </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">3</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
<tr><td><pre style="text-align: left;">9</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
<tr><td><pre style="text-align: left;">7</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



In its simplest form, **`ITER`** only takes a *body expression* (the two curly braces) and runs every element of the list against the code inside the curly braces. The first element is pushed onto the stack and the instructions inside the curly braces are run as usual. When there are no more instructions to run, **`ITER`** pushes the second element of the list onto the stack, runs the instructions, and so on until the end of the list.

To demonstrate it, we could take each element of the list and add `2` to it:


```Michelson
DROP_ALL ;
PUSH (list int) { 7 ; 9 ; 3 } ;
ITER { PUSH int 2 ; ADD } ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push [7, 9, 3];
    ITER: pop [7, 9, 3]; push 7;
      PUSH: push 2;
      ADD: pop 2, 7; push 9;
      push 9;
      PUSH: push 2;
      ADD: pop 2, 9; push 11;
      push 3;
      PUSH: push 2;
      ADD: pop 2, 3; push 5;




<table>
<thead>
<tr><th>value                                  </th><th>type                                    </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">5</pre> </td><td><pre style="text-align: left;">int</pre></td></tr>
<tr><td><pre style="text-align: left;">11</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
<tr><td><pre style="text-align: left;">9</pre> </td><td><pre style="text-align: left;">int</pre></td></tr>
</tbody>
</table>



First observation from this code snippet, **`ITER`** removes the list from the stack. Make sure to duplicate it if you need it later.  
Next, the elements present in the stack are indeed the values from the list + `2` for each value. Remember that the first value in the list will be the last one in the iteration. Here is another example:


```Michelson
DROP_ALL ;
PUSH (list string) { "John" ; "Amir" ; "Stella" } ;
ITER { PUSH string "Hello " ; CONCAT } ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push ['John', 'Amir', 'Stella'];
    ITER: pop ['John', 'Amir', 'Stella']; push John;
      PUSH: push Hello ;
      CONCAT: pop Hello ; pop John; push Hello John;
      push Amir;
      PUSH: push Hello ;
      CONCAT: pop Hello ; pop Amir; push Hello Amir;
      push Stella;
      PUSH: push Hello ;
      CONCAT: pop Hello ; pop Stella; push Hello Stella;




<table>
<thead>
<tr><th>value                                              </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello Stella"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">"Hello Amir"</pre>  </td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">"Hello John"</pre>  </td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



This is how you can greet all the people in a list! **`ITER`** goes through the list, takes the elements one by one and adds "Hello " in front of each name. You can add the level of complexity you want in the body expression (we'll keep that for the exercices!)

The second iterative instruction is **`MAP`**. It works in a very similar fashion: you write a body expression next to the instruction with the instructions you want to apply to the elements of the list. However, this time, **`MAP`** is going to return a new list!

To observe clearly the difference between these two instruction, let's get our first example and replace **`ITER`** with **`MAP`**:


```Michelson
DROP_ALL ;
PUSH (list int) { 7 ; 9 ; 3 } ;
MAP { PUSH int 2 ; ADD } ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push [7, 9, 3];
    MAP: pop [7, 9, 3]; push 7;
      PUSH: push 2;
      ADD: pop 2, 7; push 9;
      pop 9; push 9;
      PUSH: push 2;
      ADD: pop 2, 9; push 11;
      pop 11; push 3;
      PUSH: push 2;
      ADD: pop 2, 3; push 5;
      pop 5; push [9, 11, 5];




<table>
<thead>
<tr><th>value                                              </th><th>type                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ 9 ; 11 ; 5 }</pre></td><td><pre style="text-align: left;">list int</pre></td></tr>
</tbody>
</table>



As you can see, instead of having all the updated elements of the list one on top of the other in the stack, we have a single list where all the elements are in the same order as the previous one and are the result of the previous element value + `2`.

As you can imagine, this is a powerful feature, it allows you to update a list of values in the same exact way. We can go even further with the pattern and apply a conditional to it. For example, you can ask the contract to increase the value in the list only if it is above a certain value:


```Michelson
DROP_ALL ;
PUSH (list int) { 7 ; 9 ; 3 ; 4 ; 2 } ;
MAP {
        DUP ;
        PUSH int 4 ;
        SWAP ;
        IFCMPGT
            { PUSH int 2 ; ADD }
            {}
} ;
DUMP ;
```

    DROP_ALL: drop all;
    PUSH: push [7, 9, 3, 4, 2];
    MAP: pop [7, 9, 3, 4, 2]; push 7;
      DUP: push 7;
      PUSH: push 4;
      SWAP: pop 4, 7; push 4; push 7;
      COMPARE: pop 7, 4; push 1;
      GT: pop 1; push True;
      IF: pop True;
        PUSH: push 2;
        ADD: pop 2, 7; push 9;
      pop 9; push 9;
      DUP: push 9;
      PUSH: push 4;
      SWAP: pop 4, 9; push 4; push 9;
      COMPARE: pop 9, 4; push 1;
      GT: pop 1; push True;
      IF: pop True;
        PUSH: push 2;
        ADD: pop 2, 9; push 11;
      pop 11; push 3;
      DUP: push 3;
      PUSH: push 4;
      SWAP: pop 4, 3; push 4; push 3;
      COMPARE: pop 3, 4; push -1;
      GT: pop -1; push False;
      IF: pop False;
      pop 3; push 4;
      DUP: push 4;
      PUSH: push 4;
      SWAP: pop 4, 4; push 4; push 4;
      COMPARE: pop 4, 4; push 0;
      GT: pop 0; push False;
      IF: pop False;
      pop 4; push 2;
      DUP: push 2;
      PUSH: push 4;
      SWAP: pop 4, 2; push 4; push 2;
      COMPARE: pop 2, 4; push -1;
      GT: pop -1; push False;
      IF: pop False;
      pop 2; push [9, 11, 3, 4, 2];




<table>
<thead>
<tr><th>value                                                      </th><th>type                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">{ 9 ; 11 ; 3 ; 4 ; 2 }</pre></td><td><pre style="text-align: left;">list int</pre></td></tr>
</tbody>
</table>



Don't let the long list of operations scare you, what happens under the hood is actually quite simple!  
First, we add a new list of `int` on top of the stack. Then, we loop through it using the **`MAP`** instruction. At the beginning of each iteration, the **`MAP`** instruction pushes the current value on the stack. We duplicate it (because we will need this value later if the comparison yields `true`), we push `4` onto the stack for the comparison and we swap the position of the list value and the comparison element to put them in the right order. **`IFCMPGT`** checks if the top element is greater than the element below. If `true`, we push `2` and add it to the number remaining on the stack. Otherwise, the value from the list is pushed into the new list with no change.

### Exercises

1. Write a contract that receives a list of strings and creates a new list with the strings whose size is less or equal to 5 characters and replaces the longer strings with an "X". Store the new list into the storage.


```Michelson
## Write your code here
```

<details>
    <summary>Solution</summary>
    <p>Copy-paste the solution in the cell above to compile it!</p>
    <br />
    <div>
        storage (list string) ;<br />
        parameter (list string) ;<br />
        code {<br />
            &emsp;&emsp;CAR ;<br />
            &emsp;&emsp;MAP {<br />
                &emsp;&emsp;&emsp;&emsp;DUP ;<br />
                &emsp;&emsp;&emsp;&emsp;SIZE ;<br />
                &emsp;&emsp;&emsp;&emsp;PUSH nat 5 ;<br />
                &emsp;&emsp;&emsp;&emsp;IFCMPGE<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{}<br />
                    &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;{ PUSH string "X" }<br />
            &emsp;&emsp;&emsp;&emsp;} ;<br />
            &emsp;&emsp;&emsp;&emsp;NIL operation ;<br />
            &emsp;&emsp;&emsp;&emsp;PAIR<br />
        } ;<br /><br />
        RUN %default { "tezos" ; "bakingbad" ; "taco" ; "crypto" } {} ;
    </div>
</details>


```Michelson

```
