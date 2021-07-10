unit BTMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Bass, StdCtrls, ExtCtrls, Buttons;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Edit1: TEdit;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Label5: TLabel;
    Edit2: TEdit;
    Label6: TLabel;
    Button15: TButton;
    Button16: TButton;
    CheckBox1: TCheckBox;
    Button17: TButton;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    OpenDialog2: TOpenDialog;
    OpenDialog3: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    { Private-Deklarationen }
    mods: array[0..128] of HMUSIC;
    modc: Integer;
    sams: array[0..128] of HSAMPLE;
    samc: Integer;
    str: HSTREAM;
    cdplaying: Boolean;
    procedure Error(msg: string);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Error(msg: string);
var
  s: string;
begin
  s := msg + #13#10 + '(error code: ' + IntToStr(BASS_ErrorGetCode) + ')';
  MessageBox(handle, PChar(s), 'Error', MB_ICONERROR or MB_OK);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  modc := 0;
  samc := 0;
  cdplaying := FALSE;
  str := 0;
  {
    Check that BASS 0.7 was loaded
  }
  if BASS_GetVersion() <> MAKELONG(0,8) then begin
    Error('BASS version 0.8 was not loaded');
    Halt;
  end;
  {
    Initialize digital sound -
    default device, 44100hz, stereo, 16 bits
  }
  if not BASS_Init(-1, 44100, 0, handle) then
    Error('Can''t initialize digital sound system');
  {
    Initialize CD
  }
  if not BASS_CDInit(nil) then
    Error('Can''t initialize CD system');
  {
    Start digital output
  }
  BASS_Start;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  a: Integer;
begin
  {
    Stop digital output
  }
  BASS_Stop;
  {
    Free the stream
  }
  BASS_StreamFree(str);
  {
    It's not actually necessary to free the musics and
    samples because they are automatically freed by
    BASS_Free
  }
  {
    Free musics
  }
  if modc > 0 then
    for a := 0 to modc - 1 do BASS_MusicFree(mods[a]);
  {
    Free samples
  }
  if samc > 0 then
    for a := 0 to samc - 1 do BASS_SampleFree(sams[a]);
  BASS_Free();	// Close digital sound system
  BASS_CDFree(); // Close CD system
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i: Integer;
begin
  i := ListBox1.ItemIndex;
  // Play the music (continue from current position)
  if i >= 0 then
    if not BASS_MusicPlay(mods[i]) then
      Error('Can''t play music');
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  i: Integer;
begin
  i := ListBox1.ItemIndex;
  // Stop the music
  if i >= 0 then
    BASS_ChannelStop(mods[i]);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  i: Integer;
begin
  i := ListBox1.ItemIndex;
  // Play the music from the start
  if i >= 0 then
    BASS_MusicPlayEx(mods[i], 0, -1, TRUE);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  f: PChar;
begin
  if OpenDialog1.Execute then begin
    f := PChar(OpenDialog1.FileName);
    mods[modc] := BASS_MusicLoad(FALSE, f, 0, 0, BASS_MUSIC_RAMP);
    if mods[modc] <> 0 then begin
      ListBox1.Items.Add(OpenDialog1.FileName);
      Inc(modc);
    end
    else Error('Can''t load music');
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  a, i: Integer;
begin
  i := ListBox1.ItemIndex;
  if i >= 0 then begin
    BASS_MusicFree(mods[i]);
    if i < modc then
      for a := i to modc - 1 do
        mods[a] := mods[a + 1];
    Dec(modc);
    ListBox1.Items.Delete(i);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Integer;
  s: string;
begin
  // update the CD status
  CheckBox1.Checked := BASS_CDInDrive;
  i := BASS_ChannelGetPosition(CDCHANNEL);
  s := IntToStr(i div 1000 mod 60);
  if Length(s) < 2 then s := '0' + s;
  s := IntToStr(i div 60000) + ':' + s;
  Label6.Caption := s;
  // update the CPU usage % display
  Label2.Caption := FloatToStrF(BASS_GetCPU, ffFixed, 4, 1);
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  // Play CD track (looped)
  if not BASS_CDPlay(StrToInt(Edit2.Text), TRUE, FALSE) then
    Error('Can''t play CD')
  else
    cdplaying := TRUE;
end;

procedure TForm1.Button16Click(Sender: TObject);
begin
  // Pause CD
  BASS_ChannelPause(CDCHANNEL);
  cdplaying := FALSE;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
  // Resume CD
  if BASS_ChannelResume(CDCHANNEL) then
    cdplaying := TRUE;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // Pause digital output and CD
  BASS_Pause();
  BASS_ChannelPause(CDCHANNEL);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Resume digital output and CD
  if cdplaying then BASS_ChannelResume(CDCHANNEL);
  BASS_Start();
end;

procedure TForm1.Button12Click(Sender: TObject);
var
  f: PChar;
begin
  if OpenDialog2.Execute then begin
    f := PChar(OpenDialog2.Filename);
    str := BASS_StreamCreateFile(FALSE, f, 0, 0, 0);
    if str = 0 then
      Error('Can''t create stream')
    else
      Edit1.Text := Opendialog2.Filename;
  end;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  // Play stream, not flushed
  if not BASS_StreamPlay(str, FALSE, 0) then
    Error('Can''t play stream');
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
  // Stop the stream
  BASS_ChannelStop(str);
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  f: PChar;
begin
  if OpenDialog3.Execute then begin
    f := PChar(OpenDialog3.FileName);
    sams[samc] := BASS_SampleLoad(FALSE, f, 0, 0, 3, BASS_SAMPLE_OVER_POS);
    if sams[samc] <> 0 then begin
      ListBox2.Items.Add(OpenDialog3.FileName);
      Inc(samc);
    end
    else Error('Can''t load sample');
  end;                            
end;

procedure TForm1.Button11Click(Sender: TObject);
var
  a, i: Integer;
begin
  i := ListBox2.ItemIndex;
  if i >= 0 then begin
    BASS_SampleFree(sams[i]);
    if i < samc then
      for a := i to samc - 1 do
        sams[a] := sams[a + 1];
    Dec(samc);
    ListBox2.Items.Delete(i);
  end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  i: Integer;
begin
  i := ListBox2.ItemIndex;
  // Play the sample from the start, volume=50, random pan position,
  // using the default frequency and looping settings
  if i >= 0 then
    if not BASS_SamplePlayEx(sams[i], 0, -1, 50, Random(101), FALSE) = 0 then
      Error('Can''t play sample');
end;

end.
