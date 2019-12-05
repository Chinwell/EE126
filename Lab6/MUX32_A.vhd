library ieee;
use ieee.std_logic_1164.all;

entity MUX32_A is
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0);
    in1    : in STD_LOGIC_VECTOR(31 downto 0);
    sel    : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end MUX32_A;

architecture arch of MUX32_A is
begin
process(in0, in1, sel)
begin 
	if(sel = '0') then 
		output <= in0;
	elsif(sel = '1') then 
		output <= in1;
	end if;
end process;
end arch;
