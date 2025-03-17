library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity DC_MOTOR_DECODER is
generic (
REG_LEN : integer );
port (
i_data  : in  std_logic_vector(REG_LEN-1 downto 0);
o_duty  : out std_logic_vector(16 downto 0) );
end;



architecture arch of DC_MOTOR_DECODER is
begin



process (i_data)
  variable data_int : integer range 0 to 2**REG_LEN-1 := 0;
begin
  data_int := to_integer(unsigned(i_data));
  case data_int is
    when 16#80# => o_duty <= "11000011010100000"; -- 100%
    when 16#40# => o_duty <= "10101111110010000"; -- 90%
    when 16#20# => o_duty <= "10011100010000000"; -- 80%
    when 16#10# => o_duty <= "10001000101110000"; -- 70%
    when 16#08# => o_duty <= "01110101001100000"; -- 60%
    when 16#04# => o_duty <= "01101011011011000"; -- 55%
    when 16#02# => o_duty <= "01100001101010000"; -- 50%
    when 16#01# => o_duty <= "00000000000000000"; -- 0%
    when others => o_duty <= "00000000000000000"; -- 0%
  end case;
end process;



end arch;