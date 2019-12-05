library ieee;
use ieee.std_logic_1164.all;

entity MUX32_3B is
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0);
    in1    : in STD_LOGIC_VECTOR(31 downto 0);
    in2    : in STD_LOGIC_VECTOR(31 downto 0);
    sel    : in STD_LOGIC_VECTOR(1 downto 0);
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end MUX32_3B;

architecture arch of MUX32_3B is
begin
process(in0, in1, in2, sel)
begin 
	if (sel = "00") then
		output <= in0;
	elsif (sel = "01") then
		output <= in1;
	elsif (sel = "10") then
		output <= in2;
	else
		output <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	end if;
end process;
end arch;
