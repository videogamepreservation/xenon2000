# Microsoft Developer Studio Project File - Name="xenon" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=xenon - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "xenon.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "xenon.mak" CFG="xenon - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "xenon - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "xenon - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "xenon - Win32 TrueTime" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "xenon - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /G6 /Gr /W3 /GX /Zi /O2 /Ob2 /I ".\includes" /I "..\gamesystem\includes" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"game.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x809 /d "NDEBUG"
# ADD RSC /l 0x809 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dxguid.lib ddraw.lib dinput.lib winmm.lib bass.lib /nologo /subsystem:windows /pdb:"..\bin\Release/xenon.pdb" /debug /machine:I386 /out:"..\bin\Release/xenon.exe" /libpath:"..\libs\Release"
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "xenon - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "xenon___Win32_Debug"
# PROP BASE Intermediate_Dir "xenon___Win32_Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /G6 /Gr /W3 /Gm /GX /ZI /Od /I ".\includes" /I "..\gamesystem\includes" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FR /Yu"game.h" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x809 /d "_DEBUG"
# ADD RSC /l 0x809 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dxguid.lib ddraw.lib dinput.lib winmm.lib bass.lib /nologo /subsystem:windows /pdb:"..\bin\Debug/xenon.pdb" /debug /machine:I386 /out:"..\bin\Debug/xenon.exe" /pdbtype:sept /libpath:"..\libs\Debug"
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "xenon - Win32 TrueTime"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "xenon___Win32_TrueTime"
# PROP BASE Intermediate_Dir "xenon___Win32_TrueTime"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "TrueTime"
# PROP Intermediate_Dir "TrueTime"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /G6 /Gr /W3 /GX /Zi /O2 /Ob2 /I ".\includes" /I "..\gamesystem\includes" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"game.h" /FD /c
# ADD CPP /nologo /G6 /Gr /W3 /GX /Zi /O2 /Ob2 /I ".\includes" /I "..\gamesystem\includes" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_PROFILING" /Yu"game.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x809 /d "NDEBUG"
# ADD RSC /l 0x809 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dxguid.lib ddraw.lib dinput.lib winmm.lib bass.lib /nologo /subsystem:windows /pdb:"..\bin\Release/xenon.pdb" /debug /machine:I386 /out:"..\bin\Release/xenon.exe" /libpath:"..\libs\Release"
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib dxguid.lib ddraw.lib dinput.lib winmm.lib bass.lib /nologo /subsystem:windows /pdb:"..\bin\TrueTime/xenon.pdb" /debug /machine:I386 /out:"..\bin\TrueTime/xenon.exe" /libpath:"..\libs\Release"
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "xenon - Win32 Release"
# Name "xenon - Win32 Debug"
# Name "xenon - Win32 TrueTime"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\source\actor.cpp
# End Source File
# Begin Source File

SOURCE=.\source\actorinfo.cpp
# End Source File
# Begin Source File

SOURCE=.\source\alien.cpp
# End Source File
# Begin Source File

SOURCE=.\source\asteroid.cpp
# End Source File
# Begin Source File

SOURCE=.\source\audiomenustate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\boss.cpp
# End Source File
# Begin Source File

SOURCE=.\source\bosscontrol.cpp
# End Source File
# Begin Source File

SOURCE=.\source\bosseye.cpp
# End Source File
# Begin Source File

SOURCE=.\source\bossmouth.cpp
# End Source File
# Begin Source File

SOURCE=.\source\bullet.cpp
# End Source File
# Begin Source File

SOURCE=.\source\clone.cpp
# End Source File
# Begin Source File

SOURCE=.\source\cloneengine.cpp
# End Source File
# Begin Source File

SOURCE=.\source\controlmenustate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\creditsstate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\demorecorder.cpp
# End Source File
# Begin Source File

SOURCE=.\source\drone.cpp
# End Source File
# Begin Source File

SOURCE=.\source\dronegenerator.cpp
# End Source File
# Begin Source File

SOURCE=.\source\dusteffect.cpp
# End Source File
# Begin Source File

SOURCE=.\source\engine.cpp
# End Source File
# Begin Source File

SOURCE=.\source\explosion.cpp
# End Source File
# Begin Source File

SOURCE=.\source\game.cpp
# ADD CPP /Yc"game.h"
# End Source File
# Begin Source File

SOURCE=.\source\gamestate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\homer.cpp
# End Source File
# Begin Source File

SOURCE=.\source\homerprojectile.cpp
# End Source File
# Begin Source File

SOURCE=.\source\homerprojectileweapon.cpp
# End Source File
# Begin Source File

SOURCE=.\source\homingmissile.cpp
# End Source File
# Begin Source File

SOURCE=.\source\homingmissileweapon.cpp
# End Source File
# Begin Source File

SOURCE=.\source\introstate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\label.cpp
# End Source File
# Begin Source File

SOURCE=.\source\laser.cpp
# End Source File
# Begin Source File

SOURCE=.\source\laserweapon.cpp
# End Source File
# Begin Source File

SOURCE=.\source\level.cpp
# End Source File
# Begin Source File

SOURCE=.\source\loner.cpp
# End Source File
# Begin Source File

SOURCE=.\source\mainmenustate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\messageboxstate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\missile.cpp
# End Source File
# Begin Source File

SOURCE=.\source\missileweapon.cpp
# End Source File
# Begin Source File

SOURCE=.\source\options.cpp
# End Source File
# Begin Source File

SOURCE=.\source\optionsmenustate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\organicgun.cpp
# End Source File
# Begin Source File

SOURCE=.\source\particleeffect.cpp
# End Source File
# Begin Source File

SOURCE=.\source\pickup.cpp
# End Source File
# Begin Source File

SOURCE=.\source\player.cpp
# End Source File
# Begin Source File

SOURCE=.\source\playgamestate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\pod.cpp
# End Source File
# Begin Source File

SOURCE=.\source\retroengine.cpp
# End Source File
# Begin Source File

SOURCE=.\source\rusher.cpp
# End Source File
# Begin Source File

SOURCE=.\source\rushergenerator.cpp
# End Source File
# Begin Source File

SOURCE=.\source\scene.cpp
# End Source File
# Begin Source File

SOURCE=.\source\scoreentrystate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\ship.cpp
# End Source File
# Begin Source File

SOURCE=.\source\shipengine.cpp
# End Source File
# Begin Source File

SOURCE=.\source\smokeeffect.cpp
# End Source File
# Begin Source File

SOURCE=.\source\spinner.cpp
# End Source File
# Begin Source File

SOURCE=.\source\spinnerweapon.cpp
# End Source File
# Begin Source File

SOURCE=.\source\spore.cpp
# End Source File
# Begin Source File

SOURCE=.\source\sporegenerator.cpp
# End Source File
# Begin Source File

SOURCE=.\source\upgrade.cpp
# End Source File
# Begin Source File

SOURCE=.\source\videomenustate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\viewscoresstate.cpp
# End Source File
# Begin Source File

SOURCE=.\source\wallhugger.cpp
# End Source File
# Begin Source File

SOURCE=.\source\weapon.cpp
# End Source File
# Begin Source File

SOURCE=.\source\wingtip.cpp
# End Source File
# Begin Source File

SOURCE=.\source\xenon.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\includes\actor.h
# End Source File
# Begin Source File

SOURCE=.\includes\actorinfo.h
# End Source File
# Begin Source File

SOURCE=.\includes\alien.h
# End Source File
# Begin Source File

SOURCE=.\includes\asteroid.h
# End Source File
# Begin Source File

SOURCE=.\includes\audiomenustate.h
# End Source File
# Begin Source File

SOURCE=.\includes\boss.h
# End Source File
# Begin Source File

SOURCE=.\includes\bosscontrol.h
# End Source File
# Begin Source File

SOURCE=.\includes\bosseye.h
# End Source File
# Begin Source File

SOURCE=.\includes\bossmouth.h
# End Source File
# Begin Source File

SOURCE=.\includes\bullet.h
# End Source File
# Begin Source File

SOURCE=.\includes\clone.h
# End Source File
# Begin Source File

SOURCE=.\includes\cloneengine.h
# End Source File
# Begin Source File

SOURCE=.\includes\controlmenustate.h
# End Source File
# Begin Source File

SOURCE=D:\xenon\xenon\includes\creditsstate.h
# End Source File
# Begin Source File

SOURCE=.\includes\demorecorder.h
# End Source File
# Begin Source File

SOURCE=.\includes\drone.h
# End Source File
# Begin Source File

SOURCE=.\includes\dronegenerator.h
# End Source File
# Begin Source File

SOURCE=.\includes\dusteffect.h
# End Source File
# Begin Source File

SOURCE=.\includes\engine.h
# End Source File
# Begin Source File

SOURCE=.\includes\explosion.h
# End Source File
# Begin Source File

SOURCE=.\includes\game.h
# End Source File
# Begin Source File

SOURCE=.\includes\gamestate.h
# End Source File
# Begin Source File

SOURCE=.\includes\homer.h
# End Source File
# Begin Source File

SOURCE=.\includes\homerprojectile.h
# End Source File
# Begin Source File

SOURCE=.\includes\homerprojectileweapon.h
# End Source File
# Begin Source File

SOURCE=.\includes\homingmissile.h
# End Source File
# Begin Source File

SOURCE=.\includes\homingmissileweapon.h
# End Source File
# Begin Source File

SOURCE=.\includes\introstate.h
# End Source File
# Begin Source File

SOURCE=.\includes\label.h
# End Source File
# Begin Source File

SOURCE=.\includes\laser.h
# End Source File
# Begin Source File

SOURCE=.\includes\laserweapon.h
# End Source File
# Begin Source File

SOURCE=.\includes\level.h
# End Source File
# Begin Source File

SOURCE=.\includes\loner.h
# End Source File
# Begin Source File

SOURCE=.\includes\mainmenustate.h
# End Source File
# Begin Source File

SOURCE=.\includes\messageboxstate.h
# End Source File
# Begin Source File

SOURCE=.\includes\missile.h
# End Source File
# Begin Source File

SOURCE=.\includes\missileweapon.h
# End Source File
# Begin Source File

SOURCE=.\includes\options.h
# End Source File
# Begin Source File

SOURCE=.\includes\optionsmenustate.h
# End Source File
# Begin Source File

SOURCE=.\includes\organicgun.h
# End Source File
# Begin Source File

SOURCE=.\includes\particleeffect.h
# End Source File
# Begin Source File

SOURCE=.\includes\pickup.h
# End Source File
# Begin Source File

SOURCE=.\includes\player.h
# End Source File
# Begin Source File

SOURCE=.\includes\playgamestate.h
# End Source File
# Begin Source File

SOURCE=.\includes\pod.h
# End Source File
# Begin Source File

SOURCE=.\includes\retroengine.h
# End Source File
# Begin Source File

SOURCE=.\includes\rusher.h
# End Source File
# Begin Source File

SOURCE=.\includes\rushergenerator.h
# End Source File
# Begin Source File

SOURCE=.\includes\scene.h
# End Source File
# Begin Source File

SOURCE=.\includes\scoreentrystate.h
# End Source File
# Begin Source File

SOURCE=.\includes\ship.h
# End Source File
# Begin Source File

SOURCE=.\includes\shipengine.h
# End Source File
# Begin Source File

SOURCE=.\includes\smokeeffect.h
# End Source File
# Begin Source File

SOURCE=.\includes\spinner.h
# End Source File
# Begin Source File

SOURCE=.\includes\spinnerweapon.h
# End Source File
# Begin Source File

SOURCE=.\includes\spore.h
# End Source File
# Begin Source File

SOURCE=.\includes\sporegenerator.h
# End Source File
# Begin Source File

SOURCE=.\includes\upgrade.h
# End Source File
# Begin Source File

SOURCE=.\includes\videomenustate.h
# End Source File
# Begin Source File

SOURCE=.\includes\viewscoresstate.h
# End Source File
# Begin Source File

SOURCE=.\includes\wallhugger.h
# End Source File
# Begin Source File

SOURCE=.\includes\weapon.h
# End Source File
# Begin Source File

SOURCE=.\includes\wingtip.h
# End Source File
# Begin Source File

SOURCE=.\includes\xenon.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
