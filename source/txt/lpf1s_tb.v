module LPF1s_TB();      // testbench to check response of low-pass filters
  wreal OUT1, OUT2, OUT3, IN;

  LPF1s #(.Fp(10e+6),  .Ts(1e-9))  LP1(OUT1, IN);   // Tau = 1/2πFp = 16ns
  LPF1s #(.Fp(30e+6),  .Ts(1e-9))  LP2(OUT2, IN);   // Tau = 5.3ns
  LPF1s #(.Fp(100e+6), .Ts(1e-9)) LP3(OUT3, IN);   // Tau = 1.6ns

  real Vin = 0;        // initialize input to 0
  always #20 Vin = 1 - Vin;     // alternate between 0 and 1 every 20ns
  assign IN = Vin;     // drive input pin with Vin value
  initial #120 $stop;  // stop after several cycles
endmodule

