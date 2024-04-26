[BITS 16]
[ORG 0x7C00]

_start:
	jmp short start
	nop

OEMIdentifier			db 'TEST    '
BytesPerSector			dw 0x200
SectorsPerCluser 		db 1
ReservedSectors			dw 100
FATCopies 				db 0x1
RootDirEntries			dw 16
NumSectors				dw 65535
MediaType				db 0xF8			;0xF0 = Floppy; 0xF8 = HDD
SectorsPerFat			dw 255
SectorsPerTrack			dw 0
NumberOfHeads			dw 0
HiddenSectors			dd 0
SectorsBig 				dd 0

; Extended BPB
DriveNumber				db 0x00
WinNTBit				db 0x00
Signature 				db 0x29
VolumeID				dd 0xD106
VolumeIDString 			db 'TEST   BOOT'
SystemIDString 			db 'FAT16   '



start:
	jmp 0x0:$+1						; Set CS to 0
	
	cli

	mov ax, 0
	mov es, ax
	mov ds, ax
	mov di, ax
	mov ss, ax
	mov fs, ax
	mov sp, 0x7C00

	sti

	mov [driveId], dl				; Save driveId

	mov si, welcomeMessage
	call print	
	
	;Kcall getDriveGeometry
	call diskReadSector
	;call resetDrive
	;call checkDriveReady

	jmp 0x7E00


diskReadSector:
	push ax
	push cx
	push dx
	push bx

	;Hardcodes CHS value to 0,0,2 for test

	mov al, 1				; 1 sector
	mov ah, 0x2			

	mov cl, 0x2				; Sector number (bits 0-5) and high 2 bits of cylinder (0)
	mov ch, 0x00			; Cylinder number

	xor bx, bx
	mov es, bx				; es = 0x00
	mov bx, 0x7E00			; Destionation
	mov dl, [driveId]		; Drive number
	mov dh, 0				; Head number

	
	int 0x13
	
	jc .error

.done:
	pop bx
	pop dx
	pop cx
	pop ax

	ret

.error:
	mov si, driveReadError
	call print

	add ah, 48
	mov [errorNumber+9], ah
	mov si, errorNumber
	call print

	jmp $

print:
	push ax
	push bx
	
	xor ax, ax

	mov ah, 0xE
	mov bx, 0x0
.loop:
	lodsb
	cmp al, 0
	jz .done
	int 0x10	
	jmp .loop
.done:

	pop bx
	pop ax
	ret

;Typical floppy disc (80, 2, 18)

driveId: db 0
numHeads: db 16
secPerTrack: db 63

readLoopCount db 10

welcomeMessage: db 'BIOS Bootloader test',10, 13, 0
driveReadError: db 'There was an error reading from disk', 10, 13, 0
errorNumber: db 'Error No:', 0, 10, 13, 0

times 446- ($-$$) db 0

partition_table:
	db 0x80		; Bootable FLAG 0x80 = bootable
	db 0x00		; Starting head
	db 0x00		; Starting sector and cylinder
	db 0x00		; staring cylinder
	db 0x0E		; Partition type (System ID)
	db 0x00		; Enbding head
	db 0x00		; Ending sector 6bit
	db 0x00		; Ending sector 10 bit (4 byte)
	db 0x00		; Relative sector 32 bit
	db 0x00
	db 0x00
	db 0x00
	db 0xFF		; Total sectors 32 bit (4 bytes)
	db 0xFF
	db 0x00
	db 0x00

times 48 db 0

dw 0xAA55
