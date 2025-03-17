library ieee;
use ieee.std_logic_1164.ALL;



entity US_DISTANCE_COUNTER_TB is
end;



architecture test of US_DISTANCE_COUNTER_TB is

constant FPGA_CLK_Hz : integer := 100_000_000;
constant IMPULSE_MAX : integer := (FPGA_CLK_Hz / 1_000_000) * 11;
constant I_MAX       : integer := ((FPGA_CLK_Hz / 1_000) * 20) - 1;
constant I_MAX_CNT   : integer := ((FPGA_CLK_Hz / 1_000_000) * 17) - 1;
constant REG_LEN    : integer := 16;


signal i_rst         : std_logic := '1';
signal i_clk         : std_logic := '0';
signal i_inc_dist    : std_logic := '0';
signal i_del         : std_logic := '0';
signal i_en          : std_logic := '0';
signal i_en_from_CU  : std_logic := '1';
signal o_distance    : std_logic_vector(REG_LEN-1 downto 0);

begin



i_clk <= not i_clk after 5ns;



uut: entity work.US_DISTANCE_COUNTER
generic map (
REG_LEN   => REG_LEN )
port map (
i_rst      => i_rst,
i_clk      => i_clk,
i_inc_dist => i_inc_dist,
i_del      => i_del,
i_en       => i_en,
o_distance => o_distance );



GENERATE_IMPULSE: process ( i_rst, i_clk )
variable i : integer := 0;
begin
if i_rst='1' or i_en_from_CU='0' then
  i_del <= '0'; 
  i     := 0;
elsif rising_edge(i_clk) then
  if i<I_MAX then
    i := i + 1;
  else
    i := 0;
  end if;
  if i<IMPULSE_MAX then
    i_del <= '1';
  else
    i_del <= '0'; 
  end if;
end if;
end process;



DISTANCE_IMP_GEN: process ( i_rst, i_clk )
variable i : integer := 0;
begin
if i_rst='1' or i_en='0' then
    i_inc_dist <= '0';
    i          := 0;
elsif rising_edge(i_clk) then
  if i<I_MAX_CNT then
    i_inc_dist <= '0';
    i          := i + 1;
  else
    i_inc_dist <= '1';
    i          := 0;
  end if;
end if;
end process;



process
begin

wait for 100us;
i_rst <= '0';
wait for 100us;

wait until falling_edge(i_del);
i_en <= '1';
wait for 11ms;
i_en <= '0';

wait until falling_edge(i_del);
i_en <= '1';
wait for 5ms;
i_en <= '0';

i_en_from_CU <= '0';

wait;
end process;



end test;