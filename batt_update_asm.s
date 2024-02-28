# Connell Hagen (hage0686), I worked alone on all submitted code.

.text
.global  set_batt_from_ports
        
set_batt_from_ports: # rdi = batt : batt_t*
    movw    BATT_VOLTAGE_PORT(%rip), %cx # rcx = BATT_VOLTAGE_PORT
    movb    BATT_STATUS_PORT(%rip), %dl # rdx = BATT_STATUS_PORT

    // if BATT_VOLTAGE_PORT < 0 then return -1, else continue
    cmpw    $0, %cx
    jge     .positive_voltage
    movq    $1, %rax
    ret

    .positive_voltage:
    movw    %cx, %bx # copying BATT_VOLTAGE_PORT in rbx
    shrw    $1, %bx # right shifts BATT_VOLTAGE_PORT by 1
    movw    %bx, 0(%rdi) # batt->mlvolts = BATT_VOLTAGE_PORT >> 1

    cmpw    $7600, %cx # jump if BATT_VOLTAGE_PORT >= 7600
    jge     .P1
    cmpw    $6000, %cx # jump if BATT_VOLTAGE_PORT <= 6000
    jle     .P2
    jmp     .P3 # jump if BATT_VOLTAGE_PORT is in standard range

    .P1:
    movb    $100, 2(%rdi) # batt->percent = 100
    jmp     .Pcont
    .P2:
    movb    $0, 2(%rdi) # batt->percent = 0
    jmp     .Pcont
    .P3:
    subw    $3000, %bx
    shrw    $3, %bx
    movb    %bl, 2(%rdi) # batt->percent = ((BATT_VOLTAGE_PORT >> 1) - 3000) >> 3
    
    .Pcont: # continuation after handling battery->percent
    movsbl  %dl, %edx # converting BATT_STATUS_PORT from byte to doubleworld (int)
    movl    $1, %ecx
    shll    $4, %ecx # rcx = 1 << 4
    andl    %edx, %ecx # ecx = fourth_bit
    cmpl    $0, %ecx
    jne     .M1 # jump if fourth_bit is not zero
    movb    $2, 3(%rdi)  # if fourth_bit is zero, set batt->mode = 2
    jmp     .Mcont
    .M1:
    movb    $1, 3(%rdi) # fourth_bit isn't zero, set batt->mode = 1

    .Mcont:
    movq    $0, %rax # return 0 on success
    ret                                    


.data

// binary equivalents for the display digits
digit_masks:
    .int 0b0111111 # 0
    .int 0b0000110 # 1
    .int 0b1011011 # 2
    .int 0b1001111 # 3
    .int 0b1100110 # 4
    .int 0b1101101 # 5
    .int 0b1111101 # 6
    .int 0b0000111 # 7
    .int 0b1111111 # 8
    .int 0b1101111 # 9
    .int 0b0000000 # empty

.text
.global  set_display_from_batt

set_display_from_batt: # rdi = batt : batt_t, rsi = display : int*
    movq    $0, %r11 # set r11 to 0 to prepare for shifting, *display will be set to r11 at the end

    // r8b = batt.percent of rdi (byte 2)
    movq    %rdi, %r8
    shlq    $40, %r8
    shrq    $56, %r8

    // r12w = batt.mlvolts of rdi (bytes 0-1)
    pushq   %r12
    movq    %rdi, %r12
    shlq    $48, %r12
    shrq    $48, %r12

    // r13b = batt.mode of rdi (byte 3)
    pushq   %r13
    movq    %rdi, %r13
    shlq    $32, %r13
    shrq    $56, %r13

    
    cmpb    $90, %r8b # jump if batt->percent >= 90
    jge     .BP90
    cmpb    $70, %r8b # jump if batt->percent >= 70
    jge     .BP70
    cmpb    $50, %r8b # jump if batt->percent >= 50
    jge     .BP50
    cmpb    $30, %r8b # jump if batt->percent >= 30
    jge     .BP30
    cmpb    $5, %r8b # jump if batt->percent >= 5
    jge     .BP5
    jmp     .BPLow # jump if batt->percent < 5

    .BP90:
    orq     $0b11111, %r11
    jmp     .BPCont
    .BP70:
    orq     $0b01111, %r11
    jmp     .BPCont
    .BP50:
    orq     $0b00111, %r11
    jmp     .BPCont
    .BP30:
    orq     $0b00011, %r11
    jmp     .BPCont
    .BP5:
    orq     $0b00001, %r11
    jmp     .BPCont
    .BPLow:
    orq     $0b00000, %r11

    .BPCont:
    cmpb    $1, %r13b
    je      .BattMode1 # jump if batt->mode == 1
    jmp     .BattMode2 # jump if batt->mode == 2

    .BattMode1: # percentage mode
    // divides batt.percent by 10 for last digit modulus and second digit int division
    movw    $0, %dx
    movzbw  %r8b, %ax
    movw    $10, %bx # prepare divisor
    idivw   %bx
    pushw   %dx # last digit

    movw    $0, %dx
    idivw   %bx
    pushw   %dx # second digit

    movw    $0, %dx
    movzbw  %r8b, %ax
    movw    $100, %bx # prepare divisor
    idivw   %bx
    pushw   %ax # first digit


    movb    $0, %r8b # r8 = i = 0
    movw    $0, %r10w # r10 = digits_started = 0
    leaq    digit_masks(%rip), %r9 
    .L1: # for(int i = 0; i < 3; i++)
    popw    %dx # next digit
    movswq  %dx, %rdx

    cmpb    $2, %r8b
    movw    $1, %cx # prepare constant 1 for conditional moving
    cmove   %cx, %r10w # if i == 2, digits_started = 1
    cmpq    $0, %rdx
    cmovne  %cx, %r10w # if rdx is nonzero, digits_started = 1
    cmpw    $1, %r10w
    je      .digits_started # jump if digits_started = 1

    // if digits_started == 0, set the current digit to blank
    movq    $11, %rdx

    .digits_started:
    leaq    (%r9, %rdx, 4), %rcx # %rcx = digit_masks[digit]
    shlq    $7, %r11
    movq    (%rcx), %rcx
    orq     %rcx, %r11 # shifts display left by 7, and ORs the proper bitmask for the digit

    // loop check
    inc     %r8b
    cmpb    $3, %r8b
    jl      .L1

    // shifts display left 3 and adds the proper suffix
    shlq    $3, %r11
    orq     $0b001, %r11

    jmp     .BattModeCont

    .BattMode2: # voltage mode, NOTE: the division/modulus is wrong
    // divides batt->mlvolts by 10, then mod 10 for last digit
    movw    $0, %r10w # r10 = 0 = digit_3_rounding
    movw    $0, %dx
    movw    %r12w , %ax
    movw    $10, %bx # prepare divisor
    idivw   %bx # get int quotient
    cmpw    $5, %dx # compare hanging digit (4) to 5 for rounding purposes
    movw    $1, %cx # prepare constant for conditional move
    cmovge  %cx, %r10w # r10 = 1 = digit_3_rounding IF the hanging digit >= 5

    movw    $0, %dx
    idivw   %bx # get int quotient mod 10
    addw    %r10w, %dx # rounds final digit
    pushw   %dx # pushes final digit on stack

    // divides batt->mlvolts by 100, then mod 10 for second digit
    movw    $0, %dx
    movw    %r12w, %ax
    movw    $100, %cx # prepare divisor
    idivw   %cx # get int quotient
    movw    $0, %dx
    idivw   %bx # get int quotient mod 10
    pushw   %dx # pushes second digit on stack

    // divides batt->mlvolts by 1000 for first digit
    movw    $0, %dx
    movw    %r12w, %ax
    movw    $1000, %cx # prepare divisor
    idivw   %cx # get int quotient
    pushw   %ax # pushes first digit on stack

    movb    $0, %r8b # r8 = i = 0
    leaq    digit_masks(%rip), %r9 
    .L2: # for(int i = 0; i < 3; i++)
    popw    %dx # next digit
    movswq  %dx, %rdx
    leaq    (%r9, %rdx, 4), %rcx # %rcx = digit_masks[digit]
    shlq    $7, %r11
    movq    (%rcx), %rcx
    orq     %rcx, %r11 # shifts display left by 7, and ORs the proper bitmask for the digit

    // loop checking
    inc     %r8b
    cmpb    $3, %r8b
    jl      .L2

    // shifts display left 3 and adds the proper suffix
    shlq    $3, %r11
    orq     $0b110, %r11

    .BattModeCont:
    movl    %r11d, (%rsi)
    movq    $0, %rax
    popq    %r13
    popq    %r12
    ret


.text
.global batt_update
   
batt_update:
    movq    $0, %rdx # int display
    movq    $0, %rcx # batt_t battery

    pushq   %rdx
    pushq   %rcx

    movq    %rsp, %rdi # rdi = address of battery on stack
    call    set_batt_from_ports
    cmpq    $0, %rax # return 1 if anything but 0 is returned
    je      .NO_ERROR1
    popq    %rdx
    popq    %rdx
    jmp     .ERROR

    .NO_ERROR1:
    popq    %rcx # pop battery
    movq    %rcx, %rdi # rdi = battery, not a pointer
    movq    %rsp, %rsi # rsi = address of display on stack
    call    set_display_from_batt
    cmpq    $0, %rax # return 1 if anything but 0 is returned
    je      .NO_ERROR2
    popq    %rdx
    jmp     .ERROR

    .NO_ERROR2:
    popq    %rdx
    movl    %edx, BATT_DISPLAY_PORT(%rip)

    movq    $0, %rax
    ret

    .ERROR:
    movq    $1, %rax
    ret
