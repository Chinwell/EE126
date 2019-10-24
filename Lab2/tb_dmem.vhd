library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL; 

entity tb_dmem is
end tb_dmem;

architecture tb of tb_dmem is
    signal MemRead, MemWrite: std_logic;
    signal WriteData, Address, ReadData: std_logic_vector(31 downto 0);
    signal Clock : std_logic := '0';
    signal DEBUG_MEM_CONTENTS : STD_LOGIC_VECTOR(32*4 - 1 downto 0);

begin
    instance0 : entity 
	work.dmem port map(MemRead => MemRead, MemWrite => MemWrite, WriteData => WriteData, Address => Address,ReadData => ReadData, Clock => Clock, DEBUG_MEM_CONTENTS => DEBUG_MEM_CONTENTS);

    process
	begin
	    wait for 20 ns;
            Clock <= '1';
            wait for 20 ns;
            Clock <= '0';
    end process;

    process
    begin    

        MemWrite <= '1';
      	MemRead <= '0';
        WriteData <= x"0000000A";
      	Address <= x"00000008";
	wait for 40 ns;
        
	MemWrite <= '1';
      	MemRead <= '0';
        WriteData <= x"0000000B";
      	Address <= x"0000000C";
	wait for 40 ns;

        MemWrite <= '0';
      	MemRead <= '1';
      	Address <= x"00000008";
	wait for 40 ns;  
        assert (ReadData = x"0000000A")
	report "Error occured: NO1" severity error;

      
        MemWrite <= '0';
      	MemRead <= '1';
      	Address <= x"0000000C";
	wait for 40 ns;  
        assert (ReadData = x"0000000B")
	report "Error occured: NO2" severity error;


   end process;
end tb;
