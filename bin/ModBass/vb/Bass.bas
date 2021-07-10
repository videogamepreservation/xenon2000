Attribute VB_Name = "modBass"
'BASS 0.8 Multimedia Library
'-----------------------------
'(c) 1999-2000 Ian Luck.
'Please report bugs/suggestions/etc... to bass@un4seen.com

'Visual Basic API Version 0.8 by Adam Hoult
'------------------------------------------
'Questions, suggestions, etc. regarding the Visual Basic API
'can be sent to admin@daedalusd.com

'NOTE: This unit will only work with BASS.DLL version 0.8
'Check http://www.un4seen.com/music for any later
'versions of BASS.BAS

' HISTORY - UK Dates (DD/MM/YYYY)
' -------------------------------
' 12/01/2000 BASS.BAS 0.8
'            Happy new Year !! =) Updated for BASS 0.8
'            Tons of stuff added, especially to do with
'            Directsound objects etc plus some other
'            General Enhancements.
'
' 22/09/1999 BASS.BAS 0.7
'            Updated the BAS file for use with the new
'            version of BASS (0.7). Added the extra A3D
'            calls, plus the new POSRESET flag. Also
'            updated the needed functions.
'
' 07/09/1999 BASS.BAS 0.6
'            The first BASS API for Visual Basic
'            Tested with VB5, but should also work
'            properly under VB4 & VB6 (Not sure about
'            VB3 due to the use of callbacks.)

Global Const BASSTRUE As Integer = 1   'Use this instead of VB Booleans
Global Const BASSFALSE As Integer = 0  'Use this instead of VB Booleans

'***********************************************
'* Error codes returned by BASS_GetErrorCode() *
'***********************************************
Global Const BASS_OK = 0               'all is OK
Global Const BASS_ERROR_MEM = 1        'memory error
Global Const BASS_ERROR_FILEOPEN = 2   'can't open the file
Global Const BASS_ERROR_DRIVER = 3     'can't find a free sound driver
Global Const BASS_ERROR_BUFLOST = 4    'the sample buffer was lost - please report this!
Global Const BASS_ERROR_HANDLE = 5     'invalid handle
Global Const BASS_ERROR_FORMAT = 6     'unsupported format
Global Const BASS_ERROR_POSITION = 7   'invalid playback position
Global Const BASS_ERROR_INIT = 8       'BASS_Init has not been successfully called
Global Const BASS_ERROR_START = 9      'BASS_Start has not been successfully called
Global Const BASS_ERROR_INITCD = 10    'can't initialize CD
Global Const BASS_ERROR_CDINIT = 11    'BASS_CDInit has not been successfully called
Global Const BASS_ERROR_NOCD = 12      'no CD in drive
Global Const BASS_ERROR_CDTRACK = 13   'can't play the selected CD track
Global Const BASS_ERROR_ALREADY = 14   'already initialized
Global Const BASS_ERROR_CDVOL = 15     'CD has no volume control
Global Const BASS_ERROR_NOPAUSE = 16   'not paused
Global Const BASS_ERROR_NOTAUDIO = 17  'not an audio track
Global Const BASS_ERROR_NOCHAN = 18    'can't get a free channel
Global Const BASS_ERROR_ILLTYPE = 19   'an illegal type was specified
Global Const BASS_ERROR_ILLPARAM = 20  'an illegal parameter was specified
Global Const BASS_ERROR_NO3D = 21      'no 3D support
Global Const BASS_ERROR_NOEAX = 22     'no EAX support
Global Const BASS_ERROR_DEVICE = 23    'illegal device number
Global Const BASS_ERROR_NOPLAY = 24    'not playing
Global Const BASS_ERROR_FREQ = 25      'illegal sample rate
Global Const BASS_ERROR_NOA3D = 26     'A3D.DLL is not installed
Global Const BASS_ERROR_NOTFILE = 27   'the stream is not a file stream (WAV/MP3)
Global Const BASS_ERROR_NOHW = 29      'no hardware voices available
Global Const BASS_ERROR_UNKNOWN = -1   'some other mystery error

'**********************
'* Device setup flags *
'**********************
Global Const BASS_DEVICE_8BITS = 1     'use 8 bit resolution, else 16 bit
Global Const BASS_DEVICE_MONO = 2      'use mono, else stereo
Global Const BASS_DEVICE_3D = 4        'enable 3D functionality
' If the BASS_DEVICE_3D flag is not specified when initilizing BASS,
' then the 3D flags (BASS_SAMPLE_3D and BASS_MUSIC_3D) are ignored when
' loading/creating a sample/stream/music.
Global Const BASS_DEVICE_A3D = 8       'enable A3D functionality
Global Const BASS_DEVICE_NOSYNC = 16       'disable synchronizers

'***********************************
'* BASS_INFO flags (from DSOUND.H) *
'***********************************
Global Const DSCAPS_CONTINUOUSRATE = 16
' supports all sample rates between min/maxrate
Global Const DSCAPS_EMULDRIVER = 32
' device does NOT have hardware DirectSound support
Global Const DSCAPS_CERTIFIED = 64
' device driver has been certified by Microsoft
' The following flags tell what type of samples are supported by HARDWARE
' mixing, all these formats are supported by SOFTWARE mixing
Global Const DSCAPS_SECONDARYMONO = 256    ' mono
Global Const DSCAPS_SECONDARYSTEREO = 512  ' stereo
Global Const DSCAPS_SECONDARY8BIT = 1024   ' 8 bit
Global Const DSCAPS_SECONDARY16BIT = 2048  ' 16 bit

'***************
'* Music flags *
'***************
Global Const BASS_MUSIC_RAMP = 1       ' normal ramping
Global Const BASS_MUSIC_RAMPS = 2      ' sensitive ramping
' Ramping doesn't take a lot of extra processing and improves
' the sound quality by removing "clicks". Sensitive ramping will
' leave sharp attacked samples, unlike normal ramping.
Global Const BASS_MUSIC_LOOP = 4       ' loop music
Global Const BASS_MUSIC_FT2MOD = 16    ' play .MOD as FastTracker 2 does
Global Const BASS_MUSIC_PT1MOD = 32    ' play .MOD as ProTracker 1 does
Global Const BASS_MUSIC_MONO = 64      ' force mono mixing (less CPU usage)
Global Const BASS_MUSIC_3D = 128       ' enable 3D functionality
Global Const BASS_MUSIC_POSRESET = 256 ' stop all notes when moving position

'*********************
'* Sample info flags *
'*********************
Global Const BASS_SAMPLE_8BITS = 1             ' 8 bit, else 16 bit
Global Const BASS_SAMPLE_MONO = 2              ' mono, else stereo
Global Const BASS_SAMPLE_LOOP = 4              ' looped
Global Const BASS_SAMPLE_3D = 8                ' 3D functionality enabled
Global Const BASS_SAMPLE_SOFTWARE = 16         ' it's NOT using hardware mixing
Global Const BASS_SAMPLE_MUTEMAX = 32          ' muted at max distance (3D only)
Global Const BASS_SAMPLE_VAM = 64              ' uses the DX7 voice allocation & management
Global Const BASS_SAMPLE_OVER_VOL = 65536      ' override lowest volume
Global Const BASS_SAMPLE_OVER_POS = 131072     ' override longest playing
Global Const BASS_SAMPLE_OVER_DIST = 196608    ' override furthest from listener (3D only)

Global Const BASS_MP3_HALFRATE = 65536         ' reduced quality MP3 (half sample rate)
Global Const BASS_MP3_SETPOS = 131072          ' enable BASS_ChannelSetPosition on the MP3

'********************
'* 3D channel modes *
'********************
Global Const BASS_3DMODE_NORMAL = 0
' normal 3D processing
Global Const BASS_3DMODE_RELATIVE = 1
' The channel's 3D position (position/velocity/orientation) are relative to
' the listener. When the listener's position/velocity/orientation is changed
' with BASS_Set3DPosition, the channel's position relative to the listener does
' not change.
Global Const BASS_3DMODE_OFF = 2
' Turn off 3D processing on the channel, the sound will be played
' in the center.


'****************************************************
'* EAX environments, use with BASS_SetEAXParameters *
'****************************************************
Global Const EAX_ENVIRONMENT_GENERIC = 0
Global Const EAX_ENVIRONMENT_PADDEDCELL = 1
Global Const EAX_ENVIRONMENT_ROOM = 2
Global Const EAX_ENVIRONMENT_BATHROOM = 3
Global Const EAX_ENVIRONMENT_LIVINGROOM = 4
Global Const EAX_ENVIRONMENT_STONEROOM = 5
Global Const EAX_ENVIRONMENT_AUDITORIUM = 6
Global Const EAX_ENVIRONMENT_CONCERTHALL = 7
Global Const EAX_ENVIRONMENT_CAVE = 8
Global Const EAX_ENVIRONMENT_ARENA = 9
Global Const EAX_ENVIRONMENT_HANGAR = 10
Global Const EAX_ENVIRONMENT_CARPETEDHALLWAY = 11
Global Const EAX_ENVIRONMENT_HALLWAY = 12
Global Const EAX_ENVIRONMENT_STONECORRIDOR = 13
Global Const EAX_ENVIRONMENT_ALLEY = 14
Global Const EAX_ENVIRONMENT_FOREST = 15
Global Const EAX_ENVIRONMENT_CITY = 16
Global Const EAX_ENVIRONMENT_MOUNTAINS = 17
Global Const EAX_ENVIRONMENT_QUARRY = 18
Global Const EAX_ENVIRONMENT_PLAIN = 19
Global Const EAX_ENVIRONMENT_PARKINGLOT = 20
Global Const EAX_ENVIRONMENT_SEWERPIPE = 21
Global Const EAX_ENVIRONMENT_UNDERWATER = 22
Global Const EAX_ENVIRONMENT_DRUGGED = 23
Global Const EAX_ENVIRONMENT_DIZZY = 24
Global Const EAX_ENVIRONMENT_PSYCHOTIC = 25
' total number of environments
Global Const EAX_ENVIRONMENT_COUNT = 26

'*************************************************************
'* EAX presets, usage: BASS_SetEAXParametersVB(EAX_PRESET_xxx) *
'*************************************************************
Global Const EAX_PRESET_GENERIC = 1
Global Const EAX_PRESET_PADDEDCELL = 2
Global Const EAX_PRESET_ROOM = 3
Global Const EAX_PRESET_BATHROOM = 4
Global Const EAX_PRESET_LIVINGROOM = 5
Global Const EAX_PRESET_STONEROOM = 6
Global Const EAX_PRESET_AUDITORIUM = 7
Global Const EAX_PRESET_CONCERTHALL = 8
Global Const EAX_PRESET_CAVE = 9
Global Const EAX_PRESET_ARENA = 10
Global Const EAX_PRESET_HANGAR = 11
Global Const EAX_PRESET_CARPETEDHALLWAY = 12
Global Const EAX_PRESET_HALLWAY = 13
Global Const EAX_PRESET_STONECORRIDOR = 14
Global Const EAX_PRESET_ALLEY = 15
Global Const EAX_PRESET_FOREST = 16
Global Const EAX_PRESET_CITY = 17
Global Const EAX_PRESET_MOUNTAINS = 18
Global Const EAX_PRESET_QUARRY = 19
Global Const EAX_PRESET_PLAIN = 20
Global Const EAX_PRESET_PARKINGLOT = 21
Global Const EAX_PRESET_SEWERPIPE = 22
Global Const EAX_PRESET_UNDERWATER = 23
Global Const EAX_PRESET_DRUGGED = 24
Global Const EAX_PRESET_DIZZY = 25
Global Const EAX_PRESET_PSYCHOTIC = 26

'******************************
'* A3D resource manager modes *
'******************************
Global Const A3D_RESMODE_OFF = 0                'off
Global Const A3D_RESMODE_NOTIFY = 1             'notify when there are no free hardware channels
Global Const A3D_RESMODE_DYNAMIC = 2            'non-looping channels are managed
Global Const A3D_RESMODE_DYNAMIC_LOOPERS = 3    'all (inc. looping) channels are managed (req A3D 1.2)


'**********************************************************************
'* Sync types (with BASS_ChannelSetSync() "param" and SYNCPROC "data" *
'* definitions) & flags.                                              *
'**********************************************************************
' Sync when a music reaches a position.
' param: LOWORD=order (0=first, -1=all) HIWORD=row (0=first, -1=all)
' data : LOWORD=order HIWORD=row
Global Const BASS_SYNC_MUSICPOS = 0
' Sync when an instrument (sample for the non-instrument based formats)
' is played in a music (not including retrigs).
' param: LOWORD=instrument (1=first) HIWORD=note (0=c0...119=b9, -1=all)
' data : LOWORD=note HIWORD=volume (0-64)
Global Const BASS_SYNC_MUSICINST = 1
' Sync when a music or file stream reaches the end.
' param: not used
' data : not used
Global Const BASS_SYNC_END = 2
' Sync when the "sync" effect (XM/MTM/MOD: E8x, IT/S3M: S0x) is used.
' param: 0:data=pos, 1:data="x" value
' data : param=0: LOWORD=order HIWORD=row, param=1: "x" value */
Global Const BASS_SYNC_MUSICFX = 3
'FLAG: sync at mixtime, else at playtime
Global Const BASS_SYNC_MIXTIME = 1073741824#
' FLAG: sync only once, else continuously
Global Const BASS_SYNC_ONETIME = 2147483648#

Global Const CDCHANNEL = 0                    ' CD channel, for use with BASS_Channel functions

'**************************************************************
'* DirectSound interfaces (for use with BASS_GetDSoundObject) *
'**************************************************************
Global Const BASS_OBJECT_DS = 1                     ' DirectSound
Global Const BASS_OBJECT_DS3DL = 2                  'IDirectSound3DListener

'******************************
'* DX7 voice allocation flags *
'******************************
' Play the sample in hardware. If no hardware voices are available then
' the "play" call will fail
Global Const BASS_VAM_HARDWARE = 1
' Play the sample in software (ie. non-accelerated). No other VAM flags
'may be used together with this flag.
Global Const BASS_VAM_SOFTWARE = 2

'******************************
'* DX7 voice management flags *
'******************************
' These flags enable hardware resource stealing... if the hardware has no
' available voices, a currently playing buffer will be stopped to make room for
' the new buffer. NOTE: only samples loaded/created with the BASS_SAMPLE_VAM
' flag are considered for termination by the DX7 voice management.

' If there are no free hardware voices, the buffer to be terminated will be
' the one with the least time left to play.
Global Const BASS_VAM_TERM_TIME = 4
' If there are no free hardware voices, the buffer to be terminated will be
' one that was loaded/created with the BASS_SAMPLE_MUTEMAX flag and is beyond
' it 's max distance. If there are no buffers that match this criteria, then the
' "play" call will fail.
Global Const BASS_VAM_TERM_DIST = 8
' If there are no free hardware voices, the buffer to be terminated will be
' the one with the lowest priority.
Global Const BASS_VAM_TERM_PRIO = 16

'**********************************************************************
'* software 3D mixing algorithm modes (used with BASS_Set3DAlgorithm) *
'**********************************************************************
' default algorithm (currently translates to BASS_3DALG_OFF)
Global Const BASS_3DALG_DEFAULT = 0
' Uses normal left and right panning. The vertical axis is ignored except for
'scaling of volume due to distance. Doppler shift and volume scaling are still
'applied, but the 3D filtering is not performed. This is the most CPU efficient
'software implementation, but provides no virtual 3D audio effect. Head Related
'Transfer Function processing will not be done. Since only normal stereo panning
'is used, a channel using this algorithm may be accelerated by a 2D hardware
'voice if no free 3D hardware voices are available.
Global Const BASS_3DALG_OFF = 1
' This algorithm gives the highest quality 3D audio effect, but uses more CPU.
' Requires Windows 98 2nd Edition or Windows 2000 that uses WDM drivers, if this
' mode is not available then BASS_3DALG_OFF will be used instead.
Global Const BASS_3DALG_FULL = 2
' This algorithm gives a good 3D audio effect, and uses less CPU than the FULL
' mode. Requires Windows 98 2nd Edition or Windows 2000 that uses WDM drivers, if
' this mode is not available then BASS_3DALG_OFF will be used instead.
Global Const BASS_3DALG_LIGHT = 3

Type BASS_INFO
    size As Long                'size of this struct (set this before calling the function)
    flags As Long               'device capabilities (DSCAPS_xxx flags)
    ' The following values are irrelevant if the device doesn't have hardware
    ' support (DSCAPS_EMULDRIVER is specified in flags)
    hwsize As Long              'size of total device hardware memory
    hwfree As Long              'size of free device hardware memory
    freesam As Long             'number of free sample slots in the hardware
    free3d As Long              'number of free 3D sample slots in the hardware
    minrate As Long             'min sample rate supported by the hardware
    maxrate As Long             'max sample rate supported by the hardware
    eax As Integer              'device supports EAX? (always BASSFALSE if BASS_DEVICE_3D was not used)
    a3d As Long                 'A3D version (0=unsupported or BASS_DEVICE_A3D was not used)
    dsver As Long               'DirectSound version (use to check for DX5/7 functions)
End Type

'*************************
'* Sample info structure *
'*************************
Type BASS_SAMPLE
    freq As Long                'default playback rate
    volume As Long              'default volume (0-100)
    pan As Integer              'default pan (-100=left, 0=middle, 100=right)
    flags As Long               'BASS_SAMPLE_xxx flags
    length As Long              'length (in samples, not bytes)
    max As Long ' maximum simultaneous playbacks
    ' The following are the sample's default 3D attributes (if the sample
    ' is 3D, BASS_SAMPLE_3D is in flags) see BASS_ChannelSet3DAttributes
    mode3d As Long              'BASS_3DMODE_xxx mode
    mindist As Single           'minimum distance
    MAXDIST As Single           'maximum distance
    iangle As Long              'angle of inside projection cone
    oangle As Long              'angle of outside projection cone
    outvol As Long              'delta-volume outside the projection cone
    ' The following are the defaults used if the sample uses the DirectX 7
    ' voice allocation/management features.
    vam As Long                 'voice allocation/management flags (BASS_VAM_xxx)
    priority As Long            'priority (0=lowest, 0xffffffff=highest)
End Type

'********************************************************
'* 3D vector (for 3D positions/velocities/orientations) *
'********************************************************
Type BASS_3DVECTOR
    X As Single                 '+=right, -=left
    Y As Single                 '+=up, -=down
    z As Single                 '+=front, -=behind
End Type

' Retrieve the version number of BASS that is loaded. RETURN : The BASS version (LOWORD.HIWORD)
Declare Function BASS_GetVersion Lib "bass.dll" () As Long

' Get the text description of a device. This function can be used to enumerate the available devices.
' devnum: The device(0 = First)
' desc: Pointer to store pointer to text description
Declare Function BASS_GetDeviceDescription Lib "bass.dll" (ByVal devnum As Long, ByRef Desc As String) As Integer

' Set the amount that BASS mixes ahead new musics/streams.
' Changing this setting does not affect musics/streams
' that have already been loaded/created. Increasing the
' buffer length, decreases the chance of the sound
' possibly breaking-up on slower computers, but also
' requires more memory. The default length is 0.5 secs.
' length : The buffer length in seconds (limited to 0.3-2.0s)

' NOTE: This setting does not represent the latency
' (delay between playing and hearing the sound). The
' latency depends on the drivers, the power of the CPU,
' and the complexity of what's being mixed (eg. an IT
' using filters requires more processing than a plain
' 4 channel MOD). So the buffer length actually has no
' effect on the latency.
Declare Sub BASS_SetBufferLength Lib "bass.dll" (ByVal length As Single)

' Set the global music/sample/stream volume levels.
' musvol : MOD music global volume level (0-100, -1=leave current)
' samvol : Sample global volume level (0-100, -1=leave current)
' strvol : Stream global volume level (0-100, -1=leave current)
Declare Sub BASS_SetGlobalVolumes Lib "bass.dll" (ByVal musvol As Long, ByVal samvol As Long, ByVal strvol As Long)

' Retrive the global music/sample/stream volume levels.
' musvol : MOD music global volume level (NULL=don't retrieve it)
' samvol : Sample global volume level (NULL=don't retrieve it)
' strvol : Stream global volume level (NULL=don't retrieve it)
Declare Sub BASS_GetGlobalVolumes Lib "bass.dll" (ByRef musvol As Long, ByRef samvol As Long, ByRef strvol As Long)

' Make the volume/panning values translate to a logarithmic curve,
' or a linear "curve" (the default)
' volume :   volume curve(BASSFALSE = linear, BASSTRUE = Log)
' pan    : panning curve (BASSFALSE=linear, BASSTRUE=log) */
Declare Sub BASS_SetLogCurves Lib "bass.dll" (ByVal volume As Integer, ByVal pan As Integer)

' Set the 3D algorithm for software mixed 3D channels (does not affect
' hardware mixed channels). Changing the mode only affects subsequently
' created or loaded samples/streams/musics, not those that already exist.
' Requires DirectX 7 or above.
' algo : algorithm flag (BASS_3DALG_xxx)
Declare Sub BASS_Set3DAlgorithm Lib "bass.dll" (ByVal algo As Long)

' Get the BASS_ERROR_xxx error code. Use this function to get the reason for an error.
Declare Function BASS_ErrorGetCode Lib "bass.dll" () As Long

' Initialize the digital output. This must be called
' before all following BASS functions (except CD functions).
' The volume is initially set to 100 (the maximum),
' use BASS_SetVolume() to adjust it.
' device : Device to use (0=first, -1=default, -2=no sound)
' freq   : Output sample rate
' flags:     BASS_DEVICE_xxx flags
' win:       Owner window

' NOTE: The "no sound" device (device=-2), allows loading
' and "playing" of MOD musics only (all sample/stream
' functions and most other functions fail). This is so
' that you can still use the MOD musics as synchronizers
' when there is no soundcard present. When using device -2,
' you should still set the other arguments as you would do
' normally.
Declare Function BASS_Init Lib "bass.dll" (ByVal device As Integer, ByVal freq As Long, ByVal flags As Long, ByVal win As Long) As Integer

' Free all resources used by the digital output, including  all musics and samples.
Declare Sub BASS_Free Lib "bass.dll" ()

' Retrieve a pointer to a DirectSound interface. This can be used by
' advanced users to "plugin" external functionality.
' object : The interface to retrieve (BASS_OBJECT_xxx)
' RETURN : A pointer to the requested interface (NULL=error)
Declare Sub BASS_GetDSoundObject Lib "bass.dll" (ByRef object As Long)

' Retrieve some information on the device being used.
' info   : Pointer to store info at
Declare Sub BASS_GetInfo Lib "bass.dll" (ByRef info As BASS_INFO)

' Get the current CPU usage of BASS. This includes the time taken to mix
' the MOD musics and sample streams, and also the time taken by any user
' DSP functions. It does not include plain sample mixing which is done by
' the output device (hardware accelerated) or DirectSound (emulated). Audio
' CD playback requires no CPU usage.
' RETURN : The CPU usage percentage (floating-point)
Declare Function BASS_GetCPU Lib "bass.dll" () As Single

' Start the digital output.
Declare Function BASS_Start Lib "bass.dll" () As Integer

' Stop the digital output, stopping all musics/samples/streams.
Declare Function BASS_Stop Lib "bass.dll" () As Integer

' Stop the digital output, pausing all musics/samples/
' streams. Use BASS_Start to resume the digital output.
Declare Function BASS_Pause Lib "bass.dll" () As Integer

' Set the digital output master volume.
' volume : Desired volume level (0-100)
Declare Function BASS_SetVolume Lib "bass.dll" (ByVal volume As Long) As Integer

' Get the digital output master volume.
' RETURN : The volume level (0-100, -1=error)
Declare Function BASS_GetVolume Lib "bass.dll" () As Long

' Set the factors that affect the calculations of 3D sound.
' distf  : Distance factor (0.0-10.0, 1.0=use meters, 0.3=use feet, <0.0=leave current)
'          By default BASS measures distances in meters, you can change this
'          setting if you are using a different unit of measurement.
' roolf  : Rolloff factor, how fast the sound quietens with distance
'          (0.0=no rolloff, 1.0=real world, 2.0=2x real... 10.0=max, <0.0=leave current)
' doppf  : Doppler factor (0.0=no doppler, 1.0=real world, 2.0=2x real... 10.0=max, <0.0=leave current)
'          The doppler effect is the way a sound appears to change frequency when it is
'          moving towards or away from you. The listener and sound velocity settings are
'          used to calculate this effect, this "doppf" value can be used to lessen or
'          exaggerate the effect.
Declare Function BASS_Set3DFactors Lib "bass.dll" (ByVal distf As Single, ByVal rollf As Single, ByVal doppf As Single) As Integer

' Get the factors that affect the calculations of 3D sound.
' distf  : Distance factor (NULL=don't get it)
' roolf  : Rolloff factor (NULL=don't get it)
' doppf  : Doppler factor (NULL=don't get it)
Declare Function BASS_Get3DFactors Lib "bass.dll" (ByRef distf As Single, ByRef rollf As Single, doppf As Single) As Integer

' Set the position/velocity/orientation of the listener (ie. the player/viewer).
' pos    : Position of the listener (NULL=leave current)
' vel    : listener 's velocity, used to calculate doppler effect (NULL=leave current)
' front  : Direction that listener's front is pointing (NULL=leave current)
' top    : Direction that listener's top is pointing (NULL=leave current)
' NOTE   : front & top must both be set in a single call
Declare Function BASS_Set3DPosition Lib "bass.dll" (ByRef pos As Any, ByRef vel As Any, ByRef front As Any, ByRef top As Any) As Integer

' Get the position/velocity/orientation of the listener.
' pos    : Position of the listener (NULL=don't get it)
' vel    : listener 's velocity (NULL=don't get it)
' front  : Direction that listener's front is pointing (NULL=don't get it)
' top    : Direction that listener's top is pointing (NULL=don't get it)
' NOTE   : front & top must both be retrieved in a single call
Declare Function BASS_Get3DPosition Lib "bass.dll" (ByRef pos As Any, ByRef vel As Any, ByRef front As Any, ByRef top As Any) As Integer

' Apply changes made to the 3D system. This must be called to apply any changes
' made with BASS_Set3DFactors, BASS_Set3DPosition, BASS_ChannelSet3DAttributes or
' BASS_ChannelSet3DPosition. It improves performance to have DirectSound do all the
' required recalculating at the same time like this, rather than recalculating after
' every little change is made. NOTE: This is automatically called when starting a 3D
' sample with BASS_SamplePlay3D/Ex.
Declare Function BASS_Apply3D Lib "bass.dll" () As Integer

' Set the type of EAX environment and it's parameters. Obviously, EAX functions
' have no effect if no EAX supporting device (ie. SB Live) is used.
' env    : Reverb environment (EAX_ENVIRONMENT_xxx, -1=leave current)
' vol    : Volume of the reverb (0.0=off, 1.0=max, <0.0=leave current)
' decay  : Time in seconds it takes the reverb to diminish by 60dB (0.1-20.0, <0.0=leave current)
' damp   : The damping, high or low frequencies decay faster (0.0=high decays quickest,
'          1.0=low/high decay equally, 2.0=low decays quickest, <0.0=leave current)
Declare Function BASS_SetEAXParameters Lib "bass.dll" (ByVal env As Long, ByVal vol As Single, ByVal decay As Single, ByVal damp As Single) As Integer

' Get the current EAX parameters.
' env    : Reverb environment (NULL=don't get it)
' vol    : Reverb volume (NULL=don't get it)
' decay  : Decay duration (NULL=don't get it)
' damp   : The damping (NULL=don't get it)
Declare Function BASS_GetEAXParameters Lib "bass.dll" (ByRef env As Long, ByRef vol As Single, ByRef decay As Single, ByRef damp As Single) As Integer

' Set the A3D resource management mode.
' mode   : The mode (A3D_RESMODE_OFF=disable resource management,
' A3D_RESMODE_DYNAMIC = enable resource manager but looping channels are not managed,
' A3D_RESMODE_DYNAMIC_LOOPERS = enable resource manager including looping channels,
' A3D_RESMODE_NOTIFY = plays will fail when there are no available resources)
Declare Function BASS_SetA3DResManager Lib "bass.dll" (ByVal mode As Long) As Integer

' Get the A3D resource management mode.
' RETURN : The mode (0xffffffff=error)
Declare Function BASS_GetA3DResManager Lib "bass.dll" () As Long

' Set the A3D high frequency absorbtion factor.
' factor  : Absorbtion factor (0.0=disabled, <1.0=diminished, 1.0=default,
'           >1.0=exaggerated)
Declare Function BASS_SetA3DHFAbsorbtion Lib "bass.dll" (ByVal factor As Single) As Integer

' Retrieve the current A3D high frequency absorbtion factor.
' factor  : The absorbtion factor
Declare Function BASS_GetA3DHFAbsorbtion Lib "bass.dll" (ByRef factor As Single) As Integer

' Load a music (MO3/XM/MOD/S3M/IT/MTM). The amplification and pan
' seperation are initially set to 50, use BASS_MusicSetAmplify()
' and BASS_MusicSetPanSep() to adjust them.
' mem    : BASSTRUE = Load music from memory
' f      : Filename (mem=BASSFALSE) or memory location (mem=BASSTRUE)
' offset : File offset to load the music from (only used if mem=BASSFALSE)
' length : Data length (only used if mem=BASSFALSE, 0=use to end of file)
' flags  :     BASS_MUSIC_xxx flags
' RETURN : The loaded music's handle (NULL=error)
Declare Function BASS_MusicLoad Lib "bass.dll" (ByVal mem As Integer, ByVal f As Any, ByVal offset As Long, ByVal length As Long, ByVal flags As Long) As Long

'  Free a music's resources. handle =  Music handle
Declare Sub BASS_MusicFree Lib "bass.dll" (ByVal handle As Long)

' Retrieves a music's name.
' handle :  Music handle
' Return : The Music 's name (NULL=error)
Declare Function BASS_MusicGetName Lib "bass.dll" (ByVal handle As Long) As String

' Retrieves the length of a music in patterns (ie. how many "orders"
' there are).
' handle :  Music handle
' RETURN : The length of the music (0xFFFFFFFF=error)
Declare Function BASS_MusicGetLength Lib "bass.dll" (ByVal handle As Long) As Long

' Play a music. Playback continues from where it was last stopped/paused.
' Multiple musics may be played simultaneously.
' handle : Handle of music to play
Declare Function BASS_MusicPlay Lib "bass.dll" (ByVal handle As Long) As Integer

' Play a music, specifying start position and playback flags.
' handle : Handle of music to play
' pos    : Position to start playback from, LOWORD=order HIWORD=row
' flags  : BASS_MUSIC_xxx flags. These flags overwrite the defaults
'          specified when the music was loaded. (-1=use current flags)
' reset  : BASSTRUE = Stop all current playing notes and reset bpm/etc...
Declare Function BASS_MusicPlayEx Lib "bass.dll" (ByVal handle As Long, ByVal pos As Long, ByVal flags As Long, ByVal reset As Integer) As Integer

' Set a music's amplification level.
' handle:    Music handle
' amp:       Amplification Level(0 - 100)
Declare Function BASS_MusicSetAmplify Lib "bass.dll" (ByVal handle As Long, amp As Long) As Integer

' Set a music's pan seperation.
' handle:    Music handle
' pan:       pan seperation(0 - 100, 50 = linear)
Declare Function BASS_MusicSetPanSep Lib "bass.dll" (ByVal handle As Long, pan As Long) As Integer

' Set a music's "GetPosition" scaler
' When you call BASS_ChannelGetPosition, the "row" (HIWORD) will be
' scaled by this value. By using a higher scaler, you can get a more
' precise position indication.
' handle:    Music handle
' Scale: The scaler(1 - 256)
Declare Function BASS_MusicSetPositionScaler Lib "bass.dll" (ByVal handle As Long, ByVal pscale As Long) As Integer

' Load a WAV sample. If you're loading a sample with 3D functionality,
' then you should use BASS_GetInfo and BASS_SetInfo to set the default 3D
' parameters. You can also use these two functions to set the sample's
' default frequency/volume/pan/looping.
' mem    : BASSTRUE = Load sample from memory
' f      : Filename (mem=BASSFALSE) or memory location (mem=BASSTRUE)
' offset : File offset to load the sample from (only used if mem=BASSFALSE)
' length : Data length (only used if mem=BASSFALSE, 0=use to end of file)
' max    : Maximum number of simultaneous playbacks (1-65535)
' flags  : BASS_SAMPLE_xxx flags (only the LOOP/3D/SOFTWARE/DEFER/MUTEMAX/OVER_xxx flags are used)
' RETURN : The loaded sample's handle (NULL=error)
Declare Function BASS_SampleLoad Lib "bass.dll" (ByVal mem As Integer, ByVal f As Any, ByVal offset As Long, ByVal length As Long, ByVal max As Long, ByVal flags As Long) As Long

' Create a sample. This function allows you to generate custom samples, or
' load samples that are not in the WAV format. A pointer is returned to the
' memory location at which you should write the sample's data. After writing
' the data, call BASS_SampleCreateDone to get the new sample's handle.
' length:    The sample 's length (in samples, NOT bytes)
' freq   : default sample rate
' max    : Maximum number of simultaneous playbacks (1-65535)
' flags:     BASS_SAMPLE_xxx flags
' RETURN : Memory location to write the sample's data (NULL=error)
Declare Function BASS_SampleCreate Lib "bass.dll" (ByVal length As Long, ByVal freq As Long, ByVal max As Long, ByVal flags As Long) As Long

' Finished creating a new sample.
' Return: The New sample 's handle (NULL=error)
Declare Function BASS_SampleCreateDone Lib "bass.dll" () As Long

' Free a sample's resources.
' handle:    Sample handle
Declare Sub BASS_SampleFree Lib "bass.dll" (ByVal handle As Long)

' Retrieve a sample's current default attributes.
' handle:    Sample handle
' info   : Pointer to store sample info
Declare Function BASS_SampleGetInfo Lib "bass.dll" (ByVal handle As Long, ByRef info As BASS_SAMPLE) As Integer

'Set a sample's default attributes.
' handle:    Sample handle
' info   : Sample info, only the freq/volume/pan/3D attributes and
'          looping/override method flags are used
Declare Function BASS_SampleSetInfo Lib "bass.dll" (ByVal handle As Long, ByRef info As BASS_SAMPLE) As Integer

' Play a sample, using the sample's default attributes.
' handle : Handle of sample to play
' RETURN : Handle of channel used to play the sample (NULL=error)
Declare Function BASS_SamplePlay Lib "bass.dll" (ByVal handle As Long) As Long

' Play a sample, using specified attributes.
' handle : Handle of sample to play
' start  : Playback start position (in samples, not bytes)
' freq:      Playback Rate(-1 = Default)
' volume : Volume (-1=default, 0=silent, 100=max)
' pan:       pan position(-101 = Default, -100 = Left, 0 = middle, 100 = Right)
' loop   : 1 = Loop sample (-1=default)
' RETURN : Handle of channel used to play the sample (NULL=error)
Declare Function BASS_SamplePlayEx Lib "bass.dll" (ByVal handle As Long, ByVal start As Long, ByVal freq As Long, ByVal volume As Long, ByVal pan As Long, ByVal pLoop As Integer) As Long

' Play a 3D sample, setting it's 3D position, orientation and velocity.
' handle : Handle of sample to play
' pos    : position of the sound (NULL = x/y/z=0.0)
' orient : orientation of the sound, this is irrelevant if it's an
'          omnidirectional sound source (NULL = x/y/z=0.0)
' vel    : velocity of the sound (NULL = x/y/z=0.0)
' RETURN : Handle of channel used to play the sample (NULL=error)
Declare Function BASS_SamplePlay3D Lib "bass.dll" (ByVal handle As Long, ByRef pos As Any, ByRef orient As Any, ByRef vel As Any) As Long

' Play a 3D sample, using specified attributes.
' handle : Handle of sample to play
' pos    : position of the sound (NULL = x/y/z=0.0)
' orient : orientation of the sound, this is irrelevant if it's an
'          omnidirectional sound source (NULL = x/y/z=0.0)
' vel    : velocity of the sound (NULL = x/y/z=0.0)
' start  : Playback start position (in samples, not bytes)
' freq:      Playback Rate(-1 = Default)
' volume : Volume (-1=default, 0=silent, 100=max)
' loop   : 1 = Loop sample (-1=default)
' RETURN : Handle of channel used to play the sample (NULL=error)
Declare Function BASS_SamplePlay3DEx Lib "bass.dll" (ByVal handle As Long, ByRef pos As Any, ByRef orient As Any, ByRef vel As Any, ByVal start As Long, ByVal freq As Long, ByVal volume As Long, ByVal pLoop As Integer) As Long

' Stops all instances of a sample. For example, if a sample is playing
' simultaneously 3 times, calling this function will stop all 3 of them,
' which is obviously simpler than calling BASS_ChannelStop() 3 times.
' handle : Handle of sample to stop
Declare Function BASS_SampleStop Lib "bass.dll" (ByVal handle As Long) As Integer

' Create a user sample stream.
' freq   : Stream playback rate
' flags  : BASS_SAMPLE_xxx flags (only the 8BITS/MONO/3D flags are used)
' proc   : User defined stream writing function pass using "AddressOf STREAMPROC"
' RETURN : The created stream's handle (NULL=error)
Declare Function BASS_StreamCreate Lib "bass.dll" (ByVal freq As Long, ByVal flags As Long, ByRef proc As Long, ByVal user As Long) As Long

' Create a sample stream from an MP3 or WAV file.
' mem    : BASSTRUE = Stream file from memory
' f      : Filename (mem=BASSFALSE) or memory location (mem=BASSTRUE)
' offset : File offset of the stream data
' length : File length (0=use whole file if mem=BASSFALSE)
' flags  : BASS_SAMPLE_3D and/or BASS_MP3_LOWQ flags
' user   : The 'user' value passed to the callback function
' RETURN : The created stream's handle (NULL=error)
Declare Function BASS_StreamCreateFile Lib "bass.dll" (ByVal mem As Integer, ByVal f As Any, ByVal offset As Long, ByVal length As Long, ByVal flags As Long) As Long

' Free a sample stream's resources.
' stream:    stream handle
Declare Sub BASS_StreamFree Lib "bass.dll" (ByVal handle As Long)

' Retrieves the playback length (in bytes) of a file stream. It's not always
' possible to 100% accurately guess the length of a stream, so the length returned
' may be only an approximation when using some WAV codecs.
' handle :  Stream handle
' RETURN : The length (0xffffffff=error)
Declare Function BASS_StreamGetLength Lib "bass.dll" (ByVal handle As Long) As Long

' Retrieves the playback length (in bytes) of a block in a file stream.
' handle :  Stream handle
' RETURN : The block length (0xffffffff=error)
Declare Function BASS_StreamGetBlockLength Lib "bass.dll" (ByVal handle As Long) As Long

' Play a sample stream, optionally flushing the buffer first.
' handle : Handle of stream to play
' flush  : Flush buffer contents. If you stop a stream and then want to
'          continue it from where it stopped, don't flush it. Flushing
'          a file stream causes it to restart from the beginning.
' flags  : BASS_SAMPLE_xxx flags (only affects file streams, and only the
'          LOOP flag is used)
Declare Function BASS_StreamPlay Lib "bass.dll" (ByVal handle As Long, ByVal flush As Integer, ByVal flags As Long) As Integer

' Initialize the CD functions, must be called before any other CD
' functions. The volume is initially set to 100 (the maximum), use
' BASS_ChannelSetAttributes() to adjust it.
' drive  : The CD drive, for example: "d:" (NULL=use default drive)
Declare Function BASS_CDInit Lib "bass.dll" (ByVal drive As Any) As Integer

' Free resources used by the CD
Declare Sub BASS_CDFree Lib "bass.dll" ()

' Check if there is a CD in the drive.
' RETURN : 1 if cd in drive, 0 if not.
Declare Function BASS_CDInDrive Lib "bass.dll" () As Long

' Play a CD track.
' track  : Track number to play (1=first)
' loop   : BASSTRUE = Loop the track
' wait   : BASSTRUE = don't return until playback has started
'          (some drives will always wait anyway)
Declare Function BASS_CDPlay Lib "bass.dll" (ByVal track As Long, ByVal pLoop As Integer, ByVal wait As Integer) As Integer

'*************************************************************************
'* A "channel" can be a playing sample (HCHANNEL), a MOD music (HMUSIC), *
'* a sample stream (HSTREAM), or the CD (CDCHANNEL). The following       *
'* functions can be used with one or more of these channel types.        *
'*************************************************************************

' Check if a channel is active (playing).
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
' Returns : BASSTRUE if active, BASSFALSE if inactive
Declare Function BASS_ChannelIsActive Lib "bass.dll" (ByVal handle As Long) As Integer

' Get some info about a channel.
' handle:    channel handle(HCHANNEL / HMUSIC / HSTREAM)
' RETURN : BASS_SAMPLE_xxx flags (0xffffffff=error)
Declare Function BASS_ChannelGetFlags Lib "bass.dll" (ByVal handle As Long) As Long

' Stop a channel.
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
Declare Function BASS_ChannelStop Lib "bass.dll" (ByVal handle As Long) As Integer

' Pause a channel.
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
Declare Function BASS_ChannelPause Lib "bass.dll" (ByVal handle As Long) As Integer

' Resume a paused channel.
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
Declare Function BASS_ChannelResume Lib "bass.dll" (ByVal handle As Long) As Integer

' Update a channel's attributes. The actual setting may not be exactly
' as specified, depending on the accuracy of the device and drivers.
' NOTE: Only the volume can be adjusted for the CD "channel", but not all
' soundcards allow controlling of the CD volume level.
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
' freq   : Playback rate (-1=leave current)
' volume : Volume (-1=leave current, 0=silent, 100=max)
' pan    : pan position(-101 = current, -100 = Left, 0 = middle, 100 = Right)
'          panning has no effect on 3D channels
Declare Function BASS_ChannelSetAttributes Lib "bass.dll" (ByVal handle As Long, ByVal freq As Long, ByVal volume As Long, ByVal pan As Long) As Integer

' Retrieve a channel's attributes. Only the volume is available for
' the CD "channel" (if allowed by the soundcard/drivers).
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
' freq   : Pointer to store playback rate (NULL=don't retrieve it)
' volume : Pointer to store volume (NULL=don't retrieve it)
' pan    : Pointer to store pan position (NULL=don't retrieve it)
Declare Function BASS_ChannelGetAttributes Lib "bass.dll" (ByVal handle As Long, ByRef freq As Long, ByRef volume As Long, ByRef pan As Long) As Integer

' Set a channel's 3D attributes.
' handle : channel handle(HCHANNEL / HSTREAM / HMUSIC)
' mode   : BASS_3DMODE_xxx mode (-1=leave current setting)
' min    : minimum distance, volume stops increasing within this distance (<0.0=leave current)
' max    : maximum distance, volume stops decreasing past this distance (<0.0=leave current)
' iangle : angle of inside projection cone in degrees (360=omnidirectional, -1=leave current)
' oangle : angle of outside projection cone in degrees (-1=leave current)
'          NOTE: iangle & oangle must both be set in a single call
' outvol : delta-volume outside the projection cone (0=silent, 100=same as inside)
' The iangle/oangle angles decide how wide the sound is projected around the
' orientation angle. Within the inside angle the volume level is the channel
' level as set with BASS_ChannelSetAttributes, from the inside to the outside
' angles the volume gradually changes by the "outvol" setting.
Declare Function BASS_ChannelSet3DAttributes Lib "bass.dll" (ByVal handle As Long, ByVal mode As Long, ByVal min As Single, ByVal max As Single, ByVal iangle As Long, ByVal oangle As Long, ByVal outvol As Long) As Integer

' Retrieve a channel's 3D attributes.
' handle : channel handle(HCHANNEL / HSTREAM / HMUSIC)
' mode   : BASS_3DMODE_xxx mode (NULL=don't retrieve it)
' min    : minumum distance (NULL=don't retrieve it)
' max    : maximum distance (NULL=don't retrieve it)
' iangle : angle of inside projection cone (NULL=don't retrieve it)
' oangle : angle of outside projection cone (NULL=don't retrieve it)
'          NOTE: iangle & oangle must both be retrieved in a single call
' outvol : delta-volume outside the projection cone (NULL=don't retrieve it)
Declare Function BASS_ChannelGet3DAttributes Lib "bass.dll" (ByVal handle As Long, ByRef mode As Long, ByRef min As Single, ByRef max As Single, ByRef iangle As Long, ByRef oangle As Long, ByRef outvol As Long) As Integer

' Update a channel's 3D position, orientation and velocity. The velocity
' is only used to calculate the doppler effect.
' handle : channel handle(HCHANNEL / HSTREAM / HMUSIC)
' pos    : position of the sound (NULL=leave current)
' orient : orientation of the sound, this is irrelevant if it's an
'          omnidirectional sound source (NULL=leave current)
' vel    : velocity of the sound (NULL=leave current)
Declare Function BASS_ChannelSet3DPosition Lib "bass.dll" (ByVal handle As Long, ByRef pos As Any, ByRef orient As Any, ByRef vel As Any) As Integer

' Retrieve a channel's current 3D position, orientation and velocity.
' handle : channel handle(HCHANNEL / HSTREAM / HMUSIC)
' pos    : position of the sound (NULL=don't retrieve it)
' orient : orientation of the sound, this is irrelevant if it's an
'          omnidirectional sound source (NULL=don't retrieve it)
' vel    : velocity of the sound (NULL=don't retrieve it)
Declare Function BASS_ChannelGet3DPosition Lib "bass.dll" (ByVal handle As Long, ByRef pos As Any, ByRef orient As Any, ByRef vel As Any) As Integer

' Set the current playback position of a channel.
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
' pos    : the position
'          if HCHANNEL: position in bytes
'          if HMUSIC: LOWORD=order HIWORD=row ... use MAKELONG(order,row)
'          if HSTREAM: position in bytes, file streams (WAV/MP3) only (MP3s require BASS_MP3_SETPOS)
'          if CDCHANNEL: position in milliseconds from start of track
Declare Function BASS_ChannelSetPosition Lib "bass.dll" (ByVal handle As Long, ByVal pos As Long) As Integer

' Get the current playback position of a channel.
' handle : Channel handle (HCHANNEL/HMUSIC/HSTREAM, or CDCHANNEL)
' RETURN : the position (0xffffffff=error)
'          if HCHANNEL: position in bytes
'          if HMUSIC: LOWORD=order HIWORD=row (use GetLoWord(position), GetHiWord(Position))
'          if HSTREAM: total bytes played since the stream was last flushed
'          if CDCHANNEL: position in milliseconds from start of track
Declare Function BASS_ChannelGetPosition Lib "bass.dll" (ByVal handle As Long) As Long

' Calculate a channel's current output level.
' handle : channel handle(HMUSIC / HSTREAM)
' RETURN : LOWORD=left level (0-128) HIWORD=right level (0-128) (0xffffffff=error)
'          Use GetLoWord and GetHiWord functions on return function.
Declare Function BASS_ChannelGetLevel Lib "bass.dll" (ByVal handle As Long) As Long

' Retrieves upto "length" bytes of the channel's current sample data. This is
' useful if you wish to "visualize" the sound.
' handle:  Channel handle(HMUSIC / HSTREAM)
' buffer : Location to write the sample data
' length : Number of bytes wanted
' RETURN : Number of bytes actually written to the buffer (0xffffffff=error) */
Declare Function BASS_ChannelGetData Lib "bass.dll" (ByVal handle As Long, ByRef buffer As Any, ByVal length As Long) As Long

' Setup a sync on a channel. Multiple syncs may be used per channel.
' handle : Channel handle (currently there are only HMUSIC syncs)
' atype  : Sync type (BASS_SYNC_xxx type & flags)
' param  : Sync parameters (see the BASS_SYNC_xxx type description)
' proc   : User defined callback function (use AddressOf SYNCPROC)
' user   : The 'user' value passed to the callback function
' Return : Sync handle(Null = Error)
Declare Function BASS_ChannelSetSync Lib "bass.dll" (ByVal handle As Long, ByVal param As Long, ByRef proc As Long, ByVal user As Long) As Long

' Remove a sync from a channel
' handle : channel handle(HMUSIC)
' sync   : Handle of sync to remove
Declare Function BASS_ChannelRemoveSync Lib "bass.dll" (ByVal handle As Long, sync As Long) As Integer

' Setup a user DSP function on a channel. When multiple DSP functions
' are used on a channel, they are called in the order that they were added.
' handle:  channel handle(HMUSIC / HSTREAM)
' proc   : User defined callback function
' user   : The 'user' value passed to the callback function
' RETURN : DSP handle (NULL=error)
Declare Function BASS_ChannelSetDSP Lib "bass.dll" (ByVal handle As Long, ByRef proc As Long, ByVal user As Long) As Long

' Remove a DSP function from a channel
' handle : channel handle(HMUSIC / HSTREAM)
' dsp    : Handle of DSP to remove */
' RETURN : BASSTRUE / BASSFALSE
Declare Function BASS_ChannelRemoveDSP Lib "bass.dll" (ByVal handle As Long, ByVal dsp As Long) As Integer

' Set the wet(reverb)/dry(no reverb) mix ratio on the channel. By default
' the distance of the sound from the listener is used to calculate the mix.
' NOTE: The channel must have 3D functionality enabled for the EAX environment
' to have any affect on it.
' handle : channel handle(HCHANNEL / HSTREAM / HMUSIC)
' mix    : The ratio (0.0=reverb off, 1.0=max reverb, -1.0=let EAX calculate
'          the reverb mix based on the distance)
Declare Function BASS_ChannelSetEAXMix Lib "bass.dll" (ByVal handle As Long, ByVal mix As Single) As Integer

' Get the wet(reverb)/dry(no reverb) mix ratio on the channel.
' handle:    channel handle(HCHANNEL / HSTREAM / HMUSIC)
' mix    : Pointer to store the ratio at
Declare Function BASS_ChannelGetEAXMix Lib "bass.dll" (ByVal handle As Long, ByRef mix As Single) As Integer
Function STREAMPROC(ByVal handle As Long, ByRef buffer As Long, ByVal length As Long, ByVal user As Long) As Long
    
    'CALLBACK FUNCTION !!!
    
    'In here you can write a function to write out to a file, or send over the
    'internet etc, and stream into a BASS Buffer on the client, its up to you.
    'This function must return the number of bytes written out, so that BASS,
    'knows where to carry on sending from.

    ' NOTE: A stream function should obviously be as quick
    ' as possible, other streams (and MOD musics) can't be mixed until it's finished.
    ' handle : The stream that needs writing
    ' buffer : Buffer to write the samples in
    ' length : Number of bytes to write
    ' user   : The 'user' parameter value given when calling BASS_StreamCreate
    ' RETURN : Number of bytes written. If less than "length" then the
    '          stream is assumed to be at the end, and is stopped.
    
End Function
Sub SYNCPROC(ByVal handle As Long, ByVal channel As Long, ByVal data As Long, ByVal user As Long)
    
    'CALLBACK FUNCTION !!!
    
    'Similarly in here, write what to do when sync function
    'is called, i.e screen flash etc.
    
    ' NOTE: a sync callback function should be very
    ' quick (eg. just posting a message) as other syncs cannot be processed
    ' until it has finished.
    ' handle : The sync that has occured
    ' channel: Channel that the sync occured in
    ' data   : Additional data associated with the sync's occurance
    ' user   : The 'user' parameter given when calling BASS_ChannelSetSync */
    
End Sub
Sub DSPPROC(ByVal handle As Long, ByVal channel As Long, ByRef buffer As Long, ByVal length As Long, ByVal user As Long)

    'CALLBACK FUNCTION !!!

    ' DSP callback function. NOTE: A DSP function should obviously be as quick as
    ' possible... other DSP functions, streams and MOD musics can not be processed
    ' until it's finished.
    ' handle : The DSP handle
    ' channel: Channel that the DSP is being applied to
    ' buffer : Buffer to apply the DSP to
    ' length : Number of bytes in the buffer
    ' user   : The 'user' parameter given when calling BASS_ChannelSetDSP
    
End Sub
Function BASS_SetEAXParametersVB(Preset) As Integer
' This function is a workaround, because VB doesn't support multiple comma seperated
' paramaters for each Global Const, simply pass the EAX_PRESET_XXXX value to this function
' instead of BASS_SetEasParamaets as you would to in C++
Select Case Preset
    Case EAX_PRESET_GENERIC
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_GENERIC, 0.5, 1.493, 0.5)
    Case EAX_PRESET_PADDEDCELL
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_PADDEDCELL, 0.25, 0.1, 0)
    Case EAX_PRESET_ROOM
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_ROOM, 0.417, 0.4, 0.666)
    Case EAX_PRESET_BATHROOM
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_BATHROOM, 0.653, 1.499, 0.166)
    Case EAX_PRESET_LIVINGROOM
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_LIVINGROOM, 0.208, 0.478, 0)
    Case EAX_PRESET_STONEROOM
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_STONEROOM, 0.5, 2.309, 0.888)
    Case EAX_PRESET_AUDITORIUM
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_AUDITORIUM, 0.403, 4.279, 0.5)
    Case EAX_PRESET_CONCERTHALL
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_CONCERTHALL, 0.5, 3.961, 0.5)
    Case EAX_PRESET_CAVE
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_CAVE, 0.5, 2.886, 1.304)
    Case EAX_PRESET_ARENA
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_ARENA, 0.361, 7.284, 0.332)
    Case EAX_PRESET_HANGAR
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_HANGAR, 0.5, 10, 0.3)
    Case EAX_PRESET_CARPETEDHALLWAY
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_CARPETEDHALLWAY, 0.153, 0.259, 2)
    Case EAX_PRESET_HALLWAY
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_HALLWAY, 0.361, 1.493, 0)
    Case EAX_PRESET_STONECORRIDOR
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_STONECORRIDOR, 0.444, 2.697, 0.638)
    Case EAX_PRESET_ALLEY
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_ALLEY, 0.25, 1.752, 0.776)
    Case EAX_PRESET_FOREST
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_FOREST, 0.111, 3.145, 0.472)
    Case EAX_PRESET_CITY
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_CITY, 0.111, 2.767, 0.224)
    Case EAX_PRESET_MOUNTAINS
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_MOUNTAINS, 0.194, 7.841, 0.472)
    Case EAX_PRESET_QUARRY
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_QUARRY, 1, 1.499, 0.5)
    Case EAX_PRESET_PLAIN
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_PLAIN, 0.097, 2.767, 0.224)
    Case EAX_PRESET_PARKINGLOT
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_PARKINGLOT, 0.208, 1.652, 1.5)
    Case EAX_PRESET_SEWERPIPE
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_SEWERPIPE, 0.652, 2.886, 0.25)
    Case EAX_PRESET_UNDERWATER
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_UNDERWATER, 1, 1.499, 0)
    Case EAX_PRESET_DRUGGED
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_DRUGGED, 0.875, 8.392, 1.388)
    Case EAX_PRESET_DIZZY
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_DIZZY, 0.139, 17.234, 0.666)
    Case EAX_PRESET_PSYCHOTIC
        BASS_SetEAXParametersVB = BASS_SetEAXParameters(EAX_ENVIRONMENT_PSYCHOTIC, 0.486, 7.563, 0.806)
End Select
End Function
Function BASS_GetStringVersion() As String
'This function will return the string version
'of the BASS DLL. For example the provided function within the DLL
'"BASS_GetVersion" will return 393216, whereas this function works
'out the actual version string as you would need to see it.
BASS_GetStringVersion = Trim(Str(GetLoWord(BASS_GetVersion))) & "." & Trim(Str(GetHiWord(BASS_GetVersion)))
End Function

Public Function GetHiWord(lparam As Long) As Long
' This is the HIWORD of the lParam:
GetHiWord = lparam \ &H10000 And &HFFFF&
End Function
Public Function GetLoWord(lparam As Long) As Long
' This is the LOWORD of the lParam:
GetLoWord = lparam And &HFFFF&
End Function

Public Function BASS_GetErrorDescription(ErrorCode As Long) As String
Select Case ErrorCode
    Case BASS_OK
        BASS_GetErrorDescription = "All is OK"
    Case BASS_ERROR_MEM
        BASS_GetErrorDescription = "Memory Error"
    Case BASS_ERROR_FILEOPEN
        BASS_GetErrorDescription = "Can't Open the File"
    Case BASS_ERROR_DRIVER
        BASS_GetErrorDescription = "Can't Find a Free Sound Driver"
    Case BASS_ERROR_BUFLOST
        BASS_GetErrorDescription = "The Sample Buffer Was Lost - Please Report This!"
    Case BASS_ERROR_HANDLE
        BASS_GetErrorDescription = "Invalid Handle"
    Case BASS_ERROR_FORMAT
        BASS_GetErrorDescription = "Unsupported Format"
    Case BASS_ERROR_POSITION
        BASS_GetErrorDescription = "Invalid Playback Position"
    Case BASS_ERROR_INIT
        BASS_GetErrorDescription = "BASS_Init Has Not Been Successfully Called"
    Case BASS_ERROR_START
        BASS_GetErrorDescription = "BASS_Start Has Not Been Successfully Called"
    Case BASS_ERROR_INITCD
        BASS_GetErrorDescription = "Can't Initialize CD"
    Case BASS_ERROR_CDINIT
        BASS_GetErrorDescription = "BASS_CDInit Has Not Been Successfully Called"
    Case BASS_ERROR_NOCD
        BASS_GetErrorDescription = "No CD in drive"
    Case BASS_ERROR_CDTRACK
        BASS_GetErrorDescription = "Can't Play the Selected CD Track"
    Case BASS_ERROR_ALREADY
        BASS_GetErrorDescription = "Already Initialized"
    Case BASS_ERROR_CDVOL
        BASS_GetErrorDescription = "CD Has No Volume Control"
    Case BASS_ERROR_NOPAUSE
        BASS_GetErrorDescription = "Not Paused"
    Case BASS_ERROR_NOTAUDIO
        BASS_GetErrorDescription = "Not An Audio Track"
    Case BASS_ERROR_NOCHAN
        BASS_GetErrorDescription = "Can't Get a Free Channel"
    Case BASS_ERROR_ILLTYPE
        BASS_GetErrorDescription = "An Illegal Type Was Specified"
    Case BASS_ERROR_ILLPARAM
        BASS_GetErrorDescription = "An Illegal Parameter Was Specified"
    Case BASS_ERROR_NO3D
        BASS_GetErrorDescription = "No 3D Support"
    Case BASS_ERROR_NOEAX
        BASS_GetErrorDescription = "No EAX Support"
    Case BASS_ERROR_DEVICE
        BASS_GetErrorDescription = "Illegal Device Number"
    Case BASS_ERROR_NOPLAY
        BASS_GetErrorDescription = "Not Playing"
    Case BASS_ERROR_FREQ
        BASS_GetErrorDescription = "Illegal Sample Rate"
    Case BASS_ERROR_NOA3D
        BASS_GetErrorDescription = "A3D.DLL is Not Installed"
    Case BASS_ERROR_NOTFILE
        BASS_GetErrorDescription = "The Stream is Not a File Stream (WAV/MP3)"
    Case BASS_ERROR_NOHW
        BASS_GetErrorDescription = "No Hardware Voices Available"
    Case BASS_ERROR_UNKNOWN
        BASS_GetErrorDescription = "Some Other Mystery Error"
End Select
End Function

Function MakeLong(LoWord As Long, HiWord As Long) As Long
'Replacement for the c++ Function MAKELONG
'You need this to pass values to certain function calls.
'i.e BASS_ChannelSetPosition needs to pass a value
'using make long, i.e BASS_ChannelSetPosition Handle,MakeLong(Order,Row)
MakeLong = LoWord Or LShift(HiWord, 16)
End Function


Public Function LShift(ByVal lValue As Long, ByVal lNumberOfBitsToShift As Long) As Long
    Const ksCallname As String = "LShift"
    On Error GoTo Procedure_Error
    LShift = lValue * (2 ^ lNumberOfBitsToShift)
    
Procedure_Exit:
    Exit Function
    
Procedure_Error:
    Err.Raise Err.Number, ksCallname, Err.Description, Err.HelpFile, Err.HelpContext
    Resume Procedure_Exit
End Function

Public Function RShift(ByVal lValue As Long, ByVal lNumberOfBitsToShift As Long) As Long

    Const ksCallname As String = "RShift"
    On Error GoTo Procedure_Error
    RShift = lValue \ (2 ^ lNumberOfBitsToShift)
    
Procedure_Exit:
    Exit Function
    
Procedure_Error:
    Err.Raise Err.Number, ksCallname, Err.Description, Err.HelpFile, Err.HelpContext
    Resume Procedure_Exit
End Function


