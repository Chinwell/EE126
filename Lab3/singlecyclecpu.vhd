library	ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;			   
use ieee.std_logic_unsigned.all;

entity SingleCycleCPU is
port(clk :in STD_LOGIC;
     rst :in STD_LOGIC;
     --Probe ports used for testing
     --The current address (AddressOut from the PC)
     DEBUG_PC : out STD_LOGIC_VECTOR(31 downto 0);
     --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
     DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end SingleCycleCPU;

architecture struct of singlecyclecpu is

    component ADD_A is
    port(
        in0    : in  STD_LOGIC_VECTOR(31 downto 0);
        in1    : in  STD_LOGIC_VECTOR(31 downto 0);
        output : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component ADD_B is
    port(
        in0    : in  STD_LOGIC_VECTOR(31 downto 0);
        in1    : in  STD_LOGIC_VECTOR(31 downto 0);
        output : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component ALU is
    port(
        a         : in     STD_LOGIC_VECTOR(31 downto 0);
        b         : in     STD_LOGIC_VECTOR(31 downto 0);
        operation : in     STD_LOGIC_VECTOR(3 downto 0);
        result    : buffer STD_LOGIC_VECTOR(31 downto 0);
        zero      : buffer STD_LOGIC;
        overflow  : buffer STD_LOGIC
    );
    end component;

    component ALUControl is
    port(
         ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
         Funct     : in  STD_LOGIC_VECTOR(5 downto 0);
         Operation : out STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;

    component CPUControl is
    port(Opcode   : in  STD_LOGIC_VECTOR(5 downto 0);
         RegDst   : out STD_LOGIC:='0';
         Branch   : out STD_LOGIC:='0';
         MemRead  : out STD_LOGIC:='0';
         MemtoReg : out STD_LOGIC:='0';
         MemWrite : out STD_LOGIC:='0';
         ALUSrc   : out STD_LOGIC:='0';
         RegWrite : out STD_LOGIC:='0';
         Jump     : out STD_LOGIC:='0';
         ALUOp    : out STD_LOGIC_VECTOR(1 downto 0):="00"
    );
    end component;

    component DMEM is
    generic(NUM_BYTES : integer := 32);
    port(
         WriteData          : in  STD_LOGIC_VECTOR(31 downto 0);
         Address            : in  STD_LOGIC_VECTOR(31 downto 0);
         MemRead            : in  STD_LOGIC;
         MemWrite           : in  STD_LOGIC;
         Clock              : in  STD_LOGIC;
         ReadData           : out STD_LOGIC_VECTOR(31 downto 0);
         DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
    );
    end component;

    component IMEM is
    generic(NUM_BYTES : integer := 128);
    port(
         Address  : in  STD_LOGIC_VECTOR(31 downto 0);
         ReadData : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component registers is
    port(RR1      : in  STD_LOGIC_VECTOR (4 downto 0); 
         RR2      : in  STD_LOGIC_VECTOR (4 downto 0); 
         WR       : in  STD_LOGIC_VECTOR (4 downto 0); 
         WD       : in  STD_LOGIC_VECTOR (31 downto 0);
         RegWrite : in  STD_LOGIC;
         Clock      : in  STD_LOGIC;
         RD1      : out STD_LOGIC_VECTOR (31 downto 0);
         RD2      : out STD_LOGIC_VECTOR (31 downto 0);
         DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
         DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
    );
    end component;

    component and2 is
    port(
          in0    : in  STD_LOGIC;
          in1    : in  STD_LOGIC;
          output : out STD_LOGIC
    );
    end component;

    component MUX5 is    
    port(
        in0    : in STD_LOGIC_VECTOR(4 downto 0);
        in1    : in STD_LOGIC_VECTOR(4 downto 0);
        sel    : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(4 downto 0)
    );
    end component;

    component MUX32_A is
    port(
        in0    : in STD_LOGIC_VECTOR(31 downto 0);
        in1    : in STD_LOGIC_VECTOR(31 downto 0);
        sel    : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component MUX32_B is
    port(
        in0    : in STD_LOGIC_VECTOR(31 downto 0);
        in1    : in STD_LOGIC_VECTOR(31 downto 0);
        sel    : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component MUX32_C is
    port(
        in0    : in STD_LOGIC_VECTOR(31 downto 0);
        in1    : in STD_LOGIC_VECTOR(31 downto 0);
        sel    : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component MUX32_D is
    port(
        in0    : in STD_LOGIC_VECTOR(31 downto 0);
        in1    : in STD_LOGIC_VECTOR(31 downto 0);
        sel    : in STD_LOGIC;
        output : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

	component PC is
	port(
        clk          : in  STD_LOGIC;
        write_enable : in  STD_LOGIC:='1';
	    rst          : in  STD_LOGIC;
	    AddressIn    : in  STD_LOGIC_VECTOR(31 downto 0):=x"00000004";
	    AddressOut   : out STD_LOGIC_VECTOR(31 downto 0):=x"00000004"
	);
	end component;

    component ShiftLeft_A is
    port(
         x : in  STD_LOGIC_VECTOR(31 downto 0);
         y : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component ShiftLeft_B is
    port(
         x : in  STD_LOGIC_VECTOR(31 downto 0);
         y : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    component SignExtend is
    port(
         x : in  STD_LOGIC_VECTOR(15 downto 0);
         y : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    signal PCaddrout,MUX32Aout,MUX32Bout,MUX32Cout,MUX32Dout,
	instruction,AddAout,SLAout,SLBout,AddBout,ALUresult,
	Readdata1,Readdata2,Signextendout,DMEM_RD:std_logic_vector(31 downto 0);
    signal AddAin4:std_logic_vector(31 downto 0):=X"00000004";
    signal MUX5out:std_logic_vector(4 downto 0);
    signal CtrlRegDst, CtrlBranch, CtrlMemRead, CtrlMemtoReg, CtrlMemWrite, CtrlALUSrc, CtrlRegWrite, CtrlJump,ADD2out : STD_LOGIC:='0';
    signal Regwrite: std_logic;
    signal CtrlALUOp :STD_LOGIC_VECTOR(1 downto 0);
    signal ALUCTRLout:std_logic_vector(3 downto 0);
    signal ALUoverflow: std_logic:='0';
    signal ALUzero: std_logic;
    --signal rst:std_logic:='0';
    signal writeenable:std_logic:='1';

signal tmpReg , savedReg, memContents : STD_LOGIC_VECTOR(32*4-1 downto 0);

begin
    U0: ADD_A port map(PCaddrout,AddAin4,AddAout);--
    U1: ADD_B port map(AddAout, SLBout, AddBout);--
    U2: ALU port map (Readdata1, MUX32Aout, ALUCTRLout, ALUresult, ALUzero,ALUoverflow);--
    U3: ALUControl port map(CtrlALUOp,instruction(5 downto 0), ALUCTRLout);--
    U4: CPUControl port map(instruction(31 downto 26),CtrlRegDst, CtrlBranch, CtrlMemRead, CtrlMemtoReg, CtrlMemWrite, CtrlALUSrc, CtrlRegWrite, CtrlJump, CtrlALUOp);--
    U5: DMEM port map(Readdata2, ALUresult,CtrlMemRead, CtrlMemWrite,clk,DMEM_RD, memContents);--
    U6: IMEM port map(PCaddrout,instruction);--
    U7: registers port map(instruction(25 downto 21), instruction(20 downto 16), MUX5out, MUX32Dout, CtrlRegWrite,clk, Readdata1,Readdata2, tmpReg,savedReg);--
    U8: AND2 port map(CtrlBranch, ALUzero, ADD2out);--
    U9: MUX5 port map(instruction(20 downto 16),instruction(15 downto 11),CtrlRegDst,MUX5out);--
    U10: MUX32_A port map(Readdata2, Signextendout, CtrlALUSrc, MUX32Aout);--
    U11: MUX32_B port map(AddAout, AddBout, ADD2out,MUX32Bout);--
    U12: MUX32_C port map(MUX32Bout, SLAout, CtrlJump, MUX32Cout);--
    U13: MUX32_D port map(ALUresult,DMEM_RD,CtrlMemtoReg,MUX32Dout);
    U14: PC port map(clk,writeenable,rst,MUX32Cout,PCaddrout);--
    U15: ShiftLeft_A port map("000000"&instruction(25 downto 0), SLAout);--
    U16: ShiftLeft_B port map(Signextendout, SLBout);
    U17: signextend port map(instruction(15 downto 0), Signextendout);

	DEBUG_PC <= PCaddrout;
	DEBUG_INSTRUCTION <= instruction;
	DEBUG_TMP_REGS <= tmpReg;
	DEBUG_SAVED_REGS <= savedReg;
	DEBUG_MEM_CONTENTS <= memContents;


end struct;		
