define temp r3
define x_new1 r4
define x_new2 r5
define temp1 r6
define temp2 r7
define t1 r8
define t2 r9
define i r10
define y1 r11
define y2 r12
define x1 r13
define x2 r14


      # load x
      # 1(4bit MSW),2(8bits LSW)

      # load y
      # 3(4bit MSW),4(8bits LSW) is x

      # set immediate for t 12 bits
      set r0, 0
      set r1, 0
      add t1
      add t2
      add i


FORLOOP:
      #compare i with 12
      mov r1, i
      set r0, 11
      blts END:

      #compare if y is greater than 0
      set r1, 0
      lw r0, 1
      add x1
      lw r0, 2
      add x2
      lw r0, 3
      add y1
      lw r0, 4
      add y2

      set r0, 0
      mov r1, y1
      blts ELSE_ONLY:

      beq IF_ONLY:


IF_ONLY:
      mov r1, y2
      blts ELSE_ONLY:

      #x_new = x + (y>>i);
      srlc y1, y2, i, r2, r0 # y1, y2 equal to after shifted values
      mov r1, x2 # r1 = x2
      add x_new2 # x_new2 = y2+x2
      mov r0, r2
      mov r1, x1
      adc x_new1 # x_new1 = y1+x1+carry



      # y_new = y + ((-x)>>i);
      mov r0, x2
      neg r0  #r0 = -x2
      set r1, 1
      add temp2 # add -x2+1, 2's complement
      mov r0, x1
      neg r0
      set r1, 0
      adc temp1 # temp1 = -x1+carry in case there is carrybit


      srlc temp1, temp2, i, r2, r0
      mov r1, y2 # add y2+ ((-x)>>i)'s LSB
      add y2
      mov r1, y1
      mov r0, r2 # add y1+((-x)>>i)'s MSB
      adc y1


      #t_new = t + (1<<(11-i));
      set r0, 11
      mov r1, i
      sub temp1  #(11-i)
      set r0, 0
      set r1, 0
      add temp2
      set r0, 1
      add temp
      sllc temp2, temp, temp1, r2, r0 # 0,1<<(11-i)
      mov r1, t2
      add t2
      mov r1, t1
      mov r0, r2
      adc t1

      # go to assign parts
      beq ASSIGN:

ELSE_ONLY:
      #x_new = x + ((-y)>>i);
      mov r0, y2
      neg r0  #r0 = -y2
      set r1, 1
      add temp2 # temp2 = -x2+1
      mov r0, x1
      neg r0 # r0 = -y1
      set r1, 0
      add temp1 # temp1 = -x1+carru


      # -y>>i
      srlc temp1, temp2, i, r2, r0 # temp1, temp1 equal to after shifted values
      mov r1, x2 # r1 = x2
      add x_new2 # x_new2 = y2+x2
      mov r0, r2
      mov r1, x1
      adc x_new1 # x_new1 = y1+x1+carry



      # y_new = y + (x>>i);
      srlc x1, x2, i, r2, r0
      mov r1, y2 # add y2+ ((x)>>i)'s LSB
      add y2
      mov r0, r2
      mov r1, y1 # add y1+((-x)>>i)'s MSB
      adc y1


      #t_new = t - (1<<(11-i));
      set r0, 11
      mov r1, i
      sub temp1  #(11-i)
      set r0, 0
      set r1, 0
      add temp2
      set r1, 1
      add temp
      sllc temp2, temp, temp1, r2, r0 # 1<<(11-i)

      #negate temp1, temp2
      neg r0 # negate 1<<(11-i) LSB
      set r1, 1
      add temp2 # temp2 = -1<<(11-i) LSB+1
      mov r0, r2
      neg r0
      set r1, 0
      adc temp1 # temp1 = -1<<(11-i) MSB

      # add together
      mov r0, t2
      mov r1, temp2
      add t2   # t2 = t2+(-1<<(11-i))LSB
      mov r0, t1
      mov r1, temp1
      adc t1    # t1 = t1+(-1<<(11-i))MSB


ASSIGN:
      #i++
      set r0,1
      mov r1, i
      add i
      # save new x1, x2 to 1 and 2 locs
      mov r0, x_new1
      mov r1, x_new2
      sw r0, 1
      sw r1, 2
      #save new y1, y2 to 3 and 4 locs
      mov r0, y1
      mov r1, y2
      sw r0, 3
      sw r1, 4

      # go back to for loop
      beq FORLOOP:

END:
      # store radian x
      lw r0, 1
      lw r1, 2
      sw r0, 5
      sw r1, 6
      #store theta t
      mov r0, t1
      mov r1, t2
      sw r0, 7
      sw r1, 8

