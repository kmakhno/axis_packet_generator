`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/29/2022 05:19:04 PM
// Design Name: 
// Module Name: axis_packet_generator_tb
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


module axis_packet_generator_tb;

    localparam integer C_S0_AXI_DATA_WIDTH	= 32;
    localparam integer C_S0_AXI_ADDR_WIDTH	= 5;
    localparam integer C_M0_AXIS_TDATA_WIDTH = 32;


    reg  s0_axi_aclk;
    reg  s0_axi_aresetn;
    reg [C_S0_AXI_ADDR_WIDTH-1 : 0] s0_axi_awaddr;
    reg [2 : 0] s0_axi_awprot;
    reg  s0_axi_awvalid;
    wire  s0_axi_awready;
    reg [C_S0_AXI_DATA_WIDTH-1 : 0] s0_axi_wdata;
    reg [(C_S0_AXI_DATA_WIDTH/8)-1 : 0] s0_axi_wstrb;
    reg  s0_axi_wvalid;
    wire  s0_axi_wready;
    wire [1 : 0] s0_axi_bresp;
    wire  s0_axi_bvalid;
    reg  s0_axi_bready;
    reg [C_S0_AXI_ADDR_WIDTH-1 : 0] s0_axi_araddr;
    reg [2 : 0] s0_axi_arprot;
    reg  s0_axi_arvalid;
    wire  s0_axi_arready;
    wire [C_S0_AXI_DATA_WIDTH-1 : 0] s0_axi_rdata;
    wire [1 : 0] s0_axi_rresp;
    wire  s0_axi_rvalid;
    reg  s0_axi_rready;

    // Ports of Axi Master Bus Interface M0_AXIS
    wire  m0_axis_tvalid;
    wire [C_M0_AXIS_TDATA_WIDTH-1 : 0] m0_axis_tdata;
    wire  m0_axis_tlast;
    reg  m0_axis_tready;

	axis_packet_generator_v1_0 #( .C_M0_AXIS_TDATA_WIDTH(C_M0_AXIS_TDATA_WIDTH)) axis_packet_generator_v1_0_inst (
		.s0_axi_aclk(s0_axi_aclk),
		.s0_axi_aresetn(s0_axi_aresetn),
		.s0_axi_awaddr(s0_axi_awaddr),
		.s0_axi_awprot(s0_axi_awprot),
		.s0_axi_awvalid(s0_axi_awvalid),
		.s0_axi_awready(s0_axi_awready),
		.s0_axi_wdata(s0_axi_wdata),
		.s0_axi_wstrb(s0_axi_wstrb),
		.s0_axi_wvalid(s0_axi_wvalid),
		.s0_axi_wready(s0_axi_wready),
		.s0_axi_bresp(s0_axi_bresp),
		.s0_axi_bvalid(s0_axi_bvalid),
		.s0_axi_bready(s0_axi_bready),
		.s0_axi_araddr(s0_axi_araddr),
		.s0_axi_arprot(s0_axi_arprot),
		.s0_axi_arvalid(s0_axi_arvalid),
		.s0_axi_arready(s0_axi_arready),
		.s0_axi_rdata(s0_axi_rdata),
		.s0_axi_rresp(s0_axi_rresp),
		.s0_axi_rvalid(s0_axi_rvalid),
		.s0_axi_rready(s0_axi_rready),
		.m0_axis_aclk(s0_axi_aclk),
		.m0_axis_aresetn(s0_axi_aresetn),
		.m0_axis_tvalid(m0_axis_tvalid),
	    .m0_axis_tdata(m0_axis_tdata),
		.m0_axis_tlast(m0_axis_tlast),
		.m0_axis_tready(m0_axis_tready)
    );

    // AXI-Lite Read task
    task axi_read;
    input  [29:0] offset;
    output [31:0] data;
    reg    [31:0] addr;
    reg     [1:0] resp;
    begin
        // shift offset to account for AXI byte addressing
        addr = {offset, 2'b00};
        // Drive Address valid
        @(posedge s0_axi_aclk);
        #1;
        s0_axi_araddr  = addr;
        s0_axi_arvalid = 1;
        s0_axi_rready  = 0;
        // Address Response Phase
        @(negedge s0_axi_aclk);
        while (s0_axi_arready == 1'b0)
        @(negedge s0_axi_aclk);
        @(posedge s0_axi_aclk);
        #1;
        s0_axi_araddr  = 0;
        s0_axi_arvalid = 0;
        s0_axi_rready  = 1;
        // Read Data Phase
        @(negedge s0_axi_aclk);
        while (s0_axi_rvalid == 1'b0)
        @(negedge s0_axi_aclk);
        @(posedge s0_axi_aclk);
        data = s0_axi_rdata;
        resp = s0_axi_rresp;
        if (resp != 0) $display ("Error AXI RRESP not equal 0");
        #1;
        s0_axi_rready  = 0;
    end
    endtask // axi_read

    // AXI-Lite Write task
    task axi_write;
    input [29:0] offset;
    input [31:0] data;
    reg   [31:0] addr;
    reg    [1:0] resp;
    begin
        // shift offset to account for AXI byte addressing
        addr = {offset, 2'b00};
        // Drive Address & Data valid
        @(posedge s0_axi_aclk);
        #1;
        s0_axi_awaddr  = addr;
        s0_axi_awvalid = 1;
        s0_axi_wdata   = data;
        s0_axi_wvalid  = 1;
        s0_axi_bready  = 0;
        fork
        // Address Response Phase
        begin
            @(negedge s0_axi_aclk);
            while (s0_axi_awready == 1'b0)
            @(negedge s0_axi_aclk);
            @(posedge s0_axi_aclk);
            #1;
            s0_axi_awaddr  = 0;
            s0_axi_awvalid = 0;
        end
        // Data Response Phase
        begin		  
            @(negedge s0_axi_aclk);
            while (s0_axi_wready == 1'b0)
            @(negedge s0_axi_aclk);
            @(posedge s0_axi_aclk);
            #1;
            s0_axi_wdata   = 0;
            s0_axi_wvalid  = 0;
        end
        join
        // BRESP phase
        @(negedge s0_axi_aclk);
        while (s0_axi_bvalid == 1'b0)
        @(negedge s0_axi_aclk);
        @(posedge s0_axi_aclk);
        resp = s0_axi_bresp;
        if (resp != 0) $display ("Error AXI BRESP not equal 0");
        #1;
        s0_axi_bready = 1;
        @(posedge s0_axi_aclk);
        #1;
        s0_axi_bready = 0;
    end
    endtask // axi_write

    initial begin
        s0_axi_aclk <= 0;
        forever #40 s0_axi_aclk <= ~s0_axi_aclk;
    end

    reg [31:0] val;

    initial 
    begin: main_stimulus
        s0_axi_awaddr=0;
        s0_axi_awprot=0;
        s0_axi_awvalid=0;
        s0_axi_wdata=0;
        s0_axi_wstrb=4'hf;
        s0_axi_wvalid=0;
        s0_axi_bready=0;
        s0_axi_araddr=0;
        s0_axi_arprot=0;
        s0_axi_arvalid=0;
        s0_axi_rready=0;
        s0_axi_aresetn = 0;
        repeat (50) @(negedge s0_axi_aclk);
        s0_axi_aresetn = 1;
        repeat (100) @(posedge s0_axi_aclk);
        axi_write(1, 0); //start delay 10 clock cycles
        axi_write(2, 100); //100 delay between packets
        axi_write(3, 9); //packet size is 9 in clock units
        axi_write(4, 4); //4 packets
        axi_write(0, 1);
        forever begin
            axi_read(5, val);
            if (val == 1)
                break;
        end
        repeat (100) @(posedge s0_axi_aclk);
        $finish;
    end
    
    initial 
    begin: m_axis_tready_gen
        int del;
        m0_axis_tready = 0;
        while (s0_axi_aresetn == 0) begin
            @(negedge s0_axi_aclk);
        end
        #250;
        forever begin
            m0_axis_tready = $urandom_range(0, 1);
            del = $urandom_range(80, 800);
            #del;
        end
    end

endmodule
