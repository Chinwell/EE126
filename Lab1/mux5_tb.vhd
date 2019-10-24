library ieee;
use ieee.std_logic_1164.all;

entity mux5_tb is
end mux5_tb;

architecture tb of mux5_tb is

    signal sel: std_logic;
    signal in0, in1, output: std_logic_vector(4 downto 0);

begin
    instance0 : entity 
        work.mux5 port map(in0 => in0, in1 => in1, sel => sel, output => output);

    process
    begin
    	in0<= "00000";
		in1<= "00000";
		sel<= '0';
		wait for 100 ns;
		assert (output = in0)
		report "Error occured No1" severity error;

    	in0<= "00000";
		in1<= "00000";
		sel<= '1';
		wait for 100 ns;
		assert (output = in1)
		report "Error occured No2" severity error;

    	in0<= "00000";
		in1<= "00010";
		sel<= '0';
		wait for 100 ns;
		assert (output = in0)
		report "Error occured No3" severity error;

    	in0<= "00000";
		in1<= "00010";
		sel<= '1';
		wait for 100 ns;
		assert (output = in1)
		report "Error occured No4" severity error;

		in0<= "00100";
		in1<= "00000";
		sel<= '0';
		wait for 100 ns;
		assert (output = in0)
		report "Error occured No5" severity error;

		in0<= "00100";
		in1<= "00000";
		sel<= '1';
		wait for 100 ns;
		assert (output = in1)
		report "Error occured No6" severity error;

		in0<= "00100";
		in1<= "00010";
		sel<= '0';
		wait for 100 ns;
		assert (output = in0)
		report "Error occured No7" severity error;

		in0<= "00100";
		in1<= "00010";
		sel<= '1';
		wait for 100 ns;
		assert (output = in1)
		report "Error occured No8" severity error;
  
		in0 <= "XXXXX";
		in1 <= "XXXXX";
		sel <= 'X';
		wait;

   end process;
end tb;
