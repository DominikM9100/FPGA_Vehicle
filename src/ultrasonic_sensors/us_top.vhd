library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity ULTRASONIC_SENSOR_TOP is
generic (
FPGA_CLK_Hz      : integer;
STOP_DISTANCE_mm : integer;
TRIG_WIDTH_us    : integer;
TRIG_PERIOD_ms   : integer );
port (
i_rst            : in  std_logic;
i_clk            : in  std_logic;
i_en             : in  std_logic;
i_echo           : in  std_logic;
o_stop           : out std_logic;
o_trig           : out std_logic );
end;



architecture arch of ULTRASONIC_SENSOR_TOP is

signal inc_dist    : std_logic := '0';
signal trigger     : std_logic := '0';
signal echo        : std_logic := '0';
signal r_distance  : std_logic_vector(15 downto 0) := (others=>'0');
signal r_sync_echo : std_logic_vector(1 downto 0) := (others=>'0');

begin



o_trig <= trigger;
echo <= r_sync_echo(1) and r_sync_echo(0);



I_US_TRIGGER_GENERATOR: entity work.US_TRIGGER_GENERATOR
generic map (
FPGA_CLK_Hz    => FPGA_CLK_Hz,
TRIG_WIDTH_us  => TRIG_WIDTH_us,
TRIG_PERIOD_ms => TRIG_PERIOD_ms )
port map (
i_rst          => i_rst,
i_clk          => i_clk,
i_en           => i_en,
o_impulse      => trigger );



I_US_PRESCALER: entity work.US_PRESCALER
generic map (
FPGA_CLK_Hz  => FPGA_CLK_Hz )
port map (
i_rst        => i_rst,
i_clk        => i_clk,
i_en         => i_en,
i_echo       => echo,
o_impulse    => inc_dist );



I_US_DISTANCE_COUNTER: entity work.US_DISTANCE_COUNTER
generic map (
REG_LEN    => 16 )
port map (
i_rst      => i_rst,
i_clk      => i_clk,
i_inc_dist => inc_dist,
i_del      => trigger,
i_en       => echo,
o_distance => r_distance );



COMPARE_DISTANCE: process (i_en, r_distance)
begin
  if i_en='1' then
    if unsigned(r_distance) < STOP_DISTANCE_mm then
      o_stop <= '1';
    else
      o_stop <= '0';
    end if;
  else
    o_stop <= '0';
  end if;
end process;



SYNC_ECHO_SIGNAL: process (i_rst, i_en, i_clk)
begin
  if i_rst='1' or i_en='0' then
    r_sync_echo <= "00";
  elsif rising_edge(i_clk) then
    r_sync_echo <= r_sync_echo(0) & i_echo;
  end if;
end process;



end arch;