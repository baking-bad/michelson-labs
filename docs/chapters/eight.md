
# Michelson tutorial
## Chapter eight

Pairs are probably one of the most important type in your Michelson tool belt. Every contract starts with a pair, every contract ends with a pair. They are a fundamental component of Michelson contracts. A pair is the smallest type of value you can use to store multiple values: it can hold two values of different types. You can also *nest* pairs: a pair can consist of a simple value and another pair or even two other pairs! This model allows nesting multiple pairs one into the other, like Russian dolls.

Along the previous lessons, we encountered a couple of instruction that act on pairs, namely **`CAR`** and **`CDR`**. If you remember, these two opcodes extract the left side and the right side of the pair, respectively. There is also **`PAIR`** that creates a new pair with two provided values. But that's just the tip of the iceberg! There are other instructions you can use to create or manipulate pairs. By the end of this chapter, pairs will have no secret for you!

##### 1. Overview of the pair type

A pair is fundamentally a value that holds two other values. These two values can be of any type. In the documentation, you will find pair type written this way: `(pair type1 type2)`. The value of the pair is written this way: `(Pair value1 value2)`. Every smart contract written in Michelson starts and ends with a pair:


```Michelson
storage (pair int int) ;
parameter unit ;
code {
    DROP ;
    PUSH int 6 ;
    PUSH int 7 ;
    PAIR ;
    NIL operation ;
    PAIR ;
} ;

RUN %default Unit (Pair 0 0) ;
```

    storage (pair int int);
    parameter unit;
    code { DROP ; PUSH int 6 ; PUSH int 7 ; PAIR ; NIL operation ; PAIR };
    RUN: use %default; drop all; push (Unit, (0, 0));
    DROP: pop (Unit, (0, 0));
    PUSH: push 6;
    PUSH: push 7;
    PAIR: pop 7, 6; push (7, 6);
    NIL: push [];
    PAIR: pop [], (7, 6); push ([], (7, 6));




<table>
<thead>
<tr><th>value                                        </th><th>type                                             </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair 7 6</pre></td><td><pre style="text-align: left;">pair int int</pre></td></tr>
</tbody>
</table>



You can choose the types you want in a pair, even other pairs:


```Michelson
storage unit ;
parameter unit ;
BEGIN Unit Unit ;
DROP ;
PUSH nat 5 ;
PUSH string "hello" ;
PAIR @first_pair ;
PUSH mutez 5000 ;
NOW ;
PAIR @second_pair ;
PUSH (pair int string) (Pair 3 "hello") ;
PUSH (pair nat mutez) (Pair 5 45678) ;
PAIR @third_pair ;
DUMP ;
```

    storage unit;
    parameter unit;
    BEGIN: use %default; drop all; push (Unit, Unit);
    DROP: pop (Unit, Unit);
    PUSH: push 5;
    PUSH: push hello;
    PAIR: pop hello, 5; push ('hello', 5);
    PUSH: push 5000;
    NOW: push 1593158292;
    PAIR: pop 1593158292, 5000; push (1593158292, 5000);
    PUSH: push (3, 'hello');
    PUSH: push (5, 45678);
    PAIR: pop (5, 45678), (3, 'hello'); push ((5, 45678), (3, 'hello'));




<table>
<thead>
<tr><th>value                                                                    </th><th>type                                                                        </th><th>name                                             </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">Pair (Pair 5 45678) (Pair 3 "hello")</pre></td><td><pre style="text-align: left;">pair (pair nat mutez) (pair int string)</pre></td><td><pre style="text-align: left;">@third_pair</pre> </td></tr>
<tr><td><pre style="text-align: left;">Pair 1593158292 5000</pre>                </td><td><pre style="text-align: left;">pair timestamp mutez</pre>                   </td><td><pre style="text-align: left;">@second_pair</pre></td></tr>
<tr><td><pre style="text-align: left;">Pair "hello" 5</pre>                      </td><td><pre style="text-align: left;">pair string nat</pre>                        </td><td><pre style="text-align: left;">@first_pair</pre> </td></tr>
</tbody>
</table>



##### 2. Operations on pairs
