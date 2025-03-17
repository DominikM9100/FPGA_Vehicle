library ieee;
use ieee.std_logic_1164.ALL;



entity US_TRIGGER_GENERATOR_TB is
end;



architecture test of US_TRIGGER_GENERATOR_TB is

signal i_rst     : std_logic := '1';
signal i_clk     : std_logic := '0';
signal i_en      : std_logic := '0';
signal o_impulse : std_logic;

begin



i_clk <= not i_clk after 5ns;



uut: entity work.US_TRIGGER_GENERATOR
generic map (
FPGA_CLK_Hz    => 100_000_000,
TRIG_WIDTH_us  => 11,
TRIG_PERIOD_ms => 10 )
port map (
i_rst          => i_rst,
i_clk          => i_clk,
i_en           => i_en,
o_impulse      => o_impulse );



process
begin

wait for 100us;
i_rst <= '0';
wait for 100us;
i_en <= '1';
wait for 21ms;
i_en <= '0';


wait;
end process;



end test;