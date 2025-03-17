library ieee;
use ieee.std_logic_1164.ALL;



entity UART_TOP_TB is
end ;



architecture test of UART_TOP_TB is

constant DATA_LEN : integer := 8;

signal i_clk       : std_logic := '0';
signal i_rst       : std_logic := '1';
signal i_btn       : std_logic := '0';
signal i_rx_line   : std_logic := '1';
signal i_tx_rqst   : std_logic := '0';
signal i_tx_data   : std_logic_vector(DATA_LEN-1 downto 0) := (others=>'0');
signal o_rx_data   : std_logic_vector(DATA_LEN-1 downto 0) := (others=>'0');
signal o_tx_line   : std_logic;

constant t : time := 8.68us;
constant t_05 : time := 4.34us;
constant t_15 : time := 17.36us;

begin


uut: entity work.UART_TOP
generic map (
FPGA_CLK_Hz   => 100_000_000,
BAUD_RATE_bps => 115_200,
DATA_LEN      => 8,
PARITY_BIT    => 0,
STOP_BIT      => 2,
REG_LEN       => 8 )
port map (
i_clk       => i_clk,
i_rst       => i_rst,
i_rx_line   => i_rx_line,
i_tx_rqst   => i_tx_rqst,
i_tx_data   => i_tx_data,
o_rx_data   => o_rx_data,
o_tx_line   => o_tx_line );



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
    i_rx_line <= '1';
    wait for t;
    
    -- 1 bit
    i_rx_line <= '0';
    wait for t;
    
    -- 2 bit
    i_rx_line <= '1';
    wait for t;
    
    -- 3 bit
    i_rx_line <= '0';
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
    i_rx_line <= '1';
    wait for t;
    
--    -- parity bit
--    i_rx_line <= '0';
--    wait for t;
    
    -- stop bit
    i_rx_line <= '1';
    wait for t_15;
    
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
    i_rx_line <= '1';
    wait for t;
    
    -- 7 bit
    i_rx_line <= '0';
    wait for t;
    
--    -- parity bit
--    i_rx_line <= '1';
--    wait for t;
    
    -- stop bit
    i_rx_line <= '1';
    wait for t_15;
    
--------------------------------------------

    wait for 1 ms;

    i_btn <= '1';
    i_tx_data <= x"c7";
    
    wait for 2000 us;

    i_btn <= '0';
    
    wait for 1ms;
    
    
    
    i_btn <= '1';
    i_tx_data <= x"6a";
    
    wait for 2000 us;

    i_btn <= '0';


wait;
end process;



end test;