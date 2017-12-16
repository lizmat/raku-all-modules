## Synopsis

A mimimal dockerized jupyter notebook installation with python3 and Perl6

## Installation 

run with 

    docker run -d --name jupyter-base \
        -p 8888:8888 \
        -v $CONFIG:/home/jovyan/.jupyter \
        -v $NOTEBOOKS:/home/jovyan/work \
        gabrielash/base-notebook

  1.    set CONFIG to the directory (Full Path) for overriding jupyter settings. For example 
        to substitute a fixed authentification token. There is a demo
        jupyter_notebook_config.py in the docker dir that you can copy into it and edit.
  2.    set NOTEBOOKS to the directory that will hold all notebooks created. It will be the top directory
        for the Jupyter server.



 see also [Jupyter's base-notebook docker image ](https://github.com/jupyter/docker-stacks/tree/master/base-notebook)