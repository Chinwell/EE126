library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;

entity IDEX is 
port(
     clk	: in STD_LOGIC;
     rst	: in STD_LOGIC;
     ID1	: in STD_LOGIC;
     ID2	: in STD_LOGIC;
     ID3	: in STD_LOGIC;
     ID4	: in STD_LOGIC;
     ID5	: in STD_LOGIC;
     ID6	: in STD_LOGIC;
     ID7	: in STD_LOGIC;
     ID8	: in STD_LOGIC_VECTOR(1 downto 0);
     ID9	: in  STD_LOGIC_VECTOR(31 downto 0);  
     ID10	: in  STD_LOGIC_VECTOR(31 downto 0);
     ID11	: in  STD_LOGIC_VECTOR(31 downto 0); 
     ID12	: in  STD_LOGIC_VECTOR(31 downto 0);
     ID13	: in STD_LOGIC_VECTOR(4 downto 0);
     ID14	: in STD_LOGIC_VECTOR(4 downto 0);
     ID15	: in STD_LOGIC_VECTOR(4 downto 0);
     EX1	: out STD_LOGIC_VECTOR(1 downto 0);
     EX2	: out STD_LOGIC_VECTOR(2 downto 0);
     EX3	: out STD_LOGIC;
     EX4	: out STD_LOGIC;
     EX5	: out STD_LOGIC_VECTOR(1 downto 0);
     EX6	: out STD_LOGIC_VECTOR(31 downto 0);
     EX7	: out STD_LOGIC_VECTOR(31 downto 0);
     EX8	: out STD_LOGIC_VECTOR(31 downto 0); 
     EX9	: out STD_LOGIC_VECTOR(31 downto 0);
     EX10	: out STD_LOGIC_VECTOR(4 downto 0);
     EX11	: out STD_LOGIC_VECTOR(4 downto 0);
     EX12	: out STD_LOGIC_VECTOR(4 downto 0)
);
end IDEX;

architecture behavioral of IDEX is
	signal WB : STD_LOGIC_VECTOR(1 downto 0);
	signal M  : STD_LOGIC_VECTOR(2 downto 0);
begin
	WB <= ID7 & ID4;
	M <= ID2 & ID3 & ID5;
	process(clk,rst) is
	begin
	if rst = '1' then
		EX1 <= "00";
		EX2  <= "000";
		EX3 <= '0';
		EX4 <= '0';
		EX5 <= "00";
		EX6 <= x"00000000";
		EX7 <= x"00000000";
		EX8 <= x"00000000"; 
		EX9 <= x"00000000";
		EX10 <= "00000";
		EX11 <= "00000";
		EX12 <= "00000";
    	elsif(clk'event and clk = '1')then
		EX1 <= WB;
		EX2 <= M;
		EX3 <= ID1;
		EX5 <= ID8;
		EX4 <= ID6;
		EX6<= ID9;
		EX7 <= ID10;
		EX8 <= ID11;
		EX9 <= ID12;
		EX10 <= ID13;
		EX11 <= ID14;
		EX12 <= ID15;
    end if;	
end process;
end behavioral;

--https://github.com/sanchezg/mips-pipeline-vhdl/blob/master/IDEX.vhd



