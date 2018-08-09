`timescale 1ns / 1ns

module realtobinary();
`include "header.vh"
integer inputFile, outputFile, counterInput;
real value;

initial 
begin
    inputFile=$fopen("lut.txt", "r");
    if(inputFile==0)
    begin
        $display("Unable to open input file");
        $finish;
    end
    outputFile=$fopen("lut_bin.txt", "w");
    if(outputFile==0)
    begin
        $display("Unable to open output file");
        $finish;
    end
    forever
    begin
        counterInput=$fscanf(inputFile, "%f\n", value);
        if($feof(inputFile))
        begin
            $display("Finished reading file");
            $fclose(inputFile);
            $fclose(outputFile);
            $finish;
        end
        $fdisplay(outputFile, "%10b", d(value, INPUT_WIDTH, IFRACTION, IINT));
    end
    
end




endmodule
