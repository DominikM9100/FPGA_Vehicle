library ieee;
use ieee.std_logic_1164.ALL;



entity UART_DECODER_TB is
end;



architecture test of UART_DECODER_TB is

constant REG_LEN  : integer := 8;

signal i_uart_data : std_logic_vector(REG_LEN-1 downto 0);
signal o_servo_pos : std_logic_vector(REG_LEN-1 downto 0);
signal o_mode      : std_logic_vector(REG_LEN-1 downto 0);
signal o_wheel_v   : std_logic_vector(REG_LEN-1 downto 0);

begin



uut: entity work.UART_DECODER
generic map (
REG_LEN     => REG_LEN )
port map (
i_uart_data => i_uart_data,
o_servo_pos => o_servo_pos,
o_mode      => o_mode,
o_wheel_v   => o_wheel_v );



process
begin

wait for 100us;

i_uart_data <= x"53";
wait for 100us;

i_uart_data <= x"a7";
wait for 100us;

i_uart_data <= x"c0";
wait for 100us;

i_uart_data <= x"fe";
wait for 100us;

i_uart_data <= x"ff";
wait for 100us;

i_uart_data <= x"00";
wait for 100us;

wait;
end process;



end test;