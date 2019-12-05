library ieee;
use ieee.std_logic_1164.all;

entity ShiftLeft_B is
port(
     x : in  STD_LOGIC_VECTOR(31 downto 0);
     y : out STD_LOGIC_VECTOR(31 downto 0)
);
end ShiftLeft_B;

architecture shiftleft2_example of ShiftLeft_B is
begin
	y<=x sll 2;
end shiftleft2_example;


