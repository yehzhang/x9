ac = r0
t1 = r8
t2 = r9
i = r10

main: # load x
      # 1(4bit MSW),2(8bits LSW)

      # load y
      # 3(4bit MSW),4(8bits LSW) is x

      # set immediate for t 12 bits
      set 0
      mov t1, ac
      mov t2, ac
      # r2 is i
      mov i, ac


FORLOOP: # for loop
      # cmp i with 11
      set 12
      mov r1, i
      slt r1
      set 1
      beq END

      # cmp y<0
      lw 4
      mov r1, ac
      set 0
      slt r1
      beq ELSE


      # sra $tp, $r1, $r3 # y>>i
      set 3
      mov r1, i
      srac r1

      lw 1
      addc r3
      lw 2
      mov r1, r0
      set 0
      addc r4
      #x_new in address r3, r4

      #-x
      lw 2
      neg r1 #negate least significant
      set 1
      add r1 #least significant + 1
      lw 1
      neg r2 #negate most significant
      addc r0 #add two parts

      mov r1, i
      srac r1 #-x>>i

      lw 3
      addc r5
      lw 4
      mov r1, r0
      set 0
      addc r6
      #y_new in address r5,6


      set 11
      mov r1, i
      sub r1
      set 1
      sllc r1


      mov r0, t2
      addc t2
      mov r1, t1
      set 0
      addc t1
      #t_new in address t1, t2

      set ASSIGN
      mov r1, r0
      set 0
      add r7
      set 0
      mov r1, r0
      set 0
      beq r7 # to ASSIGN

ELSE:
      #-y
      lw 4
      neg r1 #negate least significant
      set 1
      add r1 #least significant + 1
      lw 3
      neg r2 #negate most significant
      addc r1 #add two parts


      # sra $tp, $r1, $r3 # -y>>i
      mov r1, i
      srac r1

      lw 1
      addc r3
      lw 2
      mov r1, r0
      set 0
      addc r4
      #x_new in address r3, r4

      set 1
      mov r1, i
      srac r1 #x>>i

      lw 3
      addc r5
      lw 4
      mov r1, r0
      set 0
      addc r6
      #y_new in address r5, r6

      #t_new = t- 1<<(11-i)
      set 11
      mov r1, i
      sub r1
      set 1
      sllc r1

      mov r0, t2
      sub t2
      mov r1, t1
      set 0
      sub t1
      #t_new in address r2


ASSIGN:
      mov r0, r3
      sw 1
      mov r0, r4
      sw 2
      mov r0, r5
      sw 3
      mov r0, r6
      sw 4


      set FORLOOP
      mov r1, r0
      set 0
      add r7
      set 0
      mov r1, r0
      set 0
      beq r7 # to FORLOOP


END:
      #Store radian, x
      lw 1
      sw 5
      lw 2
      sw 6

      #Store theata, t
      mov r0, t1
      sw 7
      mov r0, t2
      sw 8