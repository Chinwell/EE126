library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;


entity PipelinedCPU2 is
port(
    clk :in std_logic;
    rst :in std_logic;
    --Probe ports used for testing or for the tracker.
    DEBUG_IF_SQUASH : out std_logic;
    DEBUG_REG_EQUAL : out std_logic;
    -- Forwarding control signals
    DEBUG_FORWARDA : out std_logic_vector(1 downto 0);
    DEBUG_FORWARDB : out std_logic_vector(1 downto 0);

    --The current address (in various pipe stages)
    DEBUG_PC, DEBUG_PCPlus4_ID, DEBUG_PCPlus4_EX, DEBUG_PCPlus4_MEM,
               DEBUG_PCPlus4_WB: out STD_LOGIC_VECTOR(31 downto 0);
    -- instruction is a store.
    DEBUG_MemWrite, DEBUG_MemWrite_EX, DEBUG_MemWrite_MEM: out STD_LOGIC;
    -- instruction writes the regfile.
    DEBUG_RegWrite, DEBUG_RegWrite_EX, DEBUG_RegWrite_MEM, DEBUG_RegWrite_WB: out std_logic;
    -- instruction is a branch or a jump.
    DEBUG_Branch, DEBUG_Jump: out std_logic;

    DEBUG_PC_WRITE_ENABLE : out STD_LOGIC;
    --The current instruction (Instruction output of IMEM)
    DEBUG_INSTRUCTION : out std_logic_vector(31 downto 0);
    --DEBUG ports from other components
    DEBUG_TMP_REGS : out std_logic_vector(32*4 - 1 downto 0);
    DEBUG_SAVED_REGS : out std_logic_vector(32*4 - 1 downto 0);
    DEBUG_MEM_CONTENTS : out std_logic_vector(32*4 - 1 downto 0)
);
end PipelinedCPU2;


architecture PipelinedCPU_arch of PipelinedCPU2 is

component MUX32_A is
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

component ADD_A is
port(
    in0    : in  STD_LOGIC_VECTOR(31 downto 0);
    in1    : in  STD_LOGIC_VECTOR(31 downto 0);
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component IMEM is
generic(NUM_BYTES : integer := 128);
port(
    Address  : in  STD_LOGIC_VECTOR(31 downto 0);
    ReadData : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component IFID is 
port(
    clk    : in   STD_LOGIC; 
    rst    : in   STD_LOGIC;
    w_enable   : in   STD_LOGIC;
    IF0    : in   STD_LOGIC_VECTOR(31 downto 0); 
    IF1    : in   STD_LOGIC_VECTOR(31 downto 0);
    IF3  : in   STD_LOGIC;
    ID0    : out  STD_LOGIC_VECTOR(31 downto 0); 
    ID1    : out  STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component harzard is 
port(
    IFIDrs  : in STD_LOGIC_VECTOR(4 downto 0);
    IFIDrt  : in STD_LOGIC_VECTOR(4 downto 0);    
    IDEXMEMr    : in std_logic;
    IDEXrt  : in STD_LOGIC_VECTOR(4 downto 0);
    PCw     : out std_logic;
    IFIDw   : out std_logic;
    MuxControl  : out std_logic
);
end component;

component CPUControl is
port(Opcode   : in  STD_LOGIC_VECTOR(5 downto 0);
    RegDst   : out STD_LOGIC;
    Branch   : out STD_LOGIC;
    MemRead  : out STD_LOGIC;
    MemtoReg : out STD_LOGIC;
    MemWrite : out STD_LOGIC;
    ALUSrc   : out STD_LOGIC;
    RegWrite : out STD_LOGIC;
    Jump     : out STD_LOGIC;
    ALUOp    : out STD_LOGIC_VECTOR(1 downto 0)
);
end component;

component ShiftLeft_A is
port(
    x : in  STD_LOGIC_VECTOR(31 downto 0);
    y : out STD_LOGIC_VECTOR(31 downto 0) 
);
end component;

component ADD_B is
port(
    in0    : in  STD_LOGIC_VECTOR(31 downto 0);
    in1    : in  STD_LOGIC_VECTOR(31 downto 0);
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component mux is 
port(
    RegDst_in   : in STD_LOGIC;
    Branch_in   : in STD_LOGIC;
    MemRead_in  : in STD_LOGIC;
    MemtoReg_in : in STD_LOGIC;
    MemWrite_in : in STD_LOGIC;
    ALUSrc_in   : in STD_LOGIC;
    RegWrite_in : in STD_LOGIC;
    Jump_in     : in STD_LOGIC;
    ALUOp_in    : in STD_LOGIC_VECTOR(1 downto 0);
    sel         : in std_logic;

    RegDst_out  : out STD_LOGIC;
    Branch_out  : out STD_LOGIC;
    MemRead_out : out STD_LOGIC;
    MemtoReg_out    : out STD_LOGIC;
    MemWrite_out    : out STD_LOGIC;
    ALUSrc_out  : out STD_LOGIC;
    RegWrite_out    : out STD_LOGIC;
    Jump_out    : out STD_LOGIC;
    ALUOp_out   : out STD_LOGIC_VECTOR(1 downto 0)
);
end component;

component registers is
port(
    RR1 : in  STD_LOGIC_VECTOR (4 downto 0); 
    RR2 : in  STD_LOGIC_VECTOR (4 downto 0); 
    WR  : in  STD_LOGIC_VECTOR (4 downto 0); 
    WD  : in  STD_LOGIC_VECTOR (31 downto 0);
    RegWrite : in  STD_LOGIC;
    Clock   : in  STD_LOGIC;
    RD1 : out STD_LOGIC_VECTOR (31 downto 0);
    RD2 : out STD_LOGIC_VECTOR (31 downto 0);
    DEBUG_TMP_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0);
    DEBUG_SAVED_REGS : out STD_LOGIC_VECTOR(32*4 - 1 downto 0)
);
end component;

component compare is
port(
    input1 : in std_logic_vector(31 downto 0);
    input2 : in std_logic_vector(31 downto 0);
    res : out std_logic
);
end component;

component SignExtend is
port(
    x : in  STD_LOGIC_VECTOR(15 downto 0);
    y : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component ShiftLeft_B is
port(
    x : in  STD_LOGIC_VECTOR(31 downto 0);
    y : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component AND2 is
port (
    in0    : in  STD_LOGIC;
    in1    : in  STD_LOGIC;
    output : out STD_LOGIC
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

component IDEX is 
port(
    clk    : in STD_LOGIC;
    rst    : in STD_LOGIC;
    ID1    : in STD_LOGIC;
    ID2    : in STD_LOGIC;
    ID3    : in STD_LOGIC;
    ID4    : in STD_LOGIC;
    ID5    : in STD_LOGIC;
    ID6    : in STD_LOGIC;
    ID7    : in STD_LOGIC;
    ID8    : in STD_LOGIC_VECTOR(1 downto 0);
    ID9    : in  STD_LOGIC_VECTOR(31 downto 0);  
    ID10   : in  STD_LOGIC_VECTOR(31 downto 0);
    ID11   : in  STD_LOGIC_VECTOR(31 downto 0); 
    ID12   : in  STD_LOGIC_VECTOR(31 downto 0);
    ID13   : in STD_LOGIC_VECTOR(4 downto 0);
    ID14   : in STD_LOGIC_VECTOR(4 downto 0);
    ID15   : in STD_LOGIC_VECTOR(4 downto 0);
    EX1    : out STD_LOGIC_VECTOR(1 downto 0);
    EX2    : out STD_LOGIC_VECTOR(2 downto 0);
    EX3    : out STD_LOGIC;
    EX4    : out STD_LOGIC;
    EX5    : out STD_LOGIC_VECTOR(1 downto 0);
    EX6    : out STD_LOGIC_VECTOR(31 downto 0);
    EX7    : out STD_LOGIC_VECTOR(31 downto 0);
    EX8    : out STD_LOGIC_VECTOR(31 downto 0); 
    EX9    : out STD_LOGIC_VECTOR(31 downto 0);
    EX10   : out STD_LOGIC_VECTOR(4 downto 0);
    EX11   : out STD_LOGIC_VECTOR(4 downto 0);
    EX12   : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component MUX32_3A is
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0);
    in1    : in STD_LOGIC_VECTOR(31 downto 0);
    in2    : in STD_LOGIC_VECTOR(31 downto 0);
    sel    : in STD_LOGIC_VECTOR(1 downto 0);
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;

component MUX32_3B is
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0);
    in1    : in STD_LOGIC_VECTOR(31 downto 0);
    in2    : in STD_LOGIC_VECTOR(31 downto 0);
    sel    : in STD_LOGIC_VECTOR(1 downto 0);
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


component MUX5 is
port(
    in0    : in STD_LOGIC_VECTOR(4 downto 0);
    in1    : in STD_LOGIC_VECTOR(4 downto 0);
    sel    : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component forward is 
port(
    IDEXrs : in STD_LOGIC_VECTOR(4 downto 0);
    IDEXrt : in STD_LOGIC_VECTOR(4 downto 0);
    EXMEMrd    : in STD_LOGIC_VECTOR(4 downto 0);
    MEMWBrd    : in STD_LOGIC_VECTOR(4 downto 0);
    EXMEMw : in STD_LOGIC;
    MEMWBw : in STD_LOGIC; 
    ForwardA   : out STD_LOGIC_VECTOR(1 downto 0);
    ForwardB   : out STD_LOGIC_VECTOR(1 downto 0)
);
end  component;

component MUX32_C is
port(
    in0    : in STD_LOGIC_VECTOR(31 downto 0);
    in1    : in STD_LOGIC_VECTOR(31 downto 0);
    sel    : in STD_LOGIC;
    output : out STD_LOGIC_VECTOR(31 downto 0)
);
end component;


component ALUControl is
port(
    ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);
    Funct     : in  STD_LOGIC_VECTOR(5 downto 0);
    Operation : out STD_LOGIC_VECTOR(3 downto 0)
);
end component;

component EXMEM is
port(
    clk    : in STD_LOGIC;
    rst    : in STD_LOGIC;
    EX0    : in STD_LOGIC_VECTOR(31 downto 0);
    EX1    : in STD_LOGIC_VECTOR(1 downto 0);
    EX2    : in STD_LOGIC_VECTOR(2 downto 0);
    EX3    : in STD_LOGIC;
    EX4    : in  STD_LOGIC_VECTOR(31 downto 0);
    EX5    : in  STD_LOGIC_VECTOR(31 downto 0);
    EX6    : in  STD_LOGIC_VECTOR(4 downto 0);
    MEM0   : out STD_LOGIC_VECTOR(31 downto 0);
    MEM1   : out STD_LOGIC_VECTOR(1 downto 0);
    MEM2   : out STD_LOGIC;
    MEM3   : out STD_LOGIC;
    MEM4   : out STD_LOGIC;
    MEM5   : out STD_LOGIC;
    MEM6   : out STD_LOGIC_VECTOR(31 downto 0);
    MEM7   : out STD_LOGIC_VECTOR(31 downto 0);
    MEM8   : out STD_LOGIC_VECTOR(4 downto 0)
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

component MEMWB is
port(
    clk    : in  STD_LOGIC;
    rst    : in  STD_LOGIC;
    MEM0   : in  STD_LOGIC_VECTOR(31 downto 0);
    MEM1   : in  STD_LOGIC_VECTOR(1 downto 0);
    MEM2   : in  STD_LOGIC_VECTOR(31 downto 0);  
    MEM3   : in  STD_LOGIC_VECTOR(31 downto 0);
    MEM4   : in  STD_LOGIC_VECTOR(4 downto 0);
    WB0    : out STD_LOGIC_VECTOR(31 downto 0);
    WB1    : out STD_LOGIC;
    WB2    : out STD_LOGIC;
    WB3    : out STD_LOGIC_VECTOR(31 downto 0);  
    WB4    : out STD_LOGIC_VECTOR(31 downto 0);
    WB5    : out STD_LOGIC_VECTOR(4 downto 0)
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

signal ALUzero, ALUoverflow, AND2out, equal, PCen, IFIDen, RegDstCtrl , BranchCtrl , MemReadCtrl , MemtoRegCtrl , MemWriteCtrl , ALUSrcCtrl , RegWriteCtrl , JumpCtrl, SelMux, RegDstMux , BranchMux, MemReadMux, MemtoRegMux, MemWriteMux, ALUSrcMux, RegWriteMux, JumpMux, IDEX3, IDEX4, EXMEM3, EXMEM4, EXMEM5, EXMEM6, MEMWB2, MEMWB3 : STD_LOGIC;
signal ALUOpMux, ALUOpCtrl , IDEX1, IDEX5, EXMEM2, forwardA , forwardB : STD_LOGIC_VECTOR(1 downto 0);
signal IDEX2 : STD_LOGIC_VECTOR(2 downto 0);
signal ALUop : STD_LOGIC_VECTOR(3 downto 0);
signal MEMWB6 , MUX5out, EXMEM9, IDEX10, IDEX11 , IDEX12 : STD_LOGIC_VECTOR(4 downto 0);
signal SLAout, SLBout, SEout, ADDAout, ADDBout, ReadData1, ReadData2, ALURes, MemData, MUX323Aout, MUX323Bout, Mux32_Aout, Mux32_Bout, MUX32Cout, MUX32Dout, PCout, inst, IFID1 ,IFID2, IDEX6, IDEX7, IDEX8, IDEX9, EXMEM1, MEMWB1, MEMWB4, MEMWB5, EXMEM7, EXMEM8 : STD_LOGIC_VECTOR(31 downto 0);
signal tmpReg , savedReg, MemContents : STD_LOGIC_VECTOR(32*4-1 downto 0);

begin

U1: MUX32_A port map (Mux32_Bout,SLBout,JumpMux,Mux32_Aout);
U2: PC port map(clk,PCen,rst,Mux32_Aout,PCout);
U3: IMEM port map(PCout,inst);
U4: ADD_A port map(PCout,X"00000004",ADDAout);
----------------------------------------------------
U5: IFID port map(clk,rst,IFIDen,ADDAout,inst,AND2out or JumpMux,IFID1,IFID2);
----------------------------------------------------
U6: harzard port map(IFID2(20 downto 16),IFID2(15 downto 11),IDEX2(1),IDEX10,PCen,IFIDen,SelMux);
U7: CPUControl port map(IFID2(31 downto 26),RegDstCtrl,BranchCtrl,MemReadCtrl,MemtoRegCtrl,MemWriteCtrl,ALUSrcCtrl,RegWriteCtrl,JumpCtrl,ALUOpCtrl);
U8: ShiftLeft_A port map(SEout,SLAout);
U0: ADD_B port map(IFID1,SLAout,ADDBout);
U10: mux port map(RegDstCtrl,BranchCtrl,MemReadCtrl,MemtoRegCtrl,MemWriteCtrl,ALUSrcCtrl,RegWriteCtrl,JumpCtrl,ALUOpCtrl,SelMux,RegDstMux,BranchMux,MemReadMux,MemtoRegMux,MemWriteMux,ALUSrcMux,RegWriteMux,JumpMux,ALUOpMux);
U11: registers port map(IFID2(25 downto 21),IFID2(20 downto 16),MEMWB6,MUX32Dout,MEMWB2,clk,ReadData1,ReadData2,tmpReg,savedReg);
U12: compare port map(ReadData1,ReadData2,equal);
U13: SignExtend port map(IFID2(15 downto 0),SEout);

U14: AND2 port map(BranchMux,equal,AND2out);
U15: ShiftLeft_B port map("000000"&IFID2(25 downto 0),SLBout);
U16: MUX32_B port map(ADDAout,ADDBout,AND2out,Mux32_Bout);
----------------------------------------------------
U17: IDEX port map(clk,rst,RegDstMux,BranchMux,MemReadMux,MemtoRegMux,MemWriteMux,ALUSrcMux,RegWriteMux,ALUOpMux,IFID1,ReadData1,ReadData2,SEout,IFID2(20 downto 16),IFID2(15 downto 11),IFID2(25 downto 21),IDEX1,IDEX2,IDEX3,IDEX4,IDEX5,IDEX6,IDEX7,IDEX8,IDEX9,IDEX10,IDEX11,IDEX12);
----------------------------------------------------
U18: MUX32_3A port map(IDEX7,MUX32Dout,EXMEM7,forwardA,MUX323Aout);
U19: MUX32_3B port map(IDEX8,MUX32Dout,EXMEM7,forwardB,MUX323Bout);
U20: ALU port map(MUX323Aout,MUX32Cout,ALUop,ALURes,ALUzero,ALUoverflow);
U21: MUX5 port map(IDEX10,IDEX11,IDEX3,MUX5out);
U22: forward port map(IDEX12,IDEX10,EXMEM9,MEMWB6,EXMEM2(1),MEMWB2,forwardA,forwardB);

U23: MUX32_C port map(MUX323Bout,IDEX9,IDEX4,MUX32Cout);
U24: ALUControl port map(IDEX5,IDEX9(5 downto 0),ALUop);
----------------------------------------------------
U25: EXMEM port map(clk,rst,IDEX6,IDEX1,IDEX2,ALUzero,ALURes,MUX323Bout,MUX5out,EXMEM1,EXMEM2,EXMEM3,EXMEM4,EXMEM5,EXMEM6,EXMEM7,EXMEM8,EXMEM9);
----------------------------------------------------
U26: DMEM port map(EXMEM8,EXMEM7,EXMEM4,EXMEM5,clk,MemData,MemContents);
----------------------------------------------------
U27: MEMWB port map(clk,rst,EXMEM1,EXMEM2,MemData,EXMEM7,EXMEM9,MEMWB1,MEMWB2,MEMWB3,MEMWB4,MEMWB5,MEMWB6);
----------------------------------------------------
U28: MUX32_D port map(MEMWB5,MEMWB4,MEMWB3,MUX32Dout);

DEBUG_IF_SQUASH <= AND2out or JumpMux;
DEBUG_REG_EQUAL <= equal;
DEBUG_FORWARDA <= forwardA;
DEBUG_FORWARDB <= forwardB;
DEBUG_PC <= PCout;
DEBUG_PCPlus4_ID <= IFID1;
DEBUG_PCPlus4_EX <= IDEX6;
DEBUG_PCPlus4_MEM <= EXMEM1;
DEBUG_PCPlus4_WB <= MEMWB1;
DEBUG_MemWrite <= MemWriteMux;
DEBUG_MemWrite_EX <= IDEX2(0);
DEBUG_MemWrite_MEM <= EXMEM5;
DEBUG_RegWrite <= RegWriteMux;
DEBUG_RegWrite_EX <= IDEX1(1);
DEBUG_RegWrite_MEM <= EXMEM2(1);
DEBUG_RegWrite_WB <= MEMWB2;
DEBUG_Branch <= AND2out;
DEBUG_Jump <= JumpMux;
DEBUG_PC_WRITE_ENABLE <= PCen;
DEBUG_INSTRUCTION <= inst;
DEBUG_TMP_REGS <= tmpReg;
DEBUG_SAVED_REGS <= savedReg;
DEBUG_MEM_CONTENTS <= MemContents;

end architecture PipelinedCPU_arch;
--worked with Ruoxi
