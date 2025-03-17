library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity SEVEN_SEG_DISPLAY is
port (
i_clk     : in  std_logic;
i_rst     : in  std_logic;
i_en      : in  std_logic; -- enable segments
i_digit_3 : in  std_logic_vector(3 downto 0);
i_digit_2 : in  std_logic_vector(3 downto 0);
i_digit_1 : in  std_logic_vector(3 downto 0);
i_digit_0 : in  std_logic_vector(3 downto 0);
o_digit   : out std_logic_vector(7 downto 0); -- active '0'
o_seg_en  : out std_logic_vector(3 downto 0) ); -- active '0'
end;



architecture arch of SEVEN_SEG_DISPLAY is

signal cnt        : integer range 0 to 3 := 0;
signal change_seg : std_logic := '0';
signal rst        : std_logic := '0';
signal to_decode  : std_logic_vector(3 downto 0) := (others=>'0');
signal decoded    : std_logic_vector(7 downto 0) := (others=>'0');

begin



rst <= i_rst or not( i_en );



I_PRES_7_SEG: entity work.PRESCALER
generic map (
LEN       => 18 )
port map (
i_rst     => rst,
i_clk     => i_clk,
o_impulse => change_seg );



COUNTER: process (rst, i_clk) 
begin
  if rst='1' then
    cnt <= 0;
  elsif rising_edge(i_clk) then
    if change_seg='1' then
      cnt <= cnt + 1;
    end if;
  end if;
end process;



DECODER: process (to_decode)
begin
  case (to_integer(unsigned(to_decode))) is
    when 0 =>      decoded <= "11000000"; -- 0
    when 1 =>      decoded <= "11111001"; -- 1
    when 2 =>      decoded <= "10100100"; -- 2
    when 3 =>      decoded <= "10110000"; -- 3
    when 4 =>      decoded <= "10011001"; -- 4
    when 5 =>      decoded <= "10010011"; -- 5
    when 6 =>      decoded <= "10000010"; -- 6
    when 7 =>      decoded <= "11111000"; -- 7
    when 8 =>      decoded <= "10000000"; -- 8
    when 9 =>      decoded <= "10010000"; -- 9
    when 10 =>     decoded <= "10001000"; -- a
    when 11 =>     decoded <= "10000011"; -- b
    when 12 =>     decoded <= "11000110"; -- c
    when 13 =>     decoded <= "10100001"; -- d
    when 14 =>     decoded <= "10000110"; -- e
    when 15 =>     decoded <= "10001110"; -- f
    when others => decoded <= "11111111"; -- blank
  end case;
end process;



SEND_DIGITS: process (rst, i_clk)
begin
  if rst='1' then
    o_digit  <= x"11";
    o_seg_en <= "1111";
  elsif rising_edge(i_clk) then
    case (cnt) is
      when 3 =>
        to_decode <= i_digit_3;
        o_digit   <= decoded;
        o_seg_en  <= "0111";
      when 2 =>
        to_decode <= i_digit_2;
        o_digit   <= decoded;
        o_seg_en  <= "1011";
      when 1 =>
        to_decode <= i_digit_1;
        o_digit   <= decoded;
        o_seg_en  <= "1101";
      when 0 =>
        to_decode <= i_digit_0;
        o_digit   <= decoded;
        o_seg_en  <= "1110";
      when others =>
        o_digit   <= "11111111";
        o_seg_en  <= "1111";
    end case;
  end if;
end process;



end arch;