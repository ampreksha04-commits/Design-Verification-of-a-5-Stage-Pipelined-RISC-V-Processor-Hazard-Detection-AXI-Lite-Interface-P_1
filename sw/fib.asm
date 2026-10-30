# Fibonacci(n), where n comes from the board switches SW0..SW4 (memory-mapped input at 0x2000_0000)
      lui  x5, 0x20000      # x5 = 0x2000_0000  (switch input address)
      lw   x3, 0(x5)        # n = switches
      andi x3, x3, 31       # keep 5 bits (n = 0..31)
      addi x1, x0, 0        # a = 0
      addi x2, x0, 1        # b = 1
      beq  x3, x0, store    # if n == 0 skip the loop
loop: add  x4, x1, x2       # t = a + b
      add  x1, x2, x0       # a = b
      add  x2, x4, x0       # b = t
      addi x3, x3, -1
      bne  x3, x0, loop
store: sw  x1, 0(x0)        # store the result in data memory
      lw   x6, 0(x0)        # read it back
done: beq  x0, x0, done     # stop. Result Fibonacci(n) is in x1 (shown on the LEDs)
