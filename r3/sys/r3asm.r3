| generate amd64 code
| PHREDA 2020
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

::checkvreg
	cellnewg |dup "[%d]" ,format
	0? ( drop ; )
	'TOS cell.REG ;

|----------------------
:g0 :g: :g:: :g# :g: :g| :g^    ;

:gdec
	getcte push.nro
	checkvreg ;

:ghex
	getcte2 push.nro
	checkvreg ;

:gbin
	getcte neg push.nro
	checkvreg ;

:gfix
	getcte push.nro
	checkvreg ;

:gstr
	getval push.str
	checkvreg ;

:gdwor
	getval
	dup 'lastdircode !
	push.wrd
	checkvreg ;

:gdvar
	getval
	push.wrd
	checkvreg ;

:gvar
	getval
	push.var
	checkvreg ;

:gwor
	stk.normal
	dup @ $ff and
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
	"mov rcx,#0" ,asm
	.drop
	stk.normal | TOS in eax or something
	over @ $ff and
	16 <>? ( drop "call rcx" ,asm ; ) drop
	"jmp rcx" ,asm
	;

:g0?
	gwhilejmp
	'TOS needREG
	"or #0,#0" ,asm
	getval "jnz _o%h" ,format ,cr
	;

:g1?
	gwhilejmp
	'TOS needREG
	"or #0,#0" ,asm
	getval "jz _o%h" ,format ,cr
	;

:g+?
	gwhilejmp
	'TOS needREG
	"or #0,#0" ,asm
	getval "js _o%h" ,format ,cr
	;

:g-?
	gwhilejmp
	'TOS needREG
	"or #0,#0" ,asm
	getval "jns _o%h" ,format ,cr
	;

:g<?
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jge _o%h" ,format ,cr
	;

:g>?
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jle _o%h" ,format ,cr
	;

:g=?
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jne _o%h" ,format ,cr
	;

:g>=?
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jl _o%h" ,format ,cr
	;

:g<=?
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jg _o%h" ,format ,cr
	;

:g<>?
	"cmp #1,#0" ,asm
	.drop
	gwhilejmp
	getval "je _o%h" ,format ,cr
	;

:gA?
	"test #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jnz _o%h" ,format ,cr
	;

:gN?
	"test #1,#0" ,asm
	.drop
	gwhilejmp
	getval "jz _o%h" ,format ,cr
	;

:gB?
	| sub nos2,nos
	| cmp nos,tos-nos
	"cmp #2,#1" ,asm
	.2drop
	gwhilejmp
	getval "jge _o%h" ,format ,cr
	;


:gDUP
	.DUP checkvreg ;
:gDROP
	.DROP ;
:gOVER
	.OVER checkvreg ;
:gPICK2
	.PICK2 checkvreg ;
:gPICK3
	.PICK3 checkvreg ;
:gPICK4
	.PICK4 checkvreg ;
:gSWAP
	.SWAP ;
:gNIP
	.NIP ;
:gROT
	.ROT ;
:g2DUP
	.over checkvreg
	.over checkvreg ;
:g2DROP
	.2DROP ;
:g3DROP
	.3DROP ;
:g4DROP
	.4DROP ;
:g2OVER
	.pick3 checkvreg
	.pick3 checkvreg ;
:g2SWAP
	.2SWAP ;

:g>R
	"push #0" ,asm
	.drop ;
:gR>
	.dup checkvreg
	"pop #0" ,asm ;
:gR@
	.dup  checkvreg
	"mov #0,[esp]" ,asm ;

:gAND
	nro2stk 0? ( drop .AND ; ) drop
	NOS needREG
	"and #1,#0" ,asm
	.drop ;
:gOR
	nro2stk 0? ( drop .OR ; ) drop
	"or #1,#0" ,asm
	.drop ;
:gXOR
	nro2stk 0? ( drop .XOR ; ) drop
	"xor #1,#0" ,asm
	.drop ;
:gNOT
	nro1stk 0? ( drop .NOT ; ) drop
	"not #0" ,asm ;
:gNEG
	nro1stk 0? ( drop .NEG ; ) drop
	"neg #0" ,asm ;
:g+
	nro2stk 0? ( drop .+ ; ) drop
	NOS needREG
	"add #1,#0" ,asm
	.drop ;
:g-
	nro2stk 0? ( drop .- ; ) drop
	NOS needREG
	"sub #1,#0" ,asm
	.drop ;
:g*
	nro2stk 0? ( drop .* ; ) drop
	NOS needREG
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
	"call sqrt" ,asm
	;
:gCLZ
	nro1stk 0? ( drop .CLZ ; ) drop
	"bsr #0,#0;xor #0,31" ,asm ;
:g<<
	nro2stk 0? ( drop .<< ; ) drop
	'TOS needECXcte
	"shl #1,#0" ,asm
	.drop ;
:g>>
	nro2stk 0? ( drop .>> ; ) drop
	'TOS needECXcte
	"sar #1,#0" ,asm
	.drop ;
:g>>>
	nro2stk 0? ( drop .>>> ; ) drop
	'TOS needECXcte
	"shr #1,#0" ,asm
	.drop ;

:cte*>>
	NOS2 needEAX
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
:gQ@
	'TOS needREG
	"mov #0,qword[#0]" ,asm ;

:g@+
	.dup checkvreg
	'TOS needREG
	NOS needREG
	"movsx #0,dword[#1];add #1,4" ,asm ;
:gC@+
	.dup checkvreg
	'TOS needREG
	NOS needREG
	"movsx #0,byte[#1];add #1,1" ,asm  ;
:gQ@+
	.dup checkvreg
	'TOS needREG
	NOS needREG
	"mov #0,qword[#1];add #1,8" ,asm	;

:g!
	'TOS needMEMREG
	"mov dword[#0],#1" ,asm
	.2drop ;
:gC!
	'TOS needMEMREG
	"mov byte[#0],#1" ,asm
	.2drop ;
:gQ!
	'TOS needMEMREG
	"mov qword[#0],#1" ,asm
	.2drop ;

:g!+
	'TOS needMEMREG
	"mov dword[#0],#1;add #0,4" ,asm
	.drop ;
:gC!+
	'TOS needMEMREG
	"mov byte[#0],#1;add #0,1" ,asm
	.drop ;
:gQ!+
	'TOS needMEMREG
	"mov qword[#0],#1;add #0,8" ,asm
	.drop ;

:g+!
	'TOS needMEMREG
	"add dword[#0],#1" ,asm
	.2drop ;
:gC+!
	'TOS needMEMREG
	"add byte[#0],#1" ,asm
	.2drop ;
:gQ+!
	'TOS needMEMREG
	"add qword[#0],#1" ,asm
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
	"rep movsq" ,asm ;
:gMOVE>
	needESIEDIECX
	"lea esi,[esi+ecx*4-4];lea edi,[edi+ecx*4-4];std;rep movsd;cld" ,asm ;
:gFILL
	needEDIECXEAX
	"rep stosq" ,asm ;
:gCMOVE
	needESIEDIECX
	"rep movsb" ,asm ;
:gCMOVE>
	needESIEDIECX
	"lea esi,[esi+ecx-1];lea edi,[edi+ecx-1];std;rep movsb;cld" ,asm ;
:gCFILL
	needEDIECXEAX
	"rep stosb" ,asm ;
:gQMOVE
	needESIEDIECX
	"rep movsq" ,asm ;
:gQMOVE>
	needESIEDIECX
	"lea rsi,[rsi+rcx*8-8];lea rdi,[rdi+rcx*8-8];std;rep movsq;cld" ,asm ;
:gQFILL
	needEDIECXEAX
	"rep stosq" ,asm ;

:gUPDATE
	"call SYSREDRAW" ,asm
	;
:gREDRAW
	"call SYSUPDATE" ,asm
	;
:gMEM
	0 PUSH.CTEM ;
:gSW
	0 PUSH.CTE ;
:gSH
	1 PUSH.CTE ;
:gFRAMEV
	1 PUSH.CTEM ;

:gXYPEN
	2 PUSH.CTEM 3 PUSH.CTEM ;
:gBPEN
	4 PUSH.CTEM ;
:gKEY
	5 PUSH.CTEM ;
:gCHAR
	6 PUSH.CTEM ;

:gMSEC
	"call SYSMSEC" ,asm ;
:gTIME
	"call SYSTIME" ,asm ;
:gDATE
	"call SYSDATE" ,asm ;
:gLOAD
	"call SYSLOAD" ,asm ;
:gSAVE
	"call SYSSAVE" ,asm ;
:gAPPEND
	"call SYSAPPEND" ,asm ;

:gFFIRST
:gFNEXT
	;
:gSYS
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
0 0 0 0 0 0 0 gdec ghex gdec gdec gstr gwor gvar gdwor gdvar
g; g( g) g[ g] gEX g0? g1? g+? g-? g<? g>? g=? g>=? g<=? g<>?
gA? gN? gB? gDUP gDROP gOVER gPICK2 gPICK3 gPICK4 gSWAP gNIP gROT g2DUP g2DROP g3DROP g4DROP
g2OVER g2SWAP g>R gR> gR@ gAND gOR gXOR g+ g- g* g/ g<< g>> g>>> gMOD
g/MOD g*/ g*>> g<</ gNOT gNEG gABS gSQRT gCLZ g@ gC@ gQ@ g@+ gC@+ gQ@+ g!
gC! gQ! g!+ gC!+ gQ!+ g+! gC+! gQ+! g>A gA> gA@ gA! gA+ gA@+ gA!+ g>B
gB> gB@ gB! gB+ gB@+ gB!+ gMOVE gMOVE> gFILL gCMOVE gCMOVE> gCFILL gQMOVE gQMOVE> gQFILL gUPDATE
gREDRAW gMEM gSW gSH gFRAMEV gXYPEN gBPEN gKEY gCHAR gMSEC gTIME gDATE gLOAD gSAVE gAPPEND gFFIRST
gFNEXT gSYS


:codestep | token --
	$ff and
|	dup r3tokenname slog
	2 << 'vmc + @ ex ;


::genasmcode | duse --
|	dup cellinig
	stk.start
	cellstart
	'bcode ( bcode> <?
		@+
		"; " ,s dup ,tokenprint 9 ,c ,printstk ,cr
		codestep
|		"asm/code.asm" savemem | debug
		) drop ;