unit DTMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, BASS, Math;

const
  MV_LEFT            = 1;
  MV_RIGHT           = 2;
  MV_UP              = 4;
  MV_DOWN            = 8;

  XDIST              = 70;
  YDIST              = 65;
  XCENTER            = 268;
  YCENTER            = 92;

  DIAM               = 10;

  MAXDIST            = 500;             // maximum distance of the channels (m)
  SPEED              = 5.0;             // speed of the channels' movement (m/s)
  PAR                = 50;

type
  PSource = ^TSource;
  TSource = record
    x, y: Float;
    next: PSource;
    movement: Integer;
    sample, channel: Integer;
    playing: Boolean;
  end;

  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Bevel1: TBevel;
    StaticText1: TStaticText;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    GroupBox2: TGroupBox;
    ComboBox1: TComboBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    ScrollBar3: TScrollBar;
    Bevel2: TBevel;
    Timer1: TTimer;
    Bevel3: TBevel;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
  private
    { Private-Deklarationen }
    sources: PSource;
    procedure Error(msg: string);
    procedure AddSource(name: string);
    procedure RemSource(num: Integer);
    function GetSource(num: Integer): PSource;
    procedure DrawSources;
    procedure FreeSources;
    procedure ActualizeSources(forceupdate: Boolean);
    procedure ActualizeButtons;
    function GetVel(p: PSource): BASS_3DVECTOR;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses DTSelect;

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
  sources := nil;
end;

procedure TForm1.AddSource(name: string);
var
  p, last: PSource;
  newchan, newsamp: Integer;
  sam: BASS_SAMPLE;
begin
  newsamp := 0;
  // Load a music from "file" with 3D enabled, and make it loop & use ramping
  newchan := BASS_MusicLoad(FALSE, PChar(name), 0, 0, BASS_MUSIC_RAMP or BASS_MUSIC_LOOP or BASS_MUSIC_3D);
  if (newchan <> 0) then
  begin
    // Set the min/max distance to 15/1000 meters
    BASS_ChannelSet3DAttributes(newchan, -1, 35.0, 1000.0, -1, -1, -1);
  end
  else
  begin
    // Load a sample from "file" with 3D enabled, and make it loop
    newsamp := BASS_SampleLoad(FALSE, PChar(name), 0, 0, 1, BASS_SAMPLE_LOOP or BASS_SAMPLE_3D or BASS_SAMPLE_VAM);
    if (newsamp <> 0) then
      begin
      // Set the min/max distance to 15/1000 meters
      BASS_SampleGetInfo(newsamp, sam);
      sam.mindist := 35.0;
      sam.maxdist := 1000.0;
      BASS_SampleSetInfo(newsamp, sam);
    end;
  end;
  if (newchan = 0) and (newsamp = 0) then
  begin
    Error('Can''t load file');
    Exit;
  end;

  New(p);
  p.x := 0;
  p.y := 0;
  p.movement := 0;
  p.sample := newsamp;
  p.channel := newchan;
  p.playing := FALSE;
  p.next := nil;
  last := sources;
  if last <> nil then
    while (last.next <> nil) do last := last.next;
  if last = nil then
    sources := p
  else
    last.next := p;
  ListBox1.Items.Add(name);
  ActualizeButtons;
end;

procedure TForm1.RemSource(num: Integer);
var
  p, prev: PSource;
  i: Integer;
begin
  prev := nil;
  p := sources;
  i := 0;
  while (p <> nil) and (i < num) do
  begin
    Inc(i);
    prev := p;
    p := p.next;
  end;
  if (p <> nil) then
  begin
    if (prev <> nil) then
      prev.next := p.next
    else
      sources := p.next;
    if (p.sample <> 0) then
      BASS_SampleFree(p.sample)
    else
      BASS_MusicFree(p.channel);
    Dispose(p);
  end;
  ListBox1.Items.Delete(num);
  ActualizeButtons;
end;

function TForm1.GetSource(num: Integer): PSource;
var
  p: PSource;
  i: Integer;
begin
  if num < 0 then
  begin
    Result := nil;
    Exit;
  end;
  p := sources;
  i := 0;
  while (p <> nil) and (i < num) do
  begin
    Inc(i);
    p := p.next;
  end;
  Result := p;
end;

procedure TForm1.DrawSources;
var
  p: PSource;
  i, j: Integer;
begin
  p := sources;
  with Canvas do
  begin
    Brush.Color := Form1.Color;
    Pen.Color := Form1.Color;
    Rectangle(XCENTER - XDIST - DIAM,
              YCENTER - YDIST - DIAM,
              XCENTER + XDIST + DIAM,
              YCENTER + YDIST + DIAM);
    Brush.Color := clGray;
    Pen.Color := clBlack;
    Ellipse(XCENTER - DIAM div 2,
            YCENTER - DIAM div 2,
            XCENTER + DIAM div 2,
            YCENTER + DIAM div 2);
    Pen.Color := Form1.Color;
    i := 0; j := ListBox1.ItemIndex;
    while (p <> nil) do
    begin
      if (i = j) then
        Brush.Color := clRed
      else
        Brush.Color := clBlack;
        Ellipse(XCENTER + Trunc(p.x * XDIST / MAXDIST) - DIAM div 2,
                YCENTER + Trunc(p.y * YDIST / MAXDIST) - DIAM div 2,
                XCENTER + Trunc(p.x * XDIST / MAXDIST) + DIAM div 2,
                YCENTER + Trunc(p.y * YDIST / MAXDIST) + DIAM div 2);
      p := p.next;
      Inc(i);
    end;
  end;
end;

procedure TForm1.ActualizeSources(forceupdate: Boolean);
var
  p: PSource;
  chng, fchng: Boolean;
  pos, rot, vel: BASS_3DVECTOR;
begin
  pos.y := 0;
  rot.x := 0;
  rot.y := 0;
  rot.z := 0;
  fchng := forceupdate;
  p := sources;
  while (p <> nil) do
  begin
    chng := forceupdate;
    if (p.playing) then
    begin
      if ((p.movement and MV_LEFT) = MV_LEFT) then
      begin
        p.x := p.x - SPEED;
        chng := TRUE;
      end;
      if ((p.movement and MV_RIGHT) = MV_RIGHT) then
      begin
        p.x := p.x + SPEED;
        chng := TRUE;
      end;
      if ((p.movement and MV_UP) = MV_UP) then
      begin
        p.y := p.y - SPEED;
        chng := TRUE;
      end;
      if ((p.movement and MV_DOWN) = MV_DOWN) then
      begin
        p.y := p.y + SPEED;
        chng := TRUE;
      end;
      if (p.x < -MAXDIST) then
      begin
        p.x := -MAXDIST;
        p.movement := MV_RIGHT;
      end;
      if (p.x > MAXDIST) then
      begin
        p.x := MAXDIST;
        p.movement := MV_LEFT;
      end;
      if (p.y < -MAXDIST) then
      begin
        p.y := -MAXDIST;
        p.movement := MV_DOWN;
      end;
      if (p.y > MAXDIST) then
      begin
        p.y := MAXDIST;
        p.movement := MV_UP;
      end;
      if chng then
      begin
        pos.x := p.x;
        pos.z := -p.y;
        vel := getVel(p);
	BASS_ChannelSet3DPosition(p.channel, pos, rot, vel);
      end;
    end;
    p := p.next;
    if chng then fchng := TRUE;
  end;
  if fchng then
  begin
    DrawSources;
    BASS_Apply3D;
  end;
end;

procedure TForm1.FreeSources;
var
  p, v: PSource;
begin
  p := sources;
  while (p <> nil) do
  begin
    v := p.next;
    Dispose(v);
    p := v;
  end;
  sources := nil;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  DrawSources;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  ActualizeSources(FALSE);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  If OpenDialog1.Execute then
  begin
    AddSource(OpenDialog1.FileName);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeSources;
  BASS_Stop;
  BASS_Free;
end;

procedure TForm1.ActualizeButtons;
var
  en: Boolean;
  p: PSource;
begin
  en := (ListBox1.ItemIndex >= 0);
  Button2.Enabled := en;
  Button3.Enabled := en;
  Button4.Enabled := en;
  RadioButton1.Enabled := en;
  RadioButton2.Enabled := en;
  RadioButton3.Enabled := en;
  RadioButton4.Enabled := en;
  RadioButton5.Enabled := en;
  DrawSources;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  if (p.x = -PAR) and ((p.movement = MV_UP) or (p.movement = MV_DOWN)) then
    RadioButton1.Checked := TRUE
  else if (p.x = PAR) and ((p.movement = MV_UP) or (p.movement = MV_DOWN)) then
    RadioButton2.Checked := TRUE
  else if (p.y = -PAR) and ((p.movement = MV_LEFT) or (p.movement = MV_RIGHT)) then
    RadioButton3.Checked := TRUE
  else if (p.y = PAR) and ((p.movement = MV_LEFT) or (p.movement = MV_RIGHT)) then
    RadioButton4.Checked := TRUE
  else
    RadioButton5.Checked := TRUE;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  ActualizeButtons;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if ListBox1.ItemIndex >= 0 then
    RemSource(ListBox1.ItemIndex);
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ActualizeButtons;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  p: PSource;
  pos, rot, vel: BASS_3DVECTOR;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.itemIndex);
  if not p.playing then
  begin
    p.playing := TRUE;
    pos.x := p.x;
    pos.y := 0;
    pos.z := -p.y;
    vel := GetVel(p);
    rot.x := 0;
    rot.y := 0;
    rot.z := 0;
    if (p.sample <> 0) then
    begin
      if (p.channel = 0) then
        p.channel := BASS_SamplePlay3D(p.sample, pos, rot, vel);
    end
    else
      BASS_MusicPlay(p.channel);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  p: PSource;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  BASS_ChannelStop(p.channel);
  if (p.sample <> 0) then p.channel := 0;
  p.playing := FALSE;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
var
  p: PSource;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  if (p.movement and MV_UP = 0) and
     (p.movement and MV_DOWN = 0) then
  begin
    p.movement := MV_UP;
    p.x := -PAR;
    p.y := 0;
  end
  else
    p.x := -PAR;
  DrawSources;
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
var
  p: PSource;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  if (p.movement and MV_UP = 0) and
     (p.movement and MV_DOWN = 0) then
  begin
    p.movement := MV_UP;
    p.x := PAR;
    p.y := 0;
  end
  else
    p.x := PAR;
  DrawSources;
end;

procedure TForm1.RadioButton3Click(Sender: TObject);
var
  p: PSource;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  if (p.movement and MV_LEFT = 0) and
     (p.movement and MV_RIGHT = 0) then
  begin
    p.movement := MV_RIGHT;
    p.x := 0;
    p.y := -PAR;
  end
  else
    p.y := -PAR;
  DrawSources;
end;

procedure TForm1.RadioButton4Click(Sender: TObject);
var
  p: PSource;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  if (p.movement and MV_LEFT = 0) and
     (p.movement and MV_RIGHT = 0) then
  begin
    p.movement := MV_RIGHT;
    p.x := 0;
    p.y := PAR;
  end
  else
    p.y := PAR;
  DrawSources;
end;

procedure TForm1.RadioButton5Click(Sender: TObject);
var
  p: PSource;
begin
  if ListBox1.ItemIndex < 0 then Exit;
  p := GetSource(ListBox1.ItemIndex);
  if p = nil then Exit;
  p.movement := 0;
  ActualizeSources(TRUE);
end;

function TForm1.GetVel(p: PSource): BASS_3DVECTOR;
var
  x, z: Float;
  sp: Float;
begin
  x := 0;
  z := 0;
  if p.playing then
  begin
    sp := SPEED * 1000 / Timer1.Interval;
    if (p.movement = MV_LEFT) then x := -sp
    else if (p.movement = MV_RIGHT) then x := sp
    else if (p.movement = MV_UP) then z := sp
    else if (p.movement = MV_DOWN) then z := -sp;
  end;
  Result.x := x;
  Result.y := 0;
  Result.z := z;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  case (ComboBox1.ItemIndex) of
    0: BASS_EAXPreset(EAX_ENVIRONMENT_OFF);
    1: BASS_EAXPreset(EAX_ENVIRONMENT_GENERIC);
    2: BASS_EAXPreset(EAX_ENVIRONMENT_PADDEDCELL);
    3: BASS_EAXPreset(EAX_ENVIRONMENT_ROOM);
    4: BASS_EAXPreset(EAX_ENVIRONMENT_BATHROOM);
    5: BASS_EAXPreset(EAX_ENVIRONMENT_LIVINGROOM);
    6: BASS_EAXPreset(EAX_ENVIRONMENT_STONEROOM);
    7: BASS_EAXPreset(EAX_ENVIRONMENT_AUDITORIUM);
    8: BASS_EAXPreset(EAX_ENVIRONMENT_CONCERTHALL);
    9: BASS_EAXPreset(EAX_ENVIRONMENT_CAVE);
    10: BASS_EAXPreset(EAX_ENVIRONMENT_ARENA);
    11: BASS_EAXPreset(EAX_ENVIRONMENT_HANGAR);
    12: BASS_EAXPreset(EAX_ENVIRONMENT_CARPETEDHALLWAY);
    13: BASS_EAXPreset(EAX_ENVIRONMENT_HALLWAY);
    14: BASS_EAXPreset(EAX_ENVIRONMENT_STONECORRIDOR);
    15: BASS_EAXPreset(EAX_ENVIRONMENT_ALLEY);
    16: BASS_EAXPreset(EAX_ENVIRONMENT_FOREST);
    17: BASS_EAXPreset(EAX_ENVIRONMENT_CITY);
    18: BASS_EAXPreset(EAX_ENVIRONMENT_MOUNTAINS);
    19: BASS_EAXPreset(EAX_ENVIRONMENT_QUARRY);
    20: BASS_EAXPreset(EAX_ENVIRONMENT_PLAIN);
    21: BASS_EAXPreset(EAX_ENVIRONMENT_PARKINGLOT);
    22: BASS_EAXPreset(EAX_ENVIRONMENT_SEWERPIPE);
    23: BASS_EAXPreset(EAX_ENVIRONMENT_UNDERWATER);
    24: BASS_EAXPreset(EAX_ENVIRONMENT_DRUGGED);
    25: BASS_EAXPreset(EAX_ENVIRONMENT_DIZZY);
    26: BASS_EAXPreset(EAX_ENVIRONMENT_PSYCHOTIC);
  end;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
    BASS_SetA3DHFAbsorbtion(Power(2, ScrollBar3.Position / 2.0))
  else
    BASS_SetA3DHFAbsorbtion(0);
end;

procedure TForm1.ScrollBar3Change(Sender: TObject);
var
  a: Float;
begin
  a := ScrollBar3.Position;
  if CheckBox1.Checked then
    BASS_SetA3DHFAbsorbtion(Power(2.0, a / 2.0));
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
var
  a: Float;
begin
  a := ScrollBar1.Position;
  BASS_Set3DFactors(-1, Power(2.0, a / 4.0), -1);
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
var
  a: Float;
begin
  a := ScrollBar2.Position;
  BASS_Set3DFactors(-1, -1, Power(2.0, a / 4.0));
end;

end.

