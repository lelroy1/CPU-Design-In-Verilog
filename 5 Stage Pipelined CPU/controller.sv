// Defines the logic to control the control signals that go to the datapath	
// takes inputs: instruction, negative, overflow, zero, zero_alu, carry_out, setflags_ex, blt_rf, b_rf
// from the datapath with these inputs creates outputs: reg2loc, regwr, alusrc, addi, byteop,
// setflags, setzeroflag, mov, memwr, mem2reg, movk, uncondbr, brtaken, cbz, blt, b

`timescale 1ns/10ps
module controller (instruction, negative, negative_alu, overflow, overflow_alu, zero, zero_alu, carry_out, setflags_ex, blt_rf, b_rf, aluop, reg2loc, regwr, alusrc,
                   addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk, uncondbr,
                   brtaken, cbz, blt, b);
    input logic [31:0] instruction;
    input logic negative, overflow, negative_alu, overflow_alu, zero, zero_alu, carry_out, setflags_ex, blt_rf, b_rf;
    output logic [2:0] aluop;
    output logic reg2loc, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, 
                 mem2reg, movk, uncondbr, brtaken, cbz, blt, b;
    
    always_comb begin
        // ADDI
        if (instruction[31:22] == 10'b1001000100) begin
            aluop = 3'b010;
            //reg2loc = 1'bX;
            regwr = 1'b1;
            // alusrc = 1'bX;
            addi = 1'b1;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b0;
            memwr = 1'b0;
            mem2reg = 1'b0;
            // movk = 1'bX;
            // uncondbr = 1'bX;
            // this assumes all no ops following B or BLT are ADDI
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;

            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end

        // ADDS
        if (instruction[31:21]== 11'b10101011000) begin
            aluop = 3'b010;
            reg2loc = 1'b0;
            regwr = 1'b1;
            alusrc = 1'b1;
            addi = 1'b0;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b1;
            mov = 1'b0;
            memwr = 1'b0;
            mem2reg = 1'b0;
            // movk = 1'bX;
            // uncondbr = 1'bX;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;

            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end

        // B
        if (instruction[31:26] == 6'b000101) begin
            //aluop = 3'b010;
            //reg2loc = 1'b0;
            regwr = 1'b0;
            //alusrc = 1'b1;
            //addi = 1'b0;
            //byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            //mov = 1'b0;
            memwr = 1'b0;
            //mem2reg = 1'b0;
            // movk = 1'bX;
            uncondbr = 1'b1;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b1;
        end

        // B.LT
        if (instruction[31:24] == 8'b01010100) begin
            //aluop = 3'b010;
            //reg2loc = 1'b0;
            regwr = 1'b0;
            //alusrc = 1'b1;
            //addi = 1'b0;
            //byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            //mov = 1'b0;
            memwr = 1'b0;
            //mem2reg = 1'b0;
            // movk = 1'bX;
            uncondbr = 1'b0; 
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b1;
            b = 1'b0;
        end

        // CBZ
        if (instruction[31:24] == 8'b10110100) begin
            aluop = 3'b000;
            reg2loc = 1'b1;
            regwr = 1'b0;
            alusrc = 1'b1;
            addi = 1'b0;
            //byteop = 1'b0;
            setzeroflag = 1'b1;
            setflags = 1'b0;
            //mov = 1'b0;
            memwr = 1'b0;
            mem2reg = 1'b0;
            // movk = 1'bX;
            uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b1;
            blt = 1'b0;
            b = 1'b0;
        end

        // LDUR
        if (instruction[31:21] == 11'b11111000010) begin
            aluop = 3'b010;
            //reg2loc = 1'b1;
            regwr = 1'b1;
            alusrc = 1'b0;
            addi = 1'b0;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b0;
            memwr = 1'b0;
            mem2reg = 1'b1;
            // movk = 1'bX;
            // uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end

        // LDURB
        if (instruction[31:21] == 11'b00111000010) begin
            aluop = 3'b010;
            //reg2loc = 1'bX;
            regwr = 1'b1;
            alusrc = 1'b0;
            addi = 1'b0;
            byteop = 1'b1;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b0;
            memwr = 1'b0;
            mem2reg = 1'b1;
            // movk = 1'bX;
            // uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end

        // MOVK
        if (instruction[31:23] == 9'b111100101) begin
            aluop = 3'b000;
            reg2loc = 1'b1;
            regwr = 1'b1;
            alusrc = 1'b1;
            addi = 1'b0;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b1;
            memwr = 1'b0;
            mem2reg = 1'b0;
            movk = 1'b1;
            // uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end

        // MOVZ
        if (instruction[31:23] == 9'b110100101) begin
            aluop = 3'b000;
            reg2loc = 1'b1;
            regwr = 1'b1;
            alusrc = 1'b1;
            addi = 1'b0;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b1;
            memwr = 1'b0;
            mem2reg = 1'b0;
            movk = 1'b0;
            // uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end
        
        // STUR
        if (instruction[31:21] == 11'b11111000000) begin
            aluop = 3'b010;
            reg2loc = 1'b1;
            regwr = 1'b0;
            alusrc = 1'b0;
            addi = 1'b0;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b0;
            memwr = 1'b1;
            //mem2reg = 1'b0;
            //movk = 1'b0;
            // uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end
        
        // STURB
        if (instruction[31:21] == 11'b00111000000) begin
            aluop = 3'b010;
            reg2loc = 1'b1;
            regwr = 1'b0;
            alusrc = 1'b0;
            addi = 1'b0;
            byteop = 1'b1;
            setzeroflag = 1'b0;
            setflags = 1'b0;
            mov = 1'b0;
            memwr = 1'b1;
            //mem2reg = 1'b0;
            //movk = 1'b0;
            // uncondbr = 1'b0; 
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end

        // SUBS 
        if (instruction[31:21] == 11'b11101011000) begin
            aluop = 3'b011;
            reg2loc = 1'b0;
            regwr = 1'b1;
            alusrc = 1'b1;
            addi = 1'b0;
            byteop = 1'b0;
            setzeroflag = 1'b0;
            setflags = 1'b1;
            mov = 1'b0;
            memwr = 1'b0;
            mem2reg = 1'b0;
            //movk = 1'b0;
            //uncondbr = 1'b0;
            // Logic in case this operation is after a branch
            if (blt_rf) begin
                if (setflags_ex) begin
                    if (negative_alu != overflow_alu) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
                else begin
                    if (negative != overflow) begin
                        brtaken = 1'b1;
                    end else begin
                        brtaken = 1'b0;
                    end
                end
            end 
            else if (b_rf) begin
                brtaken = 1'b1;
            end else begin
                brtaken = 1'b0;
            end
            cbz = 1'b0;
            blt = 1'b0;
            b = 1'b0;
        end
    end
endmodule