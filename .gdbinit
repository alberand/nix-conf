set history save on
set history size 10000
set history filename ~/.gdb_history

# Print backtrace of all threads
define btall
thread apply all backtrace
end

# Print code in HEX
# (gdb) xxd &shell_uart_out_buffer sizeof(shell_uart_out_buffer)
define xxd
  dump binary memory /tmp/dump.bin $arg0 ((char *)$arg0)+$arg1
  shell xxd /tmp/dump.bin
end
document xxd
  Runs xxd on a memory ADDR and LENGTH

  xxd ADDR LENTH
end
