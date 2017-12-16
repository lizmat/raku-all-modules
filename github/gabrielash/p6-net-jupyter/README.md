# Net::Jupyter

## SYNOPSIS

Net::Jupyter is a Perl6 Jupyter kernel

## Introduction

  This is a perl6 kernel for jupyter

  only the minumum required messages are implemented: kernel_info_request and execute_request

#### Version 0.1.1

#### Status

  In development.

  Todo:
  1. Implement Magic statements (see section below)
  2. Implement additional messages


#### Alternatives

  1. https://github.com/timo/iperl6kernel

  2. https://github.com/bduggan/p6-jupyter-kernel


#### Portability
  relies on [Net::ZMQ](https://github.com/gabrielash/perl6-zmq)


## Documentation

  see also http://jupyter.org/

### Installation

First, install the  module: 

    git clone https://github.com/gabrielash/p6-net-jupyter
    cd p6-net-jupyter
    zef install .

then, install the kernel:

    bin/kernel-install.sh [ dir ]?


Assuming jupyter is already installed on your system, and  LOCAL_HOME is defined,
it will try to install in the correct .local subdir that Anaconda recognizes
for jupyter kernels.  You can also specify a custom dirctory as an argument.

###  Docker Installation

      docker run -d --name jupyter-als \
        -p 8888:8888 \
        -v $CONFIG:/home/jovyan/.jupyter \
        -v $NOTEBOOKS:/home/jovyan/work \
        gabrielash/all-spark-notebook

  1.    set CONFIG to the directory (Full Path) for overriding jupyter settings. For example 
        to substitute a fixed authentification token. There is a demo
        jupyter_notebook_config.py in the docker dir that you can copy into it and edit.
  2.    set NOTEBOOKS to the directory that will hold all notebooks created. It will be the top directory
        for the Jupyter server.

see also [Jupyter's all-spark-notebook docker image ](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook)

An alternative minimal image based on jupyter base-notebook is also provided. 
see the docker directory.

### Magic declarations

magic declrations are lines beginning and ending with %%.

All magic declarations apply to the whole cell, must come at the top, and cannot be interleaved 
with Perl6 code.

#### Implemented: 

    %% timeout 5 %%  
    # sets a timeout on execution