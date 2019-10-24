library ieee;
use ieee.std_logic_1164.all;


entity shiftLeft2_tb is
end shiftLeft2_tb;

architecture tb of shiftLeft2_tb is

    signal x, y: std_logic_vector(31 downto 0);

begin
    instance0 : entity 
        work.shiftLeft2 port map(x => x, y => y);

    process
    begin
		x <= "00000000000000000000000000001111";
		wait for 100 ns;
		assert (y = "00000000000000000000000000111100")
		report "Error occured: NO1" severity error;

		x <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
 		wait;

   end process;
end tb;
