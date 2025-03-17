library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity SERVO_DECODER is
generic (
REG_LEN : integer );
port (
i_data : in  std_logic_vector(REG_LEN-1 downto 0);
o_duty : out std_logic_vector(16 downto 0) );
end;



architecture arch of SERVO_DECODER is
begin

process(i_data)
  variable data_int : integer range 0 to 63 := 19;
begin
  data_int := to_integer(unsigned(i_data));

  case data_int is
    when 37 => o_duty <= "00000100111000100"; -- 2500
    when 36 => o_duty <= "00000101011010010"; -- 2770
    when 35 => o_duty <= "00000101111100000"; -- 3040
    when 34 => o_duty <= "00000110011101110"; -- 3310
    when 33 => o_duty <= "00000110111111100"; -- 3580
    when 32 => o_duty <= "00000111100001010"; -- 3850
    when 31 => o_duty <= "00001000000011000"; -- 4120
    when 30 => o_duty <= "00001000100100110"; -- 4390
    when 29 => o_duty <= "00001001000110100"; -- 4660
    when 28 => o_duty <= "00001001101000010"; -- 4930
    when 27 => o_duty <= "00001010001010000"; -- 5200
    when 26 => o_duty <= "00001010101011110"; -- 5470
    when 25 => o_duty <= "00001011001101100"; -- 5740
    when 24 => o_duty <= "00001011101111010"; -- 6010
    when 23 => o_duty <= "00001100010001000"; -- 6280
    when 22 => o_duty <= "00001100110010110"; -- 6550
    when 21 => o_duty <= "00001101010100100"; -- 6820
    when 20 => o_duty <= "00001101110110010"; -- 7090
    when 19 => o_duty <= "00001110101001100"; -- 7500
    when 18 => o_duty <= "00001111011011100"; -- 7900
    when 17 => o_duty <= "00001111111101010"; -- 8170
    when 16 => o_duty <= "00010000011111000"; -- 8440
    when 15 => o_duty <= "00010001000000110"; -- 8710
    when 14 => o_duty <= "00010001100010100"; -- 8980
    when 13 => o_duty <= "00010010000100010"; -- 9250
    when 12 => o_duty <= "00010010100110000"; -- 9520
    when 11 => o_duty <= "00010011000111110"; -- 9790
    when 10 => o_duty <= "00010011101001100"; -- 10060
    when 9 => o_duty <= "00010100001011010"; -- 10330
    when 8 => o_duty <= "00010100101101000"; -- 10600
    when 7 => o_duty <= "00010101001110110"; -- 10870
    when 6 => o_duty <= "00010101110000100"; -- 11140
    when 5 => o_duty <= "00010110010010010"; -- 11410
    when 4 => o_duty <= "00010110110100000"; -- 11680
    when 3 => o_duty <= "00010111010101110"; -- 11950
    when 2 => o_duty <= "00010111110111100"; -- 12220
    when 1 => o_duty <= "00011000011010100"; -- 12500
    when others => o_duty <= "00001110101001100"; -- 7500
  end case;
end process;

end arch;