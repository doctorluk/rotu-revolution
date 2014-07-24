#ifndef ROTU_LOGO_X
	#define ROTU_LOGO_X 0
#endif
	
#ifndef ROTU_LOGO_Y_OFFSET
	#define ROTU_LOGO_Y_OFFSET -146
#endif

#ifndef ROTU_LOGO_Y
	#define ROTU_LOGO_Y ROTU_LOGO_Y_OFFSET
#endif

#ifndef ROTU_LOGO_X_SIZE
	#define ROTU_LOGO_X_SIZE 350
#endif

#ifndef ROTU_LOGO_Y_SIZE
	#define ROTU_LOGO_Y_SIZE 292
#endif

#ifndef ROTU_LOGO_HORIZONTAL_ALIGN
	#define ROTU_LOGO_HORIZONTAL_ALIGN HORIZONTAL_ALIGN_CENTER
#endif

#ifndef ROTU_LOGO_VERTICAL_ALIGN
	#define ROTU_LOGO_VERTICAL_ALIGN VERTICAL_ALIGN_CENTER
#endif


itemDef
{
	visible			1
	rect			ROTU_LOGO_X ROTU_LOGO_Y ROTU_LOGO_X_SIZE ROTU_LOGO_Y_SIZE ROTU_LOGO_HORIZONTAL_ALIGN ROTU_LOGO_VERTICAL_ALIGN
	forecolor		1 1 1 1
	style			WINDOW_STYLE_SHADER
	background		"rotu-r_logo"
	visible 		when( !localvarBool( ui_hideBack ) && dvarString("ui_mainmenu_logo") != "0" );
	decoration
}