integer CountErr=0,CountOK=0,i;   // variables to keep running count of tests
task D2Acheck;                    // task to check for valid response
 input real Dval;
 real Anom,PctErr;
 begin
  Din = Dval;
  #50 Anom = V(Vdd,Vss)*Din/63;
  PctErr = (V(Aout,Vss)-Anom)/V(Vdd,Vss)*100;
  if (abs(PctErr)>1.0) begin
   $display(
   "*SpecErr: Din=%b Anom=%5.3f Aout=%5.3f Out of spec by %.1f%% at T=%.1fns",
          Din,  Anom,   V(Aout,Vss),    PctErr, $realtime);
   CountErr=CountErr+1;
  end
  else CountOK=CountOK+1;
 end
endtask


