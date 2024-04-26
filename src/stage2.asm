[bits 16]
[org 0x7E00]
stage2_begin:
	xor ax, ax
	xor bx, bx

	mov ah, 0x0E
	mov al, 'H'
	int 0x10

	jmp $