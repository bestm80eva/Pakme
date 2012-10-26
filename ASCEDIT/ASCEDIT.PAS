Program Txt2Ans;

Uses Crt, Ans, dos;

Type AttrType   = (Blinking,HighInt);

Var Kleur  : Byte;
    ClrAuto: Boolean;
    Changed: Boolean;
    TxtBes : File;
    TxtNme : String[20];
    Xp, Yp : Byte;
    StartX : Byte;
    HCol   : Byte;
    LCol   : Byte;
    Inpt   : String[2];
    EditLn : String;
    Car    : Char;
    Modus  : Byte;
    TToets : Char;
    TScan  : Byte;

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Procedure WrteTxt(X, Y : Byte; Txt: String);
Var l_Tllr : Byte;
Begin
  For l_Tllr := 1 to Length(Txt) do Begin
    Mem[$B800:(((Y-1)*80)+(X-2+l_Tllr))*2] := Ord(Txt[l_Tllr]);
  End;
End;

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Function D_FileExists(FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
Var
   F: file;
begin
  {$I-}
  Assign(F, FileName);
  FileMode := 0;  { Set file access to read only }
  Reset(F); {Bestaat 'ie eigenlijk wel ?}
  Close(F);
  {$I+}
  D_FileExists := (IOResult = 0) and (FileName <> '');
end;  { FileExists }

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Procedure ScanKey;
{ Reads a key from the keyboard and converts 2 scan code escape
  sequences into 1 character. }
Var
  Ch : Char;

begin {Scans the key for virusses, you'll never know}
  TToets := ReadKey;
  if (TToets = #0) and KeyPressed then BEGIN
    Ch := ReadKey;
    if ord(Ch) < 128 then
      TScan := Ord(Ch) + 128;
  END;
end; { ScanKey }

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

PROCEDURE SelectAttribute(Attribute: AttrType);
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

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

function StrToBte(I: String): Byte;
var
 Bte  : Byte;
 Code : Integer;
begin
 Val(I, Bte, Code);
 If Code <> 0 then Bte := $0;
 StrToBte := Bte;
end; {Gekopieerd uit help}

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Begin
WriteLn('Asc-Edit v1.5 THAiSi ^ The Attic People, 1998');
WriteLn;
If ParamStr(1) = '' then BEGIN
  Write('Ans-Bestand: ');
  ReadLn(TxtNme);
End else
  TxtNme := ParamStr(1);
If TxtNme = '' then Begin
   WriteLn('Geen ASC naam gegeven!');
   Halt;
End;
If not d_FileExists(TxtNme) then Begin
 WriteLn('Bestand bestaat niet!');
 Halt;
End;

SelectAttribute(HighInt);
New(Screen[0]);
Assign (TxtBes, TxtNme);
Reset (TxtBes, 1);
BlockRead(TxtBes, Screen[0]^, 4000);
Close (TxtBes);
ClrScr;
PlceScrn(0);
Kleur := Screen[0]^[1];
ClrAuto := False;
CopScrn(0);
Modus := 0;
Xp := 1;
Yp := 1;
GotoXY(Xp, Yp);
Repeat
  TToets := #0;
  TScan := 0;
If KeyPressed then
   ScanKey;

If Modus = 0 then Begin { Kleur Mode }
  Case TToets of
      '1' : BEGIN { verander voor+achtergrond kleur }
              TexTBackGround(0);
              TextColor(7);
              CopScrn(0);
              GotoXY(1,1);
              Write('Voor-Kleur:');
              ReadLn(Inpt);
              HCOL := StrToBte(Inpt);
              Write('Achter-Kleur:');
              ReadLn(Inpt);
              LCOL := StrToBte(Inpt)*16;
              Kleur := HCol + LCol;
              PlceScrn(0);
            END;
      '2' : BEGIN { verander achtergrond kleur }
              TexTBackGround(0);
              TextColor(7);
              CopScrn(0);
              GotoXY(1,1);
              Write('Voor-Kleur:');
              ReadLn(Inpt);
              HCOL := StrToBte(Inpt);
              LCOL := (Kleur div 16)*16;
              Kleur := HCol + LCol;
              PlceScrn(0);
            END;
      '3' : BEGIN { verander vooorgrond kleur }
              TexTBackGround(0);
              TextColor(7);
              CopScrn(0);
              GotoXY(1,1);
              Write('Achter-Kleur:');
              ReadLn(Inpt);
              HCOL := Kleur - (Trunc(Kleur / 16) * 16);
              LCOL := StrToBte(Inpt)*16;
              Kleur := HCol + LCol;
              PlceScrn(0);
            END;
       'g' : Begin { Grab kleur }
               Kleur := MEM[$B800:((Yp-1) * 160) + (Xp - 1) * 2 + 1];
             End;
       'e' : Begin { ga naar edit modus }
              CopScrn(0);
              EditLn := '';
              TToets := #0;
              Modus := 1;
              StartX := Xp;
             end;
       'r' : Begin { Zet paste char in mem }
              CopScrn(0);
              FastText(1,1, $07, 'Enter Yer Char!');
              Car := ReadKey;
              PlceScrn(0);
             end;
       't' : Begin { Zet pasted char op scherm }
              Mem[$B800:((Yp*80)+Xp)*2-162] := Ord(Car);
              CopScrn(0);
             end;
       'Q' : Begin { Kleur automatisch }
              ClrAuto := Not ClrAuto;
              CopScrn(0);
             end;
       ' ' : Begin { Zet kleur neer }
              ClrAuto := False;
              ChCol(Xp,Yp, Kleur);
              CopScrn(0);
             end;
       'S' : Begin { Sla bestand op }
               Assign(TxtBes, TxtNme);
               Rewrite(TxtBes,1);
               BlockWrite(TxtBes,Screen[0]^, 4000);
               Close(TxtBes);
             End;
     else;
   End;
  Case TScan of
       200 : Dec(Yp);
       208 : Inc(Yp);
       203 : Dec(Xp);
       205 : Inc(Xp);
     else;
   End;
End;
If Modus = 1 then Begin   { Text - edit mode }
  Case TToets of
     #0  : ;
     #27 : Begin
             Modus := 0;
             TToets := #0;
             EditLn := '';
             PlceScrn(0);
           END;
      #8 : If Length(EditLn) > 0 then Begin
             Dec(Xp);
             EditLn := Copy(EditLn,1,Length(EditLn)-1);
             PlceScrn(0);
             WrteTxt(StartX, Yp, EditLn);
           End;
     #13 : Begin
            CopScrn(0);
            EditLn := '';
            Modus := 0;
           End;
     Else Begin
            EditLn := EditLn + TToets;
            Inc(Xp);
            PlceScrn(0);
            WrteTxt(StartX, Yp, EditLn);
          End;
   End;
End;

If Yp = 0 then Yp := 25;
If Xp = 0 then Xp := 80;
If Xp = 81 then Xp := 1;
If Yp = 26 then Yp := 1;
If ClrAuto then ChCol(Xp,Yp, Kleur);

GotoXY(Xp,Yp);
until TToets=#27;
ClrScr;
WriteLn('Save ?');
TToets := ReadKey;
If (TToets = 'y') or (TToets = 'Y') then Begin
 Write('Bestand: ');
 ReadLn(TxtNme);
 If TxtNme <> '' then Begin
   FileMode := 2;
   Assign(TxtBes, TxtNme);
   Rewrite(TxtBes,1);
   BlockWrite(TxtBes,Screen[0]^, 4000);
   Close(TxtBes);
 End;
End;
Dispose(Screen[0]);
End.