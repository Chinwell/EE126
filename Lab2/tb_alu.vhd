library ieee;
use ieee.std_logic_1164.all;

entity tb_alu is
end tb_alu;

architecture tb of tb_alu is
	signal a, b, result:STD_LOGIC_VECTOR(31 downto 0);
	signal operation:STD_LOGIC_VECTOR(3 downto 0);
	signal zero,overflow:STD_LOGIC;

begin
	instance0 : entity 
		work.alu port map(a => a, b => b, result => result,operation => operation, zero=>zero, overflow => overflow);
	
	process
	begin
		operation <= "0000";	--and
		a <= x"0F0F0F0F";
		b <= x"AAAAAAAA";
		wait for 100 ns;
		assert (result = x"0A0A0A0A")
		report "Error occured: NO1" severity error;

		operation <= "0001";	--or
		a <= x"0F0F0F0F";
		b <= x"F0F0F0F0";
		wait for 100 ns;
		assert (result = x"FFFFFFFF")
		report "Error occured: NO2" severity error;

		operation <= "0010";	--add
		a <= "01111111111111111111111111111111";
		b <= x"00000001";
		wait for 100 ns;
		assert (overflow = '1')
		report "Error occured: NO3" severity error;

		operation <= "0110";	--sub
		a <= x"0FFFFFFF";
		b <= x"0FFFFFFF";
		wait for 100 ns;
		assert (zero = '1')
		report "Error occured: NO4" severity error;

		operation <= "XXXX";
		a <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		b <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		wait;
	end process;
end tb;
