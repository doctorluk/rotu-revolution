REM //******************************************************************************
REM // Call of Duty 4: Modern Warfare
REM //******************************************************************************
REM // Mod      : RotU - Revolution for COD4:MW!
REM // Website  : http://sogmods.net
REM //******************************************************************************

@echo off
set COMPILEDIR=%CD%
set MAINDIR=%CD%../..
set color=0A
set modName=rotur_dev
set mapname=mp_shipment
set serverip=127.0.0.1
set configfile=server
color %color%

:START
cls
echo.
echo     "%modName%" a Mod for
echo     Call of Duty 4: Modern Warfare         
echo.
goto MAKEOPTIONS

:MAKEOPTIONS
echo _________________________________________________________________
echo.
echo  Please select an option:
echo    1. Build everything
echo    2. Build .iwd files
echo    3. Build mod.ff
echo    4. Start Game
echo    5. Start Game in developer mode
echo    6. Start Game with custom command line
echo    7. Start Game and connect to sandbox
echo.
echo    0. Exit
echo.
set /p main_option=:
set main_option=%main_option:~0,1%
if "%main_option%"=="1" goto CHOOSE_LANG
if "%main_option%"=="2" goto CHOOSE_IWD
if "%main_option%"=="3" goto CHOOSE_LANG
if "%main_option%"=="4" goto START_GAME
if "%main_option%"=="5" goto START_GAME_DEV
if "%main_option%"=="6" goto START_GAME_CHOOSE
if "%main_option%"=="7" goto START_GAME_CLIENT
if "%main_option%"=="0" goto FINAL
goto START

:CHOOSE_LANG
echo _________________________________________________________________
echo.
echo  Please choose the language you would like to compile:
echo    1. English
echo    2. French
echo    3. German
echo    4. Italian
echo    5. Portuguese
echo    6. Russian
echo    7. Spanish
echo.
echo    0. Back
echo.
set /p lang_chosen=:
set lang_chosen=%lang_chosen:~0,1%
if "%lang_chosen%"=="1" goto LANGEN
if "%lang_chosen%"=="2" goto LANGFR
if "%lang_chosen%"=="3" goto LANGDE
if "%lang_chosen%"=="4" goto LANGIT
if "%lang_chosen%"=="5" goto LANGPT
if "%lang_chosen%"=="6" goto LANGRU
if "%lang_chosen%"=="7" goto LANGES
if "%lang_chosen%"=="0" goto MAKEOPTIONS
goto CHOOSE_LANG

:LANGEN
set CLANGUAGE=English
set LANG=english
set LTARGET=english
goto COMPILE

:LANGFR
set CLANGUAGE=French
set LANG=french
set LTARGET=french
goto COMPILE

:LANGDE
set CLANGUAGE=German
set LANG=german
set LTARGET=german
goto COMPILE

:LANGIT
set CLANGUAGE=Italian
set LANG=italian
set LTARGET=italian
goto COMPILE

:LANGPT
set CLANGUAGE=Portuguese
set LANG=portuguese
set LTARGET=leet
goto COMPILE

:LANGRU
set CLANGUAGE=Russian
set LANG=russian
set LTARGET=russian
goto COMPILE

:LANGES
set CLANGUAGE=Spanish
set LANG=spanish
set LTARGET=spanish
goto COMPILE

:COMPILE
echo.

echo  Checking language directories...
if not exist ..\..\zone\%LTARGET% mkdir ..\..\zone\%LTARGET%
if not exist ..\..\zone_source\%LTARGET% xcopy ..\..\zone_source\english ..\..\zone_source\%LTARGET% /SYI > NUL

echo  %modName% will be created in %CLANGUAGE%!
if "%main_option%"=="1" goto BUILD_SVR_IWD
if "%main_option%"=="3" goto MAKE_MOD_FF
goto END

:CHOOSE_IWD
echo _________________________________________________________________
echo.
echo  Please select the iwd you want to create
echo     1. create all iwds
echo     2. create z_svr_scripts.iwd - script files
echo     3. create zz_images.iwd - .iwi image files
echo     4. create zz_sounds.iwd - sound files
echo     5. create zz_%modName%.iwd - weapon files
echo.
echo     0. Back
echo.
set /p iwd_option=:
set iwd_option=%iwd_option:~0,1%
if "%iwd_option%"=="1" goto BUILD_SVR_IWD
if "%iwd_option%"=="2" goto BUILD_SVR_IWD
if "%iwd_option%"=="3" goto BUILD_IMAGES_IWD
if "%iwd_option%"=="4" goto BUILD_SOUNDS_IWD
if "%iwd_option%"=="5" goto BUILD_MOD_IWD
if "%iwd_option%"=="0" goto MAKEOPTIONS
goto CHOOSE_IWD

:BUILD_SVR_IWD
echo _________________________________________________________________
echo.
echo  Building z_svr_scripts.iwd
echo  Deleting old z_svr_scripts.iwd...
del z_svr_scripts.iwd
echo  Adding maps\mp folder...
7z a -r -tzip z_svr_scripts.iwd maps\mp\*.* > NUL
echo  Adding scripts folder...
7z a -r -tzip z_svr_scripts.iwd scripts\*.* > NUL
echo  Adding common_scripts folder...
7z a -r -tzip z_svr_scripts.iwd common_scripts\*.* > NUL
echo  New z_svr_scripts.iwd file successfully built!
if "%iwd_option%"=="1" goto BUILD_IMAGES_IWD
if "%main_option%"=="1" goto BUILD_IMAGES_IWD
goto END

:BUILD_IMAGES_IWD
echo _________________________________________________________________
echo.
echo  Building zz_images.iwd
echo  Deleting old zz_images.iwd...
del zz_images.iwd
echo  Adding images...
7z a -r -tzip zz_images.iwd images\*.iwi > NUL
echo  New zz_images.iwd file successfully built!
if "%iwd_option%"=="1" goto BUILD_SOUNDS_IWD
if "%main_option%"=="1" goto BUILD_SOUNDS_IWD
goto END

:BUILD_SOUNDS_IWD
echo _________________________________________________________________
echo.
echo  Building zz_sounds.iwd
echo  Deleting old zz_sounds.iwd...
del zz_sounds.iwd
echo  Adding sounds...
7z a -r -tzip zz_sounds.iwd sound\*.* > NUL
echo  New zz_sounds.iwd file successfully built!
if "%iwd_option%"=="1" goto BUILD_MOD_IWD
if "%main_option%"=="1" goto BUILD_MOD_IWD
goto END

:BUILD_MOD_IWD
echo _________________________________________________________________
echo.
echo  Building zz_%modName%.iwd
echo  Deleting old zz_%modName%.iwd...
del zz_%modName%.iwd
echo  Adding weapons folder...
7z a -r -tzip zz_%modName%.iwd weapons\mp\* > NUL
echo  Adding character folder...
7z a -r -tzip zz_%modName%.iwd character\*.* > NUL
echo  Adding mptype folder...
7z a -r -tzip zz_%modName%.iwd mptype\*.* > NUL
echo  New zz_%modName%.iwd file successfully built!
if "%main_option%"=="1" goto MAKE_MOD_FF
goto END

:MAKE_MOD_FF
echo _________________________________________________________________
echo.
echo  Building mod.ff
echo  Deleting old mod.ff backup file...
del mod.ff.bak
echo  Backing up old mod.ff file...
rename mod.ff mod.ff.bak

echo  Copying localized strings...
robocopy %LANG% ..\..\raw\%LTARGET% /E /NS /NC /NFL /NDL /NJH /NJS > NUL

echo  Copying game resources...
robocopy animtrees ..\..\raw\animtrees /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy fx ..\..\raw\fx /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy images ..\..\raw\images /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy clientcfg ..\..\raw\clientcfg /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy maps ..\..\raw\maps /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy material_properties ..\..\raw\material_properties /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy materials ..\..\raw\materials /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy mp ..\..\raw\mp /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy scripts ..\..\raw\scripts /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy shock ..\..\raw\shock /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy sound ..\..\raw\sound /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy sound_modff ..\..\raw\sound /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy soundaliases ..\..\raw\soundaliases /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy ui ..\..\raw\ui /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy ui_mp ..\..\raw\ui_mp /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy vision ..\..\raw\vision /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy weapons\mp ..\..\raw\weapons\mp /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy weapons_fake\mp ..\..\raw\weapons\mp /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy xanim ..\..\raw\xanim /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy xmodel ..\..\raw\xmodel /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy xmodelparts ..\..\raw\xmodelparts /E /NS /NC /NFL /NDL /NJH /NJS > NUL
robocopy xmodelsurfs ..\..\raw\xmodelsurfs /E /NS /NC /NFL /NDL /NJH /NJS > NUL
REM xcopy zone_source ..\..\zone_source /SYI > NUL

echo  Copying csv files...
copy /Y mod.csv ..\..\zone_source > NUL
copy /Y mod_ignore.csv ..\..\zone_source\%LTARGET%\assetlist > NUL
REM copy /Y mod_server.csv ..\..\zone_source > NUL
REM copy /Y mod_weapons.csv ..\..\zone_source > NUL
cd ..\..\bin > NUL

echo  Compiling mod...
linker_pc.exe -language %LTARGET% -compress -cleanup mod
cd %COMPILEDIR% > NUL
copy ..\..\zone\%LTARGET%\mod.ff > NUL
echo  New mod.ff file successfully built!
goto END

REM //******************************************************************************
REM // START GAME
REM //******************************************************************************
:START_GAME
echo _________________________________________________________________
echo.
echo  Please select an option to start with:
echo     1. "logfile 1"
echo     2. "exec %configfile%"
echo     3. "map_rotate"
echo     4. "logfile 1 exec %configfile%"
echo     5. "logfile 1 exec %configfile% map_rotate"
echo.
echo     0. Back
echo.
set /p start_option=:
set start_option=%start_option:~0,1%
if "%start_option%"=="1" (
	set commandline=+set logfile 1
	goto START_GAME_CUSTOM
)
if "%start_option%"=="2" (
	set commandline=+exec %configfile%
	goto START_GAME_CUSTOM
)
if "%start_option%"=="3" (
	set commandline=+map_rotate
	goto START_GAME_CUSTOM
)
if "%start_option%"=="4" (
	set commandline=+set logfile 1 +exec %configfile%
	goto START_GAME_CUSTOM
)
if "%start_option%"=="5" (
	set commandline=+set logfile 1 +exec %configfile% +map_rotate
	goto START_GAME_CUSTOM
)
if "%start_option%"=="0" goto MAKEOPTIONS
goto START_GAME

:START_GAME_DEV
echo _________________________________________________________________
echo.
echo  Please select an option to start with:
echo     1. "developer 1"
echo     2. "developer 1 developer_script 1"
echo     3. "logfile 1 developer 1 developer_script 1"
echo     4. "logfile 1 developer 1 developer_script 1 exec %configfile%"
echo     5. "logfile 1 developer 1 developer_script 1 exec %configfile% devmap %mapname%"
echo     6. "logfile 1 developer 1 exec %configfile% devmap %mapname%"
echo.
echo     0. Back
echo.
set /p start_option=:
set start_option=%start_option:~0,1%
if "%start_option%"=="1" (
	set commandline=+set developer 1
	goto START_GAME_CUSTOM
)
if "%start_option%"=="2" (
	set commandline=+set developer 1 +set developer_script 1
	goto START_GAME_CUSTOM
)
if "%start_option%"=="3" (
	set commandline=+set logfile 1 +set developer 1 +set developer_script 1
	goto START_GAME_CUSTOM
)
if "%start_option%"=="4" (
	set commandline=+set logfile 1 +set developer 1 +set developer_script 1 +exec %configfile%
	goto START_GAME_CUSTOM
)
if "%start_option%"=="5" (
	set commandline=+set logfile 1 +set developer 1 +set developer_script 1 +exec %configfile% +devmap %mapname%
	goto START_GAME_CUSTOM
)
if "%start_option%"=="6" (
	set commandline=+set logfile 1 +set developer 1 +exec %configfile% +devmap %mapname%
	goto START_GAME_CUSTOM
)
if "%start_option%"=="0" goto MAKEOPTIONS
goto START_GAME_DEV

:START_GAME_CHOOSE
echo _________________________________________________________________
echo.
echo  Please select an prefix to start with:
echo     1. "logfile 1"
echo     2. "exec %configfile%"
echo     3. "map_rotate"
echo     4. "logfile 1 exec %configfile%"
echo     5. "logfile 1 exec %configfile% map_rotate"
echo.
echo     6. "developer 1"
echo     7. "developer 1 developer_script 1"
echo     8. "logfile 1 developer 1 developer_script 1"
echo     9. "logfile 1 developer 1 developer_script 1 exec %configfile% devmap %mapname%"
echo.
echo     0. Back
echo.
set /p start_option=:
set start_option=%start_option:~0,1%
REM NORMAL
if "%start_option%"=="1" set commandline=+set logfile 1
if "%start_option%"=="2" set commandline=+exec %configfile%
if "%start_option%"=="3" set commandline=+map_rotate
if "%start_option%"=="4" set commandline=+set logfile 1 +exec %configfile%
if "%start_option%"=="5" set commandline=+set logfile 1 +exec %configfile% +map_rotate
REM DEVELOPER
if "%start_option%"=="6" set commandline=+set developer 1
if "%start_option%"=="7" set commandline=+set developer 1 +set developer_script 1
if "%start_option%"=="8" set commandline=+set logfile 1 +set developer 1 +set developer_script 1
if "%start_option%"=="9" set commandline=+set logfile 1 +set developer 1 +set developer_script 1 +exec %configfile% +devmap %mapname%
if "%start_option%"=="0" goto MAKEOPTIONS
echo _________________________________________________________________
echo.
echo  Please type the custom command input below
echo.
set /p additions=:
REM if "%start_option%"=="5"
REM if "%start_option%"=="9"
set commandline=%commandline% %additions%
goto START_GAME_CUSTOM

:START_GAME_CLIENT
echo _________________________________________________________________
echo.
echo  Connecting to server %serverip%...
echo.
set commandline=+connect %serverip%
goto START_GAME_CUSTOM

:START_GAME_CUSTOM
echo _________________________________________________________________
echo.
echo  Starting Call of Duty 4:Modern Warfare - Multiplayer
echo.
cd ../..
echo  %CD%\iw3mp.exe +set sv_punkbuster 0 +set fs_game mods/%modName% %commandline%
iw3mp.exe +set sv_punkbuster 0 +set fs_game mods/%modName% %commandline%
goto FINAL

REM //******************************************************************************
REM // END
REM //******************************************************************************

:END
echo _________________________________________________________________
echo.
pause
goto FINAL

:FINAL