library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity SERVO_TOP is
generic (
FPGA_CLK_Hz   : integer;
PWM_PERIOD_ms : integer;
REG_LEN       : integer );
port (
i_rst         : in  std_logic;
i_clk         : in  std_logic;
i_en          : in  std_logic_vector(3 downto 0);
i_duty        : in  std_logic_vector(REG_LEN*4-1 downto 0);
o_pwm         : out std_logic_vector(3 downto 0) );
end;



architecture arch of SERVO_TOP is

type t_duty_data is array (natural range <>) of std_logic_vector(REG_LEN-1 downto 0);
type t_duty is array (natural range <>) of std_logic_vector(16 downto 0);

signal a_duty_data : t_duty_data(3 downto 0);
signal a_duty : t_duty(3 downto 0);

begin



a_duty_data(3) <= i_duty(REG_LEN*4-1 downto REG_LEN*3);
a_duty_data(2) <= i_duty(REG_LEN*3-1 downto REG_LEN*2);
a_duty_data(1) <= i_duty(REG_LEN*2-1 downto REG_LEN);
a_duty_data(0) <= i_duty(REG_LEN-1 downto 0);



G_SERVO: for i in 3 downto 0 generate

  I_SERVO_DECODER: entity work.SERVO_DECODER
  generic map (
  REG_LEN => REG_LEN )
  port map (
  i_data   => a_duty_data(i),
  o_duty   => a_duty(i) );

  I_PWM_SERVO: entity work.PWM
  generic map ( 
  FPGA_CLK_Hz   => FPGA_CLK_Hz,
  PWM_PERIOD_ms => PWM_PERIOD_ms )
  port map (
  i_rst         => i_rst,
  i_clk         => i_clk,
  i_en          => i_en(i),
  i_duty        => a_duty(i),
  o_pwm         => o_pwm(i) );

end generate;
    


end arch;