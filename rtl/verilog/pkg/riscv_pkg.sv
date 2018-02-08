/////////////////////////////////////////////////////////////////
//                                                             //
//    ???????  ???????  ??????                                 //
//    ?????????????????????????                                //
//    ???????????   ???????????                                //
//    ???????????   ???????????                                //
//    ???  ???????????????  ???                                //
//    ???  ??? ??????? ???  ???                                //
//          ???      ???????  ??????? ??? ???????              //
//          ???     ????????????????? ???????????              //
//          ???     ???   ??????  ??????????                   //
//          ???     ???   ??????   ?????????                   //
//          ?????????????????????????????????????              //
//          ???????? ???????  ??????? ??? ???????              //
//                                                             //
//    RISC-V                                                   //
//    Definitions Package                                      //
//                                                             //
/////////////////////////////////////////////////////////////////
//                                                             //
//             Copyright (C) 2014-2017 ROA Logic BV            //
//             www.roalogic.com                                //
//                                                             //
//    Unless specifically agreed in writing, this software is  //
//  licensed under the RoaLogic Non-Commercial License         //
//  version-1.0 (the "License"), a copy of which is included   //
//  with this file or may be found on the RoaLogic website     //
//  http://www.roalogic.com. You may not use the file except   //
//  in compliance with the License.                            //
//                                                             //
//    THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY        //
//  EXPRESS OF IMPLIED WARRANTIES OF ANY KIND.                 //
//  See the License for permissions and limitations under the  //
//  License.                                                   //
//                                                             //
/////////////////////////////////////////////////////////////////

/*
  2017-02-25: Added MRET/HRET/SRET/URET per 1.9 supervisor spec
  2017-03-01: Removed MRTH/MRTS/HRTS per 1.9 supervisor spec
*/


package riscv_pkg;

  /*
   *  Constants
   */
  parameter [31:0] INSTR_NOP  = 'h13;
  parameter [31:0] MTVEC_INIT = 'h100;

  parameter        EXCEPTION_SIZE = 12;

  /*
   * Opcodes
   */
  parameter [ 6:2] OPC_LOAD     = 5'b00_000,
                   OPC_LOAD_FP  = 5'b00_001,
                   OPC_MISC_MEM = 5'b00_011,
                   OPC_OP_IMM   = 5'b00_100, 
                   OPC_AUIPC    = 5'b00_101,
                   OPC_OP_IMM32 = 5'b00_110,
                   OPC_STORE    = 5'b01_000,
                   OPC_STORE_FP = 5'b01_001,
                   OPC_AMO      = 5'b01_011, 
                   OPC_OP       = 5'b01_100,
                   OPC_LUI      = 5'b01_101,
                   OPC_OP32     = 5'b01_110,
                   OPC_MADD     = 5'b10_000,
                   OPC_MSUB     = 5'b10_001,
                   OPC_NMSUB    = 5'b10_010,
                   OPC_NMADD    = 5'b10_011,
                   OPC_OP_FP    = 5'b10_100,
                   OPC_BRANCH   = 5'b11_000,
                   OPC_JALR     = 5'b11_001,
                   OPC_JAL      = 5'b11_011,
                   OPC_SYSTEM   = 5'b11_100;

  /*
   * RV32/RV64 Base instructions
   */
  //                            f7       f3 opcode
  parameter [14:0] LUI    = 15'b??????????01101,
                   AUIPC  = 15'b??????????00101,
                   JAL    = 15'b??????????11011,
                   JALR   = 15'b???????00011001,
                   BEQ    = 15'b???????00011000,
                   BNE    = 15'b???????00111000,
                   BLT    = 15'b???????100_11000,
                   BGE    = 15'b???????10111000,
                   BLTU   = 15'b???????11011000,
                   BGEU   = 15'b???????11111000,
                   LB     = 15'b???????00000000,
                   LH     = 15'b???????00100000,
                   LW     = 15'b???????01000000,
                   LBU    = 15'b???????10000000,
                   LHU    = 15'b???????10100000,
                   LWU    = 15'b???????11000000,
                   LD     = 15'b???????01100000,
                   SB     = 15'b???????00001000,
                   SH     = 15'b???????00101000,
                   SW     = 15'b???????01001000,
                   SD     = 15'b???????01101000,
                   ADDI   = 15'b???????00000100,
                   ADDIW  = 15'b???????00000110,
                   ADD    = 15'b000000000001100,
                   ADDW   = 15'b000000000001110,
                   SUB    = 15'b010000000001100,
                   SUBW   = 15'b010000000001110,
                   XORI   = 15'b???????10000100,
                   XOR    = 15'b000000010001100,
                   ORI    = 15'b???????11000100,
                   OR     = 15'b000000011001100,
                   ANDI   = 15'b???????11100100,
                   AND    = 15'b000000011101100,
                   SLLI   = 15'b000000?00100100,
                   SLLIW  = 15'b000000000100110,
                   SLL    = 15'b000000000101100,
                   SLLW   = 15'b000000000101110,
                   SLTI   = 15'b???????01000100,
                   SLT    = 15'b000000001001100,
                   SLTU   = 15'b000000001101100,
                   SLTIU  = 15'b???????01100100,
                   SRLI   = 15'b000000?10100100,
                   SRLIW  = 15'b000000010100110,
                   SRL    = 15'b000000010101100,
                   SRLW   = 15'b000000010101110,
                   SRAI   = 15'b010000?10100100,
                   SRAIW  = 15'b010000010100110,
                   SRA    = 15'b010000010101100,
                   SRAW   = 15'b010000010101110,

                   //pseudo instructions
                   SYSTEM = 15'b???????00011100, //excludes RDxxx instructions
                   MISCMEM= 15'b??????????00011;


  /*
   * SYSTEM/MISC_MEM opcodes
   */
  parameter [31:0] FENCE      = 32'b0000????????00000000000000001111,
                   SFENCE_VM  = 32'b000100000100?????000000001110011,
                   FENCE_I    = 32'b00000000000000000001000000001111,
                   ECALL      = 32'b00000000000000000000000001110011,
                   EBREAK     = 32'b00000000000100000000000001110011,
                   MRET       = 32'b00110000001000000000000001110011,
                   HRET       = 32'b00100000001000000000000001110011,
                   SRET       = 32'b00010000001000000000000001110011,
                   URET       = 32'b00000000001000000000000001110011,
//                   MRTS       = 32'b001100000101_00000_000_00000_1110011,
//                   MRTH       = 32'b001100000110_00000_000_00000_1110011,
//                   HRTS       = 32'b001000000101_00000_000_00000_1110011,
                   WFI        = 32'b00010000010100000000000001110011;

  //                                f7      f3  opcode
  parameter [14:0] CSRRW      = 15'b???????00111100,
                   CSRRS      = 15'b???????01011100,
                   CSRRC      = 15'b???????01111100,
                   CSRRWI     = 15'b???????10111100,
                   CSRRSI     = 15'b???????11011100,
                   CSRRCI     = 15'b???????11111100;


  /*
   * RV32/RV64 A-Extensions instructions
   */
  //                            f7       f3 opcode
  parameter [14:0] LRW      = 15'b00010??01001011,
                   SCW      = 15'b00011??01001011,
                   AMOSWAPW = 15'b00001??01001011,
                   AMOADDW  = 15'b00000??01001011,
                   AMOXORW  = 15'b00100??01001011,
                   AMOANDW  = 15'b01100??01001011,
                   AMOORW   = 15'b01000??01001011,
                   AMOMINW  = 15'b10000??01001011,
                   AMOMAXW  = 15'b10100??01001011,
                   AMOMINUW = 15'b11000??01001011,
                   AMOMAXUW = 15'b11100??01001011;

  parameter [14:0] LRD      = 15'b00010??01101011,
                   SCD      = 15'b00011??01101011,
                   AMOSWAPD = 15'b00001??01101011,
                   AMOADDD  = 15'b00000??01101011,
                   AMOXORD  = 15'b00100??01101011,
                   AMOANDD  = 15'b01100??01101011,
                   AMOORD   = 15'b01000??01101011,
                   AMOMIND  = 15'b10000??01101011,
                   AMOMAXD  = 15'b10100??01101011,
                   AMOMINUD = 15'b11000??01101011,
                   AMOMAXUD = 15'b11100??01101011;

  /*
   * RV32/RV64 M-Extensions instructions
   */
  //                            f7       f3 opcode
  parameter [14:0] MUL    = 15'b0000001_000_01100,
                   MULH   = 15'b0000001_001_01100,
                   MULW   = 15'b0000001_000_01110,
                   MULHSU = 15'b0000001_010_01100,
                   MULHU  = 15'b0000001_011_01100,
                   DIV    = 15'b0000001_100_01100,
                   DIVW   = 15'b0000001_100_01110,
                   DIVU   = 15'b0000001_101_01100,
                   DIVUW  = 15'b0000001_101_01110,
                   REM    = 15'b0000001_110_01100,
                   REMW   = 15'b0000001_110_01110,
                   REMU   = 15'b0000001_111_01100,
                   REMUW  = 15'b0000001_111_01110;


  /*
   * RV32/64 C-Extensions instructions
   */
  //					31	       16 f3  12	3 op
  parameter [31:0] 	CILLEGAL   = 32'b0000000000000000_000_00000000000_00,
                    CADDI4SPN  = 32'b????????????????000???????????00,
                    CLOADDQ    = 32'b????????????????001???????????00,
                    CLW        = 32'b????????????????010???????????00,
                    CLOADFD    = 32'b????????????????011???????????00,
                    CSTOREDQ   = 32'b????????????????101???????????00,
                    CSW        = 32'b????????????????110???????????00,
                    CSTOREFD   = 32'b????????????????111???????????00,
                    CADDI	   = 32'b????????????????000???????????01,
                    CJALADDIW  = 32'b????????????????001???????????01,
                    CLI        = 32'b????????????????010???????????01,
                    CLUIADDI16 = 32'b????????????????011???????????01,
                    CALU 	   = 32'b????????????????100???????????01,
                    CJ         = 32'b????????????????101???????????01,
                    CBEQZ      = 32'b????????????????110???????????01,
                    CBNEZ      = 32'b????????????????111???????????01,
                    CSLLI      = 32'b????????????????000???????????10,
                    CSPLDQ     = 32'b????????????????001???????????10,
                    CLWSP      = 32'b????????????????010???????????10,
                    CSPLFD     = 32'b????????????????011???????????10,
                    CSYSTEM    = 32'b????????????????100???????????10,
                    CSPSDQ     = 32'b????????????????101???????????10,
                    CSWSP      = 32'b????????????????110???????????10,
                    CSPSFD     = 32'b????????????????111???????????10;

  parameter [4:0]	SP = 5'b00010,
                    X1 = 5'b00001,
                    X0 = 5'b00000;

  parameter[4:0]	CSRLI	   = 5'b?00??,
			CSRAI	   = 5'b?01??,
			CANDI	   = 5'b?10??,
			CSUB	   = 5'b01100,
			CXOR	   = 5'b01101,
			COR	   = 5'b01110,
			CAND	   = 5'b01111,
			CSUBW	   = 5'b11100,
			CADDW	   = 5'b11101;
				 
endpackage

