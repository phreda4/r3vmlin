| lorenz
| GALILEOG 2016
| +3d PHREDA 2016
| r3 PHREDA 2019
|-------------------------------------------
^r3/lib/gui.r3
^r3/lib/3d.r3

#xcam 0 #ycam 0 #zcam -100.0

:fcircle | xc yc r --
	>r over r@ - over op
	2dup r@ - over r@ - over pcurve
	over r@ + over 2dup r@ - pcurve
	2dup r@ + over r@ + over pcurve
	swap r@ - swap 2dup r> + pcurve
	poli ;

:3dop project3d op ;
:3dline project3d line ;
:3dpoint project3d msec 6 >> $7 and 4 and? ( $7 xor ) 1 + fcircle ;

:grillaxy
	-50.0 ( 50.0 <=?
		dup -50.0 0 3dop dup 50.0 0 3dline
		-50.0 over 0 3dop 50.0 over 0 3dline
		10.0 + ) drop ;

:grillayz
	-50.0 ( 50.0 <=?
		0 over -50.0 3dop 0 over 50.0 3dline
		0 -50.0 pick2 3dop 0 50.0 pick2 3dline
		10.0 + ) drop ;

:grillaxz
	-50.0 ( 50.0 <=?
		dup 0 -50.0 3dop dup 0 50.0 3dline
		-50.0 0 pick2 3dop 50.0 0 pick2 3dline
		10.0 + ) drop ;


|---- lorenz

#s 10.0
#p 28.0
#b 2.6666
#zoom 6.0
#dt 0.004

#x 10.0
#y 0.0
#z 10.0

:asigna
	y x - s *. dt *. 'x +!
	p z - x *. y - dt *. 'y +!
	x y *. b z *. - dt *. 'z +!
	;

#lorenz * 120000	| 10000 puntos... con multiplos de 12 (3 puntos de 4 bytes)
#lorenz> 'lorenz	| cursor

:lorenz!+ | z y x --
	asigna
	x y z
	lorenz> 'lorenz> =? ( 'lorenz nip ) | la direccion del cursor sirve de limite en el array
	!+ !+ !+
	'lorenz> ! ;

:lorenz3d
	lorenz!+

	lorenz>
	'lorenz> =? ( 'lorenz nip )	| ultimo punto
	dup @ over 4 + @ pick2 8 + @ 3dop
	12 +
	( 'lorenz> <?
		dup @ over 4 + @ pick2 8 + @
		3dline
		12 +
		) drop
	'lorenz ( lorenz> <?
		dup @ over 4 + @ pick2 8 + @
		3dline
		12 +
		) drop

	lorenz> 12 -
	'lorenz <? ( 'lorenz> 12 - nip )	| ultimo punto
	$ffffff 'ink !
	@+ swap @+ swap @ 3dpoint
	;

:teclado
	key
	>esc< =? ( exit )
	<up> =? ( 0.1 'zcam +! )
	<dn> =? ( -0.1 'zcam +! )
	<le> =? ( 0.1 'xcam +! )
	<ri> =? ( -0.1 'xcam +! )
	<pgdn> =? ( 0.1 'ycam +! )
	<pgup> =? ( -0.1 'ycam +! )
	drop
	;


|------ vista
#xm #ym
#rx #ry
:dnlook
	xypen 'ym ! 'xm ! ;

:movelook
	xypen
	ym over 'ym ! - neg 7 << 'rx +!
	xm over 'xm ! - 7 << neg 'ry +!  ;

:inicio
	cls gui
   	teclado
	'dnlook 'movelook onDnMove
	1.0 3dmode
	rx mrotx ry mroty
	xcam ycam zcam mtrans
	$1f1f1f 'ink !
	grillaxy grillayz grillaxz

	$ff0000 'ink !
	lorenz3d

	$ff00 'ink !
	home
	"ViewLorenz3d" print cr
	z y x "x:%f y:%f z:%f" print

	acursor ;

:
0 'paper !
'inicio onshow ;