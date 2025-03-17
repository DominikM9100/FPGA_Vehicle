library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity US_DISTANCE_COUNTER is
generic (
REG_LEN    : integer );
port (
i_rst      : in  std_logic;
i_clk      : in  std_logic;
i_inc_dist : in  std_logic; -- signal form us_prescaler, to increment distance counter
i_del      : in  std_logic; -- signal from trigger pin
i_en       : in  std_logic; -- signal from echo pin
o_distance : out std_logic_vector(REG_LEN-1 downto 0) );
end;



architecture arch of US_DISTANCE_COUNTER is

signal r_distance  : unsigned(REG_LEN-1 downto 0) := (others=>'0');
signal r_fall_edge : std_logic_vector(1 downto 0) := (others=>'0');
signal send_data   : std_logic := '0';

begin



COUNT_DISTANCE: process (i_rst, i_clk, i_del)
begin
  if i_del='1' or i_rst='1' then
   r_distance <= (others=>'0');
  elsif rising_edge(i_clk) then
    if i_inc_dist='1' then
      r_distance <= r_distance + 3;
    end if;
  end if;
end process;



DETECT_FALLING_EDGE: process (i_rst, i_clk)
begin
  if i_rst='1' then
    r_fall_edge <= (others=>'0');
  elsif rising_edge(i_clk) then
    r_fall_edge <= r_fall_edge(0) & i_en; -- shift data in register
  end if;
end process;



send_data <= r_fall_edge(1) and not(r_fall_edge(0)); -- detect falling edge



SEND_DISTANCE: process (i_rst, i_clk)
begin
  if i_rst='1' then  
    o_distance <= (others => '0');
  elsif rising_edge(i_clk) then
    if send_data='1' then
      o_distance <= std_logic_vector(r_distance);
    end if;
  end if;
end process;



end arch;