library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;


entity PipelinedCPU0 is
port(
     clk : in STD_LOGIC;
     rst : in STD_LOGIC;
     --Probe ports used for testing or for the tracker.
     --The current address (in various pipe stages)
     DEBUG_PC, DEBUG_PCPlus4_ID, DEBUG_PCPlus4_EX, DEBUG_PCPlus4_MEM,
               DEBUG_PCPlus4_WB: out STD_LOGIC_VECTOR(31 downto 0);
     -- instruction is a store.
     DEBUG_MemWrite, DEBUG_MemWrite_EX, DEBUG_MemWrite_MEM: out STD_LOGIC;
     -- instruction writes the regfile.
     DEBUG_RegWrite, DEBUG_RegWrite_EX, DEBUG_RegWrite_MEM, DEBUG_RegWrite_WB: out std_logic;
     -- instruction is a branch or a jump.
     DEBUG_Branch, DEBUG_Jump: out std_logic;

     --The current instruction (Instruction output of IMEM)
     DEBUG_INSTRUCTION : out STD_LOGIC_VECTOR(31 downto 0);
     --DEBUG ports from other components
     DEBUG_TMP_REGS     : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
     DEBUG_SAVED_REGS   : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
     DEBUG_MEM_CONTENTS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end PipelinedCPU0;

architecture struct of PipelinedCPU0 is

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

	component PC is
	port(
        clk          : in  STD_LOGIC;
        write_enable : in  STD_LOGIC:='1';
	    rst          : in  STD_LOGIC;
	    AddressIn    : in  STD_LOGIC_VECTOR(31 downto 0);
	    AddressOut   : out STD_LOGIC_VECTOR(31 downto 0)
	);
	end component;

    component ShiftLeft is
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

component IFID is 
port(
     clk	: in   STD_LOGIC; 
     rst	: in   STD_LOGIC;
     IF1	: in   STD_LOGIC_VECTOR(31 downto 0); 
     IF2	: in   STD_LOGIC_VECTOR(31 downto 0); 
     ID1	: out  STD_LOGIC_VECTOR(31 downto 0); 
     ID2	: out  STD_LOGIC_VECTOR(31 downto 0)
);
end component;


component IDEX is 
port(
     clk	: in STD_LOGIC;
     rst	: in STD_LOGIC;
     ID1	: in STD_LOGIC;
     ID2	: in STD_LOGIC;
     ID3	: in STD_LOGIC;
     ID4	: in STD_LOGIC;
     ID5	: in STD_LOGIC;
     ID6	: in STD_LOGIC;
     ID7	: in STD_LOGIC;
     ID8	: in STD_LOGIC_VECTOR(1 downto 0);
     ID9	: in  STD_LOGIC_VECTOR(31 downto 0);  
     ID10	: in  STD_LOGIC_VECTOR(31 downto 0);
     ID11	: in  STD_LOGIC_VECTOR(31 downto 0); 
     ID12	: in  STD_LOGIC_VECTOR(31 downto 0);
     ID13	: in STD_LOGIC_VECTOR(4 downto 0);
     ID14	: in STD_LOGIC_VECTOR(4 downto 0);
     EX1	: out STD_LOGIC_VECTOR(1 downto 0);
     EX2	: out STD_LOGIC_VECTOR(2 downto 0);
     EX3	: out STD_LOGIC;
     EX4	: out STD_LOGIC_VECTOR(1 downto 0);
     EX5	: out STD_LOGIC; 
     EX6	: out STD_LOGIC_VECTOR(31 downto 0);  
     EX7	: out STD_LOGIC_VECTOR(31 downto 0);
     EX8	: out STD_LOGIC_VECTOR(31 downto 0); 
     EX9	: out STD_LOGIC_VECTOR(31 downto 0);
     EX10	: out STD_LOGIC_VECTOR(4 downto 0);
     EX11	: out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component EXMEM is
port(
     clk    : in STD_LOGIC;
     rst    : in STD_LOGIC;
     EX0    : in STD_LOGIC_VECTOR(31 downto 0);
     EX1    : in STD_LOGIC_VECTOR(1 downto 0);
     EX2    : in STD_LOGIC_VECTOR(2 downto 0);
     EX3    : in STD_LOGIC_VECTOR(31 downto 0);  
     EX4    : in STD_LOGIC;
     EX5    : in  STD_LOGIC_VECTOR(31 downto 0);
     EX6    : in  STD_LOGIC_VECTOR(31 downto 0);
     EX7    : in  STD_LOGIC_VECTOR(4 downto 0);
     MEM0   : out STD_LOGIC_VECTOR(31 downto 0);
     MEM1   : out STD_LOGIC_VECTOR(1 downto 0);
     MEM2   : out STD_LOGIC;
     MEM3   : out STD_LOGIC;
     MEM4   : out STD_LOGIC;
     MEM5   : out STD_LOGIC_VECTOR(31 downto 0);  
     MEM6   : out STD_LOGIC;
     MEM7   : out STD_LOGIC_VECTOR(31 downto 0);
     MEM8   : out STD_LOGIC_VECTOR(31 downto 0);   
     MEM9  : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component MEMWB is
port(
     clk        : in  STD_LOGIC;
     rst        : in  STD_LOGIC;
     MEM0       : in  STD_LOGIC_VECTOR(31 downto 0);
     MEM1       : in  STD_LOGIC_VECTOR(1 downto 0);
     MEM2       : in  STD_LOGIC_VECTOR(31 downto 0);  
     MEM3       : in  STD_LOGIC_VECTOR(31 downto 0);
     MEM4       : in  STD_LOGIC_VECTOR(4 downto 0);
     WB0        : out STD_LOGIC_VECTOR(31 downto 0);
     WB1        : out STD_LOGIC;
     WB2        : out STD_LOGIC;
     WB3        : out STD_LOGIC_VECTOR(31 downto 0);  
     WB4        : out STD_LOGIC_VECTOR(31 downto 0);
     WB5        : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;


    signal PCwrite, RegDst, IDEX3, Branch, EXMEM2, MemRead, MemtoReg, EXMEM3, MEMWB2, MemWrite, EXMEM4, ALUSrc, IDEX5, RegWrite, MEMWB1, Jump, PCSrc, ALUzero, EXMEM6, ALUoverflow : STD_LOGIC;
    signal IDEX1, EXMEM1, ALUOp, IDEX4 : STD_LOGIC_VECTOR(1 downto 0);
    signal IDEX2 : STD_LOGIC_VECTOR(2 downto 0);
    signal ALUCTRLout : STD_LOGIC_VECTOR(3 downto 0);
    signal IDEX10, IDEX11, MEMWB5, MUX5out, EXMEM9 : STD_LOGIC_VECTOR(4 downto 0);
    signal PCin, PCout, AddAout, IFID1, IDEX6, PC4MEM, PC4WB, MUX32_Cout, ReadData1, IDEX7, ReadData2, IDEX8, EXMEM8, ALUResult, EXMEM7, MEMWB4, MUX32_Bout, ReadData, MEMWB3, ADD_Bout, EXMEM5, SIGNEXTENDout, IDEX9, SHIFTLEFTout, INST, IFID2 : STD_LOGIC_VECTOR(31 downto 0);
    signal four:std_logic_vector(31 downto 0):=X"00000004";
    signal TMP_REGS, SAVED_REGS, MEMContents: STD_LOGIC_VECTOR(32*4-1 downto 0);

begin
    U1: PC port map(clk,PCwrite,rst,PCin,PCout);--
    U2: MUX32_A port map(AddAout,EXMEM5,PCSrc,PCin);--
    U3: ADD_A port map(PCout,four,AddAout);--
    U4: IMEM port map(PCout,INST);--
    U5: IFID port map(clk,rst,AddAout,INST,IFID1,IFID2);--
    U6: CPUControl port map(IFID2(31 downto 26),RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,Jump,ALUOp);--
    U7: registers port map(IFID2(25 downto 21),IFID2(20 downto 16),MEMWB5,MUX32_Cout,MEMWB1,clk,ReadData1,ReadData2,TMP_REGS,SAVED_REGS);--
    U8: SignExtend port map(IFID2(15 downto 0),SIGNEXTENDout);--
    U9: IDEX port map(clk,rst,RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,ALUOp,IFID1,ReadData1,ReadData2,SIGNEXTENDout,IFID2(20 downto 16),IFID2(15 downto 11),IDEX1,IDEX2,IDEX3,IDEX4,IDEX5,IDEX6,IDEX7,IDEX8,IDEX9,IDEX10,IDEX11);--
    U10: ADD_B port map(IDEX6,SHIFTLEFTout,ADD_Bout);--
    U11: ShiftLeft port map(IDEX9,SHIFTLEFTout);--
    U12: ALU port map(IDEX7,MUX32_Bout,ALUCTRLout,ALUResult,ALUzero,ALUoverflow);--
    U13: MUX32_B port map(IDEX8,IDEX9,IDEX5,MUX32_Bout);--
    U14: ALUControl port map(IDEX4,IDEX9(5 downto 0),ALUCTRLout);--
    U15: MUX5 port map(IDEX10,IDEX11,IDEX3,MUX5out);--
    U16: EXMEM port map(clk,rst,IDEX6,IDEX1,IDEX2,ADD_Bout,ALUzero,ALUResult,IDEX8,MUX5out,PC4MEM,EXMEM1,EXMEM2,EXMEM3,EXMEM4,EXMEM5,EXMEM6,EXMEM7,EXMEM8,EXMEM9);
    U17: AND2 port map(EXMEM2,EXMEM6,PCSrc);--
    U18: DMEM port map(EXMEM8,EXMEM7,EXMEM3,EXMEM4,clk,ReadData,MEMContents);--
    U19: MEMWB port map(clk,rst,PC4MEM,EXMEM1,ReadData,EXMEM7,EXMEM9,PC4WB,MEMWB1,MEMWB2,MEMWB3,MEMWB4,MEMWB5);
    U20: MUX32_C port map(MEMWB4,MEMWB3,MEMWB2,MUX32_Cout);--

    PCwrite <='1';
    --DEBUG_INSTRUCTION <= IFID2;
    DEBUG_INSTRUCTION <= INST;
    DEBUG_TMP_REGS <= TMP_REGS;
    DEBUG_SAVED_REGS <= SAVED_REGS;
    DEBUG_MEM_CONTENTS <= MEMContents;
    DEBUG_PC <= PCout;
    DEBUG_PCPlus4_ID <= IFID1;
    DEBUG_PCPlus4_EX <= IDEX6;
    DEBUG_PCPlus4_MEM <= PC4MEM;
    DEBUG_PCPlus4_WB <= PC4WB;
    DEBUG_MemWrite <= MemWrite;
    DEBUG_MemWrite_EX <= IDEX2(0);
    DEBUG_MemWrite_MEM <= EXMEM4;
    DEBUG_RegWrite <= RegWrite;
    DEBUG_RegWrite_EX <= IDEX1(1);
    DEBUG_RegWrite_MEM <= EXMEM1(1);
    DEBUG_RegWrite_WB <= RegWrite;
    DEBUG_Branch <= Branch;
    DEBUG_Jump <= Jump;

end struct;	
