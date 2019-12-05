library ieee;
use ieee.std_logic_1164.all;

entity harzard is 
port(
    IFIDrs	: in STD_LOGIC_VECTOR(4 downto 0);
    IFIDrt	: in STD_LOGIC_VECTOR(4 downto 0);    
    IDEXMEMr	: in std_logic;
    IDEXrt	: in STD_LOGIC_VECTOR(4 downto 0);
    PCw		: out std_logic;
    IFIDw	: out std_logic;
    MuxControl	: out std_logic
);
end harzard;

architecture arch of harzard is
begin
	process(IFIDrs,IFIDrt,IDEXMEMr,IDEXrt)
	begin
		if(IDEXMEMr = '1' and ((IDEXrt = IFIDrs) or (IDEXrt=IFIDrt))) then
			PCw <= '0';
			IFIDw <= '0';
			MuxControl <= '1';
		else
			PCw <= '1';
			IFIDw <= '1';
			MuxControl <= '0';
		end if;
	end process;
end arch;

--https://github.com/EricMiukyQin/MIPS32_vhdl/blob/master/hazard_detection_unit.vhd
