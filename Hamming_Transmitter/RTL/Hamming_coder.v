module Hamming_coder( 

    input  [  7 : 0 ] data_i, 	// Данные, которые будем кодировать 
    output [ 15 : 0 ] package_o // Пакет с информационными и служебными битами
    
    );
    
    wire parity_8 = data_i[ 7 ] ^ data_i[ 6 ] ^ data_i[ 5 ] ^ data_i[ 4 ];
    wire parity_4 = data_i[ 7 ] ^ data_i[ 3 ] ^ data_i[ 2 ] ^ data_i[ 1 ];
    wire parity_2 = data_i[ 6 ] ^ data_i[ 5 ] ^ data_i[ 3 ] ^ data_i[ 2 ] ^ data_i[ 0 ];
    wire parity_1 = data_i[ 6 ] ^ data_i[ 4 ] ^ data_i[ 3 ] ^ data_i[ 1 ] ^ data_i[ 0 ];
    
    wire [ 14 : 0 ] temporary = { 3'b000, data_i[ 7 : 4 ], parity_8, data_i[ 3 : 1 ], parity_4 , data_i[ 0 ], parity_2 , parity_1 };
    
    assign package_o = { temporary, ^temporary };
    
endmodule