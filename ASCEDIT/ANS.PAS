Unit ANS; {Ansi / Text Screen lib Started on : 21-5-1997}

interface

uses dos;

Type TAnsScreen = Array[0..4000] of Byte;
     AttrType   = (Blinking,HighInt);

var
   Screen         : Array[0..10] of ^TAnsScreen;

Function GetChr (x,y : byte) : char;

Procedure fasttext(x, y : word; col : byte; what : string);
{New 21-5-1997}
Procedure CopScrn(ScrNum : Byte);
{New 21-5-1997}
Procedure PlceScrn(ScrNum : Byte);
{New 21-5-1997}
Procedure SelectAttribute(Attribute: AttrType);
{New 20-6-1997}
Procedure ChCol(X, Y, Col : Byte);
{New 27-9-1997}
Implementation

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Function GetChr (x,y : byte) : char;
Begin
GetChr := CHR(Mem[$B800:((Y*80)+X)*2-162]);
end; {GetChr}

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

Procedure fasttext(x, y : word; col : byte; what : string); Assembler;
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

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Procedure CopScrn(ScrNum : Byte);
Var K : Integer;
Begin
For K := 0 to 4000 do
    Screen[ScrNum]^[K]:= MEM[$B800:K];
end;

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Procedure ChCol(X, Y, Col : Byte);
Var K : Integer;
Begin
K := ((Y-1) * 160) + (X - 1) * 2 + 1;
MEM[$B800:K] := Col;
end;

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

Procedure PlceScrn(ScrNum : Byte);
Var K : Integer;
Begin
{For K := 0 to 4000 do
    MEM[$B800:K] := Screen[ScrNum]^[K];}
    Move(Screen[ScrNum]^[0], Mem[$B800:0], 4000);
end;

{<(*[--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ---]*)>}

end.