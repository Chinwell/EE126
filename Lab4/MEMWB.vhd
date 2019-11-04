library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;

entity MEMWB is
port(
     clk    : in  STD_LOGIC;
     rst    : in  STD_LOGIC;
     MEM1   : in  STD_LOGIC_VECTOR(1 downto 0);
     MEM2   : in  STD_LOGIC_VECTOR(31 downto 0);  
     MEM3   : in  STD_LOGIC_VECTOR(31 downto 0);
     MEM4   : in  STD_LOGIC_VECTOR(4 downto 0);
     WB1    : out STD_LOGIC;
     WB2    : out STD_LOGIC;
     WB3    : out STD_LOGIC_VECTOR(31 downto 0);  
     WB4    : out STD_LOGIC_VECTOR(31 downto 0);
     WB5    : out STD_LOGIC_VECTOR(4 downto 0)
);
end MEMWB;

architecture behavioral of MEMWB is
begin
	process(clk,rst) is
	begin
	      if rst = '1' then
	          WB1 <= '0';
	          WB2 <='0';
	          WB3 <= x"00000000";  
	          WB4 <= x"00000000";
	          WB5 <= "00000";
	      elsif (clk'event and clk = '1') then
	          WB1 <= MEM1(1);
	          WB2 <= MEM1(0);      
	          WB3<= MEM2;
	          WB4 <= MEM3;
	          WB5<= MEM4;
	      end if;
	end process;
end behavioral;

--https://github.com/sanchezg/mips-pipeline-vhdl/blob/master/MemWb.vhd


