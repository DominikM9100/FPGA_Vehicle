library ieee;
use ieee.std_logic_1164.ALL;





entity UART_RX_TB is
end;





architecture test of UART_RX_TB is

constant DATA_LEN : integer := 7;

signal i_clk       :   std_logic := '0';
signal i_rst       :   std_logic := '1';
signal i_rx_line   :   std_logic := '1';
signal o_data      :  std_logic_vector(DATA_LEN-1 downto 0);
signal o_busy      :  std_logic;
signal o_error     :  std_logic;

constant t : time := 8.68us;
constant t_05 : time := 4.34us;
constant t_15 : time := 17.36us;

begin


uut: entity work.UART_RX
generic map (
FPGA_CLK_Hz   => 100_000_000,
BAUD_RATE_bps => 115_200,
DATA_LEN      => DATA_LEN,
PARITY_BIT    => 1,
STOP_BIT      => 2 )
port map (
i_clk         => i_clk,
i_rst         => i_rst,
i_rx_line     => i_rx_line,
o_data        => o_data, 
o_busy        => o_busy,
o_error       => o_error );




i_clk <= not i_clk after 5ns;


process
begin


    wait for 1us;    
    i_rst <= '0';
    wait for 100us;
    
---------------------------------------------------------------------
    
    
    -- start bit
    i_rx_line <= '0';
    wait for t;
    
    -- 0 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 1 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 2 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 3 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 4 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 5 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 6 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 7 bit
    --i_rx_line <= '1';
    --wait for t;
    
    -- parity bit
    i_rx_line <= '0';
    wait for t;
    
    -- stop bit
    i_rx_line <= '1';
    wait for t;

    -- stop bit
    i_rx_line <= '1';
    wait for t;
    
    wait for 11ms;


-----------------------------------------------------------------    
    
    -- start bit
    i_rx_line <= '0';
    wait for t;
    
    -- 0 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 1 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 2 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 3 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 4 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 5 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 6 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 7 bit
    --i_rx_line <= '0';
    --wait for t;
    
    -- parity bit
    i_rx_line <= '0';
    wait for t;
    
    -- stop bit
    i_rx_line <= '1';
    wait for t;
    
    -- stop bit
    i_rx_line <= '1';
    wait for t;
    
    


wait;
end process;





end test;