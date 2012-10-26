Unit PKMform; { Alle Vars nodig voor PkmFile }

InterFace

Const
      PakHead : Array[0..7] of Char = '<PakC'+#1+#0+'>';
      PakVersie : Array[0..8] of Char = 'Ver 0.80';
      PakSep : Char = ';';
      wRight = 0;
      wLeft = 1;
      wUp = 2;
      wDown = 3;

{ De Pakme Limits }
      MaxEnemy = 14;
      MaxTele = 14;
      MaxLicht = 14;
      MaxChange = 14;

Type
     TelPrt = Record
       X, Y : Byte;
     End;
     Lichtje = Record
       X, Y : Byte;
       Typ : Byte;
     End;

     { Stuk FileFormaat }
     tFileForm = Record
        Bonus : Record
          Normaal,
          Mega,
          Negatief : Char;
          NorWaard,
          MegWaard,
          NegWaard : Integer;
        End;
        Asse : Record
          Leven,
          HoloFace,
          Bomb : Char;
          Collect : Word;        { Aantal pakme bonussen!     }
          AantEnemy,                 { Aantal Vijanden            }
          AantTele,                  { Aantal Teleporters         }
          Lichten,                   { Aantal LichtVlekken        }
          Kleur : Byte;        { Aantal Verkleuringen       }
        End;
     End;

     tCreature = Record
       X : Byte;
       Y : Byte;
       Soort : Byte;
       Richting : Byte;
       Speed : Word;
       Special : Byte;
       Licht : Byte;
     End;
     tCreat = Record
       Wait : Word;
       Face : Char;
       Spc : Array[0..7] of Boolean;
       TeleAble : Boolean;
       TelePort : Boolean;
     End;
     TextScherm = Array[0..3999] of Byte;
     tPlayer = Record
       Levens : Byte;
       LevWaard : Integer;
     End;
     tItems = Record
       TeleStrt : Array[0..MaxTele] of TelPrt;
       TeleEind : Array[0..MaxTele] of TelPrt;
       Licht : Array[0..MaxLicht] of Lichtje;
       Kleur : Array[0..MaxChange] of Lichtje;
       Muren : String;
       EnmyFaces : String;
     End;
     tLevel = Record
       InvTijd : Word; { Tijd van ontsterfelijkheid }
       HolTijd : Word; { Tijd Holo Aanwezig }
       Holo : Boolean; { Heb je een Holo? }
       Muziek : String; { Naam Muziek File }
       Naam : String; { Levelnaam }
       Bestand : String; { Bestands naam }
       Special : Byte; { Level Specialties }
       Spec : Array[0..7] of Boolean;
       Licht : Byte; { Standaard licht kleur }
       Nr : Byte; { Level Nr }
       Scherm : TextScherm; { Level map }
     End;

(*) -/-\-/-\-/-\-/-\-/-\- (*)
Var
   RDPakHead : Array[0..7] of Char; { File Header }
   Level : tLevel; { The Game Stuff }
   Speler : tPlayer;
   Items : tItems;
   Wezen : Array[0..1+MaxEnemy] of tCreature;
   WezenE : Array[0..1+MaxEnemy] of tCreat;
   LevelFile : File;
   LevelForm : tFileForm;
   ErrorMessage : String;
   Musiclevel : Integer;

Function FileExists(Naam : String) : Boolean;
Function HoofdLetters(Text : String) : String;
Function StripSpace(Text : String) : String;
Function ReadLevel(Naam : String) : Boolean;
Procedure WriteLevel(OutPutNaam: String);
Procedure Virfasttext(x, y : word; col : byte; what : string; SegM, Ofst : Word);
Procedure ClearLevel;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
                               Implementation
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Uses Crt; {tijdelijk voor de-buggen, kan straks wieder weg }

Var
(*) -/-\-/-\-/-\-/-\-/-\- (*)
   Code : Integer;
   IniFile : Text;
   IniPrim,
   IniSecnd : String;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure Virfasttext(x, y : word; col : byte; what : string; SegM, Ofst : Word); Assembler;
{ Probeert zo snel mogelijk text op scherm te smijten}
asm
   push   ds

   dec    [x]
   dec    [y]
   mov    ax, [Segm]
   mov    es, ax
   mov    ax, [y]
   mov    bl, 160
   mul    bl
   add    ax, [Ofst]
   add    ax, [x]
   add    ax, [x]
   mov    di, ax

   lds    si, what
   cld
   lodsb
   xor    ch, ch
   mov    ah, [col]
   mov    cl, al
   cmp    cx, 0
   jz     @@2

 @@1: lodsb
   stosw
   loop   @@1

 @@2:
   pop    ds
end; {FastText}
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
function BitAan(Bty : Byte; BitNr : Byte) : Boolean;
Var Bits : array [0..7] of Boolean;
    TmpByt : Byte;
Begin
   Bits[0] := false; Bits[1] := false; Bits[2] := false; Bits[3] := false;
   Bits[4] := false; Bits[5] := false; Bits[6] := false; Bits[7] := false;

   TmpByt := Bty;
   if  TmpByt > 127 then Begin Dec(TmpByt, 128); Bits[0] := True; End;
   if  TmpByt > 63 then Begin Dec(TmpByt, 128); Bits[1] := True; End;
   if  TmpByt > 31 then Begin Dec(TmpByt, 128); Bits[2] := True; End;
   if  TmpByt > 15 then Begin Dec(TmpByt, 128); Bits[3] := True; End;
   if  TmpByt > 7 then Begin Dec(TmpByt, 128); Bits[4] := True; End;
   if  TmpByt > 3 then Begin Dec(TmpByt, 128); Bits[5] := True; End;
   if  TmpByt > 1 then Begin Dec(TmpByt, 128); Bits[6] := True; End;
   if  TmpByt > 0 then Begin Dec(TmpByt, 128); Bits[7] := True; End;
   BitAan := Bits[BitNr];
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
function MaakByte(Bit1, Bit2, Bit3, Bit4, Bit5, Bit6, Bit7, Bit8 : Boolean) : Byte;
Var TmpByt : Byte;
Begin
 TmpByt := 0;
 if Bit8 then Inc(TmpByt, 1);
 if Bit7 then Inc(TmpByt, 2);
 if Bit6 then Inc(TmpByt, 4);
 if Bit5 then Inc(TmpByt, 8);
 if Bit4 then Inc(TmpByt, 16);
 if Bit3 then Inc(TmpByt, 32);
 if Bit2 then Inc(TmpByt, 64);
 if Bit1 then Inc(TmpByt, 128);
 MaakByte := TmpByt;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure Fasttext(x, y : word; col : byte; what : string); Assembler;
{ Probeert zo snel mogelijk text op scherm te smijten}
asm
   push   ds

   dec    [x]
   dec    [y]
   mov    ax, 0b800h
   mov    es, ax
   mov    ax, [y]
   mov    bl, 160
   mul    bl
   add    ax, 0
   add    ax, [x]
   add    ax, [x]
   mov    di, ax

   lds    si, what
   cld
   lodsb
   xor    ch, ch
   mov    ah, [col]
   mov    cl, al
   cmp    cx, 0
   jz     @@2

 @@1: lodsb
   stosw
   loop   @@1

 @@2:
   pop    ds
end; {FastText}

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function FileExists(Naam : String) : Boolean;
Var l_File : File;
Begin
{$I-}
  Assign(l_File, Naam);
  Reset(l_File,1);
  Close(l_File);
{$I+}
  FileExists := (IoResult = 0) And (Naam <> '');
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function HoofdLetters(Text : String) : String;
Var l_TijdLoper : Byte;
begin
  For l_TijdLoper := 1 to Length(Text) do
    Text[l_TijdLoper] := UpCase(Text[l_TijdLoper]);
  HoofdLetters := Text;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
{ Haalt spaties weg aan voor -en achterkant van een string... }
Function StripSpace(Text : String) : String;
begin
If Length(Text) > 1 then Begin
  While Text[1] = #32  do Text := Copy(Text, 2, Length(Text));
  While Text[Length(Text)] = #32  do Text := Copy(Text, 1, Length(Text)-1);
End;
  StripSpace := Text;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function ReadLevelString : String;
Var
   TRdString : String;
   LenStr    : Byte;
   FGotChar  : Char;
   FGtString : Byte;
Begin
  TRdString := '';
  BlockRead(LevelFile, LenStr, SizeOf(LenStr));
  For FGtString := 1 to LenStr do Begin
      BlockRead(LevelFile, FGotChar, SizeOf(FGotChar));
      TRdString := TRdString + FGotChar;
  End;
ReadLevelString := TRdString;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function ReadLevel(Naam : String) : Boolean;
Var SchermNaam : String;
    OnderWerp  : String;
    lTempBty   : Byte;
    CheckChar  : Char;
    NMITeller  : Byte;
    IncMuziek  : Byte;
Begin
    If not FileExists(Naam) then Begin
       ReadLevel    := False;
       ErrorMessage := 'Levelbestand bestaat niet!';
       Exit;
    End;
    OnderWerp     := '';
    Level.Naam    := '';
    Level.Special := 0;
    Level.Licht   := 0;
    With Items do Begin
         Muren := '³ÄÀ¿ÙÚÃ´ÂÁ'; { standaard muren }
         EnmyFaces := '!#@?&*';
    End;
    With LevelForm do Begin
         With Bonus do Begin
              Normaal := 'Ÿ';
              NorWaard := 1;
              Mega := '$';
              MegWaard := 50;
              Negatief := '%';
              NegWaard := -20;
         End;
         With Asse do Begin
              Leven := #3;           { Hartje }
              AantEnemy := 0;
         End;
    End;
    With Wezen[0] do Begin
         X   := 1;
         Y   := 1;
    End;
    Level.HolTijd := 0;

    Assign(LevelFile, Naam);
    Reset(LevelFile,1);
    BlockRead(LevelFile, RDPakHead, SizeOf(PakHead));
    If RDPakHead <> PakHead then Begin
       ErrorMessage := 'Bestand heeft verkeerde header!';
       Close(LevelFile);
       ReadLevel := False;
       Exit;
    End;
    Level.Naam      := ReadLevelString;
    Items.Muren     := ReadLevelString;
    Items.EnmyFaces := ReadLevelString;
    Level.Muziek    := ReadLevelString;
    BlockRead(LevelFile, CheckChar, SizeOf(PakSep));
    If CheckChar <> PakSep then Begin
       ErrorMessage := 'Bestandsformaat komt niet overeen (1)!';
       Close(LevelFile);
       ReadLevel := False;
       Exit;
    End;

    With LevelForm do Begin
         BlockRead(LevelFile, Bonus, SizeOf(Bonus));
         BlockRead(LevelFile, Asse, SizeOf(Asse));
    End;

    BlockRead(LevelFile, Wezen[0].x, SizeOf(Wezen[0].x));
    BlockRead(LevelFile, Wezen[0].y, SizeOf(Wezen[0].y));
    BlockRead(LevelFile, Wezen[0].Special, SizeOf(Wezen[0].Special));
    BlockRead(LevelFile, Wezen[0].Licht, SizeOf(Wezen[0].Licht));

    BlockRead(LevelFile, Level.Special, SizeOf(Level.Special));
    BlockRead(LevelFile, Level.Licht, SizeOf(Level.Licht));

    WezenE[1].Face     := LevelForm.Asse.HoloFace;
    WezenE[0].TeleAble := BitAan(Wezen[0].Special, 6);

    BlockRead(LevelFile, CheckChar, SizeOf(PakSep));
    If CheckChar <> PakSep then Begin
{      WriteLn('Erreur! Level settings kloppen niet!');}
       ErrorMessage := 'Bestandsformaat komt niet overeen (2)!';
       Close(LevelFile);
       ReadLevel := False;
       Exit;
    End;

    If LevelForm.Asse.AantEnemy > 0 then Begin
       For NMITeller := 0 to LevelForm.Asse.AantEnemy do Begin
           BlockRead(LevelFile, Wezen[NMITeller+2],SizeOf(Wezen[NMITeller+2]));

           WezenE[NMITeller+2].TeleAble := BitAan(Wezen[NMITeller+2].Special, 0);
           WezenE[NMITeller+2].Face := Items.EnmyFaces[1+Wezen[NMITeller+2].Soort];
           Inc(Wezen[NMITeller+2].Soort, 2);

       End;
    End;

    BlockRead(LevelFile, CheckChar, SizeOf(PakSep));
    If CheckChar <> PakSep then Begin
       ErrorMessage := 'Bestandsformaat komt niet overeen (3)!';
{      WriteLn('VouD Vijanden kloppen niet!');}
       Close(LevelFile);
       ReadLevel := False;
       Exit;
    End;
    If LevelForm.Asse.AantTele > 0 then Begin
       For NMITeller := 0 to LevelForm.Asse.AantTele-1 do Begin
           BlockRead(LevelFile, Items.TeleStrt[NMITeller],
                           SizeOf(Items.TeleStrt[NMITeller]));
           BlockRead(LevelFile, Items.TeleEind[NMITeller],
                           SizeOf(Items.TeleEind[NMITeller]));
       End;
    End;
    If LevelForm.Asse.Lichten > 0 then Begin
       For NMITeller := 0 to LevelForm.Asse.Lichten-1 do Begin
           BlockRead(LevelFile, Items.Licht[NMITeller],
                   SizeOf(Items.Licht[NMITeller]));
       End;
    End;
    If LevelForm.Asse.Kleur > 0 then Begin
       For NMITeller := 0 to LevelForm.Asse.Kleur-1 do Begin
           BlockRead(LevelFile, Items.Kleur[NMITeller],
                           SizeOf(Items.Kleur[NMITeller]));
       End;
    End;

    BlockRead(LevelFile, CheckChar, SizeOf(PakSep));
    If CheckChar <> PakSep then Begin
       WriteLn('Errier!');
       Close(LevelFile);
       ReadLevel := False;
       Exit;
    End;
    FillChar(Level.Scherm, 4000, 0);
    BlockRead(LevelFile, Level.Scherm[160*2], 22*160);
    BlockRead(LevelFile, IncMuziek, 1);
    {If IncMuziek = 0 then Begin{}
    Close(LevelFile);
    {End;{}
    If Level.Naam = '' then Begin
        Str(Level.Nr, Level.Naam);
        Level.Naam := 'Level '+Level.Naam;
    End;
    if BitAan(Level.Special, 7) then Level.Licht := 1;
    if BitAan(Level.Special, 6) then Level.Licht := 2;

    Inc(Wezen[0].Y,2);
    Writeln('er zijn ',LevelForm.Asse.AantEnemy,' NMies in het level');
    ReadKey;
End;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}

Procedure WriteLevel(OutPutNaam: String);
Var
    MuzkStr       : String;
    PickCount     : LongInt;
    NMINaam       : Byte;
    MuziekFile    : File;
    MuziekBuff    : Array[0..6200] of Byte;
    MuziekLees    : Word;
Begin
Assign(LevelFile, OutPutNaam);
Rewrite(LevelFile,1);
{ Schrijf Header }

BlockWrite(LevelFile, PakHead, SizeOf(PakHead));

BlockWrite(LevelFile, Level.Naam, Length(Level.Naam)+1);
BlockWrite(LevelFile, Items.Muren, Length(Items.Muren)+1);
BlockWrite(LevelFile, Items.EnmyFaces, Length(Items.EnmyFaces)+1);

If FileExists(Level.Muziek) then Begin
   MuzkStr := '???';
   BlockWrite(LevelFile, MuzkStr, Length(MuzkStr)+1);
End Else BlockWrite(LevelFile, Level.Muziek, Length(Level.Muziek)+1);

BlockWrite(LevelFile, PakSep, SizeOf(PakSep));

BlockWrite(LevelFile, LevelForm.Bonus.Normaal, SizeOf(LevelForm.Bonus.Normaal));
BlockWrite(LevelFile, LevelForm.Bonus.Mega, SizeOf(LevelForm.Bonus.Mega));
BlockWrite(LevelFile, LevelForm.Bonus.Negatief, SizeOf(LevelForm.Bonus.Negatief));
BlockWrite(LevelFile, LevelForm.Bonus.NorWaard, SizeOf(LevelForm.Bonus.NorWaard));
BlockWrite(LevelFile, LevelForm.Bonus.MegWaard, SizeOf(LevelForm.Bonus.MegWaard));
BlockWrite(LevelFile, LevelForm.Bonus.NegWaard, SizeOf(LevelForm.Bonus.NegWaard));


LevelForm.Asse.HoloFace := WezenE[1].Face;
BlockWrite(LevelFile, LevelForm.Asse.Leven, SizeOf(LevelForm.Asse.Leven));
BlockWrite(LevelFile, LevelForm.Asse.HoloFace, SizeOf(LevelForm.Asse.HoloFace));
BlockWrite(LevelFile, LevelForm.Asse.Bomb, SizeOf(LevelForm.Asse.Bomb));
BlockWrite(LevelFile, LevelForm.Asse.Collect, SizeOf(LevelForm.Asse.Collect));

BlockWrite(LevelFile, LevelForm.Asse.AantEnemy, SizeOf(LevelForm.Asse.AantEnemy));
BlockWrite(LevelFile, LevelForm.Asse.AantTele, SizeOf(LevelForm.Asse.AantTele));
BlockWrite(LevelFile, LevelForm.Asse.Lichten, SizeOf(LevelForm.Asse.Lichten));
BlockWrite(LevelFile, LevelForm.Asse.Kleur, SizeOf(LevelForm.Asse.Kleur));

BlockWrite(LevelFile, Wezen[0].x, SizeOf(Wezen[0].x));
Dec(Wezen[0].y, 2);
BlockWrite(LevelFile, Wezen[0].y, SizeOf(Wezen[0].y));
Inc(Wezen[0].y, 2);

  Wezen[0].Special := MaakByte(WezenE[0].Spc[6], WezenE[0].Spc[1],
            WezenE[0].Spc[2], WezenE[0].Spc[3], WezenE[0].Spc[4],
            WezenE[0].Spc[5], WezenE[0].TeleAble, WezenE[0].Spc[7]);

BlockWrite(LevelFile, Wezen[0].Special, SizeOf(Wezen[0].Special));
BlockWrite(LevelFile, Wezen[0].Licht, SizeOf(Wezen[0].Licht));

BlockWrite(LevelFile, Level.Special, SizeOf(Level.Special));
BlockWrite(LevelFile, Level.Licht, SizeOf(Level.Licht));

BlockWrite(LevelFile, PakSep, SizeOf(PakSep));

If LevelForm.Asse.AantEnemy > 0 then Begin  { De Vijanden }
  For PickCount := 0 to LevelForm.Asse.AantEnemy do Begin
      BlockWrite(LevelFile, Wezen[PickCount+2].X,
                      SizeOf(Wezen[PickCount+2].X));
      BlockWrite(LevelFile, Wezen[PickCount+2].Y,
                      SizeOf(Wezen[PickCount+2].Y));
      Dec(Wezen[PickCount+2].Soort, 2);

      BlockWrite(LevelFile, Wezen[PickCount+2].Soort,
                      SizeOf(Wezen[PickCount+2].Soort));
      Inc(Wezen[PickCount+2].Soort, 2);

      BlockWrite(LevelFile, Wezen[PickCount+2].Richting,
                      SizeOf(Wezen[PickCount+2].Richting));
      BlockWrite(LevelFile, Wezen[PickCount+2].Speed,
                      SizeOf(Wezen[PickCount+2].Speed));
      Wezen[PickCount+2].Special :=
                MaakByte(WezenE[PickCount+2].TeleAble,
                         WezenE[PickCount+2].spc[1],
                         WezenE[PickCount+2].spc[2],
                         WezenE[PickCount+2].spc[3],
                         WezenE[PickCount+2].spc[4],
                         WezenE[PickCount+2].spc[5],
                         WezenE[PickCount+2].spc[6],
                         WezenE[PickCount+2].spc[7]);
      BlockWrite(LevelFile, Wezen[PickCount+2].Special,
                      SizeOf(Wezen[PickCount+2].Special));

{      Case Wezen[PickCount-1].Licht of
        0 : Wezen[PickCount-1].Licht := 9;
        9 : Wezen[PickCount-1].Licht := 0;
      End;
}
      BlockWrite(LevelFile, Wezen[PickCount+2].Licht,
                      SizeOf(Wezen[PickCount+2].Licht));

  End;
End;

BlockWrite(LevelFile, PakSep, SizeOf(PakSep));

If LevelForm.Asse.AantTele > 0 then Begin
  For PickCount := 0 to LevelForm.Asse.AantTele-1 do Begin
      BlockWrite(LevelFile, Items.TeleStrt[PickCount].x,
                             SizeOf(Items.TeleStrt[PickCount].x));
      BlockWrite(LevelFile, Items.TeleStrt[PickCount].y,
                             SizeOf(Items.TeleStrt[PickCount].y));
      BlockWrite(LevelFile, Items.TeleEind[PickCount].x,
                             SizeOf(Items.TeleEind[PickCount].x));
      BlockWrite(LevelFile, Items.TeleEind[PickCount].y,
                             SizeOf(Items.TeleEind[PickCount].y));
  End;
End;

If LevelForm.Asse.Lichten > 0 then Begin
  For PickCount := 0 to LevelForm.Asse.Lichten-1 do Begin

      BlockWrite(LevelFile, Items.Licht[PickCount],
                             SizeOf(Items.Licht[PickCount]));
  End;
End;

If LevelForm.Asse.Kleur > 0 then Begin
  For PickCount := 0 to LevelForm.Asse.Kleur-1 do Begin
      BlockWrite(LevelFile, Items.Kleur[PickCount],
                             SizeOf(Items.Kleur[PickCount]));
  End;
End;

BlockWrite(LevelFile, PakSep, SizeOf(PakSep));
BlockWrite(LevelFile, Level.Scherm, 22*160);

If FileExists(Level.Muziek) then NMINaam := 1 else NMINaam := 0;
BlockWrite(LevelFile, NMINaam, 1);

If NMINaam = 1 then Begin
{   Write('(Inserting Music File)..');}
   Assign(MuziekFile, Level.Muziek);
   Reset(MuziekFile, 1);
   Repeat
     BlockRead(MuziekFile, MuziekBuff, SizeOf(MuziekBuff), MuziekLees);
     BlockWrite(LevelFile, MuziekBuff, MuziekLees);
   until EOF(MuziekFile);
   Close(MuziekFile);
End;
Close(LevelFile);
End;

Procedure ClearLevel;
Begin
    With Level do Begin
       InvTijd := 0; { Tijd van ontsterfelijkheid }
       HolTijd := 0; { Tijd Holo Aanwezig }
       Special := 0; { Level Specialties }
       Licht := 7; { Standaard licht kleur }
    End;
    With LevelForm.Asse do Begin
       Collect := 0;        { Aantal pakme bonussen!     }
       AantEnemy := 0;      { Aantal Vijanden            }
       AantTele := 0;       { Aantal Teleporters         }
       Lichten := 0;        { Aantal LichtVlekken        }
       Kleur := 0;          { Aantal Verkleuringen       }
    End;

End;

Begin
  WezenE[0].Face := #1;
End.