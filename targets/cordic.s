main: # load x
      # r0(4bit MSW),r1(8bits LSW) is x
      addi $tp, zero, 1
      lw $r0, $tp 
      addi $tp, zero, 2
      lw $r1, $tp
      # load y
      # r2(4bit MSW),r3(8bits LSW) is x
      addi $tp, zero, 3
      lw $r2, $tp 
      addi $tp, zero, 4
      lw $r3, $tp
      # set immediate for t 12 bits
      # r4,r5 is t, t=0
      li $r4, zero
      li $r5, zero
      # r3 is i, i=0
      li $r6, $0


FORLOOP: # for loop
      ble $r6, 11, END  # cmp i with 11
      blt $r2, zero, ELSE # cmp y<0

      #every shift store in 7, 8
      #every add in address9,10

      # sra $tp, $r1, $r3 # y>>i
      addi $s1, zero, 3 # address of y
      jal SHIFTRIGHTFUN # y>>i 

      addi $s1, zero, 7 # address of y>>i
      addi $s2, zero, 1 # address of x
      jal ADDTWO  #x_new = r4 = x+(y)>>i, 
      addi $tp, zero, 9
      lw $tp, $tp 
      sw $tp, 10$(s2) # 10($s2) = 11
      addi $tp, zero, 10
      lw $tp, $tp 
      sw $tp, 11$(s2) # 11($s2) = 12      
      #x_new in address 11, 12

      #-x
      inv $tp, $r0
      sw $tp, 9($s2) #add 10
      inv $tp, $r1
      sw $tp, 10($s2) # add 11

      addi $s1, zero, 10 #set address to 10
      jal SHIFTRIGHTFUN # -x>>i

      addi $s1, zero, 7 # address of -x>>i
      addi $s2, zero, 3 # address of y
      jal ADDTWO
      addi $tp, zero, 9
      lw $tp, $tp 
      sw $tp, 12$(s2) # 12($s2) = 13
      addi $tp, zero, 10
      lw $tp, $tp 
      sw $tp, 13$(s2) # 13($s2) = 14      
      #y_new in address 13, 14

      
      add $tp, zero, 11 # temp = 11
      sub $tp, $tp, $r6 #temp = 11-i
      sll $tp, 1, $tp # temp = 1<<(11-i)

      addi $s1, zero, 7
      sw $r4, 0($s1)
      addi $s1, zero, 8
      sw $r5, 0($s1)
      addi $s1, zero, 7

      jal ADDONE
      #t_new in address 15, 16


      j ASSIGN
      
ELSE:
      sub $tp, $0, $r1   # -y
      sra $tp, $tp, $r3 # -y>>i
      add $r4, $tp, $r0 #x_new = r4 = x+(-y)>>i
      sra $tp, $r0, $r3 # x>>i
      add $r5, $tp, $r1 #y_new = x>>i +y
      li $tp, 11 # temp = 11
      sub $tp, $tp, $r3 #temp = 11-i
      sll $tp, 1, $tp # temp = 1<<(11-i)
      add $r6, $r2, $tp #t_new = t- 1<<(11-i)

ASSIGN:
      addi $tp, zero, 11
      lw $r0, $tp
      addi $tp, zero, 12
      lw $r1, $tp
      addi $tp, zero, 13
      lw $r2, $tp
      addi $tp, zero, 14
      lw $r3, $tp
      addi $tp, zero, 15
      lw $r4, $tp
      addi $tp, zero, 16
      lw $r5, $tp
      
      j FORLOOP


SHIFTRIGHTFUN:
      # $s1 $r8
      lw $s2, $s1
      addi $tp, $s1, 1
      lw $s3, $tp
      sra $s2, $s2, $r6
      sra $s3, $s3, $r6
      add $s3, $sov, $s3
      addi $s1, zero, 1
      sw $s2, 6($s1) # ramdom
      sw $s3, 7($s1) # ramdom


ADDONE:
      # s1, tp = 11-i
      lw $s2, $s1
      add $tp, $tp, $s2
      sw $tp, 8($s1) #loc 15
      addi $s1, $s1, 1
      lw $s2, $s1
      add $s2, $co, $s2
      sw $s2, 8($s1) #loc 16

ADDTWO:
      # $s1 (y), $s2 (x)
      lw $s3, $s1
      lw $s4, $s2
      add $s4, $s4, $s3
      sw $s4, 9($s2) # least significant
      addi $tp, $s1, 1
      lw $s3, $tp
      addi $tp, $s2, 1
      lw $s4, $tp
      add $s3, $co, $s3
      add $s3, $s3, $s4
      sw $s3, 8($s2) # most significant


END: 
      #Store radian, x
      addi $tp, zero, 5
      sw $r0, 0($tp)
      addi $tp, zero, 6
      sw $r1, 0($tp)

      #Store theata, t
      addi $tp, zero, 7
      sw $r4, 0($tp)
      addi $tp, zero, 8
      sw $r5, 0($tp)