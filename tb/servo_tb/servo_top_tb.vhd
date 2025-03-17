library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity SERVO_TOP_TB is
end;



architecture arch of SERVO_TOP_TB is

constant REG_LEN : integer := 8;

signal i_rst : std_logic := '1';
signal i_clk : std_logic := '0';
signal i_en : std_logic_vector(3 downto 0) := (others=>'0');
signal i_duty : std_logic_vector(REG_LEN*4-1 downto 0) := (others=>'0');
signal o_pwm : std_logic_vector(3 downto 0);

begin



UUT: entity work.SERVO_TOP
generic map (
FPGA_CLK_Hz   => 50_000_000,
PWM_PERIOD_ms => 20,
REG_LEN       => REG_LEN )
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
wait for 1ms;
i_en <= x"f";
i_duty <= x"1a201013";
wait for 21ms;
i_en <= x"f";

i_duty <= x"221b041c";
wait for 21ms;
i_en <= x"f";

i_duty <= x"11181312";
wait for 21ms;
i_en <= x"f";

i_duty <= x"171e1f04";
wait for 300us;
i_en <= x"0";

wait;
end process;



end arch;