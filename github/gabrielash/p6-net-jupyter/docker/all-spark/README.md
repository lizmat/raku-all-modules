## Synopsis

A dockerized jupyter notebook installation with python3 and Perl6
loaded with packages

## Installation 

run with 

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


 see [Jupyter's all-spark-notebook docker image ](https://github.com/jupyter/docker-stacks/tree/master/all-spark-notebook)