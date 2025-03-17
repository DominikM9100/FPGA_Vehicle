library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity PWM is
generic ( 
FPGA_CLK_Hz   : integer;
PWM_PERIOD_ms : integer );
port (
i_rst         : in  std_logic;
i_clk         : in  std_logic;
i_en          : in  std_logic;
i_duty        : in  std_logic_vector(16 downto 0); -- i.e. 85_239 -> 85.239%
o_pwm         : out std_logic );
end;



architecture arch of PWM is

constant PERIOD : integer := ( FPGA_CLK_Hz / 1_000 ) * PWM_PERIOD_ms;

signal cnt      : unsigned(26 downto 0) := (others=>'0');
signal r_data   : unsigned(i_duty'length+9 downto 0) := (others=>'0');
signal r_duty   : std_logic_vector(i_duty'length-1 downto 0) := (others=>'0');

begin



SAMPLE_NEW_DATA: process (i_rst, i_clk, i_en)
begin
  if i_rst='1' or i_en='0' then             -- there is no permission or reset is set
    r_duty <= (others=>'0');
    cnt <= (others=>'0');
  elsif rising_edge(i_clk) then
    if cnt<(to_unsigned(PERIOD, 27)-1) then -- check if still less then max value
      cnt <= cnt + 1;                       -- incerement counter
    else                                    -- when counter is equal to given period 
      r_duty <= i_duty;                     -- take new data
      cnt <= (others=>'0');                 -- reset counter
    end if;
  end if;
end process;



-- r_data <= unsigned(r_duty) * to_unsigned(PWM_PERIOD_ms, 10); -- for 100MHz
r_data <= unsigned('0' & r_duty(16 downto 1)) * to_unsigned(PWM_PERIOD_ms, 10); -- for 50MHz


COMPARE: process (i_rst, i_clk, i_en)
begin
  if i_rst='1' or i_en='0' then
    o_pwm <= '0';
  elsif rising_edge(i_clk) then
    if cnt<r_data then
      o_pwm <= '1';
    else
      o_pwm <= '0';
    end if;
  end if;
end process;



end arch;