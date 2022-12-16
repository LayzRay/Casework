module Transmitter #(parameter FREQUENCY = 32'd50_000_000, SPEED = 32'd15_000_00) (

    input CLK_i,
    
    input reset_n,
    
    input dataReady, // Сигнал о том, что на входе данные готовы
    input [7:0] data, // Уже закодированные данные
    
    output reg tx, // Выход на TxD UART
    output reg rts // Сигнал о том, что передатчик готов отправлять данные
    
);

//////////Parameters//////////////////////
    parameter Divider = FREQUENCY/SPEED; // Количество тактов, необходимых для соблюдения
													  // определённой скорости
	 // Состояния конечного автомата												  
    parameter Idle = 2'b00; 			// Шум
    parameter StartBit = 2'b01;		// Стадия отправки стартового бита
    parameter DataBit = 2'b10;		// Стадия отправки кадра
    parameter StopBit = 2'b11;      // Стадия отправки стопового бита

//////Служебные переменные////////////////
    
    reg [1:0] state;
    reg [3:0] bitCount; // Счётчик битов кадра
    reg [31:0] tickCount; // Счётчик тактовых импульсов
    reg CLK_low;  // Медленный CLOCK, по которому всё будет работать
						// (соответствует заданной скорости передачи)

////////////////////////////////////////
	 
    initial begin
    
        state <= Idle;
		  
        rts <= 1'b1;
       
        bitCount <= 4'd0;
        tickCount <= 32'd0;
        
    end
	 
////////////////////////////////////////
    
    always @( posedge CLK_i or posedge reset_n ) begin
    
        if ( reset_n ) begin // Сброс внутренних регистров
       
            state <= Idle;
				
            rts <= 1'b1;
            
            bitCount <= 4'd0;
            tickCount <= 32'd0;
        
        end else begin
		  
			  if ( tickCount != Divider) tickCount <= tickCount + 32'd1;
			  else tickCount <= 32'd0;
					  
			  CLK_low <= (tickCount == 32'd0);
			  
			  if ( CLK_low ) begin
		  
					  case ( state )
						 
							  Idle: begin
								
									tx <= 1'b1;
													 
									if ( dataReady ) begin
										 
										 rts <= 1'b0;
										 state <= StartBit;
									
									end else begin
										 
										 rts <= 1'b1;
										 state <= state;		
									
									end
									
							  end
									  
							  StartBit: begin
								
									tx <= 1'b0;         
									state <= DataBit;

							  end
									  
							  DataBit: begin
								
									bitCount <= bitCount + 1;
									  
									if (bitCount == 4'b1000) begin
									  
										 bitCount <= 4'd0;
										 state <= StopBit;
															
									end else tx <= data[bitCount];
									  
							  end
									  
							  StopBit: begin
								
									tx <= 1'b1;
									rts <= 1'b1;
					  
									state <= Idle;
														  
									end
									  
							  default: state <= Idle;
								
					endcase
			  end
				 
		 end
	 end
    
endmodule
