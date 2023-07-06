module UART_FSM_Tx #( parameter FREQUENCY = 32'd50_000_000, SPEED = 32'd15_000_00 ) ( // Магические числа

    input 	   clk_i,
    	  	   reset_n,
    
    	       req_i,
    [ 7:0 ]    data,
    
    output reg tx_o,   // Выход на TxD UART
    		   ready_o // Сигнал о том, что передатчик готов отправлять данные

);

//////////Parameters//////////////////////
	localparam Divider = FREQUENCY/SPEED; // Количество тактов, необходимых для соблюдения определённой скорости
 
	// Состояния конечного автомата		
											  
	localparam IDLE     = 2'd0; // Chill
	localparam STARTBIT = 2'd1; // Стадия отправки стартового бита
	localparam DATABIT  = 2'd2; // Стадия отправки кадра
	localparam STOPBIT  = 2'd3; // Стадия отправки стопового бита

//////Служебные переменные////////////////
    
    reg [ 1  : 0  ] state;
    reg [ 3  : 0  ] bit_counter;  // Счётчик битов кадра
    reg [ 31 : 0  ] tick_counter; // Счётчик тактовых импульсов
    reg 			CLK_low;  	  // Медленный CLOCK, по которому всё будет работать (соответствует заданной скорости передачи)
    
    always @( posedge CLK_i )
    
		if ( ~reset_n ) begin // Сброс внутренних регистров

			state   <= IDLE;
			ready_o <= 1'd1;
			tx_o    <= 1'd1;
			
			bit_counter  <= 4'd0;
			tick_counter <= 32'd0;

		end else begin
		  
			tick_counter <= ( tick_counter != Divider ) ? tick_counter + 32'd1 : 32'd0;		  
			CLK_low      <= ( tick_counter == 32'd0 );
			  
			if ( CLK_low )
		  
					case ( state )
						 
						IDLE: begin
								
							tx_o <= 1'd1;
												
							if ( req_i ) begin
									
								ready_o <= 1'd0;
								state   <= STARTBIT;
							
							end else begin
									
								state   <= IDLE;
								ready_o <= 1'd1;
								tx_o    <= 1'd1;		
							
							end
							
						end
									  
						STARTBIT: begin
								
							tx    <= 1'd0;         
							state <= DATABIT;

						end
									  
						DataBit: begin
								
							bit_counter <= bit_counter + 4'd1;
								
							if ( bit_counter == 4'd8 ) begin
								
								bit_counter <= 4'd0;
								state       <= STOPBIT;
													
							end else 
								
								tx <= data[ bitCount ];
									  
						end
									  
						STOPBIT: begin
						
							tx      <= 1'b1;
							ready_o <= 1'b1;
				
							state <= IDLE;
													
						end
									  
						default: begin 
						
							state   <= IDLE;
							ready_o <= 1'd1;
							tx_o    <= 1'd1;
							
							bit_counter  <= 4'd0;
							tick_counter <= 32'd0;

						end
								
					endcase
			  end
				 
endmodule
