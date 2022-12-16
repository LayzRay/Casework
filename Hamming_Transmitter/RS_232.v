module RS_232 (

	input CLOCK_50,
	
	input [1:0] KEY,
	
	output UART_TXD

);

/////////////Main parameteres/////////////////////////////////
   
   parameter FREQUENCY = 32'd50_000_000;
   parameter SPEED = 32'd9600;
   //parameter FOLLOW_UP_PERIOD = 32'd1000;
    
   //parameter PERIOD_PULSES = FREQUENCY/FOLLOW_UP_PERIOD;
   parameter Divider = FREQUENCY/SPEED;
	
//////////////////////////////////////////////////////////////	

	reg [7:0] frame;
	reg dataReady;
	wire rts;
	
	Transmitter #(FREQUENCY, SPEED) T (
		
		.CLK_i(CLOCK_50),
		.data(frame),
		.dataReady(dataReady),
		.tx(UART_TXD),
		.rts(rts),
		.reset_n(!KEY[0])
		
	);
	
////////////////////////////////////////////////////////

	reg [7:0] data_to_code;
	wire [15:0] package;

	Coder_RS_232 CD (.data_i(data_to_code), .package_o(package));

////////////////////////////////////////////////////////

	reg [3:0] data_counter;
	wire [7:0] Read_data;

	Data_memory DM (.A(data_counter), .RD(Read_data));
	
///////Service VAR/////////////////////////////////////
		
	reg first_frame, CLK_low;
	reg [1:0] state;
	reg [31:0] tickCount;
	reg KEY_presssed;
	reg [2:0] sync_reg;
	reg [7:0] error;
	
///////////FSM Parameteres/////////////
	
	parameter IDLE = 2'b00;
	parameter DATA_READY = 2'b01;
	parameter Transfer = 2'b10;
	parameter READY_TO_SEND = 2'b11;
	
//////////Begining/////////////////////	
	
	initial begin
	   
	   state <= IDLE;
	   first_frame <= 1'b1;
	   
	   data_counter <= 4'd0;
	   tickCount <= 32'd0;
		KEY_presssed <= 1'b0;
		sync_reg <= 3'd0;
		error <= 8'b01000100; // Можно внести ошибку
	   
	end
	
	always @( posedge CLOCK_50 or negedge KEY[0] ) begin
	
        if ( !KEY[0] ) begin
       
			  state <= IDLE;
			  dataReady <= 1'b0; 
			  first_frame <= 1'b1; 
			  data_counter <= 4'd0;
			  tickCount <= 32'd0;
			  KEY_presssed <= 1'b0;
			  sync_reg <= 3'd0;
        
      end else begin
		
		  if ( tickCount != Divider) tickCount <= tickCount + 32'd1;
        else tickCount <= 32'd0;
              
        CLK_low <= (tickCount == 32'd0);
		  
		  sync_reg[2] <= !KEY[1];
		  sync_reg[1] <= sync_reg[2];
		  sync_reg[0] <= sync_reg[1];
		
		  KEY_presssed <= sync_reg[1] & ( !sync_reg[0] );
			
			if ( KEY_presssed && (data_counter == 4'd0) ) begin
					
				data_to_code <= Read_data;
				data_counter <= data_counter + 1;
				
				dataReady <= 1'b1;
				state <= DATA_READY;
				
		   end
			
			if ( CLK_low ) begin

            case ( state )
        
            IDLE: begin
                
                     if ( (data_counter != 4'd0) && (data_counter != 4'd6) ) begin
                     
                          data_to_code <= Read_data;
                          data_counter <= data_counter + 1;
                          first_frame <= 1'b1;
                          dataReady <= 1'b1;
                          
                          state <= DATA_READY;
                     
                     end else state <= IDLE;
                            
            end
            
            DATA_READY: begin
            
                if ( first_frame ) frame <= package[15:8];
                else if (data_counter != 4'd2) frame <= package[7:0];
					 else frame <= package[7:0] ^ error;
                
                dataReady <= 1'b0;
                state <= Transfer;
                        
            end
            
            Transfer: begin
            
                if (rts) state <= READY_TO_SEND;
             
            end
            
            READY_TO_SEND: begin

                     if ( first_frame ) begin
                     
                         first_frame <= 1'b0;
                         dataReady <= 1'b1;
                         state <= DATA_READY;
                         
                     end else state <= IDLE;
                     
                end
        
            endcase
			end	
		end
		end
	
endmodule