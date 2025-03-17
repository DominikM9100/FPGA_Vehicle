library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity PRESCALER is
generic (
LEN       : integer );
port (
i_rst     : in  std_logic;
i_clk     : in  std_logic;
o_impulse : out std_logic );
end;



architecture arch of PRESCALER is

signal cnt : unsigned(LEN-1 downto 0) := (others=>'1');

begin



COUNTER: process (i_rst, i_clk)
begin
  if i_rst='1' then
    cnt <= (others=>'1');
  elsif rising_edge(i_clk) then
    cnt <= cnt - 1;
  end if;
end process;



o_impulse <= '1' when (cnt = 0) else '0';



end arch;