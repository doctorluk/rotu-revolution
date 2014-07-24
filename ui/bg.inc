#undef	FOG_SCROLL_TIME
#define FOG_SCROLL_TIME 60000 //30000

#undef	THINFOG_SCROLL_TIME
#define THINFOG_SCROLL_TIME 100000 //50000

#define STEP_1 6891
// #define STEP_1 2000
#define STEP_2 9876
#define STEP_3 8444
#define STEP_4 14785

#define THUNDER_DURATION_MIN 120
#define THUNDER_DURATION_MAX_ADD 100

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	// rect			-107 0 854 480
	background		"animbg_front"
	forecolor		1 1 1 1
	visible			when( dvarString( fs_game ) != ""  )
	decoration
}

// -- 
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 1
	exp forecolor A( 1 - ( (milliseconds() % STEP_1) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_1 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 1
	exp forecolor A( 1 - ( (milliseconds() % STEP_2) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_2 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 1
	exp forecolor A( 1 - ( (milliseconds() % STEP_3) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_3 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			FULLSCREEN_WIDE
	background		"bg_front_thunder"
	forecolor		1 1 1 1
	exp forecolor A( 1 - ( (milliseconds() % STEP_4) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) )
	visible			when( ( milliseconds() % STEP_4 < (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD)) ) && dvarString("ui_mainmenu_thunder") != "0" )
	decoration
}
// --
 
itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-107 0 1708 480
	exp				rect X((-107) - ((float(milliseconds() % FOG_SCROLL_TIME) / FOG_SCROLL_TIME) * (854)))
	forecolor		1 0.6 0.6 0.2
	background		"animbg_fogscroll"
	visible			when( dvarString( fs_game ) != "" )
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-107 0 1708 480
	exp				rect X((-961) + ((float(milliseconds() % THINFOG_SCROLL_TIME) / THINFOG_SCROLL_TIME) * (854)))
	background		"animbg_fogscrollthin"
	forecolor		1 0.6 0.6 0.9
	visible			when( dvarString( fs_game ) != "" )
	decoration
}

// itemDef // DEBUG
// {
	// rect		0 0 0 0 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_CENTER
	// exp text	( "Alpha: " + ( 1 - ( (milliseconds() % STEP_1) / (THUNDER_DURATION_MIN + (milliseconds() % THUNDER_DURATION_MAX_ADD) ) ) ) );
	// textfont	UI_FONT_DEFAULT
	// textscale	0.4
	// textalign	ITEM_ALIGN_CENTER
	// textstyle	ITEM_TEXTSTYLE_SHADOWEDMORE
	// forecolor	1 1 1 1
	// visible 	when ( 1 )
// }