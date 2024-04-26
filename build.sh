#/bin/bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

#export PREFIX2="$HOME/opt/cross"
#export TARGET2=x86_64-elf
#export PATH2="$PREFIX2/bin:$PATH"
# make with x86_64-elf-gcc and the -m64 flag 64 bit files.

make all