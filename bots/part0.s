# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1


# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

OTHER_X                 = 0xffff00a0
OTHER_Y                 = 0xffff00a4

TIMER                   = 0xffff001c
GET_MAP                 = 0xffff2008

REQUEST_PUZZLE          = 0xffff00d0  ## Puzzle
SUBMIT_SOLUTION         = 0xffff00d4  ## Puzzle

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800       ## Puzzle
REQUEST_PUZZLE_ACK      = 0xffff00d8  ## Puzzle

FALLING_INT_MASK        = 0x200
FALLING_ACK             = 0xffff00f4

STOP_FALLING_INT_MASK   = 0x400
STOP_FALLING_ACK        = 0xffff00f8

POWERWASH_ON            = 0xffff2000
POWERWASH_OFF           = 0xffff2004

GET_WATER_LEVEL         = 0xffff201c

MMIO_STATUS             = 0xffff204c

.data
### Puzzle
board:     .space 512
#### Puzzle
puzzle_received: .byte 0
has_puzzle: .word 0
has_timer: .byte 0
has_bonked: .byte 0
# -- string literals --
.text
main:
    sub $sp, $sp, 8
    sw  $ra, 0($sp)

    # Construct interrupt mask
    li      $t4, 0
    or      $t4, $t4, TIMER_INT_MASK            # enable timer interrupt
    or      $t4, $t4, BONK_INT_MASK             # enable bonk interrupt
    or      $t4, $t4, REQUEST_PUZZLE_INT_MASK   # enable puzzle interrupt
    or      $t4, $t4, 1 # global enable
    mtc0    $t4, $12

    li $t1, 0
    sw $t1, ANGLE
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t2, 0
    sw $t2, VELOCITY






loop: # Once done, enter an infinite loop so that your bot can be graded by QtSpimbot once 10,000,000 cycles have elapsed
    jal puzzle_part
    li $t0, 0x00040000
    sw $t0, POWERWASH_ON

go_right:  
    lw $t5, BOT_X
    beq $t5, 312, go_left
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 0
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_right

 go_left:
    lw $t5, BOT_X
    beq $t5, 296, go_up
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 180
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_left

go_up:
    lw $t5, BOT_Y
    beq $t5, 216, next
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 270
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_up

next:
    jal puzzle_part
    li $t0, 0x00040000
    sw $t0, POWERWASH_ON
    j go_down

go_down:
    lw $t5, BOT_Y
    beq $t5, 312, next_2
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 90
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_down

next_2:
    jal puzzle_part
    li $t0, 0x00040000
    sw $t0, POWERWASH_ON
    j go_left_2

 go_left_2:
    lw $t5, BOT_X
    beq $t5, 16, go_up_2
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 180
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_left_2

go_up_2:
    lw $t5, BOT_Y
    beq $t5, 216, next_3
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 270
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_up_2

next_3:
    jal puzzle_part
    li $t0, 0x00040000
    sw $t0, POWERWASH_ON
    j go_right_2

 go_right_2:
    lw $t5, BOT_X
    beq $t5, 56, go_up_3
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 0
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_right_2

go_up_3:
    lw $t5, BOT_Y
    beq $t5, 48, next_4
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 270
    sw $t1, ANGLE
    li $t2, 8
    sw $t2, VELOCITY
    j go_up_3

next_4:
    jal puzzle_part
    li $t0, 0x00040000
    sw $t0, POWERWASH_ON
    j else

else:
    li $t1, 1
    sw $t1, ANGLE_CONTROL
    li $t1, 180
    sw $t1, ANGLE
    j loop

puzzle_part:
    sub $sp, $sp, 8
    sw $ra, 0($sp)
    sw $s0, 4($sp)

    li $s0, 0
    for:
        bge $s0, 2, out_for
        #li puzzle_received, 0
        li $t5, 0
        sb $t5, puzzle_received
        la $t5, board
        sw $t5, REQUEST_PUZZLE
        while:
            lb $t1, puzzle_received
            #beq $t1, 1, while
            bnez $t1, out_while
            j while
        out_while:
        move $a0, $t5
        jal quant_solve
        la $t5, board
        sw $t5, SUBMIT_SOLUTION
        add $s0, $s0, 1
        j for
out_for:
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    add $sp, $sp, 8
    jr $ra

.kdata
chunkIH:    .space 40
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
    move    $k1, $at        # Save $at
                            # NOTE: Don't touch $k1 or else you destroy $at!
.set at
    la      $k0, chunkIH
    sw      $a0, 0($k0)        # Get some free registers
    sw      $v0, 4($k0)        # by storing them to a global variable
    sw      $t0, 8($k0)
    sw      $t1, 12($k0)
    sw      $t2, 16($k0)
    sw      $t3, 20($k0)
    sw      $t4, 24($k0)
    sw      $t5, 28($k0)

    # Save coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    mfhi    $t0
    sw      $t0, 32($k0)
    mflo    $t0
    sw      $t0, 36($k0)

    mfc0    $k0, $13                # Get Cause register
    srl     $a0, $k0, 2
    and     $a0, $a0, 0xf           # ExcCode field
    bne     $a0, 0, non_intrpt


interrupt_dispatch:                 # Interrupt:
    mfc0    $k0, $13                # Get Cause register, again
    beq     $k0, 0, done            # handled all outstanding interrupts

    and     $a0, $k0, BONK_INT_MASK     # is there a bonk interrupt?
    bne     $a0, 0, bonk_interrupt

    and     $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
    bne     $a0, 0, timer_interrupt

    and     $a0, $k0, REQUEST_PUZZLE_INT_MASK
    bne     $a0, 0, request_puzzle_interrupt

    and     $a0, $k0, FALLING_INT_MASK
    bne     $a0, 0, falling_interrupt

    and     $a0, $k0, STOP_FALLING_INT_MASK
    bne     $a0, 0, stop_falling_interrupt

    li      $v0, PRINT_STRING       # Unhandled interrupt types
    la      $a0, unhandled_str
    syscall
    j       done

bonk_interrupt:
    sw      $0, BONK_ACK
    la      $t0, has_bonked
    li      $t1, 1
    sb      $t1, 0($t0)
    #Fill in your bonk handler code here
    j       interrupt_dispatch      # see if other interrupts are waiting

timer_interrupt:
    sw      $0, TIMER_ACK
    #Fill your timer interrupt code here
    j        interrupt_dispatch     # see if other interrupts are waiting

request_puzzle_interrupt:
    sw      $0, REQUEST_PUZZLE_ACK
    #Fill in your puzzle interrupt code here
    li $t0, 1
    sw $t0, REQUEST_PUZZLE_ACK
    sb $t0, puzzle_received
    j       interrupt_dispatch

falling_interrupt:
    sw      $0, FALLING_ACK
    #Fill in your respawn handler code here
    j       interrupt_dispatch

stop_falling_interrupt:
    sw      $0, STOP_FALLING_ACK
    #Fill in your respawn handler code here
    j       interrupt_dispatch

non_intrpt:                         # was some non-interrupt
    li      $v0, PRINT_STRING
    la      $a0, non_intrpt_str
    syscall                         # print out an error message
    # fall through to done

done:
    la      $k0, chunkIH

    # Restore coprocessor1 registers!
    # If you don't do this and you decide to use division or multiplication
    #   in your main code, and interrupt handler code, you get WEIRD bugs.
    lw      $t0, 32($k0)
    mthi    $t0
    lw      $t0, 36($k0)
    mtlo    $t0

    lw      $a0, 0($k0)             # Restore saved registers
    lw      $v0, 4($k0)
    lw      $t0, 8($k0)
    lw      $t1, 12($k0)
    lw      $t2, 16($k0)
    lw      $t3, 20($k0)
    lw      $t4, 24($k0)
    lw      $t5, 28($k0)

.set noat
    move    $at, $k1        # Restore $at
.set at
    eret


### Puzzle Solver Constants
GRIDSIZE = 4
GRID_SQUARED = 16
ALL_VALUES = 65535
.data
symbollist:
  .byte '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'A' 'B' 'C' 'D' 'E' 'F' 'G'

# Below are the provided puzzle functionality.
.text
.globl quant_solve
quant_solve:
    sub  $sp, $sp, 28
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)
    sw   $a1, 8($sp)
    sw   $s0, 12($sp) # changed
    sw   $s1, 16($sp)
    sw   $s2, 20($sp) # solution
    sw   $s3, 24($sp)
    li $s0, 0
    li $s2, 1
    move $s1, $a0
quant_solve_first_do_while:
    jal  rule1
    move $s0, $v0
    beq  $s0, $zero, quant_solve_first_if
    move $a0, $s1
    jal  board_done
    beq  $v0, $zero, quant_solve_first_do_while
quant_solve_first_if:
    move $a0, $s1
    jal  board_done
    bne  $v0, $zero, quant_solve_second_if
    addi $s2, $s2, 1
quant_solve_second_do_while:
    move $a0, $s1
    jal  rule1
    move $s0, $v0
    move $a0, $s1
    jal  rule2
    or   $s0, $s0, $v0
    beq  $s0, $zero, quant_solve_second_if
    move $a0, $s1
    jal  board_done
    bne  $v0, $zero, quant_solve_second_do_while
quant_solve_second_if:
    move $a0, $s1
    jal  board_done
    li   $v0, 0
    beq  $v0, $zero, quant_solve_exit
    move $v0, $s2
quant_solve_exit:
    lw   $ra, 0($sp)
    lw   $a0, 4($sp)
    lw   $a1, 8($sp)
    lw   $s0, 12($sp) # changed
    lw   $s1, 16($sp) # iter
    lw   $s2, 20($sp) # solution
    lw   $s3, 24($sp)
    add  $sp, $sp, 28
    jr   $ra

.globl board_done
# BOARD_DONE
board_done:
    sub  $sp, $sp, 24
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)     # i
    sw   $s1, 8($sp)     # j
    sw   $s2, 12($sp)    # GRID_SIZE
    sw   $s3, 16($sp)    # arg
    sw   $a0, 20($sp)
    and  $s0, $zero, $s0
    and  $s1, $zero, $s1
    li   $s2, GRID_SQUARED
    move $s3, $a0
board_done_outer_loop:  # for (int i = 0 ; i < GRID_SQUARED ; ++ i)
    bge  $s0, $s2, board_done_exit
    li   $s1, 0
board_done_inner_loop:  # for (int j = 0 ; j < GRID_SQUARED ; ++ j)
    bge  $s1, $s2, board_done2_exit
    mul  $t0, $s0, GRID_SQUARED    # i * 16
    add  $t0, $t0, $s1   # i * GRID_SQUARED + j
    mul  $t0, $t0, 0x0002     # (i * GRID_SQUARED + j) * data_size
    add  $t0, $t0, $s3   # &board[i][j]
    lhu  $a0, 0($t0)
    jal  has_single_bit_set
    bne  $v0, $zero, board_done_not_if #if (!has_single_bit_set(board[i][j]))
    move $v0, $zero     # return false;
    j    board_done_finish
board_done_not_if:
    addi  $s1, $s1, 1
    j    board_done_inner_loop
board_done2_exit:
    addi  $s0, $s0, 1
    j    board_done_outer_loop
board_done_exit:
    li   $v0, 1 # return true;
board_done_finish:
    lw   $a0, 20($sp)
    lw   $s3, 16($sp)
    lw   $s2, 12($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $ra, 0($sp)
    add  $sp, $sp, 24
    jr $ra
# BOARD_DONE
# PRINT BOARD
print_board:
    sub  $sp, $sp, 20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)
    move $s0, $a0
    li   $s1, 0          # $s1 is i
pb_for_i:
    bge  $s1, GRID_SQUARED, pb_done_for_i
    li   $s2, 0          # $s2 is j
pb_for_j:
    bge  $s2, GRID_SQUARED, pb_done_for_j
    mul  $t0, $s1, GRID_SQUARED    # i * 16
    add  $t0, $t0, $s2   # i * 16 + j
    mul  $t0, $t0, 0x0002     # (i * 16 + j) * data_size
    add  $t0, $t0, $s0   # &board[i][j]
    lhu  $s3, 0($t0)     # value = board[i][j]

    move $a0, $s3
    jal  has_single_bit_set
    li   $a0, '*'        # c = '*'
    beq  $v0, $0, pb_skip_if # if (has_single_bit_set(value))
    move $a0, $s3
    jal  get_lowest_set_bit  # get_lowest_bit_set(value)
    add  $t0, $v0, 1         # c
    la   $t1, symbollist
    add  $t0, $t0, $t1
    lbu  $a0, 0($t0)
pb_skip_if:
    li   $v0, 11  #printf(c)
    syscall
    add  $s2, $s2, 1
    j    pb_for_j
pb_done_for_j:
    li   $a0, '\n'
    li   $v0, 11   #printf("\n")
    syscall
    add  $s1, $s1, 1
    j    pb_for_i
pb_done_for_i:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    add  $sp, $sp, 20
    
    jr   $ra
# PRINT BOARD
# HAS SINGLE BIT SET
has_single_bit_set:
    bne  $a0, $0, skip_hs_if_1
    li   $v0, 0
    jr   $ra
skip_hs_if_1:
    sub  $t0, $a0, 1
    and  $t0, $a0, $t0
    beq  $t0, $0, skip_hs_if2
    li   $v0, 0
    jr   $ra
skip_hs_if2:
    li   $v0, 1
    jr   $ra
# HAS SINGLE BIT SET
# GET LOWEST SET BIT
get_lowest_set_bit:
    li   $t0, 0
    li   $t1, 16
    li   $t2, 1
gl_for:
    bge  $t0, $t1, done_gl_loop
    and  $t3, $a0, $t2
    beq  $t3, $0, skip_gl_if
    move $v0, $t0
    jr   $ra
skip_gl_if:
    sll  $t2, $t2, 1
    add  $t0, $t0, 1
    j    gl_for
done_gl_loop:
    li   $v0, 0
    jr   $ra
# GET LOWEST SET BIT
# QUANT_SOLVE
# QUANT_SOLVE
# RULE 1
rule1:
    sub  $sp, $sp, 0x0020
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)     # board
    sw   $s1, 8($sp)     # changed
    sw   $s2, 12($sp)    # i
    sw   $s3, 16($sp)    # j
    sw   $s4, 20($sp)    # ii
    sw   $s5, 24($sp)    # value
    sw   $a0, 28($sp)    # saved a0
    move $s0, $a0
    li   $s1, 0          # $s1 is changed
    li   $s2, 0
r1_for_i:
    bge  $s2, GRID_SQUARED, r1_done_for_i
    li   $s3, 0
r1_for_j:
    bge  $s3, GRID_SQUARED, r1_done_for_j
    mul  $t0, $s2, GRID_SQUARED   # i * 16
    add  $t0, $t0, $s3   # i * 16 + j
    mul  $t0, $t0, 0x0002     # (i * 16 + j) * data_size
    add  $t0, $t0, $s0   # &board[i][j]
    lhu  $s5, 0($t0)     # board[i][j]
    move $a0, $s5
    jal  has_single_bit_set
    beq  $v0, $0, r1_inc_j
    li   $t1, 0          # k
r1_for_k:
    bge  $t1, GRID_SQUARED, r1_done_for_k
    beq  $t1, $s3, r1_skip_inner_if1
    mul  $t0, $s2, GRID_SQUARED    # i * 16
    add  $t0, $t0, $t1   # i * 16 + k
    mul  $t0, $t0, 0x0002     # (i * 16 + k) * data_size
    add  $t0, $t0, $s0   # &board[i][k]
    lhu  $t2, 0($t0)     # board[i][k]
    and  $t3, $s5, $t2   # board[i][k] & value
    beq  $t3, $0, r1_skip_inner_if1
    not  $t4, $s5        # ~value
    and  $t3, $t4, $t2   # 
    sh   $t3, 0($t0)     # board[i][k] = 
    li   $s1, 1
r1_skip_inner_if1:
    beq  $t1, $s2, r1_skip_inner_if2
    mul  $t0, $t1, GRID_SQUARED    # k * 16
    add  $t0, $t0, $s3   # k * 16 + j
    mul  $t0, $t0, 0x0002     # (k * 16 + j) * data_size
    add  $t0, $t0, $s0   # &board[k][j]
    lhu  $t2, 0($t0)     # board[k][j]
    and  $t3, $s5, $t2   # board[k][j] & value
    beq  $t3, $0, r1_skip_inner_if2
    not  $t4, $s5        # ~value
    and  $t3, $t4, $t2   # 
    sh   $t3, 0($t0)     # board[i][k] = 
    li   $s1, 1
r1_skip_inner_if2:
    
    add  $t1, $t1, 1
    j    r1_for_k
r1_done_for_k:
    move $a0, $s2
    jal  get_square_begin
    move $s4, $v0       # ii = get_square_begin(i)
    move $a0, $s3
    jal  get_square_begin
                        # jj = get_square_begin(j)
    move $t8, $s4       # k = ii
    add  $t5, $s4, 0x0004    # ii + GRIDSIZE
r1_for_k2:
    bge  $t8, $t5, r1_done_for_k2
    move $t9, $v0       # l = jj
    add  $t6, $v0, 0x0004    # jj + GRIDSIZE
r1_for_l:
    bge  $t9, $t6, r1_done_for_l
    bne  $t8, $s2, r1_skip_inner_if3
    bne  $t9, $s3, r1_skip_inner_if3
    j    r1_skip_inner_if4
r1_skip_inner_if3:
    mul  $t0, $t8, GRID_SQUARED    # k * 16
    add  $t0, $t0, $t9   # k * 16 + l
    mul  $t0, $t0, 0x0002     # (k * 16 + l) * data_size
    add  $t0, $t0, $s0   # &board[k][l]
    lhu  $t2, 0($t0)     # board[k][l]
    and  $t3, $s5, $t2   # board[k][l] & value
    beq  $t3, $0, r1_skip_inner_if4
    not  $t4, $s5        # ~value
    and  $t3, $t4, $t2   # 
    sh   $t3, 0($t0)     # board[i][k] = 
    li   $s1, 1
r1_skip_inner_if4:   
    add  $t9, $t9, 1
    j    r1_for_l
r1_done_for_l:
    add  $t8, $t8, 1
    j    r1_for_k2
r1_done_for_k2:
    nop
r1_inc_j:
    add  $s3, $s3, 1
    j    r1_for_j
r1_done_for_j:
    add  $s2, $s2, 1
    j    r1_for_i
r1_done_for_i:
    move $v0, $s1          # return changed
r1_return:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    lw   $s5, 24($sp)
    lw   $a0, 28($sp)    # saved a0
    add  $sp, $sp, 0x0020
    jr   $ra
# RULE 1
# RULE 2
rule2:
    sub  $sp, $sp, 36
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)     # board
    sw   $s1, 8($sp)     # changed
    sw   $s2, 12($sp)    # i
    sw   $s3, 16($sp)    # j
    sw   $s4, 20($sp)    # ii
    sw   $s5, 24($sp)    # value
    sw   $a0, 28($sp)    # saved a0
    sw   $s6, 0x0020($sp)    # &board[i][j]
    move $s0, $a0
    li   $s1, 0          # $s1 is changed
    li   $s2, 0
r2_for_i:
    bge  $s2, GRID_SQUARED, r2_done_for_i
    li   $s3, 0
r2_for_j:
    bge  $s3, GRID_SQUARED, r2_done_for_j
    mul  $t0, $s2, GRID_SQUARED   # i * 16
    add  $t0, $t0, $s3   # i * 16 + j
    mul  $t0, $t0, 0x0002     # (i * 16 + j) * data_size
    add  $t0, $t0, $s0   # &board[i][j]
    move $s6, $t0        # save &board[i][j]
    lhu  $s5, 0($t0)     # board[i][j]
    move $a0, $s5
    jal  has_single_bit_set
    bne  $v0, $0, r2_inc_j


##################
### first k loop #
##################
    li   $t8, 0         # jsum = 0
    li   $t9, 0         # isum = 0
    
    li   $t1, 0          # k
r2_for_k:
    bge  $t1, GRID_SQUARED, r2_done_for_k
    beq  $t1, $s3, r2_skip_inner_k_if1
    mul  $t0, $s2, GRID_SQUARED    # i * 16
    add  $t0, $t0, $t1   # i * 16 + k
    mul  $t0, $t0, 0x0002     # (i * 16 + k) * data_size
    add  $t0, $t0, $s0   # &board[i][k]
    lhu  $t2, 0($t0)     # board[i][k]
    or   $t8, $t2, $t8   # jsum |= board[i][k]
r2_skip_inner_k_if1:
    beq  $t1, $s2, r2_skip_inner_k_if2
    mul  $t0, $t1, GRID_SQUARED    # k * 16
    add  $t0, $t0, $s3   # k * 16 + j
    mul  $t0, $t0, 0x0002     # (k * 16 + j) * data_size
    add  $t0, $t0, $s0   # &board[k][j]
    lhu  $t2, 0($t0)     # board[k][j]
    or   $t9, $t2, $t9   # isum |= board[k][j]
r2_skip_inner_k_if2:
    add  $t1, $t1, 1
    j    r2_for_k
r2_done_for_k:


### if_else-if structure
    beq  $t8, ALL_VALUES, r2_skip_to_else_if
    not  $t2, $t8        # ~jsum
    and  $t2, $t2, ALL_VALUES
    sh   $t2, 0($s6)     # board[i][j] = &
    li   $s1, 1
    j    r2_inc_j
r2_skip_to_else_if:
    beq  $t9, ALL_VALUES, r2_get_square_begin
    not  $t2, $t9        # ~isum
    and  $t2, $t2, ALL_VALUES
    sh   $t2, 0($s6)     # board[i][j] = &
    li   $s1, 1
    j    r2_inc_j


r2_get_square_begin:
    move $a0, $s2
    jal  get_square_begin
    move $s4, $v0       # ii = get_square_begin(i)
    move $a0, $s3
    jal  get_square_begin
                        # jj = get_square_begin(j)
                        
    li   $t7, 0         # sum = 0
    move $t8, $s4       # k = ii
    add  $t5, $s4, 0x0004    # ii + GRIDSIZE
r2_for_k2:
    bge  $t8, $t5, r2_done_for_k2
    move $t9, $v0       # l = jj
    add  $t6, $v0, 0x0004    # jj + GRIDSIZE
r2_for_l:
    bge  $t9, $t6, r2_done_for_l
    bne  $t8, $s2, r2_skip_inner_if3
    bne  $t9, $s3, r2_skip_inner_if3
    j    r2_skip_inner_if4
r2_skip_inner_if3:
    mul  $t0, $t8, GRID_SQUARED    # k * 16
    add  $t0, $t0, $t9   # k * 16 + l
    mul  $t0, $t0, 0x0002     # (k * 16 + l) * data_size
    add  $t0, $t0, $s0   # &board[k][l]
    lhu  $t2, 0($t0)     # board[k][l]
    or   $t7, $t2, $t7

r2_skip_inner_if4:   
    add  $t9, $t9, 1
    j    r2_for_l
r2_done_for_l:
    add  $t8, $t8, 1
    j    r2_for_k2
r2_done_for_k2:

    beq  $t7, ALL_VALUES, r2_inc_j
    not  $t2, $t7        # ~sum
    and  $t2, $t2, ALL_VALUES
    sh   $t2, 0($s6)     # board[i][j] = &
    li   $s1, 1
    
r2_inc_j:
    add  $s3, $s3, 1
    j    r2_for_j
r2_done_for_j:
    add  $s2, $s2, 1
    j    r2_for_i
r2_done_for_i:
    move $v0, $s1          # return changed
r2_return:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    lw   $s5, 24($sp)
    lw   $a0, 28($sp)    # saved a0
    lw   $s6, 0x0020($sp)    # &board[i][j]
    add  $sp, $sp, 36
    jr   $ra
# RULE 2
# GET_SQUARE_BEGIN
get_square_begin:
    div $v0, $a0, GRIDSIZE
    mul $v0, $v0, GRIDSIZE
    jr  $ra
# GET_SQUARE_BEGIN