library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity PWM_TB is
end;


architecture test of PWM_tb is

signal i_rst : std_logic := '1';
signal i_clk : std_logic := '1';
signal i_en : std_logic := '0';
signal i_duty : std_logic_vector(16 downto 0) := (others=>'0');
signal o_pwm : std_logic;

begin



UUT: entity work.PWM
generic map ( 
FPGA_CLK_Hz   => 50_000_000,
PWM_PERIOD_ms => 1 )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_en          => i_en,
i_duty        => i_duty,
o_pwm         => o_pwm );



i_clk <= not i_clk after 10ns;



process
begin

wait for 100us;
i_rst <= '0';
wait for 100us;

i_en <= '1';
i_duty <= "00010010100010010";
wait for 5ms;

i_duty <= "00110100010101010";
wait for 3ms;

i_duty <= "00100010000100010";
wait for 4ms;

i_en <= '0';
i_duty <= "10100100001000001";
wait for 5ms;

i_en <= '1';
wait for 1ms;
i_rst <= '1';

wait;
end process;



end test;