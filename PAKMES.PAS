Unit PakmeS; { Sound Engine

 Hier worden de mooiste beepjes gefabriceerd!

}
Interface uses Crt, PakMeI;

Const SoundChannels = 5; { Aantal geluids kanalen }
Var SoundRep : Array[0..SoundChannels-1] of Boolean;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure PutSound(Kanaal : Byte; Toon, Lengte : Word);
Procedure AddSound(Kanaal : Byte; Toon, Lengte : Word);
Procedure GetSound(Kanaal : Byte);
Procedure SoundFX(Nr: Byte);
Function  GetChanl : Byte;
Procedure MixSound;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
                              Implementation
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Type
     Noise      = Array [0..1]  of Word;
     SBuff      = Array [0..63] of Noise;
(*) -/-\-/-\-/-\-/-\-/-\- (*)
Var
   SoundCntr : Word;
   SoundFreq : LongInt;
   SoundTijd : Array[0..SoundChannels-1] of Word;
   SoundChan : Array[0..SoundChannels-1] of Word;
   SoundBuff : Array[0..SoundChannels-1] of SBuff;
   SndBufPos : Array[0..SoundChannels-1] of Byte;
   SndBufLen : Array[0..SoundChannels-1] of Byte;
   SoundMix  : Byte;
   SoundNu   : Byte;

{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Function  GetChanl : Byte;
Var KanLeeg : Byte;
Begin
KanLeeg := 0;
Repeat
 Inc(KanLeeg);
Until (SndBufLen[KanLeeg-1] = 0) or (KanLeeg > SoundChannels);
If (KanLeeg > SoundChannels) Then GetChanl := 0
                             Else GetChanl := KanLeeg -1;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure PutSound(Kanaal : Byte; Toon, Lengte : Word);
Begin
  SoundBuff[Kanaal][0][0] := Toon;
  SoundBuff[Kanaal][0][1] := Lengte;
  SndBufLen[Kanaal] := 1;
  SndBufPos[Kanaal] := 0;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure AddSound(Kanaal : Byte; Toon, Lengte : Word);
Begin
  SoundBuff[Kanaal][SndBufLen[Kanaal]][0] := Toon;
  SoundBuff[Kanaal][SndBufLen[Kanaal]][1] := Lengte;
  Inc(SndBufLen[Kanaal]);
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure GetSound(Kanaal : Byte);
Begin
  SoundChan[Kanaal] := SoundBuff[Kanaal][SndBufPos[Kanaal]][0];
  SoundTijd[Kanaal] := SoundBuff[Kanaal][SndBufPos[Kanaal]][1];

  If SoundRep[Kanaal] = False then Begin
    SoundBuff[Kanaal][SndBufPos[Kanaal]][0] := 0;
    SoundBuff[Kanaal][SndBufPos[Kanaal]][1] := 0;
  End;

  {If (SoundTijd[Kanaal] > 0) or SoundRep[Kanaal] then}
    Inc(SndBufPos[Kanaal]);

  If SndBufPos[Kanaal] > SndBufLen[Kanaal] Then SndBufPos[Kanaal] := 0;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure MixSound;
Begin
  if not Geluid then Begin NoSound; Exit; end;
  SoundMix := SoundChannels;
  For SoundCntr := 0 to SoundChannels-1 do Begin
     If SoundTijd[SoundCntr] > 0 then SoundTijd[SoundCntr] :=
                                         SoundTijd[SoundCntr] -1;
     If SoundTijd[SoundCntr] = 0 then Begin
                                           SoundChan[SoundCntr] := 0;
                                           Dec(SoundMix);
                                           GetSound(SoundCntr);
                                      End;
   End;
  SoundFreq := 0;
{  For SoundCntr := 0 to SoundChannels-1 do Begin
    Inc(SoundFreq, SoundChan[SoundCntr]);
  End;
  If SoundMix = 0 then SoundMix := 1;
  SoundFreq := SoundFreq div SoundMix;{}
  SoundFreq := 0;
  SoundCntr := 0;
  Repeat
   SoundFreq := SoundChan[SoundNu];
   Inc(SoundNu);
   If SoundNu > SoundChannels-1 then SoundNu := 0;
   Inc(SoundCntr);
  Until (SoundFreq > 0) or (SoundCntr > SoundChannels-1);
 {}
  If SoundFreq > 0 then Sound(SoundFreq)
                   else NoSound;
End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Procedure SoundFX(Nr: Byte);
Begin
   Case Nr of
     0 : Begin
                PutSound(0, 0, 1); { Normale Bonus }
                AddSound(0, 800, 20);
         End;
     1 : Begin
                PutSound(2, 0, 1); { Mega Bonus }
                AddSound(2, 800, 20);
                AddSound(2, 900, 20);
                AddSound(2,1000, 20);
         End;
     2 : Begin
             PutSound(1, 0, 1); { Nega Bonus }
             AddSound(1, 300, 20);
             AddSound(1, 200, 30);
             AddSound(1, 100, 40);
         End;
     3 : Begin
             PutSound(1, 0, 1); { Holo gevonden ! }
             AddSound(1, 1000, 10);
             AddSound(1,  900, 10);
             AddSound(1, 1000, 20);
         End;
     4 : Begin
             PutSound(2, 0, 1); { TelePorter }
             AddSound(2, 1500, 30);
             AddSound(2,  200, 10);
             AddSound(2, 2000, 20);
         End;
   else
   end;

End;
{}(* -/-\-/-\-/-\-/-\-/-\-/-\-/-\-/\_^^_/\-/-\-/-\-/-\-/-\-/-\-/-\-/-\-/- *){}
Begin
End.