library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity US_PRESCALER is
generic (
FPGA_CLK_Hz  : integer );
port (
i_rst        : in  std_logic;
i_clk        : in  std_logic;
i_en         : in  std_logic; -- enable signal from switch
i_echo       : in  std_logic; -- incoming echo signal from sensor
o_impulse    : out std_logic );
end;



architecture arch of US_PRESCALER is

-- now for 20'C, general formula:    CNT_MAX = [MHz_clock_speed] * t[us];    t[s] = 2 * 0.003m / v_sound(T)[m/s] <- have to know the temperature of the air
-- constant CNT_MAX : integer := 1749; -- for 100MHz
constant CNT_MAX : integer := 874; -- for 50MHz
signal cnt : integer range 0 to CNT_MAX := 0;

begin



COUNTER: process (i_rst, i_clk, i_en, i_echo)
begin
  if i_rst='1' or i_echo='0' or i_en='0' then
    o_impulse <= '0';
    cnt <= 0;
  elsif rising_edge(i_clk) then
    if cnt<CNT_MAX then -- wait until the max value
      o_impulse <= '0';
      cnt <= cnt + 1;
    else -- when counter overflows
      o_impulse <= '1'; -- send impulse
      cnt <= 0;
    end if;
  end if;
end process;



end arch;