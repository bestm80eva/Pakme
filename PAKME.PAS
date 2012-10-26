(*)
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                          The Attic People, 1998-1999-2000
                        \-/-\-/-\-/-\-/-\-/-\-/-\-/
                          "Lame-o-Game" Project
                        \-/-\-/-\-/-\-/-\-/-\-/-\-/
                             Pak me, Pak me !!
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
(*)
{ Define Stack, Heap minimum, and Heap Maximum. REQUIRED! }
{$M 16384,0, 16384}
{
 Stack Size            16384
 Low Heap Limit        0
 High Heap Limit       655360
}

Program PakMe; { "Lame-o-Game" Project, "Pak me, pak me" - THAiSi }

Uses Crt, Dos, PakMeS, PakMeE, PakMeG, PakMeI, PakMem,
     PkmForm, MSE_TP, PakTro;
{
   Crt -> Funcs zoals: ReadKey, WriteLn, Keypressed, Delay enz.
   Dos -> Om met bestanden te werken
   PakMeS -> PakMe, Sound Lib
   PakMeE -> PakMe, Enemy Lib
   PakMeG -> PakMe, Game Engine
   PakMeI -> PakMe, Initialisatie en Level-bestanden uitlezen
   PakMeM -> PakMe, Music Engine  (GDM: door andere pikkies gemaakt)
   PkmForm -> Spel Variabelen: in een aparte Unit zodat de Editor 'm ook
              kan gebruiken
   MSE_TP -> Voor sound engine

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}

Begin
{   Begin initialisatie ******************  }
  Randomize;
{  TextColor(7); TextBackGround(0);}
  ClrScr;
  WriteLn('Lame game van The Attic People,');
  WriteLn('Gemaakt door ThaBoo (THAiSi - BamBoo)');
  WriteLn('Bezig met laden enzo, je snapt''t wel');

  New(Muzieck, Create); { Musax engine }

  New(Initialize, Create);  { INI file lezen enzo.. }
  Dispose(Initialize, Destroy); { Daarna niet meer nodig }

  Initialize := nil;
{
  MusicLevel := $fc;
  MusicVolume(MusicLevel);
{
  WriteLn('Press a key..');
  ReadKey;

{   Begin Intro *** Eind initialisatie ***  }

  New(Intro, Create);
  Dispose(Intro, Destroy);
  Intro := nil;
{  Menu gedeelte *** Eind Intro **********  }

{  Spel gedeelte *** Eind Menu gedeelte **  }
(* *)
  New(Game);
  Game^.Create;
  Case Game^.Play of
    gGameOver : ;
    gAborted  : ;
    gFinished : ;
  end;
  If Game <> nil then Begin
    Dispose(Game, Destroy); { Mieter spel in het grote VOID }
    Game := nil;
  End;
(* *)
{  Spel Afsluiten *** Eind Spel gedeelte *  }
  Quit;
End.
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
                          The Attic People, 1998-1999-2000
                        \-/-\-/-\-/-\-/-\-/-\-/-\-/
                          "Lame-o-Game" Project
                        \-/-\-/-\-/-\-/-\-/-\-/-\-/
                             Pak me, Pak me !!
  * -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *
