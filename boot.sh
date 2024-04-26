#!/bin/bash

case $1 in
	f)
		echo ""
		echo "Booting FLOPPY"
		echo ""
		qemu-system-i386 -fda ./bin/boot.bin
	;;
	*)
		echo ""
		echo "Booting HDD"
		echo ""
		qemu-system-i386 -hda ./bin/boot.bin
	;;
esac
