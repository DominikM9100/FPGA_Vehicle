library ieee;
use ieee.std_logic_1164.ALL;



entity UART_TX is
generic (
FPGA_CLK_Hz   : integer;
BAUD_RATE_bps : integer; 
DATA_LEN      : integer;
PARITY_BIT    : integer;
STOP_BIT      : integer );
port (
i_clk         : in  std_logic;
i_rst         : in  std_logic;
i_rqst_send   : in  std_logic;
i_data        : in  std_logic_vector(DATA_LEN-1 downto 0);
o_busy        : out std_logic;
o_tx_line     : out std_logic );
end;



architecture arch of UART_TX is

type STATES is ( IDLE, START, TRANSMITT, PARITY_CHECK, STOP );
signal STATE : STATES := IDLE;

constant CHANGE_CNT_MAX : integer := ( FPGA_CLK_Hz / BAUD_RATE_bps ) / 2 - 1;

signal phase_cnt       : integer range 0 to 2 := 0;
signal data_index      : integer range 0 to DATA_LEN-1 := 0;
signal change_phase    : std_logic := '0';
signal en_phase_cnt    : std_logic := '0';
signal en_stop_bit_cnt : std_logic := '0';
signal busy            : std_logic := '0';
signal tx_line         : std_logic := '0';

begin



CHANGE_GENERATOR: process (i_rst, i_clk)
  variable i : integer range 0 to CHANGE_CNT_MAX := 0;
begin
  if i_rst='1' then
    i := 0;
    change_phase <= '0';
  elsif rising_edge(i_clk) then
    if en_phase_cnt='1' or en_stop_bit_cnt='1' then -- check if there is a transmission 
      if i<CHANGE_CNT_MAX-1 then -- wait until the counter has a max value
        i := i + 1;
        change_phase <= '0';
      else -- change phase
        i := 0;
        change_phase <= '1';   
      end if;
    else
      i := 0;
      change_phase <= '0';
    end if;    
  end if;
end process;



PHASE_COUNTER: process (i_rst, i_clk, busy)
begin
  if i_rst='1' or busy='0' then
    phase_cnt <= 0;
  elsif rising_edge(i_clk) then    
    if change_phase='1' then -- wait for change to be possible
      if en_phase_cnt='1' and en_stop_bit_cnt='0' then -- when transmitting data
        if phase_cnt=0 then
          phase_cnt <= 1;
        else
          phase_cnt <= 0; 
        end if;
      elsif en_stop_bit_cnt='1' then -- when transmitting stop bit
        if phase_cnt<STOP_BIT then
          phase_cnt <= phase_cnt + 1;
        else
          phase_cnt <= 0;
        end if;
      end if;
    end if;
  end if;
end process;



SM: process (i_rst, i_clk)
    variable par_bit : std_logic := '0';
begin
  if i_rst='1' then 
    STATE <= IDLE;        
  elsif rising_edge(i_clk) then        
    case (STATE) is
        
      when IDLE =>
        busy <= '0';
        tx_line <= '1';
        en_phase_cnt <= '0';
        en_stop_bit_cnt <= '0';
        data_index <= 0;

        if i_rqst_send='1' then -- change state when request for the transmission
          STATE <= START;
        else
          STATE <= IDLE;
        end if;
            
      when START =>
        busy <= '1'; -- set busy flag
        tx_line <= '0'; -- send '0'
        en_phase_cnt <= '1'; -- enable the counter

        if phase_cnt=1 and change_phase='1' then -- change state after certain time
          STATE <= TRANSMITT;
        else
          STATE <= START;
        end if;            
            
      when TRANSMITT =>
        busy <= '1';
        en_phase_cnt <= '1';

        if data_index<DATA_LEN and phase_cnt=1 and change_phase='1' then -- check when to change the index
          data_index <= data_index + 1; -- increment the index
        end if;

        if data_index<DATA_LEN-1 then -- check if not out of boundry
          tx_line <= i_data(data_index); -- send the bit
        elsif data_index=DATA_LEN-1 then -- check if there is the last bit to be transmitted
          tx_line <= i_data(DATA_LEN-1); -- send the last bit
        end if;

        if PARITY_BIT=0 and phase_cnt=1 and change_phase='1' and data_index=DATA_LEN-1 then -- move if there is no parity bit
          STATE <= STOP;
        elsif phase_cnt=1 and change_phase='1' and data_index=DATA_LEN-1 then -- move if there is a parity bit
          STATE <= PARITY_CHECK;
        else
          STATE <= TRANSMITT;
        end if;            
            
      when PARITY_CHECK =>
        busy <= '1';
        en_phase_cnt <= '1';

        par_bit := i_data(i_data'low); -- sample the LSB
        for i in 1 to DATA_LEN-1 loop -- iterate through all data which will be send
          par_bit := par_bit xor i_data(i); -- xor all values
        end loop;

        tx_line <= par_bit; -- transmmit the xored value

        if phase_cnt=1 and change_phase='1' then
          STATE <= STOP;
        else
          STATE <= PARITY_CHECK;
        end if;            
            
      when STOP =>
        busy <= '1';
        en_phase_cnt <= '0';
        en_stop_bit_cnt <= '1';

        tx_line <= '1'; -- transmmit the stop bit

        if phase_cnt=(STOP_BIT*2)-1 and change_phase='1' then
          STATE <= IDLE;
        else
          STATE <= STOP;
        end if;            
            
      when others => -- should not end up in this state
        busy <= '0';
        en_phase_cnt <= '0';
        tx_line <= '1';

    end case;      
  end if;
end process;



o_busy    <= busy;
o_tx_line <= tx_line;



end arch;