library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;

entity IFID is 
port(
     clk    : in   STD_LOGIC; 
     rst    : in   STD_LOGIC;
     w_enable  : in   STD_LOGIC;
     IF1    : in   STD_LOGIC_VECTOR(31 downto 0); 
     IF2    : in   STD_LOGIC_VECTOR(31 downto 0); 
     ID1    : out  STD_LOGIC_VECTOR(31 downto 0); 
     ID2    : out  STD_LOGIC_VECTOR(31 downto 0)
);
end IFID;

architecture behavioral of IFID is
begin
	process(clk,rst,w_enable) is
	begin
	      if rst = '1' then
	          ID1 <= X"00000000";
	          ID2 <= X"00000000";
	      elsif (w_enable = '1' and clk'event and clk = '1') then
	          ID1 <= IF1;
	          ID2 <= IF2;
	      end if;
	end process;
end behavioral;

--https://github.com/sanchezg/mips-pipeline-vhdl/blob/master/IFID.vhd
