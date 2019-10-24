library ieee;
use ieee.std_logic_1164.all;

entity ShiftLeft_A is -- Shifts the input by 2 bits
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(31 downto 0) -- x << 2
);
end ShiftLeft_A;

architecture arch of ShiftLeft_A is
begin
	y <= x sll 2;
end;
