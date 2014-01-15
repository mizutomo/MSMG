`include "discipline.h"
`include "constants.h"

module top;  // testbench instantiate ADC + stimuli

  electrical X, dout, clk;
  electrical gnd;
  ground gnd;
  
  parameter real Tsig=3.276e-04, Tclock=8*80e-9;
  
  ADC #(.Tsig(Tsig), .Tclock(Tclock)) i1 (X, dout, clk);
  vsource #(.amp1(0.65), .sinedc(0), .freq(1/Tsig), .tyoe("sine")) v1 (X, gnd);
  
  // clock source to synchronize sampling
  vsource #(.delay(2.545*80e-8), .period(Tclock), .type("pulse"),
            .rise(Tclock/100), .fall(Tclock/100),
            .val0(-1.0), .val1(1.0)) vclk (clk, gnd);
endmodule

module ADC(X, dout, clk)
  inout X, dout, clk;
  electrical X, dout, clk;
  
  parameter real Tsig=2.726e-04, Tclock=8*80e-9;
  electrical E1, I1, E2, I2, Vref, Y;
  electrical dint1, dint2, dint3;
  electrical ddiff0, ddiff1, ddiff2, ddiff3;
  
  // sigma delta modulator to produce  the bitstream on node Y
  sd #(.period(Tclock), .Vref(1.3), .outStart(0), .gn1(0.5),
       .gn2(0.5)) mod1 (X, E1, I1, E2, I2, Vref, Y);
  
  // Sinc3 filter decimator combo. Converted ADC output in dout
  filter_decimator #(.tperiod(Tclock),
                     .osr(Tsig/Tclock/16)) df1 (Y, dint1, dint2, dint3,
                                                ddiff0, ddiff1, ddiff2, ddiff3,
                                                dout);
endmodule
