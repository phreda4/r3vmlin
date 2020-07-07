| load TGA
| faltan modos!!!
| PHREDA 2017
|-----------------------

#tgahead
#tgaw
#tgah
#tgacolormap
#tgaend
#tgaimage

:ReadTGA8bits ;
:ReadTGA16bits ;

:ReadTGA24bits
	>a
	here dup 'tgaimage ! >b
	tgaw tgah * ( 1? 1 -
		a@+ $ff000000 or b!+ -1 a+
		) drop
	tgahead 'here !
	tgaw tgah 12 << or ,
	here tgaimage tgaw tgah * dup 'here +! move
	tgahead ;


:ReadTGA32bits | adr -- new
	tgahead 'here !
   	tgaw tgah 12 << or ,
	here swap tgaw tgah * dup 'here +! move
	tgahead
	;

:ReadTGAgray8bits ;
:ReadTGAgray16bits ;
:ReadTGA8bitsRLE ;
:ReadTGA16bitsRLE ;

:runlen24 | adr cnt -- adr'
	swap @+ $ff000000 or
	rot $7f and 1 + ( 1? 1 - over b!+ ) 2drop
	1 - ;

:norun24 | adr cnt
	$7f and 1 + ( 1? 1 - swap
		@+ $ff000000 or b!+ 1 -
		swap ) drop ;

:trun
	$80 and? ( runlen24 ; )
	norun24 ;

:ReadTGA24bitsRLE
	here dup 'tgaimage ! >b
	( tgaend <?
		c@+ trun
		) drop
	tgahead 'here !
	tgaw tgah 12 << or ,
	here tgaimage tgaw tgah * dup 'here +! move
	tgahead
	;

:runlen32 | adr cnt -- adr'
	swap @+
	rot $7f and 1 + ( 1? 1 - over b!+ ) 2drop ;

:norun32 | adr cnt
	$7f and 1 + ( 1? 1 - swap
		@+ b!+
		swap ) drop ;

:trun
	$80 and? ( runlen32 ; )
	norun32 ;

:ReadTGA32bitsRLE
	here dup 'tgaimage ! >b
	( tgaend <?
		c@+ trun
		) drop
	tgahead 'here !
	tgaw tgah 12 << or ,
	here tgaimage tgaw tgah * dup 'here +! move
	tgahead
	;

:ReadTGAgray8bitsRLE ;
:ReadTGAgray16bitsRLE ;

:ReadTGAXbits
	tgahead 16 + c@
	16 =? ( drop ReadTGA16bits ; )
	24 =? ( drop ReadTGA24bits ; )
	32 =? ( drop ReadTGA32bits ; )
	drop ;

:ReadTGAgray
	tgahead 16 + c@
	8 =? ( drop ReadTGAgray8bits ; )
	16 =? ( drop ReadTGAgray16bits ; )
	drop ;

:ReadTGARLE
	tgahead 16 + c@
	16 =? ( drop ReadTGA16bitsRLE ; )
	24 =? ( drop ReadTGA24bitsRLE ; )
	32 =? ( drop ReadTGA32bitsRLE ; )
	drop ;

:ReadTGAgrayRLE
	tgahead 16 + c@
	8 =? ( drop ReadTGAgray8bitsRLE ; )
	16 =? ( drop ReadTGAgray16bitsRLE ; )
	drop ;

:tgaimage
	tgahead 2 + c@
	1 =? ( drop ReadTGA8bits ; )	| Uncompressed 8 bits color index
	2 =? ( drop ReadTGAXbits ; )	| Uncompressed 16-24-32 bits
    3 =? ( drop ReadTGAgray ; )		| Uncompressed 8 or 16 bits grayscale
	9 =? ( drop ReadTGA8bitsRLE ; ) | RLE compressed 8 bits color index
	10 =? ( drop ReadTGARLE ; )		| RLE compressed 16-24-32 bits
	11 =? ( drop ReadTGAgrayRLE ; )	| RLE compressed 8 or 16 bits grayscale
	2drop 0 ;

|  0 id_lenght;		/* size of image id
|  1 colormap_type;	/* 1 is has a colormap
|  2 image_type;	/* compression type
|  3 cm_first_entry;/* colormap origin
|  5 cm_length;     /* colormap length
|  7 cm_size;       /* colormap size
|  8 x_origin;      /* bottom left x coord origin
|  10 y_origin;     /* bottom left y coord origin
|  12 width;        /* picture width (in pixels)
|  14 height;       /* picture height (in pixels)
|  16 pixel_depth;  /* bits per pixel: 8, 16, 24 or 32
|  17 image_descriptor; /* 24 bits = 0x00; 32 bits = 0x80
:tgaheader | adr -- adr'
	dup 12 + @
	dup $ffff and 'tgaw !
	16 >> $ffff and 'tgah !
|	dup 1 + c@ 1? ( ) drop	| colormap
	18 + | heder size
	;

::loadtga | filename -- adr/0
	here dup 'tgahead !
	dup rot load over =? ( 2drop 0 ; )
	dup 'here ! 'tgaend !
	tgaheader
	tgaimage
	;

