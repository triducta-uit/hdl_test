/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_asiclab_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = 0;
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
    wire _unused = &{ena, uio_in, ui_in, 1'b0};

  reg [7:0] PC;
  reg [7:0] regfile[0:3];             
  reg [7:0] memory[0:31];      
  reg [7:0] alu_result;             
  reg jump;
  wire [7:0] PC_next = PC + 1;
  wire [7:0] PC_jump = {4'b0000, imm4};
  wire [7:0] PC_new = ((opcode == 2'd11)&(regfile[regA] == 8'd0))?PC_jump:PC_next;
  wire [7:0] instr = memory[PC];   // đọc lệnh từ bộ nhớ
  wire [1:0] opcode = instr[7:6];    // phân vùng mã lệnh
  wire [1:0] regA   = instr[5:4];      // phân vùng địa chỉ reg đích
  wire [1:0] regB   = instr[3:2];      // phân vùng địa chỉ reg nguồn
  wire [1:0] func   = instr[1:0];      // phân vùng địa chỉ mã chức năng
  wire [3:0] imm4   = instr[3:0];    // phân vùng địa chỉ mem/nhảy
    
  always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
      PC <= 8'd0;
      regfile[0] <= 0;
      regfile[1] <= 0;
      regfile[2] <= 0;
      regfile[3] <= 0;
        memory[0] <= 0;
        memory[1] <= 0;
        memory[2] <= 0;
        memory[3] <= 0;
        memory[4] <= 0;
        memory[5] <= 0;
        memory[6] <= 0;
        memory[7] <= 0;
        memory[8] <= 0;
        memory[9] <= 0;
        memory[10] <= 0;
        memory[11] <= 0;
        memory[12] <= 0;
        memory[13] <= 0;
        memory[14] <= 0;
        memory[15] <= 0;
        memory[16] <= 0;
        memory[17] <= 0;
        memory[18] <= 0;
        memory[19] <= 0;
        memory[20] <= 0;
        memory[21] <= 0;
        memory[22] <= 0;
        memory[23] <= 0;
        memory[24] <= 0;
        memory[25] <= 0;
        memory[26] <= 0;
        memory[27] <= 0;
        memory[28] <= 0;
        memory[29] <= 0;
        memory[30] <= 0;
        memory[31] <= 0;
    end else begin
      PC <= PC_new; 
      jump <= 0;
      case (opcode)
        2'b00: begin // LD reg, [imm]
          regfile[regA] <= memory[{4'b0001, imm4}];  
        end
        2'b01: begin // ST reg, [imm]
          memory[{4'b0001, imm4}] <= regfile[regA];  
        end
          2'b10: begin // ALU
            case (func)
              2'b00: alu_result <= regfile[regA] + regfile[regB]; // ADD
              2'b01: alu_result <= regfile[regA] - regfile[regB]; // SUB
              2'b10: alu_result <= regfile[regA] & regfile[regB]; // AND
              2'b11: alu_result <= regfile[regA] ^ regfile[regB]; // XOR
            endcase
            regfile[regA] <= alu_result;
          end
          2'b11: begin // JZ regA, imm
            if (regfile[regA] == 8'd0) begin
              jump <= 1;  
              end else jump <= 0;
            end
        endcase
    end
end
endmodule
