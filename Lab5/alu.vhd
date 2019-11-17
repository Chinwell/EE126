library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.numeric_std.ALL; -- to_integer and unsigned

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
--    as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'MIPS Reference Data' sheet at the
--    front of the textbook.
port(
     a         : in     STD_LOGIC_VECTOR(31 downto 0);
     b         : in     STD_LOGIC_VECTOR(31 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(31 downto 0):=X"00000000";
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
);
end ALU;

architecture alu_behaviour of ALU is

signal res : STD_LOGIC_VECTOR(31 downto 0);
signal extend        : STD_LOGIC_VECTOR(32 downto 0);

begin 
	process (a,b,operation)
	begin
		case (operation) is
			when "0000" =>
				res <= a and b;
			when "0001" => 
				res <= a or b;
			when "0010" => 
				res <= a+b;
				extend <= ('0'&a) + ('0'&b);
			when "0110" => 
				res <= a-b;
				extend <= ('0'&a) - ('0'&b);
			when "0111" => 
				if (a<b) then
					res <= X"00000001";
				else 
					res <= X"00000000";
				end if;
			when "1100" => 
				res <= a nor b;
			when others =>
				res <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		end case;
	end process;
	process(res)
	begin
		if (res = X"00000000") then
			zero <= '1';
		else 
			zero <= '0';
		end if;
	end process;
	result <= res;
	overflow <= extend(32) xor extend(31);
end alu_behaviour;


