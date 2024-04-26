[bits 16]
[org 0x7E00]

	xor ax, ax
	xor bx, bx

	mov ah, 0xE
	mov al, 'H'
	int 0x10

	jmp $
