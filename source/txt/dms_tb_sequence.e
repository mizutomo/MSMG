-- This sequence is defined in a test file
extend MAIN dms_tb_sequence {
  body() @driver.clock is only {
    out("Signal source 1 set up");
    do DRIVE_SEQ dms_sequence on driver.osc1 keeping {
      .ampl == 20.0;
      .bias == -5.5;
      .freq == 10.0e6;
      .phase == 0.0;
    };

    out("Signal source 2 set up");
    do DRIVE_SEQ dms_sequence on driver.osc2 keeping {
      .ampl == 0.5;
      .freq == 1.0e8;
      .phase == 90.0;
    };

    out("Measure");
    do MEASURE_SEQ dms_sequence on driver.mon keeping {
      .delay == 400.0;
      .duration == 400;
    }

    wait [100];
    out("Done");
    stop_run();
  };
};

