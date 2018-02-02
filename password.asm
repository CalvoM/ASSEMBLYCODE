.model small ;define model of the program this allocates various spaces to the segment

.stack 100h

data segment  ; our data segment where we declare the variables by allocating spaces eg if a byte or a word(dw)
bad db 0ah,0dh,'Wrong Password$'
string1 db 'Enter the password',0ah,0dh,'$' 
goods db 0ah,0dh,'Password ni fiti$'
realpass db 'Sami'
password db 5,?,5 dup('') ; the password inputted by the user where the first is maximum chars, the second is the number inputted and third are the chars
ends

code segment ;where we start our code
start:
 mov ax,@data
 mov ds,ax     ;moving our data segment address to the chip's data segment
 
 mov dx,offset string1
 mov ah,09h   ;call function in the 21h interrupt to display string in ds:dx
 int 21h
 
 mov dx,offset password
 mov ah,0ah  ;call function in the 21h interrupt to input string into ds:dx
 int 21h
 
 
 ;xor bx,bx  ;clear base register
 ;mov bl,password[1]   ;moving the actual number of chars inputted by user
 
 
 mov si,02 ;set the value si to 2
 mov di,00 ;set value of di to 00
 
comp proc ;the comp procedure where we do the comparing of the chars
 mov cl,password+si ;mov the various chars of inputted password to register cl
 cmp realpass+di,cl  ;compare the corresponding real password char with the inputted password
 je increase   ; if the compared chars are equal the program jumps to increase procedure
 jne sorry      ; if the compared chars are not equal the program jumps to sorry procedure
 endp comp

 increase proc  ;procedure where we increase the index regs to enable continual comparing of the chars
 inc si 
 inc di
 cmp di,4 
 je better
 jne comp
 endp increase
  
 sorry proc  ;procedure where we display the message when the user inputs wrong password
 mov ah,09h  
 mov dx,offset bad
 int 21h
 jmp mwisho
 endp sorry
 
 better proc ;procedure where we display the message when the user inputs correct password      
 mov ah,09h
 mov dx,offset goods
 int 21h  
 jmp mwisho
 endp better 
 
 mwisho proc ;procedure to terminate program and return control to OS
 mov ax,4c00h
 int 21h
 endp mwisho
 
end start 
ends