| VSPRITE   Sprites Vectoriales (v3)
| PHREDA 2013
|-------------------------------------------
^r3/lib/gr.r3
^r3/lib/3d.r3

##paltex
|--------- formato vesprite
#yp #xp
:finpoli xp yp pline $80000000 'xp ! poli ;

|--------??????
:a0 drop ; 						| el valor no puede ser 0
:a1 8 >> 'ink ! ; 					| color0
:a2 swap >b gc>xy b@+ gc>xy 	| xc yc xm ym ; centro y matriz
	>r neg pick2 + r> neg pick2 +
	1.0 pick2 dup * pick2 dup * +
	1 max / >r 		| xc yc xm ym d
	swap neg r@ 16 *>> swap r> 16 *>>
	fmat fcen b> ;
:a3 gc>xy fcen @+ gc>xy fmat ;	| sirve esto???
|-------- poligono
:a4 xp $80000000 <>? ( yp pline )( drop )
	gc>xy 2dup 'yp !+ ! op ;  | punto
:a5 gc>xy pline ; | linea
:a6 swap >b gc>xy b@+ gc>xy pcurve b> ;  | curva
:a7 swap >b gc>xy b@+ gc>xy b@+ gc>xy pcurve3 b> ; | curva3
|-------- linea
:a8 gc>xy op ; | punto de trazo
:a9 gc>xy line ; | linea
:aa swap >b gc>xy b@+ gc>xy curve b> ;  | curva
:ab swap >b gc>xy b@+ gc>xy b@+ gc>xy curve3 b> ; | curva3
|-------- pintado de poligonos
:ac 8 >> 'ink ! sfill finpoli ; 			| solido
:ad 8 >> ink fcol lfill finpoli ; 	| ldegrade
:ae 8 >> ink fcol rfill finpoli ; 	| rdegrade
:af 8 >> 2 << paltex + @ tfill finpoli ; 	| tdegrade

#jves a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af

::vesprite | 'rf --
	$80000000 'xp !
	( @+ 1? )( dup $f and 2 << 'jves + @ exec ) 2drop ;

|--------- R vesprite
#cosa #sina | para rotar
:r>xy
	d>xy over sina * over cosa * + 16 >> h * 14 >> yc + >r
	swap cosa * swap sina * - 16 >> w * 14 >> xc + r> ;

|--------??????
:a2 swap >b r>xy b@+ r>xy 	| xc yc xm ym ; centro y matriz
	>r neg pick2 + r> neg pick2 +
	1.0 pick2 dup * pick2 dup * +
	1 max /  >r 		| xc yc xm ym d
	swap neg r@ 16 *>> swap r> 16 *>>
	fmat fcen b> ;
:a3 r>xy fcen @+ r>xy fmat ;	| sirve esto???
|-------- poligono
:a4 xp $80000000 <>? ( yp pline )( drop )
	r>xy 2dup 'yp !+ ! op ;  | punto
:a5 r>xy pline ; | linea
:a6 swap >b r>xy b@+ r>xy pcurve b> ;  | curva
:a7 swap >b r>xy b@+ r>xy b@+ r>xy pcurve3 b> ; | curva3
|-------- linea
:a8 r>xy op ; | punto de trazo
:a9 r>xy line ; | linea
:aa swap >b r>xy b@+ r>xy curve b> ;  | curva
:ab swap >b r>xy b@+ r>xy b@+ r>xy curve3 b> ; | curva3

#jves a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af

::rvesprite | adr ang --
	dup cos 'cosa ! sin 'sina !
	$80000000 'xp !
	( @+ 1? )( dup $f and 2 << 'jves + @ exec ) 2drop ;

|--------- 3d vesprite
| 3 << porque usa 14 bits a 17 bits queda 1.0
:3d>xy
	dup  18 >> 3 << swap 14 << 18 >> 3 << 0 project3d ;

|--------??????
:a2 swap >b 3d>xy b@+ 3d>xy 	| xc yc xm ym ; centro y matriz
	>r neg pick2 + r> neg pick2 +
	1.0 pick2 dup * pick2 dup * +
	1 max /  >r 		| xc yc xm ym d
	swap neg r@ 16 *>> swap r> 16 *>>
	fmat fcen b> ;
:a3 3d>xy fcen @+ 3d>xy fmat ;	| sirve esto???
|-------- poligono
:a4 xp $80000000 <>? ( yp pline )( drop )
	3d>xy 2dup 'yp !+ ! op ;  | punto
:a5 3d>xy pline ; | linea
:a6 swap >b 3d>xy b@+ 3d>xy pcurve b> ;  | curva
:a7 swap >b 3d>xy b@+ 3d>xy b@+ 3d>xy pcurve3 b> ; | curva3
|-------- linea
:a8 3d>xy op ; | punto de trazo
:a9 3d>xy line ; | linea
:aa swap >b 3d>xy b@+ 3d>xy curve b> ;  | curva
:ab swap >b 3d>xy b@+ 3d>xy b@+ 3d>xy curve3 b> ; | curva3

#jves a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af

::3dvesprite | adr --
	$80000000 'xp !
	( @+ 1? )( dup $f and 2 << 'jves + @ exec ) 2drop ;

|--------------------------------------------------------------
:dumprf | 'rf
	$80000000 'xp !
	( @+ 1? )( "%h " allowcr print ) 2drop
	cr
	;

|----------- interpolar 2 sprites
:lerp | t a b -- r | a + t * (b - a) | t 0.0 .. 1.0
	over - rot 16 *>> + ;

:inod | n s1 s2 v2 -- n s1 s2 n
	>r | n s1 s2
	swap @+ r>  | n s2 s1 v1 v2
	pick4 >r
	r@ pick2 d>x pick2 d>x lerp | n s2 s1 v1 v2 xx
	r> pick3 d>y pick3 d>y lerp xy>d
	nip swap $f and or | n s2 s1 v
	;

:inod2
	inod a!+ swap
	@+ inod ;

:inod3
	inod a!+ swap
	@+ inod a!+ swap
	@+ inod ;

:icol | n s1 s2 v2 -- c
	>r swap @+ 8 >> | n s2 s1 v1
	pick3 1? ( 1- 8 >> ) swap r@ 8 >>
	lerpcol
	8 << r> $f and or
	;

#jint 0 icol inod2 inod2 inod inod inod2 inod3 inod inod inod2 inod3 icol icol icol 0

| n 0.0 .. 1.0
| s1 sprite fuente 1
| s2 sprite fuente 2
| s3 sprite destino
|----------------------------------
::vespriteInter | n s1 s2 s3 --
	>a
	( @+ 1? )(
		dup $f and
		2 << 'jint + 1? ( @ exec )( drop )
		a!+	swap )
	a!
	3drop ;
