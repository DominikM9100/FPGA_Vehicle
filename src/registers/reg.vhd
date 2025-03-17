library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity REG is
generic (
REG_LEN    : integer; -- length of the register in bits
REG_NUMBER : integer ); -- number of the register
port (
i_clk      : in  std_logic; -- clock signal
i_rst      : in  std_logic; -- asynch reset, when '1' all bits to '0'
i_en_write : in  std_logic; -- when '1' write to the register
i_d        : in  std_logic_vector(REG_LEN-1 downto 0); -- incoming data, to be registered
o_q        : out std_logic_vector(REG_LEN-1 downto 0); -- stored data
o_nbr      : out std_logic_vector(REG_LEN-1 downto 0) ); -- display the number if the register
end;



architecture arch of REG is

signal data : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');

begin



o_nbr <= std_logic_vector(to_unsigned(REG_NUMBER, REG_LEN));



REGISTER_DATA: process (i_rst, i_clk)
begin
  if i_rst = '1' then
    data <= (others => '0');
  elsif rising_edge(i_clk) then
    if i_en_write='1' then
      data <= i_d;
    end if;
  end if;
end process;



o_q <= data;



end arch;