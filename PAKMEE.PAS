Unit PakMeE; { Enemy Lib: **************************************************

 Hier worden de vijand funcs gedumpt.
 de AI beschreven en navigatie door speelomgeving geregeld

 Oh ja, message handling en een paar teken functies staan hier ook

  ************************************************************************** }

Interface uses Crt, PakMeI, PakMeS, PkmForm;

Type tAI = Object
     { AI handling :
       Hoe gedragen de onderstaande schatjes zich
     }
       Private
         Gelopen   : Boolean;
         Direction : Array[0..3] of Boolean; { welke kant lopen we op :
                                               Noord Boven
                                               Zuid  Onder
                                               West  Links
                                               Oost  Rechts
                                             }
         Function Richtingen(Dude : Byte) : Byte;
         Procedure GaLopen(Dude : Byte);
       Public
         Procedure PlaatsPoppetje (Dude : Byte);
         Function CanWalk(Xas, Yas : Byte; Dude : Byte; Wie : Persoon) : Boolean;
         Procedure DoeEnemies;
         Procedure HoloPal;
         Procedure NMI0(Welke : Byte); { Judith       }
         Procedure NMI1(Welke : Byte); { Wouter       }
         Procedure NMI2(Welke : Byte); { Matthijs     }
         Procedure NMI3(Welke : Byte); { SanderSmeenk }
         Procedure NMI4(Welke : Byte); { Martijn      }
         Constructor Create;
         Destructor  Destroy;
     End;
     tMessage = Object
     { Bericht handling:
       Laat berichten en evt. error messages zien
     }
       public
         MessageStr : String; { " je hebt een holo! "  }
         MessWait   : Word;   { hoelang blijft message staan }
         MessMove   : Word;   { hoesnel schuift 'ie }
         WarningStr : String; { " Sound engine not found! " }
         WarnWait   : Word;   { hoelang blijft message staan }
         WarnMove   : Word;   { hoesnel schuift 'ie }
         Procedure DoeMessage;
         Procedure NewMessage(Wat : String);
         Procedure DoeWarning;
         Procedure NewWarning(Wat : String);
         Function SPC(Aantal : Byte; Teken : Char): String;
         Constructor Create;
         Destructor Destroy;
       End;

Var
    AI         : ^tAI;
    Message    : ^tMessage;


(*  -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/-  *)
                               Implementation
uses PakMeG;
(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\ ^^ /\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                 Overige kleine tools & Teken funk-ties
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\ ^^ /\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Function GetColor(X,Y: Byte; SegM, Ofst : Word) : Byte;
{
  --Word gebruikt door Plaatspoppetje -> moet naar renderen toe
  --XY moet aangepast op flexibele speelvelden
  Haal een Kleur van het scherm
}
Begin
  GetColor := Mem[SegM:Ofst+((Y-1)*160)+((X-1)*2)+1];
End;


Function GetChar(X,Y: Byte; SegM, Ofst : Word) : Char;
{
  --Moet aangepast worden voor flexibele speelvelden
  --word gebruikt voor zoeken van muren & navigatie
  Haal een letter van 't scherm
}
Begin
  GetChar := Chr(Mem[SegM:Ofst+((Y-1)*160)+((X-1)*2)]);
End;

Procedure SetChar(karakter : Char; X,Y: Byte; SegM, Ofst : Word);
{
  --word gebruikt om veranderingen in het level aan te passen
  -(pakken van bonussen/holo's en zo)
  --moet ook nog aangepast worden op flex-velden
  Plaats een letter op het scherm
}
Begin
  Mem[SegM:Ofst+((Y-1)*160)+((X-1)*2)] := Ord(Karakter);
End;


(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                                MESSAGE Handling
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Constructor tMessage.Create;
Begin
  MessageStr := ' ';
  MessWait   := 0;   { hoelang blijft message staan }
  MessMove   := 0;   { hoesnel schuift 'ie }
  WarningStr := ' ';
  WarnWait   := 0;   { hoelang blijft message staan }
  WarnMove   := 0;   { hoesnel schuift 'ie }
End;

Destructor tMessage.Destroy;
Begin
{  WriteLn('Messages killed.');}
End;

Function tMessage.SPC(Aantal : Byte; Teken : Char): String;
{
  Kleine tool om een rijtje spaties enzo te maken
}
var TmpStr : String;
Begin
  TmpStr := '';
  While (Length(TmpStr) < Aantal) do TmpStr := TmpStr + Teken;
  SPC := TmpStr;
end;

Procedure tMessage.NewMessage(Wat : String);
{
  Plaats een nieuw bericht op de Message regel: bv. "Je hebt een Holo!"
}
Begin
  MessageStr := '';
  MessageStr := Wat + SPC(60-Length(Wat),' ');
  MessWait   := 0;
End;

Procedure tMessage.DoeMessage;
{
  Zorgt dat het bericht Message een tijdje blijft staan en daarna van het
  scherm schuift
}
Begin
  Inc(MessWait);
  If MessWait > 350 then Begin
     inc(MessMove);
     If MessMove > 20 then Begin
       MessageStr := ' ' + Copy(MessageStr, 1, 59);
       MessMove := 0;
     End;
  End;
End;

Procedure tMessage.NewWarning(Wat : String);
{
 Plaats een nieuwe errormessage :)
}
Begin
  WarningStr := '';
  WarningStr := Wat + SPC(80-Length(Wat),' ');
  WarnWait   := 0;
End;

Procedure tMessage.DoeWarning;
{
  Zorgt dat het bericht Warning een tijdje blijft staan en daarna van het
  scherm schuift
}
Begin
  Inc(WarnWait);
  If WarnWait > 350 then Begin
     inc(WarnMove);
     If WarnMove > 20 then Begin
       WarningStr := ' ' + Copy(WarningStr, 1, 79);
       WarnMove := 0;
     End;
  End;
End;

(*)
 * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                         NMI funk-s, en AI "scripting"
 * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Function tAI.Richtingen(Dude : Byte) : Byte;
{
  Hoeveel richingen kan Actor "Dude" oplopen,
  en deze richtingen worden op true of false gezet in de VAR Direction ^^
}
var Bestemming : Byte;
Begin
 Bestemming := 0;
 If CanWalk(Wezen[Dude].x+1, Wezen[Dude].y, Dude, Test) then
             Begin
               Inc(Bestemming);
               Direction[wRight] := True;
             End else
               Direction[wRight] := False;
 If CanWalk(Wezen[Dude].x-1, Wezen[Dude].y, Dude, Test) then
             Begin
               Inc(Bestemming);
               Direction[wLeft] := True;
             End else
               Direction[wLeft] := False;
 If CanWalk(Wezen[Dude].x, Wezen[Dude].y-1, Dude, Test) then
             Begin
               Inc(Bestemming);
               Direction[wUp] := True;
             End else
               Direction[wUp] := False;
 If CanWalk(Wezen[Dude].x, Wezen[Dude].y+1, Dude, Test) then
             Begin
               Inc(Bestemming);
               Direction[wDown] := True;
             End else
               Direction[wDown] := False;

 Richtingen := Bestemming;
End;

Procedure tAI.GaLopen(Dude : Byte);
{
  Laat Actor richting op lopen waar hij heen wil,
  en maak iemand dood of pak bonussen
}
Begin
  Case Wezen[Dude].Richting Of
   wRight : If CanWalk(Wezen[Dude].x+1, Wezen[Dude].y, Dude, Test) then Begin
              CanWalk(Wezen[Dude].x+1, Wezen[Dude].y, Dude, Real);
              Gelopen := True;
           End;
   wLeft : If CanWalk(Wezen[Dude].x-1, Wezen[Dude].y, Dude, Test) then Begin
             CanWalk(Wezen[Dude].x-1, Wezen[Dude].y, Dude, Real);
             Gelopen := True;
          End;
   wUp : If CanWalk(Wezen[Dude].x, Wezen[Dude].y-1, Dude, Test) then Begin
             CanWalk(Wezen[Dude].x, Wezen[Dude].y-1, Dude, Real);
           Gelopen := True;
        End;
   wDown : If CanWalk(Wezen[Dude].x, Wezen[Dude].y+1, Dude, Test) then Begin
             CanWalk(Wezen[Dude].x, Wezen[Dude].y+1, Dude, Real);
             Gelopen := True;
          End;
  End;
End;

Procedure tAI.PlaatsPoppetje (Dude : Byte);
{
  --Dit moet bij renderen staan! niet bij AI!
  Zorg dat ACTOR met de juiste kleuren op het juiste vakje getekend word
}
Var KlrTmp : Byte;
Begin
  KlrTmp := GetColor(Wezen[Dude].x, Wezen[Dude].y, Level_Seg, Level_Ofs);
  KlrTmp := (KlrTmp div 16);
  If (Dude = 0) and (Level.InvTijd > 0) then Begin
    If KlrTmp > 7 then KlrTmp := ((KlrTmp-8) * 16) + 8
                  else KlrTmp := (KlrTmp * 16) + 8;
  End else Begin
    If KlrTmp > 7 then KlrTmp := ((KlrTmp-8) * 16) + 15
                  else KlrTmp := (KlrTmp * 16) + 15;
  End;
  If WezenE[Dude].Face <> #0 then
     VirFastText(Wezen[Dude].x, Wezen[Dude].y, KlrTmp, WezenE[Dude].Face, Vir_Seg, Vir_Ofs);
End;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function tAI.CanWalk(Xas, Yas : Byte; Dude : Byte; Wie : Persoon) : Boolean;
{
  Kan ACTOR "Dude" lopen naar positie (Xas, Yas) ?
  Wie = Test -> kijk of er gelopen kan worden.
  Wie = Real -> pak vast bonussen op (Xas, Yas), maak iemand af, omdat het
                al zeker is dat je naar die positie gaat lopen.
}
Var l_GotChar : Char;
    l_ItmTllr : Byte;
    SndChan   : Byte;
    TeleCnt   : Byte;
    Lopen     : Boolean;
{XStr, YStr : String;}
Begin
  Lopen := True;
  If Yas < 3 then Lopen := False;
  If Xas < 1 then Lopen := False;
  If Yas > 24 then Lopen := False;
  If Xas > 80 then Lopen := False;
  If (Dude = 0) or (Dude = 1) then
    l_Gotchar := GetChar(Xas, Yas, Level_Seg, Level_Ofs)
   Else
    l_Gotchar := GetChar(Xas, Yas, Vir_Seg, Vir_Ofs);

  For l_ItmTllr := 1 to Length(Items.Muren) do Begin
    If l_GotChar = Items.Muren[l_ItmTllr] then Lopen := False;
  end;
  If (Dude > 1) then Begin
    For l_ItmTllr := 1 to Length(Items.EnmyFaces) do Begin
      If l_GotChar = Items.EnmyFaces[l_ItmTllr] then Lopen := False;
    end;
  End;

  If (Wie = Real) and ((Dude = 0) or (Dude = 1)) then Begin
    If Level.InvTijd = 0 then Begin
      If (l_GotChar = WezenE[1].Face) and (Level.Holo = False) then Begin
         SoundFx(3);
         Message^.NewMessage('Je hebt een HOLO! <h> om los te laten!');
         Level.Holo := True;
         SetChar(' ', Xas, Yas, Level_Seg, Level_Ofs);
      End;
      If l_GotChar = LevelForm.Bonus.Normaal then Begin
        SoundFx(0);

        SetChar(' ', Xas, Yas, Level_Seg, Level_Ofs);
        Inc(Score, LevelForm.Bonus.NorWaard);
        Dec(TillLife, LevelForm.Bonus.NorWaard);
        Dec(LevelForm.Asse.Collect);
        If TillLife < 1 then Begin
          Inc(TillLife, Speler.LevWaard);
          Inc(speler.levens);
        End;
      End;
      If l_GotChar = LevelForm.Bonus.Mega then Begin
        SoundFx(1);
        SetChar(' ', Xas, Yas, Level_Seg, Level_Ofs);
        Inc(Score, LevelForm.Bonus.MegWaard);
        Dec(TillLife, LevelForm.Bonus.MegWaard);
        If TillLife < 1 then Begin
          Inc(TillLife, Speler.LevWaard);
          Inc(speler.levens);
        End;
      End;
      If l_GotChar = LevelForm.Bonus.Negatief then Begin
        SoundFx(2);
        SetChar(' ', Xas, Yas, Level_Seg, Level_Ofs);
        Inc(Score, LevelForm.Bonus.NegWaard);
        Dec(TillLife, LevelForm.Bonus.NegWaard);
        If TillLife < 1 then Begin
          Inc(TillLife, Speler.LevWaard);
          Inc(speler.levens);
        End;
      End;
    End;
  End;

  if (Wie = Real) and Lopen then Begin
    Wezen[Dude].x := Xas;
    Wezen[Dude].y := Yas;

    If WezenE[Dude].TelePort then begin
       TeleCnt := 0;
       Repeat { Scot me up beamie ! }
           if (Wezen[Dude].x = Items.TeleStrt[TeleCnt].x) and
              (Wezen[Dude].y = Items.TeleStrt[TeleCnt].y) then Begin

              SoundFx(4); {<< ZzzZAp! >>}

              Wezen[Dude].x := Items.TeleEind[TeleCnt].x;
              Wezen[Dude].y := Items.TeleEind[TeleCnt].y;
              WezenE[Dude].TelePort := False;
              TeleCnt := MaxTele;
           { Tele FRAGGEN ;) ?  - Bouw dat dan hieronder! - }
           End;
           inc(TeleCnt);
       Until TeleCnt > MaxTele;
    End else Begin
      If WezenE[Dude].TeleAble then WezenE[Dude].TelePort := True;
    End;
  End;

  CanWalk := Lopen;
End;

Procedure tAI.DoeEnemies;
{
  Laat vijanden reageren op hun omgeving volgens hun AI
}
Var
    EnmyCntr : Byte;
Begin
    If Level.HolTijd > 0 then HoloPal;
    For EnmyCntr := 2 to LevelForm.Asse.AantEnemy+2 do Begin
        Case Wezen[EnmyCntr].Soort of
          2 : NMI0(EnmyCntr);
          3 : NMI1(EnmyCntr);
          4 : NMI2(EnmyCntr);
          5 : NMI3(EnmyCntr);
          6 : NMI4(EnmyCntr);
        End;
    End;
End;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-  AI    -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Constructor tAI.Create;
Begin
End;

Destructor tAI.Destroy;
Begin
{  WriteLn('AI killed.');}
End;

Procedure tAI.HoloPal; { Laat holodude lopen }
{
  Laat "normale" Holo lopen en GET SUM MONEY!
}
Var
    DirLooper : Byte;
    NtPoging  : Byte;
    AantDirct : Byte;
Begin
  Inc(WezenE[1].Wait);
  If WezenE[1].Wait >= Wezen[1].Speed then
     WezenE[1].Wait := 0 else Exit;
  Gelopen := False;
  If Wezen[1].Speed > 1 then Dec(Wezen[1].Speed);
  AantDirct := Richtingen(1);
  Repeat
    GaLopen (1);
    If Gelopen = False then Begin
      If AantDirct > 1 then Begin
        If Wezen[1].Richting = wUp then
          Direction[wDown] := False;
        If Wezen[1].Richting = wDown then
          Direction[wUp] := False;
        If Wezen[1].Richting = wRight then
          Direction[wLeft] := False;
        If Wezen[1].Richting = wLeft then
          Direction[wRight] := False;
      End;
      If AantDirct < 3 then Begin
        For DirLooper := 0 to 4 do Begin
          If Direction[DirLooper] = True then
            Wezen[1].Richting := DirLooper;
        End;
      End Else Begin
        NtPoging := 0;
        repeat
          Wezen[1].Richting := Random(4);
          Inc(NtPoging);
        until (Direction[Wezen[1].Richting]) or (NtPoging = 10);
        If NtPoging = 10 then Gelopen := True;
      End;
    End;
  until Gelopen = True;
  PlaatsPoppetje(1);
End;

Procedure tAI.NMI4(Welke : Byte); { Martijn, TAP co-founder }
{
  AI MOET NOG GEDAAN WORDEN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  GUIDO!!!!!!!!!!!!!!!!!!!!!!!!!!
}
Var
    DirLooper : Byte; { als je klem zit, richtingen aflopen}
    NtPoging  : Byte; { aantal pogingen die je geprobeert hebt te lopen}
    AantDirct : Byte; { aantal kanten die je op kan}

    VerschilX : Integer; {Verschil tussen vijand en speler horizontaal}
    VerschilY : Integer; {Verschil tussen vijand en speler verticaal}
    PositiefX : Byte;
    PositiefY : Byte;
Begin
  Inc(WezenE[Welke].Wait);
  If Level.InvTijd = 0 then Begin
    If (Wezen[Welke].X = Wezen[0].X) and
       (Wezen[welke].Y = Wezen[0].Y) then Begin
          Dec(Speler.Levens);
          Level.InvTijd := 400;
    End;
  End;
  If WezenE[Welke].Wait = Wezen[Welke].Speed then
     WezenE[Welke].Wait := 0 else Exit;

  If Level.InvTijd > 0 then Exit;
     { Herpositioneer alleen als speler sterfelijk is }
     { Anders is het helemaal niet te overleven       }

     AantDirct := Richtingen(Welke);
     Gelopen := False;
     VerschilX := (Wezen[Welke].X - Wezen[0].X);
     VerschilY := (Wezen[welke].Y - Wezen[0].Y);
     If VerschilX < 0 then PositiefX := (VerschilX * -1) else
                           PositiefX := VerschilX;
     If VerschilY < 0 then PositiefY := (VerschilY * -1) else
                           PositiefY := VerschilY;

     If (PositiefX = PositiefY) then Dec(PositiefX);

     NtPoging := 0;
Repeat
     If (PositiefX > PositiefY) and (VerschilX = PositiefX) then
     { hier ga je naar links }
     begin
       Wezen[Welke].richting := wLeft;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefX := 0;
       end;
     end;

     If (PositiefX > PositiefY) and (VerschilX <> PositiefX) then
     { hier ga je naar rechts }
     begin
       Wezen[Welke].richting := wRight;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefX := 0;
       end;
     end;

     If (PositiefX < PositiefY) and (VerschilY = PositiefY) then
     { hier ga je naar boven }
     begin
       Wezen[Welke].richting := wUp;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefY := 0;
       end;
     end;
     If (PositiefX < PositiefY) and (VerschilY <> PositiefY) then
     { hier ga je naar beneden }
     begin
       Wezen[Welke].richting := wDown;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefY := 0;
       end;
    end;
    Inc(NtPoging);
until gelopen or (NtPoging = 5)

End;

Procedure tAI.NMI3(Welke : Byte); { SanderSmeenk, TAP member }
{
   SEEK & ELIMINATE NMI "Player" !
}
Var
    DirLooper : Byte; { als je klem zit, richtingen aflopen}
    NtPoging  : Byte; { aantal pogingen die je geprobeert hebt te lopen}
    AantDirct : Byte; { aantal kanten die je op kan}

    VerschilX : Integer; {Verschil tussen vijand en speler horizontaal}
    VerschilY : Integer; {Verschil tussen vijand en speler verticaal}
    PositiefX : Byte;
    PositiefY : Byte;
Begin
  Inc(WezenE[Welke].Wait);
  If Level.InvTijd = 0 then Begin
    If (Wezen[Welke].X = Wezen[0].X) and
       (Wezen[welke].Y = Wezen[0].Y) then Begin
          Dec(Speler.Levens);
          Level.InvTijd := 400;
    End;
  End;
  If WezenE[Welke].Wait = Wezen[Welke].Speed then
     WezenE[Welke].Wait := 0 else Exit;

  If Level.InvTijd > 0 then Exit;
     { Herpositioneer alleen als speler sterfelijk is }
     { Anders is het helemaal niet te overleven       }

     AantDirct := Richtingen(Welke);
     Gelopen := False;
     VerschilX := (Wezen[Welke].X - Wezen[0].X);
     VerschilY := (Wezen[welke].Y - Wezen[0].Y);
     If VerschilX < 0 then PositiefX := (VerschilX * -1) else
                           PositiefX := VerschilX;
     If VerschilY < 0 then PositiefY := (VerschilY * -1) else
                           PositiefY := VerschilY;

     If (PositiefX = PositiefY) then Dec(PositiefX);

     NtPoging := 0;
Repeat
     If (PositiefX > PositiefY) and (VerschilX = PositiefX) then
     { hier ga je naar links }
     begin
       Wezen[Welke].richting := wLeft;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefX := 0;
       end;
     end;

     If (PositiefX > PositiefY) and (VerschilX <> PositiefX) then
     { hier ga je naar rechts }
     begin
       Wezen[Welke].richting := wRight;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefX := 0;
       end;
     end;

     If (PositiefX < PositiefY) and (VerschilY = PositiefY) then
     { hier ga je naar boven }
     begin
       Wezen[Welke].richting := wUp;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefY := 0;
       end;
     end;
     If (PositiefX < PositiefY) and (VerschilY <> PositiefY) then
     { hier ga je naar beneden }
     begin
       Wezen[Welke].richting := wDown;
       Galopen(Welke);
       If not Gelopen then begin
          PositiefY := 0;
       end;
    end;
    Inc(NtPoging);
until gelopen or (NtPoging = 5)

End;

Procedure tAI.NMI2(Welke : Byte); { MATTHIJS, Ikke! ;) }
{
  -- moet nog nieuwe AI krijgen
}
Var
    DirLooper : Byte;
    NtPoging  : Byte;
    AantDirct : Byte;
Begin
  Inc(WezenE[Welke].Wait);
  If Level.InvTijd = 0 then Begin
    If (Wezen[Welke].X = Wezen[0].X) and
       (Wezen[welke].Y = Wezen[0].Y) then Begin
          Dec(Speler.Levens);
          Level.InvTijd := 400;
    End;
  End;
  If WezenE[Welke].Wait = Wezen[Welke].Speed then
     WezenE[Welke].Wait := 0 else Exit;

  AantDirct := Richtingen(Welke);

  Gelopen := False;
  Repeat
    If Direction[Wezen[Welke].Richting] = True Then Begin
       Case Wezen[Welke].Richting of
         wUp    : If Direction[wRight] then
                 Wezen[Welke].Richting := wRight;
         wRight : If Direction[wDown] then
                 Wezen[Welke].Richting := wDown;
         wDown  : If Direction[wLeft] then
                 Wezen[Welke].Richting := wLeft;
         wLeft  : If Direction[wUp] then
                 Wezen[Welke].Richting := wUp;
       End;
    End;
    GaLopen(Welke);

    If Gelopen = False then Begin
       If AantDirct = 1 then Begin
         For DirLooper := 0 to 3 do Begin
           If Direction[DirLooper] = True then
              Wezen[Welke].Richting := DirLooper;
         End;
       End else Begin
        If Wezen[Welke].Richting = wUp then
           Direction[wDown] := False;
        If Wezen[Welke].Richting = wDown then
           Direction[wUp] := False;
        If Wezen[Welke].Richting = wRight then
           Direction[wLeft] := False;
        If Wezen[Welke].Richting = wLeft then
           Direction[wRight] := False;

        Case Wezen[Welke].Richting of
          wUp    : If Direction[wRight] then
                  Wezen[Welke].Richting := wRight;
          wRight : If Direction[wDown] then
                  Wezen[Welke].Richting := wDown;
          wDown  : If Direction[wLeft] then
                  Wezen[Welke].Richting := wLeft;
          wLeft  : If Direction[wUp] then
                  Wezen[Welke].Richting := wUp;
        End;
        If Direction[Wezen[Welke].Richting] = False then Begin
          NtPoging := 0;
          repeat
            Wezen[Welke].Richting := Random(4);
            Inc(NtPoging);
          until (Direction[Wezen[Welke].Richting]) or (NtPoging = 10);
          If NtPoging = 10 then Gelopen := True;
        End;
      End;
    End;
  until Gelopen = True;
  PlaatsPoppetje(Welke);
End;

Procedure tAI.NMI1(Welke : Byte); { WOUTER, mijn broertje :) }
{
  Loop rechtdoor tot je tegen een muur aanknalt, en kies een nieuwe richting
}
Var AantDirct : Byte;

    DirLooper : Byte;
    NtPoging  : Byte;
Begin
  Inc(WezenE[Welke].Wait);
  If Level.InvTijd = 0 then Begin
    If (Wezen[Welke].X = Wezen[0].X) and
       (Wezen[welke].Y = Wezen[0].Y) then Begin
          Dec(Speler.Levens);
          Level.InvTijd := 400;
    End;
  End;
  If WezenE[Welke].Wait = Wezen[Welke].Speed then
     WezenE[Welke].Wait := 0 else Exit;
  Gelopen := False;

  AantDirct := Richtingen(Welke);
  Repeat
    GaLopen(Welke);
    If Gelopen = False then Begin
       If AantDirct > 1 then Begin
         If Wezen[Welke].Richting = wUp then
            Direction[wDown] := False;
         If Wezen[Welke].Richting = wDown then
            Direction[wUp] := False;
         If Wezen[Welke].Richting = wRight then
            Direction[wLeft] := False;
         If Wezen[Welke].Richting = wLeft then
            Direction[wRight] := False;
       End;
       If AantDirct < 3 then Begin
         For DirLooper := 0 to 4 do Begin
           If Direction[DirLooper] = True then
              Wezen[Welke].Richting := DirLooper;
         End;
       End Else Begin
         NtPoging := 0;
         repeat
           Wezen[Welke].Richting := Random(4);
           Inc(NtPoging);
         until (Direction[Wezen[Welke].Richting]) or (NtPoging = 10);
         If NtPoging = 10 then Gelopen := True;
       End;
     End;
    Inc(NtPoging);
  until (Gelopen = True) or (NtPoging > 10);
  PlaatsPoppetje(Welke);
End;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure tAI.NMI0(Welke : Byte); { JUDITH }
{
  Kies een random richting, en dool wat rond :)
}
Var
    NtPoging : Byte;
Begin
  Inc(WezenE[Welke].Wait);
  If Level.InvTijd = 0 then Begin
    If (Wezen[Welke].X = Wezen[0].X) and
       (Wezen[welke].Y = Wezen[0].Y) then Begin
          Dec(Speler.Levens);
          Level.InvTijd := 400;
    End;
  End;
  If WezenE[Welke].Wait = Wezen[Welke].Speed then
     WezenE[Welke].Wait := 0 else Exit;
  Gelopen := False;
  NtPoging := 0;
  Repeat
    Inc(NtPoging);
    Wezen[Welke].Richting := Random(4);
    GaLopen(Welke);
  until (Gelopen = True) or (NtPoging = 10);
  PlaatsPoppetje(Welke);
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\- END AI -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
(*)
 * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                     END OF NMI funk-s, en AI "scripting"
 * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)
Begin { Begin deze fantastisch lib, }
end.  { en maak een end aan jezellef! }

Zo weer een LIB af, het schiet al op!

End of enemy libary.
