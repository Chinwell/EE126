library ieee;
use ieee.std_logic_1164.all;

entity ShiftLeft2 is -- Shifts the input by 2 bits
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(31 downto 0) -- x << 2
);
end ShiftLeft2;

architecture arch of ShiftLeft2 is
begin
	y <= x(29 downto 0) & x(31 downto 30);
end;
