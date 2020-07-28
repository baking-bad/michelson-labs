# Introduction




## Notebook workflow

### Code block

```Michelson
PUSH string "Hello" ;
```

### Execution log

<div class="stdout">
    <pre><span class="stream-name">stdout</span><br/>PUSH: push Hello;</pre>
</div>

### Errors

<div class="stderr">
    <pre><span class="stream-name">stderr</span><br/>MichelsonRuntimeError</pre>
</div>

### Stack values

<div class="embedded-html">
<table>
<thead>
<tr><th>value                                             </th><th>type                                       </th></tr>
</thead>
<tbody>
<tr><td><pre style="text-align: left;">"Hello"</pre></td><td><pre style="text-align: left;">string</pre></td></tr>
</tbody>
</table>
</div>

### Helpers and macros

```Michelson
DROP ;  ## Michelson instruction
FAIL ;  ## Michelson macro
DUMP ;  ## Jupyter kernel helper
```

### Exercises


## Run online



## Run in Docker

Ensure you have [Docker](https://docs.docker.com/get-docker/) installed.

```
docker pull bakingbad/michelson-kernel
docker run --rm -it -p 127.0.0.1:8888:8888 -v $(pwd):/home/jupyter/notebooks bakingbad/michelson-kernel
```

Open _http://127.0.0.1:8888_ in your browser.  

Note, that the _notebooks_ folder is mounted to your local filesystem by default, so you won't loose any changes made.

## Install Jupyter

First of all, install several crypto libraries:
* Ubuntu: `sudo apt install libsodium-dev libsecp256k1-dev libgmp-dev`
* MacOS: `brew install libsodium libsecp256k1 gmp`
* Windows: follow the [guide](https://github.com/baking-bad/pytezos#windows)

Ensure you have a suitable Python version (3.5+). 
The recomended way is [pyenv](https://github.com/pyenv/pyenv-installer).
Make sure you have installed all the [dependencies](https://github.com/pyenv/pyenv/wiki/Common-build-problems) first.

```
pip install jupyter michelson-kernel
jupyter notebook
```

Open the link from the command output, create new notebook with Michelson kernel.
