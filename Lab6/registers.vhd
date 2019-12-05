library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity registers is

port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
     RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
     WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
     WD       : in  STD_LOGIC_VECTOR (31 downto 0);
     RegWrite : in  STD_LOGIC;
     Clock    : in  STD_LOGIC;
     RD1      : out STD_LOGIC_VECTOR (31 downto 0);
     RD2      : out STD_LOGIC_VECTOR (31 downto 0);
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end registers;

architecture behavioral of registers is
type regArry is array (0 to 32) of STD_LOGIC_VECTOR(31 downto 0);
signal regA : regArry;
begin
     process(Clock,RR1,RR2,WR,WD,RegWrite)
     variable addr:integer;
     variable first:boolean :=true;
     begin

          if(first) then
               regA(0) <= X"00000000";
               regA(8) <= X"00000001";
               regA(9) <= X"00000002";
               regA(10) <= X"00000004";
               regA(11) <= X"00000008";
               regA(16) <= X"00000001";
               regA(17) <= X"00000002";
               regA(18) <= X"8badf00d";
               regA(19) <= X"8badf00d";
               first := false;
          end if;

	if Clock = '0' and Clock'event and RegWrite='1' then
               addr := to_integer(unsigned(WR));
               if addr = 0 then
                    regA(addr) <= X"00000000";
               else
                    regA(addr) <= WD;
               end if;
          end if;
     end process;


     RD1 <= X"00000000" when RR1 = "00000" else regA(to_integer(unsigned(RR1)));
     RD2 <= X"00000000" when RR2 = "00000" else regA(to_integer(unsigned(RR2)));
     DEBUG_TMP_REGS <= regA(8) & regA(9) & regA(10) & regA(11);
     DEBUG_SAVED_REGS <= regA(16) & regA(17) & regA(18) & regA(19);


end behavioral;
