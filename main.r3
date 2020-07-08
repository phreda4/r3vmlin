|---------------------------------
^r3/lib/gui.r3

#va 10

:draw
	vframe >a
	va ( 1? 1 -
		sw ( 1? 1 -
			$ff00 a!+ ) drop
	) drop ;


:main
	cls home
	"hola" print cr

	key

	>esc< =? ( exit )
	<up> =? ( 1 'va +! )
	<dn> =? ( -1 'va +! )
	drop
	;

: 'main onshow ;