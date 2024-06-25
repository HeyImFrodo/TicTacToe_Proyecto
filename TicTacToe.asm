.data

.text

main:

    jal dibujarTablero

    li $v0 10
    syscall

dibujarTablero:

    # Color blanco para las lineas en hexadecimal
    li $t1, 0xFFFFFF

    # Direccion por defecto del tablero (bitmap)
    lui $t0, 0x1001

# Empieza dibujando las lineas horizontales

    li $t5, 1024
    li $t6, 80
    mult $t5, $t6
    mflo $t6

    # VERTICAL
    add $t0, $t0, $t6
    
    # HORIZONTAL
    addi $t0, $t0, 56
    # contador
    li $t2, 0
    
    primeraHorizontal:
        sw $t1, 0($t0)

        addi $t0, $t0, 4

        # Aumentar contador
        addi $t2, $t2, 1
        bne $t2, 224, primeraHorizontal
        
    # Pasa a la segunda linea
    lui $t0, 0x1001

    li $t5, 1024
    li $t6, 150
    mult $t5, $t6
    mflo $t6

    #VERTICAL
    add $t0, $t0, $t6
    
    #Horizontal
    addi $t0, $t0, 56
    li $t2, 0
    
    segundaHorizontal:
        sw $t1, 0($t0)
        addi $t0, $t0, 4
        addi $t2, $t2, 1
        bne $t2, 224, segundaHorizontal

# Ahora dibuja las lineas verticales

    lui $t0, 0x1001

    li $t6, 10
    mult $t5, $t6
    mflo $t6

    # VERTICAL
    add $t0, $t0, $t6

    # HORIZONTAL
    addi $t0, $t0, 320
    li $t2, 0
    primeraVertical:
        addi $t0, $t0, 1024
        sw $t1, 0($t0)
        addi $t2, $t2, 1
        bne $t2, 200, primeraVertical
        
    # Pasa a la segunda linea
    lui $t0, 0x1001
    
    # HORIZONTAL
    addi $t0, $t0, 660
    li $t2, 0
    
    # VERTICAL
    li $t6, 10
    mult $t5, $t6
    mflo $t6
    add $t0, $t0, $t6

    segundaVertical:
        addi $t0, $t0, 1024
        sw $t1, 0($t0)
        addi $t2, $t2, 1
        bne $t2, 200, segundaVertical

        jr $ra