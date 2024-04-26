[BITS 16]
[ORG 0x7C00]

_start:
	jmp short start
	nop

; 1.44MB floppy from https://stackoverflow.com/questions/47277702/custom-bootloader-booted-via-usb-drive-produces-incorrect-output-on-some-compute/47320115#47320115
OEMIdentifier			db 'TEST    '
BytesPerSector			dw 0x200
SectorsPerCluser 		db 1
ReservedSectors			dw 1
FATCopies 				db 0x02
RootDirEntries			dw 224
NumSectors				dw 2880
MediaType				db 0xF0			;0xF0 = Floppy; 0xF8 = HDD
SectorsPerFat			dw 9
SectorsPerTrack			dw 18
NumberOfHeads			dw 2
HiddenSectors			dd 0
SectorsBig 				dd 0

; Extended BPB
DriveNumber				db 0x00
WinNTBit				db 0x00
Signature 				db 0x29
VolumeID				dd 0xD106
VolumeIDString 			db 'TEST   BOOT'
SystemIDString 			db 'FAT12   '

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

	xor cx, cx
	xor bx, bx

	mov cl, [readLoopCount]
.loop:
	mov [readLoopCount], cl

	;Hardcodes CHS value to 0,0,2 for test
	mov ah, 0x2			
	mov al, 1				; 1 sector

	mov ch, 0x00			; Cylinder number
	mov cl, 0x2				; Sector number (bits 0-5) and high 2 bits of cylinder (0)

	xor bx, bx
	mov es, bx				; es = 0x00
	mov bx, 0x7E00			; Destionation
	mov dh, 0				; Head number
	mov dl, [driveId]		; Drive number
	
	int 0x13
	
	jnc .done

	mov cl, [readLoopCount]
	loop .loop				; Rety it 10 times because of, why not

.error:
	mov si, driveReadError
	call print

	add ah, 48
	mov [errorNumber+9], ah
	mov si, errorNumber
	call print

	jmp $

.done:
	pop bx
	pop dx
	pop cx
	pop ax

	ret

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

welcomeMessage: db 'BIOS Bootloader test',0xa,0xd, 0
driveReadError: db 'There was an error reading from disk', 0xa, 0xd, 0
errorNumber: db 'Error No:', 0, 0xa, 0xd, 0

times 510- ($-$$) db 0
dw 0xAA55
