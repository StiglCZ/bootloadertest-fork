FILES = boot loader

all: folders $(FILES)
	rm -rf ./bin/boot.bin
	cat bin/stage1.bin > bin/boot.bin
	cat bin/stage2.bin >> bin/boot.bin

folders:
	mkdir -p ./bin/

boot: ./src/boot.asm
	nasm -f bin ./src/boot.asm -o ./bin/stage1.bin

loader: ./src/stage2.asm
	nasm -f bin ./src/stage2.asm -o ./bin/stage2.bin
