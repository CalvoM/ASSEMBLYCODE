.model small
.stack 100h
.data 
  rowNo db ?   
  colNo db ? 
  counter db ?  
  colors db 3
  col db 3,?,4 dup('')
one db "1234567890" 
    db "abcdefghij"
    db "ABCDEFGHIJ"
    db "!@#$%^&*()"
    db "mamemimomu"
    db "=[];'\,/<>"
    db "Comosiilem"
    db "micro-mini"
    db "Bungalow12"
    db "Mecht2014."
     
row db 3,?,4 dup('')

 
  
tryagain db 10,13,10,13,"Sorry Row number out of range$"   
tryagain2 db 10,13,10,13,10,13,"Sorry Column number out of range$"
 
.code
 

mov ax,@data
mov ds,ax

start:
mov dl,'R'
mov ah,02h
int 21h 

call space  

lea dx,row
mov ah,0ah
int 21h
        

call jump 

mov dl,'C'
mov ah,02h
int 21h

call space

lea dx,col
mov ah,0ah
int 21h

jmp calc

mov ah,4ch
int 21h

jump:
mov ah,02h
mov dl,0dh
int 21h
mov dl,0ah
int 21h
ret  
space:
mov dl,20h
mov ah,02h
int 21h
ret 
calc:
cmp row+2,'0'
je calc2
jne ten
ten:
cmp row+2,'1'
jne calc3 
cmp row+3,'0'
jne calc3
mov rowNo,10
mov cl,rowNo
jmp Final
calc2:
mov cl,row+3
mov rowNo,cl
sub rowNo,30h
jmp Final
calc3:
lea dx,tryagain
mov ah,09h
int 21h 
call jump
jmp start

Final:
jmp Colcalc

Colcalc:
cmp col+2,'0'
je Cocalc2
jne Colten
Colten:
cmp col+2,'1'
jne Cocalc3 
cmp col+3,'0'
jne Cocalc3
mov colNo,10
mov cl,colNo 
jmp Start2
Cocalc2:
mov cl,col+3
mov colNo,cl
sub colNo,30h
jmp Start2
Cocalc3: 
lea dx,tryagain2
mov ah,09h
int 21h 
call jump  
jmp start
Start2: 
lea bx,one

dec colNo 

dec rowNo    

mov al,rowNo
mov cl,10
mul cl
add bx,ax
mov al,colNo
mov cl,1
mul cl
mov si,ax 
jmp display

display proc

    
mov cx,1 
mov counter,6
call jump
mov dl,bx+si

color: 
mov ah,01h
int 16h
jnz keyPressed   
push bx
push cx
mov al,bx+si 
mov bl,colors 
mov ah,09h
int 10h 
mov cx,1eh
mov dx,8480h
mov ah,86h
int 15h
inc colors
pop cx 
pop bx
dec counter
cmp counter,0  
jnz color

mov ah,4ch
int 21h
endp display
keyPressed proc
    cmp al,'S'
    jnz color
    mov ah,06h
    mov al,00h
    int 10h
    mov dh,0
    mov dl,0
    mov bh,0
    mov ah,02h
    int 10h
    mov dl,bx+si
    mov ah,02h
    int 21h
endp keyPressed