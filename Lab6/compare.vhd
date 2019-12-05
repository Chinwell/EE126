library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;

entity compare is
port(
	input1 : in std_logic_vector(31 downto 0);
	input2 : in std_logic_vector(31 downto 0);
	res : out std_logic
);
end compare;

architecture arch of compare is
begin
	process(input1,input2)
	begin
		if input1 = input2 then
			res <= '1';
		else 
			res <= '0';
		end if;
	end process;
end arch;
