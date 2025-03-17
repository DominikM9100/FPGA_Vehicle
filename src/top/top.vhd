library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity TOP is
generic (
-- TO ALL ------------------------------------------------------
FPGA_CLK_Hz            : integer := 50_000_000;
REG_LEN                : integer := 8; -- most of data is stored in registers of that length

-- UART --------------------------------------------------------
UART_BAUD_RATE_bps     : integer := 115_200; -- give value typical in UART communication (i.e. 9600, 115200, ...)
UART_DATA_LEN          : integer := 8; -- 7 or 8
UART_PARITY_BIT        : integer := 0; -- 0 (none), 1 (even parity), for odd parity heve to uncomment line in UART_RX and UART_TX
UART_STOP_BIT          : integer := 1; -- 1 or 2

-- ULTRASONIC SENSORS ------------------------------------------
US_FRONT_NBR           : integer := 5; -- give the quantity of front ultrasonic sensors
US_BACK_NBR            : integer := 5; -- give the quantity of back ultrasonic sensors
US_STOP_DISTANCE_mm    : integer := 300; -- give the distance at which the vehicle should stop
US_TRIG_WIDTH_us       : integer := 11; -- depends on used sensors, at least 10us for HC-SR04
US_TRIG_PERIOD_ms      : integer := 40; -- depends on max distance that is measured

-- SERVOS ------------------------------------------------------
SERVO_PWM_PERIOD_ms    : integer := 20; -- give the period of the pwm signal that is used control position of servos

-- DC MOTORS ---------------------------------------------------
DC_MOTOR_PWM_PERIOD_ms : integer := 5 ); -- give the period of the pwm signal that is used to control dc motors rotation speed
port (
-- TO ALL ------------------------------------------------------
i_rst          : in  std_logic;
i_clk          : in  std_logic;
i_sw           : in  std_logic;
i_key_3        : in  std_logic;
i_key_4        : in  std_logic;
o_oe           : out std_logic_vector(3 downto 0); -- to activate digital level converters

-- UART --------------------------------------------------------
i_rx_line      : in  std_logic;
-- o_tx_line      : out std_logic; -- unconnected

-- ULTRASONIC SENSORS ------------------------------------------
i_echo_f       : in  std_logic_vector(US_FRONT_NBR-1 downto 0);
i_echo_b       : in  std_logic_vector(US_BACK_NBR-1 downto 0);
o_trig_f       : out std_logic_vector(US_FRONT_NBR-1 downto 0);
o_trig_b       : out std_logic_vector(US_BACK_NBR-1 downto 0);

-- SERVOS ------------------------------------------------------
o_servo_pwm    : out std_logic_vector(3 downto 0); -- (3) lf, (2) rf, (1) lb, (0) rb

-- DC MOTORS ---------------------------------------------------
o_dc_motor_pwm : out std_logic_vector(7 downto 0); -- (3) lf, (2) rf, (1) lb, (0) rb

-- 7 SEG DISPLAY -----------------------------------------------
o_7_seg_en     : out std_logic_vector(3 downto 0); -- (3) ll, (2) cl, (1) cr, (0) rr
o_7_seg_digit  : out std_logic_vector(7 downto 0) ); -- (7) dp, (6) g, (5) f, (4) e, (3) d, (2) c, (1) b, (0) a
end;



architecture arch of TOP is

-- ULTRASINC SENSORS --------------------------------------------
signal proc_us_en_f : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal us_en_f      : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal cu_us_en_f   : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal us_stop_f    : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal cu_us_stop_f : std_logic_vector(US_FRONT_NBR-1 downto 0) := (others=>'0');
signal proc_us_en_b : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');
signal us_en_b      : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');
signal cu_us_en_b   : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');
signal us_stop_b    : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');
signal cu_us_stop_b : std_logic_vector(US_BACK_NBR-1 downto 0) := (others=>'0');

-- DC MOTORS ----------------------------------------------------
signal dc_motor_en   : std_logic := '1'; -- unconnected
signal dc_motor_duty : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal dc_motor_pin  : std_logic := '1';

-- SERVOS -------------------------------------------------------
signal servo_en   : std_logic_vector(3 downto 0) := (others=>'1'); -- unconnected
signal servo_duty : std_logic_vector(REG_LEN*4-1 downto 0) := (others=>'0');

-- UART ---------------------------------------------------------
signal tx_rqst   : std_logic := '0';
signal mode      : std_logic_vector(REG_LEN-1 downto 0) := x"01";
signal servo_pos : std_logic_vector(REG_LEN-1 downto 0) := x"13";
signal wheel_v   : std_logic_vector(REG_LEN-1 downto 0) := x"01";
signal tx_data   : std_logic_vector(REG_LEN-1 downto 0) := x"00"; -- unconnected
signal rx_data   : std_logic_vector(REG_LEN-1 downto 0) := x"00";
signal tx_line   : std_logic := '1'; -- unconnected
signal turn_l    : std_logic := '0';
signal turn_r    : std_logic := '0';

-- 7 SEG DISPLAY ------------------------------------------------
signal digit_3 : std_logic_vector(3 downto 0) := (others=>'0');
signal digit_2 : std_logic_vector(3 downto 0) := (others=>'0');
signal digit_1 : std_logic_vector(3 downto 0) := (others=>'0');
signal digit_0 : std_logic_vector(3 downto 0) := (others=>'0');

begin



o_oe <= (others=>'1');



I_CENTRAL_UNIT: entity work.CENTRAL_UNIT
generic map (
REG_LEN         => REG_LEN,
US_FRONT_NBR    => US_FRONT_NBR,
US_BACK_NBR     => US_BACK_NBR )
port map (
i_rst           => i_rst,
i_clk           => i_clk,
i_dc_motor_pin  => dc_motor_pin,
i_us_stop_f     => cu_us_stop_f,
i_us_stop_b     => cu_us_stop_b,
i_mode          => mode,
i_servo_pos     => servo_pos,
i_wheel_v       => wheel_v,
i_turn_l        => turn_l,
i_turn_r        => turn_r,
o_en_us_f       => cu_us_en_f,
o_en_us_b       => cu_us_en_b,
o_dc_motor_data => dc_motor_duty, -- velocity of wheels
o_dc_motor_pin  => o_dc_motor_pwm, -- pins to dc motors
o_servo_pos     => servo_duty ); -- data for servos



G_ULTRASONIC_SENSOR_F: for i in US_FRONT_NBR-1 downto 0 generate
  I_ULTRASONIC_SENSOR_TOP_F: entity work.ULTRASONIC_SENSOR_TOP
  generic map (
  FPGA_CLK_Hz      => FPGA_CLK_Hz,
  STOP_DISTANCE_mm => US_STOP_DISTANCE_mm,
  TRIG_WIDTH_us    => US_TRIG_WIDTH_us,
  TRIG_PERIOD_ms   => US_TRIG_PERIOD_ms )
  port map (
  i_rst            => i_rst,
  i_clk            => i_clk,
  i_en             => us_en_f(i),
  i_echo           => i_echo_f(i),
  o_stop           => us_stop_f(i),
  o_trig           => o_trig_f(i) );
end generate;



G_ULTRASONIC_SENSOR_B: for i in US_BACK_NBR-1 downto 0 generate
  I_ULTRASONIC_SENSOR_TOP_B: entity work.ULTRASONIC_SENSOR_TOP
  generic map (
  FPGA_CLK_Hz      => FPGA_CLK_Hz,
  STOP_DISTANCE_mm => US_STOP_DISTANCE_mm,
  TRIG_WIDTH_us    => US_TRIG_WIDTH_us,
  TRIG_PERIOD_ms   => US_TRIG_PERIOD_ms )
  port map (
  i_rst            => i_rst,
  i_clk            => i_clk,
  i_en             => us_en_b(i),
  i_echo           => i_echo_b(i),
  o_stop           => us_stop_b(i),
  o_trig           => o_trig_b(i) );
end generate;



I_DC_MOTOR_TOP: entity work.DC_MOTOR_TOP
generic map (
FPGA_CLK_Hz   => FPGA_CLK_Hz,
PWM_PERIOD_ms => DC_MOTOR_PWM_PERIOD_ms,
REG_LEN       => REG_LEN )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_en          => dc_motor_en,
i_duty        => dc_motor_duty,
o_pwm         => dc_motor_pin );



I_SERVO_TOP: entity work.SERVO_TOP
generic map (
FPGA_CLK_Hz   => FPGA_CLK_Hz,
PWM_PERIOD_ms => SERVO_PWM_PERIOD_ms,
REG_LEN       => REG_LEN )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_en          => servo_en,
i_duty        => servo_duty,
o_pwm         => o_servo_pwm );



I_UART_TOP: entity work.UART_TOP
generic map (
FPGA_CLK_Hz   => FPGA_CLK_Hz,
BAUD_RATE_bps => UART_BAUD_RATE_bps,
DATA_LEN      => UART_DATA_LEN,
PARITY_BIT    => UART_PARITY_BIT,
STOP_BIT      => UART_STOP_BIT,
REG_LEN       => REG_LEN )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_tx_rqst     => tx_rqst,
i_rx_line     => i_rx_line,
i_tx_data     => tx_data,
o_rx_data     => rx_data,
o_tx_line     => tx_line,
o_servo_pos   => servo_pos,
o_mode        => mode,
o_wheel_v     => wheel_v,
o_turn_l      => turn_l,
o_turn_r      => turn_r );



I_7_SEG_DISPLAY: entity work.SEVEN_SEG_DISPLAY
port map (
i_clk     => i_clk,
i_rst     => i_rst,
i_en      => i_sw,
i_digit_3 => digit_3,
i_digit_2 => digit_2,
i_digit_1 => digit_1,
i_digit_0 => digit_0,
o_digit   => o_7_seg_digit,
o_seg_en  => o_7_seg_en );



SWITCH_BTN_ENABLES: process (i_key_3, i_key_4)
begin
--  if i_sw='1'then
--    us_en_f <= cu_us_en_f;
--    us_en_b <= cu_us_en_b;
--    cu_us_stop_f <= us_stop_f;
--    cu_us_stop_b <= us_stop_b;
--  else
--    if i_sw_en_us='0' then
--      us_en_f <= (others=>'0');
--      us_en_b <= (others=>'0');
--      cu_us_stop_f <= (others=>'0');
--      cu_us_stop_b <= (others=>'0');
--   else
--      us_en_f <= (others=>'1');
--      us_en_b <= (others=>'1');
--      cu_us_stop_f <= us_stop_f;
--      cu_us_stop_b <= us_stop_b;
--    end if;
--  end if;
  
  if i_key_3='0' then -- normal - control ultrasonic sensors from CENTRAL_UNIT
    us_en_f <= cu_us_en_f; -- enable front ultrasonic sensors from CENTRAL_UNIT
    us_en_b <= cu_us_en_b; -- enable back ultrasonic sensors from CENTRAL_UNIT
    cu_us_stop_f <= us_stop_f; -- pass stop signals to CENTRAL_UNIT
    cu_us_stop_b <= us_stop_b; -- pass stop signals to CENTRAL_UNIT
  else
    if i_key_4='0' then -- diable all ultrasonic sensors - no detection!!!!!!!!!!
      us_en_f <= (others=>'0'); -- disable ultrasonic sensors
      us_en_b <= (others=>'0'); -- disable ultrasonic sensors
      cu_us_stop_f <= (others=>'0'); -- always show no object detected
      cu_us_stop_b <= (others=>'0'); -- always show no object detected
    else -- enable all ultrasonic sensors - no matter the mode the vehicle is in
      us_en_f <= (others=>'1'); -- always enable ultrasonic sensors
      us_en_b <= (others=>'1'); -- always enable ultrasonic sensors
      cu_us_stop_f <= us_stop_f; -- pass stop signals to CENTRAL_UNIT
      cu_us_stop_b <= us_stop_b; -- pass stop signals to CENTRAL_UNIT
    end if;
  end if;
end process;



CHOOSE_DATA_FOR_7_SEG_DISPLAY: process (i_rst, i_sw)
begin
  if i_rst='1' or i_sw='0' then
    digit_3 <= "0000";
    digit_2 <= "0000";
    digit_1 <= "0000";
    digit_0 <= "0000";
  else
    digit_3 <= cu_us_stop_f(4 downto 1);
    digit_2 <= cu_us_stop_f(0) & "000";
    digit_1 <= cu_us_stop_b(4 downto 1);
    digit_0 <= cu_us_stop_b(0) & "000";
  end if;
end process;



end arch;