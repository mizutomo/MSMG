`timescale 1ns/1ps
module DFF_TB;
   reg D=1,CK=0,RST=0;
   DFF1 DUT(.Q(Q), .Qb(QB), .Data(D), .Clock(CK), .Reset(RST));
   always #5 CK = ~CK;
   initial begin
      #13 D=0;
      #15 D=1;
      #10 RST=1;
      #10 RST=0;
      #22 $stop;
   end
endmodule
