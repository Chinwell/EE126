library ieee;
use ieee.std_logic_1164.all;


entity PC_tb is
end PC_tb;

architecture tb of PC_tb is

    signal write_enable, rst: std_logic;
    signal AddressIn, AddressOut: std_logic_vector(31 downto 0);
    signal clk : std_logic := '0';

begin
    instance0 : entity 
    work.PC port map(write_enable => write_enable, clk => clk, rst => rst, AddressIn => AddressIn, AddressOut => AddressOut);

    process
    begin
		clk <= '1';

        write_enable <= '0';
      	rst <= '0';
      	AddressIn <= x"00000000";
		wait for 100 ns;

		clk <= '0';
		wait for 100 ns;
      	clk <= '1';

	    write_enable <= '0';
      	rst <= '0';
      	AddressIn <= x"ABCD1234";
		wait for 100 ns;

      	clk <= '0';
		wait for 100 ns;	
		clk <= '1';

	    write_enable <= '0';
      	rst <= '1';
      	AddressIn <= x"00000000";
		wait for 100 ns;
		assert (AddressOut = x"00000000")
		report "Error occured: NO3" severity error;

      	clk <= '0';
		wait for 100 ns;	
		clk <= '1';
      		
	    write_enable <= '0';
      	rst <= '1';
      	AddressIn <= x"ABCD1234";
		wait for 100 ns;
		assert (AddressOut = x"00000000")
		report "Error occured: NO4" severity error;

      	clk <= '0';
		wait for 100 ns;	
		clk <= '1';
      		
	    write_enable <= '1';
      	rst <= '0';
      	AddressIn <= x"00000000";
		wait for 100 ns;
		assert (AddressOut = x"00000000")
		report "Error occured: NO5" severity error;

      	clk <= '0';
		wait for 100 ns;	
		clk <= '1';
      		
	    write_enable <= '1';
      	rst <= '0';
      	AddressIn <= x"ABCD1234";
		wait for 100 ns;
		assert (AddressOut = x"ABCD1234")
		report "Error occured: NO6" severity error;

      	clk <= '0';
		wait for 100 ns;	
		clk <= '1';
      		
	    write_enable <= '1';
      	rst <= '1';
      	AddressIn <= x"00000000";
		wait for 100 ns;
		assert (AddressOut = x"00000000")
		report "Error occured: NO7" severity error;

      	clk <= '0';
		wait for 100 ns;	
		clk <= '1';
      			
	    write_enable <= '1';
      	rst <= '1';
      	AddressIn <= x"ABCD1234";
		wait for 100 ns;
		assert (AddressOut = x"00000000")
		report "Error occured: NO8" severity error;

      		
	    write_enable <= 'X';
      	rst <= 'X';
      	AddressIn <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
 	    wait;

   end process;
end tb;
