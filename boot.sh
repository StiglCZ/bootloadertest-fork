#!/bin/bash

case $1 in
	f)
		echo ""
		echo "Booting FLOPPY"
		echo ""
		qemu-system-i386 -drive file=./bin/boot.bin,format=raw,if=floppy
	;;
	*)
		echo ""
		echo "Booting HDD"
		echo ""
		qemu-system-i386 -drive file=./bin/boot.bin,format=raw
	;;
esac
