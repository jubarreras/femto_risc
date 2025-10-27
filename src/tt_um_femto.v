module tt_um_femto (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // Declaración explícita de señales internas
    wire RXD           = ui_in[0];
    wire spi_miso      = ui_in[1];
    wire spi_miso_ram  = ui_in[2];
    wire TXD;
    wire spi_mosi;
    wire spi_cs_n;
    wire spi_clk;
    wire spi_clk_ram;
    wire spi_cs_n_ram;
    wire spi_mosi_ram;
    wire LEDS;
    assign uo_out[0] = TXD;
    assign uo_out[1] = spi_mosi;
    assign uo_out[2] = spi_cs_n;
    assign uo_out[3] = spi_clk;
    assign uo_out[4] = spi_clk_ram;
    assign uo_out[5] = spi_cs_n_ram;
    assign uo_out[6] = spi_mosi_ram;
    assign uo_out[7] = LEDS;
    assign uio_out = 0;
    assign uio_oe  = 0;
    wire [31:0] mem_address;
    reg  [31:0] mem_rdata;
    wire mem_rstrb;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wmask;
    wire mapped_spi_flash_rbusy;
	
   FemtoRV32 CPU(
      .clk(clk),
	  .reset(rst_n),		 
      .mem_addr(mem_address),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask),
      .mem_rbusy(mapped_spi_flash_rbusy | spi_ram_rbusy),
      .mem_wbusy(spi_ram_wbusy)
   );
   wire [31:0] RAM_rdata;
   wire  wr = |mem_wmask;
   wire  rd = mem_rstrb; 
   wire spi_ram_rbusy;
   wire spi_ram_wbusy;
   MappedSPIRAM mapped_spi_ram(
      .clk(clk),
	   .reset(rst_n),
      .word_address(mem_address[21:2]),
      .wdata(mem_wdata),
      .rd(cs[6] & rd),
      .wr(cs[6] & wr),
      .rbusy(spi_ram_rbusy),
      .wbusy(spi_ram_wbusy),
      .CLK(spi_clk_ram),
      .CS_N(spi_cs_n_ram),
      .MISO(spi_miso_ram),
      .MOSI(spi_mosi_ram),
      .rdata(dpram_dout)
   );
   
   MappedSPIFlash mapped_spi_flash(
      .clk(clk),
      .reset(rst_n),
      .rstrb(cs[0] & rd),
      .word_address(mem_address[21:2]),
      .rdata(RAM_rdata),
      .rbusy(mapped_spi_flash_rbusy),
      .CLK(spi_clk),
      .CS_N(spi_cs_n),
      .MISO(spi_miso),
      .MOSI(spi_mosi)   
   );

   wire [31:0] uart_dout;
   wire [31:0] mult_dout;
   wire [31:0] dpram_dout;

  peripheral_uart #(
     .clk_freq(27000000),    // 27000000 for gowin
     .baud(115200)            // 57600 for gowin
   ) per_uart(
     .clk(clk), 
	  .rst(!rst_n), 
     .d_in(mem_wdata[7:0]), 
     .cs(cs[5]), 
     .addr(mem_address[4:0]), 
     .wr(wr), 
     .d_out(uart_dout), 
     .uart_tx(TXD), 
     .uart_rx(RXD), 
     .ledout(LEDS)
   ); 
  reg [6:0]cs;  // CHIP-SELECT
  always @*
  begin
      case (mem_address[31:16])	// direcciones - chip_select
        16'h0000: cs= 7'b0000001; 	//RAM
        16'h0040: cs= 7'b0100000; 	//uart
        16'h0041: cs= 7'b0010000;	//gpio
        16'h0042: cs= 7'b0001000;	//mult
        16'h0043: cs= 7'b0000100;	//div
        16'h0044: cs= 7'b0000010;	//bin_to_bcd
        16'h0001: cs= 7'b1000000;   //dpRAM
        default: cs= 7'b0000001;
      endcase
  end
  // ============== MUX ========================  // se encarga de lecturas del RV32
  always @*
  begin
      case (cs)
        7'b1000000: mem_rdata = dpram_dout;
        7'b0100000: mem_rdata = uart_dout;
        7'b0001000: mem_rdata = mult_dout;
        7'b0000001: mem_rdata = RAM_rdata;
        default:    mem_rdata = 32'h00000000;
      endcase
  end
 // ============== MUX ========================  // 

`ifdef BENCH
   always @(posedge clk) begin
      if(cs[5] & wr ) begin
	 $write("%c", mem_wdata[7:0] );
	 $fflush(32'h8000_0001);
      end
   end
`endif

	// Flip-flop dummy para asegurar lógica secuencial
reg [7:0] dummy_ff;

always @(posedge clk) begin
  if (!rst_n)
    dummy_ff <= 8'h00;
  else
    dummy_ff <= ui_in;
end

endmodule
