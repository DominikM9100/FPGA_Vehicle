library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity DC_MOTOR_TOP is
generic (
FPGA_CLK_Hz   : integer;
PWM_PERIOD_ms : integer;
REG_LEN       : integer );
port (
i_rst         : in  std_logic;
i_clk         : in  std_logic;
i_en          : in  std_logic;
i_duty        : in  std_logic_vector(REG_LEN-1 downto 0);
o_pwm         : out std_logic ); -- the same signal for all the wheels
end;



architecture arch of DC_MOTOR_TOP is

signal duty : std_logic_vector(16 downto 0);

begin



I_DC_MOTOR_DECODER: entity work.DC_MOTOR_DECODER
generic map (
REG_LEN => REG_LEN )
port map (
i_data  => i_duty,
o_duty  => duty );



I_PWM_DC_MOTOR: entity work.PWM
generic map ( 
FPGA_CLK_Hz   => FPGA_CLK_Hz,
PWM_PERIOD_ms => PWM_PERIOD_ms )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_en          => i_en,
i_duty        => duty,
o_pwm         => o_pwm );



end arch;