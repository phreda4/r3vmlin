| Lee BMP 4,8 y 32 bit sin comprimir
| PHREDA
|------------------------------------------
#wbmp
#hbmp
#bbmp

#pal
#pad

|----------------------------
#slot 0

:color4>32 | b -- b+ rgb
	slot -? ( drop c@+ $ff and dup 'slot ! 4 >> 2 << pal + @ ; )
	$f and 2 << pal + @ -1 'slot ! ;

:color8>32 | b -- b+ rgb
	c@+ $ff and 2 << pal + @ ;

:color24>32 | 'b -- 'b+ rgb
	c@+ $ff and >r c@+ $ff and 8 << >r c@+ $ff and 16 << r> or r> or ;

|----------------------------
:linea24 | 'v 'b --
	wbmp ( 1? 1 - >r
		color24>32 rot !+ swap
		r> )  drop ;

:linea8 | 'v 'b --
	wbmp ( 1? 1 - >r
		color8>32 rot !+ swap
		r> )  drop ;

:linea4 | 'v 'b --
	-1 'slot !
	wbmp ( 1? 1 - >r
		color4>32 rot !+ swap
		r> )  drop ;

#finimg
#modolin

|-----------------------------
:moveor | de sr cnt --
	rot >a
	( 1? 1 - swap
		@+ $ff000000 or a!+
		swap ) 2drop ;

::loadBMP | "nombre" -- 0/mem
	here swap load
	here =? ( drop 0 ; ) 'finimg !
	here
	dup @ $ffff and $4d42 <>? ( 2drop 0 ; ) drop | magic
	dup $12 + @ 'wbmp !
	dup $16 + @ 'hbmp !
	dup $36 + 'pal !

    1 'pad !
	dup 10 + @
	'linea8 'modolin !
	54 =? ( 'linea24 'modolin ! 3 'pad ! )
	118 =? ( 'linea4 'modolin ! )
	+ wbmp hbmp 1 - * 2 << finimg +
    4 wbmp pad * $3 and - $3 and 'pad !
	swap
	hbmp ( 1? 1 - >r
		modolin ex
		swap wbmp 3 <<  -
		swap pad +
		r> ) 3drop
	here
	wbmp hbmp 12 << or ,
	here finimg wbmp hbmp * moveor
	wbmp hbmp * 2 + 2 << over + 'here !
	;

