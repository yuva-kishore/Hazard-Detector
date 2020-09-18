`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2019 14:11:12
// Design Name: 
// Module Name: main
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


module main(
    input clk,  //clock
    input [7:0] A, //instruction input
    input data_in, // input switch
    input rst,   //reset
    output reg [7:0]led
    
    );
    reg [7:0] array [7:0];      //instructions are stored here
    reg [20:0] debounce=0;      //debounce  to control switch
    reg flag_input_over;        //indicates the completion of 8 instr.
    reg [1:0]flag_display=0;    //to control display of all hazards for each pair of instructions
    
    integer address=0;          //counting instr.
    reg [7:0] ins1;             //first instr.
    reg [7:0] ins2;             //second instr.
    wire [2:0] out;             //hazards are stored in out
    reg [2:0] out_dum;
    integer k1=0;               //counter
    integer k2=1;
    wire redclk;                //delay between each display with reduced clock frequency
    
    check c1 (.x(ins1),.y(ins2),.z(out));   //checks for dependencies between pair of instr.
    freqdiv f1 (.clk_in(clk),.clk_reduced(redclk)); //delay between each display
    always@(posedge clk)
        if(rst)                 //reset
        begin
            array[0]<=0; array[1]<=0; array[2]<=0;array[3]<=0;
            array[4]<=0; array[5]<=0; array[6]<=0;array[7]<=0;  
            address=0;
            flag_input_over=0;flag_display=0;
            k1=0;k2=0;
            led<=0;           
        end
   //debounce
    always@(posedge clk)
    
        if(debounce==21'b1_1111_1111_1111_1111_1111)  //approx 1sec delay between switch inputs
            if(data_in && (address<8))  //when switch is on and all inputs are not taken
                begin
                    array[address]<=A;
                    address<=address+1;
                    debounce<=0;
                end
            else if(data_in && (address==8)) //last instruction input
               begin
                    address<=address;
                    debounce<=debounce;
                    flag_input_over<=1;
                end 
            else 
                begin
                    debounce<=debounce;
                    
                end
        else 
            begin
                debounce<=debounce+1;
                flag_input_over<=0;
            end
    
    
    always @(posedge clk)
    begin
        if(flag_input_over)
         begin
            if(k1<8)            //running check for every pair of instructions
                begin
                if(k2<8)
                    begin
                        if(flag_display==2'b00)
                            begin
                                ins1<=array[k1];        //check is run for ins1 and ins2
                                ins2<=array[k2];
                                flag_display<=2'b01;    //indicates that display of hazard is still pending
                            end
                        //k2<=k2+1;
                    end
                end
                else
                    begin
                        k1<=k1+1;     //loopcontrol
                        k2<=k1+1;
                    end
         end   
    end
   //output encoding
    //waw=11 war=01 raw=10
    always@(posedge redclk)
    begin
        if(flag_display==2'b01)
            begin
                out_dum<=out;           //out value is copied to out_dum a dummy value so that actual wire-out doesn't change
                flag_display<=2'b10;    
            end
        if(flag_display==2'b10)
        begin
            if(out_dum[2])
                begin
                    led<={2'b10,k1,k2};  //raw hazard is displayed and that bit changed to skip reprint again
                    out_dum[2]<=0;
                end
            else if(out_dum[1])
                begin
                    led<={2'b01,k1,k2};   //war hazard is displayed and that bit changed to skip reprint again
                    out_dum[1]<=0;
                end
            else if(out_dum[0])
                begin
                    led<={2'b11,k1,k2};   //waw hazard is displayed and that bit changed to skip reprint again
                    out_dum[0]<=0;
                end
            else
                begin
                    k2<=k2+1;               //after display ,instruction two is incremented
                    flag_display<=2'b00;    //now ready for check with next set of instructions
                end
        end
    end
    
    
endmodule
