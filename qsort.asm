.globl main
.data 
str1: .asciiz "Initial array:"
str2: .asciiz "Sorted array:"
left: .asciiz "[ "
right: .asciiz "] "
newline: .asciiz "\n"
space: .asciiz " "

#array of strings dataName[]
dataName: 
.align 5
.asciiz "Joe"
.align 5
.asciiz "Jenny"
.align 5
.asciiz "Jill"
.align 5
.asciiz "John"
.align 5
.asciiz "Jeff"
.align 5
.asciiz "Joyce"
.align 5
.asciiz "Jerry"
.align 5
.asciiz "Janice"
.align 5
.asciiz "Jake"
.align 5
.asciiz "Jonna"
.align 5
.asciiz "Jack"
.align 5
.asciiz "Jocelyn"
.align 5
.asciiz "Jessie"
.align 5
.asciiz "Jess"
.align 5
.asciiz "Janet"
.align 5
.asciiz "Jane"
.align 5

#array of pointers dataAddr[]
.align 2
dataAddr: .space 64

.text 
main :
#t1= dataName 
#t7= dataAddr
la $t1,dataName
la $t7,dataAddr

#print text
# printf("Initial array:\n");
# printf("[ ");
la $a0,str1
jal print_char
la $a0,newline
jal print_char
la $a0,left
jal print_char

# t0 = 16
# t1 = 0
li $t0,16 #constant
li $t1,0 #counter

#build the pointer array dataAddr[]
# for(int i=0; i<n; i++)
loop: 
beq $t1,$t0,loopend

	# a0 = dataName + i*32 (dataName[i])
	mul $t5,$t1,32 #offset
	la $t6,dataName #base
	add $a0,$t6,$t5

	# dataAddr[i] =  &dataName[i]
	sw $a0,($t7)# store the addr in dataAddr
	add $t7,$t7,4 # next pos

	# printf("%d ",dataName[i])
	jal print_str
	
	# i++
	add $t1,$t1,1
	j loop
loopend:

# printf("%s"," ]")
la $a0,right
jal print_char


# quick_sort(leftaddr, rightaddr);
la $a0,dataAddr
li $t4,15 #length-1 = 16 -1 =15
mul $t4,$t4,4 #offset
add $a1,$a0,$t4 #last element addr
jal quick_sort
 
#output sorted list

# printf("%s","\n")
la $a0,newline
jal print_char
# printf("%s","Sorted array: ")
la $a0,str2
jal print_char
# printf("%s","\n")
la $a0,newline
jal print_char
# printf("%s","[ ")
la $a0,left
jal print_char


# t0 = 16
# t1 = 0
li $t0,16 #constant
li $t1,0 #counter
# for(int i=0; i<n; i++)
print_loop:
beq $t1,$t0,print_loop_end
	#printf("%s ", dataAddr[i]);
	mul $t5,$t1,4 #offset
	la $t6,dataAddr #base
	add $t6,$t6,$t5 #cal pointer addr
	lw $a0,($t6)#get the real addr
	jal print_str
	add $t1,$t1,1
	j print_loop
print_loop_end:

# printf("%s"," ]")
la $a0,right
jal print_char

#test case for swap_str_ptrs()		
#	la $a0,dataAddr
#	add $a1,$a0,4
#	jal swap_str_ptrs

#test case for str_lt()
#	la $a0,dataAddr
#	add $a1,$a0,4
#	jal str_lt
#	move $t9,$v0

#exit and return 0
li $v0, 10       # system call 10 is exit()
        li $a0, 0          # setting return code of program to 0 (success)
	syscall

# void quick_sort(const char **left, const char **right)
#input: $a0 array start element addr, $a1 last element addr 
#sort the array
quick_sort:
	sub $sp,$sp,20
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	sw $t1,16($sp)
	#prologue
	
	#if (*left<= *right) {return;}
	move $t0,$a0 #t0 array start addr
	move $t1,$a1 #t1 array last element addr
	bge $t0,$t1,return_array # laddr >= raddr len<=1
	
	#pivot = dataAddr
	#pos = dataAddr
	move $s0,$t0	#s0 pivot cursor addr 
	move $s1,$t0	#s1 counter cursor addr 
	
	partition:
	# for(left=dataAddr; left<right; left+=4)
	beq $s1,$t1,partition_end #when counter==last element, exit loop
		move $a0,$s1
		move $a1,$t1
		jal str_lt 
		# if(str_lt(pos,right))
		beq $v0,0,swap_end #if ith-elemnt< last element, then swap to front
			# swap_str_ptrs(&a[i], &a[pivot]);
			move $a0,$s1
			move $a1,$s0
			jal swap_str_ptrs
			add $s0,$s0,4 #pivot++	
		swap_end:
		add $s1,$s1,4 #counter move++
		j partition
	
	partition_end:
	
	# swap_str_ptrs(&a[pivot], &a[len - 1]);
	move $a0,$s0
	move $a1,$t1
	jal swap_str_ptrs
	
	#store register
	
	# quick_sort(a, pivot);
	move $a0,$t0
	sub $a1,$s0,4 # (pivot-1)-th element addr
	jal quick_sort
	
  	# quick_sort(a + pivot + 1, len - pivot - 1); 
  	add $a0,$s0,4 #(pivot+1)-th addr+4
	move $a1,$t1 # last element addr 
	
	jal quick_sort
	
	return_array:
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	lw $t1,16($sp)
	add $sp,$sp,20
	jr $ra 
	
# void swap_str_ptrs(const char **s1, const char **s2)	
#input: $a0,$a1 two pointer addr of strings
#output: swap ($a0) and ($a1) in ram
#use: t0 t1
swap_str_ptrs:
	sub $sp,$sp,16
	sw $ra,($sp)
	sw $fp,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	#prologue
	
	#t0 = *(a0)
	#t1 = *(a1)
	lw $t0,($a0) #fetch the addr value
	lw $t1,($a1)
	
	#*(a0) = t1
	#*(a1) = t0
	sw $t1,($a0)
	sw $t0,($a1)
	
	#epilogue
	lw $ra,($sp)
	lw $fp,4($sp)
	lw $t0,8($sp)
	lw $t1,12($sp)
	add $sp,$sp,16
	jr $ra


# int str_lt (const char *x, const char *y)
#input: $a0 $a1 two pointer's addr of strings
#return: $v0 = 1 if $a0 < $a1
#use: t0 t1 t2 t3
str_lt: 
	sub $sp,$sp,24
	sw $ra,($sp)
	sw $fp,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	sw $t2,16($sp)
	sw $t3,20($sp)
	move $fp,$sp
	#prologue
	
	move $t0,$a0 #pointer addr
	move $t1,$a1
	lw $t0,($t0) #fetch the real addr
	lw $t1,($t1)
	# for (; *x!='\0' && *y!='\0'; x++, y++) 
	loop_str_lt:
		lb $t2,($t0) 
		lb $t3,($t1)
		beq $t2,$0,return_1 #if t1 is empty than t1<=t2 1
		beq $t3,$0,return_0 #if t2 is empty than t1>t2 0
		
		# if ( *x < *y ) return 1;
    		# if ( *y < *x ) return 0;
		blt $t2,$t3,return_1
		blt $t3,$t2,return_0
		
		# x++
		# y++
		add $t0,$t0,1
		add $t1,$t1,1 
		
		j loop_str_lt
		
	
	str_lt_exit:
	#epilogue
	lw $ra,($sp)
	lw $fp,4($sp)
	lw $t0,8($sp)
	lw $t1,12($sp)
	lw $t2,16($sp)
	lw $t3,20($sp)
	add $sp,$sp,24
	jr $ra #exit
	
	return_1:
		li $v0,1
		j str_lt_exit
	return_0:
		li $v0,0
		j str_lt_exit

print_int:
	# argument to print_str syscall already in $a0; Else do:  move $a0, ...
	li $v0, 1  # The print_str system call is number 4 in the table. 34 is hex
	syscall
	li $v0, 4  #print \n
	la $a0, space
	syscall
	li $v0, 0  # 0 means success; Pass return value in $v0
	jr $ra

print_str:
	# argument to print_str syscall already in $a0; Else do:  move $a0, ...
	li $v0, 4  # The print_str system call is number 4 in the table.
	syscall
	li $v0, 4  #print \n
	la $a0, space
	syscall
	li $v0, 0  # 0 means success; Pass return value in $v0
	jr $ra

#input $a0
print_char:
	li $v0, 4
	syscall
	li $v0, 0
	jr $ra 
