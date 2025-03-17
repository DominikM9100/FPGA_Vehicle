library ieee;
use ieee.std_logic_1164.ALL;



entity UART_TOP is
generic (
FPGA_CLK_Hz   : integer;   -- [Hz]
BAUD_RATE_bps : integer;   -- [bps]
DATA_LEN      : integer;   -- 7 or 8
PARITY_BIT    : integer;   -- 0 or 1
STOP_BIT      : integer; -- 1 or 2
REG_LEN       : integer );
port (
i_rst         : in  std_logic;
i_clk         : in  std_logic;
i_tx_rqst     : in  std_logic; -- request to transmit new data
i_rx_line     : in  std_logic; -- rx line
i_tx_data     : in  std_logic_vector(DATA_LEN-1 downto 0); -- data to transmit
o_rx_data     : out std_logic_vector(DATA_LEN-1 downto 0); -- received data
o_tx_line     : out std_logic; --  tx line
o_servo_pos   : out std_logic_vector(REG_LEN-1 downto 0); -- position of servo mechanisms
o_mode        : out std_logic_vector(REG_LEN-1 downto 0); -- mode of the vechicle FORWARD, BACKWARD, ...
o_wheel_v     : out std_logic_vector(REG_LEN-1 downto 0); -- value of speed that the vehicle should ride with
o_turn_l      : out std_logic; -- signal weather the vehicle turns left
o_turn_r      : out std_logic ); -- signal weather the vehicle turns right
end;



architecture arch of UART_TOP is

signal rx_busy  : std_logic := '0';
signal tx_busy  : std_logic := '0';
signal rx_error : std_logic := '0';
signal rx_data  : std_logic_vector(DATA_LEN-1 downto 0) := (others=>'0');

begin



o_rx_data <= rx_data;



UART_RECEIVER: entity work.UART_RX
generic map (
FPGA_CLK_Hz   => FPGA_CLK_Hz,
BAUD_RATE_bps => BAUD_RATE_bps,
DATA_LEN      => DATA_LEN,
PARITY_BIT    => PARITY_BIT,
STOP_BIT      => STOP_BIT )
port map (
i_clk         => i_clk,
i_rst         => i_rst,
i_rx_line     => i_rx_line,
o_data        => rx_data,
o_busy        => rx_busy,
o_error       => rx_error );



UART_TRANSMITTER: entity work.UART_TX
generic map (
FPGA_CLK_Hz   => FPGA_CLK_Hz,
BAUD_RATE_bps => BAUD_RATE_bps,
DATA_LEN      => DATA_LEN,
PARITY_BIT    => PARITY_BIT,
STOP_BIT      => STOP_BIT )
port map (
i_rst         => i_rst,
i_clk         => i_clk,
i_rqst_send   => i_tx_rqst,
i_data        => i_tx_data,
o_busy        => tx_busy,
o_tx_line     => o_tx_line );



UART_DECODER: entity work.UART_DECODER
generic map (
REG_LEN     => REG_LEN )
port map (
i_clk       => i_clk,
i_uart_data => rx_data,
o_servo_pos => o_servo_pos,
o_mode      => o_mode,
o_wheel_v   => o_wheel_v,
o_turn_l    => o_turn_l,
o_turn_r    => o_turn_r );



end arch;