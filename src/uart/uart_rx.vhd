library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity UART_RX is
generic (
FPGA_CLK_Hz   : integer;
BAUD_RATE_bps : integer;
DATA_LEN       : integer;
PARITY_BIT    : integer;
STOP_BIT      : integer );
port (
i_clk         : in  std_logic;
i_rst         : in  std_logic;
i_rx_line     : in  std_logic;
o_error       : out std_logic;
o_busy        : out std_logic;
o_data        : out std_logic_vector(DATA_LEN-1 downto 0) );
end;



architecture arch of UART_RX is
	
constant COUNTER_MAX : integer := ( FPGA_CLK_Hz / BAUD_RATE_bps ) / 2 - 1;

signal cnt1          : integer := 0; -- i
signal index         : integer := 0;
signal cnt2          : std_logic := '0'; -- j
signal change_index  : std_logic := '0';
signal busy          : std_logic := '0';
signal start_rx      : std_logic := '0';
signal end_rx        : std_logic := '0';
signal error_parity  : std_logic := '0';
signal rx_line       : std_logic := '1';
signal r_change      : std_logic_vector(1 downto 0) := (others=>'0');
signal r_rx_line     : std_logic_vector(1 downto 0) := (others=>'1');
signal r_data_prev   : std_logic_vector((DATA_LEN+PARITY_BIT+STOP_BIT) downto 0) := (others=>'0');
signal r_data        : std_logic_vector((DATA_LEN+PARITY_BIT+STOP_BIT) downto 0) := (others=>'0');

begin



change_index <= not r_change(1) and r_change(0); -- signal the change of index
rx_line      <= r_rx_line(1) and r_rx_line(0); -- synched rx line
start_rx     <= not(rx_line) and not(busy); -- detect the biginning of transmission
o_busy       <= busy; -- signal ongoing transmission



SYCH_RX_LINE_WITH_CLOCK_DOMAIN: process (i_rst, i_clk)
begin
  if i_rst='1' then
    r_rx_line <= (others=>'1');
  elsif rising_edge(i_clk) then
    r_rx_line <= r_rx_line(0) & i_rx_line;
  end if;
end process;



CHANGE_INDEX_PULSE_GENERATOR: process (i_rst, i_clk)
begin
  if i_rst='1' then
    cnt1 <= 0;
    cnt2 <= '0';
  elsif rising_edge(i_clk) then
    if busy='1' then -- check if there is a transmission
      if cnt1<COUNTER_MAX then -- count up until the max value
        cnt1 <= cnt1 + 1;
      else
        cnt1 <= 0;
        if cnt2='0' then
          cnt2 <= '1';
        else
          cnt2 <= '0';
        end if;
      end if;
    else
      cnt1 <= 0;
      cnt2 <= '0';
    end if;
  end if;
end process;



EDGE_DETECTION: process (i_rst, i_clk, busy)
begin
  if i_rst='1' or busy='0' then
    r_change <= (others=>'0');
  elsif rising_edge(i_clk) then
    r_change <= r_change(0) & cnt2;
  end if;
end process;



RECEIVING: process (i_rst, i_clk)
begin
  if i_rst='1' then
    busy <= '0';
    end_rx <= '0';
    index <= 0;
    r_data <= (others=>'0');
  elsif rising_edge(i_clk) then
    if start_rx='1' then
      busy <= '1'; -- begin receiving
    elsif end_rx='1' then
      busy <= '0';  -- end receiving
    else
      busy <= busy;
    end if;

    if index=(DATA_LEN + PARITY_BIT + STOP_BIT + 1) then -- check if there is the end of transmission
      if cnt1=COUNTER_MAX then
        end_rx <= '1'; -- end of transmission
      else
        end_rx <= '0';
      end if;
    else
      end_rx <= '0';
    end if;

    if busy='1' then -- when there is a transmission
      if change_index='1' then -- change index
        index <= index + 1; -- increment index
        r_data(index) <= rx_line; -- sample data form rx line
      else
        index <= index;
      end if;
    else -- when there is no transmission
      r_data <= r_data;
      index <= 0;
    end if;
  end if;
end process;



PARITY_CHECK: process (i_rst, i_clk)
	variable xor_gate : std_logic := '0'; -- for xor operations
begin
  if i_rst='1' then
    error_parity <= '0'; -- set no error
  elsif rising_edge(i_clk) then
    if PARITY_BIT/=0 then -- check if parity bit was set
      if index=DATA_LEN+2 then -- wait for parity bit to be received
        xor_gate := r_data(1); -- assign LSB first
        for k in 2 to DATA_LEN loop -- iterate through all data bits
          xor_gate := xor_gate xor r_data(k); -- for even parity
          -- xor_gate := xor_gate xnor r_data(k); -- for odd parity
        end loop;
        error_parity <= xor_gate; -- send outcome
      end if;
    else
      error_parity <= '0'; -- set no error
    end if;
  end if;
end process;



DATA_SEND: process (i_rst, i_clk)
begin
  if i_rst='1' then
    o_data <= (others=>'0');
  elsif rising_edge(i_clk) then
    if busy='0' then -- wait until the transmission is over
      if error_parity='1' then -- if parity check failed
        o_data <= r_data_prev(DATA_LEN downto 1); -- send previous data if error occurred
      else -- if data received correctly
        o_data <= r_data(DATA_LEN downto 1); -- send received data if no error
        r_data_prev <= r_data; -- update previous data
      end if;
      o_error <= error_parity; -- error signal update      
    end if;
  end if;
end process;



end arch;