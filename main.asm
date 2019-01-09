.include "m16def.inc";include functions needed and constants
.org 0
;data segment
.dseg
pass:
     .byte 4 
.def temp =        r16
.def temp2 =       r17
.equ lcdport =     porta
.equ lcdctrlport = portb

.equ lcd_clear=        $01
.equ lcd_display_on=   $0c
.equ lcd_8bit =        $38
.equ line1=            $80
.equ line2=            $c0
.equ line3=            $94
.equ line4=             $d4
.equ lcd_SetCursor=    $80
;code segment
.macro disp
ldi zh,high(@0)
 ldi zl,low(@0)
 ldi temp,@1
 call printf 
 .endm
 ;MACRO NUMBER 2
 .macro disp2
 ldi temp, lcd_clear
 out lcdport, temp
 ldi temp2, $04
 out lcdctrlport, temp2
 nop
 nop
 ldi temp2, $00
 out lcdctrlport, temp2
 rcall delay
 ldi zh,high(@0)
 ldi zl,low(@0)
 ldi temp,@1
 call printf 
 .endm

.cseg
 ldi temp, low(ramend)
 out spl, r16
 ldi temp, high(ramend)
 out sph, r16
 ldi r22,4
 main:
 rcall port_init
 rcall lcd_init

;disp welcome,line1
;call delay
disp2 name,line1
ldi yh,high(pass)
ldi yl,low(pass)
rcall keypad

end:
rjmp end


 port_init:
 ldi temp2, $07
 out ddrb, temp2
 ldi temp2, $ff
 out ddra, temp2
 ldi temp2,$0f
 out ddrd,temp2
 ret

 lcd_init:
 rcall delay
 ldi temp, lcd_clear
 out lcdport, temp
 ldi temp2, $04
 out lcdctrlport, temp2
 nop
 nop
 ldi temp2, $00
 out lcdctrlport, temp2
 rcall delay

 ldi temp, lcd_display_on
 out lcdport, temp
 ldi temp2, $04
 out lcdctrlport, temp2
 nop
 nop
 ldi temp2, $00
 out lcdctrlport, temp2
 rcall delay

 ldi temp,lcd_8bit
 out lcdport, temp
 ldi temp2, $04
 out lcdctrlport, temp2
 nop
 nop
 ldi temp2, $00
 out lcdctrlport, temp2
 rcall delay
ret


delay:
ldi r19, 50
delay_1:
ldi r18, 250
delay_2:
dec r18
ldi r20, 0
cp r18, r20
brne delay_2
dec r19
brne delay_1
ret

delay_2s:
ldi r19, 6
ldi r20, 250
ldi r21, 250
_delay_2:
dec r21
nop
brne _delay_2
_delay_0:
dec r20
nop
brne _delay_2
_delay_1:
dec r19
nop
brne _delay_2
ret

printf:
push    zh                             ; preserve pointer registers
push    zl
; fix up the pointers for use with the 'lpm' instruction
    lsl     zl                             ; shift the pointer one bit left for the lpm instruction
    rol     zh
; set up the initial DDRAM address

	call lcd_write_cmd; set up the first DDRAM address
    call    delay
; write the string of characters
lcd_write_string_8d_01:
    lpm     temp, Z+                        ; get a character
    cpi     temp,  0                        ; check for end of string
    breq    lcd_write_string_8d_02          ; done
; arrive here if this is a valid character
    call    lcd_write_character_8d          ; display the character
    call    delay
    rjmp    lcd_write_string_8d_01          ; not done, send another character
; arrive here when all characters in the message have been sent to the LCD module
lcd_write_string_8d_02:
    pop     ZL                              ; restore pointer registers
    pop     ZH
    ret
lcd_write_character_8d:
    ldi temp2,$01
	out lcdctrlport,temp2           ; make sure E is initially low
    call lcd_write                    ; write the data
    ret
lcd_write:
	out lcdport,temp
	ldi temp2,$05
	out lcdctrlport,temp2
	call delay
	ldi temp2,$01
	out lcdctrlport,temp2
	call delay 
	ret
lcd_write_cmd:
	out lcdport,temp
	ldi temp2,$04
	out lcdctrlport,temp2
	call delay
	ldi temp2,$00
	out lcdctrlport,temp2
	call delay 
	ret
keypad:
    ldi temp2,$f0
	out portd,temp2
	nop
wait:
	in temp2,pind
	andi temp2,$f0
	cpi temp2,$f0
	breq wait
	

ReadKey: 
    ldi ZH,HIGH(2*KeyTable) ; Z is pointer to key code table
	ldi ZL,LOW(2*KeyTable)
    ldi temp2,0b11111100 ; PB6 = 0
	out portd,temp2
	call delay
	in temp2,pind ; read input line
nop
	ori temp2,$0f ; mask upper bits
	cpi temp2,$ff ; key in this column pressed?
	brne RowFound ; key found
	nop 
	call delay
	adiw zl,4; column not found, point Z one row down
	; read column 2
	
	ldi temp2,0b11111010 ; PB5 = 0
	out portd,temp2
	call delay
	in temp2,pind ;	 read again input line
nop
	ori temp2,$0f; mask upper bits
	cpi temp2,$ff  ; a key in this column?
	brne RowFound; column found
	nop
	call delay
	adiw zl,4; column not found, another four keys down
	; read column 3
	
	ldi temp2,0b11110110 ; PB4 = 0
	out portd,temp2
	nop
	in temp2,pind; read last line
nop
	ori temp2,$0f ; mask upper bits
	cpi temp2,$ff  ; a key in this column?
	breq keypad
RowFound:
    lsl temp2
	brcc KeyFound
	call delay
	adiw zl,1
	jmp RowFound
KeyFound: ; pressed key is found 
;lpm temp,z; read key code to R16
lpm r0,z+
 rcall delay
 ldi temp,$2a
 out lcdport,temp
 ldi temp2, 0x05
 out lcdctrlport, temp2
 nop
 nop
 ldi temp2, 0x01
 out lcdctrlport, temp2
 rcall delay
 
 jmp logic
 logic:
	  st y+,r0
      dec r22
	   breq thank
	   brne keypadd
thank:
	   disp2 thanks,line1
       ldi zl,low(pass)
       ldi  zh,high(pass)
       ldi yh, high(clients)
       ldi yl,low(clients)
adiw z,2
       ld r23,z
 out lcdport,r23
 ldi temp2, 0x05
 out lcdctrlport, temp2
 nop
 nop
 ldi temp2, 0x01
 out lcdctrlport, temp2
 rcall delay
cpi r23,$34
 breq three
 call end
three:
disp tree,line2
call end
keypadd:
 jmp keypad
tree:
      .db "Tatu ",0
 welcome:
       .db "**BANK NA SI **",0
       name:
      .db "Passcode:",0
thanks:
      .db "Password Entered ",0
KeyTable:
      .db "+","9","6","3"
	  .db "0","8","5","2"
	  .db ".","7","4","1"
clients:
           .db "1234","10000",0
            .db "1235","20000",0
            .db "1236","30000",0
            .db "1231","40000",0
            .db "1230","50000",0
            .db "1239","60000",0
            .db "1238","70000",0
            .db "1237","80000",0
            .db "1224","90000",0
            .db "1214","15000",0