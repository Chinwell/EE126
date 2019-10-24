library ieee;
use ieee.std_logic_1164.all;

entity SignExtend is
port(
     x : in  STD_LOGIC_VECTOR(15 downto 0);
     y : out STD_LOGIC_VECTOR(31 downto 0) -- sign-extend(x)
);
end SignExtend;


architecture arch of SignExtend is
	Signal DataEXD: std_logic_vector(31 downto 0);
begin
	DataEXD <= x"0000" & x(15 downto 0);
	y <= DataEXD;

end arch;
