module DFF1 (Q, Qb, Data, Clock, Reset);     // name of module, list of pins
   output Q,Qb;                              // nomal and inverted output
   input  Data,Clock,Reset;                  // data in, clock, asynch reset
   reg    Q,                                 // register for output signal to drive
   always @(posedge Clock or posedge Reset)  // when clock or reset fo high
      if (Reset) Q = 1'b0;                   // if reset is high, output goes zero
      else       Q = Data;                   // otherwise on clock edge get data
   assign Qb = ~Q;                           // degine notQ output to be inverse of Q
endmodule
