library ieee;
use ieee.std_logic_1164.ALL;



entity US_PRESCALER_TB is
end;



architecture test of US_PRESCALER_TB is

signal i_rst     : std_logic := '0';
signal i_clk     : std_logic := '0';
signal i_en      : std_logic := '0';
signal i_echo    : std_logic := '0';
signal o_impulse : std_logic;

begin



i_clk <= not i_clk after 5ns;



uut: entity work.US_PRESCALER
generic map (
FPGA_CLK_Hz  => 100_000_000 )
port map (
i_rst        => i_rst,
i_clk        => i_clk,
i_en         => i_en,
i_echo       => i_echo,
o_impulse    => o_impulse );



process
begin

wait for 100us;
i_rst <= '0';
wait for 100us;

i_en <= '1';
wait for 4ms;
i_en <= '0';
wait for 6ms;

i_en <= '1';
wait for 7ms;
i_en <= '0';
wait for 5ms;

wait;
end process;



end test;