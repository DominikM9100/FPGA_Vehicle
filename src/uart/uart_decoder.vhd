library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity UART_DECODER is
generic (
REG_LEN     : integer);
port (
i_clk       : in  std_logic;
i_uart_data : in  std_logic_vector(REG_LEN-1 downto 0);
o_servo_pos : out std_logic_vector(REG_LEN-1 downto 0);
o_mode      : out std_logic_vector(REG_LEN-1 downto 0);
o_wheel_v   : out std_logic_vector(REG_LEN-1 downto 0);
o_turn_l    : out std_logic;
o_turn_r    : out std_logic );
end;



architecture arch of UART_DECODER is

signal r_data     : unsigned(REG_LEN-1 downto 0) := x"00";
signal r_data_sub : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal r_wheel_v  : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal r_mode     : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');

begin



r_data <= unsigned( i_uart_data );



DECODER: process (i_clk)
  variable data_var : unsigned(REG_LEN-1 downto 0) := x"00";
begin

if rising_edge(i_clk) then
	 
  if r_data=0 then
    o_wheel_v   <= x"01";
    o_mode      <= x"01";
    o_servo_pos <= x"13";
    o_turn_l <= '0';    
    o_turn_r <= '0';

  elsif r_data>0 and r_data<=37 then
    o_servo_pos <= std_logic_vector( r_data );
    o_wheel_v   <= x"02";
    o_mode      <= x"02";
    if r_data<19 then
      o_turn_l <= '0';
      o_turn_r <= '1';
    elsif r_data>19 then
      o_turn_l <= '1';
      o_turn_r <= '0';
    else
      o_turn_l <= '0';    
      o_turn_r <= '0';
    end if;

  elsif r_data>37 and r_data<=74 then
	 r_data_sub  <= std_logic_vector( r_data - 37 );
    o_servo_pos <= r_data_sub;
    r_wheel_v   <= x"04";
	 o_wheel_v   <= r_wheel_v;
	 r_mode      <= x"02";
    o_mode      <= r_mode;
    if unsigned(r_data_sub)<19 then
      o_turn_l <= '0';
      o_turn_r <= '1';
    elsif unsigned(r_data_sub)>19 then
      o_turn_l <= '1';
      o_turn_r <= '0';
    else
      o_turn_l <= '0';    
      o_turn_r <= '0';
    end if;

  elsif r_data>74 and r_data<=111 then
	 r_data_sub  <= std_logic_vector( r_data - 74 );
    o_servo_pos <= r_data_sub;
    r_wheel_v   <= x"08";
	 o_wheel_v   <= r_wheel_v;
	 r_mode      <= x"02";
    o_mode      <= r_mode;
    if unsigned(r_data_sub)<19 then
      o_turn_l <= '0';
      o_turn_r <= '1';
    elsif unsigned(r_data_sub)>19 then
      o_turn_l <= '1';
      o_turn_r <= '0';
    else
      o_turn_l <= '0';    
      o_turn_r <= '0';
    end if;

  elsif r_data>111 and r_data<=148 then
	 r_data_sub  <= std_logic_vector( r_data - 111 );
    o_servo_pos <= r_data_sub;
    r_wheel_v   <= x"10";
	 o_wheel_v   <= r_wheel_v;
	 r_mode      <= x"02";
    o_mode      <= r_mode;
    if unsigned(r_data_sub)<19 then
      o_turn_l <= '0';
      o_turn_r <= '1';
    elsif unsigned(r_data_sub)>19 then
      o_turn_l <= '1';
      o_turn_r <= '0';
    else
      o_turn_l <= '0';    
      o_turn_r <= '0';
    end if;

  elsif r_data>148 and r_data<=185 then
	 r_data_sub  <= std_logic_vector( r_data - 148 );
    o_servo_pos <= r_data_sub;
    r_wheel_v   <= x"20";
	 o_wheel_v   <= r_wheel_v;
	 r_mode      <= x"02";
    o_mode      <= r_mode;
    if unsigned(r_data_sub)<19 then
      o_turn_l <= '0';
      o_turn_r <= '1';
    elsif unsigned(r_data_sub)>19 then
      o_turn_l <= '1';
      o_turn_r <= '0';
    else
      o_turn_l <= '0';    
      o_turn_r <= '0';
    end if;

  elsif r_data>185 and r_data<=222 then
	 r_data_sub  <= std_logic_vector( r_data - 185 );
    o_servo_pos <= r_data_sub;
    r_wheel_v   <= x"02";
	 o_wheel_v   <= r_wheel_v;
	 r_mode      <= x"04";
    o_mode      <= r_mode;
    if unsigned(r_data_sub)<19 then
      o_turn_l <= '0';
      o_turn_r <= '1';
    elsif unsigned(r_data_sub)>19 then
      o_turn_l <= '1';
      o_turn_r <= '0';
    else
      o_turn_l <= '0';    
      o_turn_r <= '0';
    end if;

  elsif r_data=254 then
    o_wheel_v   <= x"02";
    o_mode      <= x"08";
    o_turn_l <= '0';    
    o_turn_r <= '0';

  elsif r_data=255 then
    o_wheel_v   <= x"02";
    o_mode      <= x"10";
    o_turn_l <= '0';    
    o_turn_r <= '0';
  
  else
    o_servo_pos <= x"13";
    o_wheel_v   <= x"01";
    o_mode      <= x"01";
    o_turn_l <= '0';    
    o_turn_r <= '0';
	 
  end if;
end if;

end process;



end arch;