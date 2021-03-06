Unit PKMform; { Alle Vars nodig voor PkmFile }

InterFace

Const
      PakHead     : Array[0..7] of Char = '<PakC'+#1+#0+'>';
      PakSep      : Char = ';';
      Right       = 0;
      Left        = 1;
      Up          = 2;
      Down        = 3;

{ De Pakme Limits }
      MaxEnemy    = 40;
      MaxTele     = 15;
      MaxLicht    = 15;
      MaxChange   = 14;

Type
     TelPrt       = Record
       X, Y       : Byte;
     End;
     Lichtje      = Record
       X, Y       : Byte;
       Typ        : Byte;
     End;
     tCreature    = Record
       X          : Byte;
       Y          : Byte;
       Soort      : Byte;
       Face       : Char;
       Richting   : Byte;
       Wait       : Word;
       Special    : Byte;
       Speed      : Word;
       Licht      : Byte;
       TeleAble   : Boolean;
       TelePort   : Boolean;
       Spc        : Array[0..7] of Boolean;
     End;
     TextScherm   = Array[0..3999] of Byte;
     tPlayer      = Record
       Levens     : Byte;
       LevWaard   : Integer;
     End;
     tItems       = Record
       TeleStrt   : Array[0..MaxTele] of TelPrt;
       TeleEind   : Array[0..MaxTele] of TelPrt;
       Licht      : Array[0..MaxLicht] of Lichtje;
       Kleur      : Array[0..MaxChange] of Lichtje;
       Muren      : String;
       EnmyFaces  : String;
       Leven,
       Bomb       : Char;
       Bonus      : Record
         Normaal  : Char;
         NorWaard : Integer;
         Mega     : Char;
         MegWaard : Integer;
         Negatief : Char;
         NegWaard : Integer;
       End;
     End;
     tLevel       = Record
       InvTijd    : Word;        { Tijd van ontsterfelijkheid }
       HolTijd    : Word;        { Tijd Holo Aanwezig         }
       Lichten    : Byte;        { Aantal LichtVlekken        }
       Kleur      : Byte;        { Aantal Verkleuringen       }
       AantTele   : Byte;        { Aantal Teleporters         }
       Holo       : Boolean;     { Heb je een Holo?           }
       Collect    : Word;        { Aantal pakme bonussen!     }
       Muziek     : String;      { Naam Muziek File           }
       Naam       : String;      { Levelnaam                  }
       AantEnemy  : Byte;        { Aantal Vijanden            }
       Special    : Byte;        { Level Specialties          }
       Spec       : Array[0..7] of Boolean;
       Licht      : Byte;        { Standaard licht kleur      }
       Nr         : Byte;        { Level Nr                   }
       Scherm     : TextScherm;  { Level map                  }
     End;
(*) -/-\-/-\-/-\-/-\-/-\- (*)
Var
   Level          : tLevel;      { The Game Stuff }
   Speler         : tPlayer;
   Items          : tItems;
   Wezen          : Array[0..1+MaxEnemy] of tCreature;
   LevelFile      : File;

Function  FileExists(Naam : String) : Boolean;
Function  HoofdLetters(Text : String) : String;
Function  StripSpace(Text : String) : String;
Function  ReadLevel(Naam : String) : Boolean;
Procedure WriteLevel(OutPutNaam: String);

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
                               Implementation
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Var
(*) -/-\-/-\-/-\-/-\-/-\- (*)
   Code      : Integer;
   IniFile   : Text;
   IniPrim,
   IniSecnd  : String;
   RDPakHead : Array[0..7] of Char;

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
If not FileExists(Naam) then Exit;
OnderWerp     := '';
Level.Naam    := '';
Level.Special := 0;
Level.Licht   := 0;
With Items do Begin
  Muren := '������ô��'; { standaard muren }
  EnmyFaces := '!#@?&*';
  Leven := #3;           { Hartje }
  Bonus.Normaal := '�';
  Bonus.NorWaard := 1;
  Bonus.Mega := '$';
  Bonus.MegWaard := 50;
  Bonus.Negatief := '%';
  Bonus.NegWaard := -20;
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
     WriteLn('Erreur! Header Voud!');
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
     WriteLn('Erreur! Strings kloppen niet!');
     Close(LevelFile);
     ReadLevel := False;
     Exit;
  End;
BlockRead(LevelFile, Items.Bonus.Normaal, SizeOf(Items.Bonus.Normaal));
BlockRead(LevelFile, Items.Bonus.Mega, SizeOf(Items.Bonus.Mega));
BlockRead(LevelFile, Items.Bonus.Negatief, SizeOf(Items.Bonus.Negatief));

BlockRead(LevelFile, Items.Bonus.NorWaard, SizeOf(Items.Bonus.NorWaard));
BlockRead(LevelFile, Items.Bonus.MegWaard, SizeOf(Items.Bonus.MegWaard));
BlockRead(LevelFile, Items.Bonus.NegWaard, SizeOf(Items.Bonus.NegWaard));

BlockRead(LevelFile, Items.Leven, SizeOf(Items.Leven));
BlockRead(LevelFile, Wezen[1].Face, SizeOf(Wezen[1].Face));
BlockRead(LevelFile, Items.Bomb, SizeOf(Items.Bomb));

BlockRead(LevelFile, Level.Collect, SizeOf(Level.Collect));
BlockRead(LevelFile, Level.AantEnemy, SizeOf(Level.AantEnemy));
BlockRead(LevelFile, Level.AantTele, SizeOf(Level.AantTele));
BlockRead(LevelFile, Level.Lichten, SizeOf(Level.Lichten));
BlockRead(LevelFile, Level.Kleur, SizeOf(Level.Kleur));

BlockRead(LevelFile, Wezen[0].x, SizeOf(Wezen[0].x));
BlockRead(LevelFile, Wezen[0].y, SizeOf(Wezen[0].y));

BlockRead(LevelFile, Wezen[0].Special, SizeOf(Wezen[0].Special));
Wezen[0].TeleAble := BitAan(Wezen[0].Special, 6);
BlockRead(LevelFile, Wezen[0].Licht, SizeOf(Wezen[0].Licht));

BlockRead(LevelFile, Level.Special, SizeOf(Level.Special));
BlockRead(LevelFile, Level.Licht, SizeOf(Level.Licht));


BlockRead(LevelFile, CheckChar, SizeOf(PakSep));
  If CheckChar <> PakSep then Begin
     WriteLn('Erreur! Level settings kloppen niet!');
     Close(LevelFile);
     ReadLevel := False;
     Exit;
  End;
If Level.AantEnemy > 0 then Begin
  For NMITeller := 0 to Level.AantEnemy do Begin
      BlockRead(LevelFile, Wezen[NMITeller+2].X,
                      SizeOf(Wezen[NMITeller+2].X));
      BlockRead(LevelFile, Wezen[NMITeller+2].Y,
                      SizeOf(Wezen[NMITeller+2].Y));
      BlockRead(LevelFile, Wezen[NMITeller+2].Soort,
                      SizeOf(Wezen[NMITeller+2].Soort));
      Wezen[NMITeller+2].Face := Items.EnmyFaces[1+Wezen[NMITeller+2].Soort];
      Inc(Wezen[NMITeller+2].Soort, 2);
      BlockRead(LevelFile, Wezen[NMITeller+2].Richting,
                      SizeOf(Wezen[NMITeller+2].Richting));
      BlockRead(LevelFile, Wezen[NMITeller+2].Speed,
                      SizeOf(Wezen[NMITeller+2].Speed));

      BlockRead(LevelFile, Wezen[NMITeller+2].Special,
                      SizeOf(Wezen[NMITeller+2].Special));
      Wezen[NMITeller+2].TeleAble := BitAan(Wezen[NMITeller+2].Special, 0);

      BlockRead(LevelFile, Wezen[NMITeller+2].Licht,
                      SizeOf(Wezen[NMITeller+2].Licht));

{      WriteLn(Wezen[NMITeller+1].Special);
      WriteLn(Wezen[NMITeller+1].Licht);   }

  End;
End;

BlockRead(LevelFile, CheckChar, SizeOf(PakSep));
  If CheckChar <> PakSep then Begin
     WriteLn('VouD Vijanden kloppen niet!');
     Close(LevelFile);
     ReadLevel := False;
     Exit;
  End;
If Level.AantTele > 0 then Begin
  For NMITeller := 0 to Level.AantTele-1 do Begin
      BlockRead(LevelFile, Items.TeleStrt[NMITeller].x,
                           SizeOf(Items.TeleStrt[NMITeller].x));
      BlockRead(LevelFile, Items.TeleStrt[NMITeller].y,
                           SizeOf(Items.TeleStrt[NMITeller].y));
      BlockRead(LevelFile, Items.TeleEind[NMITeller].x,
                           SizeOf(Items.TeleEind[NMITeller].x));
      BlockRead(LevelFile, Items.TeleEind[NMITeller].y,
                           SizeOf(Items.TeleEind[NMITeller].y));
  End;
End;
If Level.Lichten > 0 then Begin
  For NMITeller := 0 to Level.Lichten-1 do Begin
      BlockRead(LevelFile, Items.Licht[NMITeller].x,
                           SizeOf(Items.Licht[NMITeller].x));
      BlockRead(LevelFile, Items.Licht[NMITeller].y,
                           SizeOf(Items.Licht[NMITeller].y));
      BlockRead(LevelFile, Items.Licht[NMITeller].typ,
                           SizeOf(Items.Licht[NMITeller].typ));
  End;
End;
If Level.Kleur > 0 then Begin
  For NMITeller := 0 to Level.Kleur-1 do Begin
      BlockRead(LevelFile, Items.Kleur[NMITeller].x,
                           SizeOf(Items.Kleur[NMITeller].x));
      BlockRead(LevelFile, Items.Kleur[NMITeller].y,
                           SizeOf(Items.Kleur[NMITeller].y));
      BlockRead(LevelFile, Items.Kleur[NMITeller].typ,
                           SizeOf(Items.Kleur[NMITeller].typ));
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
If IncMuziek = 0 then Begin
Close(LevelFile);
End;

If Level.Naam = '' then Begin
   Str(Level.Nr, Level.Naam);
   Level.Naam := 'Level '+Level.Naam;
End;
if BitAan(Level.Special, 7) then Level.Licht := 1;
if BitAan(Level.Special, 6) then Level.Licht := 2;

Inc(Wezen[0].Y,2);
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

BlockWrite(LevelFile, Items.Bonus.Normaal, SizeOf(Items.Bonus.Normaal));
BlockWrite(LevelFile, Items.Bonus.Mega, SizeOf(Items.Bonus.Mega));
BlockWrite(LevelFile, Items.Bonus.Negatief, SizeOf(Items.Bonus.Negatief));

BlockWrite(LevelFile, Items.Bonus.NorWaard, SizeOf(Items.Bonus.NorWaard));
BlockWrite(LevelFile, Items.Bonus.MegWaard, SizeOf(Items.Bonus.MegWaard));
BlockWrite(LevelFile, Items.Bonus.NegWaard, SizeOf(Items.Bonus.NegWaard));

BlockWrite(LevelFile, Items.Leven, SizeOf(Items.Leven));
BlockWrite(LevelFile, Wezen[1].Face, SizeOf(Wezen[1].Face));
BlockWrite(LevelFile, Items.Bomb, SizeOf(Items.Bomb));

BlockWrite(LevelFile, Level.Collect, SizeOf(Level.Collect));
BlockWrite(LevelFile, Level.AantEnemy, SizeOf(Level.AantEnemy));
BlockWrite(LevelFile, Level.AantTele, SizeOf(Level.AantTele));
BlockWrite(LevelFile, Level.Lichten, SizeOf(Level.Lichten));
BlockWrite(LevelFile, Level.Kleur, SizeOf(Level.Kleur));

BlockWrite(LevelFile, Wezen[0].x, SizeOf(Wezen[0].x));
BlockWrite(LevelFile, Wezen[0].y, SizeOf(Wezen[0].y));

  Wezen[0].Special := MaakByte(Wezen[0].Spc[6], Wezen[0].Spc[1],
            Wezen[0].Spc[2], Wezen[0].Spc[3], Wezen[0].Spc[4],
            Wezen[0].Spc[5], Wezen[0].TeleAble, Wezen[0].Spc[7]);

BlockWrite(LevelFile, Wezen[0].Special, SizeOf(Wezen[0].Special));
BlockWrite(LevelFile, Wezen[0].Licht, SizeOf(Wezen[0].Licht));

BlockWrite(LevelFile, Level.Special, SizeOf(Level.Special));
BlockWrite(LevelFile, Level.Licht, SizeOf(Level.Licht));

BlockWrite(LevelFile, PakSep, SizeOf(PakSep));

If Level.AantEnemy > 0 then Begin  { De Vijanden }
  PickCount := 0;
  For PickCount := 0 to Level.AantEnemy do Begin
      BlockWrite(LevelFile, Wezen[PickCount+2].X,
                      SizeOf(Wezen[PickCount+2].X));
      BlockWrite(LevelFile, Wezen[PickCount+2].Y,
                      SizeOf(Wezen[PickCount+2].Y));
      BlockWrite(LevelFile, Wezen[PickCount+2].Soort,
                      SizeOf(Wezen[PickCount+2].Soort));
      BlockWrite(LevelFile, Wezen[PickCount+2].Richting,
                      SizeOf(Wezen[PickCount+2].Richting));
      BlockWrite(LevelFile, Wezen[PickCount+2].Speed,
                      SizeOf(Wezen[PickCount+2].Speed));
      Wezen[PickCount+2].Special :=
                MaakByte(Wezen[PickCount+2].TeleAble,
                         Wezen[PickCount+2].spc[1],
                         Wezen[PickCount+2].spc[2],
                         Wezen[PickCount+2].spc[3],
                         Wezen[PickCount+2].spc[4],
                         Wezen[PickCount+2].spc[5],
                         Wezen[PickCount+2].spc[6],
                         Wezen[PickCount+2].spc[7]);
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

If Level.AantTele > 0 then Begin
  PickCount := 0;
  For PickCount := 1 to Level.AantTele do Begin
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

If Level.Lichten > 0 then Begin
  PickCount := 0;
  For PickCount := 1 to Level.Lichten do Begin

      BlockWrite(LevelFile, Items.Licht[PickCount],
                             SizeOf(Items.Licht[PickCount]));
  End;
End;

If Level.Kleur > 0 then Begin
  PickCount := 0;
  For PickCount := 1 to Level.Kleur do Begin
      BlockWrite(LevelFile, Items.Kleur[PickCount],
                             SizeOf(Items.Kleur[PickCount]));
  End;
End;

BlockWrite(LevelFile, PakSep, SizeOf(PakSep));
BlockWrite(LevelFile, Level.Scherm, 22*160);

If FileExists(Level.Muziek) then NMINaam := 1 else NMINaam := 0;
BlockWrite(LevelFile, NMINaam, 1);

If NMINaam = 1 then Begin
   Write('(Inserting Music File)..');
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


Begin
End.