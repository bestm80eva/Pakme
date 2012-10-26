Program PakC; { Pakme Level Compiler }

uses Dos, Crt, PkmForm;

Const
      NMImax = 3;
      NMI_ID : Array[0..NMImax] of string =
               ('JUDITH',
                'WOUTER',
                'MATTHIJS',
                'SANDERSMEENK');
      Titel1 = 'PakZe!!! PakMe Level Compiler!! <THAiSi ^ TaP>';
(*      Right = 0;
      Left  = 1;
      Up    = 2;
      Down  = 3;
      MaxEnemy = 20;
      MaxLicht = 10;
      MaxTele = 5;
      MaxChange = 10;}
      PakHead : Array[0..7] of Char = '<PakC'+#1+#0+'>';
      PakSep  : Char = ';';
{--}(* *)
(*
Type
     TelePrt = Array [0..1] of Byte;
     Lichtje = Array [0..2] of Byte;
     { gegevens van een vijand }
     tEnemy = Record
       X        : Byte;      { X }
       Y        : Byte;      { X }
       Soort    : Byte;      { X }
       Richting : Byte;      { X }
       Wait     : Word;
       Speed    : Word;      { X }
       Licht    : Byte;
       Spc      : Array [0..7] of Boolean;
       Special  : Byte;
     End;

     tItems = Record
       TeleStrt : Array [0..MaxTele] of TelePrt;
       TeleEind : Array [0..MaxTele] of TelePrt;
       Licht    : Array [0..MaxLicht] of Lichtje;
       VerKleur : Array [0..MaxChange] of Lichtje;
       Muren     : String;   { X }
       EnmyFaces : String;   { X }
       Leven,                { X }
       Continue,             { X }
       Holo,                 { X }
       Bomb      : Char;     { X }
       Bonus     : Record
         Normaal  : Char;    { X }
         NorWaard : Integer; { X }
         Mega     : Char;    { X }
         MegWaard : Integer; { X }
         Negatief : Char;    { X }
         NegWaard : Integer; { X }
       End;
     End;
     TextScherm = Array[0..3999] of Byte;
     tPlayer = Record
       Gezicht  : Char;      { X }
       X        : Byte;      { X }
       Y        : Byte;      { X }
       Spc      : Array [0..7] of Boolean;
       Licht    : Byte;
       Special  : Byte;
       Levens   : Byte;
       LevWaard : Integer;
       Continue : Byte;
       Richting : Byte;
     End;
     tLevel = Record
       Licht  : Byte;
       Naam   : String; { X }
       Nr     : Byte;
       Muziek : String;
       Scherm : TextScherm;
       Ofs,
       Seg    : Word;
     End;*)
{--}

Var
    NMINaam       : Byte;
    OutPutNaam    : String;
(*    OutPutFile    : File;*)
    SchermNaam    : String;
    OnderWerp     : String;
    SchermBestand : File;
    Naam          : String;
    Holo          : Byte; { aantal holo's in een level }
    IniFile       : Text;
    IniPrim,
    IniSecnd      : String;
{    Level         : tLevel;      { The Game Stuff }
{    Speler        : tPlayer;}
{    Items         : tItems;}
    Code          : Integer;
{    Vijand        : Array[0..MaxEnemy] of tEnemy;}
{    AantTele      : Byte;
    AantEnemy     : Byte;        { X }
{    PickBonus     : Word;        { X } { aantal geld dat verzameld moet worre }
    PickCount     : LongInt;
{    LvlSpc        : Array [0..7] of Boolean;}

{    LevelSpecial  : Byte; { Licht en andere groovy FX }

{    Lichten       : Byte;
    VerKlr        : Byte; }

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
{ Zet een string in hoofdletters ...}
Function HoofdLetters(Text : String) : String;
Var l_TijdLoper : Byte;
begin
  For l_TijdLoper := 1 to Length(Text) do
    Text[l_TijdLoper] := UpCase(Text[l_TijdLoper]);
  HoofdLetters := Text;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function KleurLicht : Byte;
Begin
    KleurLicht := 7;
    IniSecnd := HoofdLetters(IniSecnd);
    if IniSecnd = 'ZWART' then KleurLicht := 0;
    if IniSecnd = 'BLAUW' then KleurLicht := 1;
    if IniSecnd = 'GROEN' then KleurLicht := 2;
{    if IniSecnd = '' then KleurLicht := 1;}
    if IniSecnd = 'ROOD'  then KleurLicht := 4;
    if IniSecnd = 'PAARS' then KleurLicht := 5;
    if IniSecnd = 'BRUIN' then KleurLicht := 6;
    if IniSecnd = 'WIT'   then KleurLicht := 7;
    if IniSecnd = 'GRIJS' then KleurLicht := 8;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
{ Leest een regel uit inifile en splitst 'm in inisecnd & iniprim ... }
Procedure GetLine;
Var l_TempStr : String;
    l_GoedRegel : Boolean;
    l_TijdLoper : Byte;
Begin
  Repeat
    l_GoedRegel := False;
    ReadLn(IniFile, l_TempStr);
    If Pos(':', l_TempStr)>0 then l_GoedRegel := True;
  Until Eof(IniFile) or l_GoedRegel;
  IniPrim  := Copy(l_TempStr, 1, Pos(':', l_TempStr)-1);
  IniPrim  := HoofdLetters(IniPrim);
  IniSecnd := Copy(l_TempStr, Pos(':', l_TempStr)+1, Length(l_TempStr));
  IniPrim  := StripSpace(IniPrim);
  IniSecnd := StripSpace(IniSecnd);
End;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
{ hoe gebruikt men deze compiler }
Procedure Help(Regel : String);
Begin
If Regel <> '' then Begin
   WriteLn('Fout : '+Regel);
End;
WriteLn;
WriteLn('Gebruik: PakC Level.txt');
WriteLn('  N.B. Het bestand Level.txt moet dan wel bestaan');
WriteLn(' zo ingewikkeld is dat toch niet?');
Halt(0);
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
{ de heuse Pakme, pakme compiler }

Begin
TextColor(7);
TextBackGround(0);
{ClrScr;}
WriteLn(Titel1);
WriteLn;

If ParamStr(1) = '' then Help('Geen ParaMeetz!');
Naam := ParamStr(1);
If not FileExists(Naam) then Help('Bestandje is niet aanwezig!');

Write('Reading Text-Info file or sumtin like that....');

OnderWerp    := '';
With Level do Begin
  Naam   := '';
  Licht  := 7;
  AantEnemy := 0;
End;
Wezen[0].Licht := 7;
SchermNaam   := '';
For PickCount := 2 to MaxEnemy+2 do Begin
  Wezen[PickCount].Licht := 9;
End;

With Items do Begin
  Muren := '³ÄÀ¿ÙÚÃ´ÂÁ'; { standaard muren }
  EnmyFaces := '!#@?&*';
    { bij nieuwe vijanden moet hier dus een teken aan toegevoegd worre... }

  Leven    := #03;       { Hartje }
{  Continue := #19;       { Dubbel uitroepteken }
{  Holo     := #01;}
  Bomb     := #15;
  Bonus.Normaal  := 'Ÿ';
  Bonus.NorWaard := 1;
  Bonus.Mega     := '$';
  Bonus.MegWaard := 50;
  Bonus.Negatief := '%';
  Bonus.NegWaard := -20;
End;
With Wezen[0] do Begin
 X   := 1;
 Y   := 1;
End;
Level.Spec[0] := False;
Level.Spec[1] := False;
Level.Spec[2] := False;
Level.Spec[3] := False;
Level.Spec[4] := False;
Level.Spec[5] := False;
Level.Spec[6] := False;
Level.Spec[7] := False;

Assign(IniFile, Naam);
Reset(IniFile);
Inc(Level.Nr);
Repeat
  GetLine;
{
  WriteLn(Onderwerp);
  WriteLn(IniPrim);
  WriteLn(IniSecnd);
  ReadKey;
}
  If (OnderWerp = '') and (IniPrim = '') and (IniSecnd <> '') then
     OnderWerp := HoofdLetters(IniSecnd);
{  (*------------- }
  If OnderWerp = 'LEVEL'   then Begin
     If IniPrim = 'NAAM'   then Level.Naam := IniSecnd;
     If IniPrim = 'SCHERM' then SchermNaam := IniSecnd;
     If IniPrim = 'MUREN'  then Items.Muren  := IniSecnd;
     If IniPrim = 'MUZIEK'  then Level.Muziek  := IniSecnd;
     If IniPrim = 'FACES'  then Items.EnmyFaces  := IniSecnd;
     If IniPrim = 'BNSW_NORMAAL' then Val(IniSecnd, Items.Bonus.NorWaard, code);
     If IniPrim = 'BNSW_MEGA' then Val(IniSecnd, Items.Bonus.MegWaard, code);
     If IniPrim = 'BNSW_NEGATIEF' then Val(IniSecnd, Items.Bonus.NegWaard, code);
     If IniPrim = 'BNSU_NORMAAL' then Items.Bonus.Normaal := IniSecnd[1];
     If IniPrim = 'BNSU_MEGA' then Items.Bonus.Mega := IniSecnd[1];
     If IniPrim = 'BNSU_NEGATIEF' then Items.Bonus.Negatief := IniSecnd[1];
     If IniPrim = 'LICHT' then Begin
        Level.Licht := KleurLicht;
{
        IniSecnd := HoofdLetters(IniSecnd);
        if IniSecnd = 'ZWART' then Level.Licht := 0;
        if IniSecnd = 'BLAUW' then Level.Licht := 1;
        if IniSecnd = 'GROEN' then Level.Licht := 2;
        if IniSecnd = 'ROOD'  then Level.Licht := 4;
        if IniSecnd = 'WIT'   then Level.Licht := 7;
        if IniSecnd = 'GRIJS' then Level.Licht := 8;
}
     End;
  End;
{*-------------                }
  If OnderWerp = 'SPELER' then Begin
     If IniPrim = 'X_START' then Val(IniSecnd,Wezen[0].X,Code);
     If IniPrim = 'Y_START' then Val(IniSecnd,Wezen[0].Y,Code);
     If IniPrim = 'LICHT' then Begin
        Wezen[0].Licht := KleurLicht;
{        IniSecnd := HoofdLetters(IniSecnd);
        if IniSecnd = 'BLAUW' then Speler.Licht := 1;
        if IniSecnd = 'GROEN' then Speler.Licht := 2;
        if IniSecnd = 'ROOD'  then Speler.Licht := 4;
        if IniSecnd = 'WIT'   then Speler.Licht := 7;
        if IniSecnd = 'GRIJS' then Speler.Licht := 8;
}
     End;
     If IniPrim = 'TELEPORT' then Wezen[0].TeleAble := True;
  End;
{*-------------                }
  If OnderWerp = 'TELEPORTER' then Begin
     If IniPrim = 'X_START' then Begin
        Inc(Level.AantTele);
        Val(IniSecnd,Items.TeleStrt[Level.AantTele].x,Code);
     End;
     If IniPrim = 'Y_START' then
        Val(IniSecnd,Items.TeleStrt[Level.AantTele].y,Code);
     If IniPrim = 'X_EIND' then
        Val(IniSecnd,Items.TeleEind[Level.AantTele].x,Code);
     If IniPrim = 'Y_EIND' then
        Val(IniSecnd,Items.TeleEind[Level.AantTele].y,Code);
  End;
{*-------------                }
  If OnderWerp = 'LICHT' then Begin
     If IniPrim = 'X' then Begin
        Inc(Level.Lichten);
        Val(IniSecnd,Items.Licht[Level.Lichten].x,Code);
        Items.Licht[Level.Lichten].typ := 9;
     End;
     If IniPrim = 'Y' then
        Val(IniSecnd,Items.Licht[Level.Lichten].y,Code);
     If IniPrim = 'KLEUR' then Begin
        Items.Licht[Level.Lichten].typ := KleurLicht;
     End;
  End;
{*-------------                }
  If OnderWerp = 'VERKLEUR' then Begin
     If IniPrim = 'X' then Begin
        Inc(Level.Kleur);
        Val(IniSecnd,Items.Kleur[Level.Kleur].x,Code);
{        Inc(Items.VerKleur[VerKlr][0]);}
        Items.Kleur[Level.Kleur].typ := 9;
     End;
     If IniPrim = 'Y' then Begin
        Val(IniSecnd,Items.Kleur[Level.Kleur].y,Code);
        Inc(Items.Kleur[Level.Kleur].y,2);
     End;
     If IniPrim = 'KLEUR' then Begin
        Items.Kleur[Level.Kleur].typ := KleurLicht;
{
        IniSecnd := HoofdLetters(IniSecnd);
        if IniSecnd = 'ZWART' then Items.VerKleur[VerKlr][2] := 0;
        if IniSecnd = 'BLAUW' then Items.VerKleur[VerKlr][2] := 1;
        if IniSecnd = 'GROEN' then Items.VerKleur[VerKlr][2] := 2;
        if IniSecnd = 'ROOD'  then Items.VerKleur[VerKlr][2] := 4;
        if IniSecnd = 'GRIJS' then Items.VerKleur[VerKlr][2] := 8;
        if IniSecnd = 'WIT'   then Items.VerKleur[VerKlr][2] := 7;
}
     End;
  End;
{*-------------                }
  If OnderWerp = 'VIJAND' then Begin
     If Wezen[Level.AantEnemy+2].Speed = 0 then
        Wezen[Level.AantEnemy+2].Speed := 100;
     If IniPrim = 'SNELHEID' then
        Val(IniSecnd, Wezen[Level.AantEnemy+2].Speed,Code);
     If IniPrim = 'RICHTING' then Begin
        If HoofdLetters(IniSecnd) = 'OMHOOG' then
           Wezen[Level.AantEnemy+2].Richting := Up;
        If HoofdLetters(IniSecnd) = 'OMLAAG' then
           Wezen[Level.AantEnemy+2].Richting := Down;
        If HoofdLetters(IniSecnd) = 'LINKS' then
           Wezen[Level.AantEnemy+2].Richting := Left;
        If HoofdLetters(IniSecnd) = 'RECHTS' then
           Wezen[Level.AantEnemy+2].Richting := Right;
     End;
     If IniPrim = 'X_START' then Val(IniSecnd, Wezen[Level.AantEnemy+2].X,Code);
     If IniPrim = 'Y_START' then Begin
                                   Val(IniSecnd, Wezen[Level.AantEnemy+2].Y,Code);
                                   Inc(Wezen[Level.AantEnemy+2].Y,3);
                                 End;
     If IniPrim = 'TYPE' then Begin
       For NMInaam := 0 to NMImax do
         If HoofdLetters(IniSecnd) = NMI_ID[NMInaam] then
            Wezen[Level.AantEnemy+2].Soort := NMInaam;
      Inc(Level.AantEnemy);
     End;
     If IniPrim = 'LICHT' then Begin
        Wezen[Level.AantEnemy+2].Licht := KleurLicht;
{
        IniSecnd := HoofdLetters(IniSecnd);
        if IniSecnd = 'BLAUW' then Wezend[AantEnemy].Licht := 1;
        if IniSecnd = 'WIT' then Vijand[AantEnemy].Licht := 7;
        if IniSecnd = 'GROEN' then Vijand[AantEnemy].Licht := 2;
        if IniSecnd = 'ROOD' then Vijand[AantEnemy].Licht := 4;}
        if Wezen[Level.AantEnemy+2].Licht = 9 then
           Wezen[Level.AantEnemy+2].Licht := 0;

     End;
     If IniPrim = 'TELEPORT' then Wezen[Level.AantEnemy+2].TeleAble := True;
  End;
{*-------------                } (*  *)
  If (OnderWerp <> '') and (IniPrim = '') and
     (HoofdLetters(IniSecnd) = 'END') then OnderWerp := '';

Until Eof(IniFile);
Close(IniFile);
WriteLn('...Dunnit');
If Level.Naam = '' then Begin
   Str(Level.Nr, Level.Naam);
   Level.Naam := 'Level '+Level.Naam;
End;
If SchermNaam = '' then SchermNaam := Copy(Naam, 1, Pos('.', Naam))+'SCR';
If Not FileExists(SchermNaam) then Begin
  Help('Van "'+SchermNaam+'" aanwezigheid zeer op prijs gesteld!');
End;
Write('Reading stunning graphic file ('+SchermNaam+')...');
Assign(SchermBestand, SchermNaam);
Reset(SchermBestand, 1);
BlockRead(SchermBestand, Level.Scherm[0], 22*160);
Close(SchermBestand);
Level.Collect := 0;
PickCount     := 0;
Holo          := 0;
Wezen[1].Face := #1;
Repeat
    If Chr(Level.Scherm[PickCount]) = Items.Bonus.Normaal then Inc(Level.Collect);
    If Chr(Level.Scherm[PickCount]) = Wezen[1].Face then Inc(Holo);
    Inc(PickCount,2);
until PickCount >= (22*160);
WriteLn('Dunnit');
Level.Special := MaakByte(Level.Spec[7], Level.Spec[6],
                          Level.Spec[5], Level.Spec[4],
                          Level.Spec[3], Level.Spec[2],
                          Level.Spec[1], Level.Spec[0]);
{
Write('Speler : ', Speler.x,' ');
Write( Speler.y,' ');
Write( Speler.spc[0],' ');
Write( Speler.spc[1],' ');
Write( Speler.spc[2],' ');
Write( Speler.spc[3],' ');
Write( Speler.spc[4],' ');
Write( Speler.spc[5],' ');
Write( Speler.spc[6],' ');
WriteLn( Speler.spc[7]);
{}
WriteLn('Specials : ', Level.Special);
WriteLn('Teleporters : ',Level.AantTele);
WriteLn('Lichten : ',Level.Lichten);
WriteLn('Vijanden : ',Level.AantEnemy);
WriteLn('Bonussen : ',Level.Collect);
WriteLn('Holo''s : ', Holo);

OutPutNaam := Copy(ParamStr(1), 1, Pos('.', ParamStr(1)))+'PKM';
Write('Writing '+OutPutNaam+' ...');
WriteLevel(OutPutNaam);

WriteLn('Dunnit');
WriteLn('Klaar=klaas!');
{ReadKey;{}
End.

