----------------------------------------------------------------
--  Use o_impulse as a debounced signal
--
--  i.e.
--
--  ...
--  if rising_edge(clk) then    -- use the same clock which was connected to the DEBOUNCER module
--      if o_impulse='1' then   -- check when the implulse occurred
--          value <= value + 1; -- describe an action when button was pressed/released
--  ...
----------------------------------------------------------------



library ieee;
use ieee.std_logic_1164 .all;
use ieee.numeric_std.all;



entity DEBOUNCER is
generic (
FPGA_CLK_Hz         : integer;
TIME_TO_DEBOUNCE_us : integer );
port (
i_rst               : in  std_logic;
i_clk               : in  std_logic;
i_unstable          : in  std_logic;
o_impulse           : out std_logic );
end;



architecture arch of DEBOUNCER is

constant CNT_MAX : integer := ( (FPGA_CLK_Hz/1_000_000) * TIME_TO_DEBOUNCE_us ) / 2 - 1;
signal cnt       : integer range 0 to ( (FPGA_CLK_Hz/1_000_000) * TIME_TO_DEBOUNCE_us ) / 2 - 1 := 0;
signal reg       : std_logic_vector (1 downto 0) := (others=>'0');
signal change    : std_logic := '0';

begin



COUNTER: process (i_rst, i_clk)
begin
  if i_rst='1' then
    cnt <= 0;
    change <= '0';
  elsif rising_edge(i_clk) then
    if cnt<CNT_MAX then
      cnt <= cnt + 1;
      change <= '0';
    else
      cnt <= 0;
      change <= '1';
    end if;
  end if;
end process;



SHIFT_REGISTER: process (i_rst, i_clk)
begin
  if i_rst='1' then
    reg <= (others=>'0');  
  elsif rising_edge(i_clk) then
    if change='1' then
      reg <= reg(0) & i_unstable;
    end if;
  end if;
end process;



-- o_impulse <= change and ( not(reg(1)) and reg(0) ); -- active '0' falling_edge
-- o_impulse <= change and ( reg(1) and not(reg(0)) ); -- active '1' falling_edge
-- o_impulse <= change and ( reg(1) and not(reg(0)) ); -- active '0' rising_edge
o_impulse <= change and ( not(reg(1)) and reg(0) ); -- active '1' rising_edge



end arch;