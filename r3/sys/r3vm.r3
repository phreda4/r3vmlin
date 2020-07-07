| VM r3
| PHREDA 2018
|-------------
^./r3base.r3

#niv* 1024
#niv> 'niv
#nniv 0

:level+
	nniv niv> !+ 'niv> ! 1 'nniv +! ;
:level-
	-4 'niv> +! ;
:nlevel	| -- nl
	niv> 4 - @ $ffffff and 	;
:wlevel	| -- wl
	niv> 4 - @ 24 >> ;

:getcte
	;
:strmem
	0
	;

|----------------------

:i0 :i: :i:: :i# :i: :i| :i^	;
:g0 :g: :g:: :g# :g: :g| :g^    ;

:idec								|07
	dup 16 << 23 >> .PUSHD 8 0>> ;

:ihex								|08 | rest bits
	7 0>> .PUSHD 0 ;

:ibin								|09 | rest bits neg
	7 0>> neg .PUSHD 0 ;

:ifix								|0A | cte
	7 0>> getcte .PUSHD 0 ;

:istr								|0B	| nstr
	7 0>> strmem + .PUSHD 0 ;

:iwor								|c
	7 0>> .PUSHD 0 ;

:ivar								|d
	.PUSHD
	;

:idwor								|e
	7 0>> .PUSHD 0 ;

:idvar								|f
	7 0>> .PUSHD 0 ;


:next(
	;

:i; 							| 10
	2drop .popIP 0 ;

|--- IF
:i(				| 11
	level+
	nlevel "_li%h:" ,ln
	;

:i)				| 12
	wlevel 1? ( nlevel "jmp _li%h" ,ln ) drop
	nlevel "_lo%h:" ,ln
	level-
	;
|--- REP
:i[				| 13
:i]             | 14
	;

:iEX			| 15
	.EX ;

:i0?
	next(
	"or #0,#0" ,asm
	nlevel "jnz _lo%h" ,ln
	;

:i1?
	next(
	"or #0,#0" ,asm
	nlevel "jz _lo%h" ,ln
	;

:i+?
	next(
	"or #0,#0" ,asm
	nlevel "js _lo%h" ,ln
	;

:i-?
	next(
	"or #0,#0" ,asm
	nlevel "jns _lo%h" ,ln
	;

:i<?
	next(
	"cmp #1,#0" ,asm
	nlevel "jge _lo%h" ,ln
	;

:i>?
	next(
	"cmp #1,#0" ,asm
	nlevel "jle _lo%h" ,ln
	;

:i=?
	next(
	"cmp #1,#0" ,asm
	nlevel "jne _lo%h" ,ln
	;

:i>=?
	next(
	"cmp #1,#0" ,asm
	nlevel "jl _lo%h" ,ln
	;

:i<=?	| 18
	next(
	"cmp #1,#0" ,asm
	nlevel "jg _lo%h" ,ln
	;

:i<>?	| 19
	next(
	"cmp #1,#0" ,asm
	nlevel "je _lo%h" ,ln
	;

:iA?	| 20
	next(
	"test #1,#0" ,asm
	nlevel "jnz _lo%h" ,ln
	;

:iN?	| 21
	next(
	"test #1,#0" ,asm
	nlevel "jz _lo%h" ,ln
	;

:iB?    | 22
	next(
	| sub nos2,nos
	| cmp nos,tos-nos
	"cmp #2,#1" ,asm
	nlevel "jge _lo%h" ,ln
	;



:i@
	;

:iC@
	;

:iQ@
	;

:i@+
	;

:iC@+
	;

:iQ@+
	;

:i!
	;
:iC!
	;
:iQ!
	;

:i!+
	;

:iC!+
	;

:iQ!+
	;

:i+!
	;

:iC+!
	;

:iQ+!
	;



:iMOVE

:iMOVE>
:iFILL
	;

:iCMOVE
	;

:iCMOVE>
	;

:iCFILL
	;

:iDMOVE
	;

:iDMOVE>
	;

:iDFILL
	;

:iUPDATE
:iREDRAW
:iMEM
:iSW 
:iSH 
:iFRAMEV
:iXYPEN 
:iBPEN 
:iKEY
:iMSEC
:iTIME 
:iDATE
:iLOAD 
:iSAVE 
:iAPPEND
:iFFIRST 
:iFNEXT
	;

:iSYSCALL
:gSYSCALL

:iSYSMEM
:gSYSMEM
	;


#vml
i0 i: i:: i# i: i| i^		| 0 1 2 3 4 5 6
idec ihex ibin ifix istr    | 7 8 9 a b
iwor ivar idwor idvar		| c d e f
i; i( i) i[ i] iEX
i0? i1? i+? i-? i<? i>? i=? i>=? i<=? i<>? iA? iN? iB?
.DUP .DROP .OVER .PICK2 .PICK3 .PICK4 .SWAP .NIP
.ROT .2DUP .2DROP .3DROP .4DROP .2OVER .2SWAP
.>R .R> .R@
.AND .OR .XOR .NOT .NEG
.+ .- .* ./ .*/
./MOD .MOD .ABS .SQRT .CLZ
.<< .>> .>>> .*>> .<</
i@ iC@ iQ@ i@+ iC@+ iQ@+
i! iC! iQ! i!+ iC!+ iQ!+
i+! iC+! iQ+!
.>A .A> .A@ .A! .A+ .A@+ .A!+
.>B .B> .B@ .B! .B+ .B@+ .B!+
iMOVE iMOVE> iFILL
iCMOVE iCMOVE> iCFILL
iDMOVE iDMOVE> iDFILL
iUPDATE
iREDRAW
iMEM
iSW iSH iFRAMEV
iXYPEN iBPEN iKEY
iMSEC iTIME iDATE
iLOAD iSAVE iAPPEND
iFFIRST iFNEXT
iSYSCALL iSYSMEM


:vmstep
	$7f and 2 << 'vml + @ exec ;

::vmrun | adr --
	( @+ 1?
		( dup vmstep 8 0>> 1? ) drop
		0? ( drop ; )
		) 2drop ;
