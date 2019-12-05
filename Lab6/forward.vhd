library ieee;
use ieee.std_logic_1164.all;

entity forward is 
port(
     IDEXrs	: in STD_LOGIC_VECTOR(4 downto 0);
     IDEXrt	: in STD_LOGIC_VECTOR(4 downto 0);
     EXMEMrd	: in STD_LOGIC_VECTOR(4 downto 0);
     MEMWBrd	: in STD_LOGIC_VECTOR(4 downto 0);
     EXMEMw	: in STD_LOGIC;
     MEMWBw	: in STD_LOGIC; 
     ForwardA	: out STD_LOGIC_VECTOR(1 downto 0);
     ForwardB	: out STD_LOGIC_VECTOR(1 downto 0)
);
end forward;

architecture arch of forward is
begin
	process(IDEXrs,IDEXrt,EXMEMrd,MEMWBrd,EXMEMw,MEMWBw)
	begin
		if ((EXMEMw ='1') 
			and (EXMEMrd /= "00000") 
			and (EXMEMrd = IDEXrs)) then
			ForwardA <= "10";
		elsif ((MEMWBw ='1') 
			and (MEMWBrd /= "00000") 
			and (MEMWBrd = IDEXrs)) then
			ForwardA <= "01";
		else
			ForwardA <= "00";
		end if;

		if ((EXMEMw ='1') 
			and (EXMEMrd /= "00000") 
			and (EXMEMrd = IDEXrt)) then
			ForwardB <= "10";
		elsif ((MEMWBw ='1') 
			and (MEMWBrd /= "00000") 
			and (MEMWBrd = IDEXrt)) then
			ForwardB <= "01";
		else
			ForwardB <= "00";
		end if;
	end process;
end arch;

--https://github.com/EricMiukyQin/MIPS32_vhdl/blob/master/forwarding_unit.vhd
