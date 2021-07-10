/* BASS Simple Console Test, copyright (c) 1999-2000 Ian Luck.
==============================================================
Imports: bass.lib, kernel32.lib, user32.lib, winmm.lib
*/

#include <windows.h>
#include <mmsystem.h>
#include <stdio.h>
#include <conio.h>
#include "bass.h"

/* display error messages */
void Error(char *text) 
{
	printf("Error(%d): %s\n",BASS_ErrorGetCode(),text);
	BASS_Free();
	ExitProcess(0);
}

static DWORD starttime;

/* looping synchronizer, resets the clock */
void CALLBACK LoopSync(HSYNC handle, DWORD channel, DWORD data, DWORD user)
{
	starttime=timeGetTime();
}

void main(int argc, char **argv)
{
	HMUSIC mod;
	HSTREAM str;
	DWORD time,pos,level;
	int a,freq;
	BOOL mono=FALSE;

	printf("Simple console mode BASS example : MOD/MP3/WAV player\n"
			"-----------------------------------------------------\n");

	/* check that BASS 0.8 was loaded */
	if (BASS_GetVersion()!=MAKELONG(0,8)) {
		printf("BASS version 0.8 was not loaded\n");
		return;
	}

	if (argc!=2) {
		printf("\tusage: contest <file>\n");
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
		BASS_ChannelSetSync(str,BASS_SYNC_END,0,&LoopSync,0);
		printf("streaming file [%d bytes]\n",BASS_StreamGetLength(str));
	} else {
		/* load the MOD (with looping and normal ramping) */
		if (!(mod=BASS_MusicLoad(FALSE,argv[1],0,0,BASS_MUSIC_LOOP|BASS_MUSIC_RAMP)))
			/* not a MOD either */
			Error("Can't play the file");
		/* set a synchronizer for when the MOD reaches the end */
		BASS_ChannelSetSync(mod,BASS_SYNC_END,0,&LoopSync,0);
		printf("playing MOD music \"%s\" [%d orders]\n",BASS_MusicGetName(mod),BASS_MusicGetLength(mod));
	}

	BASS_Start();
	if (str)
		BASS_StreamPlay(str,FALSE,BASS_SAMPLE_LOOP);
	else
		BASS_MusicPlayEx(mod,0,-1,1);
	starttime=timeGetTime();

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
}
