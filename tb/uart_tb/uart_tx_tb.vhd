library ieee;
use ieee.std_logic_1164.ALL;



entity UART_TX_TB is
end;



architecture test of UART_TX_TB is

constant DATA_LEN : integer := 8;

signal i_clk       : std_logic := '0';
signal i_rst       : std_logic := '1';
signal i_rqst_send : std_logic := '0';
signal i_data      : std_logic_vector(DATA_LEN-1 downto 0) := (others=>'0');
signal o_busy      : std_logic;
signal o_tx_line   : std_logic;

begin



uut: entity work.UART_TX
generic map (
FPGA_CLK_Hz   => 100_000_000,
BAUD_RATE_bps => 9_600,
DATA_LEN       => DATA_LEN,
PARITY_BIT    => 1,
STOP_BIT      => 2 )
port map (
i_clk         => i_clk,
i_rst         => i_rst,
i_rqst_send   => i_rqst_send,
i_data        => i_data,
o_busy        => o_busy,
o_tx_line     => o_tx_line );



i_clk <= not i_clk after 5ns;



process
begin

wait for 1us;    
i_rst <= '0';
wait for 100us;
    
i_data <= "11010101";
i_rqst_send <= '1';
wait for 10 ns;
i_rqst_send <= '0';
wait for 4ms;
    
i_data <= "01010101";
i_rqst_send <= '1';
wait for 10 ns;
i_rqst_send <= '0';
wait for 3ms;

wait;
end process;



end test;