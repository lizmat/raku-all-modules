#!/bin/bash

root=$(pwd)
root=${root%/bin}
if [ ! -r "$root/META6.json" ]; then 
  echo "please run $0 from the root or bin directory of the module"
  exit -1
fi

if [ -d "$1" ]; then 
  dir="$1"
  shift
elif [ -d "$LOCAL_HOME" ]; then
  dir="$LOCAL_HOME/share/jupyter/kernels/iperl6"
else
  echo "I don't know where to install the kernel."
  echo "    you can rerun the script with the directory name as argument"
  echo "    the directory must exist."
  exit -1
fi

if [ "$1" == "-y" ]; then
  CONFIRM="Y"
else
  read -r -p "Installing Jupyter Kernel in [ $dir ]? y|N" CONFIRM
fi

if [[ "$CONFIRM" =~ ^[Yy]$ ]] ; then

  mkdir -p "$dir"
  cat << END > "$dir/kernel.json"
{
  "display_name": "Perl 6.d",
  "argv": [
    "$dir/kernel.pl",
    "{connection_file}"
  ], 
  "language": "Perl6"
}
END
  RES="$root/resources/kernels/perl6"
  cp "$root/bin/kernel.pl" "$dir/"
  cp "$RES/"*.png "$RES/README.md" "$dir/"

  echo "the iperl6 jupyter kernel has been installed in [ $dir ]" 
else 
  echo aborting...
fi


