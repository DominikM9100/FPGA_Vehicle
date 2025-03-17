library ieee;
use ieee.std_logic_1164.ALL;





entity DEBOUNCER_TB is
end ;





architecture test of DEBOUNCER_TB is

signal i_clk      : std_logic := '0';
signal i_rst      : std_logic := '1';
signal i_unstable : std_logic := '0';
signal o_impulse  : std_logic;

begin





uut: entity work.DEBOUNCER
generic map (
FPGA_CLK_Hz         => 100_000_000,
TIME_TO_DEBOUNCE_us => 3_000 )
port map (
i_rst               => i_rst,
i_clk               => i_clk,
i_unstable          => i_unstable,
o_impulse           => o_impulse );





i_clk <= not i_clk after 5ns;





process
begin

    wait for 1us;
    i_rst <= '0';
    wait for 100us;

    i_unstable <= '1';
    wait for 100us;
    i_unstable <= '0';
    wait for 100us;
    i_unstable <= '1';
    wait for 100us;
    i_unstable <= '0';
    wait for 100us;
    i_unstable <= '1';
    wait for 100us;
    i_unstable <= '0';
    wait for 100us;
    i_unstable <= '1';
    wait for 100us;
    i_unstable <= '0';
    wait for 100us;
    i_unstable <= '1';
    wait for 100us;
    i_unstable <= '0';
    wait for 100us;
    i_unstable <= '1';
    wait for 100us;

    wait for 5ms;
    
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;
    i_unstable <= '0';
    wait for 50us;
    i_unstable <= '1';
    wait for 50us;

wait;
end process;





end test;