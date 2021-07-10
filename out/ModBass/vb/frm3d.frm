VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.1#0"; "COMDLG32.OCX"
Begin VB.Form frm3d 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "BASS - 3D Test"
   ClientHeight    =   3555
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6210
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   3555
   ScaleWidth      =   6210
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame4 
      Height          =   3495
      Left            =   2640
      TabIndex        =   3
      Top             =   0
      Width           =   3495
      Begin VB.PictureBox picDisplay 
         FillStyle       =   0  'Solid
         Height          =   3135
         Left            =   120
         ScaleHeight     =   205
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   213
         TabIndex        =   4
         Top             =   240
         Width           =   3255
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Channels (sample/music)"
      Height          =   2055
      Left            =   120
      TabIndex        =   2
      Top             =   0
      Width           =   2415
      Begin VB.CommandButton cmdStop 
         Caption         =   "Stop"
         Enabled         =   0   'False
         Height          =   300
         Left            =   1320
         TabIndex        =   9
         Top             =   1560
         Width           =   975
      End
      Begin VB.CommandButton cmdPlay 
         Caption         =   "Play"
         Enabled         =   0   'False
         Height          =   300
         Left            =   120
         TabIndex        =   8
         Top             =   1560
         Width           =   975
      End
      Begin VB.CommandButton cmdRemove 
         Caption         =   "Remove"
         Enabled         =   0   'False
         Height          =   300
         Left            =   1320
         TabIndex        =   7
         Top             =   1200
         Width           =   975
      End
      Begin VB.CommandButton cmdAdd 
         Caption         =   "Add ..."
         Height          =   300
         Left            =   120
         TabIndex        =   6
         Top             =   1200
         Width           =   975
      End
      Begin VB.ListBox lstChannels 
         Height          =   840
         ItemData        =   "frm3d.frx":0000
         Left            =   120
         List            =   "frm3d.frx":0002
         TabIndex        =   5
         Top             =   240
         Width           =   2175
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Movement"
      ClipControls    =   0   'False
      Height          =   735
      Left            =   120
      TabIndex        =   1
      Top             =   2040
      Width           =   2415
      Begin MSComDlg.CommonDialog DLG 
         Left            =   1680
         Top             =   0
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   327681
      End
      Begin VB.OptionButton optDirection 
         Caption         =   "None"
         Height          =   255
         Index           =   4
         Left            =   1680
         TabIndex        =   14
         Top             =   450
         Value           =   -1  'True
         Width           =   700
      End
      Begin VB.OptionButton optDirection 
         Caption         =   "Back"
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   13
         Top             =   450
         Width           =   735
      End
      Begin VB.OptionButton optDirection 
         Caption         =   "Front"
         Height          =   255
         Index           =   2
         Left            =   1680
         TabIndex        =   12
         Top             =   175
         Width           =   700
      End
      Begin VB.OptionButton optDirection 
         Caption         =   "Right"
         Height          =   255
         Index           =   1
         Left            =   840
         TabIndex        =   11
         Top             =   175
         Width           =   735
      End
      Begin VB.OptionButton optDirection 
         Caption         =   "Left"
         Height          =   255
         Index           =   0
         Left            =   120
         TabIndex        =   10
         Top             =   175
         Width           =   735
      End
      Begin VB.Timer tmr3D 
         Enabled         =   0   'False
         Interval        =   50
         Left            =   2160
         Top             =   0
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "EAX Environment"
      ClipControls    =   0   'False
      Height          =   735
      Left            =   120
      TabIndex        =   0
      Top             =   2760
      Width           =   2415
      Begin VB.ComboBox cmbEAX 
         BackColor       =   &H00C0C0C0&
         Enabled         =   0   'False
         Height          =   315
         ItemData        =   "frm3d.frx":0004
         Left            =   120
         List            =   "frm3d.frx":0059
         TabIndex        =   15
         Text            =   "Off"
         Top             =   240
         Width           =   2175
      End
   End
End
Attribute VB_Name = "frm3d"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'*********************************************************
'* BASS 3D test (rev .1), copyright (c) 1999 Adam Hoult. *
'*********************************************************

Private Type Channel
    Sample As Long          ' Sample Handle (NOTHING if it's a MOD music.
    Channel As Long         ' The Channel
    pos As BASS_3DVECTOR    ' Position
    vel As BASS_3DVECTOR    ' Velocity
    direction As Integer    ' Direction of the channel
End Type
    
Dim Chans() As Channel      ' Array of channels
Dim NOFChannels As Long     ' Number of Channels
Dim CurrentChannel As Long  ' Current Channel

Const TIMERPER = 50         ' Timer period (ms)
Const MAXDIST = 500         ' maximum distance of the channels (m)
Const SPEED = 5             ' Speed of the channels' movement (m/s)

Const ID_LEFT = 0
Const ID_RIGHT = 1
Const ID_FRONT = 2
Const ID_BACK = 3
Const ID_NONE = 4

Sub ThrowError(Message As String)
'Display error dialogues
Dim ErrorNum As Long
ErrorNum = BASS_ErrorGetCode
MsgBox Message & vbCrLf & vbCrLf & "Error Code : " & ErrorNum & vbCrLf & BASS_GetErrorDescription(ErrorNum), vbCritical, "Error"
End Sub

Sub Update()
Dim c As Integer, X As Integer, Y As Integer, cx As Integer, cy As Integer
cx = picDisplay.ScaleWidth / 2
cy = picDisplay.ScaleHeight / 2
' Clear the display
picDisplay.Cls
' Draw Center Circle
picDisplay.FillColor = RGB(100, 100, 100)
picDisplay.Circle (cx - 4, cy - 4), 4, RGB(0, 0, 0)

For c = 1 To NOFChannels
    ' If the channel is playing, then update it's position
    If BASS_ChannelIsActive(Chans(c).Channel) = BASSTRUE Then
        ' Check if channel has reached the max distance
        If Chans(c).pos.z >= MAXDIST Or Chans(c).pos.z <= -MAXDIST Then Chans(c).vel.z = -Chans(c).vel.z
        If Chans(c).pos.X >= MAXDIST Or Chans(c).pos.X <= -MAXDIST Then Chans(c).vel.X = -Chans(c).vel.X
        ' Update channel position
        Chans(c).pos.z = Chans(c).pos.z + Chans(c).vel.z * TIMERPER / 1000
        Chans(c).pos.X = Chans(c).pos.X + Chans(c).vel.X * TIMERPER / 1000
        If BASS_ChannelSet3DPosition(Chans(c).Channel, Chans(c).pos, Nothing, Chans(c).vel) = BASSFALSE Then ThrowError "Unable to set 3d position"
    End If
    ' Draw the channel position indicator
    X = cx + Int(cx * Chans(c).pos.X / (MAXDIST + 40))
    Y = cy - Int(cy * Chans(c).pos.z / (MAXDIST + 40))
    If CurrentChannel = c Then
        picDisplay.FillColor = RGB(255, 0, 0)
    Else
        picDisplay.FillColor = RGB(150, 0, 0)
    End If
    picDisplay.Circle (X - 4, Y - 4), 4, RGB(0, 0, 0)
Next c
'Apply 3d changes
BASS_Apply3D
End Sub
Sub UpdateButtons()
' Update the button states
' Disable/enable controls depending on NOFChannels
cmdRemove.Enabled = IIf(NOFChannels = 0, False, True)
cmdPlay.Enabled = IIf(NOFChannels = 0, False, True)
cmdStop.Enabled = IIf(NOFChannels = 0, False, True)
For i = 0 To 4
    optDirection(i).Enabled = IIf(NOFChannels = 0, False, True)
Next i
If CurrentChannel > 0 Then
    optDirection(Chans(CurrentChannel).direction).Value = True
End If
End Sub

Private Sub cmdAdd_Click()
On Error Resume Next
' Change the EAX Environment depending on which is selected
Select Case cmbEAX.ListIndex
    Case 0
        BASS_SetEAXParameters -1, 0, -1, -1
    Case 1
        BASS_SetEAXParametersVB EAX_PRESET_GENERIC
    Case 2
        BASS_SetEAXParametersVB EAX_PRESET_PADDEDCELL
    Case 3
        BASS_SetEAXParametersVB EAX_PRESET_ROOM
    Case 4
        BASS_SetEAXParametersVB EAX_PRESET_BATHROOM
    Case 5
        BASS_SetEAXParametersVB EAX_PRESET_LIVINGROOM
    Case 6
        BASS_SetEAXParametersVB EAX_PRESET_STONEROOM
    Case 7
        BASS_SetEAXParametersVB EAX_PRESET_AUDITORIUM
    Case 8
        BASS_SetEAXParametersVB EAX_PRESET_CONCERTHALL
    Case 9
        BASS_SetEAXParametersVB EAX_PRESET_CAVE
    Case 10
        BASS_SetEAXParametersVB EAX_PRESET_ARENA
    Case 11
        BASS_SetEAXParametersVB EAX_PRESET_HANGAR
    Case 12
        BASS_SetEAXParametersVB EAX_PRESET_CARPETEDHALLWAY
    Case 13
        BASS_SetEAXParametersVB EAX_PRESET_HALLWAY
    Case 14
        BASS_SetEAXParametersVB EAX_PRESET_STONECORRIDOR
    Case 15
        BASS_SetEAXParametersVB EAX_PRESET_ALLEY
    Case 16
        BASS_SetEAXParametersVB EAX_PRESET_FOREST
    Case 17
        BASS_SetEAXParametersVB EAX_PRESET_CITY
    Case 18
        BASS_SetEAXParametersVB EAX_PRESET_MOUNTAINS
    Case 19
        BASS_SetEAXParametersVB EAX_PRESET_QUARRY
    Case 20
        BASS_SetEAXParametersVB EAX_PRESET_PLAIN
    Case 21
        BASS_SetEAXParametersVB EAX_PRESET_PARKINGLOT
    Case 22
        BASS_SetEAXParametersVB EAX_PRESET_SEWERPIPE
    Case 23
        BASS_SetEAXParametersVB EAX_PRESET_UNDERWATER
    Case 24
        BASS_SetEAXParametersVB EAX_PRESET_DRUGGED
    Case 25
        BASS_SetEAXParametersVB EAX_PRESET_DIZZY
    Case 26
        BASS_SetEAXParametersVB EAX_PRESET_PSYCHOTIC
End Select
Dim newchan As Long
DLG.filename = ""
DLG.CancelError = True
DLG.flags = cdlOFNExplorer Or cdlOFNFileMustExist Or cdlOFNHideReadOnly
DLG.Filter = "MOD Music/Sample Files (wav/xm/mod/s3m/it/mtm)|*.wav;*.xm;*.mod;*.s3m;*.it;*.mtm|All Files (*.*)|*.*|"
DLG.ShowOpen
'if cancel was pressed, exit the procedure
If Err.Number = 32755 Then Exit Sub
' Load a music from "file" with 3D enabled, and make it loop & use ramping
newchan = BASS_MusicLoad(BASSFALSE, DLG.filename, 0, 0, BASS_MUSIC_RAMP Or BASS_MUSIC_LOOP Or BASS_MUSIC_3D)
If newchan <> 0 Then
    NOFChannels = NOFChannels + 1
    ReDim Preserve Chans(NOFChannels)
    Chans(NOFChannels).Channel = newchan
    Chans(NOFChannels).direction = ID_NONE
    lstChannels.AddItem DLG.filename
    ' Set the min/max distance to 15/1000 meters
    BASS_ChannelSet3DAttributes newchan, -1, 15, 1000, -1, -1, -1
Else
    ' Load a sample from "file" with 3D enabled, and make it loop */
     newchan = BASS_SampleLoad(BASSFALSE, DLG.filename, 0, 0, 1, BASS_SAMPLE_LOOP Or BASS_SAMPLE_3D)
     If newchan <> 0 Then
        Dim sam As BASS_SAMPLE
        NOFChannels = NOFChannels + 1
        ReDim Preserve Chans(NOFChannels)
        Chans(NOFChannels).Sample = newchan
        Chans(NOFChannels).direction = ID_NONE
        lstChannels.AddItem DLG.filename
        'get the info
        BASS_SampleGetInfo newchan, sam
        ' Set the min/max distance to 15/1000 meters
        sam.mindist = 15
        sam.MAXDIST = 1000
        BASS_SampleSetInfo newchan, sam
    Else
        ThrowError "Can't load file"
    End If
End If
End Sub

Private Sub cmdPlay_Click()
'Play the select sample/music
If Chans(CurrentChannel).Sample > 0 Then
    If Chans(CurrentChannel).Channel = 0 Then
        Chans(CurrentChannel).Channel = BASS_SamplePlay3D(Chans(CurrentChannel).Sample, Chans(CurrentChannel).pos, Nothing, Chans(CurrentChannel).vel)
    End If
Else
    BASS_MusicPlay Chans(CurrentChannel).Channel
End If
End Sub

Private Sub cmdRemove_Click()
    If Chans(CurrentChannel).Sample > 0 Then
        BASS_SampleFree Chans(CurrentChannel).Sample
    Else
        BASS_MusicFree Chans(CurrentChannel).Channel
    End If
    'remove the item from the array
    Dim TempChans() As Channel, Counter As Integer
    ReDim TempChans(NOFChannels)
    Counter = 0
    For i = 1 To NOFChannels
        If i <> CurrentChannel Then
            Counter = Counter + 1
            TempChans(Counter) = Chans(i)
        End If
    Next i
    NOFChannels = NOFChannels - 1
    ReDim Chans(NOFChannels)
    For i = 1 To NOFChannels
        Chans(i) = TempChans(i)
    Next i
    Erase TempChans
    lstChannels.RemoveItem lstChannels.ListIndex
    CurrentChannel = 0
    UpdateButtons
End Sub

Private Sub cmdStop_Click()
'stop playing music/sample
BASS_ChannelStop Chans(CurrentChannel).Channel
If Chans(CurrentChannel).Sample > 0 Then Chans(CurrentChannel).Channel = 0
End Sub

Private Sub Form_Load()
cmbEAX.ListIndex = 0
DLG.InitDir = App.Path
' Check that BASS 0.8 was loaded
If BASS_GetStringVersion <> "0.8" Then
    ThrowError "BASS version 0.8 was not loaded"
End If

' Initialize output device - default device, 44100hz, stereo, 16 bits, with 3D funtionality
If BASS_Init(-1, 44100, BASS_DEVICE_3D, frm3d.hWnd) = BASSFALSE Then ThrowError "Can't initialize output device"
' Use meters as distance unit, 2x real world rolloff, real doppler effect
BASS_Set3DFactors 1, 2, 1
'Turn EAX off (volume=0.0), if error then EAX is not supported
If BASS_SetEAXParameters(-1, 0, -1, -1) = BASSFALSE Then
    cmbEAX.Enabled = False
Else
    cmbEAX.Enabled = True
End If
' Start digital output
BASS_Start
UpdateButtons
tmr3D.Enabled = True
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
' Stop digital output.
BASS_Stop
BASS_Free
Erase Chans
End Sub

Private Sub lstChannels_Click()
    ' Change the selected channel
    CurrentChannel = lstChannels.ListIndex + 1
    If chan < 0 Then chan = 0
    UpdateButtons
End Sub

Private Sub optDirection_Click(Index As Integer)
Select Case Index
    Case ID_LEFT
        Chans(CurrentChannel).direction = ID_LEFT
        ' Make the channel move past the left of you
        ' Set speed in m/s
        Chans(CurrentChannel).vel.z = SPEED * 1000 / TIMERPER
        Chans(CurrentChannel).vel.X = 0
        ' Set positon to the left
        Chans(CurrentChannel).pos.X = -20
    Case ID_RIGHT
        Chans(CurrentChannel).direction = ID_RIGHT
        ' Make the channel move past the Right of you
        Chans(CurrentChannel).vel.z = SPEED * 1000 / TIMERPER
        Chans(CurrentChannel).vel.X = 0
        ' Set positon to the Right
        Chans(CurrentChannel).pos.X = 20
    Case ID_FRONT
        Chans(CurrentChannel).direction = ID_FRONT
        ' Make the channel move past the front of you
        Chans(CurrentChannel).vel.X = SPEED * 1000 / TIMERPER
        Chans(CurrentChannel).vel.z = 0
        ' Set positon to the front
        Chans(CurrentChannel).pos.z = 20
    Case ID_BACK
        Chans(CurrentChannel).direction = ID_BACK
        ' Make the channel move past the back of you
        Chans(CurrentChannel).vel.X = SPEED * 1000 / TIMERPER
        Chans(CurrentChannel).vel.z = 0
        ' Set positon to the back
        Chans(CurrentChannel).pos.z = -20
    Case ID_NONE
        Chans(CurrentChannel).direction = ID_NONE
        ' Make the channel stop moving
        Chans(CurrentChannel).vel.z = 0
        Chans(CurrentChannel).vel.X = 0
End Select
End Sub

Private Sub tmr3D_Timer()
    Update
End Sub
