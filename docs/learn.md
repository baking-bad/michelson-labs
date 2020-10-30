---
title: Learn | Tezos Labs
summary: How to use this course materials
---

# How to use this course
Welcome to the Tezos Labs interactive learning course!   

It consists of a series of [Jupyter notebooks](https://jupyter.org/). Code snippets from the notebooks can be executed both online and locally. Also, you can write code yourself — there are exercises at the end of several tutorials for self-evaluation.  

## Run online
In order to feel what interactive notebooks are you can open course chapters in the Binder service, that provides a temporary Jupyter environment.

![Open in Binder](./.vuepress/public/binder.gif)

::: warning NOTE
Your changes won't be saved unless you download the notebook to your computer.  
For regular use consider local setup (options below).
:::

## Run in Docker

Ensure you have [Docker](https://docs.docker.com/get-docker/) installed.

```
docker pull bakingbad/michelson-kernel
docker run --rm -it -p 127.0.0.1:8888:8888 -v $(pwd):/home/jupyter/notebooks bakingbad/michelson-kernel
```

Open _http://127.0.0.1:8888_ in your browser.  

Note, that the _notebooks_ folder is mounted to your local filesystem by default, so you won't loose any changes made.

## Run locally

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

## Contact us
If you have any questions regarding the tutorials, Michelson kernel, PyTezos library, TzKT API, or you spotted a bug — please reach us:
* Telegram [https://t.me/baking_bad_chat](https://t.me/baking_bad_chat)
* Slack [https://tezos-dev.slack.com/archives/CV5NX7F2L](https://tezos-dev.slack.com/archives/CV5NX7F2L)
* Email [hello@baking-bad.org](mailto://hello@baking-bad.org)

## About

This educational project is supported by [Tezos Foundation](https://tezos.foundation). 

*Michelson tutorials: [Claude Barde](https://twitter.com/claudebarde)*  
*PyTezos tutorials: [Michael Zaikin](https://github.com/m-kus)*  
*Educational platform: [Baking Bad](https://baking-bad.org/docs)*  
