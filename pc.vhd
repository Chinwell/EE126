library ieee;
use ieee.std_logic_1164.all;

entity PC is -- 32-bit rising-edge triggered register with write-enable and asynchronous reset
-- For more information on what the PC does, see page 251 in the textbook
port(
     clk          : in  STD_LOGIC; -- Propogate AddressIn to AddressOut on rising edge of clock
     write_enable : in  STD_LOGIC; -- Only write if '1'
     rst          : in  STD_LOGIC; -- Asynchronous reset! Sets AddressOut to 0x0
     AddressIn    : in  STD_LOGIC_VECTOR(31 downto 0); -- Next PC address
     AddressOut   : out STD_LOGIC_VECTOR(31 downto 0) -- Current PC address
);
end PC;

architecture arch of PC is
begin
	sync_stuff: process (clk,write_enable,rst)
    begin
		if rst = '1'
			then AddressOut <=X"00000000";
		elsif (clk'event and clk ='1') then
            if write_enable = '1'
			then AddressOut <= AddressIn;
		end if;
 	end if;
end process;

end arch;
