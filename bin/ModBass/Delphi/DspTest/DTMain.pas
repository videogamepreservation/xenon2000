unit DTMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, BASS;

type
  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
  private
    { Private-Deklarationen }
    chan: DWORD;
    procedure Error(msg: string);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const
  ECHBUFLEN = 1200;        // buffer length
  FLABUFLEN = 350;         // buffer length

var
  d: ^DWORD;
  rotdsp: HDSP;            // DSP handle
  rotpos: FLOAT;           // cur.pos
  echdsp: HDSP;            // DSP handle
  echbuf: array[0..ECHBUFLEN-1, 0..1] of SmallInt;  // buffer
  echpos: Integer;         // cur.pos
  fladsp: HDSP;            // DSP handle
  flabuf: array[0..FLABUFLEN-1, 0..2] of SmallInt;  // buffer
  flapos: Integer;         // cur.pos
  flas, flasinc: FLOAT;  // sweep pos/min/max/inc

function fmod(a, b: FLOAT): FLOAT;
begin
  Result := a - (b * Trunc(a / b));
end;

function Clip(a: Integer): Integer;
begin
  if a <= -32768 then a := -32768
  else if a >= 32767 then a := 32767;
  Result := a;
end;

procedure Rotate(handle: HSYNC; channel: DWORD; buffer: Pointer; length, user: DWORD); stdcall;
var
  lc, rc: SmallInt;
begin
  d := buffer;
  while (length > 0) do
  begin
    lc := LOWORD(d^); rc := HIWORD(d^);
    lc := SmallInt(Trunc(sin(rotpos) * lc));
    rc := SmallInt(Trunc(cos(rotpos) * rc));
    d^ := MakeLong(lc, rc);
    Inc(d);
    rotpos := rotpos + fmod(0.00003, PI);
    length := length - 4;
  end;
end;

procedure Echo(handle: HSYNC; channel: DWORD; buffer: Pointer; length, user: DWORD); stdcall;
var
  lc, rc: SmallInt;
  l, r: Integer;
begin
  d := buffer;
  while (length > 0) do
  begin
    lc := LOWORD(d^); rc := HIWORD(d^);
    l := lc + (echbuf[echpos, 1] div 2);
    r := rc + (echbuf[echpos, 0] div 2);
    echbuf[echpos, 0] := lc;
    echbuf[echpos, 1] := rc;
    lc := Clip(l);
    rc := Clip(r);
    d^ := MakeLong(lc, rc);
    Inc(d);
    Inc(echpos);
    if (echpos = ECHBUFLEN) then echpos := 0;
    length := length - 4;
  end;
end;

procedure Flange(handle: HSYNC; channel: DWORD; buffer: Pointer; length, user: DWORD); stdcall;
var
  lc, rc: SmallInt;
  p1, p2, s: Integer;
  f: FLOAT;
begin
  d := buffer;
  while (length > 0) do
  begin
    lc := LOWORD(d^); rc := HIWORD(d^);
    p1 := (flapos + Trunc(flas)) mod FLABUFLEN;
    p2 := (p1 + 1) mod FLABUFLEN;
    f := fmod(flas, 1.0);
    s := lc + Trunc(((1.0-f) * flabuf[p1, 0]) + (f * flabuf[p2, 0]));
    flabuf[flapos, 0] := lc;
    lc := Clip(s);
    s := rc + Trunc(((1.0-f) * flabuf[p1, 1]) + (f * flabuf[p2, 1]));
    flabuf[flapos, 1] := rc;
    rc := Clip(s);
    d^ := MakeLong(lc, rc);
    Inc(d);
    Inc(flapos);
    if (flapos = FLABUFLEN) then flapos := 0;
    flas := flas + flasinc;
    if (flas < 0) or (flas > FLABUFLEN) then
      flasinc := -flasinc;
    length := length - 4;
  end;
end;

procedure TForm1.Error(msg: string);
var
  s: string;
begin
  s := msg + #13#10 + '(error code: ' + IntToStr(BASS_ErrorGetCode) + ')';
  MessageBox(handle, PChar(s), 'Error', MB_ICONERROR or MB_OK);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  rotdsp := 0;
  echdsp := 0;
  fladsp := 0;
  if (BASS_GetVersion <> MAKELONG(0,8)) then
  begin
    Error('BASS version 0.8 was not loaded');
    Halt;
  end;
  // setup output - default device, 44100hz, stereo, 16 bits, no syncs (not used)
  if not BASS_Init(-1, 44100, BASS_DEVICE_NOSYNC, handle) then
  begin
    Error('Can''t initialize device');
    Halt;
  end
  else
    BASS_Start;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  chattr: Integer;
begin
  if OpenDialog1.Execute then
  begin
    // free both MOD and stream, it must be one of them! :)
    BASS_MusicFree(chan);
    BASS_StreamFree(chan);
    chan := BASS_StreamCreateFile(FALSE, PChar(OpenDialog1.FileName), 0, 0, 0);
    if (chan = 0) then
      chan := BASS_MusicLoad(FALSE, PChar(OpenDialog1.FileName), 0, 0, BASS_MUSIC_LOOP or BASS_MUSIC_RAMP);
    if (chan = 0) then
    begin
      // not a WAV/MP3 or MOD
      Button1.Caption := 'click here to open a file...';
      Error('Can''t play the file');
      Exit;
    end;
    chattr := BASS_ChannelGetFlags(chan) and (BASS_SAMPLE_MONO or BASS_SAMPLE_8BITS);
    if chattr > 0 then
    begin
      // not 16-bit stereo
      Button1.Caption := 'click here to open a file...';
      BASS_MusicFree(chan);
      BASS_StreamFree(chan);
      Error('16-bit stereo sources only');
      Exit;
    end;
    Button1.Caption := OpenDialog1.FileName;
    // setup DSPs on new channel
    CheckBox1Click(Sender);
    CheckBox2Click(Sender);
    CheckBox3Click(Sender);
    // play both MOD and stream, it must be one of them! :)
    BASS_MusicPlay(chan);
    BASS_StreamPlay(chan, FALSE, BASS_SAMPLE_LOOP);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  BASS_Free();
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
  begin
    rotpos := 0.7853981;
    rotdsp := BASS_ChannelSetDSP(chan, Rotate, 0);
  end
  else
    BASS_ChannelRemoveDSP(chan, rotdsp);
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then
  begin
    FillChar(echbuf, SizeOf(echbuf), 0);
    echpos := 0;
    echdsp := BASS_ChannelSetDSP(chan, Echo, 0);
  end
  else
    BASS_ChannelRemoveDSP(chan, echdsp);
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  if CheckBox3.Checked then
  begin
    FillChar(flabuf, SizeOf(flabuf), 0);
    flapos := 0;
    flas := FLABUFLEN / 2;
    flasinc := 0.002;
    fladsp := BASS_ChannelSetDSP(chan, Flange, 0);
  end
  else
    BASS_ChannelRemoveDSP(chan, fladsp);
end;

end.

