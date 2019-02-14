.data
	msg: .asciiz "Introduce un numero (0 para finalizar): "
	salto: .asciiz "\n"
	memory_msg: .asciiz "Sin memoria."
.text
main:
	li $s0, 0
loop:
	li $v0, 4
	la $a0, msg
	syscall
	li $v0, 5
	syscall

	beqz $v0, end_loop

	move $a0, $s0	# a0=first
	move $a1, $v0	# a1=val
	jal insert_in_order	# insert(first, val) // Devuelve el primer nodo de la lista
	move $s0, $v0

	b loop
end_loop:
	move $a0, $s0	# void print(node_t *node)
	jal print
	b exit
no_memory:
	li $v0, 4
	la $a0, memory_msg
	syscall
exit:
	li $v0, 10
	syscall
create:	#node_t * create(int val, node_t *next)
	addi $sp, $sp, -32
	sw $ra, 20($sp)
	sw $fp, 16($sp)
	addi $fp, $sp, 28
	sw $a0, 0($fp)

	li $a0, 8
	li $v0, 9
	syscall

	beqz $v0, no_memory

	lw $a0, 0($fp)

	sw $a0, 0($v0)
	sw $a1, 4($v0)

	lw $ra, 20($sp)
	lw $fp, 16($sp)
	addi $sp, $sp, 32
	jr $ra
insert_in_order:	# node_t * insert_in_order(node_t *first, int val)
	addi $sp, $sp, -32
	sw $ra, 20($sp)
	sw $fp, 16($sp)
	addi $fp, $sp, 28
	sw $a0, 0($fp)
	sw $a1, -4($fp)
	
	move $a0, $a1
	li $a1, 0
	jal create	# v0=nuevo nodo
	
	lw $a0, 0($fp)	# a0=first
	lw $a1, -4($fp)	# a1=val
	beqz $a0, end_insert_in_order	# La lista esta vacia y el nuevo nodo es el unico.
	lw $t0, 0($a0)	# t0=first->val
	blt $a1, $t0, first	# El valor del nuevo nodo es menor que el del primero de la lista
	beq $a1, $t0, equal	# El valor del nuevo nodo es igual que el del primero de la lista
	lw $t0, 4($a0)	# t0=first->next
insert_loop:
	beqz $t0, last	# Si t0 es el ultimo nodo
	lw $t1, 0($t0)	# t1=node-val
	beq $t1, $a1, equal	# val==node->val
	ble $a1, $t1, less	# val<node->val
	move $a0, $t0	# a0=node
	lw $t0, 4($a0)	# t0=node->next
	b insert_loop
first:
	sw $a0, 4($v0)
	b end_insert_in_order
last:
	sw $v0, 4($a0)
	lw $v0, 0($fp)	# v0=first
	b end_insert_in_order
less:
	sw $v0, 4($a0)
	sw $t0, 4($v0)
	lw $v0, 0($fp)	# v0=first
	b end_insert_in_order
equal:
	lw $v0, 0($fp)	# v0=first
	b end_insert_in_order
end_insert_in_order:
	lw $ra, 20($sp)
	lw $fp, 16($sp)
	addi $sp, $sp, 32
	jr $ra
print:
	addi $sp, $sp, -32
	sw $ra, 20($sp)
	sw $fp, 16($sp)
	addi $fp, $sp, 28
	sw $a0, 0($fp)
	
	beqz $a0, end_print
	lw $a0, 4($a0)
	jal print
	
	lw $a0, 0($fp)
	lw $a0, 0($a0)
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, salto
	syscall
end_print:
	lw $ra, 20($sp)
	lw $fp, 16($sp)
	addi $sp, $sp, 32
	jr $ra