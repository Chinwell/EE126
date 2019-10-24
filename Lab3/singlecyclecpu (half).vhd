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

signal writeenable:STD_LOGIC:='1';
signal MUX32Cout , PCaddrout , AddAout: STD_LOGIC_VECTOR(31 downto 0);
signal instruction : STD_LOGIC_VECTOR(31 downto 0);
signal RegDst , Branch , MemRead , MemtoReg , MemWrite , ALUSrc , RegWrite , Jump: STD_LOGIC;
signal MUX5out : STD_LOGIC_VECTOR(4 downto 0);
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
signal ALUCTRLout : STD_LOGIC_VECTOR(3 downto 0);
signal SLAout : STD_LOGIC_VECTOR(31 downto 0);
signal Signextendout , SLBout : STD_LOGIC_VECTOR(31 downto 0);
signal AddBout : STD_LOGIC_VECTOR(31 downto 0);
signal MUX32Dout , Readdata1 , ReadData2 : STD_LOGIC_VECTOR(31 downto 0);
signal ALURes , ALUb: STD_LOGIC_VECTOR(31 downto 0);
signal ALUzero , ALUoverflow : STD_LOGIC;
signal MEMRData : STD_LOGIC_VECTOR(31 downto 0);
signal IAddr0: STD_LOGIC_VECTOR(31 downto 0);
signal BranchSig : STD_LOGIC;


signal tmpReg , savedReg, memContents : STD_LOGIC_VECTOR(32*4-1 downto 0);

begin
    U1: ADD_A port map(PCaddrout,X"00000004",AddAout);
    U2: ADD_B port map(AddAout,SLBout,AddBout);
    U3: ALU port map(Readdata1,ALUb,ALUCTRLout,ALURes,ALUzero,ALUoverflow);
    U4: ALUControl port map(ALUOp,instruction(5 downto 0),ALUCTRLout);
    U5: CPUControl port map(instruction(31 downto 26),RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,Jump,ALUOp);
    U6: DMEM port map(ReadData2,ALURes,MemRead,MemWrite,clk,MEMRData,memContents);
    U7: IMEM port map(PCaddrout,instruction);
    U8: registers port map(instruction(25 downto 21),instruction(20 downto 16),MUX5out,MUX32Dout,RegWrite,clk,Readdata1,ReadData2,tmpReg,savedReg);
    U9: AND2 port map(Branch,ALUzero,BranchSig);
    U10: MUX5 port map(instruction(20 downto 16),instruction(15 downto 11),RegDst,MUX5out);
    U11: MUX32_A port map(ReadData2,Signextendout,ALUSrc,ALUb);    
    U12: MUX32_C port map(AddAout,AddBout,BranchSig,IAddr0);
    U13: MUX32_D port map (IAddr0,SLAout,Jump,MUX32Cout);
    U14: MUX32_B port map(ALURes,MEMRData,MemtoReg,MUX32Dout);
    U15: PC port map(clk,writeenable,rst,MUX32Cout,PCaddrout);
    U16: ShiftLeft_A port map("000000"&instruction(25 downto 0),SLAout);
    U17: ShiftLeft_B port map(Signextendout,SLBout); 
    U18: SignExtend port map(instruction(15 downto 0),Signextendout);
    

    DEBUG_PC <= PCaddrout;
    DEBUG_INSTRUCTION <= instruction;
    DEBUG_TMP_REGS <= tmpReg;
    DEBUG_SAVED_REGS <= savedReg;
    DEBUG_MEM_CONTENTS <= memContents;

end struct;		
