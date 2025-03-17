library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity DC_MOTOR_TOP_TB is
end;



architecture arch of DC_MOTOR_TOP_TB is

constant REG_LEN : integer := 8;

signal i_rst : std_logic := '1';
signal i_clk : std_logic := '0';
signal i_en : std_logic := '0';
signal i_duty : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal o_pwm : std_logic;

begin



UUT: entity work.DC_MOTOR_TOP
generic map (
FPGA_CLK_Hz   => 100_000_000,
PWM_PERIOD_ms => 1,
REG_LEN       => REG_LEN )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_en          => i_en,
i_duty        => i_duty,
o_pwm         => o_pwm );



i_clk <= not i_clk after 5ns;



process
begin

wait for 100us;
i_rst <= '0';
i_duty <= x"02";
wait for 5000us;

i_en <= '1';
wait for 6000us;

i_duty <= x"40";
wait for 3000us;

i_duty <= x"80";
wait for 5000us;

i_duty <= x"04";
wait for 300us;
i_en <= '0';

wait;
end process;



end arch;