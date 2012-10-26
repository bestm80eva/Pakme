Unit PakMeG; { Game Engine
 Hier wordt het spel getekent
}

InterFace uses Crt, Dos, PakMeS, PakMeI, PakMeE, MSE_TP, PakMeM, PkmForm,
               PakTro, Wait;
{ ^- kortom : een hoop! (Beschrijvingen in Pakme.PAS) }

Const
  gLaden = 'Level laden';
  gUitgespeeld = 'gefeliciteerd!';
  gLost = 'Loser! loser!';
  gNokken = 'Rot maar weer op dan!';

  { hieronder is oud, het word nog wel gebruikt, maar er moet een nieuwe
    manier gemaakt worden (voor flex-velden enzo }

  fKant = 5;
  { ^ render overlay virtscreen 5 vakjes naast het scherm zodat
    licht niet op de volgende regel getekent word }
  fZKant = fKant * 2;
  { ^ beide kanten 3 vakjes dus }
  fScrBr = 160+(2*fzKant);
  { ^ 80 * 2 = 160 : breedte van een "normaal" textmode scherm
    hier wordt de extra breedte aan toegevoegd. }

  { er zijn Begmes+1 verschillende begin-van-een-level-messages }
  BegMess = 3;
  BeginMess : Array[0..BegMess] of String = { de "begin-van-een-level" }
               ('Vooruit met de geit',      { messages                 }
                'Gaan met die banaan',
                'Karre met die hap',
                'Lopuh Maar');

Type
  tGameResult = (gGameOver, gFinished, gAborted);
  tGameState = (gPause, gCheat, gSpelen);
  tGame = Object
    Private
      Again : Boolean;
      Cheat : String;  { Cheat Commando }
      GameState : tGameState;
      GameOver,
      LevelGehaald: Boolean;
      Finished : Boolean;
      FXLayer    : Array[0..((26+fKant)*fScrBr)] of Byte;
      { layer waar licht FX op getekend worden }
      LevelNaam  : String; { naam van een level, (jeehee) }
      Function  BeginMessage : String; { laat RNDM een begin message van een level zien }
      Procedure IntroLevel(Text : String); { Bouw  Scherm een beetje leuk op }
      Procedure ExtroLevel(Text : String); { Breek Scherm een beetje leuk af }
      Procedure NewLevelNaam; { zoek bestandsnaam van volgend level }
      Procedure TurnToGold; { Rekent scores om en zet ze op 't scherm }
      Procedure UpDateScr; { Render/teken het speel-scherm }
      Procedure SpeelLevel; { wat denk je, hier draait het om! }
      Function VerKleur(Nr, Kleur : Byte) : Byte; { mengt 2 kleuren }
      Procedure LichtVlek(Xas,Yas, Kleur : Byte); { Tekent lichtvlek }
      Procedure LichtEffect; { Tekent alle lichteffecten }
      Procedure Command; { vangt cheatcode op }
      Procedure Compare; { neemt actie op cheatcode input }

    Public
      Function  Play : tGameResult;
      Constructor Create;
      Destructor Destroy;
  End;


(*) -/-\-/-\-/-\-/-\-/-\- (*)
Var
  Game : ^tGame;
  InputChar  : Char; { toets die je intikt }
  InputScan  : Byte; { of een pijltje, F-toets etc. }

(*) -/-\-/-\-/-\-/-\-/-\- (*)
{ Procedures en Functies inventariseren }

Procedure GeefInput;
Procedure Quit;
Procedure Wacht (HSec : Word);
{ zorgt dat spel ff wacht (doet 't nog steeds niet goed) }

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
                               Implementation
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}

(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                        De GAME ENGINE (ongeveer)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Constructor tGame.Create;
Begin
  if AI = nil then Begin { Build the brain of the Actors }
    New(AI, Create);
  End; {IF}
  if Message = nil then Begin { Build Message Handling }
    New(Message, Create);
  End; {IF}
end;

Destructor tGame.Destroy;
Begin
  if Message <> nil then Begin { Erase Message Handling }
    Dispose(Message, Destroy);
    Message := nil;
  End; {IF}
  if AI <> nil then Begin { Erase the brain of the Actors }
    Dispose(AI, Destroy);
    AI := nil;
  End; {IF}
{  WriteLn('Game killed.');}
End;

Function tGame.Play : tGameResult;
Begin
  { schermen wissen }
  FillChar(Level.Scherm, SizeOf(Level.Scherm), 0);
  FillChar(VirScr, SizeOf(VirScr), 0);
  FillChar(FxLayer, SizeOf(FxLayer), 0);
  GotoXY(1,1);

  Fx_Ofs := Ofs(Game^.FxLayer);
  Fx_Seg := Seg(Game^.FxLayer);
  Finished := False;
  GameOver := False;
  NewLevelNaam;
  If LevelNaam = '???' then Finished := True;
  Repeat
    { nog niet uitgespeeld, en geen abort?  speel nog maar een leveltje }
    If Not Finished and (InPutChar <> #27) then Begin
      Message^.MessageStr := ' ';
      ReadLevel(LevelNaam);
      Muzieck^.SpeelMod(Level.Muziek);
      IntroLevel(Level.Naam);
      Message^.NewMessage(BeginMessage);
  {    ReadKey;}
      SpeelLevel;{}
    End;
    If ((not GameOver) and (InputChar <> #27)) then Begin
      Message^.NewMessage('Level gehaald, druk op Enter...');
      UpDateScr;
      MusicOrder(0);
      Inc(Level.Nr);
      While (InputChar <> #13) do Begin
        MixSound;
        if keypressed then GeefInput;
      End;
      NewLevelNaam;
      If LevelNaam = '???' then Finished := True;
    End;
    { Game-Abort }
    If InPutChar = #27 then ExtroLevel(gNokken);

    { GameOver }
    if GameOver then ExtroLevel(gLost);
    { Level Laden }
    if not (InPutChar = #27) and not GameOver and
       not Finished then ExtroLevel(gLaden);
    if ModLoad then Muzieck^.StopMod;
    If Finished then ExtroLevel(gUitgespeeld);
    ClearLevel; { Gooi levelwaardes uit geheugen }
  until GameOver or (InputChar = #27) or Finished;
  If GameOver then Play := gGameOver;
  If Finished then Play := gFinished;
  If (InputChar = #27) then Play := gAborted;
  End;
Function tGame.BeginMessage : String;
{
 Kies een random begin textje "Gaan met die banaan!"
}
Var Kies : Byte;
Begin
  Randomize;
  Kies := Random(BegMess);
  BeginMessage := BeginMess[Kies];
End;

Function tGame.VerKleur(Nr, Kleur : Byte) : Byte;
{
  Zorg voor de nieuwe kleur  (verkleuring voor gekleurde lichten)
}
Const VerkleurTabel : Array[0..63] of Byte =
{ zwt blw grn cyn rod prs brn wit }
 (  0,  1,  2,  3,  4,  5,  6,  7, { Zwart  }
    1,  1,  3,  3,  5,  5,  5,  1, { Blauw  }
    2,  3,  2,  3,  6,  1,  2,  2, { Groen  }
    3,  3,  3,  3,  0,  5,  0,  3, { cyaan  }
    4,  5,  6,  0,  4,  4,  4,  4, { rood   }
    5,  5,  1,  5,  4,  5,  4,  5, { paars  }
    6,  5,  2,  0,  4,  4,  6,  6, { bruin  }
    7,  1,  2,  3,  4,  5,  6,  7  { wit    }
 );

Var Org : Byte;
    Mix : Byte;

Begin
  Org := Trunc(Nr / 16);
  Kleur := VerKleurTabel[Kleur+(Org*8)];
  Mix := (Kleur * 16) + Kleur+8;
  VerKleur := Mix;
  {}
End;

Procedure tGame.Compare;
{
  Vergelijkt cheatcode en neemt een actie;
}
Begin
  { Guido deze code kan toch slimmer!
    (If Again = False then GameState := gSpelen;) <- }
  If Cheat = 'dead' then begin Dec(speler.levens);
    If Again = False then GameState := gSpelen;
  End;
  If Cheat = 'life' then begin Inc(speler.levens);
    If Again = False then GameState := gSpelen;
  End;
  If Cheat = 'next' then begin LevelGehaald := True;
    If Again = False then GameState := gSpelen
  End;
  If Cheat = 'money' then begin Score := Score+100;
    If Again = False then GameState := gSpelen;
  End;
End;

Procedure tGame.Command;
{
  Zorgt dat je een cheatcode in kan tikken
}
Begin
  Case InputChar of
    #48 : Begin Again := True;
            Compare;
            Cheat := '';
          End;
    #27 : Begin Again := False;
            GameState := gSpelen;
            Cheat := '';
          End;
    #13 : Begin Again := False;
            Compare;
            Cheat := '';
          End;
    #8  : Cheat := Copy (Cheat, 1,Length(Cheat)-1);
            else Cheat := Cheat+InputChar;
  End;
  InputChar := #0;
End;

Procedure tGame.NewLevelNaam;
{
  Zoek bestandsnaam volgende level
}
Var Numm : Byte;
    NummStr : String;
    Count   : Byte;
Begin
  Numm := Level.Nr;
  Count := 0;
Repeat
  Numm := Level.Nr;
  Str(Numm, NummStr);
  If Numm < 10 then NummStr := '0'+NummStr;
  LevelNaam := 'Level'+NummStr+'.pkm';
  If FileExists(LevelNaam) then Exit;
  LevelNaam := 'Levels\'+LevelNaam;
  If FileExists(LevelNaam) then Exit;
  inc(Level.Nr);
  Inc(Count);
Until (Count > 10);
If Count > 10 then LevelNaam := '???';
End;

Procedure tGame.TurnToGold;
{
  noteert je score bovenaan het scherm
}
Begin
   Str(Score, ScoreStr);
 If Score div 1000 > 0 then
   ScoreStr := Copy(ScoreStr, 1, Length(ScoreStr)-3)+'.'+
               Copy(ScoreStr, Length(ScoreStr)-2,3)+',-'
 else
   ScoreStr := ScoreStr+',-';
  If Score >= 0 then ScoreStr := 'Ÿ'+ScoreStr
                else ScoreStr := '-Ÿ'+Copy(ScoreStr,2,Length(Scorestr));
End;

Procedure tGame.LichtVlek(Xas,Yas, Kleur : Byte);
{
  Maak een lichtvlek op (Xas, Yas) met kleur "Kleur"
}
Var
    NormXY  : LongInt;
    NormXY2 : LongInt;
    FX_XY   : LongInt;
    FX_XY2  : LongInt;

    Straal : Byte;
    Verminderd : Integer;

  Procedure LichtLine (Y, Width : Byte);
  Var Dark : Byte;
  Begin
    NormXY := (((Y-1)*160)   +((Xas-1-Width)*2));
    FX_XY  := (((Y-1)*fScrBr)+((Xas-1-Width)*2))+fZKant;
    If Width > 0 then Begin
      { Maak gekleurt licht... }
      If (Kleur <> 9) then Begin
        For Dark := 0 to Width*2 do Begin
  {        FXLayer[FX_XY+(Dark*2)] := VirScr[NormXY+(Dark*2)]; { Licht copien }
          FXLayer[FX_XY+(Dark*2)+1] := { Licht verkleuren }
            VerKleur(FXLayer[FX_XY+(Dark*2)+1], Kleur);
        End; {FOR}
      End; {IF}
    End else Begin
      Move( VirScr[NormXY],
            FXLayer[FX_XY], 1);
    End; {IF}
    If Kleur <> 0 then Begin { Donkergrijs heeft geen X-tra randje }
      For Dark := 0 to 1 do Begin
        FX_XY2  := FX_XY -3 + (Dark*2);
        NormXY2 := NormXY;
        If Width = 0 then Begin
          FX_XY2 := FX_XY2+2;
          NormXY2 := NormXY+2;
        End; {IF}
        If FXLayer[FX_XY2] = 0 Then Begin
           FXLayer[FX_XY2] := 8;
           FXLayer[FX_XY2-1] :=
            VirScr[NormXY2-4 +(Dark*2)];
        End; {IF}
        FX_XY2 := FX_XY +3 +(Dark*2)+(4*Width);
        NormXY2 := NormXY  +(Dark*2)+(4*Width);
        If Width = 0 then Begin
          FX_XY2 := FX_XY2-2;
          NormXY2 := NormXY2-2;
        End; {IF}
        If FXLayer[FX_XY2] = 0 Then Begin
           FXLayer[FX_XY2] := 8;
           FXLayer[FX_XY2-1] :=
            VirScr[NormXY2+2];
        End; {IF}
      End; {FOR}
    End; {IF}
  End; {Subprocedure}

Begin
  Straal := 4;
  If Straal > 8 then Straal := 8;
  VerMinderd := 1;
  LichtLine(Yas, Straal); { op speler positie }
  While Straal-(Verminderd*(Verminderd+1)) > 0 do Begin { circel afmaken }
    LichtLine(Yas+Verminderd, Straal-(Verminderd*(Verminderd+1)));
    LichtLine(Yas-Verminderd, Straal-(Verminderd*(Verminderd+1)));
    Inc(Verminderd);
  End;
   LichtLine(Yas+Verminderd, 0); { Top + bodem nog }
   LichtLine(Yas-Verminderd, 0);
End;

Procedure tGame.LichtEffect;
{
  Zorg dat de lichten getekend worden
}
Var AfsX : Byte;
    Colr : LongInt;
Begin
  If (LevelForm.Asse.Kleur > 0) then Begin { zijn er verkleuringen ? }
    For AfsX := 0 to LevelForm.Asse.Kleur-1 do Begin
       if (Items.Kleur[AfsX].X = Wezen[0].x) and
          (Items.Kleur[AfsX].Y = Wezen[0].y) then
       Level.Licht := Items.Kleur[AfsX].Typ;
     { Als de speler op een plek staat waar het levellicht verkleurt,
       verkleur het dan ook }
    End;
  End;
  If Level.Licht = 7 then Exit;
  For Colr := 1 to (SizeOf(FXLayer) div 2) do Begin { verkleur het level }
      FXLayer[(Colr*2)-1] := Level.Licht;
  End;

  If Wezen[0].Licht <> 9 then begin { geef speler z'n licht als 'ie dat heeft }
     if Level.InvTijd > 0 then { PLAYER-HURT : donker lichtje }
        LichtVlek(Wezen[0].X,Wezen[0].Y, 0)
      else { ANDERS : speler het licht dat 'ie zou hebben }
        LichtVlek(Wezen[0].X,Wezen[0].Y, Wezen[0].Licht);
     If Level.HolTijd > 0 then { Geef Holo ook z'n lichtje }
        LichtVlek(Wezen[1].X,Wezen[1].Y, Wezen[1].Licht);
  End;

  { AfsX begint bij 2, omdat 0 de speler is en 1 de HOLO }
  For AfsX := 2 to LevelForm.Asse.AantEnemy+2 do Begin
    { hebben vijanden lichtje? }
    If Wezen[AfsX].Licht <> 9 then { ja? teken dan het lichtje }
       LichtVlek(Wezen[AfsX].X,Wezen[AfsX].Y,Wezen[AfsX].Licht);
  End;
  If LevelForm.Asse.Lichten > 0 then Begin { nog meer sierverlichting? }
    For AfsX := 0 to LevelForm.Asse.Lichten-1 do Begin { plaats lichten }
      LichtVlek(Items.Licht[AfsX].X,Items.Licht[AfsX].Y, Items.Licht[AfsX].Typ);
    End;
  End;
End;

Procedure tGame.UpDateScr;
{
 Teken omgeving, score, vijanden, lichten en meer funky dingen
}
Var l_EnmyCnt : Byte;
    OnderWerp : String;
    ScreenFix: LongInt;
Begin
  Move(Level.Scherm, VirScr, 4000); { plaats eerst gewone achtergrond }
  AI^.PlaatsPoppetje(0); { plaats speler }
  If Level.HolTijd > 0 then AI^.PlaatsPoppetje(1); { als er een holo is,
                                                 teken die dan ook }
  For l_EnmyCnt := 2 to LevelForm.Asse.AantEnemy+2 do Begin
    AI^.PlaatsPoppetje(l_EnmyCnt); { teken de vijanden }
  End;

  For l_EnmyCnt := 1 to 25 do Begin { verplaats getekende layer nu
                                      op de licht layer }
    Move(VirScr[l_EnmyCnt*160], FXLayer[(l_EnmyCnt*fScrBr)+fzKant], 160);
  End;
  { en teken de licht FX }
  LichtEffect;
  For l_EnmyCnt := 1 to 25 do Begin { Haal zijkanten van licht FX weer weg
                                      zodat layer weer net zo groot is als
                                      het scherm }
    Move(FXLayer[(l_EnmyCnt*fScrBr)+fzKant], FXLayer[l_EnmyCnt*160], 160);
  End;
  For ScreenFix := 0 to (SizeOf(VirScr) div 2) do Begin { Maak witte
    lichten wit (orginele kleuren) }
    l_EnmyCnt := FXLayer[(ScreenFix*2)+1];
    l_EnmyCnt := trunc(l_EnmyCnt div $10);
    If l_EnmyCnt = 7 then FXLayer[(ScreenFix*2)+1] :=
                          VirScr[(ScreenFix*2)+1];
    If l_EnmyCnt = 15 then FXLayer[(ScreenFix*2)+1] :=
                          VirScr[(ScreenFix*2)+1];
  End;
  { Teken de titelbalk }
  VirFastText(2,1,$06,'Pak me, Pak me!', Fx_Seg, Fx_Ofs); { Titel }
  VirFastText(31,2,$07,'Level ', Fx_Seg, Fx_Ofs); { Level }
  VirFastText(1,1,$00,' ', Fx_Seg, Fx_Ofs);
  Str(Level.Nr, Onderwerp);
  VirFastText(37,2,$07,Onderwerp+': ', Fx_Seg, Fx_Ofs); { LevelNr }
  VirFastText(40+Length(OnderWerp),2,$09,Level.Naam, Fx_Seg, Fx_Ofs);
                        { Naam van level }
  VirFastText(1,2,$07,'Levens: ', Fx_Seg, Fx_Ofs); { Levens }
  Str(Speler.Levens, LiveStr); { Toon levens }
  If Level.InvTijd > 0 then { als je gezond bent }
    VirFastText(9,2,$0F,LiveStr, Fx_Seg, Fx_Ofs) { wit }
  else { PLAYERHURT }
    VirFastText(9,2,$09,LiveStr, Fx_Seg, Fx_Ofs); { Blauw }
  { Laat evt message zien }
  If Message^.MessageStr[1] = ' ' then
    VirFastText(20,1,$07,Message^.MessageStr, Fx_Seg, Fx_Ofs) else
    VirFastText(20,1,$0F,Message^.MessageStr, Fx_Seg, Fx_Ofs);

  { Laat evt warning zien }
  VirFastText(1,25,$0C,Message^.WarningStr, Fx_Seg, Fx_Ofs);
  If GameState = gCheat then Begin
    VirFastText(1,25,$0E,'Command:'+Cheat+' ', Fx_Seg, Fx_Ofs); { Titel }
    GotoXy (9+Length(Cheat),25);
  end else GotoXy (1,1);;
  VirFastText(12,2,$07,'Geld: ', Fx_Seg, Fx_Ofs); { Toon Score }
  TurnToGold;
  If Score >= 0 then { Score positief? }
     VirFastText(18,2,$09, ScoreStr, Fx_Seg, Fx_Ofs) { Blauw }
    else
     VirFastText(18,2,$0C, ScoreStr, Fx_Seg, Fx_Ofs); { Rood }
  { zet de uiteindelijke layer op het scherm }
  Move(FXLayer, Mem[$b800:0000], 4000);
End;

Procedure tGame.SpeelLevel;
{
 Het Leukste: het spelen van een level
}
Var StrTmp : String;
    TmpTel : Byte;
Begin
  Again := False;
  Cheat := '';
  GameState := gSpelen;
  GameOver := False; { we moeten nog spelen dus je bent niet GAME-OVER... }
  LevelGehaald := False; { maar je hebt het level ook nog niet gehaald! }
  { DEBUG CODE :
  CanWalk(Wezen[0].x, Wezen[0].y, 0, Test);
  Str(MemAvail, StrTmp);
  Message^.NewMessage(StrTmp);{}
  Repeat
    AI^.CanWalk(Wezen[0].x, Wezen[0].y, 0, Test);
    { kunnen we lopen op de positie waar we staan? }
    If KeyPressed then Begin { er is op een toets gedrukt! }
       InputChar := #0;
       InputScan := 0;
       GeefInput; { vraag welke toets dat mag wezen }
  {     If (InputChar = 'L') then Begin
          Inc(Wezen[0].Licht);
       End;
       If (InputChar = 'l') then Begin
          Dec(Wezen[0].Licht);
       End;}
       If ((InputChar = 'h') or (InputChar = 'H')) and Level.Holo then Begin
         { Cloon holo van speler en laat 'm los }
         Level.Holo := False; { je holo ben je dus kwijt }
         Level.HolTijd := 2000; { de tijd dat 'ie mag lopen }
         { hij krijgt alle eigenschappen van de speler }
         Wezen[1].x := Wezen[0].x; { hij begint op de player positie }
         Wezen[1].y := Wezen[0].y;
         Wezen[1].Licht := Wezen[0].Licht; { Lichtkleur }
         WezenE[1].TeleAble := WezenE[0].TeleAble; { Mogelijkheid tot teleporteren }
         WezenE[1].TelePort := WezenE[0].TelePort; { toestemming tot teleporteren }
         Wezen[1].Richting := Wezen[0].richting; { richting }
         Wezen[1].Speed    := 50; { beginsnelheid }
       End;
       If GameState = gCheat then Command;
{
       If InputChar = '+' then Begin
          If MusicLevel < $f0 then Inc(MusicLevel, 10)
            else MusicLevel := $f0;
          StrTmp := '';
          For TmpTel := 0 to (MusicLevel div 15) do Begin
            StrTmp := StrTmp + '*';
          End;
          Message^.NewMessage('Volume : '+StrTmp);
       End;
       If InputChar = '-' then Begin
          If MusicLevel > 0 then Dec(MusicLevel, 10)
             else MusicLevel := 0;
          StrTmp := '';
          If MusicLevel > 0 then
            For TmpTel := 0 to (MusicLevel div 15) do Begin
              StrTmp := StrTmp + '*';
            End;
          Message^.NewMessage('Volume : '+StrTmp);
       End;
       If ModLoad then MusicVolume(MusicLevel);
}
       If InputChar = '`' then begin
         If GameState = gCheat then GameState := gSpelen else GameState := gCheat;
       end;
       if ((InputChar = 'g') or (InputChar = 'G')) then Begin Geluid := not Geluid;
          { Zet speaker sound aan/uit }
          if Geluid then Message^.NewMessage('Geluid Aan (Beep!)');
          if not Geluid then Message^.NewMessage('Error! Geen Geluid meer! :)');
       End;
       if ((InputChar = 'm') or (InputChar = 'M')) and ModLoad then Begin Muziek := not Muziek;
          { zet muziek aan/uit }
          if Muziek then begin
             Message^.NewMessage('GROOVY!!!');
             MusicLevel := $fe;
          End;
          if not Muziek then begin
             Message^.NewMessage('sst...');
             MusicLevel := 0;
          End;
          MusicVolume(MusicLevel);
       End;
       If GameState = gSpelen then begin
         Case InputScan of
           77 : If AI^.CanWalk(Wezen[0].x+1, Wezen[0].y, 0, Real) then Begin
           { pijltje naar rechts }                     Wezen[0].Richting := wRight;
                                                              End;
           75 : If AI^.CanWalk(Wezen[0].x-1, Wezen[0].y, 0, Real) then Begin
           { Pijltje naar links }                      Wezen[0].Richting := wLeft;
                                                              End;
           72 : If AI^.CanWalk(Wezen[0].x, Wezen[0].y-1, 0, Real) then Begin
           { Pijltje omhoog }                          Wezen[0].Richting := wUp;
                                                              End;
           80 : If AI^.CanWalk(Wezen[0].x, Wezen[0].y+1, 0, Real) then Begin
           { Pijltje omlaag }                          Wezen[0].Richting := wDown;
                                                            End;
         End;
      End;
    End;
    If GameState = gSpelen then begin
      If Level.InvTijd > 0 then Dec(Level.InvTijd); { HURT tijd verminderen }
      If Level.HolTijd > 0 then Dec(Level.HolTijd); { Holo-loop-tijd verminderen }
      AI^.DoeEnemies; { zet vijanden neer }
    End;
    If LevelForm.Asse.Collect = 0 then Game^.LevelGehaald := True; { al't geld }
    { Sound Mixing EnginE voor SpeakeR SounD !! (WOOOW!!)  ThS + TkR }
    MixSound;
    Wacht(1); { wacht ff }
    Message^.DoeMessage; { schuif messages }
    Message^.DoeWarning;
    If Speler.Levens = 0 then GameOver := true; { logisch }
    If (GameState = gCheat) then begin End;
    UpDateScr; { Render/teken scherm }
Until (InputChar = #27) Or GameOver or LevelGehaald;
{ level stopt als speler op ESC drukt, het levelgehaalt heeft of GAME OVER is }
End;

(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                       Nog meer standaard dingetjes
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)

Procedure tGame.IntroLevel(Text : String);
{
  Bouw Scherm een beetje leuk op
}
Var Sep : Byte;
    Row : Byte;
    Clm : Byte;

Begin
  NoSound;
  For Sep := 25 downto 1 do Begin
    FillChar(VirScr, 4000, 0);
    For Row := 0 to (11 div Sep) do Begin
      For Clm := 1 to (40 div Sep) do Begin
        VirScr[((13-(Row*Sep)) * 160) + 80 - (Clm*2)*sep] :=
        Level.Scherm[((13-Row) * 160) + 80 - ((Clm*2))];
        VirScr[((13-(Row*Sep)) * 160) + 80 - (Clm*2)*sep+1] :=
        Level.Scherm[((13-Row) * 160) + 80 - ((Clm*2))+1];

        VirScr[((13-(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep] :=
        Level.Scherm[((13-Row) * 160) + 80 + (((Clm-1)*2))];
        VirScr[((13-(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep+1] :=
        Level.Scherm[((13-Row) * 160) + 80 + (((Clm-1)*2))+1];

        VirScr[((13+(Row*Sep)) * 160) + 80 - (Clm*2)*sep] :=
        Level.Scherm[((13+Row) * 160) + 80 - ((Clm*2))];
        VirScr[((13+(Row*Sep)) * 160) + 80 - (Clm*2)*sep+1] :=
        Level.Scherm[((13+Row) * 160) + 80 - ((Clm*2))+1];

        VirScr[((13+(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep] :=
        Level.Scherm[((13+Row) * 160) + 80 + (((Clm-1)*2))];
        VirScr[((13+(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep+1] :=
        Level.Scherm[((13+Row) * 160) + 80 + (((Clm-1)*2))+1];
      End; {For}
    End; {For}
    If ModLoad and Muziek  then MusicVolume(MusicLevel div Sep);
    MixSound;

    VirFastText(40-(Length(Text) div 2),13,$0F, Text, Vir_Seg, Vir_Ofs);
    Move(VirScr, Mem[$b800:0000], 4000);
    Wacht(20);
  End; {For}
  Move(Level.Scherm, VirScr, 4000);
End;

Procedure tGame.ExtroLevel(Text : String);
{
  Breek Scherm een beetje leuk af
}
Var Sep : Byte;
    Row : Byte;
    Clm : Byte;
    Volume : Byte;
Begin
  NoSound;
  For Sep := 1 to 25 do Begin
    FillChar(VirScr, 4000, 0);
    For Row := 0 to (11 div Sep) do Begin
      For Clm := 1 to (40 div Sep) do Begin
        VirScr[((13-(Row*Sep)) * 160) + 80 - (Clm*2)*sep] :=
        Level.Scherm[((13-Row) * 160) + 80 - ((Clm*2))];
        VirScr[((13-(Row*Sep)) * 160) + 80 - (Clm*2)*sep+1] :=
        Level.Scherm[((13-Row) * 160) + 80 - ((Clm*2))+1];

        VirScr[((13-(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep] :=
        Level.Scherm[((13-Row) * 160) + 80 + (((Clm-1)*2))];
        VirScr[((13-(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep+1] :=
        Level.Scherm[((13-Row) * 160) + 80 + (((Clm-1)*2))+1];

        VirScr[((13+(Row*Sep)) * 160) + 80 - (Clm*2)*sep] :=
        Level.Scherm[((13+Row) * 160) + 80 - ((Clm*2))];
        VirScr[((13+(Row*Sep)) * 160) + 80 - (Clm*2)*sep+1] :=
        Level.Scherm[((13+Row) * 160) + 80 - ((Clm*2))+1];

        VirScr[((13+(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep] :=
        Level.Scherm[((13+Row) * 160) + 80 + (((Clm-1)*2))];
        VirScr[((13+(Row*Sep)) * 160) + 80 + ((Clm-1)*2)*sep+1] :=
        Level.Scherm[((13+Row) * 160) + 80 + (((Clm-1)*2))+1];
      End; {For}
    End; {For}
    If ModLoad and Muziek then MusicVolume(MusicLevel div Sep);

    VirFastText(40-(Length(Text) div 2),13,$0F, Text, Vir_Seg, Vir_Ofs);
    Move(VirScr, Mem[$b800:0000], 4000);
    Wacht (20);
  End; {For}
  Move(Level.Scherm, VirScr, 4000);
End;


Procedure Wacht (HSec : Word);
{
  Wacht een tijdje
}
Begin
  WaitMS(HSec*3);

End;

Procedure GeefInput;
{
  Als er een toets word ingdrukt splits 'm dan in toets en Scancode
}
Begin
InputChar := ReadKey;
If KeyPressed then InputScan := Ord(ReadKey);
End;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}

Procedure Quit;
{
 Spel SHUT DOWN:
 schakel sound, level, licht, alles uit.
}
Begin
{SelectAttribute(Blinking);}
{TextColor(7);
TextBackGround(0);}
ClrScr; { Scherm schoonmaken }
{ toon speltitel }
VirFastText(1,1,$0F, 'Lame Game van The Attic People', $B800, 0);
VirFastText(1,2,$0F, '"Pakme, Pakme!" - gemaakt door Matthijs & Guido', $B800, 0);
{ en een textke }
VirFastText(1,4,$08,'Dit is een van mijn laatste pascal programmaatjes, op naar C++!', $B800, 0);
VirFastText(1,5,$0F,'TAP HomePage: http://www.xs4all.nl/~tweakr', $B800, 0);
VirFastText(1,6,$07,'The Attic People, People with a''tic!', $B800, 0);
VirFastText(1,7,$07,'Zijn we nou alweer gestopt?', $B800, 0);
GotoXy(1,8); { zet cursor onder textblok }

if ModLoad and SndEngi then Muzieck^.StopMod; { schakel muziek uit }
if SndEngi then Muzieck^.GeenSB; { schakel sound engine uit }
{ de onderstaande dingen zouden al uit het geheugen moeten zijn,
  zoniet dan gebeurt het hieronder (extra veiligheid) }
if GAME <> nil then Begin { Kick Game Engine uit het geheugen }
  GAME^.Destroy;
  Dispose(GAME);
  GAME := nil;
End;
if AI <> nil then Begin { Erase the brain of the Actors :) }
  AI^.Destroy;
  Dispose(AI);
  AI := nil;
End;
if Message <> nil then Begin { Erase Message Handling }
  Message^.Destroy;
  Dispose(Message);
  Message := nil;
End;
if Intro <> nil then Begin { Erase Message Handling }
  Intro^.Destroy;
  Dispose(Intro);
  Intro := nil;
End;
If Initialize <> nil then Begin { Erase Initialisation stuff }
  Initialize^.Destroy;
  Dispose(Initialize);
  Initialize := nil;
End;
NoSound;
Halt; { stop programma }
{ MEZZEL! }
End;

Begin
End.