module Data_memory (

    input [3:0] A, // Адрес ячейки с данными
    output [7:0] RD // Выходные данные
    
    );
    
    reg [7:0] RAM [0:15];
	 
    initial $readmemh("Data.txt", RAM);
    
    assign RD = RAM[A];
    
endmodule