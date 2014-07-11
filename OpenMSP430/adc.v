integer file,file_r,i;
real data[0:4];

initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
      repeat(5) @(posedge mclk);
      stimulus_done = 0;

      //---------------------------------------
      // Check CPU configuration
      //---------------------------------------
      if ((`PMEM_SIZE !== 24576) || (`DMEM_SIZE !== 16384))
        begin
           $display(" ===============================================");
           $display("|               SIMULATION ERROR                |");
           $display("|                                               |");
           $display("|  Core must be configured for:                 |");
           $display("|               - 24kB program memory           |");
           $display("|               - 16kB data memory              |");
           $display(" ===============================================");
           $finish;        
        end


      //---------------------------------------
      // Generate stimulus
      //---------------------------------------

	file = $fopen("test.txt", "r");
  	
	for (i=0;i<5;i=i+1) begin  
		file_r = $fscanf(file, "%d\n",data[i]); 
  		$display("%d",data[i]);
		dmem_0.mem[5+i] = data[i];
        end     


      stimulus_done = 1;
	repeat(1000) @(posedge mclk);
      $fclose(file);

      $display(" ===============================================");
      $display("|               SIMULATION DONE                 |");
      $display("|       (stopped through verilog stimulus)      |");
      $display(" ===============================================");
      $finish;

   end
