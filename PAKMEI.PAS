Unit PakMeI; { Initialization & File-Reader

  Leest het spel ini bestandje.
  kan binnekort misschien wel weg.
}
InterFace uses PkmForm; { bestands beschrijving van een level-file }

(*){ -/-\-/-\-/-\-/-\-/-\- }(*)
Type Persoon = (Real, Test); { Kijken of je kan lopen,
                               of werkelijk gaan lopen }
  AttrType   = (Blinking, HighInt); { staan we felle achtergrond kleuren
                                      toe of gaan ze dan knipperen }
    tInit = Object
      Private
        Code      : Integer; { aantal gelezen }
        IniFile   : Text;    { inifile }
        IniPrim,             { primair stukje van een zin }
        IniSecnd  : String;  { secundair stukje van een zin }
        Procedure GetLine;
      Public
        Constructor Create;
        Destructor Destroy;
        PROCEDURE SelectAttribute(Attribute: AttrType);
        Procedure ReadINIFile;
    End;

Var
   Vir_Ofs,            { Segment + Ofset van virtual screen }
   Vir_Seg   : Word;
   Level_Ofs,          { Segment + Ofset van level-achtergrond }
   Level_Seg   : Word;
   Fx_Seg,             { Segment + Ofset van lichtFX layer }
   Fx_Ofs    : Word;
   VirScr    : TextScherm; { het virtuele scherm }

   Muziek    : Boolean; { Staat muziek aan }
   Geluid    : Boolean; { Staat geluid aan }

   LiveStr,
   ContStr,
   ScoreStr  : String[18];
   Score     : LongInt;
   TillLife  : Integer;

   WachtMs   : LongInt;
   WachtSpd  : LongInt;
   WachtLng  : LongInt;

   Initialize : ^tInit;

Procedure Fasttext(x, y : word; col : byte; what : string);

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
                               Implementation
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
uses Dos, Crt;

(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                              Initialisatie
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Constructor tInit.Create;
Begin
  ReadINIFile;
  Vir_Ofs := Ofs(VirScr);
  Vir_Seg := Seg(VirScr);
  Level_Ofs := Ofs(level.Scherm);
  Level_Seg := Seg(level.Scherm);
End;

Destructor tInit.Destroy;
Begin

End;

Procedure tInit.GetLine;
{
  Haalt een regel uit en initialisatie bestandje
}
Var l_TempStr : String;
    l_GoedRegel : Boolean;
    l_TijdLoper : Byte;
Begin
  IniPrim := '';
  IniSecnd := '';
  Repeat
    l_GoedRegel := False;
    ReadLn(IniFile, l_TempStr);
    If Pos(':', l_TempStr)>0 then l_GoedRegel := True;
  Until Eof(IniFile) or l_GoedRegel;
  IniPrim  := Copy(l_TempStr, 1, Pos(':', l_TempStr)-1);
  IniPrim  := HoofdLetters(IniPrim);
  IniSecnd := Copy(l_TempStr, Pos(':', l_TempStr)+1, Length(l_TempStr));
  IniSecnd := HoofdLetters(IniSecnd);
  IniPrim  := StripSpace(IniPrim);
  IniSecnd := StripSpace(IniSecnd);
End;

Procedure tInit.ReadINIFile;
{
  Lees het initialisatie bestand
}
Var TmpBty : Byte;
Begin
  SelectAttribute(HighInt);
  Speler.Levens := 10;
  Speler.LevWaard := 1000;

  Geluid := True;
  Muziek := True;
  TmpBty := 2;
  If FileExists('PAKME.INI') then Begin
    Assign(IniFile, 'PAKME.INI');
    Reset(IniFile);
    Repeat
      GetLine;
      If (IniPrim = 'GELUID') and (IniSecnd = 'UIT') then Geluid := False;
      If (IniPrim = 'MUZIEK') and (IniSecnd = 'UIT') then Muziek := False;
      If (IniPrim = 'GEZICHT') and (Length(IniSecnd)<4) then
         Val(IniSecnd, TmpBty, Code);
    Until Eof(IniFile);
    Close(IniFile);
  End; { iF }
  WezenE[0].Face := Chr(TmpBty);
  TillLife := Speler.LevWaard;
End; { ReadIniFile }

PROCEDURE tInit.SelectAttribute(Attribute: AttrType);
{
  Zorg dat je hoge achtergrond kleuren kan gebruiken, of juist
  dat de hoge kleuren gaan knipperen
}
VAR
  Reg  :Registers;
BEGIN
  Reg.ah := $10;
  Reg.al := 3;
  CASE Attribute OF
    HighInt  : Reg.bl := 0;
    Blinking : Reg.bl := 1
    END;
  Intr($10,Reg)
END;

(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                           Altijd Handig
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)


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

End.