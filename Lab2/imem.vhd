library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity IMEM is
-- The instruction memory is a byte addressable, big-endian, read-only memory
-- Reads occur continuously
-- HINT: Use the provided dmem.vhd as a starting point
generic(NUM_BYTES : integer := 128);
-- NUM_BYTES is the number of bytes in the memory (small to save computation resources)
port(
     Address  : in  STD_LOGIC_VECTOR(31 downto 0); -- Address to read from
     ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end IMEM;

architecture behaviour of IMEM is
type ByteArray is array (0 to NUM_BYTES) of STD_LOGIC_VECTOR(7 downto 0);
signal imemBytes : ByteArray;
begin
	process
    variable addr:integer;
	variable first:boolean := true;
	begin
		if (first) then
			imemBytes(0) <= x"00";
			imemBytes(1) <= x"00";
			imemBytes(2) <= x"00";
			imemBytes(3) <= x"00";
			
			first := false;
		end if;

        addr := to_integer(unsigned(Address));
        if((addr + 3) < NUM_BYTES) then
	            ReadData <= imemBytes(addr) & imemBytes(addr+1) & 
                            imemBytes(addr+2) & imemBytes(addr+3);
        else report "Error" severity error;
        end if;
	end process;
end behaviour;
