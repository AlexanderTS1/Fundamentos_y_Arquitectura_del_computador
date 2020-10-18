; este es el juego de serpientes comiendo pantalla ...
;
; este juego lleva al emulador al límite,
; e incluso con la máxima velocidad, sigue funcionando lentamente.
; para disfrutar de este juego se recomienda ejecutarlo en
; computadora, sin embargo, el emulador puede ser útil para depurar
; pequeños juegos y otros programas similares como este antes
; se vuelven libres de errores y viables.
;
; puedes controlar la serpiente usando las teclas de flecha de tu teclado.
;
; todas las demás llaves detendrán a la serpiente.
;
; presione esc para salir.
 
 
name "serpiente"
 
org 100h
 
; saltar sobre la sección de datos:
jmp inicio 
 
; ------ sección de datos ------
 
s_tamano  equ      7
 
; las coordenadas de la serpiente
; (de la cabeza a la cola)
; queda un byte bajo, byte alto
; está arriba - [arriba, izquierda]
serpiente dw s_tamano dup ( 0)
 
cola dw      ?
 
; constantes de dirección
;          (códigos clave de BIOS):
izquierda equ 4bh
derecha equ 4dh
arriba equ 48h
abajo equ 50h
 
; dirección actual de la serpiente:
cur_dir db derecha
 
tiempo_espera dw 0
 
; mensaje de bienvenida
msg     db "==== cómo jugar ====", 0dh, 0ah             
        db "este juego se depuró en emu8086", 0dh, 0ah
        db "pero no está diseñado para ejecutarse en el emulador", 0dh, 0ah
        db "porque requiere una tarjeta de video y una CPU relativamente rápidas", 0dh, 0ah, 0ah
             
        db "si quieres ver cómo funciona realmente este juego", 0dh, 0ah
        db "ejecútelo en una computadora real (haga clic en externo-> ejecutar desde el menú).", 0dh, 0ah, 0ah
             
        db "puedes controlar la serpiente usando las teclas de flecha", 0dh, 0ah             
        db "todas las demás teclas detendrán a la serpiente", 0dh, 0ah, 0ah
             
        db "presione esc para salir", 0dh, 0ah
        db "====================", 0dh, 0ah, 0ah
        db "presione cualquier tecla para comenzar ... $"
 
; ------ sección de código ------
 
inicio:
 
; imprimir mensaje de bienvenida:
mov dx, offset msg
mov ah, 9
int 21h
 
 
; esperar cualquier clave:
mov ah, 00h
int 16h
 
 
; ocultar el cursor de texto:
mov ah, 1
mov ch, 2bh
mov cl, 0bh
int 10h          
 
 
bucle_juego:
 
; === seleccione la primera página de video
mov al, 0; número de página.
mov ah, 05h
int 10h
 
; === mostrar nueva cabeza:
mov dx, serpiente [0]
 
; colocar el cursor en dl, dh
mov ah, 02h
int 10h
 
; imprimir '*' en la ubicación:
mov      al, '*'
mov      ah, 09h
mov bl, 0eh; atributo.
mov cx, 1   ; solo carácter.
int 10h
 
; === mantener la cola:
mov ax, serpiente [s_tamano * 2 - 2]
mov cola, ax
 
call mover_serpiente
 
 
; === ocultar la cola vieja:
mov dx, cola
 
; colocar el cursor en dl, dh
mov ah, 02h
int 10h
 
; print '' en la ubicación:
mov      al, ' '
mov      ah, 09h
mov bl, 0eh; atributo.
mov cx, 1   ; solo carácter.
int 10h
 
 
 
comprobar_tecla:
 
; === comprobar los comandos del jugador:
mov ah, 01h
int 16h
jz no_hay_clave
 
mov ah, 00h
int 16h
 
cmp al, 1bh    ; esc - llave?
je  detener_juego;
 
mov     cur_dir, ah
 
no_hay_clave:
 
 
 
; === espere unos momentos aquí:
; obtener el número de tics del reloj
; (alrededor de 18 por segundo)
; desde la medianoche en cx: dx
mov     ah, 00h
int     1ah
cmp     dx, tiempo_espera
jb      comprobar_tecla:
add     dx, 4
mov     tiempo_espera, dx
 
 
 
; === ciclo de juego eterno:
jmp     bucle_juego
 
 
detener_juego:
 
; mostrar el cursor hacia atras:
mov     ah, 1
mov     ch, 0bh
mov     cl, 0bh
int     10h
 
ret
 
; ------ sección de funciones ------
 
; este procedimiento crea el
; animación moviendo todas las serpientes
; partes del cuerpo un paso a la cola,
; la vieja cola se va:
; [última parte (cola)] -> desaparece
; [parte i] -> [parte i + 1]
; ....
 
mover_serpiente proc cerca
 
; establecer es en el segmento de información de BIOS: 
mov     ax , 40h    
mov     es, ax
 
  ; punto di a la cola
  mov   di, s_tamano * 2 - 2
  ; mover todas las partes del cuerpo
  ; (el último simplemente se va)
  mov   cx, s_tamano-1
mover_arreglo:
  mov   ax, serpiente [di-2]
  mov   serpiente [di], ax
  sub   di, 2
  loop  mover_arreglo
 
 
cmp     cur_dir, izquierda
  je    mover_izquierda
cmp     cur_dir, derecha
  je    mover_derecha
cmp     cur_dir, arriba
  je    mover_arriba
cmp     cur_dir, abajo
  je    mover_abajo
 
jmp     detener_movimiento       ; sin dirección.
 
 
mover_izquierda:
  mov   al, b.serpiente [0]
  dec   al
  mov   b.serpiente [0], al  
  cmp   al, -1
  jne   detener_movimiento      
  mov   al, es: [4ah]; número de columna.
  dec   al
  mov   b.serpiente [0], al; volver a la derecha.
  jmp   detener_movimiento
 
mover_derecha:
  mov   al, b.serpiente [0]
  inc   al
  mov   b.serpiente [0], al  
  cmp   al, es: [4ah]; número de columna .  
  jb    detener_movimiento
  mov   b.serpiente [0], 0; volver a la izquierda.
  jmp   detener_movimiento
 
mover_arriba:
  mov   al, b.serpiente [1]
  dec   al
  mov   b.serpiente [1], al  
  cmp   al, -1
  jne   detener_movimiento
  mov   al, es: [84h]; número de fila -1.
  mov   b. serpiente [1], al; volver al fondo.
  jmp   detener_movimiento
 
mover_abajo:
  mov   al, b.serpiente [1]
  inc   al
  mov   b.serpiente [1], al
  cmp   al, es : [84h]; número de fila -1.
  jbe   detener_movimiento
  mov   b.serpiente [1], 0; volver a la cima.
  jmp   detener_movimiento
 
detener_movimiento:
  ret
mover_serpiente endp
