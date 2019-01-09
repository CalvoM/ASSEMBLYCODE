.STACK 100H
DATA SEGMENT 
    PORTA_VAL DB 0 
    PORTb_VAL DB 0
    PORTc_VAL DB 0 
    MYSTR DB "HELLO THERE$"
    
    PORTA   EQU 00H
    PORTB   EQU 02H
    PORTC   EQU 04H
    CONTROL EQU 06H
ENDS        
CODE SEGMENT 
 PROC START
    MOV AX,DATA
    MOV DS,AX
    
    MOV AL,80H
    MOV DX,CONTROL
    OUT DX,AL
    
    CALL LCD_INIT
    
   MOV DL,01H
   MOV DH,01H
    CALL SET_CUR 
    
    MOV AH,"A"
    CALL WRITE_CHAR 
    MOV AH,'B'
    CALL WRITE_CHAR 
    MOV AH,'C'
    CALL WRITE_CHAR
    
    MOV DL,2
    MOV DH,1
    CALL SET_CUR 
    LEA SI,MYSTR
    CALL PRINTF
    
    MOV CX,60000
    CALL DELAY
    
    CALL CLEAR
    
    HLT  
 PROC CLEAR
    MOV AH,01H
    CALL LCD_CMD
 ENDP CLEAR
 
 PROC DELAY
    JCXZ EOF
    LOOP1:
    LOOP LOOP1
    EOF:
    RET
 ENDP DELAY
PROC LCD_INIT
    MOV AL,0
    CALL OUT_B
    
    MOV CX,1000
    CALL DELAY
    
    MOV AH,30H
    CALL LCD_CMD
    MOV CX,250
    CALL DELAY 
    
    MOV AH,30H 
    CALL LCD_CMD 
    MOV CX,50
    CALL DELAY 
    
    MOV AH,30H
    CALL LCD_CMD 
    MOV CX,500
    CALL DELAY
    
    MOV AH,38H
    CALL LCD_CMD
    
    MOV AH,0EH
    CALL LCD_CMD    
    
    MOV AH,01H
    CALL LCD_CMD
    
    MOV AH,06H        
    CALL LCD_CMD
    RET
ENDP LCD_INIT

PROC OUT_B 
    PUSH DX
    MOV DX,PORTB
    OUT DX,AL
    MOV PORTB_VAL,AL
    POP DX    
    RET    
ENDP OUT_B

PROC OUT_A
    PUSH DX
    MOV DX,PORTA
    OUT DX,AL 
    MOV PORTA_VAL,AL
    POP DX
    RET
ENDP OUT_A

PROC LCD_CMD
    PUSH DX
    PUSH AX
    
    MOV AL,PORTB_VAL
    AND AL,0FDH
    CALL OUT_B
    
    MOV AL,AH
    CALL OUT_A
              
    MOV AL,PORTB_VAL          
    OR AL,0100B
    CALL OUT_B
    
    MOV CX,50
    CALL DELAY
        
    MOV AL,PORTB_VAL    
    AND AL,0FBH
    CALL OUT_B
    
    MOV CX,50
    CALL DELAY
    
    POP AX
    POP DX
    
    RET
ENDP LCD_CMD

PROC SET_CUR
    PUSH AX
    DEC DH
    
    CMP DL,01H
    JE ROW1
    CMP DL,02H
    JE ROW2
    JMP CUR_END 
    
    ROW1:
    MOV AH,80H 
    JMP CUR_ENDCASE
    
    ROW2:
    MOV AH,0C0H
    JMP CUR_ENDCASE 
    
    CUR_ENDCASE:
    ADD AH,DH
    CALL LCD_CMD
    
    CUR_END:
    POP AX
    RET 
          
ENDP SET_CUR
                    
PROC WRITE_CHAR 
    PUSH AX
    
    MOV AL,PORTB_VAL
    OR AL,10B
    CALL OUT_B
    
    MOV AL,AH
    CALL OUT_A
    
    MOV AL,PORTB_VAL
    OR AL,100B
    CALL OUT_B
    
    MOV CX,50
    CALL DELAY 
    
    MOV AL,PORTB_VAL
    AND AL,0FBH
    CALL OUT_B
    POP AX
    RET
    
ENDP WRITE_CHAR 

PROC PRINTF
   PUSH SI
   PUSH AX
   RWSTR:
   LODSB 
   CMP AL,'$' 
   JE STR_EXIT
   MOV AH,AL
   CALL WRITE_CHAR
   JMP RWSTR
   STR_EXIT:
   POP AX
   POP SI
   RET
ENDP PRINTF
CODE ENDS
END START