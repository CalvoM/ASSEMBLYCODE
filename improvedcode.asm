.model small
.stack 100h
.data 
c1 db 30h  
tens db 30h
intro db 0dh,"Press (S) to start and (s) to stop and (c) to clear screen",0ah,0dh,"$"
wrong1 db 0dh,"Incorrect entry. Try again.",0ah,0dh,"$"

.code
start proc
    mov ax,@data
    mov ds,ax 
    mov dh, 0
	mov dl, 0
	mov bh, 0
	mov ah, 2
	int 10h
    
    mov dx,offset intro
    mov ah,09h
    int 21h 
    
    mov ah,07h
    int 21h  
    
    jmp cmp2
    
    mov ah,4ch
    int 21h
endp start  
nextchar: 
   mov ah,01h
   int 16h
   jnz cmp2
    mov dl,0dh
    mov ah,02h
    int 21h 
    
    mov dl,tens
    mov ah,02h
    int 21h
          
    mov dl,c1
    mov ah,02h
    int 21h
       
    inc c1
    mov cx,0fh
    mov dx,4240h
    mov ah,86h
    int 15h 
    
   
    cmp c1,3ah
    jl nextchar
    jge increase
 
cmp2:
   cmp al,"s" 
   jne wrong 
   je stop  
   
   
stop:
 
    mov ah,07h
   int 21h
   jmp cmp2
   
wrong:
cmp al,"S" 
   je nextchar
   jne wrong2

wrong2:
cmp al,'c'
jne wrong3
je reset

wrong3:
mov dx,offset wrong1
mov ah,09h
int 21h
jmp start

reset:
    mov c1,30h
    mov tens,30h 
    mov dh, 1
	mov dl, 0
	mov bh, 0
	mov ah, 2
	int 10h 
	mov dl,20h
	mov ah,02h
	int 21h  
	mov dl,20h
	mov ah,02h
	int 21h
    jmp start



increase proc
    inc tens
    mov c1,30h
    jmp nextchar
endp increase