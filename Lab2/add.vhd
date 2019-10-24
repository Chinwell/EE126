library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADD is
-- Adds two signed 32-bit inputs
-- output = in1 + in2
port(
     in0    : in  STD_LOGIC_VECTOR(31 downto 0);
     in1    : in  STD_LOGIC_VECTOR(31 downto 0);
     output : out STD_LOGIC_VECTOR(31 downto 0)
);
end ADD;

architecture behavioral of ADD is
begin
	output <= std_logic_vector(signed(in0)+signed(in1));
end behavioral;
