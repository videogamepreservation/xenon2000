/* BASS Console Test (LL/GPA version), copyright (c) 1999-2000 Ian Luck.
========================================================================
Demonstrates how you can use LoadLibrary and GetProcAddress to import
BASS, instead of using BASS.LIB. Also demonstrates including BASS.DLL
in the EXE as a resource, instead of seperate as a file. It's basically
the same as the CONTEST.C version, with LoadBASS and FreeBASS functions
added, to import and free BASS respectively.
Other source: loadnget.rc
Imports: kernel32.lib, user32.lib, winmm.lib
*/

#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>
#include <conio.h>

#define BASSDEF(f) (WINAPI *f)	// define the functions as pointers
#include "bass.h"

char tempfile[MAX_PATH];	// temporary BASS.DLL
HINSTANCE bass=0;			// bass handle

/* load BASS and the required functions */
void LoadBASS()
{
	BYTE *data;
	HANDLE hres,hfile;
	DWORD len,c;
	char temppath[MAX_PATH];
	/* get the BASS.DLL resource */
	if (!(hres=FindResource(GetModuleHandle(NULL),"BASS_DLL",RT_RCDATA))
		|| !(len=SizeofResource(NULL,hres))
		|| !(hres=LoadResource(NULL,hres))
		|| !(data=LockResource(hres))) {
		printf("Error: Can't get the BASS.DLL resource\n");
		ExitProcess(0);
	}
	/* get a temporary filename */
	GetTempPath(MAX_PATH,temppath);
	GetTempFileName(temppath,"bas",0,tempfile);
	/* write BASS.DLL to the temporary file */
	if (!(hfile=CreateFile(tempfile,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_TEMPORARY,NULL))) {
		printf("Error: Can't write BASS.DLL\n");
		ExitProcess(0);
	}
	WriteFile(hfile,data,len,&c,NULL);
	CloseHandle(hfile);

	/* load the temporary BASS.DLL library */
	if (!(bass=LoadLibrary(tempfile))) {
		printf("Error: Can't load BASS.DLL\n");
		ExitProcess(0);
	}
	/* "load" all the BASS functions that are to be used */
#ifdef __cplusplus
	#define LOADBASSFUNCTION(f) {\
		char *func=#f;\
		__asm {push func}\
		__asm {push bass}\
		__asm {mov eax,GetProcAddress}\
		__asm {call eax}\
		__asm {mov f,eax}\
	}
#else
	#define LOADBASSFUNCTION(f) (FARPROC)f=GetProcAddress(bass,#f)
#endif
	LOADBASSFUNCTION(BASS_ErrorGetCode);
	LOADBASSFUNCTION(BASS_Init);
	LOADBASSFUNCTION(BASS_Free);
	LOADBASSFUNCTION(BASS_GetCPU);
	LOADBASSFUNCTION(BASS_Start);
	LOADBASSFUNCTION(BASS_SetVolume);
	LOADBASSFUNCTION(BASS_MusicLoad);
	LOADBASSFUNCTION(BASS_MusicPlay);
	LOADBASSFUNCTION(BASS_StreamCreateFile);
	LOADBASSFUNCTION(BASS_StreamPlay);
	LOADBASSFUNCTION(BASS_ChannelIsActive);
	LOADBASSFUNCTION(BASS_ChannelGetFlags);
	LOADBASSFUNCTION(BASS_ChannelSetAttributes);
	LOADBASSFUNCTION(BASS_ChannelGetAttributes);
	LOADBASSFUNCTION(BASS_ChannelGetPosition);
	LOADBASSFUNCTION(BASS_ChannelGetLevel);
	LOADBASSFUNCTION(BASS_ChannelSetSync);
}

/* free the BASS library from memory and delete the temporary file */
void FreeBASS()
{
	if (!bass) return;
	FreeLibrary(bass);
	bass=0;
	DeleteFile(tempfile);
}

/* display error messages */
void Error(char *text) 
{
	printf("Error(%d): %s\n",BASS_ErrorGetCode(),text);
	BASS_Free();
	FreeBASS();
	ExitProcess(0);
}

static DWORD starttime;

/* looping synchronizer, resets the clock */
void CALLBACK LoopSync(HSYNC handle, DWORD channel, DWORD data)
{
	starttime=timeGetTime();	// reset the clock
}

void main(int argc, char **argv)
{
	HMUSIC mod;
	HSTREAM str;
	DWORD time,pos,level;
	int a,freq;
	BOOL mono=FALSE;

	printf("LoadLibrary/GetProcAddress example : MOD/MP3/WAV player\n"
		"-------------------------------------------------------\n");

	LoadBASS();

	if (argc<2 || argc>3) {
		printf("\tusage: loadnget <file>\n");
		return;
	}

	/* setup output - default device, 44100hz, stereo, 16 bits */
	if (!BASS_Init(-1,44100,0,GetForegroundWindow()))
		Error("Can't initialize device");
	/* try streaming the file */
	if (str=BASS_StreamCreateFile(FALSE,argv[1],0,0,0)) {
		/* check if the stream is mono (for the level indicator) */
		mono=BASS_ChannelGetFlags(str)&BASS_SAMPLE_MONO;
		/* set a synchronizer for when the stream reaches the end */
		BASS_ChannelSetSync(str,BASS_SYNC_END,0,&LoopSync,NULL);
	} else {
		/* load the MOD (with looping and normal ramping) */
		if (!(mod=BASS_MusicLoad(FALSE,argv[1],0,0,BASS_MUSIC_LOOP|BASS_MUSIC_RAMP)))
			/* not a MOD either */
			Error("Can't play the file");
		/* set a synchronizer for when the MOD reaches the end */
		BASS_ChannelSetSync(mod,BASS_SYNC_END,0,&LoopSync,NULL);
	}

	BASS_Start();
	if (str)
		BASS_StreamPlay(str,FALSE,BASS_SAMPLE_LOOP);
	else
		BASS_MusicPlay(mod);
	starttime=timeGetTime();
	printf("now playing... press any key to stop\n");

	/* NOTE: some compilers don't support _kbhit */
	while (!_kbhit() && BASS_ChannelIsActive(str?str:mod)) {
		/* display some stuff and wait a bit */
		time=timeGetTime()-starttime;
		level=BASS_ChannelGetLevel(str?str:mod);
		pos=BASS_ChannelGetPosition(str?str:mod);
		if (str)
			printf("pos %09d - time %d:%02d - L ",pos,time/60000,(time/1000)%60);
		else
			printf("pos %03d:%03d - time %d:%02d - L ",LOWORD(pos),HIWORD(pos),time/60000,(time/1000)%60);
		for (a=93;a;a=a*2/3) putchar(LOWORD(level)>=a?'*':'-');
		putchar(' ');
		if (mono)
			for (a=1;a<128;a+=a-(a>>1)) putchar(LOWORD(level)>=a?'*':'-');
		else
			for (a=1;a<128;a+=a-(a>>1)) putchar(HIWORD(level)>=a?'*':'-');
		printf(" R - cpu %.1f%%  \r",BASS_GetCPU());
		Sleep(50);
	}
	printf("                                                                   \r");

	/* get the frequency... and wind it down */
	BASS_ChannelGetAttributes(str?str:mod,&freq,NULL,NULL);
	level=freq/40;
	for (;freq>2000;freq-=level) {
		BASS_ChannelSetAttributes(str?str:mod,freq,-1,-101);
		Sleep(5);
	}

	/* fade-out to avoid a "click" */
	for (a=100;a>=0;a-=5) {
		BASS_SetVolume(a);
		Sleep(1);
	}

	BASS_Free();
	FreeBASS();
}
