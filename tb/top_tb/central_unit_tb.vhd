library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity CENTRAL_UNIT_TB is end;



architecture test of CENTRAL_UNIT_TB is

constant REG_LEN      : integer := 8;
constant US_FRONT_NBR : integer := 5;
constant US_BACK_NBR  : integer := 3;

signal i_rst           : std_logic := '1';
signal i_clk           : std_logic := '1';
signal i_dc_motor_pin  : std_logic := '0';
signal i_wheel_v       : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal i_us_stop_f     : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal i_us_stop_b     : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');
signal i_mode          : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal i_servo_pos     : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal o_en_us_f       : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal o_en_us_b       : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');
signal o_dc_motor_data : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal o_dc_motor_pin  : std_logic_vector(7 downto 0);
signal o_servo_pos     : std_logic_vector(REG_LEN*4-1 downto 0);

begin



uut: entity work.CENTRAL_UNIT
generic map (
REG_LEN         => REG_LEN,
US_FRONT_NBR    => US_FRONT_NBR, 
US_BACK_NBR     => US_BACK_NBR)
port map (
i_rst           => i_rst,
i_clk           => i_clk,
i_wheel_v       => i_wheel_v, -- velovity of wheel, value from decoder
i_dc_motor_pin  => i_dc_motor_pin, -- pwm signal from dc motor
i_us_stop_f     => i_us_stop_f, -- signal from ultrasonic sensors
i_us_stop_b     => i_us_stop_b, -- signal from ultrasonic sensors
i_mode          => i_mode, -- decoded mode in which the vehichle should be 
i_servo_pos     => i_servo_pos, -- position from decoder about position of servos
o_en_us_f       => o_en_us_f, -- signals to enable front ultrasonic sensors
o_en_us_b       => o_en_us_b, -- signals to enable back ultrasonic sensors
o_dc_motor_data => o_dc_motor_data, -- velocity of wheels
o_dc_motor_pin  => o_dc_motor_pin, -- pins to dc motors
o_servo_pos     => o_servo_pos ); -- data for servos



i_clk <= not i_clk after 10ns;



dc_motor_pwm_pin_generator: process (i_clk)
  variable i : integer := 0;
begin
  if rising_edge(i_clk) then
    if i<5_000 then -- 0.001s, for 50MHz
      i := i + 1;
      i_dc_motor_pin <= '1';
    elsif i>=5_000 and i<20_000 then -- 0.004s, for 50MHz
      i := i + 1;
      i_dc_motor_pin <= '0';
    else
      i := 0;
    end if;
  end if;
end process;



process
begin

wait for 100us;
i_rst <= '0';
wait for 100us;

-- check moving backward
i_wheel_v <= x"40";
i_mode <= x"02";
i_us_stop_f <= "00000";
i_us_stop_b <= "000";
i_servo_pos <= x"17";
wait for 8000us;

i_wheel_v <= x"80";
i_mode <= x"02";
i_us_stop_f <= "00000";
i_us_stop_b <= "010";
i_servo_pos <= x"21";
wait for 8000us;

-- check stop from ultrasonic sensor f
i_wheel_v <= x"80";
i_mode <= x"02";
i_us_stop_f <= "01010";
i_us_stop_b <= "000";
i_servo_pos <= x"15";
wait for 12000us;

-- check moving backward
i_wheel_v <= x"80";
i_mode <= x"04";
i_us_stop_f <= "00000";
i_us_stop_b <= "000";
i_servo_pos <= x"05";
wait for 8000us;

-- check stop from ultrasonic sensor b
i_wheel_v <= x"80";
i_mode <= x"04";
i_us_stop_f <= "00000";
i_us_stop_b <= "101";
i_servo_pos <= x"24";
wait for 8000us;

-- check spin left
i_wheel_v <= x"10";
i_mode <= x"08";
i_us_stop_f <= "11011";
i_us_stop_b <= "100";
i_servo_pos <= x"08";
wait for 8000us;

-- check stop
i_wheel_v <= x"01";
i_mode <= x"01";
i_us_stop_f <= "11000";
i_us_stop_b <= "011";
i_servo_pos <= x"13";
wait for 8000us;

-- check spin right
i_wheel_v <= x"80";
i_mode <= x"10";
i_us_stop_f <= "00100";
i_us_stop_b <= "011";
i_servo_pos <= x"19";
wait for 8000us;

i_rst <= '1';

wait;
end process;



end test;