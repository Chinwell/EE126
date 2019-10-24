library ieee;
use ieee.std_logic_1164.all;

entity SignExtend_tb is
end SignExtend_tb;

architecture tb of SignExtend_tb is
   signal x: std_logic_vector(15 downto 0);
   signal y: std_logic_vector(31 downto 0);

begin
    instance0 : entity 
        work.SignExtend port map(x => x, y => y);

   process
   begin
      	x <= X"ABCD";
      	wait for 100 ns;
		assert (y = X"0000ABCD")
		report "Error occured" severity error;

      	x <= "XXXXXXXXXXXXXXXX";
		wait;
      
   end process;
end tb;
