| generate x86 code
| only basic stack optimization
| PHREDA 2019
|-------------
^./r3base.r3
^./r3stack.r3
^./r3cellana.r3

#lastdircode 0 | ultima direccion de codigo

|--- @@
::getval | a -- a v
	dup 4 - @ 8 >>> ;

::getiw | v -- v iw
    dup 3 << blok + @ $10000000 and ;

::getsrcnro
	dup ?numero 1? ( drop nip nip ; ) drop
	?fnumero 1? ( drop nip ; ) drop
	"error" slog ;

::getcte | a -- a v
	dup 4 - @ 8 >>> src + getsrcnro ;

::getcte2 | a -- a v
	dup 4 - @ 8 >>> 'ctecode + @	;

|----------------------
:g0 :g: :g:: :g# :g: :g| :g^    ;

:gdec	getcte push.nro ;
:ghex   getcte2 push.nro ;
:gbin	getcte neg push.nro ;
:gfix	getcte push.nro ;
:gstr	getval push.str ;
:gdwor  getval dup 'lastdircode ! push.wrd ;
:gdvar	getval push.wrd ;
:gvar	getval push.var ;

:gwor
	stk.normal

	dup @ $ff and	| tail call optimization
	16 =? ( drop getval "jmp w%h" ,format ,cr ; ) drop | ret?

	getval
	dup "call w%h" ,format ,cr

	dic>du stk.gennormal
	;


:g;
	dup 8 - @ $ff and
	12 =? ( drop ; ) | tail call  call..ret?
	drop
	stk.normal
	"ret" ,ln
	;

|--- IF
:g(
	stk.normal

	stk.push
	getval
	getiw 0? ( 2drop ; ) drop
	"_i%h:" ,format ,cr ;		| while

:g)
	dup 8 - @ $ff and
	16 <>? (
|		stk.conv
		stk.normal
		)
	drop

	getval
	getiw 1? ( over "jmp _i%h" ,format ,cr ) drop	| while
	"_o%h:" ,format ,cr
	stk.pop
	;

:gwhilejmp
	getval getiw
	1? ( stk.drop stk.push ) | while
	2drop
	;

|--- REP
:g[
:g]
	;

:gEX

|	lastdircode
|	dic>du
|	"; u:%d d:%d" ,format ,cr
|	dup ( 1? 1 - .drop ) drop
|	+ ( 1? 1 - dup push.reg ) drop

	| "mov rcx
	stk.normal | TOS in eax or something

	over @ $ff and
	16 <>? ( drop "call #0" ,asm ; ) drop
	"jmp #0" ,asm | call..ret?
	;

:g0?
	'TOS needREG
	gwhilejmp
	"or #0,#0" ,asm
	getval "jnz _o%h" ,format ,cr
	;

:g1?
	'TOS needREG
	gwhilejmp
	"or #0,#0" ,asm
	getval "jz _o%h" ,format ,cr
	;

:g+?
	'TOS needREG
	gwhilejmp
	"or #0,#0" ,asm
	getval "js _o%h" ,format ,cr
	;

:g-?
	'TOS needREG
	gwhilejmp
	"or #0,#0" ,asm
	getval "jns _o%h" ,format ,cr
	;

:g<?
	NOS needREG
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jge _o%h" ,format ,cr
	;

:g>?
	NOS needREG
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jle _o%h" ,format ,cr
	;

:g=?
	NOS needREG
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jne _o%h" ,format ,cr
	;

:g>=?
	NOS needREG
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jl _o%h" ,format ,cr
	;

:g<=?
	NOS needREG
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jg _o%h" ,format ,cr
	;

:g<>?
	NOS needREG
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "je _o%h" ,format ,cr
	;

:gA?
	NOS needREG
	"test #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jnz _o%h" ,format ,cr
	;

:gN?
	NOS needREG
	"test #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jz _o%h" ,format ,cr
	;

:gB?
	NOS 4 - needREG
	| sub nos2,nos
	| cmp nos,tos-nos
	"cmp #2,#1" ,asm

	.2drop
	gwhilejmp
	getval "jge _o%h" ,format ,cr
	;

:g>R
	"push #0" ,asm
	.drop ;
:gR>
	.dup
	"pop #0" ,asm ;
:gR@
	.dup
	"mov #0,dword[esp]" ,asm ;

:gAND
	nro2stk 0? ( drop .AND ; ) drop
	need1REGno
	"and #1,#0" ,asm
	.drop ;
:gOR
	nro2stk 0? ( drop .OR ; ) drop
	need1REGno
	"or #1,#0" ,asm
	.drop ;
:gXOR
	nro2stk 0? ( drop .XOR ; ) drop
	need1REGno
	"xor #1,#0" ,asm
	.drop ;
:gNOT
	nro1stk 0? ( drop .NOT ; ) drop
	'TOS needREG
	"not #0" ,asm ;
:gNEG
	nro1stk 0? ( drop .NEG ; ) drop
	'TOS needREG
	"neg #0" ,asm ;
:g+
	nro2stk 0? ( drop .+ ; ) drop
	need1REGno
	"add #1,#0" ,asm
	.drop ;
:g-
	nro2stk 0? ( drop .- ; ) drop
	need1REG
	"sub #1,#0" ,asm
	.drop ;
:g*
	nro2stk 0? ( drop .* ; ) drop
	need1REGno
	"imul #1,#0" ,asm
	.drop ;
:g/
	nro2stk 0? ( drop ./ ; ) drop
	freeEDX
	NOS needREG-EDX
	"cdq;idiv #0" ,asm
	.drop
	'TOS setEAX
	;
:g*/
	nro3stk 0? ( drop .*/ ; ) drop
	freeEDX
	NOS2 needEAX
	NOS needREG-EDX
	"cdq;imul #1;idiv #0" ,asm
	.2drop
	'TOS setEAX
	;
:g/MOD
	nro2stk 0? ( drop ./MOD ; ) drop
	freeEDX
	NOS needEAX
	"cdq;idiv #0" ,asm
	NOS setEAX
	'TOS setEDX
	;
:gMOD
	nro2stk 0? ( drop .MOD ; ) drop
	freeEDX
	NOS needEAX
	"cdq;idiv #0" ,asm
	.drop
	'TOS setEDX
	;
:gABS
	nro1stk 0? ( drop .ABS ; ) drop
	freeEDX
	'TOS needREG-EDX
	"mov edx,#0;sar edx,31;add #0,edx;xor #0,edx" ,asm ;
:gSQRT
	nro1stk 0? ( drop .SQRT ; ) drop
   "cvtsi2sd xmm0,#0;sqrtsd xmm0,xmm0;cvtsd2si #0,xmm0" ,asm ;

:gCLZ
	nro1stk 0? ( drop .CLZ ; ) drop
	'TOS needREG
	"bsr #0,#0;xor #0,31" ,asm ;
:g<<
	nro2stk 0? ( drop .<< ; ) drop
	NOS needREG
	'TOS needECXcte
	"shl #1,#0" ,asm
	.drop ;
:g>>
	nro2stk 0? ( drop .>> ; ) drop
	NOS needREG
	'TOS needECXcte
	"sar #1,#0" ,asm
	.drop ;
:g>>>
	nro2stk 0? ( drop .>>> ; ) drop
	NOS needREG
	'TOS needECXcte
	"shr #1,#0" ,asm
	.drop ;

:cte*>>
	NOS2 needEAX
	NOS needREG
	freeEDX
	vTOS
	32 <? ( drop "cdq;imul #1;shrd eax,edx,$0" ,asm .2drop 'TOS setEAX ; )
	32 >? ( drop "cdq;imul #1;sar edx,(#0-32)" ,asm .2drop 'TOS setEDX ; )
	"cdq;imul #1" ,asm
    .2drop
	'TOS setEAX
	;

:g*>>
	nro3stk 0? ( drop .*>> ; ) drop
	nro1stk 0? ( drop cte*>> ; ) drop
	NOS2 needEAX
	freeEDX
	"cdq;imul #1;shrd eax,edx,$0;sar edx,$0;test $0,32;cmovne eax,edx" ,asm
	.2drop
	'TOS setEAX
	;

:g<</
	nro3stk 0? ( drop .<</ ; ) drop
	NOS2 needEAX
	'TOS needECXcte
	freeEDX
	"cdq;shld edx,eax,$0;shl eax,$0;idiv #1" ,asm
	.2drop
	'TOS setEAX
	;

:g@
	'TOS needREG
	"movsx #0,dword[#0]" ,asm ;
:gC@
	'TOS needREG
	"movsx #0,byte[#0]" ,asm ;
:gD@
	'TOS needREG
	"mov #0,word[#0]" ,asm ;

:g@+
	.dup
	'TOS needREG
	NOS needREG
	"movsx #0,dword[#1];add #1,4" ,asm ;
:gC@+
	.dup
	'TOS needREG
	NOS needREG
	"movsx #0,byte[#1];add #1,1" ,asm  ;
:gD@+
	.dup
	'TOS needREG
	NOS needREG
	"mov #0,word[#1];add #1,2" ,asm	;

:g!
	'TOS needMEMREG
	"mov dword[#0],#1" ,asm
	.2drop ;
:gC!
	'TOS needMEMREG
	"mov byte[#0],#1" ,asm
	.2drop ;
:gD!
	'TOS needMEMREG
	"mov word[#0],#1" ,asm
	.2drop ;

:g!+
	'TOS needMEMREG
	"mov dword[#0],#1;add #0,4" ,asm
	.drop ;
:gC!+
	'TOS needMEMREG
	"mov byte[#0],#1;add #0,1" ,asm
	.drop ;
:gD!+
	'TOS needMEMREG
	"mov word[#0],#1;add #0,2" ,asm
	.drop ;

:g+!
	'TOS needMEMREG
	"add dword[#0],#1" ,asm
	.2drop ;
:gC+!
	'TOS needMEMREG
	"add byte[#0],#1" ,asm
	.2drop ;
:gD+!
	'TOS needMEMREG
	"add word[#0],#1" ,asm
	.2drop ;

:g>A
	"mov esi,#0" ,asm
	.drop ;
:gA>
	'TOS needREG
	"mov #0,esi" ,asm ;
:gA@
	'TOS needREG
	"mov #0,[esi]" ,asm	;
:gA!
	"mov [esi],#0" ,asm
	.drop ;
:gA+
	"add esi,#0" ,asm
	.drop ;
:gA@+
	'TOS needREG
	"mov #0,[esi];add esi,4" ,asm ;
:gA!+
	"mov [esi],#0;add esi,4" ,asm
	.drop ;

:g>B
	"mov edi,#0" ,asm
	.drop ;
:gB>
	'TOS needREG
	"mov #0,edi" ,asm ;
:gB@
	'TOS needREG
	"mov #0,[edi]" ,asm ;
:gB!
	"mov [edi],#0" ,asm
	.drop ;
:gB+
	"add edi,#0" ,asm
	.drop ;
:gB@+
	'TOS needREG
	"mov #0,[edi];add edi,4" ,asm ;
:gB!+
	"mov [edi],#0;add edi,4" ,asm
	.drop ;

:gMOVE
	needESIEDIECX
	"rep movsq" ,asm 
	.3drop ;
:gMOVE>
	needESIEDIECX
	"lea esi,[esi+ecx*4-4];lea edi,[edi+ecx*4-4];std;rep movsd;cld" ,asm
	.3drop ;
:gFILL
	needEDIECXEAX
	"rep stosq" ,asm
	.3drop ;
:gCMOVE
	needESIEDIECX
	"rep movsb" ,asm
	.3drop ;
:gCMOVE>
	needESIEDIECX
	"lea esi,[esi+ecx-1];lea edi,[edi+ecx-1];std;rep movsb;cld" ,asm
	.3drop ;
:gCFILL
	needEDIECXEAX
	"rep stosb" ,asm
	.3drop ;
:gDMOVE
	needESIEDIECX
	"rep movsd" ,asm
	.3drop ;
:gDMOVE>
	needESIEDIECX
	"lea rsi,[esi+ecx*4-4];lea edi,[edi+ecx*4-4];std;rep movsd;cld" ,asm
	.3drop ;
:gDFILL
	needEDIECXEAX
	"rep stosd" ,asm
	.3drop ;

:gSW	0 PUSH.CTE ;
:gSH	1 PUSH.CTE ;
:gMEM   2 PUSH.CTE ;
:gFRAMEV 3 PUSH.CTE ;
:gXYPEN	4 PUSH.CTE ;
:gBPEN  5 PUSH.CTE ;
:gKEY   6 PUSH.CTE ;

:,callsys | "" --
	stk.normal
	over @ $ff and | word ;
	$10 =? ( drop "jmp " ,s ,s ,cr ; )
	drop "call " ,s ,s ,cr ;

:vstack+ | delta --
	drop
	;

:gUPDATE	"SYSUPDATE" ,callsys ;
:gREDRAW	"SYSREDRAW" ,callsys ;
:gMSEC		"SYSMSEC" ,callsys 1 vstack+ ;
:gTIME		"SYSTIME" ,callsys 1 vstack+ ;
:gDATE		"SYSDATE" ,callsys 1 vstack+ ;
:gLOAD		"SYSLOAD" ,callsys -1 vstack+ ;
:gSAVE		"SYSSAVE" ,callsys -3 vstack+ ;
:gAPPEND	 "SYSAPPEND" ,callsys -3 vstack+ ;
:gFFIRST	 "SYSFFIRST" ,callsys ;
:gFNEXT		 "SYSFNEXT" ,callsys 1 vstack+ ;

:gSYSCALLc
	vTOS 2 <<
	"call [SYSCALL+%d]" ,format ,cr
	;

:gSYSCALL
	nro1stk 0? ( drop gSYSCALLc ; ) drop
	"call [SYSCALL+#0*4]" ,asm
	;

:gSYSMEMc
	vTOS 2 <<
	"mov eax,[SYSMEM+%d]" ,format ,cr
	;

:gSYSMEM
	nro1stk 0? ( drop gSYSMEMc ; ) drop
	"mov eax,[#0]" ,asm
	;

|---- opt instruction
:g@* | *248 reg -- val
	'TOS needREG
	"mov #0,dword [#0*#1]" ,asm ;
	.drop
	;
:g@*+ | val *248 reg -- val
	'TOS needREG
	"mov #0,dword [#0*#1+#2]" ,asm ;
	.2drop
	;
:g*+ | val *248 reg -- val
	'TOS needREG
	"lea #0,dword [#0*#1+#2]" ,asm ;
	.2drop
	;
:g*+call | cte *248 reg --
	'TOS needREG
	"call [#0*#1+#2]" ,asm
	.3drop
	;

|----

#vmc
g0 g: g:: g# g: g| g^		| 0 1 2 3 4 5 6
gdec ghex gbin gfix gstr    | 7 8 9 a b
gwor gvar gdwor gdvar		| c d e f
g; g( g) g[ g] gEX			| 10..15
g0? g1? g+? g-? g<? g>? g=? g>=? g<=? g<>? gA? gN? gB?	| 16..22
.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP		| 23..2A
.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP			| 2B..31
g>R gR> gR@                                             | 32..34
gAND gOR gXOR gNOT gNEG									| 35..39
g+ g- g* g/ g*/                                         | 3A..3E
g/MOD gMOD gABS gSQRT gCLZ                              | 3F..43
g<< g>> g>>> g*>> g<</									| 44..48
g@ gC@ gD@ g@+ gC@+ gD@+
g! gC! gD! g!+ gC!+ gD!+
g+! gC+! gD+!
g>A gA> gA@ gA! gA+ gA@+ gA!+
g>B gB> gB@ gB! gB+ gB@+ gB!+
gMOVE gMOVE> gFILL
gCMOVE gCMOVE> gCFILL
gDMOVE gDMOVE> gDFILL
gUPDATE gREDRAW
gMEM gSW gSH gFRAMEV
gXYPEN gBPEN gKEY
gMSEC gTIME gDATE
gLOAD gSAVE gAPPEND
gFFIRST gFNEXT
gSYSCALL gSYSMEM

:codestep | token --
	$ff and 2 << 'vmc + @ ex
	;


::genasmcode | duse --

|	dup cellinig
	0? ( 1 + ) |
	stk.start
	cellstart

	'bcode ( bcode> <?
		cell.fillreg
		@+

"; " ,s dup ,tokenprint 9 ,c ,printstk ,cr

|        ,printstk
|		dup $ff and r3tokenname " %s " ,format
|		,cr

		codestep
|		"asm/code.asm" savemem | debug

		) drop ;