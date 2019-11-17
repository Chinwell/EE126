library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mux is 
port(
    RegDst_in   : in STD_LOGIC:='0';
    Branch_in   : in STD_LOGIC:='0';
    MemRead_in  : in STD_LOGIC:='0';
    MemtoReg_in : in STD_LOGIC:='0';
    MemWrite_in : in STD_LOGIC:='0';
    ALUSrc_in   : in STD_LOGIC:='0';
    RegWrite_in : in STD_LOGIC:='0';
    Jump_in     : in STD_LOGIC:='0';
    ALUOp_in    : in STD_LOGIC_VECTOR(1 downto 0):="00";
    sel         : in std_logic;

    RegDst_out  : out STD_LOGIC:='0';
    Branch_out  : out STD_LOGIC:='0';
    MemRead_out : out STD_LOGIC:='0';
    MemtoReg_out    : out STD_LOGIC:='0';
    MemWrite_out    : out STD_LOGIC:='0';
    ALUSrc_out  : out STD_LOGIC:='0';
    RegWrite_out    : out STD_LOGIC:='0';
    Jump_out    : out STD_LOGIC:='0';
    ALUOp_out   : out STD_LOGIC_VECTOR(1 downto 0):="00"
);
end mux;

architecture arch of mux is
begin
	process(RegDst_in,Branch_in,MemRead_in,MemtoReg_in,MemWrite_in,ALUSrc_in,RegWrite_in,Jump_in,ALUOp_in,sel)
	begin
		if(sel = '0') then
			RegDst_out <= RegDst_in;
			Branch_out <= Branch_in;
			MemRead_out <= MemRead_in;
			MemtoReg_out <= MemtoReg_in;
			MemWrite_out <= MemWrite_in;
			ALUSrc_out <= ALUSrc_in;
			RegWrite_out <= RegWrite_in;
			Jump_out <= Jump_in;
			ALUOp_out <= ALUOp_in;
		else
			RegDst_out <= '0';
			Branch_out <= '0';
			MemRead_out <= '0';
			MemtoReg_out <= '0';
			MemWrite_out <= '0';
			ALUSrc_out <= '0';
			RegWrite_out <= '0';
			Jump_out <= '0';
			ALUOp_out <= "00";
		end if;
	end process;
end arch;




			
