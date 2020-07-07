|MEM 8192  | 8MB
| r3 compiler
| PHREDA 2019
|------------------
|MEM $ffff
^./r3base.r3
^./r3pass1.r3
^./r3pass2.r3
^./r3pass3.r3
^./r3pass4.r3
^./r3gencod.r3
^./r3gendat.r3

#name * 1024

:r3-genset
	mark
	";---r3 setings" ,ln
	switchresx "XRES equ %d" ,format ,cr
	switchresy "YRES equ %d" ,format ,cr
	switchfull "FULL equ %d" ,format ,cr
	switchmem 10 << "MEMSIZE equ 0x%h" ,format ,cr
	0 ,c
	"asm/set.asm"
	savemem
	empty ;

::r3c | str --
	r3name
	here 'src !
	"^r3/sys/asmbase.r3" ,ln | include asmbase
	here
	'r3filename
	dup "load %s" slog

	2dup load | "fn" mem
	here =? ( "no src" slog ; )
	0 swap c!+ 'here !
	0 'error !
	0 'cnttokens !
	0 'cntdef !
	'inc 'inc> !
	" pass1" slog
	nip src |...
	r3-stage-1
	error 1? ( "ERROR %s" slog lerror "%l" slog ; ) drop
	cntdef cnttokens "toks:%d def:%d" slog
	" pass2" slog
	r3-stage-2
	1? ( "ERROR %s" slog lerror "%l" slog ; ) drop
	code> code - 2 >> "..code:%d" slog
	" pass3" slog
	r3-stage-3
	" pass4" slog
	r3-stage-4
	" genset" slog
	r3-genset
	" gencode" slog
	r3-gencode
	" gendata" slog
	r3-gendata
	;

: mark
	'name "mem/main.mem" load drop

	cls
	$ff00 'ink ! " PHREDA - 2019" print cr
	$ff0000 'ink ! " r3 compiler" print cr
	$ffffff 'ink !
	redraw

	'name r3c

    "asm\fasm.exe asm\r3fasm.asm" sys

|    "asm\fasm.exe asm\r3fasm.asm > asm\log.txt" sys
|	mark
|	here "asm\log.txt" load 0 swap !
|
|	here print
|	"press >esc< to run..." print cr
|	waitesc

	"asm\r3fasm.exe" sys
	$ffffff 'ink !
	"press >esc< to continue..." print
	waitesc
	;

