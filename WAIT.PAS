Unit Wait;

Interface

procedure WaitMs (MS : Word);

implementation
var
  {For timing}
  TicksPerMs  : LongInt;
  SystemClock : LongInt absolute $0000:$046C;

{Counts the amount of "INC"s the processor does in 1 clock tick}
procedure InitDelay;
var
  t, n : LongInt;

begin
  t := SystemClock;
  n := 0;
  repeat until (SystemClock <> t);
  t := SystemClock;
  repeat inc (n); until (SystemClock <> t);
  TicksPerMs := n div 55;
end;

{** DELAY *******************************************************************}
procedure WaitMS (MS : Word);
var
  a, b, c : LongInt;

begin
  for a := 1 to MS do begin
    for b := 1 to TicksPerMs do inc (c);
  end;
end;

begin
  InitDelay;
End.