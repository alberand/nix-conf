" Vim syntax file for trace-cmd logs
" Language: trace-cmd output
" Maintainer: Auto-generated
" Latest Revision: 2026-02-05

if exists("b:current_syntax")
  finish
endif

" Process name and PID (e.g., "bash-1234")
syn match traceProcess /\s\+[a-zA-Z0-9_\-\.]\+-[0-9]\+\s\+/ contains=tracePID
syn match tracePID /\-[0-9]\+/ contained

" CPU number (e.g., "[001]")
syn match traceCPU /\[[0-9]\+\]/

" Timestamp (e.g., "1234.567890:")
syn match traceTimestamp /\d\+\.\d\+:/

" Function calls and kernel functions
syn match traceFunction /[a-zA-Z0-9_]\+\s*(/
syn match traceKernelFunc /\<[a-zA-Z_][a-zA-Z0-9_]*\>/

" Events (e.g., "sched_switch:", "irq_handler_entry:")
syn match traceEvent /\<[a-z_]\+:\s/

" Arrows and symbols
syn match traceArrow /[=<>]\+/
syn match traceArrow /->\|<-\||/

" Numbers (hex and decimal)
syn match traceHex /\<0x[0-9a-fA-F]\+\>/
syn match traceNumber /\<\d\+\>/
syn match traceFloat /\<\d\+\.\d\+\>/

" Field names (e.g., "prev_comm=", "next_pid=")
syn match traceField /[a-zA-Z_][a-zA-Z0-9_]*=/

" Strings in quotes
syn region traceString start=/"/ end=/"/ skip=/\\"/

" Special markers
syn match traceMarker /\*\*\*.*\*\*\*/
syn match traceComment /#.*/

" IRQ and softirq
syn match traceIRQ /\<irq\>/
syn match traceIRQ /\<IRQ\>/
syn match traceSoftIRQ /\<softirq\>/

" Common syscalls
syn keyword traceSyscall read write open close fork exec exit mmap munmap
syn keyword traceSyscall ioctl poll select fcntl clone

" Scheduler events
syn keyword traceSchedEvent sched_switch sched_wakeup sched_migrate_task
syn keyword traceSchedEvent sched_process_exit sched_process_fork

" State indicators
syn match traceState /\<[RSDZTI][+ ]\?/

" Define highlighting
hi def link traceProcess Identifier
hi def link tracePID Number
hi def link traceCPU Special
hi def link traceTimestamp Type
hi def link traceFunction Function
hi def link traceKernelFunc Identifier
hi def link traceEvent Keyword
hi def link traceArrow Operator
hi def link traceHex Number
hi def link traceNumber Number
hi def link traceFloat Float
hi def link traceField Label
hi def link traceString String
hi def link traceMarker WarningMsg
hi def link traceComment Comment
hi def link traceIRQ ErrorMsg
hi def link traceSoftIRQ WarningMsg
hi def link traceSyscall PreProc
hi def link traceSchedEvent Special
hi def link traceState Constant

let b:current_syntax = "trace"
