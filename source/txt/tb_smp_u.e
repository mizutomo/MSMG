unit tb_smp_u {
  ref_vol :inout simple_port of real is instance;
  keep ref_vol.hdl_path() == "~/tb_top/ref";
  keep ref_vol.analog_kind() == potential;
  ref_cur :inout simple_port of real is instance;
  keep ref_cur.hdl_path() == "~/tb_top/ref";
  keep ref_vol.analog_kind() == flow;
};
