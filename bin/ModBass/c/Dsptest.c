/* BASS simple DSP test, copyright (c) 2000 Ian Luck.
=====================================================
Imports: bass.lib, kernel32.lib, user32.lib, comdlg32.lib
*/

#include <windows.h>
#include <stdio.h>
#include <math.h>
#include "bass.h"
#include "dsptest.h"

static HWND win=NULL;
static HINSTANCE inst;

static DWORD chan;	// the channel... HMUSIC (mod) or HSTREAM (wav/mp3)

static OPENFILENAME ofn;
static char path[MAX_PATH];

/* display error messages */
static void Error(char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d)",es,BASS_ErrorGetCode());
	MessageBox(win,mes,"Error",0);
}


#define clip(a) (short)((a<=-32768)?-32768:((a>=32767)?32767:a))

/* "rotate" */
static HDSP rotdsp=0;	// DSP handle
static float rotpos;	// cur.pos
void CALLBACK Rotate(HSYNC handle, DWORD channel, void *buffer, DWORD length, DWORD user)
{
	short *d=buffer;
	for (;length;length-=4,d+=2) {
		d[0]=(short)((float)d[0]*fabs(sin(rotpos)));
		d[1]=(short)((float)d[1]*fabs(cos(rotpos)));
		rotpos=fmod(rotpos+0.00003f,3.1415927);
	}
}

/* "echo" */
static HDSP echdsp=0;	// DSP handle
#define ECHBUFLEN 1200	// buffer length
static short echbuf[ECHBUFLEN][2];	// buffer
static int echpos;	// cur.pos
void CALLBACK Echo(HSYNC handle, DWORD channel, void *buffer, DWORD length, DWORD user)
{
	short *d=buffer;
	for (;length;length-=4,d+=2) {
		int l=d[0]+(echbuf[echpos][1]/2);
		int r=d[1]+(echbuf[echpos][0]/2);
#if 1 // 0=echo, 1=basic "bathroom" reverb
		echbuf[echpos][0]=d[0]=clip(l);
		echbuf[echpos][1]=d[1]=clip(r);
#else
		echbuf[echpos][0]=d[0];
		echbuf[echpos][1]=d[1];
		d[0]=clip(l);
		d[1]=clip(r);
#endif
		echpos++;
		if (echpos==ECHBUFLEN) echpos=0;
	}
}

/* "flanger" */
static HDSP fladsp=0;	// DSP handle
#define FLABUFLEN 350	// buffer length
static short flabuf[FLABUFLEN][2];	// buffer
static int flapos;	// cur.pos
static float flas,flasmin,flasinc;	// sweep pos/min/max/inc
void CALLBACK Flange(HSYNC handle, DWORD channel, void *buffer, DWORD length, DWORD user)
{
	short *d=buffer;

	for (;length;length-=4,d+=2) {
        int p1=(flapos+(int)flas)%FLABUFLEN;
        int p2=(p1+1)%FLABUFLEN;
		float f=fmod(flas,1.0);
		int s;

		s=d[0]+(int)(((1.0-f)*(float)flabuf[p1][0])+(f*(float)flabuf[p2][0]));
        flabuf[flapos][0]=d[0];
		d[0]=clip(s);

		s=d[1]+(int)(((1.0-f)*(float)flabuf[p1][1])+(f*(float)flabuf[p2][1]));
        flabuf[flapos][1]=d[1];
		d[1]=clip(s);
            
        flapos++;
		if (flapos==FLABUFLEN) flapos=0;
        flas+=flasinc;
        if (flas<0.0 || flas>FLABUFLEN)
            flasinc=-flasinc;
	}
}


#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)w,(LPARAM)l)

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	switch (m) {
		case WM_COMMAND:
			switch (LOWORD(w)) {
				case IDCANCEL:
					DestroyWindow(h);
					return 1;
				case ID_OPEN:
					{
						char file[MAX_PATH]="";
						ofn.lpstrFilter="playable files\0*.mo3;*.xm;*.mod;*.s3m;*.it;*.mtm;*.mp3;*.wav\0All files\0*.*\0\0";
						ofn.lpstrFile=file;
						if (GetOpenFileName(&ofn)) {
							memcpy(path,file,ofn.nFileOffset);
							path[ofn.nFileOffset-1]=0;
							// free both MOD and stream, it must be one of them! :)
							BASS_MusicFree(chan);
							BASS_StreamFree(chan);
							if (!(chan=BASS_StreamCreateFile(FALSE,file,0,0,0))
								&& !(chan=BASS_MusicLoad(FALSE,file,0,0,BASS_MUSIC_LOOP|BASS_MUSIC_RAMP))) {
								// not a WAV/MP3 or MOD
								MESS(ID_OPEN,WM_SETTEXT,0,"click here to open a file...");
								Error("Can't play the file");
								break;
							}
							if (BASS_ChannelGetFlags(chan)&(BASS_SAMPLE_MONO|BASS_SAMPLE_8BITS)) {
								/* not 16-bit stereo */
								MESS(ID_OPEN,WM_SETTEXT,0,"click here to open a file...");
								BASS_MusicFree(chan);
								BASS_StreamFree(chan);
								Error("16-bit stereo sources only");
								break;
							}
							MESS(ID_OPEN,WM_SETTEXT,0,file);
							// setup DSPs on new channel
							SendMessage(win,WM_COMMAND,ID_ROTA,0);
							SendMessage(win,WM_COMMAND,ID_ECHO,0);
							SendMessage(win,WM_COMMAND,ID_FLAN,0);
							// play both MOD and stream, it must be one of them! :)
							BASS_MusicPlay(chan);
							BASS_StreamPlay(chan,0,BASS_SAMPLE_LOOP);
						}
					}
					return 1;
				case ID_ROTA:
					if (MESS(ID_ROTA,BM_GETCHECK,0,0)) {
						rotpos=0.7853981f;
						rotdsp=BASS_ChannelSetDSP(chan,&Rotate,0);
					} else
						BASS_ChannelRemoveDSP(chan,rotdsp);
					break;
				case ID_ECHO:
					if (MESS(ID_ECHO,BM_GETCHECK,0,0)) {
						memset(echbuf,0,sizeof(echbuf));
						echpos=0;
						echdsp=BASS_ChannelSetDSP(chan,&Echo,0);
					} else
						BASS_ChannelRemoveDSP(chan,echdsp);
					break;
				case ID_FLAN:
					if (MESS(ID_FLAN,BM_GETCHECK,0,0)) {
						memset(flabuf,0,sizeof(flabuf));
						flapos=0;
					    flas=FLABUFLEN/2;
					    flasinc=0.002f;
						fladsp=BASS_ChannelSetDSP(chan,&Flange,0);
					} else
						BASS_ChannelRemoveDSP(chan,fladsp);
					break;
			}
			break;

		case WM_INITDIALOG:
			win=h;
			GetCurrentDirectory(MAX_PATH,path);
			memset(&ofn,0,sizeof(ofn));
			ofn.lStructSize=sizeof(ofn);
			ofn.hwndOwner=h;
			ofn.hInstance=inst;
			ofn.nMaxFile=MAX_PATH;
			ofn.lpstrInitialDir=path;
			ofn.Flags=OFN_HIDEREADONLY|OFN_EXPLORER;
			// setup output - default device, 44100hz, stereo, 16 bits, no syncs (not used)
			if (!BASS_Init(-1,44100,BASS_DEVICE_NOSYNC,win)) {
				Error("Can't initialize device");
				DestroyWindow(win);
			} else
				BASS_Start();
			return 1;
	}
	return 0;
}

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow)
{
	inst=hInstance;

// Check that BASS 0.8 was loaded
	if (BASS_GetVersion()!=MAKELONG(0,8)) {
		Error("BASS version 0.8 was not loaded");
		return 0;
	}

	DialogBox(inst,1000,0,&dialogproc);

	BASS_Free();

	return 0;
}
