library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity US_TRIGGER_GENERATOR is
generic (
FPGA_CLK_Hz    : integer;   -- [Hz]
TRIG_WIDTH_us  : integer;   -- [us]
TRIG_PERIOD_ms : integer ); -- [ms]
port (
i_rst          : in  std_logic;
i_clk          : in  std_logic;
i_en           : in  std_logic; -- signal from central unit, enable the start of measurement process
o_impulse      : out std_logic );
end;



architecture arch of US_TRIGGER_GENERATOR is

constant CNT_IMPULSE_MAX : integer := (FPGA_CLK_Hz / 1_000_000) * TRIG_WIDTH_us;
constant CNT_MAX         : integer := ((FPGA_CLK_Hz / 1_000) * TRIG_PERIOD_ms) - 1;

signal cnt : integer range 0 to CNT_MAX := 0;

begin



GENERATE_IMPULSE: process (i_rst, i_clk, i_en)
begin
  if i_rst='1' or i_en='0' then
    o_impulse <= '0';
    cnt <= 0;
  elsif rising_edge(i_clk) then
    if cnt<CNT_MAX then  -- count the entire period
      cnt <= cnt + 1;
    else
      cnt <= 0;
    end if;

    if cnt<CNT_IMPULSE_MAX then  -- check when to set '1'
      o_impulse <= '1';
    else                   -- set '0' of the impulse
      o_impulse <= '0'; 
    end if;
  end if;
end process;



end arch;