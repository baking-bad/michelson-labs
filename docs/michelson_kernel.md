
# Michelson kernel basics
Welcome, friend! This an ultimate Michelson playground, and in this tutorial, you will learn how to make the most of all available functionality.  
If there are any questions, please ask in our telegram chat https://t.me/baking_bad_chat


```Michelson
PUSH string "Hello, world!"
```




<table>
<thead>
<tr><th>value                                               </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello, world!"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



Michelson kernel is built on top of a custom interpreter which does not typecheck the whole script before execution but at runtime instead. Also, it allows developer to check the stack state at any time and for arbitrary depth.  
This enables a step-by-step coding approach which can save time while learning language or making a prototype or demo.


```Michelson
DROP
```

## Context, stack, and notebook cells
When you start a kernel, a new instance of context is initialized. It stores the Michelson stack, stub values for the blockchain-specific instructions (e.g. `BALANCE` or `SENDER`), big map pool, origination index, and some internal variables.  
This context is shared across all cells. Note, that the cell's position doesn't matter, only the execution order.


```Michelson
BALANCE  # balance is initialized with a default value
```




<table>
<thead>
<tr><th>value                                         </th><th>type                                      </th><th>name                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">257000000</pre></td><td><pre style="text-align: left;">mutez</pre></td><td><pre style="text-align: left;">@balance</pre></td></tr>
</tbody>
</table>



When you execute a cell, messages can appear in the `stdout` and` stderr` streams, as well as the optional result at the end.  
Let's try to execute a sequence of commands:


```Michelson
PUSH mutez 0 ;
IFCMPEQ { FAIL } { PUSH string "We got money!" }
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PUSH: push 0;
COMPARE: pop 0, 257000000; push -1;
EQ: pop -1; push False;
IF: pop False;
  PUSH: push We got money!;</pre>
</div>




<table>
<thead>
<tr><th>value                                               </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"We got money!"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



When there's more than one command a verbose logging is enabled. It can be disabled which will be shown a bit later.  
If the latest command in the sequences pushes an item onto the stack - it will be returned as a result.

### Inspecting the stack


```Michelson
DEBUG False  # we just have disabled the verbose output
```


```Michelson
PUSH (list string) { "a" ; "b" ; "c" } ;
PRINT "{0} is on top of the stack, then goes {1}" ;  # still we can printf anything to stdout
CONCAT @abc
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PRINT: [&#39;a&#39;, &#39;b&#39;, &#39;c&#39;] is on top of the stack, then goes We got money!;</pre>
</div>




<table>
<thead>
<tr><th>value                                     </th><th>type                                       </th><th>name                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"abc"</pre></td><td><pre style="text-align: left;">string</pre></td><td><pre style="text-align: left;">@abc</pre></td></tr>
</tbody>
</table>



Time to inspect the stack, there is `DUMP` helper for that. You can use it with or without depth specified (all elements)


```Michelson
DUMP 2
```




<table>
<thead>
<tr><th>value                                               </th><th>type                                       </th><th>name                                     </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"abc"</pre>          </td><td><pre style="text-align: left;">string</pre></td><td><pre style="text-align: left;">@abc</pre></td></tr>
<tr><td><pre style="text-align: left;">"We got money!"</pre></td><td><pre style="text-align: left;">string</pre></td><td>                                         </td></tr>
</tbody>
</table>




```Michelson
DROP_ALL ; DUMP
```




stack is empty



### Errors
if any instruction in a cell has failed the whole context is rolled back to the previous state. So you don't have to rerun everything from the beginning. Here are a few examples of possible errors:


```Michelson
ADD
```

<div class="stderr">
    <pre><span class="stream-name">stderr</span><br/>MichelsonRuntimeError: got 0 items, requested 2 
at ADD</pre>
</div>


```Michelson
HELLO
```

<div class="stderr">
    <pre><span class="stream-name">stderr</span><br/>MichelsonParserError: unknown primitive HELLO
at line 1, pos 0</pre>
</div>


```Michelson
PUSH mutez 1 ; EQ
```

<div class="stderr">
    <pre><span class="stream-name">stderr</span><br/>MichelsonRuntimeError: expected Int, got Mutez
at EQ</pre>
</div>


```Michelson
DEBUG True  # and we continue to the next topic ^_^
```

## Blockchain-specific instructions
First of all, there are several instructions that in a real environment push some value from the execution context, as `AMOUNT`, `SENDER`, `SOURCE`, `BALANCE`, etc. Here we are detached from any particular chain, but you have an opportunity to patch these values:


```Michelson
PATCH AMOUNT 100500 ; AMOUNT
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PATCH: set AMOUNT=100500;
AMOUNT: push 100500;</pre>
</div>




<table>
<thead>
<tr><th>value                                      </th><th>type                                      </th><th>name                                        </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">100500</pre></td><td><pre style="text-align: left;">mutez</pre></td><td><pre style="text-align: left;">@amount</pre></td></tr>
</tbody>
</table>




```Michelson
PATCH AMOUNT ; AMOUNT  # still have default value 0
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PATCH: unset AMOUNT;
AMOUNT: push 0;</pre>
</div>




<table>
<thead>
<tr><th>value                                 </th><th>type                                      </th><th>name                                        </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">mutez</pre></td><td><pre style="text-align: left;">@amount</pre></td></tr>
</tbody>
</table>



### Internal operations
Despite internal operations will never apply, Michelson kernel tries to emulate the standard behavior as closely as possible.


```Michelson
UNIT;                    # starting storage for contract
AMOUNT;                  # Push the starting balance
NONE key_hash;           # No delegate
CREATE_CONTRACT          # Create the contract
{ parameter unit ;
  storage unit ;
  code { FAIL } };
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>UNIT: push Unit;
AMOUNT: push 0;
NONE: push None;
CREATE_CONTRACT: pop None, 0, Unit; set BALANCE=257000000; push KT1Mjjcb6tmSsLm7Cb3DSQszePjfchPM4Uxm; push &lt;originate KT1Mjjcb6tmSsLm7Cb3DSQszePjfchPM4Uxm&gt;;</pre>
</div>




<table>
<thead>
<tr><th>value  </th><th>type                                          </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">amount: '0'
code: code { { UNIT ; FAILWITH } }
kind: origination
storage: Unit
target: KT1Mjjcb6tmSsLm7Cb3DSQszePjfchPM4Uxm</pre>        </td><td><pre style="text-align: left;">operation</pre></td></tr>
</tbody>
</table>



### Script sections
`parameter`, `storage`, and `code` instructions are supported as well, what they do is basically store the argument in the context.


```Michelson
parameter unit ;
storage string ;
code { DROP ; PUSH string "Hey!"; NIL operation ; PAIR }
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>parameter unit
storage string
code { DROP ; PUSH string &#34;Hey!&#34; ; NIL operation ; PAIR }</pre>
</div>

In order to run this contract with particular parameters and initial storage you can use `RUN` helper:


```Michelson
RUN %default Unit "hi"  # %default is entrypoint
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>RUN: use %default; drop all; push (Unit, &#39;hi&#39;);
  DROP: pop (Unit, &#39;hi&#39;);
  PUSH: push Hey!;
  NIL: push [];
  PAIR: pop [], Hey!; push ([], &#39;Hey!&#39;);</pre>
</div>




<table>
<thead>
<tr><th>value                                      </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hey!"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>



`RUN` returns storage, big map diff (if applicable), and list of internal operations.  
You can also load contract from file or chain via `INCLUDE` helper:


```Michelson
INCLUDE "mainnet:KT1VG2WtYdSWz5E7chTeAdDPZNy2MpP8pTfL"  # can also be a filename
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>INCLUDE: set STORAGE={&#39;prim&#39;: &#39;Pair&#39;, &#39;args&#39;: [{&#39;int&#39;: &#39;4&#39;}, {&#39;prim&#39;: &#39;Unit&#39;}]};
parameter (or
            (or %fund
              (pair :initiate %initiate (address %participant)
                                        (pair %settings
                                          (pair (bytes %hashed_secret) (timestamp %refund_time))
                                          (mutez %payoff)))
              (bytes :hashed_secret %add))
            (or %withdraw (bytes :secret %redeem) (bytes :hashed_secret %refund)))
storage (pair
          (big_map bytes
                   (pair (pair %recipients (address %initiator) (address %participant))
                         (pair %settings (pair (mutez %amount) (timestamp %refund_time))
                                         (mutez %payoff))))
          unit)
code { NIL @operations operation ;
       SWAP ;
       { { DUP ; CAR @% ; DIP { CDR } } ; DIP { { DUP ; CAR @% ; DIP { CDR @% } } } } ;
       DIP { DUP } ;
       IF_LEFT
         { IF_LEFT
             { { { DUP ; CAR @% ; DIP { CDR @% } } } ;
               DUP ;
               CONTRACT @participant unit ;
               { IF_NONE { { UNIT ; FAILWITH } } {} } ;
               DROP ;
               SWAP ;
               { { DUP ; CAR ; DIP { CDR @% } } ; { DUP ; CAR @% ; DIP { CDR @% } } } ;
               DUP ;
               SIZE ;
               PUSH nat 32 ;
               { { COMPARE ; EQ } ; IF {} { { UNIT ; FAILWITH } } } ;
               DIP { DIP { DUP } ;
                     SWAP ;
                     AMOUNT @amount ;
                     SUB ;
                     SENDER ;
                     DUP ;
                     CONTRACT @initiator unit ;
                     { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                     DROP ;
                     DIP { { PAIR ; PAIR } ; SWAP } ;
                     { PAIR ; PAIR } ;
                     SOME @xcat ;
                     SWAP } ;
               DUP ;
               DIP { MEM ; NOT ; { IF {} { { UNIT ; FAILWITH } } } } }
             { DUP ;
               DIP { GET ;
                     { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                     { { DUP ; CAR @% ; DIP { CDR @% } } } ;
                     DIP { { { DUP ; CAR ; DIP { CDR @% } } ; { DUP ; CAR @% ; DIP { CDR @% } } } ;
                           SWAP ;
                           DUP ;
                           NOW ;
                           { { COMPARE ; LT } ; IF {} { { UNIT ; FAILWITH } } } ;
                           SWAP ;
                           AMOUNT @amount ;
                           ADD } ;
                     { DIP { PAIR } ; DIP { PAIR } ; PAIR } ;
                     SOME @xcat } } ;
           UPDATE ;
           PAIR @new_storage ;
           SWAP ;
           PAIR }
         { IF_LEFT
             { DUP ;
               SIZE ;
               PUSH nat 32 ;
               { { COMPARE ; EQ } ; IF {} { { UNIT ; FAILWITH } } } ;
               SHA256 ;
               SHA256 @hash ;
               DUP ;
               DIP { SWAP } ;
               { DIP { DIP { GET ;
                             { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                             DUP ;
                             { { DUP ; CAR @% ; DIP { CDR @% } } } ;
                             CDR @% ;
                             CONTRACT @participant unit ;
                             { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                             SWAP ;
                             { CAR ; CAR @% } ;
                             { DIP { DIP { SENDER ;
                                           CONTRACT @sender unit ;
                                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                                           SWAP ;
                                           CDR @% ;
                                           { { DUP ; CAR ; DIP { CDR @% } } ;
                                             { DUP ; CAR @% ; DIP { CDR @% } } } ;
                                           DROP ;
                                           NOW ;
                                           { { COMPARE ; LT } ; IF {} { { UNIT ; FAILWITH } } } ;
                                           DUP ;
                                           PUSH mutez 0 ;
                                           { COMPARE ;
                                             LT ;
                                             IF
                                               { UNIT ; TRANSFER_TOKENS ; DIP { SWAP } ; CONS }
                                               { DROP ; DROP ; SWAP } } } } } ;
                             UNIT ;
                             TRANSFER_TOKENS } } } }
             { DUP ;
               DIP { GET ;
                     { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                     DUP ;
                     { CAR ; CAR @% } ;
                     CONTRACT @initiator unit ;
                     { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                     SWAP ;
                     CDR ;
                     { { DUP ; CAR ; DIP { CDR @% } } ; { DUP ; CAR @% ; DIP { CDR @% } } } ;
                     SWAP ;
                     NOW ;
                     { { COMPARE ; GE } ; IF {} { { UNIT ; FAILWITH } } } ;
                     ADD ;
                     UNIT ;
                     TRANSFER_TOKENS ;
                     SWAP ;
                     { DIP { DIP { SWAP } } } } } ;
           NONE @none (pair (pair address address) (pair (pair mutez timestamp) mutez)) ;
           SWAP ;
           UPDATE @cleared_map ;
           SWAP ;
           DIP { SWAP ; DIP { PAIR } } ;
           CONS ;
           PAIR } }</pre>
</div>

### Step by step debugging
In case you don't want to execute the whole `code`, you can mark the beginning of the contract by calling `BEGIN` (with the same arguments as `RUN`) and in the end call `COMMIT`:


```Michelson
BEGIN %refund 0xdeadbeef (Pair {} Unit)
```




<table>
<thead>
<tr><th>value                                                              </th><th>type  </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair 0xdeadbeef (Pair -1 Unit)</pre></td><td><pre style="text-align: left;">pair (bytes :hashed_secret %refund)
      (pair
        (big_map bytes
                 (pair (pair %recipients (address %initiator) (address %participant))
                       (pair %settings (pair (mutez %amount) (timestamp %refund_time))
                                       (mutez %payoff))))
        unit)</pre>       </td></tr>
</tbody>
</table>




```Michelson
CDR ; NIL operation ; PAIR ; COMMIT
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>CDR: pop (b&#39;\xde\xad\xbe\xef&#39;, (-1, Unit)); push (-1, Unit);
NIL: push [];
PAIR: pop [], (-1, Unit); push ([], (-1, Unit));
COMMIT:</pre>
</div>




<table>
<thead>
<tr><th>value                                           </th><th>type  </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair 0 Unit</pre></td><td><pre style="text-align: left;">pair
  (big_map bytes
           (pair (pair %recipients (address %initiator) (address %participant))
                 (pair %settings (pair (mutez %amount) (timestamp %refund_time)) (mutez %payoff))))
  unit</pre>       </td></tr>
</tbody>
</table><br><table>
<thead>
<tr><th>big_map                               </th><th>action                                    </th><th>key                                       </th><th>value  </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">alloc</pre></td><td><pre style="text-align: left;">bytes</pre></td><td><pre style="text-align: left;">pair (pair %recipients (address %initiator) (address %participant))
      (pair %settings (pair (mutez %amount) (timestamp %refund_time)) (mutez %payoff))</pre>        </td></tr>
</tbody>
</table>



You can also break the current pseudo-exection by calling `RESET` - it will clear the stack and all the cached big maps:


```Michelson
RESET
```

## Big maps
In the previous example, you might notice that we initialize the storage as an empty map, then it is displayed on the stack as -1, and as a result, it becomes 0.  
This is roughly how big map works in the real world: first, a temporary container is created, and if at the end of the contract execution it's still in use - a new big map is allocated. Basically big map is an integer pointer to a hashtable somewhere in the context.  
In our playground in order to check the big map state, you need to call `BIG_MAP_DIFF` helper.


```Michelson
EMPTY_BIG_MAP string string
```




<table>
<thead>
<tr><th>value                                  </th><th>type                                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">-1</pre></td><td><pre style="text-align: left;">big_map string string</pre></td></tr>
</tbody>
</table>




```Michelson
PUSH string "two";
SOME;
PUSH string "one";
UPDATE
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PUSH: push two;
SOME: pop two; push (&#39;two&#39;,);
PUSH: push one;
UPDATE: pop one, (&#39;two&#39;,), -1; push -1;</pre>
</div>




<table>
<thead>
<tr><th>value                                  </th><th>type                                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">-1</pre></td><td><pre style="text-align: left;">big_map string string</pre></td></tr>
</tbody>
</table>




```Michelson
BIG_MAP_DIFF  # works if the top item contains big maps
```




<table>
<thead>
<tr><th>big_map                               </th><th>action                                     </th><th>key                                        </th><th>value                                      </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">alloc</pre> </td><td><pre style="text-align: left;">string</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">update</pre></td><td><pre style="text-align: left;">"one"</pre> </td><td><pre style="text-align: left;">"two"</pre> </td></tr>
</tbody>
</table>



### Reusing big maps
So far, we have come across `alloc` and` update` actions in big map., but there are also `copy` and `remove` actions. We will need to pass one of the allocated big map pointer to another pseudo-contract:


```Michelson
parameter unit;
storage (big_map int int);
code { CDR ; NIL operation ;PAIR }
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>parameter unit
storage (big_map int int)
code { CDR ; NIL operation ; PAIR }</pre>
</div>


```Michelson
RUN Unit { Elt 1 2 ; Elt 2 3 }
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>RUN: use %default; drop all; push (Unit, -2);
  CDR: pop (Unit, -2); push -2;
  NIL: push [];
  PAIR: pop [], -2; push ([], -2);</pre>
</div>




<table>
<thead>
<tr><th>value                                 </th><th>type                                                </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">big_map int int</pre></td></tr>
</tbody>
</table><br><table>
<thead>
<tr><th>big_map                               </th><th>action                                     </th><th>key                                     </th><th>value                                   </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">alloc</pre> </td><td><pre style="text-align: left;">int</pre></td><td><pre style="text-align: left;">int</pre></td></tr>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">update</pre></td><td><pre style="text-align: left;">1</pre>  </td><td><pre style="text-align: left;">2</pre>  </td></tr>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">update</pre></td><td><pre style="text-align: left;">2</pre>  </td><td><pre style="text-align: left;">3</pre>  </td></tr>
</tbody>
</table>




```Michelson
code { CDR ; PUSH int 5; SOME ; PUSH int 4; UPDATE ; NIL operation ; PAIR }
```


```Michelson
RUN Unit 0  # passing previously allocated big_map #0
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>RUN: use %default; drop all; push (Unit, 0);
  CDR: pop (Unit, 0); push 0;
  PUSH: push 5;
  SOME: pop 5; push (5,);
  PUSH: push 4;
  UPDATE: pop 4, (5,), 0; push 0;
  NIL: push [];
  PAIR: pop [], 0; push ([], 0);</pre>
</div>




<table>
<thead>
<tr><th>value                                 </th><th>type                                                </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">big_map int int</pre></td></tr>
</tbody>
</table><br><table>
<thead>
<tr><th>big_map                               </th><th>action                                     </th><th>key                                   </th><th>value                                 </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">0</pre></td><td><pre style="text-align: left;">update</pre></td><td><pre style="text-align: left;">4</pre></td><td><pre style="text-align: left;">5</pre></td></tr>
</tbody>
</table>



## Accessing on-chain data
Sometimes it is convenient to access the blockchain data right from the notebook. The `RESET` helper has an extra parameter that allows to specify the network we shoudl bind to.


```Michelson
RESET "mainnet"
```


```Michelson
CHAIN_ID ; NOW ; DUMP 2  # Few blockchain-specific instruction will change the behavior
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>CHAIN_ID: push NetXdQprcVkpaWU;
NOW: push 1583536716;</pre>
</div>




<table>
<thead>
<tr><th>value                                                 </th><th>type                                          </th><th>name                                         </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">1583536716</pre>       </td><td><pre style="text-align: left;">timestamp</pre></td><td><pre style="text-align: left;">@now</pre>    </td></tr>
<tr><td><pre style="text-align: left;">"NetXdQprcVkpaWU"</pre></td><td><pre style="text-align: left;">chain_id</pre> </td><td><pre style="text-align: left;">@mainnet</pre></td></tr>
</tbody>
</table>




```Michelson
PUSH address "KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg" ; CONTRACT unit  # also, contract type checking is now working
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PUSH: push KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg;
CONTRACT: pop KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg; entry type mismatch; push None;</pre>
</div>




<table>
<thead>
<tr><th>value                                    </th><th>type                                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">None</pre></td><td><pre style="text-align: left;">option (contract unit)</pre></td></tr>
</tbody>
</table>



### Real big maps
The coolest thing is that now you can access real big maps by a pointer, right from your pseudo-contract.  
If you are loading the contract source from the network, a special variable `Current` is initialized with the current contract storage.


```Michelson
INCLUDE "KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg"
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>INCLUDE: set STORAGE={&#39;prim&#39;: &#39;Pair&#39;, &#39;args&#39;: [{&#39;int&#39;: &#39;9&#39;}, {&#39;prim&#39;: &#39;Pair&#39;, &#39;args&#39;: [{&#39;prim&#39;: &#39;Pair&#39;, &#39;args&#39;: [{&#39;string&#39;: &#39;tz1M9CMEtsXm3QxA7FmMU2Qh7xzsuGXVbcDr&#39;}, [{&#39;prim&#39;: &#39;Elt&#39;, &#39;args&#39;: [{&#39;string&#39;: &#39;By&#39;}, {&#39;string&#39;: &#39;https://SmartPy.io&#39;}]}, {&#39;prim&#39;: &#39;Elt&#39;, &#39;args&#39;: [{&#39;string&#39;: &#39;Help&#39;}, {&#39;string&#39;: &#39;Use Build to define a new game board and Play to make moves&#39;}]}, {&#39;prim&#39;: &#39;Elt&#39;, &#39;args&#39;: [{&#39;string&#39;: &#39;Play at&#39;}, {&#39;string&#39;: &#39;https://smartpy.io/demo/explore.html?address=KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg&#39;}]}, {&#39;prim&#39;: &#39;Elt&#39;, &#39;args&#39;: [{&#39;string&#39;: &#39;SmartPy Template&#39;}, {&#39;string&#39;: &#39;https://smartpy.io/demo/index.html?template=tictactoeFactory.py&#39;}]}]]}, {&#39;prim&#39;: &#39;False&#39;}]}]};
parameter (or
            (or
              (or
                (or
                  (or (pair %build (pair (string %game) (address %player1)) (address %player2))
                      (string %game))
                  (pair %play (pair (pair (string %game) (int %i)) (int %j)) (int %move)))
                (pair %setGameMetaData (pair (string %game) (string %name)) (string %value)))
              (pair %setMetaData (string %name) (string %value)))
            (bool %setPause))
storage (pair
          (big_map string
                   (pair
                     (pair
                       (pair
                         (pair
                           (pair
                             (pair (pair (map %deck int (map int int)) (bool %draw))
                                   (map %metaData string string))
                             (int %nbMoves))
                           (int %nextPlayer))
                         (address %player1))
                       (address %player2))
                     (int %winner)))
          (pair (pair (address %admin) (map %metaData string string)) (bool %paused)))
code { DUP ;
       CDR ;
       SWAP ;
       CAR ;
       IF_LEFT
         { IF_LEFT
             { IF_LEFT
                 { IF_LEFT
                     { IF_LEFT
                         { PAIR ;
                           DUP ;
                           { CDR ; CDR ; CDR } ;
                           NOT ;
                           IF
                             { PUSH bool True }
                             { DUP ; { CDR ; CDR ; CAR ; CAR } ; SENDER ; COMPARE ; EQ } ;
                           IF
                             {}
                             { PUSH string &#34;WrongCondition: (~ self.data.paused) | (sp.sender == self.data.admin)&#34; ;
                               FAILWITH } ;
                           DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR } ;
                           MEM ;
                           NOT ;
                           IF
                             {}
                             { PUSH string &#34;WrongCondition: ~ (params.game in self.data.boards)&#34; ;
                               FAILWITH } ;
                           DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR } ;
                           { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                           CAR ;
                           CDR ;
                           PUSH int 0 ;
                           SWAP ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CDR } ;
                           PUSH int 1 ;
                           PUSH int 0 ;
                           EMPTY_MAP string string ;
                           PUSH bool False ;
                           PUSH (map int (map int int)) { Elt 0 { Elt 0 0 ; Elt 1 0 ; Elt 2 0 } ;
                                   Elt 1 { Elt 0 0 ; Elt 1 0 ; Elt 2 0 } ;
                                   Elt 2 { Elt 0 0 ; Elt 1 0 ; Elt 2 0 } } ;
                           PAIR ;
                           PAIR ;
                           PAIR ;
                           PAIR ;
                           PAIR ;
                           PAIR ;
                           PAIR ;
                           SOME ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           DROP ;
                           NIL operation ;
                           PAIR }
                         { PAIR ;
                           DUP ;
                           { CDR ; CDR ; CAR ; CAR } ;
                           SENDER ;
                           COMPARE ;
                           EQ ;
                           IF
                             {}
                             { PUSH string &#34;WrongCondition: sp.sender == self.data.admin&#34; ; FAILWITH } ;
                           DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           CAR ;
                           NONE (pair
                                  (pair
                                    (pair
                                      (pair
                                        (pair
                                          (pair (pair (map %deck int (map int int)) (bool %draw))
                                                (map %metaData string string))
                                          (int %nbMoves))
                                        (int %nextPlayer))
                                      (address %player1))
                                    (address %player2))
                                  (int %winner)) ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           DROP ;
                           NIL operation ;
                           PAIR } }
                     { PAIR ;
                       DUP ;
                       { CDR ; CDR ; CDR } ;
                       NOT ;
                       IF {} { PUSH string &#34;WrongCondition: ~ self.data.paused&#34; ; FAILWITH } ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 0 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       CDR ;
                       COMPARE ;
                       EQ ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CDR } ;
                           NOT }
                         { PUSH bool False } ;
                       IF
                         {}
                         { PUSH string &#34;WrongCondition: (self.data.boards[params.game].winner == 0) &amp; (~ self.data.boards[params.game].draw)&#34; ;
                           FAILWITH } ;
                       DUP ;
                       CAR ;
                       { CAR ; CAR ; CDR } ;
                       PUSH int 0 ;
                       SWAP ;
                       COMPARE ;
                       GE ;
                       IF
                         { PUSH int 3 ; { DIP { DUP } ; SWAP } ; { CAR ; CAR ; CAR ; CDR } ; COMPARE ; LT }
                         { PUSH bool False } ;
                       IF
                         {}
                         { PUSH string &#34;WrongCondition: (params.i &gt;= 0) &amp; (params.i &lt; 3)&#34; ; FAILWITH } ;
                       DUP ;
                       CAR ;
                       { CAR ; CDR } ;
                       PUSH int 0 ;
                       SWAP ;
                       COMPARE ;
                       GE ;
                       IF
                         { PUSH int 3 ; { DIP { DUP } ; SWAP } ; { CAR ; CAR ; CDR } ; COMPARE ; LT }
                         { PUSH bool False } ;
                       IF
                         {}
                         { PUSH string &#34;WrongCondition: (params.j &gt;= 0) &amp; (params.j &lt; 3)&#34; ; FAILWITH } ;
                       DUP ;
                       { CDR ; CAR } ;
                       { DIP { DUP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CDR } ;
                       { DIP { DUP } ; SWAP } ;
                       { CAR ; CDR } ;
                       COMPARE ;
                       EQ ;
                       IF
                         {}
                         { PUSH string &#34;WrongCondition: params.move == self.data.boards[params.game].nextPlayer&#34; ;
                           FAILWITH } ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 0 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CDR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CDR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       COMPARE ;
                       EQ ;
                       IF
                         {}
                         { PUSH string &#34;WrongCondition: self.data.boards[params.game].deck[params.i][params.j] == 0&#34; ;
                           FAILWITH } ;
                       DUP ;
                       CAR ;
                       CDR ;
                       PUSH int 1 ;
                       COMPARE ;
                       EQ ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CDR } ;
                           SENDER ;
                           COMPARE ;
                           EQ ;
                           IF
                             {}
                             { PUSH string &#34;WrongCondition: sp.sender == self.data.boards[params.game].player1&#34; ;
                               FAILWITH } }
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CDR } ;
                           SENDER ;
                           COMPARE ;
                           EQ ;
                           IF
                             {}
                             { PUSH string &#34;WrongCondition: sp.sender == self.data.boards[params.game].player2&#34; ;
                               FAILWITH } } ;
                       DUP ;
                       CDR ;
                       DUP ;
                       CAR ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       PAIR ;
                       DUP ;
                       DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                       { { DUP ; CAR ; DIP { CDR } } } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                       CAR ;
                       { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                         SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CDR } ;
                       PUSH int 3 ;
                       SUB ;
                       SWAP ;
                       { DUP ;
                         DIP { CAR @%% ;
                               { DUP ;
                                 DIP { CAR @%% ;
                                       { DUP ;
                                         DIP { CAR @%% ; { CAR @%% ; PAIR %@ % } } ;
                                         CDR @%% ;
                                         SWAP ;
                                         PAIR %@ %@ } } ;
                                 CDR @%% ;
                                 SWAP ;
                                 PAIR %@ %@ } } ;
                         CDR @%% ;
                         SWAP ;
                         PAIR %@ %@ } ;
                       SOME ;
                       SWAP ;
                       UPDATE ;
                       SWAP ;
                       CDR ;
                       SWAP ;
                       PAIR ;
                       SWAP ;
                       CAR ;
                       PAIR ;
                       DUP ;
                       CDR ;
                       DUP ;
                       CAR ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       PAIR ;
                       DUP ;
                       DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                       { { DUP ; CAR ; DIP { CDR } } } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       DUP ;
                       { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                       { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                         SWAP } ;
                       { CAR ; CAR ; CAR ; CDR } ;
                       PAIR ;
                       DUP ;
                       DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                       { { DUP ; CAR ; DIP { CDR } } } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { DIP { DIP { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                                           SWAP } ;
                                     SWAP } ;
                               SWAP } ;
                         SWAP } ;
                       { CAR ; CAR ; CDR } ;
                       { DIP { DIP { DIP { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                                                       SWAP } ;
                                                 SWAP } ;
                                           SWAP } ;
                                     SWAP } ;
                               SWAP } ;
                         SWAP } ;
                       { CAR ; CDR } ;
                       SOME ;
                       SWAP ;
                       UPDATE ;
                       SOME ;
                       SWAP ;
                       UPDATE ;
                       SWAP ;
                       { DUP ;
                         DIP { CAR @%% ;
                               { DUP ;
                                 DIP { CAR @%% ;
                                       { DUP ;
                                         DIP { CAR @%% ;
                                               { DUP ;
                                                 DIP { CAR @%% ;
                                                       { DUP ;
                                                         DIP { CAR @%% ;
                                                               { DUP ;
                                                                 DIP { CAR @%% ;
                                                                       { CDR @%% ; SWAP ; PAIR % %@ } } ;
                                                                 CDR @%% ;
                                                                 SWAP ;
                                                                 PAIR %@ %@ } } ;
                                                         CDR @%% ;
                                                         SWAP ;
                                                         PAIR %@ %@ } } ;
                                                 CDR @%% ;
                                                 SWAP ;
                                                 PAIR %@ %@ } } ;
                                         CDR @%% ;
                                         SWAP ;
                                         PAIR %@ %@ } } ;
                                 CDR @%% ;
                                 SWAP ;
                                 PAIR %@ %@ } } ;
                         CDR @%% ;
                         SWAP ;
                         PAIR %@ %@ } ;
                       SOME ;
                       SWAP ;
                       UPDATE ;
                       SWAP ;
                       CDR ;
                       SWAP ;
                       PAIR ;
                       SWAP ;
                       CAR ;
                       PAIR ;
                       DUP ;
                       CDR ;
                       DUP ;
                       CAR ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       PAIR ;
                       DUP ;
                       DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                       { { DUP ; CAR ; DIP { CDR } } } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                       CAR ;
                       PUSH int 1 ;
                       SWAP ;
                       { DIP { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                               SWAP } ;
                         SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CDR } ;
                       ADD ;
                       SWAP ;
                       { DUP ;
                         DIP { CAR @%% ;
                               { DUP ;
                                 DIP { CAR @%% ;
                                       { DUP ;
                                         DIP { CAR @%% ;
                                               { DUP ;
                                                 DIP { CAR @%% ; { CAR @%% ; PAIR %@ % } } ;
                                                 CDR @%% ;
                                                 SWAP ;
                                                 PAIR %@ %@ } } ;
                                         CDR @%% ;
                                         SWAP ;
                                         PAIR %@ %@ } } ;
                                 CDR @%% ;
                                 SWAP ;
                                 PAIR %@ %@ } } ;
                         CDR @%% ;
                         SWAP ;
                         PAIR %@ %@ } ;
                       SOME ;
                       SWAP ;
                       UPDATE ;
                       SWAP ;
                       CDR ;
                       SWAP ;
                       PAIR ;
                       SWAP ;
                       CAR ;
                       PAIR ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 0 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CDR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       PUSH int 0 ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       COMPARE ;
                       NEQ ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 1 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           PAIR ;
                           DUP ;
                           DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                           { { DUP ; CAR ; DIP { CDR } } } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                           CAR ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           SWAP ;
                           CAR ;
                           PAIR ;
                           SOME ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           CAR ;
                           PAIR }
                         {} ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 0 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                       PUSH int 0 ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CDR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       COMPARE ;
                       NEQ ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 1 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           PAIR ;
                           DUP ;
                           DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                           { { DUP ; CAR ; DIP { CDR } } } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                           CAR ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CDR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           SWAP ;
                           CAR ;
                           PAIR ;
                           SOME ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           CAR ;
                           PAIR }
                         {} ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 0 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                       PUSH int 0 ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       PUSH int 0 ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       COMPARE ;
                       NEQ ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 1 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 1 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           PAIR ;
                           DUP ;
                           DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                           { { DUP ; CAR ; DIP { CDR } } } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                           CAR ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           SWAP ;
                           CAR ;
                           PAIR ;
                           SOME ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           CAR ;
                           PAIR }
                         {} ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 0 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                       PUSH int 0 ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       PUSH int 2 ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       COMPARE ;
                       NEQ ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 1 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 1 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           { CDR ; CAR } ;
                           { DIP { DUP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           PAIR ;
                           DUP ;
                           DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                           { { DUP ; CAR ; DIP { CDR } } } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
                           CAR ;
                           { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                             SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           { CAR ; CAR ; CAR ; CAR ; CAR ; CAR ; CAR } ;
                           PUSH int 0 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH int 2 ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           SWAP ;
                           CAR ;
                           PAIR ;
                           SOME ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           CAR ;
                           PAIR }
                         {} ;
                       DUP ;
                       CDR ;
                       CAR ;
                       PUSH int 9 ;
                       SWAP ;
                       { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                       { CAR ; CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CAR ; CAR ; CDR } ;
                       COMPARE ;
                       EQ ;
                       IF
                         { PUSH int 0 ;
                           { DIP { DUP } ; SWAP } ;
                           { CDR ; CAR } ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           CDR ;
                           COMPARE ;
                           EQ }
                         { PUSH bool False } ;
                       IF
                         { DUP ;
                           CDR ;
                           DUP ;
                           CAR ;
                           { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                           { CAR ; CAR ; CAR ; CAR } ;
                           PAIR ;
                           DUP ;
                           DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                           { { DUP ; CAR ; DIP { CDR } } } ;
                           GET ;
                           { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                           PUSH bool True ;
                           SWAP ;
                           { DUP ;
                             DIP { CAR @%% ;
                                   { DUP ;
                                     DIP { CAR @%% ;
                                           { DUP ;
                                             DIP { CAR @%% ;
                                                   { DUP ;
                                                     DIP { CAR @%% ;
                                                           { DUP ;
                                                             DIP { CAR @%% ;
                                                                   { DUP ;
                                                                     DIP { CAR @%% ;
                                                                           { CAR @%% ; PAIR %@ % } } ;
                                                                     CDR @%% ;
                                                                     SWAP ;
                                                                     PAIR %@ %@ } } ;
                                                             CDR @%% ;
                                                             SWAP ;
                                                             PAIR %@ %@ } } ;
                                                     CDR @%% ;
                                                     SWAP ;
                                                     PAIR %@ %@ } } ;
                                             CDR @%% ;
                                             SWAP ;
                                             PAIR %@ %@ } } ;
                                     CDR @%% ;
                                     SWAP ;
                                     PAIR %@ %@ } } ;
                             CDR @%% ;
                             SWAP ;
                             PAIR %@ %@ } ;
                           SOME ;
                           SWAP ;
                           UPDATE ;
                           SWAP ;
                           CDR ;
                           SWAP ;
                           PAIR ;
                           SWAP ;
                           CAR ;
                           PAIR }
                         {} ;
                       CDR ;
                       NIL operation ;
                       PAIR } }
                 { PAIR ;
                   DUP ;
                   { CDR ; CDR ; CAR ; CAR } ;
                   SENDER ;
                   COMPARE ;
                   EQ ;
                   IF
                     { PUSH bool True }
                     { DUP ;
                       { CDR ; CAR } ;
                       { DIP { DUP } ; SWAP } ;
                       { CAR ; CAR ; CAR } ;
                       GET ;
                       { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                       { CAR ; CAR ; CDR } ;
                       SENDER ;
                       COMPARE ;
                       EQ } ;
                   IF
                     {}
                     { PUSH string &#34;WrongCondition: (sp.sender == self.data.admin) | (sp.sender == self.data.boards[params.game].player1)&#34; ;
                       FAILWITH } ;
                   DUP ;
                   CDR ;
                   DUP ;
                   CAR ;
                   { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
                   { CAR ; CAR ; CAR } ;
                   PAIR ;
                   DUP ;
                   DIP { { { DUP ; CAR ; DIP { CDR } } } } ;
                   { { DUP ; CAR ; DIP { CDR } } } ;
                   GET ;
                   { IF_NONE { { UNIT ; FAILWITH } } {} } ;
                   DUP ;
                   { CAR ; CAR ; CAR ; CAR ; CAR ; CDR } ;
                   { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                   { CAR ; CAR ; CDR } ;
                   { DIP { DIP { DIP { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ; SWAP } ;
                           SWAP } ;
                     SWAP } ;
                   { CAR ; CDR } ;
                   SOME ;
                   SWAP ;
                   UPDATE ;
                   SWAP ;
                   { DUP ;
                     DIP { CAR @%% ;
                           { DUP ;
                             DIP { CAR @%% ;
                                   { DUP ;
                                     DIP { CAR @%% ;
                                           { DUP ;
                                             DIP { CAR @%% ;
                                                   { DUP ;
                                                     DIP { CAR @%% ; { CAR @%% ; PAIR %@ % } } ;
                                                     CDR @%% ;
                                                     SWAP ;
                                                     PAIR %@ %@ } } ;
                                             CDR @%% ;
                                             SWAP ;
                                             PAIR %@ %@ } } ;
                                     CDR @%% ;
                                     SWAP ;
                                     PAIR %@ %@ } } ;
                             CDR @%% ;
                             SWAP ;
                             PAIR %@ %@ } } ;
                     CDR @%% ;
                     SWAP ;
                     PAIR %@ %@ } ;
                   SOME ;
                   SWAP ;
                   UPDATE ;
                   SWAP ;
                   CDR ;
                   SWAP ;
                   PAIR ;
                   SWAP ;
                   DROP ;
                   NIL operation ;
                   PAIR } }
             { PAIR ;
               DUP ;
               { CDR ; CDR ; CAR ; CAR } ;
               SENDER ;
               COMPARE ;
               EQ ;
               IF {} { PUSH string &#34;WrongCondition: sp.sender == self.data.admin&#34; ; FAILWITH } ;
               DUP ;
               CDR ;
               DUP ;
               { CDR ; CAR ; CDR } ;
               { DIP { DIP { DUP } ; SWAP } ; SWAP } ;
               { CAR ; CAR } ;
               { DIP { DIP { DIP { DUP } ; SWAP } ; SWAP } ; SWAP } ;
               { CAR ; CDR } ;
               SOME ;
               SWAP ;
               UPDATE ;
               SWAP ;
               { DUP ;
                 DIP { CDR @%% ;
                       { DUP ; DIP { CAR @%% ; { CAR @%% ; PAIR %@ % } } ; CDR @%% ; SWAP ; PAIR %@ %@ } } ;
                 CAR @%% ;
                 PAIR %@ %@ } ;
               SWAP ;
               DROP ;
               NIL operation ;
               PAIR } }
         { PAIR ;
           DUP ;
           { CDR ; CDR ; CAR ; CAR } ;
           SENDER ;
           COMPARE ;
           EQ ;
           IF {} { PUSH string &#34;WrongCondition: sp.sender == self.data.admin&#34; ; FAILWITH } ;
           DUP ;
           CDR ;
           { DIP { DUP } ; SWAP } ;
           CAR ;
           SWAP ;
           { DUP ; DIP { CDR @%% ; { CAR @%% ; PAIR %@ % } } ; CAR @%% ; PAIR %@ %@ } ;
           SWAP ;
           DROP ;
           NIL operation ;
           PAIR } }</pre>
</div>


```Michelson
BEGIN %setPause True STORAGE
```




<table>
<thead>
<tr><th>value  </th><th>type  </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair True
      (Pair 9
            (Pair
              (Pair "tz1M9CMEtsXm3QxA7FmMU2Qh7xzsuGXVbcDr"
                    { Elt "By" "https://SmartPy.io" ;
                      Elt "Help" "Use Build to define a new game board and Play to make moves" ;
                      Elt "Play at"
                           "https://smartpy.io/demo/explore.html?address=KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg" ;
                      Elt "SmartPy Template"
                           "https://smartpy.io/demo/index.html?template=tictactoeFactory.py" })
              False))</pre>        </td><td><pre style="text-align: left;">pair (bool %setPause)
      (pair
        (big_map string
                 (pair
                   (pair
                     (pair
                       (pair
                         (pair
                           (pair (pair (map %deck int (map int int)) (bool %draw))
                                 (map %metaData string string))
                           (int %nbMoves))
                         (int %nextPlayer))
                       (address %player1))
                     (address %player2))
                   (int %winner)))
        (pair (pair (address %admin) (map %metaData string string)) (bool %paused)))</pre>       </td></tr>
</tbody>
</table>




```Michelson
CDR ; CAR ; PUSH string "MeuJogo" ; GET
```

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>CDR: pop (True, (9, ((&#39;tz1M9CMEtsXm3QxA7FmMU2Qh7xzsuGXVbcDr&#39;, {&#39;By&#39;: &#39;https://SmartPy.io&#39;, &#39;Help&#39;: &#39;Use Build to define a new game board and Play to make moves&#39;, &#39;Play at&#39;: &#39;https://smartpy.io/demo/explore.html?address=KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg&#39;, &#39;SmartPy Template&#39;: &#39;https://smartpy.io/demo/index.html?template=tictactoeFactory.py&#39;}), False))); push (9, ((&#39;tz1M9CMEtsXm3QxA7FmMU2Qh7xzsuGXVbcDr&#39;, {&#39;By&#39;: &#39;https://SmartPy.io&#39;, &#39;Help&#39;: &#39;Use Build to define a new game board and Play to make moves&#39;, &#39;Play at&#39;: &#39;https://smartpy.io/demo/explore.html?address=KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg&#39;, &#39;SmartPy Template&#39;: &#39;https://smartpy.io/demo/index.html?template=tictactoeFactory.py&#39;}), False));
CAR: pop (9, ((&#39;tz1M9CMEtsXm3QxA7FmMU2Qh7xzsuGXVbcDr&#39;, {&#39;By&#39;: &#39;https://SmartPy.io&#39;, &#39;Help&#39;: &#39;Use Build to define a new game board and Play to make moves&#39;, &#39;Play at&#39;: &#39;https://smartpy.io/demo/explore.html?address=KT1UvfyLytrt71jh63YV4Yex5SmbNXpWHxtg&#39;, &#39;SmartPy Template&#39;: &#39;https://smartpy.io/demo/index.html?template=tictactoeFactory.py&#39;}), False)); push 9;
PUSH: push MeuJogo;
GET: pop MeuJogo, 9; push (((((((({0: {0: 0, 1: 0, 2: 0}, 1: {0: 0, 1: 1, 2: 0}, 2: {0: 0, 1: 0, 2: 0}}, False), {}), 1), 2), &#39;tz1S37hEZnNrAXfzuRYSjG9Qxq8VrwpWaukB&#39;), &#39;tz1YNRy5f4vWVWTY8nqhA9Q9P1CjTb8oby6g&#39;), 0),);</pre>
</div>




<table>
<thead>
<tr><th>value  </th><th>type  </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Some (Pair
       (Pair
         (Pair
           (Pair
             (Pair
               (Pair
                 (Pair
                   { Elt 0 { Elt 0 0 ; Elt 1 0 ; Elt 2 0 } ;
                     Elt 1 { Elt 0 0 ; Elt 1 1 ; Elt 2 0 } ;
                     Elt 2 { Elt 0 0 ; Elt 1 0 ; Elt 2 0 } }
                   False)
                 {})
               1)
             2)
           "tz1S37hEZnNrAXfzuRYSjG9Qxq8VrwpWaukB")
         "tz1YNRy5f4vWVWTY8nqhA9Q9P1CjTb8oby6g")
       0)</pre>        </td><td><pre style="text-align: left;">option (pair
         (pair
           (pair
             (pair
               (pair
                 (pair (pair (map %deck int (map int int)) (bool %draw))
                       (map %metaData string string))
                 (int %nbMoves))
               (int %nextPlayer))
             (address %player1))
           (address %player2))
         (int %winner))</pre>       </td></tr>
</tbody>
</table>


