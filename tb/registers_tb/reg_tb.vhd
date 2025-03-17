
library ieee;
use ieee.std_logic_1164.all;



entity REG_tb is
end;



architecture Behavioral of REG_tb is

constant REG_LEN : integer := 8;

signal i_clk         : std_logic := '0';
signal i_rst         : std_logic := '1';
signal i_en_write    : std_logic := '0';
signal i_d           : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal o_q           : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal o_nbr         : std_logic_vector(REG_LEN-1 downto 0);

begin



i_clk <= not i_clk after 5ns;



I_REG: entity work.REG
generic map (
REG_LEN => 8,
REG_NUMBER => 3 )
port map (
i_clk           => i_clk,
i_rst           => i_rst,
i_en_write      => i_en_write,
i_d             => i_d,
o_q             => o_q,
o_nbr           => o_nbr );



process
begin

-- begin test
wait for 100us;
i_rst <= '0';
wait for 100us;

-- check enable
i_d <= x"55";
wait for 100us;
i_en_write <= '1';
wait for 100us;
i_d <= x"aa";
wait for 100us;
i_d <= x"c6";

-- check reset
wait for 100us;
i_rst <= '1';

wait;

end process;



end Behavioral;