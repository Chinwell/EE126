library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity ALU is
-- Implement: AND, OR, ADD (signed), SUBTRACT (signed)
--    as described in Section 4.4 in the textbook.
-- The functionality of each instruction can be found on the 'MIPS Reference Data' sheet at the
--    front of the textbook.
port(
     a         : in     STD_LOGIC_VECTOR(31 downto 0);
     b         : in     STD_LOGIC_VECTOR(31 downto 0);
     operation : in     STD_LOGIC_VECTOR(3 downto 0);
     result    : buffer STD_LOGIC_VECTOR(31 downto 0);
     zero      : buffer STD_LOGIC;
     overflow  : buffer STD_LOGIC
);
end ALU;

architecture behavioral of ALU is
signal extend : STD_LOGIC_VECTOR(32 downto 0):="000000000000000000000000000000000";

begin 
	process (operation,a,b,extend)
	begin
		case operation is
			when "0000" => 	--and
				result <= a and b;
			when "0001" => 	--or
				result <= a or b;
			when "0010" => 	--add
				result <= a + b;
				extend <= ('0' & a) + ('0' & b);
        			overflow <= extend(31) xor extend(32);
			when "0110" => 	--sub
				result <= a-b;
				extend <= ('0' & a) - ('0' & b);
        			overflow <= extend(31) xor extend(32);
			when others =>
                		result<="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
		end case;

        if (result = X"00000000") then
			zero <= '1';
		else 
			zero <= '0';
		end if;
	end process;

end behavioral;
