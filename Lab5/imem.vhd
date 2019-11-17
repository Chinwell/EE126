library IEEE;
use IEEE.STD_LOGIC_1164.ALL; -- STD_LOGIC and STD_LOGIC_VECTOR
use IEEE.numeric_std.ALL; -- to_integer and unsigned

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
	process(Address)
	variable first:boolean := true;
	variable addr:integer;
	begin
		if (first) then
imemBytes(0) <= X"8C";
			imemBytes(1) <= X"08";
			imemBytes(2) <= X"00";
			imemBytes(3) <= X"00";
			imemBytes(4) <= X"01";
			imemBytes(5) <= X"08";
			imemBytes(6) <= X"40";
			imemBytes(7) <= X"20";
			imemBytes(8) <= X"01";
			imemBytes(9) <= X"08";
			imemBytes(10) <= X"48";
			imemBytes(11) <= X"20";
			imemBytes(12) <= X"01";
			imemBytes(13) <= X"28";
			imemBytes(14) <= X"50";
			imemBytes(15) <= X"22";
			imemBytes(16) <= X"AC";
			imemBytes(17) <= X"0A";
			imemBytes(18) <= X"00";
			imemBytes(19) <= X"04";
			imemBytes(20) <= X"AC";
			imemBytes(21) <= X"0A";
			imemBytes(22) <= X"00";
			imemBytes(23) <= X"06";
			imemBytes(24) <= X"00";
			imemBytes(25) <= X"00";
			imemBytes(26) <= X"00";
			imemBytes(27) <= X"00";
			imemBytes(28) <= X"00";
			imemBytes(29) <= X"00";
			imemBytes(30) <= X"00";
			imemBytes(31) <= X"00";
			imemBytes(32) <= X"00";
			imemBytes(33) <= X"00";
			imemBytes(34) <= X"00";
			imemBytes(35) <= X"00";
			imemBytes(36) <= X"00";
			imemBytes(37) <= X"00";
			imemBytes(38) <= X"00";
			imemBytes(39) <= X"00";
			imemBytes(40) <= X"00";
			imemBytes(41) <= X"00";
			imemBytes(42) <= X"00";
			imemBytes(43) <= X"00";
			imemBytes(44) <= X"00";
			imemBytes(45) <= X"00";
			imemBytes(46) <= X"00";
			imemBytes(47) <= X"00";
			imemBytes(48) <= X"00";
			imemBytes(49) <= X"00";
			imemBytes(50) <= X"00";
			imemBytes(51) <= X"00";
			first := false;
		end if;
		addr:=to_integer(unsigned(Address));
		if (addr+3 < NUM_BYTES) then
		ReadData <= imemBytes(addr) & imemBytes(addr+1) & imemBytes(addr+2) & imemBytes(addr+3);
		else report "Error" severity error;
		end if;
	end process;
end behaviour;
