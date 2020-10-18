                
ORG 100h   

;------CARATULA-------------------

MOV CX, 8H  ; fijamos el valor del contador en 8 que son los mensaje a imprimir
MOV SI, offset msj1  ; se calcula el offset donde se encuentra el primer mensaje de la caratula.
MOV DH, 0H; fijamos la fila
label1:
MOV DL, 10H  ;asignamos la columna
MOV AH, 2H  ; seleccionamos el tipo de interrupcion
PUSH DX  ; colocamos el valor de fila y columna en la pila
INT 10H  ; activamos la interrupcion para fijar el cursor
MOV DX, SI ; colocamos en dx el valor del offset del mensaje 1
MOV AH, 9H  ; seleccionamos el tipo de interripcion       
INT 21H  ; activamos la interrupcion.
ADD SI, 2EH ; cambiamos el valor del offset para el siguiente mensaje 
POP DX  ; sacamos el valor de la pila de la fila y columna.
ADD DH, 1H  ; sumamos uno al numero de la fila
loop label1 ; repetimos el proceso para los 8 mensajes de la caratula.

;-----------------------------                  
 
MOV AX, 0B800h      
MOV DS, AX  
MOV BP, 4H                    

;------SUELO-Y-PAISAJE-----------         
  
MOV DH, 0000_1111b  ;retorna a los colores primarios.

;--Suelo----------------------
MOV AX, 0C80H; guardamos en ax el segmento de la posicion en la memoria de video
MOV CX, 50H  ; iniciamos el contador
MOV DH, 0AH  ; selecciona el color de los elementos del suelo
label2:
MOV DL, 0CDH ;seleccionamos caracter para imprimir el suelo
MOV BX, AX ; guardamos el segmento de memoria seleccionado en bx para poder apuntar a ese segmento
MOV [BX], DX; colocamos los valores de dx en la direccion a donde apunta la pila
MOV [BX+140H],DX; colocamos los valores de dx en la posicion de bx+140
MOV DL, 0B0H ;seleccionamos segundo caracter 
MOV [BX+0A0H], DX ; colocamos los valores del segundo caracter para imprimir en la pantalla
ADD AX, 2H ; sumamos 2 para rellenar todos los espacios del camino   
LOOP label2 ; iniciamos el ciclo

;--Paisaje----------------------- 
MOV DL, '*' ; seleccionamos la figura que formara el paisaje
MOV DH, 09H  ; seleccionamos el color de la figura
MOV CX, 45H   ; iniciamos el contador
MOV AX, 500H  ; guardamos en ax el segmento de la memoria de video donde quiero imprimir
label3: 
MOV BX, AX   ; pasamos a bx el valor de ax para poder manejar el segmento de memoria
MOV [BX], DX ; colocamos en el segmento al que apunta bx las caracterisitcas a imprimir
ADD AX,0EH ;sumamos un valor en ax para que los asteriscos del paisaje se inserten en la pantalla 
LOOP label3 ; iniciamos el ciclo para imprimir colocar el paisaje.
 
;-----FIGURA DEL JUGADOR-----------

PUSH DS  ; colocamos en la pila el valor de ds
PUSH AX  ; colocamos en la pila el valor de ax donde finalizo la colocacion de los asteriscos del paisaje
PUSH BX  ; colocamos en la pila el valor de bx donde finalizo la colocacion de los asteriscos 
PUSH BP  ; colocamos en la pila el valor del puntero base
MOV AL,1 ; modo de escritura
MOV BH,0 ; numero de pagina informacion necesaria para la interrupcion 
MOV BL,0FH; atributos del caracter
MOV CX, 3H; numero de caracteres de la figura del jugador
MOV DL, 41 ; columna para imprimir la figura
MOV DH, 19 ; fila para imprimir la figura
PUSH CS  ; colocamos el valor de cs en la pila.
POP ES   ; guardamos el ultimo valor de la pila en el registro es para poder imprimir
MOV BP, offset msj10 ; movemos al puntero base la ubicacion del mensaje 10 donde se encuentra la figura
MOV AH, 13H ; selecionamos el tipo de interrupcion
INT 10H ; iniciamos la interrupcion
POP BP ; sacamosde la pila el bp
POP BX ; sacamos de la pila el valor de bx
POP AX   ; sacamos de la pila el valor de ax              
POP DS ; sacamos de la pila el valor de ds
                
;------OBSTACULOS------------------

MOV DH, 0FH  ; atributo de la figura 
MOV DL, 0B2H  ; atriburo de la figura
MOV DI, 20H ; figura obstaculo  
MOV CX, 10H ; guardamos el valor de 10h en cx

label5:
PUSH CX  ; colocamos el valor de cx en la pila 
MOV AX, 0BE0H;colocamos la ubicacion donde imprimir los bloques   
MOV CX, 50H ; numero de cuenta para el ciclo label5 
MOV DH, 0CH ;atributo de la figura   

;--Desplazamiento del bloque-------   
label4: 
MOV ES,CX ;colocamos el valor de cx en es
MOV BX, AX; el valor de ax se guarda en bx para el manejo de los segmentos  
MOV [BX], DX ; el valor de dx se guarda en la posicion donde apunta bx 
MOV [BX-2], DI ; se imprime el obstaculo 1

;--segundo bloque-------- 
CMP CX,3EH ; compara el valor de cx con 3eh
JL bloque2  ; si es menor salta al procedimiento bloque2
JMP exit4  ; salta directamente al procedimiento exit4
bloque2:  
MOV [BX-20H], DX ; el valor de dx se guarda en la posicion donde apunta bx-20 
MOV [BX-22H], DI ; se imprime el obstaculo 2
exit4:  

CMP CX,01H ; compara el valor de cx con 01h
JE sige; si es igual salta al procedimiento je
JMP exit6; salta al procedimiento exit6
sige:
MOV CX,11h ; inicia el contador
label7: 
MOV [BX-20H], DX ; guarda el valor de dx en la posicion a la que apunta bx-20 
MOV [BX-22H], DI ; se imprime el obstaculo 2 
ADD BX,2  ; cambia la posicion 
LOOP label7  ;inicia el contador 
ADD DL,2H  ; cambia el valor de dl para cambiar la figura 
exit6: 
  
PUSH DX; guarda dx en la pila 
PUSH BX ; guarda bx en la pila
PUSH AX ; guarda ax en la pila           
PUSH DS ; guarda ds en la pila
PUSH ES ; guarda es en la pila
PUSH DI ; guarda di en la pila 

;--ENTER--Salida del juego-------
 
PUSH AX   ; saca el valor de la pila de ax
MOV [3000H], AX  ; mueve el valor de la pila al posicion 3000h 
MOV AH,1H  ; selecciona la interrupcion para saber si hay pulsaciones del teclado
INT 16H ; inicia la interrupcion 

JNE teclado  ; salta si es diferente que el pulso del teclado 

JMP exit ; salta directamente al procedimiento exit

teclado:
MOV AH,0 ; cambia a 0 el valor de ah
exit:

CMP AX,53H ; compara el valor de ax con S
JE salir  ; si es igual salta al procedimiento
JMP exit3 ; salta directamente al procedimiento exit3 
salir:
INT 20H ;Interrupcion salida del programa 
exit3: 
 
;-----SALTOS DE LA FIGURA----------- 

CMP AX,20H  ; comparamos el en ax el valor en codigo ascii de la tecla espacio
JE labelje1 ;si es igual a espacio saltamos al procedimiento labelje1
jmp exit1  ;salta directamente al procedimiento exit1
 
labelje1:
PUSH BP; colocamos el valor del puntero base en la pila
MOV BP, [3000H] ; lo que se encuentra en la posicion 3000h se guarda en el puntero base
ADD BP, 08H; al puntero base le sumamos 08h
MOV [2000H], BP ; lo que esta en el puntero base se guarda en la direccion 2000h 
;--Se borra la figura de la posicion-
MOV AL,1  ; modo de escritura
MOV BH,0  ; numero de pagina necesario para la interrupcion
MOV BL,0FH ; atriburo de la figura 
MOV CX, 3H ; numero de caracteres de la figura
MOV DL, 41 ;numero de columna
MOV DH, 19 ;numero de fila
MOV BP, offset msj9 ; colocamos en vez de la figura espacios en blanco
MOV AH, 13H; tipo de interrupcion
INT 10H; inicia la interrupcion  
;--Salta la figura a la linea de arriba--
MOV AL,1 ; modo de escritura
MOV BH,0 ; numero de pagina necesario para la interrupcion
MOV BL,0FH ; atributo de la figura;
MOV CX, 3H ; numero de caracteres de la figura
MOV DL, 41 ; numero de columna
MOV DH, 18 ; numero de fila
PUSH CS  ; colocamos en la pila el contenido de cs
POP ES  ; guardamos el contenido de cs colocado en la pila en es
MOV BP, offset msj10 ; seleccionamos la figura para que se vuelva a imprimir
MOV AH, 13H; seleccionamos la interrupcion
INT 10H ; iniciamos la interrupcion
POP BP ; sacamos el valor del puntero base de la pila
 
;--borra buffer del teclado------------
mov ax ,0C00h; 
int 21h 
 
;--Retorno a la posicion inicial-------   
exit1:

mov ax ,0C00h;;tipo de interrupcion para borrar el buffer del teclado e iniciar otra lectura 
int 21h; inicia la interrupcion 
 
POP AX; sacamos el valor de la pila y lo guardamos en el registro ax    

MOV BX, [2000H]; colocamos lo que se encuentra en la posicion 2000h dentro del registro bx
CMP AX, BX ; comparamos ax y bx
JE labelje2 ;si son iguales pasa al procedimiento labelje2
JMP exit2 ;salta directamente al procedimiento exit2

labelje2:
PUSH BP ; guardamos el puntero base en la pila
;--se borra la figura de la posicion-----
MOV AL,1 ; modo de escritura
MOV BH,0 ; numero de pagina necesaria para la interrupcion
MOV BL,0FH; atributos de la figura
MOV CX, 3H ; numero de caracteres a imprimir
MOV DL, 41 ; numero de columna
MOV DH, 18 ; numero de fila
MOV BP, offset msj9; seleccionamos el mensaje9 que es un espacio
MOV AH, 13H ; seleccionamos el tipo de interrupcion
INT 10H ; iniciamos la interrupcion 
;--Baja la figura a la posicion inicial--
MOV AL,1; modo de escritura
MOV BH,0; numero de pagina necesaria para la interrupcion
MOV BL,0FH ; atributos de la figura
MOV CX, 3H ; numero de caracteres a imprimir
MOV DL, 41; numero de columna
MOV DH, 19; numero de fila
PUSH CS ; colocamos en la pila el valor de cs
POP ES   ; guardamos el valor de cs que se almaceno en la pila y lo colocamos en es
MOV BP, offset msj10 ; guardamos la posicion del mensaje donde se encuentra la figura en en puntero base
MOV AH, 13H ; seleccionamos la interrupcion
INT 10H  ; iniciamos la interrupcion
POP BP; sacamos el valor del puntero base que se almaceno en la pila
exit2:


POP DI; saca el valor de la pila y lo almacena en di
POP ES ; saca el siguiente valor de la pila y lo guarda en es
MOV CX,ES ; guarda el valor de es en cx
POP DS ; guarda el proximo valor de la pila en ds
POP AX ; guarda el proximo valor de la pila en ax
POP BX ; guarda el proximo valor de la pila en bx
POP DX ; guarda el proximo valor de la pila en dx
ADD AX, 2H; suma 2h a ax    
LOOP label4 ; inicio del ciclo 

POP CX ; saca el valor de la pila de cx  
LOOP label5 ; inicio del ciclo 
  
RET ; retorno   

msj1  DB 'ฮอออออออออออออออออออออฯอออออออออออออออออออออฮ$'
msj2  DB 'บ  UNIVERSIDAD DE LAS FUERZAS ARMADAS ESPE  บ$' 
msj3  DB 'บ             MICROPROCESADORES             บ$'
msj4  DB 'บ       >>> PROYECTO 3ER PARCIAL <<<        บ$'
msj5  DB 'บ  ฺÛู ฏฏ  BRYAN CHAUCA - ANDRES OฅATE      บ$'
msj6  DB 'บ    ฏฏ DANIELA PEREIRA - GUSTAVO RUIZ      บ$'
msj7  DB 'ศอออออออออออออออออออออออออออออออออออออออออออผ$'                                                          
msj8  DB 'Presione tecla ALT para pausar y S para salir$'
msj9  DB '   '
msj10  DB 'ฺÛู'  

                              