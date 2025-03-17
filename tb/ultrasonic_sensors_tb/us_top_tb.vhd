library ieee;
use ieee.std_logic_1164.ALL;



entity ULTRASONIC_SENSOR_TOP_TB is
end;



architecture test of ULTRASONIC_SENSOR_TOP_TB is

signal i_rst         : std_logic := '1';
signal i_clk         : std_logic := '0';
signal i_en          : std_logic := '1';
signal i_echo        : std_logic := '0';
signal o_stop        : std_logic := '0';
signal o_trig        : std_logic := '0';

begin



i_clk <= not i_clk after 50ns;



uut: entity work.ULTRASONIC_SENSOR_TOP
generic map (
FPGA_CLK_Hz       => 10_000_000,
STOP_DISTANCE_mm  => 300,
TRIG_WIDTH_us     => 11,
TRIG_PERIOD_ms    => 20 )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_en          => i_en,
i_echo        => i_echo,
o_stop        => o_stop,
o_trig        => o_trig );



process
begin

wait for 100us;
i_rst <= '0';
wait for 100us;

wait until falling_edge(o_trig);
i_echo <= '1';
wait for 5ms;
i_echo <= '0';

wait until falling_edge(o_trig);
i_echo <= '1';
wait for 15ms;
i_echo <= '0';

wait for 2ms;
i_en <= '0';
wait for 1ms;
i_echo <= '1';

wait;
end process;



end test;