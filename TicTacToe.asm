.data
    display: .space 16384
    valores: .word 0, 0, 0, 0, 0, 0, 0, 0, 0
    jugador1_msg: .asciiz "Jugador 1, ingrese una posicion: "
    jugador2_msg: .asciiz "Jugador 2, ingrese una posicion: "
    invalida: .asciiz "El movimiento es invalido\n"
    empate: .asciiz "Juego empatado"
    ganador1_msg: .asciiz "Gano el jugador 1"
    ganador2_msg: .asciiz "Gano el jugador 2"
    
.text
main:
	la $s0, valores 
	li $s1, 1

	jal dibujarTablero

    jugador1:
        # Solicitar un numero
        li $v0, 4
        la $a0, jugador1_msg
        syscall
        
        # Registra la jugada
        li $v0, 5
        syscall
        move $a0, $v0

        move $s2, $v0
        
        # Revisa si el numero es valido
        jal validacion

        beq $v0, 1, jugadaValidada1

        # Si no es valida se vuelve a preguntar
        li $v0, 4
        la $a0, invalida
        syscall
        j jugador1
        
        # Si es valida se guarda y se dibuja en el bitmap display
        jugadaValidada1:
            li $a0, 1
            jal registrar

            move $a2, $s2
            jal dibujarX
            
            li $v1, 0

            # Revisa si el jugador 1 gano
            jal ganador1
            beq $v1, 1, salir
            
            # Revisa si el tablero esta lleno
            jal tableroLleno
            beq $v1, 1, salir

    jugador2:
        # Solicitar un numero
        li $v0, 4
        la $a0, jugador2_msg 
        syscall
        
        # Registra la jugada
        li $v0, 5
        syscall
        move $a0, $v0

        move $s3, $v0

        # Revisa si el numero el valido
        jal validacion

        beq $v0, 1, jugadaValidada2
        
        # Si no es valida se vuelve a preguntar
        li $v0, 4
        la $a0, invalida
        syscall
        j jugador2
        
        # Si es valida se guarda y se dibuja en el bitmap display
        jugadaValidada2:
        li $a0, 2
        jal registrar
        
        move $a2, $s3
        jal dibujarO
        
        li $v1, 0

        # Revisa si el jugador 2 gano
        jal ganador2
        beq $v1, 1, salir

        # Revisa si el tablero esta lleno
        jal tableroLleno
        
        beq $v1, 1, salir
        
        j jugador1
	
validacion:
	# Si numero >= 1
	move $t0, $a0
	bge $t0, 1, verificacion
	j jugadaInvalida

	# Si numero <= 9	
    verificacion:
        ble $t0, 9, jugadaValida
        j jugadaInvalida
	
	
    # Si es invalida retorna 0
    jugadaInvalida:	
        li $v0, 0
        jr $ra
        
    # Si es valida retorna 1
    jugadaValida:
        li $v0, 1
        jr $ra

## Registra la jugada hecha dependiendo del jugador
registrar:
	beq $a0, 1, jugada1
	beq $a0, 2, jugada2

    jugada1:
        # Aumenta el contador
        addi $s1, $s1, 1 
        la $t0, valores
        li $t1, 1
        li $t2, 4
        move $t3, $s2
        subu $t3, $t3, 1
        mult $t3, $t2
        mflo $t4
        add $t0, $t0, $t4
        sw $t1, 0($t0)
        jr $ra
        
    jugada2:
        # Aumenta el contador
        addi $s1, $s1, 1 
        la $t0, valores
        li $t1, 2
        li $t2, 4
        move $t3, $s3
        subu $t3, $t3, 1
        mult $t3, $t2
        mflo $t4
        add $t0, $t0, $t4
        sw $t1, 0($t0)
        jr $ra

## Verifica si quedo empate
tableroLleno:	
	li $t0, 10
	beq $s1, $t0, sinJugadas
	
	li $v1, 0
	jr $ra
	
    sinJugadas:
        li $a1, 0
        li $v0, 55
        la $a0, empate
        syscall
        
        li $v1, 1
        jr $ra

## Comprobar si gano el jugador 1
ganador1:
    # Verifica si el jugador 1 gano en las filas (horizontales)
	la $t0, valores
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	lw $t3, 8($t0)
	
    primeraFila_1:
        beq $t1, 1, segundaCasilla_primeraFila_1
        j segundaFila_1

        segundaCasilla_primeraFila_1:
            beq $t2, 1, terceraCasilla_primeraFila_1
            j segundaFila_1
            
        terceraCasilla_primeraFila_1:
            beq $t3, 1, ganaJugador1
            j segundaFila_1
        
    segundaFila_1:
        lw $t1, 12($t0)
        lw $t2, 16($t0)
        lw $t3, 20($t0)

        beq $t1, 1, segundaCasilla_segundaFila_1
        j terceraFila_1
        
        segundaCasilla_segundaFila_1:
            beq $t2, 1, terceraCasilla_segundaFila_1
            j terceraFila_1
            
        terceraCasilla_segundaFila_1:
            beq $t3, 1, ganaJugador1
            j terceraFila_1
	
    terceraFila_1:
        lw $t1, 24($t0)
        lw $t2, 28($t0)
        lw $t3, 32($t0)

        beq $t1, 1, segundaCasilla_terceraFila_1
        j primeraColumna_1
        
        segundaCasilla_terceraFila_1:
            beq $t2, 1, terceraCasilla_terceraFila_1
            j primeraColumna_1
            
        terceraCasilla_terceraFila_1:
            beq $t3, 1, ganaJugador1
            j primeraColumna_1

    # Verifica si el jugador 1 gano en las columnas (verticales)
    primeraColumna_1:
        lw $t1, 0($t0)
        lw $t2, 12($t0)
        lw $t3, 24($t0)

        beq $t1, 1, segundaCasilla_primeraColumna_1
        j segundaColumna_1
        
        segundaCasilla_primeraColumna_1:
            beq $t2, 1, terceraCasilla_primeraColumna_1
            j segundaColumna_1
            
        terceraCasilla_primeraColumna_1:
            beq $t3, 1, ganaJugador1
            j segundaColumna_1
	
    segundaColumna_1:
        lw $t1, 4($t0)
        lw $t2, 16($t0)
        lw $t3, 28($t0)

        beq $t1, 1, segundaCasilla_segundaColumna_1
        j terceraColumna_1
        
        segundaCasilla_segundaColumna_1:
            beq $t2, 1, terceraCasilla_segundaColumna_1
            j terceraColumna_1
            
        terceraCasilla_segundaColumna_1:
            beq $t3, 1, ganaJugador1
            j terceraColumna_1
        
    terceraColumna_1:
        lw $t1, 8($t0)
        lw $t2, 20($t0)
        lw $t3, 32($t0)

        beq $t1, 1, segundaCasilla_terceraColumna_1
        j primeraDiagonal_1
        
        segundaCasilla_terceraColumna_1:
            beq $t2, 1, terceraCasilla_terceraColumna_1
            j primeraDiagonal_1
            
        terceraCasilla_terceraColumna_1:
            beq $t3, 1, ganaJugador1
            j primeraDiagonal_1

    # Verifica si el jugador 1 gano en las diagonales
    primeraDiagonal_1:
        lw $t1, 0($t0)
        lw $t2, 16($t0)
        lw $t3, 32($t0)

        beq $t1, 1, segundaCasilla_primeraDiagonal_1
        j segundaDiagonal_1
        
        segundaCasilla_primeraDiagonal_1:
            beq $t2, 1, terceraCasilla_primeraDiagonal_1
            j segundaDiagonal_1
            
        terceraCasilla_primeraDiagonal_1:
            beq $t3, 1, ganaJugador1
            j segundaDiagonal_1
	
    segundaDiagonal_1:
        lw $t1, 8($t0)
        lw $t2, 16($t0)
        lw $t3, 24($t0)

        beq $t1, 1, segundaCasilla_segundaDiagonal_1
        j noGano1
        
        segundaCasilla_segundaDiagonal_1:
            beq $t2, 1, terceraCasilla_segundaDiagonal_1
            j noGano1
            
        terceraCasilla_segundaDiagonal_1:
            beq $t3, 1, ganaJugador1
            j noGano1
	
    noGano1:
        li $v1, 0
        jr $ra
        
    ganaJugador1:
        li $a1, 1
        li $v0, 55
        la $a0, ganador1_msg
        syscall

        li $v1, 1
        jr $ra

## Comprobar si gano el jugador 2
ganador2:
    # Verifica si el jugador 2 gano en las filas (horizontales)
	la $t0, valores
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	lw $t3, 8($t0)
	
    primeraFila_2:
        beq $t1, 2, segundaCasilla_primeraFila_2
        j segundaFila_2

        segundaCasilla_primeraFila_2:
            beq $t2, 2, terceraCasilla_primeraFila_2
            j segundaFila_2
            
        terceraCasilla_primeraFila_2:
            beq $t3, 2, ganaJugador2
            j segundaFila_2
        
    segundaFila_2:
        lw $t1, 12($t0)
        lw $t2, 16($t0)
        lw $t3, 20($t0)

        beq $t1, 2, segundaCasilla_segundaFila_2
        j terceraFila_2
        
        segundaCasilla_segundaFila_2:
            beq $t2, 2, terceraCasilla_segundaFila_2
            j terceraFila_2
            
        terceraCasilla_segundaFila_2:
            beq $t3, 2, ganaJugador2
            j terceraFila_2
	
    terceraFila_2:
        lw $t1, 24($t0)
        lw $t2, 28($t0)
        lw $t3, 32($t0)

        beq $t1, 2, segundaCasilla_terceraFila_2
        j primeraColumna_2
        
        segundaCasilla_terceraFila_2:
            beq $t2, 2, terceraCasilla_terceraFila_2
            j primeraColumna_2
            
        terceraCasilla_terceraFila_2:
            beq $t3, 2, ganaJugador2
            j primeraColumna_2

    # Verifica si el jugador 2 gano en las columnas (verticales)
    primeraColumna_2:
        lw $t1, 0($t0)
        lw $t2, 12($t0)
        lw $t3, 24($t0)

        beq $t1, 2, segundaCasilla_primeraColumna_2
        j segundaColumna_2
        
        segundaCasilla_primeraColumna_2:
            beq $t2, 2, terceraCasilla_primeraColumna_2
            j segundaColumna_2
            
        terceraCasilla_primeraColumna_2:
            beq $t3, 2, ganaJugador2
            j segundaColumna_2
	
    segundaColumna_2:
        lw $t1, 4($t0)
        lw $t2, 16($t0)
        lw $t3, 28($t0)

        beq $t1, 2, segundaCasilla_segundaColumna_2
        j terceraColumna_2
        
        segundaCasilla_segundaColumna_2:
            beq $t2, 2, terceraCasilla_segundaColumna_2
            j terceraColumna_2
            
        terceraCasilla_segundaColumna_2:
            beq $t3, 2, ganaJugador2
            j terceraColumna_2
        
    terceraColumna_2:
        lw $t1, 8($t0)
        lw $t2, 20($t0)
        lw $t3, 32($t0)

        beq $t1, 2, segundaCasilla_terceraColumna_2
        j primeraDiagonal_2
        
        segundaCasilla_terceraColumna_2:
            beq $t2, 2, terceraCasilla_terceraColumna_2
            j primeraDiagonal_2
            
        terceraCasilla_terceraColumna_2:
            beq $t3, 2, ganaJugador2
            j primeraDiagonal_2

    # Verifica si el jugador 2 gano en las diagonales
    primeraDiagonal_2:
        lw $t1, 0($t0)
        lw $t2, 16($t0)
        lw $t3, 32($t0)

        beq $t1, 2, segundaCasilla_primeraDiagonal_2
        j segundaDiagonal_2
        
        segundaCasilla_primeraDiagonal_2:
            beq $t2, 2, terceraCasilla_primeraDiagonal_2
            j segundaDiagonal_2
            
        terceraCasilla_primeraDiagonal_2:
            beq $t3, 2, ganaJugador2
            j segundaDiagonal_2
	
    segundaDiagonal_2:
        lw $t1, 8($t0)
        lw $t2, 16($t0)
        lw $t3, 24($t0)

        beq $t1, 2, segundaCasilla_segundaDiagonal_2
        j noGano2
        
        segundaCasilla_segundaDiagonal_2:
            beq $t2, 2, terceraCasilla_segundaDiagonal_2
            j noGano2
            
        terceraCasilla_segundaDiagonal_2:
            beq $t3, 2, ganaJugador2
            j noGano2
	
    noGano2:
        li $v1, 0
        jr $ra
        
    ganaJugador2:
        li $a1, 1
        li $v0, 55
        la $a0, ganador2_msg
        syscall

        li $v1, 1
        jr $ra

## Dibujar X (Ficha del jugador 1)
dibujarX:

    # Las dibuja en color rojo
    li $t0, 0xFF0000
    
    beq $a2, 1, x_uno

    beq $a2, 2, x_dos

    beq $a2, 3, x_tres
    
    beq $a2, 4, x_cuatro

    beq $a2, 5, x_cinco

    beq $a2, 6, x_seis
    
    beq $a2, 7, x_siete

    beq $a2, 8, x_ocho

    beq $a2, 9, x_nueve
    
    x_uno:
        li $t1 132
        x_uno_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 1148 x_uno_1
        
        li $t1 160
        x_uno_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 1148 x_uno_2
        
        jr $ra
	
    x_dos:
        li $t1 176
        x_dos_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 1148 x_dos_1
        
        li $t1 204
        x_dos_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 1148 x_dos_2
        
        jr $ra
	
    x_tres:
        li $t1 220
        x_tres_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 1148 x_tres_1
        
        li $t1 248
        x_tres_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 1148 x_tres_2
        
        jr $ra

    x_cuatro:
        li $t1 1540
        x_cuatro_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 2556 x_cuatro_1
        
        li $t1 1568
        x_cuatro_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 2556 x_cuatro_2
        
        jr $ra
	
    x_cinco:
        li $t1 1584
        x_cinco_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 2556 x_cinco_1
        
        li $t1 1612
        x_cinco_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 2556 x_cinco_2
        
        jr $ra
	
    x_seis:
        li $t1 1628
        x_seis_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 2556 x_seis_1
        
        li $t1 1656
        x_seis_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 2556 x_seis_2
        
        jr $ra
        
    x_siete:
        li $t1 2948
        x_siete_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 3964 x_siete_1
        
        li $t1 2976
        x_siete_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 3964 x_siete_2
        
        jr $ra
	
    x_ocho:
        li $t1 2992
        x_ocho_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 3964 x_ocho_1
        
        li $t1 3020
        x_ocho_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 3964 x_ocho_2
        
        jr $ra
        
    x_nueve:
        li $t1 3036
        x_nueve_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 132
        
        ble $t1 3964 x_nueve_1
        
        li $t1 3064
        x_nueve_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 124
        
        ble $t1 3964 x_nueve_2
            
        jr $ra
	
## Dibujar O (Ficha del jugador 2)
dibujarO:
    # Las dibuja en color verde				
    li $t0, 0x00FF00

    beq $a2, 1, o_uno

    beq $a2, 2, o_dos

    beq $a2, 3, o_tres

    beq $a2, 4, o_cuatro

    beq $a2, 5, o_cinco

    beq $a2, 6, o_seis
    
    beq $a2, 7, o_siete

    beq $a2, 8, o_ocho

    beq $a2, 9, o_nueve

    o_uno:
        # Horizontales
        li $t1 136
        o_uno_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 156 o_uno_h_1
        
        li $t1 1032
        o_uno_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1052 o_uno_h_2
        # Verticales
        li $t1 260
        o_uno_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 1024 o_uno_v_1
        
        li $t1 288
        o_uno_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 1024 o_uno_v_2
        
            jr $ra

    o_dos:
        # Horizontales
        li $t1 180
        o_dos_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 200 o_dos_h_1
        
        li $t1 1076
        o_dos_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1096 o_dos_h_2
        # Verticales
        li $t1 304
        o_dos_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 1024 o_dos_v_1
        
        li $t1 332
        o_dos_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 1024 o_dos_v_2
        
        jr $ra

    o_tres:
        # Horizontales
        li $t1 224
        o_tres_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 244 o_tres_h_1
        
        li $t1 1120
        o_tres_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1140 o_tres_h_2
        # Verticales
        li $t1 348
        o_tres_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 1024 o_tres_v_1
        
        li $t1 376
        o_tres_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 1024 o_tres_v_2
        
        jr $ra

    o_cuatro:
        # Horizontales
        li $t1 1544
        o_cuatro_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1564 o_cuatro_h_1
        
        li $t1 2440
        o_cuatro_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 2460 o_cuatro_h_2
        # Verticales
        li $t1 1668
        o_cuatro_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 2432 o_cuatro_v_1
        
        li $t1 1696
        o_cuatro_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 2432 o_cuatro_v_2
        
        jr $ra

    o_cinco:
        # Horizontales
        li $t1 1588
        o_cinco_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1608 o_cinco_h_1
        
        li $t1 2484
        o_cinco_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 2504 o_cinco_h_2
        # Verticales
        li $t1 1712
        o_cinco_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 2432 o_cinco_v_1
        
        li $t1 1740
        o_cinco_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 2432 o_cinco_v_2
        
        jr $ra

    o_seis:
        # Horizontales
        li $t1 1632
        o_seis_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1652 o_seis_h_1
        
        li $t1 2528
        o_seis_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 2548 o_seis_h_2
        # Verticales
        li $t1 1756
        o_seis_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 2432 o_seis_v_1
        
        li $t1 1784
        o_seis_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 2432 o_seis_v_2
        
        jr $ra

    o_siete:
        # Horizontales
        li $t1 2952
        o_siete_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 2972 o_siete_h_1
        
        li $t1 3848
        o_siete_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 3868 o_siete_h_2
        # Verticales
        li $t1 3076
        o_siete_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 3840 o_siete_v_1
        
        li $t1 3104
        o_siete_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 3840 o_siete_v_2
        
        jr $ra
	
    o_ocho:
        # Horizontales
        li $t1 2996
        o_ocho_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 3016 o_ocho_h_1
        
        li $t1 3892
        o_ocho_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 3912 o_ocho_h_2
        # Verticales
        li $t1 3120
        o_ocho_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 3840 o_ocho_v_1
        
        li $t1 3148
        o_ocho_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 3840 o_ocho_v_2
        
        jr $ra
	
    o_nueve:
        # Horizontales
        li $t1 3040
        o_nueve_h_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 3060 o_nueve_h_1
        
        li $t1 3936
        o_nueve_h_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 3956 o_nueve_h_2
        # Verticales
        li $t1 3164
        o_nueve_v_1:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 3840 o_nueve_v_1
        
        li $t1 3192
        o_nueve_v_2:	
            sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 3840 o_nueve_v_2
        
        jr $ra

## Aqui se dibuja el tablero
dibujarTablero:

    li $t0 0xffffff
    li $t1 40

    primeraColumna:
        sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 4096 primeraColumna

            
    li $t1 84
    segundaColumna:
        sw $t0 display($t1)
        
        addi $t1 $t1 128
        
        ble $t1 4096 segundaColumna
        
    li $t1 1280
    primeraFila:
        sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 1407 primeraFila

    li $t1 2688
    segundaFila:
        sw $t0 display($t1)
        
        addi $t1 $t1 4
        
        ble $t1 2815 segundaFila
            jr $ra

salir:
    li $v0 10
    syscall
