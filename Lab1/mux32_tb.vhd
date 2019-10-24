library ieee;
use ieee.std_logic_1164.all;

entity mux32_tb is
end mux32_tb;

architecture tb of mux32_tb is
    signal sel: std_logic;
    signal in0, in1, output: std_logic_vector(31 downto 0);

begin
    instance0 : entity 
	work.mux32 port map(in0 => in0, in1 => in1, sel => sel, output => output);

    process
    begin
        in0 <= X"00000000";
        in1 <= X"00000000";
        sel <= '0';
        wait for 100 ns;
	assert (output = X"00000000")
	report "Error occured: NO1" severity error;
      
        in0 <= X"00000000";
        in1 <= X"00000000";
        sel <= '1';
        wait for 100 ns;
	assert (output = X"00000000")
	report "Error occured: NO2" severity error;
      
        in0 <= X"00000000";
        in1 <= X"0000000A";
        sel <= '0';
        wait for 100 ns;
	assert (output = in0)
	report "Error occured: NO3" severity error;
      
        in0 <= X"00000000";
        in1 <= X"0000000B";
        sel <= '1';
        wait for 100 ns;
	assert (output = in1)
	report "Error occured: NO4" severity error;
      
        in0 <= X"0000000C";
        in1 <= X"00000000";
        sel <= '0';
        wait for 100 ns;
	assert (output = in0)
	report "Error occured: NO5" severity error;
      
        in0 <= X"0000000D";
        in1 <= X"00000000";
        sel <= '1';
        wait for 100 ns;
	assert (output = in1)
	report "Error occured: NO6" severity error;
      
        in0 <= X"0000000E";
        in1 <= X"0000000A";
        sel <= '0';
        wait for 100 ns;
	assert (output = in0)
	report "Error occured: NO7" severity error;

        in0 <= X"0000000A";
        in1 <= X"0000000B";
        sel <= '1';
	wait for 100 ns;
	assert (output = in1)
	report "Error occured: NO8" severity error;
 	
	wait;
   end process;
end tb;
