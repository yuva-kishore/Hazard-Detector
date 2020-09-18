`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2019 10:57:38
// Design Name: 
// Module Name: freq_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module freqdiv(
        input clk_in,
        output reg clk_reduced
    );
    parameter DIV =100;  //counter length
    reg [$clog2(DIV)-1:0]counter=0; //clog2 gives ceiling of logarithm
    reg rst=1;//reset
    
        always @(posedge clk_in)
        begin
            if(rst) //reset
            begin
                rst<=0;
                counter<=0;
                clk_reduced<=0;
            end
            else
            begin
            if(counter==DIV)  //after counted for required cycles then invert
                begin
                clk_reduced=~clk_reduced;
                counter<=0;
                end
            else
                begin
                    counter<=counter+1; //incrementing counter
                end
            end
        end
 
endmodule

