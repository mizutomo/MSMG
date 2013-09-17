//`include "constants.vams"
`timescale 1ns/1ps

`define M_TWO_PI (2*3.14159)

module LPF1s(OUT, IN);
  output OUT;
  input IN;
  wreal OUT, IN;

  parameter real Fp = 10e+6;      // corner frequency [Hz]
  parameter real Ts = 10e-9;      // sample rate [sec]
  real d0, d1, ts_ns;

  initial begin
    ts_ns = Ts/1e-9;      // sample rate converted to nanoseconds
    d0 = 1 + 2/(`M_TWO_PI * Fp * Ts);   // denominator coefficients
    d1 = 1 - 2/(`M_TWO_PI * Fp * Ts);
  end

  real INold, OUTval;   // saved value of input & output

  always #(ts_ns) begin      // sample input every Ts seconds
    OUTval = (IN + INold - OUTval * d1) / d0;   // compute output from input & state
    INold = IN;         // saved old value for use next step
  end

  assign OUT = OUTval;  // pass value to output pin
endmodule
