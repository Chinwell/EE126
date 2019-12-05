library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;


entity EXMEM is
port(
     clk    : in STD_LOGIC;
     rst    : in STD_LOGIC;
     EX0    : in STD_LOGIC_VECTOR(31 downto 0);
     EX1    : in STD_LOGIC_VECTOR(1 downto 0);
     EX2    : in STD_LOGIC_VECTOR(2 downto 0);
     EX3    : in STD_LOGIC;
     EX4    : in STD_LOGIC_VECTOR(31 downto 0);  
     EX5    : in STD_LOGIC;
     EX6    : in  STD_LOGIC_VECTOR(31 downto 0);
     EX7    : in  STD_LOGIC_VECTOR(31 downto 0);
     EX8    : in  STD_LOGIC_VECTOR(4 downto 0);
     MEM0   : out STD_LOGIC_VECTOR(31 downto 0);
     MEM1   : out STD_LOGIC_VECTOR(1 downto 0);
     MEM2   : out STD_LOGIC;
     MEM3   : out STD_LOGIC;
     MEM4   : out STD_LOGIC;
     MEM5   : out STD_LOGIC;
     MEM6   : out STD_LOGIC_VECTOR(31 downto 0);  
     MEM7   : out STD_LOGIC;
     MEM8   : out STD_LOGIC_VECTOR(31 downto 0);
     MEM9   : out STD_LOGIC_VECTOR(31 downto 0);   
     MEM10  : out STD_LOGIC_VECTOR(4 downto 0)
);
end EXMEM;

architecture behavioral of EXMEM is
begin 
	process(clk,rst) is
	begin
	if rst = '1' then
		MEM0 <= x"00000000";
		MEM1 <= "00";
		MEM2 <= '0';
		MEM3 <= '0';
		MEM4 <= '0';
        MEM5 <= '0';
		MEM6 <= x"00000000";  
		MEM7 <= '0';
		MEM8 <= x"00000000";
		MEM9 <= x"00000000";
		MEM10 <= "00000";
   	 elsif (clk'event and clk = '1') then
		MEM0 <= EX0;
		MEM1 <= EX1;
		MEM2 <= EX2(2);
		MEM3 <= EX2(1);
		MEM4 <= EX2(0);
        MEM5 <= EX3;
		MEM6 <= EX4;
		MEM7 <= EX5;
		MEM8 <= EX6;
		MEM9 <= EX7;
		MEM10 <= EX8;
    end if;
end process;
end behavioral;

--https://github.com/sanchezg/mips-pipeline-vhdl/blob/master/Exmem.vhd

