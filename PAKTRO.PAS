unit PakTro; { Pakme, Pakme Intro file }

interface

Type
  tXY = Array[0..1] of Byte;
  tBlurAssen = object
     WachtHer : Word;
     WachtETA : Word;
     DestXY : tXY;
     WijkXY : tXY;
     OrgXY : tXY;
     NuXY : tXY;
     WitXY : tXY;
     Buf1XY : tXY;
     Buf2XY : tXY;
     GrijsXY : tXY;
  End;
  tIntro = Object
    Private
      PakScr : Array[0..1999] of Byte; { PakMe Logo}
      BlurScr : Array[0..1999] of Byte; { PakMe Logo Grey }
      VirFX  : Array[0..3999] of Byte;
      Waiting   : Word;
      Procedure BlurSprite(Var Sprite : Array of Byte; X,Y : Byte);
      Procedure SpriteColorFix(var Sprite : Array of Byte; Kleur : Byte);
      Procedure BlurAssen(Var Assen : tBlurAssen);
      Procedure SetAssen(Var Assen: tBlurAssen; X, Y, wijkx, wijky : Byte; Wacht : Word);
      Procedure WriteBlur(Text : String; var Assen : tBlurAssen; Kleur : Byte);
      Procedure WriteText(XY : tXY; Kleur : Byte; Text : String);
      Procedure BuildLine;
    Public
      Procedure Play; { Speel intro af }
      Constructor Create;
      Destructor Destroy;
  End;

Var
  Intro : ^tIntro;

implementation uses PakMeG, PkmForm, PakMem, Crt, PakMeI, MSE_TP;

(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                           De Intro van het spel
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Constructor tIntro.Create;
Begin
  Play;
End;

Destructor tIntro.Destroy;
Begin
End;

Procedure tIntro.SetAssen(Var Assen: tBlurAssen; X, Y, wijkx, wijky : Byte; Wacht : Word);
Begin
  With Assen do Begin
    OrgXy[0] := X;
    OrgXy[1] := y;
    NuXy := OrgXy;
    DestXy := OrgXy;
    GrijsXy := OrgXy;
    WitXy := OrgXy;
    WijkXy[0] := WijkX;
    WijkXy[1] := WijkY;
    WachtETA := 0;
    WachtHer := Wacht;
  end;
End;

Procedure tIntro.WriteText(XY : tXY; Kleur : Byte; Text : String);
Var Teller : byte;
Begin
  For Teller := 1 to Length(Text) do Begin
  {  VirFastText(XY[0], XY[1], Kleur, Text, Seg(VirFX), Ofs(VirFX));}
    If Text[Teller] <> ' ' then Begin
      VirFX[(XY[1]*160)+((XY[0]+Teller)*2)] := Ord(Text[Teller]);
      VirFX[(XY[1]*160)+((XY[0]+Teller)*2)+1] := Kleur;
    End;
  End;
End;

Procedure tIntro.BlurAssen(Var Assen : tBlurAssen);
Begin
  With Assen do Begin
    Inc(WachtETA);
    If WachtETA > WachtHer then Begin
      Buf2Xy := WitXy;
      GrijsXY := Buf2Xy;

      Buf1Xy := NuXy;
      WitXY := Buf1Xy;
      If DestXY[0] <> NuXY[0] then Begin
        If NuXY[0] > DestXY[0] then Dec(NuXY[0]);
        If NuXY[0] < DestXY[0] then Inc(NuXY[0]);
      End;
      If DestXY[1] <> NuXY[1] then Begin
        If NuXY[1] > DestXY[1] then Dec(NuXY[1]);
        If NuXY[1] < DestXY[1] then Inc(NuXY[1]);
      End;
{      If WachtETA > round(WachtHer * 1.5) then Begin}
        If (DestXY[1] = NuXY[1]) and (DestXY[0] = NuXY[0]) then Begin
           DestXY[0] := (OrgXY[0] - WijkXY[0]) + Random(WijkXY[0]*2+1);
           DestXY[1] := (OrgXY[1] - WijkXY[1]) + Random(WijkXY[1]*2+1);
        End;
        WachtETA := 0;
{      End;}
    End;
  End;
End;

Procedure tIntro.WriteBlur(Text : String; var Assen : tBlurAssen; Kleur : Byte);
Begin
  BlurAssen(Assen);
  WriteText(Assen.GrijsXY, $08, Text);
  WriteText(Assen.WitXY, Kleur-8, Text);
  WriteText(Assen.NuXY, Kleur, Text);
End;


Procedure tIntro.BuildLine;
Var RndMNr : Byte;
    RndMNr2 : Byte;
    Teller : Byte;
    PrevSet : Word;
Begin
  If (Waiting > PrevSet +10) or (Waiting < PrevSet -10) then Begin
    RndMNr := 30+Random(20);
    RndMNr2 := 10+Random(50);
    PrevSet := Waiting;
  End;
  RndMNr := RndMNr-2+Random(5);
  RndMNr2 := RndMNr2-2+Random(5);
  For Teller := 0 to 25 do Begin
    VirFX[(Teller*160)+(RndMNr*2)] := Ord('³');
    VirFX[(Teller*160)+(RndMNr*2)+1] := $f0;
    VirFX[(Teller*160)+(RndMNr2*2)] := Ord('³');
    VirFX[(Teller*160)+(RndMNr2*2)+1] := $0f;
  End;
End;

Procedure tIntro.SpriteColorFix(var Sprite : Array of Byte; Kleur : Byte);
Var Teller : Word;
Begin
  For Teller := 0 to SizeOf(Sprite) div 2 do Begin
    Sprite[(Teller*2)+1] := Kleur;
  end;
end;

Procedure tIntro.BlurSprite(Var Sprite : Array of Byte; X,Y : Byte);
Var Teller : Word;
Begin
  For Teller := 0 to SizeOf(Sprite) div 2 do Begin
    If (VirFX[(Y*160)+((X+Teller)*2)] = Ord(' ')) or
       (VirFX[(Y*160)+((X+Teller)*2)] = 0)
       then Begin
      VirFX[(Y*160)+((X+Teller)*2)] := Sprite[(Teller*2)];
      VirFX[(Y*160)+((X+Teller)*2)+1] := Sprite[(Teller*2)+1];
    End else Begin
      If (Sprite[Teller*2] <> Ord(' ')) or
         (Sprite[Teller*2] <> 0) then Begin
         If (VirFX[(Y*160)+((X+Teller)*2)] = Sprite[Teller*2]) then Begin
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              VirFX[(Y*160)+((X+Teller)*2)+1]+8;
         End;
         If (Chr(VirFX[(Y*160)+((X+Teller)*2)]) = 'Ü') and
            (Chr(Sprite[Teller*2]) = 'ß') then Begin
           VirFX[(Y*160)+((X+Teller)*2)] := Ord('Ü');
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              $80+VirFX[(Y*160)+((X+Teller)*2)+1];
         End;
         If (Chr(VirFX[(Y*160)+((X+Teller)*2)]) = 'ß') and
            (Chr(Sprite[Teller*2]) = 'Ü') then Begin
           VirFX[(Y*160)+((X+Teller)*2)] := Ord('ß');
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              $80+VirFX[(Y*160)+((X+Teller)*2)+1];
         End;
         If (Chr(VirFX[(Y*160)+((X+Teller)*2)]) = 'Ü') and
            (Chr(Sprite[Teller*2]) = 'Û') then Begin
           VirFX[(Y*160)+((X+Teller)*2)] := Ord('Ü');
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              $80+VirFX[(Y*160)+((X+Teller)*2)+1]+8;
         End;
         If (Chr(VirFX[(Y*160)+((X+Teller)*2)]) = 'ß') and
            (Chr(Sprite[Teller*2]) = 'Û') then Begin
           VirFX[(Y*160)+((X+Teller)*2)] := Ord('ß');
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              $80+VirFX[(Y*160)+((X+Teller)*2)+1]+8;
         End;
         If (Chr(VirFX[(Y*160)+((X+Teller)*2)]) = 'Û') and
            (Chr(Sprite[Teller*2]) = 'Ü') then Begin
           VirFX[(Y*160)+((X+Teller)*2)] := Ord('Ü');
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              (VirFX[(Y*160)+((X+Teller)*2)+1] *16)
              +VirFX[(Y*160)+((X+Teller)*2)+1]+8;
         End;
         If (Chr(VirFX[(Y*160)+((X+Teller)*2)]) = 'Û') and
            (Chr(Sprite[Teller*2]) = 'ß') then Begin
           VirFX[(Y*160)+((X+Teller)*2)] := Ord('ß');
           VirFX[(Y*160)+((X+Teller)*2)+1] :=
              (VirFX[(Y*160)+((X+Teller)*2)+1] *16)
              +VirFX[(Y*160)+((X+Teller)*2)+1]+8;
         End;
      End;
    End;
  end;
End;

Procedure tIntro.Play;
{
 Hier komt spel intro!

 GUIDO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
}
var IntroFile : File;
    ToetsAs : tBlurAssen;
    LogoAs : tBlurAssen;
    TextAs  : tBlurAssen;
    Text2As  : tBlurAssen;
    Text3As  : tBlurAssen;

    Teller : Word;
    PatternSpeed : Word;
    StartTel : Word;
    NextOne : Byte;

    Procedure Stoor;
    var Teller : Byte;
    Begin
      For Teller := 0 to 3 do Begin
        { Lines }
        If (Waiting > StartTel+20+(Teller*PatternSpeed)) and
           (Waiting < StartTel+190) then BuildLine;
        { screen flashes }
        If (Waiting > StartTel+40+(Teller*PatternSpeed)*2) and
           (Waiting < StartTel+60) then FillChar(VirFx, 4000, $ff);
        If (Waiting > StartTel+300+(Teller*PatternSpeed*2)) and
           (Waiting < StartTel+315) then FillChar(VirFx, 4000, $ff);
      End;

    End;


    Procedure Start1;
    Begin
      SetAssen(TextAs, 10, 15, 5, 2, 7);
    End;
    Procedure Doe1;
    Begin
      WriteBlur('The Attic People presents...', TextAs, $0f);
      Stoor;
    End;

    Procedure Start2;
    Begin
       SetAssen(TextAs, 35, 5, 5, 2, 7);
    End;
    Procedure Doe2;
    Begin
      WriteBlur('A game from the Lame-o-game project', TextAs, $09);
      Stoor;
    End;

    Procedure Start3;
    Begin
         SetAssen(TextAs, 45, 4, 5, 2, 7);
         SetAssen(Text2As, 10, 12, 5, 2, 7);
         SetAssen(Text3As, 40, 17, 5, 2, 7);
    End;
    Procedure Doe3;
    Begin
        WriteBlur('Made by', TextAs, $0c);
        WriteBlur('THAiSi - Matthijs Groen', Text2As, $0a);
        WriteBlur('BamBoo - Guido Pater', Text3As, $09);
        Stoor;
    End;
    Procedure Start4;
    Begin
        SetAssen(LogoAs, 2, 6, 1, 2, 4);
        SetAssen(Text2As, 1, 1, 0, 0, 1);
    End;

    Procedure Doe4;
    Begin
        WriteBlur(PakVersie, Text2As, $08);
        BlurSprite(PakScr, LogoAs.NuXY[0],LogoAs.NuXY[1]);
        BlurSprite(BlurScr, LogoAs.WitXY[0], LogoAs.WitXY[1]);
        BlurAssen(LogoAs);
        Stoor;
    End;

Begin
  Randomize;
  Assign(IntroFile,'Levels\intro.asc');
  Reset(IntroFile, 1);
  BlockRead(IntroFile, PakScr, 2000);
  Close(IntroFile);
  Move(PakScr, BlurScr, 2000);
  SpriteColorFix(BlurScr, $08);
  PatternSpeed := 500;

  Muzieck^.SpeelMod('intro.gdm');
  FillChar(Mem[$b800:0], 4000, 0);
  GotoXy(80,25);
  Waiting := 0;
  SetAssen(ToetsAs, 20, 23, 13, 1, 10);
  If not ModLoad then Begin
    Repeat
      Wacht(3);
      FillChar(VirFx, 4000, 0);
      {WriteBlur('Beuk een toets om te beginne...', ToetsAs, $0a);}
      StartTel := 0;
      If Waiting = StartTel then Start1;
      If (Waiting > StartTel) and (Waiting < StartTel+PatternSpeed) then Doe1;
      StartTel := 500;
      If Waiting = StartTel then Start2;
      If (Waiting > StartTel) and (Waiting < StartTel+PatternSpeed) then Doe2;
      StartTel := 1000;
      If Waiting = StartTel then Start3;
      If (Waiting > StartTel) and (Waiting < StartTel+PatternSpeed) then Doe3;
      StartTel := 1500;
      If Waiting = StartTel then Start4;
      If (Waiting > StartTel) and (Waiting < StartTel+(PatternSpeed*7)) then Doe4;
      Inc(Waiting);
      If Waiting > 5000 then Waiting := 0;
      Move(VirFx, Mem[$b800:0], 4000);
    Until Keypressed;
  End else Begin
    Repeat
      Wacht(0);
      FillChar(VirFx, 4000, 0);
      {WriteBlur('Beuk een toets om te beginne...', ToetsAs, $0a);}
      If (MusicOrder($ff) < 2) then Begin
        If (MusicRow = 0) and (MusicOrder($ff)=0) then Begin
          StartTel := Waiting;
          Start1;
        End;
        Doe1;
      End;
      If (MusicOrder($ff) > 1) and (MusicOrder($ff) < 4) then Begin
        If (MusicRow = 0) and (MusicOrder($ff)=2) then Begin
           StartTel := Waiting;
           Start2;
        End;
        Doe2;
      End;
      If (MusicOrder($ff) > 3) and (MusicOrder($ff) < 7) then Begin
        If (MusicRow = 0) and (MusicOrder($ff)=4) then Begin
           NextOne := $30;
           StartTel := Waiting;
           Start3;
        End;
        Doe3;
        If (MusicOrder($ff)=6) then Begin
          If (MusicRow = NextOne) then Begin
             FillChar(VirFx, 4000, $ff);
             If NextOne = $3e then NextOne := $0;
             If NextOne = $3c then NextOne := $3e;
             If NextOne = $3a then NextOne := $3c;
             If NextOne = $39 then NextOne := $3a;
             If NextOne = $37 then NextOne := $39;
             If NextOne = $36 then NextOne := $37;
             If NextOne = $34 then NextOne := $36;
             If NextOne = $33 then NextOne := $34;
             If NextOne = $31 then NextOne := $33;
             If NextOne = $30 then NextOne := $31;
          End;
        End;
      End;
      If (MusicOrder($ff) > 6) then Begin
        If (MusicRow = 0) and (MusicOrder($ff)=7) then Begin
           StartTel := Waiting;
           Start4;
        End;
        Doe4;
        If (MusicRow = 0) then FillChar(VirFx, 4000, $ff);
      End;
      Inc(Waiting);
      If Waiting > 5000 then Waiting := 0;
      Move(VirFx, Mem[$b800:0], 4000);
    Until Keypressed;
  End;
  ReadKey;

  Move(VirFx, VirScr, 4000);

  Muzieck^.StopMod;
End;

End.
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
