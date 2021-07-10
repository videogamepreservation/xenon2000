/* BASS Simple Test, copyright (c) 1999-2000 Ian Luck.
======================================================
Other source: basstest.rc
Imports: bass.lib, kernel32.lib, user32.lib, comdlg32.lib
*/

#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include "bass.h"
#include "basstest.h"

static HWND win=NULL;
static HINSTANCE inst;

static HMUSIC *mods=NULL;
static int modc=0;
static HSAMPLE *sams=NULL;
static int samc=0;
static HSTREAM str;
static BOOL cdplaying=FALSE;

/* Display error dialogs */
static void Error(char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d)",es,BASS_ErrorGetCode());
	MessageBox(win,mes,"Error",0);
}

/* Messaging macros */
#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)w,(LPARAM)l)
#define MLM(m,w,l) MESS(ID_MODLIST,m,w,l)
#define SLM(m,w,l) MESS(ID_SAMLIST,m,w,l)
#define GETMOD() MLM(LB_GETCURSEL,0,0)
#define GETSAM() SLM(LB_GETCURSEL,0,0)

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	static OPENFILENAME ofn;
	static char path[MAX_PATH];

	switch (m) {
		case WM_TIMER:
			{
				char text[10];
				int p;
				/* update the CD status */
				MESS(ID_CDINDRIVE,BM_SETCHECK,BASS_CDInDrive(),0);
				p=BASS_ChannelGetPosition(CDCHANNEL);
				sprintf(text,"%d:%02d",p/60000,(p/1000)%60);
				MESS(ID_CDPOS,WM_SETTEXT,0,text);
				/* update the CPU usage % display */
				sprintf(text,"%.1f",BASS_GetCPU());
				MESS(ID_CPU,WM_SETTEXT,0,text);
			}
			break;

		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					return 1;
				case ID_MODADD:
					{
						char file[MAX_PATH]="";
						HMUSIC mod;
						ofn.lpstrFilter="MOD music files (mo3/xm/mod/s3m/it/mtm)\0*.mo3;*.xm;*.mod;*.s3m;*.it;*.mtm\0All files\0*.*\0\0";
						ofn.lpstrFile=file;
						if (GetOpenFileName(&ofn)) {
							memcpy(path,file,ofn.nFileOffset);
							path[ofn.nFileOffset-1]=0;
							/* Load a music from "file" and make it use ramping */
							if (mod=BASS_MusicLoad(FALSE,file,0,0,BASS_MUSIC_RAMP)) {
								modc++;
								mods=(HMUSIC*)realloc((void*)mods,modc*sizeof(HMUSIC));
								mods[modc-1]=mod;
								MLM(LB_ADDSTRING,0,file);
							} else
								Error("Can't load music");
						}
					}
					return 1;
				case ID_MODREMOVE:
					{
						int s=GETMOD();
						if (s!=LB_ERR) {
							MLM(LB_DELETESTRING,s,0);
							/* Free the music from memory */
							BASS_MusicFree(mods[s]);
							memcpy(mods+s,mods+s+1,(modc-s-1)*sizeof(HMUSIC));
							modc--;
						}
					}
					return 1;
				case ID_MODPLAY:
					{
						int s=GETMOD();
						/* Play the music (continue from current position) */
						if (s!=LB_ERR)
							if (!BASS_MusicPlay(mods[s])) Error("Can't play music");
					}
					return 1;
				case ID_MODSTOP:
					{
						int s=GETMOD();
						/* Stop the music */
						if (s!=LB_ERR) BASS_ChannelStop(mods[s]);
					}
					return 1;
				case ID_MODRESTART:
					{
						int s=GETMOD();
						/* Play the music from the start */
						if (s!=LB_ERR) BASS_MusicPlayEx(mods[s],0,-1,TRUE);
					}
					return 1;

				case ID_SAMADD:
					{
						char file[MAX_PATH]="";
						HSAMPLE sam;
						ofn.lpstrFilter="WAVE sample files (wav)\0*.wav\0All files\0*.*\0\0";
						ofn.lpstrFile=file;
						if (GetOpenFileName(&ofn)) {
							memcpy(path,file,ofn.nFileOffset);
							path[ofn.nFileOffset-1]=0;
							/* Load a sample from "file" and give it a max of 3 simultaneous
							playings using playback position as override decider */
							if (sam=BASS_SampleLoad(FALSE,file,0,0,3,BASS_SAMPLE_OVER_POS)) {
								samc++;
								sams=(HSAMPLE*)realloc((void*)sams,samc*sizeof(HSAMPLE));
								sams[samc-1]=sam;
								SLM(LB_ADDSTRING,0,file);
							} else
								Error("Can't load sample");
						}
					}
					return 1;
				case ID_SAMREMOVE:
					{
						int s=GETSAM();
						if (s!=LB_ERR) {
							SLM(LB_DELETESTRING,s,0);
							/* Free the sample from memory */
							BASS_SampleFree(sams[s]);
							memcpy(sams+s,sams+s+1,(samc-s-1)*sizeof(HSAMPLE));
							samc--;
						}
					}
					return 1;
				case ID_SAMPLAY:
					{
						int s=GETSAM();
						/* Play the sample from the start, volume=50, random pan position,
						using the default frequency and looping settings */
						if (s!=LB_ERR) {
							if (!BASS_SamplePlayEx(sams[s],0,-1,50,(rand()%201)-100,-1))
								Error("Can't play sample");
						}
					}
					return 1;

				case ID_STRNEW:
					{
						char file[MAX_PATH]="";
						ofn.lpstrFilter="Streamable files (wav/mp3)\0*.wav;*.mp3\0All files\0*.*\0\0";
						ofn.lpstrFile=file;
						if (GetOpenFileName(&ofn)) {
							memcpy(path,file,ofn.nFileOffset);
							path[ofn.nFileOffset-1]=0;
							/* Free old stream (if any) and create new one */
							BASS_StreamFree(str);
							MESS(ID_STRFILE,WM_SETTEXT,0,"");
							if (!(str=BASS_StreamCreateFile(FALSE,file,0,0,0)))
								Error("Can't create stream");
							else
								MESS(ID_STRFILE,WM_SETTEXT,0,file);
						}
					}
					return 1;
				case ID_STRPLAY:
					/* Play stream, not flushed */
					if (!BASS_StreamPlay(str,FALSE,0))
						Error("Can't play stream");
					return 1;
				case ID_STRSTOP:
					/* Stop the stream */
					BASS_ChannelStop(str);
					return 1;

				case ID_CDPLAY:
					/* Play CD track (looped) */
					{
						char track[4];
						MESS(ID_CDTRACK,WM_GETTEXT,4,track);
						if (!BASS_CDPlay(atoi(track),TRUE,FALSE))
							Error("Can't play CD");
						else
							cdplaying=TRUE;
					}
					return 1;
				case ID_CDSTOP:
					/* Pause CD */
					BASS_ChannelPause(CDCHANNEL);
					cdplaying=FALSE;
					return 1;
				case ID_CDRESUME:
					/* Resume CD */
					if (BASS_ChannelResume(CDCHANNEL))
						cdplaying=TRUE;
					return 1;

				case ID_STOP:
					/* Pause digital output and CD */
					BASS_Pause();
					BASS_ChannelPause(CDCHANNEL);
					return 1;
				case ID_RESUME:
					/* Resume digital output and CD */
					if (cdplaying) BASS_ChannelResume(CDCHANNEL);
					BASS_Start();
					return 1;
			}
			break;

		case WM_INITDIALOG:
			win=h;
			MESS(ID_CDTRACK,WM_SETTEXT,0,"1");
			SetTimer(h,1,250,NULL);
			GetCurrentDirectory(MAX_PATH,path);
			memset(&ofn,0,sizeof(ofn));
			ofn.lStructSize=sizeof(ofn);
			ofn.hwndOwner=h;
			ofn.hInstance=inst;
			ofn.nMaxFile=MAX_PATH;
			ofn.lpstrInitialDir=path;
			ofn.Flags=OFN_HIDEREADONLY|OFN_EXPLORER;
			return 1;

		case WM_DESTROY:
			KillTimer(h,1);
			PostQuitMessage(0);
			return 1;
	}
	return 0;
}

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg;
	inst=hInstance;

/* Check that BASS 0.8 was loaded */
	if (BASS_GetVersion()!=MAKELONG(0,8)) {
		MessageBox(0,"BASS version 0.8 was not loaded","Incorrect BASS.DLL",0);
		return 0;
	}

	if (!CreateDialog(hInstance,MAKEINTRESOURCE(1000),NULL,&dialogproc)) {
		Error("Can't create window");
		return 0;
	}

/* Initialize digital sound - default device, 44100hz, stereo, 16 bits, no syncs used */
	if (!BASS_Init(-1,44100,BASS_DEVICE_NOSYNC,win)) Error("Can't initialize digital sound system");
/* Initialize CD */
	if (!BASS_CDInit(NULL)) Error("Can't initialize CD system");

	BASS_Start();	/* Start digital output */

	while (1) {
		if (PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE)) {
			if (!GetMessage(&msg, NULL, 0, 0))
				break;
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		} else
			WaitMessage();
	}
	
	BASS_Stop();	/* Stop digital output */
/* Free the stream */
	BASS_StreamFree(str);
/* It's not actually necessary to free the musics and samples
because they are automatically freed by BASS_Free() */
/* Free musics */
	if (mods) {
		int a;
		for (a=0;a<modc;a++) BASS_MusicFree(mods[a]);
		free(mods);
	}
/* Free samples */
	if (sams) {
		int a;
		for (a=0;a<samc;a++) BASS_SampleFree(sams[a]);
		free(sams);
	}
	BASS_Free();	/* Close digital sound system */
	BASS_CDFree();	/* Close CD system */
	return 0;
}
