| cubo isometrico
| PHREDA 2017
|-------------------
^r3/lib/gui.r3
^r3/lib/3d.r3
^r3/lib/gr.r3

|------------------------------
#xcam 0 #ycam 0 #zcam 0

#octree

#octvert * 3072 	| 32 niveles de 3 valores*8 vert
#octvert> 'octvert

#rotsum * 2048		| 32 niveles de 2 valores*8 vert
#rotsum> 'rotsum

#ymin #nymin
#xmin #nxmin
#zmin #nzmin

#ymax #nymax
#xmax #nxmax
#zmax

#mask

#x0 #y0 #z0
#x1 #y1 #z1
#x2 #y2 #z2
#x4 #y4 #z4

#x7 #y7 #z7	| centro del cubo
#n1 #n2 #n3

#xmask * 1024
#ymask * 1024

:2/ 1 >> ;
:2* 1 << ;

|---------------
:fillstart | --
	'octvert >b
	1.0 1.0 1.0 transform b!+ b!+ b!+ | 111
	1.0 1.0 -1.0 transform b!+ b!+ b!+ | 110
	1.0 -1.0 1.0 transform b!+ b!+ b!+ | 101
	1.0 -1.0 -1.0 transform b!+ b!+ b!+ | 100
	-1.0 1.0 1.0 transform b!+ b!+ b!+ | 011
	-1.0 1.0 -1.0 transform b!+ b!+ b!+ | 010
	-1.0 -1.0 1.0 transform b!+ b!+ b!+ | 001
	-1.0 -1.0 -1.0 transform b!+ b!+ b!+ | 000
	b> 'octvert> !
	$ff $ff $ff transform 'x0 ! 'y0 ! 'z0 !
	$ff $ff -$ff transform 'x1 ! 'y1 ! 'z1 !
	$ff -$ff $ff transform 'x2 ! 'y2 ! 'z2 !
	-$ff $ff $ff transform 'x4 ! 'y4 ! 'z4 !
	-$ff -$ff -$ff transform
	x0 + 2/ 'x7 ! y0 + 2/ 'y7 ! z0 + 2/ 'z7 !
	;


| PERSPECTIVA
:id3d | x y z -- u v
	p3d ;

| ISOMETRICO
:id3d
	pick2 over - 0.03 / ox + >r
	rot + 2/ + 0.03 / oy + r> swap ;

:fillveciso | --
	octvert> 96 - >b
	'rotsum
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@+ id3d rot !+ !+
	b@+ b@+ b@ id3d rot !+ !+
	'rotsum> ! ;


:getp | n --
	3 << 'rotsum + @+ swap @ swap ;

:drawire
	$ffffff 'ink !
	0 getp op 1 getp line 3 getp line 2 getp line 0 getp line
	4 getp op 5 getp line 7 getp line 6 getp line 4 getp line
	0 getp op 4 getp line 1 getp op 5 getp line
	2 getp op 6 getp line 3 getp op 7 getp line
	;

:calco
	x0 x1 - x7 * y0 y1 - y7 * + z0 z1 - z7 * + dup 'n1 ! 63 >> $1 and
	x0 x2 - x7 * y0 y2 - y7 * + z0 z2 - z7 * + dup 'n2 ! 63 >> $2 and or
	x0 x4 - x7 * y0 y4 - y7 * + z0 z4 - z7 * + dup 'n3 ! 63 >> $4 and or
	$7 xor 'mask ! ;

|-----------------------------------------
:getn | id -- z y x
	dup 2* + 2 << 'octvert +
	@+ swap @+ swap @ dup >r
	pick2 over - 0.03 / ox + >r
	rot + 2/ + 0.03 / oy + r>
	r> rot rot ;

#xx0 #yy0 #zz0
#xx1 #yy1 #zz1
#xx2 #yy2 #zz2
#xx4 #yy4 #zz4

#minx #miny #minz
#lenx #leny #lenz

#vecpos * 128

|---- full
#stacko * 256
#stacko> 'stacko

:stack@ | -- top
	-4 'stacko> +! stacko> @ ;

:stack2@ | -- a b
	stacko> 8 - dup 'stacko> !
	@+ swap @ swap ;

:stack! | top --
	stacko> !+ 'stacko> ! ;

:stack2! | a b --
	stacko> !+ !+ 'stacko> ! ;

|--------------------------------------
#$base
#$magic
#$octree
#$pixels
#$paleta

:3do! | octree --
	dup '$base !
	dup 28 + '$octree !
	@+ '$magic !
	@ $octree + '$pixels !
	;

:octcolor | oct -- color
    $octree - $pixels + @ ;

#sumy #sumx
#len

:addchild | bm 0 mask -- bm ch mask
	1 over <<
	pick3 nand? ( drop ; ) drop
	swap 4 << over $8 or or swap ;

:fillchild | bitmask -- norden
	0
	mask addchild
	1 xor addchild	| 1 xor
	3 xor addchild	| 2 xor
	6 xor addchild	| 4 xor
	7 xor addchild	| 3 xor
	6 xor addchild	| 5 xor
	3 xor addchild	| 6 xor
	1 xor addchild	| 7 xor
	drop nip
	$ffffffff and ;

:level0 | y x mask -- y x mask
	over 1 << 'sumx !
	pick2 1 << 'sumy !
	'stacko 'stacko> !
	;

:getyxmakl | y x len -- y x len bm
	'ymask sumy + dup c@ swap pick2	+ c@ or
	'xmask sumx + dup c@ swap pick3 + c@ or and
	;

:getyxmask0 | y x -- y x mask
	over 1 << 'ymask + c@
	over 1 << 'xmask + c@ and $ff and
	;

:prevchild | y x len -- y x ordenn len
	1 >> 0? ( dup ; )
	stack@
	dup $7 and 4 << 'vecpos +
	@+ sumx 1 >> + 'sumx !
	@ sumy 1 >> + 'sumy !
	4 >>> 0? ( drop prevchild ; )
	swap ;

:nextchild | y x norden len -- y x norden len
	1 << swap
	dup $7 and 4 << 'vecpos +
	@+ neg sumx + 1 << 'sumx !
	@ neg sumy + 1 << 'sumy !
	stack!	| y x len
	getyxmakl 0? ( drop prevchild ; )
	fillchild  |  y x len norden
	swap ;

:rayfull2 | y x -- y x
	getyxmask0 0? ( drop 4 a+ ; )
	fillchild	| y x norden
	level0
	1 ( len <?		| y x norden len
		nextchild	| y x norden len
		0? ( 2drop 4 a+ ; )
		) 2drop
	$ff00 a!+ ;


|-----------------------------------
:raytest | y x --
	getyxmask0 0? ( drop 4 a+ ; )
	 a!+ ;
|-----------------------------------

:drawf | x y z --
	minx miny xy>v >a
	sw lenx - 2 <<
	0 ( leny <?
		0 ( lenx <?
			rayfull2
|			raytest
			1 + ) drop
		over a+
		1 + ) 2drop ;

|--------------------------------------
| with octree
|--------------------------------------
:getyxmakl | len -- len bm
	'ymask sumy + dup c@ swap pick2	+ 1 - c@ or
	'xmask sumx + dup c@ swap pick3 + 1 - c@ or and $ff and
	;

:level0 | y x mask -- y x mask
	over 1 << 'sumx ! pick2 1 << 'sumy !
	'stacko 'stacko> !
	;

:prevchild | len -- octree ordenn len
	1 >> 0? ( dup dup ; )
	stack2@	| len octree orden
	dup $7 and 4 << 'vecpos +
	@+ sumx 1 >> + 'sumx ! @ sumy 1 >> + 'sumy !
	4 >>> 0? ( 2drop prevchild ; )
	rot ;

#tpopcnt (
    0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4
    1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5
    1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5
    2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6
    1 2 2 3 2 3 3 4 2 3 3 4 3 4 4 5
    2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6
    2 3 3 4 3 4 4 5 3 4 4 5 4 5 5 6
    3 4 4 5 4 5 5 6 4 5 5 6 5 6 6 7 )

:popcnt | nro -- cnt
	'tpopcnt + c@ ;

:nextchild | octree norden len -- octree norden len
	1 << swap		| octree len norden
	dup $7 and
	1 over << 1 - >r
	4 << 'vecpos +
	@+ neg sumx + 1 << 'sumx ! @ neg sumy + 1 << 'sumy !
	stack!			| octree len
	swap dup stack!	| len octree
    @+ dup r> and popcnt swap 8 >> + 2 << +
	swap getyxmakl	| noctree len bm
	pick2 @ and 0? ( drop nip prevchild ; )
	fillchild  |  noctree len norden
	swap ;

:rayoctree | y x -- y x
	getyxmask0
	0? ( drop $ff0000 a!+ ; ) |4 a+ ; )
	level0
	$octree dup @ rot and
	0? ( 2drop $7f a!+ ; ) |4 a+ ; )
	fillchild	| y x octree norden
	1 ( len <?		| octree norden len
		nextchild	| octree norden len
		0? ( 3drop $ff a!+ ; ) |4 a+ ; )
		rot $pixels >=? ( octcolor a!+ 2drop ; ) rot rot
		) 2drop
	octcolor a!+ ;

:drawiso | --
	minx miny xy>v >a
	sw lenx - 2 <<
	0 ( leny <?
		0 ( lenx <?
			rayoctree
			1 + ) drop
		over a+
		1 + ) 2drop ;

|--------------------------------------
|--------------------------------------
:lbox | x1 y1 x2 y2
	2dup op pick3 over line 2over line
	over pick3 line line 2drop ;

:drawpanel | n --
	4 << 'vecpos +
	@+ 2/ minx + swap @ 2/ miny +
	over lenx 2/ + over leny 2/ +
	lbox ;

#colores $ffffff $ff0000 $00ff00 $ffff00 $0000ff $ff00ff $00ffff $888888

:pix
	and? ( b@+ ; )
	0 4 b+ ;

:drawxm
	'colores >b
	c@+ $1
	( $100 <?
		over pix
		dup a!+ sw 1 - 2 << a+
		a!+ sw 1 - 2 << a+
		2* ) 2drop ;

:drawym
	'colores >b
	c@+ $1
	( $100 <?
		over pix
		dup a!+ a!+
		2* ) 2drop ;

:drawrules
    0 ( 8 <?
    	dup 2 << 'colores + @ 'ink !
    	dup drawpanel
    	1 + ) drop
	'xmask
	0 ( lenx 2* <?  swap
    	over minx + miny 20 - xy>v >a
		drawxm
		swap 1 + ) 2drop
	'ymask
	0 ( leny 2* <?  swap
		minx 20 - pick2 miny + xy>v >a
		drawym
		swap 1 + ) 2drop
	;


|--------------------------------------
:sminmax3 | a b c -- sn sx
	pick2 dup 63 >> not and
	pick2 dup 63 >> not and +
	over dup 63 >> not and + >r
	dup 63 >> and
	swap dup 63 >> and +
	swap dup 63 >> and +
	r> ;

:packxyza!+ | x y z -- xyz0
	rot xx0 + minx - a!+
	swap yy0 + miny - a!+
	zz0 + minz - a!+
	0 a!+ ;

:fillx | child x --
	xx0 + minx - 'xmask +
	lenx |1 +
	( 1? 1 - | child xmin len
		pick2 pick2 c+!
		swap 1 + swap ) 3drop ;

:filly | child x --
	yy0 + miny - 'ymask +
	leny |1 + 
	( 1? 1 - | child xmin len
		pick2 pick2 c+!
		swap 1 + swap ) 3drop ;

:maskini
	'xmask 0 256 fill
	$1 0 fillx
	$2 xx1 fillx
	$4 xx2 fillx
	$8 xx1 xx2 + fillx
	$10 xx4 fillx
	$20 xx4 xx1 + fillx
	$40 xx4 xx2 + fillx
	$80 xx4 xx2 + xx1 + fillx
	'ymask 0 256 fill
	$1 0 filly
	$2 yy1 filly
	$4 yy2 filly
	$8 yy1 yy2 + filly
	$10 yy4 filly
	$20 yy4 yy1 + filly
	$40 yy4 yy2 + filly
	$80 yy4 yy2 + yy1 + filly
	;

:algo1
	0 getn 'xx0 ! 'yy0 ! 'zz0 !
	1 getn xx0 - 'xx1 ! yy0 - 'yy1 ! zz0 - 'zz1 !
	2 getn xx0 - 'xx2 ! yy0 - 'yy2 ! zz0 - 'zz2 !
	4 getn xx0 - 'xx4 ! yy0 - 'yy4 ! zz0 - 'zz4 !
    xx1 xx2 xx4 sminmax3 over - 1 +
	'lenx ! xx0 + 'minx !
    yy1 yy2 yy4 sminmax3 over - 1 +
	'leny ! yy0 + 'miny !
    zz1 zz2 zz4 sminmax3 over - 1 +
	'lenz ! zz0 + 'minz !

	lenx leny min 2 >> 'len !

	'vecpos >a
	0 0 0 packxyza!+
	xx1 yy1 zz1 packxyza!+
	xx2 yy2 zz2 packxyza!+
	xx1 xx2 + yy1 yy2 + zz1 zz2 + packxyza!+
	xx4 yy4 zz4 packxyza!+
	xx4 xx1 + yy4 yy1 + zz4 zz1 + packxyza!+
	xx4 xx2 + yy4 yy2 + zz4 zz2 + packxyza!+
	xx4 xx1 + xx2 + yy4 yy1 + yy2 + zz4 zz1 + zz2 + packxyza!+
	maskini
|	drawrules

	|drawf

	octree 3do!
	drawiso

	;

;

|----------------------------------------
:dumpvar
	$ff00 'ink !
	minz miny minx "%d %d %d " print cr
	lenz leny lenx "%d %d %d " print cr

|	$ffff 'ink ! 0 getp 1 box
|	$ffffff 'ink ! mask getp 3 box
|	minx miny op minx lenx + miny leny + line
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

#ani 0
|-----------------------------------------
:main
	cls home gui
	over "%d" print cr
	octree "%h" print cr
	Omode
	rx mrotx ry mroty
	xcam ycam zcam mtrans

	fillstart
	fillveciso
	calco

	dumpvar
	algo1
|	drawire
	ani 1? ( 0.008 'ry +! ) drop
    'dnlook 'movelook onDnMove
	key
	<f1> =? ( ani 1 xor 'ani ! )
	<up> =? ( -0.01 'zcam +! )
	<dn> =? ( 0.01 'zcam +! )
	<le> =? ( -0.01 'xcam +! )
	<ri> =? ( 0.01 'xcam +! )
	<pgup> =? ( -0.01 'ycam +! )
	<pgdn> =? ( 0.01 'ycam +! )
	>esc< =? ( exit )
	drop
	acursor ;

:load3do | "" -- moctree
	here dup rot load 'here ! ;

:
	33
	mark
	"media/3do/shuttle.3do" load3do 'octree !
	'main onshow ;
