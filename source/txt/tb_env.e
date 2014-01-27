unit tb_env_u {
  -- top level environment, instantiating monitors
  sig_in :dms_mswire_env is instance;
  keep sig_in.agent.active_passive == PASSIVE; -- monitor only
  keep sig_in.hdl_path() == "~/tb_top/sig_out";
  -- (other configulation constraints omitted for brevity)
  sig_mon :sig_mon_u is instance;
  -- connect the measurement output to the signal monitor method port
  keep bind(sig_in.agent.monitor.dms_mswire_transaction_complete, sig_mon.sig_in_meas);
};

unit signal_mon_u {
  -- method port connecting to DMS_Wire UVC minitor output
  -- presumably sig_in is a fast changing signal
  sig_in_meas : in method_port of dms_mswire measurement_done_t is instance;
  -- internal variables for coverage
  !sig_ampl :real;
  !sig_freq :real;
  event in_meas_cover;
  -- Method port implementation
  sig_in_meas(rec :dms_mswire_measurment_t) is {
    message(LOW, "Input signal measured values:",
      "\n\tAmplitude =", rec.ampl,
      "\n\tBias =", rec.bias,
      "\n\tPhase =", rec.phase,
      "\n\tFrequency =", rec.freq);
    sig_ampl = rec.ampl;
    sig_freq = rec.freq;
    emit in_meas_cover;
  };
  -- Coverage definition
  cover in_meas_cover {
    item freq : real = sig_freq using ranges = {
      range([7e8..1e9], "700M-1GHz");
      range([5e8..7e8], "500M-700MHz");
      range([2e8..5e8], "200M-500MHz");
      range([1e8..2e8], "100M-200MHz");
    }, illegal = (freq < 1e8);
    item ampl : real = sig_ampl using ranges = {
      range([5e-3..20e-3], "5-20mV");
      range([1e-3..5e-3], "1-5mV");
      range([0.0..1e-3], "Below 1mV");
    }, illegal = (ampl > 20e-3);
  };
};
