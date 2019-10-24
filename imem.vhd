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
			imemBytes(1) <= X"0A";
			imemBytes(2) <= X"00";
			imemBytes(3) <= X"00";
			imemBytes(4) <= X"11";
			imemBytes(5) <= X"0A";
			imemBytes(6) <= X"00";
			imemBytes(7) <= X"03";
			imemBytes(8) <= X"02";
			imemBytes(9) <= X"11";
			imemBytes(10) <= X"80";
			imemBytes(11) <= X"22";
			imemBytes(12) <= X"01";
			imemBytes(13) <= X"09";
			imemBytes(14) <= X"40";
			imemBytes(15) <= X"20";
			imemBytes(16) <= X"08";
			imemBytes(17) <= X"00";
			imemBytes(18) <= X"00";
			imemBytes(19) <= X"01";
			imemBytes(20) <= X"02";
			imemBytes(21) <= X"0B";
			imemBytes(22) <= X"90";
			imemBytes(23) <= X"25";
			imemBytes(24) <= X"02";
			imemBytes(25) <= X"53";
			imemBytes(26) <= X"90";
			imemBytes(27) <= X"24";
			imemBytes(28) <= X"AD";
			imemBytes(29) <= X"72";
			imemBytes(30) <= X"00";
			imemBytes(31) <= X"04";
			imemBytes(32) <= X"00";
			imemBytes(33) <= X"00";
			imemBytes(34) <= X"00";
			imemBytes(35) <= X"00";
			first := false;
		end if;
		addr:=to_integer(unsigned(Address));
		if (addr+3 < NUM_BYTES) then
		ReadData <= imemBytes(addr) & imemBytes(addr+1) & imemBytes(addr+2) & imemBytes(addr+3);
		else report "Error" severity error;
		end if;
	end process;
end behaviour;
