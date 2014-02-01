unit tb_smp_u {
  voltage_diff: in simple port of real is instance;
  keep voltage_diff.hdl_expression() == "V(tb_top.vin_p) - V(tb_top.vin_n)";
  keep voltage_diff.analog() == TRUE;
};
