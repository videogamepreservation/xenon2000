/* BASS 3D Test, copyright (c) 1999-2000 Ian Luck.
==================================================
Other source: 3dtest.rc
Imports: bass.lib, kernel32.lib, user32.lib, comdlg32.lib, gdi32.lib
*/

#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "bass.h"
#include "3dtest.h"

static HWND win=NULL;
static HINSTANCE inst;

/* channel (sample/music) info structure */
typedef struct {
	HSAMPLE sample;			// sample handle (NULL if it's a MOD music)
	DWORD channel;			// the channel
	BASS_3DVECTOR pos,vel;	// position,velocity
	int dir;				// direction of the channel
} Channel;

static Channel *chans=NULL;		// the channels
static int chanc=0,chan=-1;		// number of channels, current channel
static HBRUSH brush1,brush2;	// brushes

#define TIMERPER	50			// timer period (ms)
#define MAXDIST		500.0		// maximum distance of the channels (m)
#define SPEED		5.0			// speed of the channels' movement (m/s)

/* Display error dialogs */
static void Error(char *es)
{
	char mes[200];
	sprintf(mes,"%s\n(error code: %d)",es,BASS_ErrorGetCode());
	MessageBox(win,mes,"Error",0);
}

/* Messaging macros */
#define ITEM(id) GetDlgItem(win,id)
#define MESS(id,m,w,l) SendDlgItemMessage(win,id,m,(WPARAM)w,(LPARAM)l)
#define LM(m,w,l) MESS(ID_LIST,m,w,l)
#define EM(m,w,l) MESS(ID_EAX,m,w,l)

void CALLBACK Update(HWND win, UINT m, UINT i, DWORD t)
{
	HDC dc;
    RECT r;
	int c,x,y,cx,cy;
	int save;
	HPEN pen;

	win=ITEM(ID_DISPLAY);
	dc=GetDC(win);
	save=SaveDC(dc);
	GetClientRect(win,&r);
	cx=r.right/2;
	cy=r.bottom/2;

	/* Draw center circle */
	SelectObject(dc,GetStockObject(GRAY_BRUSH));
	Ellipse(dc,cx-4,cy-4,cx+4,cy+4);

	pen=CreatePen(PS_SOLID,2,GetSysColor(COLOR_BTNFACE));
	SelectObject(dc,pen);

	for (c=0;c<chanc;c++) {
		/* If the channel's playing then update it's position */
		if (BASS_ChannelIsActive(chans[c].channel)) {
			/* Check if channel has reached the max distance */
			if (chans[c].pos.z>=MAXDIST || chans[c].pos.z<=-MAXDIST)
				chans[c].vel.z=-chans[c].vel.z;
			if (chans[c].pos.x>=MAXDIST || chans[c].pos.x<=-MAXDIST)
				chans[c].vel.x=-chans[c].vel.x;
			/* Update channel position */
			chans[c].pos.z+=chans[c].vel.z*(float)TIMERPER/1000.0;
			chans[c].pos.x+=chans[c].vel.x*(float)TIMERPER/1000.0;
			BASS_ChannelSet3DPosition(chans[c].channel,&chans[c].pos,NULL,&chans[c].vel);
		}
		/* Draw the channel position indicator */
		x=cx+(int)((float)cx*chans[c].pos.x/(float)(MAXDIST+45));
		y=cy-(int)((float)cy*chans[c].pos.z/(float)(MAXDIST+45));
		if (chan==c)
			SelectObject(dc,brush1);
		else
			SelectObject(dc,brush2);
		Ellipse(dc,x-6,y-6,x+6,y+6);
	}
	/* Apply the 3D changes */
	BASS_Apply3D();

	RestoreDC(dc,save);
	DeleteObject(pen);
	ReleaseDC(win,dc);
}

/* Update the button states */
static void UpdateButtons()
{
	int a;
	EnableWindow(ITEM(ID_REMOVE),chan==-1?FALSE:TRUE);
	EnableWindow(ITEM(ID_PLAY),chan==-1?FALSE:TRUE);
	EnableWindow(ITEM(ID_STOP),chan==-1?FALSE:TRUE);
	for (a=0;a<5;a++)
		EnableWindow(ITEM(ID_LEFT+a),chan==-1?FALSE:TRUE);
	if (chan!=-1) {
		MESS(ID_LEFT,BM_SETCHECK,chans[chan].dir==ID_LEFT?BST_CHECKED:BST_UNCHECKED,0);
		MESS(ID_RIGHT,BM_SETCHECK,chans[chan].dir==ID_RIGHT?BST_CHECKED:BST_UNCHECKED,0);
		MESS(ID_FRONT,BM_SETCHECK,chans[chan].dir==ID_FRONT?BST_CHECKED:BST_UNCHECKED,0);
		MESS(ID_BEHIND,BM_SETCHECK,chans[chan].dir==ID_BEHIND?BST_CHECKED:BST_UNCHECKED,0);
		MESS(ID_NONE,BM_SETCHECK,!chans[chan].dir?BST_CHECKED:BST_UNCHECKED,0);
	}
}

BOOL CALLBACK dialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	static OPENFILENAME ofn;
	static char path[MAX_PATH];

	switch (m) {
		case WM_COMMAND:
			switch (LOWORD(w)) {
				case ID_EAX:
					/* Change the EAX environment */
					if (HIWORD(w)==CBN_SELCHANGE) {
						int s=EM(CB_GETCURSEL,0,0);
						switch (s) {
							case 0:
								BASS_SetEAXParameters(-1,0.0,-1.0,-1.0);
								break;
							case 1:
								BASS_SetEAXParameters(EAX_PRESET_GENERIC);
								break;
							case 2:
								BASS_SetEAXParameters(EAX_PRESET_PADDEDCELL);
								break;
							case 3:
								BASS_SetEAXParameters(EAX_PRESET_ROOM);
								break;
							case 4:
								BASS_SetEAXParameters(EAX_PRESET_BATHROOM);
								break;
							case 5:
								BASS_SetEAXParameters(EAX_PRESET_LIVINGROOM);
								break;
							case 6:
								BASS_SetEAXParameters(EAX_PRESET_STONEROOM);
								break;
							case 7:
								BASS_SetEAXParameters(EAX_PRESET_AUDITORIUM);
								break;
							case 8:
								BASS_SetEAXParameters(EAX_PRESET_CONCERTHALL);
								break;
							case 9:
								BASS_SetEAXParameters(EAX_PRESET_CAVE);
								break;
							case 10:
								BASS_SetEAXParameters(EAX_PRESET_ARENA);
								break;
							case 11:
								BASS_SetEAXParameters(EAX_PRESET_HANGAR);
								break;
							case 12:
								BASS_SetEAXParameters(EAX_PRESET_CARPETEDHALLWAY);
								break;
							case 13:
								BASS_SetEAXParameters(EAX_PRESET_HALLWAY);
								break;
							case 14:
								BASS_SetEAXParameters(EAX_PRESET_STONECORRIDOR);
								break;
							case 15:
								BASS_SetEAXParameters(EAX_PRESET_ALLEY);
								break;
							case 16:
								BASS_SetEAXParameters(EAX_PRESET_FOREST);
								break;
							case 17:
								BASS_SetEAXParameters(EAX_PRESET_CITY);
								break;
							case 18:
								BASS_SetEAXParameters(EAX_PRESET_MOUNTAINS);
								break;
							case 19:
								BASS_SetEAXParameters(EAX_PRESET_QUARRY);
								break;
							case 20:
								BASS_SetEAXParameters(EAX_PRESET_PLAIN);
								break;
							case 21:
								BASS_SetEAXParameters(EAX_PRESET_PARKINGLOT);
								break;
							case 22:
								BASS_SetEAXParameters(EAX_PRESET_SEWERPIPE);
								break;
							case 23:
								BASS_SetEAXParameters(EAX_PRESET_UNDERWATER);
								break;
							case 24:
								BASS_SetEAXParameters(EAX_PRESET_DRUGGED);
								break;
							case 25:
								BASS_SetEAXParameters(EAX_PRESET_DIZZY);
								break;
							case 26:
								BASS_SetEAXParameters(EAX_PRESET_PSYCHOTIC);
								break;
						}
					}
					return 1;
				case ID_A3DON:
					/* If A3D hi-freq absorbtion is switched on, set the absorbtion value
						... else turn it off */
					if (MESS(ID_A3DON,BM_GETCHECK,0,0))
						BASS_SetA3DHFAbsorbtion(pow(2.0,(float)(MESS(ID_A3DHF,SBM_GETPOS,0,0)-10)/2.0));
					else
						BASS_SetA3DHFAbsorbtion(0.0);
					return 1;
				case ID_LIST:
					/* Change the selected channel */
					if (HIWORD(w)!=LBN_SELCHANGE) break;
					chan=LM(LB_GETCURSEL,0,0);
					if (chan==LB_ERR) chan=-1;
					UpdateButtons();
					return 1;
				case ID_LEFT:
					if (HIWORD(w)!=BN_CLICKED) break;
					chans[chan].dir=ID_LEFT;
					/* Make the channel move past the left of you */
					/* Set speed in m/s */
					chans[chan].vel.z=SPEED*1000.0/(float)TIMERPER;
					chans[chan].vel.x=0.0;
					/* Set positon to the left */
					chans[chan].pos.x=-40.0;
					/* Reset display */
					InvalidateRect(GetDlgItem(h,ID_DISPLAY),NULL,TRUE);
					return 1;
				case ID_RIGHT:
					if (HIWORD(w)!=BN_CLICKED) break;
					chans[chan].dir=ID_RIGHT;
					/* Make the channel move past the right of you */
					chans[chan].vel.z=SPEED*1000.0/(float)TIMERPER;
					chans[chan].vel.x=0.0;
					/* Set positon to the right */
					chans[chan].pos.x=40.0;
					InvalidateRect(GetDlgItem(h,ID_DISPLAY),NULL,TRUE);
					return 1;
				case ID_FRONT:
					if (HIWORD(w)!=BN_CLICKED) break;
					chans[chan].dir=ID_FRONT;
					/* Make the channel move past the front of you */
					chans[chan].vel.x=SPEED*1000.0/(float)TIMERPER;
					chans[chan].vel.z=0.0;
					/* Set positon to in front */
					chans[chan].pos.z=40.0;
					InvalidateRect(GetDlgItem(h,ID_DISPLAY),NULL,TRUE);
					return 1;
				case ID_BEHIND:
					if (HIWORD(w)!=BN_CLICKED) break;
					chans[chan].dir=ID_BEHIND;
					/* Make the channel move past the back of you */
					chans[chan].vel.x=SPEED*1000.0/(float)TIMERPER;
					chans[chan].vel.z=0.0;
					/* Set positon to behind */
					chans[chan].pos.z=-40.0;
					InvalidateRect(GetDlgItem(h,ID_DISPLAY),NULL,TRUE);
					return 1;
				case ID_NONE:
					if (HIWORD(w)!=BN_CLICKED) break;
					chans[chan].dir=0;
					/* Make the channel stop moving */
					chans[chan].vel.x=chans[chan].vel.z=0.0;
					return 1;
				case ID_ADD:
					{
						char file[MAX_PATH]="";
						DWORD newchan;
						ofn.lpstrFile=file;
						if (GetOpenFileName(&ofn)) {
							memcpy(path,file,ofn.nFileOffset);
							path[ofn.nFileOffset-1]=0;
							/* Load a music from "file" with 3D enabled, and make it loop & use ramping */
							if (newchan=BASS_MusicLoad(FALSE,file,0,0,BASS_MUSIC_RAMP|BASS_MUSIC_LOOP|BASS_MUSIC_3D)) {
								Channel *c;
								chanc++;
								chans=(Channel*)realloc((void*)chans,chanc*sizeof(Channel));
								c=chans+chanc-1;
								memset(c,0,sizeof(Channel));
								c->channel=newchan;
								LM(LB_ADDSTRING,0,file);
								/* Set the min/max distance to 15/1000 meters */
								BASS_ChannelSet3DAttributes(newchan,-1,35.0,1000.0,-1,-1,-1);
							} else
							/* Load a sample from "file" with 3D enabled, and make it loop */
							if (newchan=BASS_SampleLoad(FALSE,file,0,0,1,BASS_SAMPLE_LOOP|BASS_SAMPLE_3D|BASS_SAMPLE_VAM)) {
								Channel *c;
								BASS_SAMPLE sam;
								chanc++;
								chans=(Channel*)realloc((void*)chans,chanc*sizeof(Channel));
								c=chans+chanc-1;
								memset(c,0,sizeof(Channel));
								c->sample=newchan;
								LM(LB_ADDSTRING,0,file);
								/* Set the min/max distance to 15/1000 meters */
								BASS_SampleGetInfo(newchan,&sam);
								sam.mindist=35.0;
								sam.maxdist=1000.0;
								BASS_SampleSetInfo(newchan,&sam);
							} else
								Error("Can't load file");
						}
					}
					return 1;
				case ID_REMOVE:
					{
						Channel *c=chans+chan;
						if (c->sample)
							BASS_SampleFree(c->sample);
						else
							BASS_MusicFree(c->channel);
						memcpy(c,c+1,(chanc-chan-1)*sizeof(Channel));
						chanc--;
						LM(LB_DELETESTRING,chan,0);
						chan=-1;
						UpdateButtons();
						InvalidateRect(GetDlgItem(h,ID_DISPLAY),NULL,TRUE);
					}
					return 1;
				case ID_PLAY:
					{
						if (chans[chan].sample) {
							if (!chans[chan].channel)
								chans[chan].channel=BASS_SamplePlay3D(chans[chan].sample,&chans[chan].pos,NULL,&chans[chan].vel);
						} else
							BASS_MusicPlay(chans[chan].channel);
					}
					return 1;
				case ID_STOP:
					BASS_ChannelStop(chans[chan].channel);
					if (chans[chan].sample) chans[chan].channel=0;
					return 1;
				case IDCANCEL:
					DestroyWindow(h);
					return 1;
			}
			break;

		case WM_HSCROLL:
			{
				int a=SendMessage(l,SBM_GETPOS,0,0);
				switch (LOWORD(w)) {
					case SB_THUMBTRACK:
					case SB_THUMBPOSITION:
						a=HIWORD(w);
						break;
					case SB_LINELEFT:
						a=max(a-1,0);
						break;
					case SB_LINERIGHT:
						a=min(a+1,20);
						break;
					case SB_PAGELEFT:
						a=max(a-5,0);
						break;
					case SB_PAGERIGHT:
						a=min(a+5,20);
						break;
				}
				PostMessage(l,SBM_SETPOS,a,1);
				switch (GetDlgCtrlID(l)) {
					case ID_A3DHF:
						/* If A3D hi-freq absorbtion is on, change the setting */
						if (MESS(ID_A3DON,BM_GETCHECK,0,0))
							BASS_SetA3DHFAbsorbtion(pow(2.0,(float)(a-10)/2.0));
						break;
					case ID_ROLLOFF:
						/* change the rolloff factor */
						BASS_Set3DFactors(-1.0,pow(2.0,(float)(a-10)/4.0),-1.0);
						break;
					case ID_DOPPLER:
						/* change the doppler factor */
						BASS_Set3DFactors(-1.0,-1.0,pow(2.0,(float)(a-10)/4.0));
						break;
				}
			}
			return 1;

		case WM_INITDIALOG:
			win=h;
			brush1=CreateSolidBrush(0xff);
			brush2=CreateSolidBrush(0);

			EM(CB_ADDSTRING,0,"Off");
			EM(CB_ADDSTRING,0,"Generic");
			EM(CB_ADDSTRING,0,"Padded Cell");
			EM(CB_ADDSTRING,0,"Room");
			EM(CB_ADDSTRING,0,"Bathroom");
			EM(CB_ADDSTRING,0,"Living Room");
			EM(CB_ADDSTRING,0,"Stone Room");
			EM(CB_ADDSTRING,0,"Auditorium");
			EM(CB_ADDSTRING,0,"Concert Hall");
			EM(CB_ADDSTRING,0,"Cave");
			EM(CB_ADDSTRING,0,"Arena");
			EM(CB_ADDSTRING,0,"Hangar");
			EM(CB_ADDSTRING,0,"Carpeted Hallway");
			EM(CB_ADDSTRING,0,"Hallway");
			EM(CB_ADDSTRING,0,"Stone Corridor");
			EM(CB_ADDSTRING,0,"Alley");
			EM(CB_ADDSTRING,0,"Forest");
			EM(CB_ADDSTRING,0,"City");
			EM(CB_ADDSTRING,0,"Mountains");
			EM(CB_ADDSTRING,0,"Quarry");
			EM(CB_ADDSTRING,0,"Plain");
			EM(CB_ADDSTRING,0,"Parking Lot");
			EM(CB_ADDSTRING,0,"Sewer Pipe");
			EM(CB_ADDSTRING,0,"Under Water");
			EM(CB_ADDSTRING,0,"Drugged");
			EM(CB_ADDSTRING,0,"Dizzy");
			EM(CB_ADDSTRING,0,"Psychotic");
			EM(CB_SETCURSEL,0,0);

			MESS(ID_A3DHF,SBM_SETRANGE,0,20);
			MESS(ID_A3DHF,SBM_SETPOS,10,0);
			MESS(ID_ROLLOFF,SBM_SETRANGE,0,20);
			MESS(ID_ROLLOFF,SBM_SETPOS,10,0);
			MESS(ID_DOPPLER,SBM_SETRANGE,0,20);
			MESS(ID_DOPPLER,SBM_SETPOS,10,0);

			SetTimer(h,1,TIMERPER,&Update);
			GetCurrentDirectory(MAX_PATH,path);
			memset(&ofn,0,sizeof(ofn));
			ofn.lStructSize=sizeof(ofn);
			ofn.hwndOwner=h;
			ofn.hInstance=inst;
			ofn.nMaxFile=MAX_PATH;
			ofn.lpstrInitialDir=path;
			ofn.Flags=OFN_HIDEREADONLY|OFN_EXPLORER;
			ofn.lpstrFilter="wav/mo3/xm/mod/s3m/it/mtm\0*.wav;*.mo3;*.xm;*.mod;*.s3m;*.it;*.mtm\0"
				"All files\0*.*\0\0";
			return 1;

		case WM_DESTROY:
			KillTimer(h,1);
			DeleteObject(brush1);
			DeleteObject(brush2);
			if (chans) free(chans);
			PostQuitMessage(0);
			return 1;
	}
	return 0;
}


// Simple device selector dialog stuff begins here
int device;		// selected device
BOOL lowqual;	// low quality option

BOOL CALLBACK devicedialogproc(HWND h,UINT m,WPARAM w,LPARAM l)
{
	switch (m) {
		case WM_COMMAND:
			switch (LOWORD(w)) {
				case ID_DEVLIST:
					if (HIWORD(w)==LBN_SELCHANGE)
						device=SendMessage(l,LB_GETCURSEL,0,0);
					else if (HIWORD(w)==LBN_DBLCLK)
						EndDialog(h,0);
					break;
				case ID_LOWQUAL:
					lowqual=SendDlgItemMessage(h,ID_LOWQUAL,BM_GETCHECK,0,0);
					break;
				case IDOK:
					EndDialog(h,0);
					return 1;
			}
			break;

		case WM_INITDIALOG:
			{
				char text[100],*d;
				int c;
				for (c=0;BASS_GetDeviceDescription(c,&d);c++) {
					strcpy(text,d);
					/* Check if the device supports A3D or EAX */
					if (!BASS_Init(c,44100,BASS_DEVICE_A3D,h)) {
						if (!BASS_Init(c,44100,BASS_DEVICE_3D,h))
							continue; // no 3D support
					} else
						strcat(text," [A3D]"); // it has A3D
					if (BASS_GetEAXParameters(NULL,NULL,NULL,NULL))
						strcat(text," [EAX]"); // it has EAX
					BASS_Free();
					SendDlgItemMessage(h,ID_DEVLIST,LB_ADDSTRING,0,text);
				}
				SendDlgItemMessage(h,ID_DEVLIST,LB_SETCURSEL,0,0);
			}
			device=lowqual=0;
			return 1;
	}
	return 0;
}
// Device selector stuff ends here

int PASCAL WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,LPSTR lpCmdLine, int nCmdShow)
{
	MSG msg;
	inst=hInstance;

	/* Check that BASS 0.8 was loaded */
	if (BASS_GetVersion()!=MAKELONG(0,8)) {
		MessageBox(0,"BASS version 0.8 was not loaded","Incorrect BASS.DLL",0);
		return 0;
	}

	/* Create the main window */
	if (!CreateDialog(hInstance,MAKEINTRESOURCE(1000),NULL,&dialogproc)) {
		Error("Can't create window");
		return 0;
	}

	/* Let the user choose an output device */
	DialogBox(inst,2000,win,&devicedialogproc);

	/* Initialize the output device with A3D (syncs not used) */
	if (!BASS_Init(device,lowqual?22050:44100,BASS_DEVICE_NOSYNC|BASS_DEVICE_A3D,win)) {
		/* no A3D, so try without... */
		if (!BASS_Init(device,lowqual?22050:44100,BASS_DEVICE_NOSYNC|BASS_DEVICE_3D,win)) {
			Error("Can't initialize output device");
			EndDialog(win,0);
			return 0;
		}
	} else {
		/* enable A3D HF absorbtion option */
		EnableWindow(GetDlgItem(win,ID_A3DON),TRUE);
		EnableWindow(GetDlgItem(win,ID_A3DHF),TRUE);
		BASS_SetA3DHFAbsorbtion(0.0);
	}

	/* Use meters as distance unit, real world rolloff, real doppler effect */
	BASS_Set3DFactors(1.0,1.0,1.0);
	/* Turn EAX off (volume=0.0), if error then EAX is not supported */
	if (BASS_SetEAXParameters(-1,0.0,-1.0,-1.0))
		EnableWindow(GetDlgItem(win,ID_EAX),TRUE);
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
	
	BASS_Stop();
	BASS_Free();

	return 0;
}
