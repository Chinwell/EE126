library ieee;
use ieee.std_logic_1164.all;

entity and2 is
port(
      in0    : in  STD_LOGIC;
      in1    : in  STD_LOGIC;
      output : out STD_LOGIC -- in0 and in1
);
end and2;

architecture data_flow of and2 is
begin
	output <= in0 and in1;
end data_flow;

