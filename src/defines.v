// I type inst
`define ysyx_22050698_INST_TYPE_I 7'b0010011
`define ysyx_22050698_INST_ADDI   3'b000
`define ysyx_22050698_INST_SLTI   3'b010
`define ysyx_22050698_INST_SLTIU  3'b011
`define ysyx_22050698_INST_XORI   3'b100
`define ysyx_22050698_INST_ORI    3'b110
`define ysyx_22050698_INST_ANDI   3'b111
`define ysyx_22050698_INST_SLLI   3'b001
`define ysyx_22050698_INST_SRI    3'b101
    
// L type inst
`define ysyx_22050698_INST_TYPE_L 7'b0000011
`define ysyx_22050698_INST_LB     3'b000
`define ysyx_22050698_INST_LH     3'b001
`define ysyx_22050698_INST_LW     3'b010
`define ysyx_22050698_INST_LD     3'b011
`define ysyx_22050698_INST_LBU    3'b100
`define ysyx_22050698_INST_LHU    3'b101
`define ysyx_22050698_INST_LWU    3'b110

// S type inst
`define ysyx_22050698_INST_TYPE_S 7'b0100011
`define ysyx_22050698_INST_SB     3'b000
`define ysyx_22050698_INST_SH     3'b001
`define ysyx_22050698_INST_SW     3'b010
`define ysyx_22050698_INST_SD     3'b011

// R and M type inst
`define ysyx_22050698_INST_TYPE_R_M 7'b0110011
// R type inst
`define ysyx_22050698_INST_ADD_SUB 3'b000
`define ysyx_22050698_INST_SLL     3'b001
`define ysyx_22050698_INST_SLT     3'b010
`define ysyx_22050698_INST_SLTU    3'b011
`define ysyx_22050698_INST_XOR     3'b100
`define ysyx_22050698_INST_SR      3'b101
`define ysyx_22050698_INST_OR      3'b110
`define ysyx_22050698_INST_AND     3'b111
// M type inst
`define ysyx_22050698_INST_MUL    3'b000
`define ysyx_22050698_INST_MULH   3'b001
`define ysyx_22050698_INST_MULHSU 3'b010
`define ysyx_22050698_INST_MULHU  3'b011
`define ysyx_22050698_INST_DIV    3'b100
`define ysyx_22050698_INST_DIVU   3'b101
`define ysyx_22050698_INST_REM    3'b110
`define ysyx_22050698_INST_REMU   3'b111

//64位仅有的指令
`define ysyx_22050698_INST_TYPE_64IW    7'b0011011  

`define ysyx_22050698_INST_ADDIW        3'b000
`define ysyx_22050698_INST_SLLIW        3'b001
`define ysyx_22050698_INST_SRIW         3'b101

`define ysyx_22050698_INST_TYPE_R_M_64W 7'b0111011

`define ysyx_22050698_INST_ADD_SUB_MULW 3'b000
`define ysyx_22050698_INST_SLLW         3'b001
`define ysyx_22050698_INST_SRW_DIVUW    3'b101
`define ysyx_22050698_INST_DIVW         3'b100
`define ysyx_22050698_INST_DIVUW        3'b101
`define ysyx_22050698_INST_REMW         3'b110
`define ysyx_22050698_INST_REMUW        3'b111
//64位仅有的指令

// J type inst
`define ysyx_22050698_INST_JAL    7'b1101111
`define ysyx_22050698_INST_JALR   7'b1100111

`define ysyx_22050698_INST_LUI    7'b0110111
`define ysyx_22050698_INST_AUIPC  7'b0010111
`define ysyx_22050698_INST_NOP    32'h00000013
`define ysyx_22050698_INST_NOP_OP 7'b0000001
`define ysyx_22050698_INST_MRET   32'h30200073
`define ysyx_22050698_INST_RET    32'h00008067

`define ysyx_22050698_INST_FENCE  7'b0001111
`define ysyx_22050698_INST_ECALL  32'h73
`define ysyx_22050698_INST_EBREAK 32'h00100073

// B type inst
`define ysyx_22050698_INST_TYPE_B 7'b1100011
`define ysyx_22050698_INST_BEQ    3'b000
`define ysyx_22050698_INST_BNE    3'b001
`define ysyx_22050698_INST_BLT    3'b100
`define ysyx_22050698_INST_BGE    3'b101
`define ysyx_22050698_INST_BLTU   3'b110
`define ysyx_22050698_INST_BGEU   3'b111

// CSR inst
`define ysyx_22050698_INST_CSR    7'b1110011
`define ysyx_22050698_INST_CSRRW  3'b001
`define ysyx_22050698_INST_CSRRS  3'b010
`define ysyx_22050698_INST_CSRRC  3'b011
`define ysyx_22050698_INST_CSRRWI 3'b101
`define ysyx_22050698_INST_CSRRSI 3'b110
`define ysyx_22050698_INST_CSRRCI 3'b111

// CSR reg addr
`define ysyx_22050698_INST_CSR_CYCLE    12'hc00
`define ysyx_22050698_INST_CSR_CYCLEH   12'hc80
`define ysyx_22050698_INST_CSR_MTVEC    12'h305
`define ysyx_22050698_INST_CSR_MCAUSE   12'h342
`define ysyx_22050698_INST_CSR_MEPC     12'h341
`define ysyx_22050698_INST_CSR_MIE      12'h304
`define ysyx_22050698_INST_CSR_MSTATUS  12'h300
`define ysyx_22050698_INST_CSR_MSCRATCH 12'h340
