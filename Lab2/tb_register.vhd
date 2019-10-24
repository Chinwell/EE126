library ieee;
use ieee.std_logic_1164.all;

entity tb_registers is
end tb_registers;

architecture tb of tb_registers is
	signal RR1, RR2, WR:STD_LOGIC_VECTOR(4 downto 0);
	signal WD, RD1, RD2:STD_LOGIC_VECTOR(31 downto 0);
	signal RegWrite,Clock:STD_LOGIC;
	signal DEBUG_TMP_REGS,DEBUG_SAVED_REGS:STD_LOGIC_VECTOR(32*4 - 1 downto 0);

begin
	instance0 : entity 
		work.registers port map(DEBUG_TMP_REGS =>DEBUG_TMP_REGS,DEBUG_SAVED_REGS=>DEBUG_SAVED_REGS,RR1 => RR1, RR2 => RR2, WR => WR,WD => WD, RD1=>RD1, RD2 => RD2, RegWrite => RegWrite, Clock => Clock);
	
	process
	begin
		Clock <= '0';
		wait for 25 ns;
		Clock <= '1';
		wait for 25 ns;
	end process;	

	process
	begin
		wait for 25 ns;

		RegWrite <= '1';
		WR <= "00001";
		WD <= x"FFFFFFFF";
		RR1 <= "00001";
		RR2 <= "01001";
		wait for 50 ns;

		RegWrite <= '1';
		WR <= "00000";
		WD <= x"11111111";
		RR1 <= "10000";
		RR2 <= "10010";
		wait for 50 ns;

		RegWrite <= 'X';
		WR <= "XXXXX";
		WD <= x"XXXXXXXX";
		RR1 <= "XXXXX";
		RR2 <= "XXXXX";
		wait;
	end process;
end tb;
