Unit PakMem; { Muziek libje

  Hier word de GDM engine geinit en gebruikt

{-=-=-=-=--=-=-=-=-=-} interface
Uses Mse_Tp, PakMeE, PakMeI, PkmForm;

Type tMusicEng = object
       Private
         EMSFlag : Word;
         Header : GDMHeader;
         SoundCardName : String;
         DMA, IRQ : Byte;
         BaseIO : Word;
         SampleRate : Word;
         DMABuffer : Word;
         Handle : File;
         MusicChannels : Word;
       Public
         Procedure GeenSB;
         Procedure LoadSoundEng;
         Constructor Create;
         Destructor Destroy;
         Procedure SpeelMod(Naam : String);
         Procedure StopMod;
     End;


var
  Muzieck : ^tMusicEng;
  ModLoad : Boolean;
  SndEngi : Boolean;

{-=-=-=-=--=-=-=-=-=-} implementation
Uses Crt;
(*)
  --------------------------------------------------------------------------
                                MUZIEK ENGINE
  --------------------------------------------------------------------------
(*)

constructor tMusicEng.Create;
Begin
  ModLoad := False;
  SndEngi := False;
  LoadSoundEng;
End;

Destructor tMusicEng.Destroy;
Begin
  GeenSB;
  SndEngi := False;
  ModLoad := False;
end;

Procedure tMusicEng.LoadSoundEng;
Const Kaarten : Array[0..5] of String = ('drv\PAS.MSE',
                                         'drv\SB16.MSE',
                                         'drv\SBPRO.MSE',
                                         'drv\SB2x.MSE',
                                         'drv\SB1x.MSE',
                                         'drv\GUS.MSE');
Var Failure : Boolean;
    Retry   : Byte;
    Kaart   : Byte;
Begin
SndEngi := False;
{ sound werkt voor geen moer, dus is het uitgeschakeld }

(*
Failure := False;
Kaart := 0;
WriteLn;
Repeat
  If Kaart < 5 then
     SoundCardName := Kaarten[Kaart]
     else Failure := True;
  if Kaart > 5 then Failure := True;
  BaseIO := $FFFF;
  IRQ := $FF;              { Get IRQ number }
  DMA := $FF;              { Get DMA Channel }
  Case Kaart of
    0 : SampleRate := 45;  { Pas }
    1 : SampleRate := 45;  { Sb 16 }
    2 : SampleRate := 45;  { SB Pro }
    3 : SampleRate := 45;  { SB 2.x }
    4 : SampleRate := 45;  { SB 1.x }
    5 : SampleRate := 45;  { GUS }
  End;
  DMABuffer := 4096; { DMA Buffer of 4096 bytes }
  Retry := 0;
  GotoXY(1,WhereY-1);
  WriteLn('Trying '+Kaarten[Kaart]+'(',Retry,')..');
  Repeat
    if LoadMSE(SoundCardName, 0, SampleRate, DMABuffer, BaseIO, IRQ, DMA) = 0 then
       SndEngi := True else Inc(Retry);
    GotoXY(1,WhereY-1);
    WriteLn('Trying '+Kaarten[Kaart]+'(',Retry,')..');
  until (Retry = 0) or (Retry = 2);
  Inc(Kaart);
Until (SndEngi = True) or Failure;
if Failure then Begin
                   GotoXY(1,WhereY-1);
                   WriteLn('No soundcard found :(');
                   Message^.NewWarning('Sound -> kon geen geluidskaart vinden!');
                   SndEngi := false;
                end;
{if Not Failure then Begin}
  If EMSExist                      { Check for EMS }
    Then EMSFlag := 1              { Yes, EMS exists, so use it }
    Else EMSFlag := 0;             { EMS does not exist }
{End;}
*)
End;

Procedure tMusicEng.SpeelMod(Naam : String);
var
   ChannelCount : Word;
Begin
  ModLoad := False;
(*
  if not SndEngi and (Level.Muziek = '???') then Close(LevelFile);

  if not SndEngi then Exit;
  if ModLoad then StopMod;

If Level.Muziek <> '???' then Begin
{$I-}                              { Turn off I/O checking }
  Assign(Handle, Naam);   { Open the file for loading }
  Reset(Handle);
{$I+}                              { Turn I/O checking back on }
  If IOResult <> 0 Then Begin
  {$I-}                              { Turn off I/O checking }
    Assign(Handle, 'Muziek\'+Naam);   { Open the file for loading }
    Reset(Handle);
  {$I+}                              { Turn I/O checking back on }
    If IOResult <> 0 Then Exit;
  End;

  Case LoadGDM(Handle, 0, EMSFlag, Header) of
    0 : ModLoad := True;
    1 : Message^.NewWarning('Muziek -> Module is verrot!');
    2 : Message^.NewWarning('Muziek -> Kon muziek type niet vinden!');
    3 : Message^.NewWarning('Muziek -> Onjuist formaat');
    4 : Message^.NewWarning('Muziek -> Niet genoeg geheugen!');
    5 : Message^.NewWarning('Muziek -> Kan samples niet uitpakken!');
    6 : Message^.NewWarning('Muziek -> geen AdLib instrumenten support!');
  End;
  Close(Handle);
End else Begin
  Case LoadGDM(LevelFile, FilePos(LevelFile), EMSFlag, Header) of
    0 : ModLoad := True;
    1 : Message^.NewWarning('Muziek -> Module is verrot!');
    2 : Message^.NewWarning('Muziek -> Kon muziek type niet vinden!');
    3 : Message^.NewWarning('Muziek -> Onjuist formaat');
    4 : Message^.NewWarning('Muziek -> Niet genoeg geheugen!');
    5 : Message^.NewWarning('Muziek -> Kan samples niet uitpakken!');
    6 : Message^.NewWarning('Muziek -> geen AdLib instrumenten support!');
  End;
  Close(LevelFile);
  Level.Muziek := '';
End;

If ModLoad then Begin
  MusicChannels := 0;            { Calculate the number of channels in song }
  For ChannelCount := 1 to 32 do
    Begin
      If Header.PanMap[ChannelCount] <> $FF
        Then MusicChannels := MusicChannels + 1;
    End;
  SampleRate := StartOutput(MusicChannels, 0);
  StartMusic;
  If not Muziek then MusicLevel := 0;
  MusicVolume(MusicLevel);
End;
*)
End;

Procedure tMusicEng.StopMod;
Begin
(*
if ModLoad then Begin
  StopOutput;
  UnloadModule;
End;
*)
ModLoad := False;
End;

Procedure tMusicEng.GeenSB;
Begin
{  If SndEngi then FreeMSE;}
End;
(*)
  --------------------------------------------------------------------------
                             EIND MUZIEK ENGINE
  --------------------------------------------------------------------------
(*)
end.

Zo geluid hebben we er ook weer bij....