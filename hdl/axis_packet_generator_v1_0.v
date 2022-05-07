
`timescale 1 ns / 1 ps

	module axis_packet_generator_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S0_AXI
		parameter integer C_S0_AXI_DATA_WIDTH	= 32,
		parameter integer C_S0_AXI_ADDR_WIDTH	= 5,

		// Parameters of Axi Master Bus Interface M0_AXIS
		parameter integer C_M0_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S0_AXI
		input wire  s0_axi_aclk,
		input wire  s0_axi_aresetn,
		input wire [C_S0_AXI_ADDR_WIDTH-1 : 0] s0_axi_awaddr,
		input wire [2 : 0] s0_axi_awprot,
		input wire  s0_axi_awvalid,
		output wire  s0_axi_awready,
		input wire [C_S0_AXI_DATA_WIDTH-1 : 0] s0_axi_wdata,
		input wire [(C_S0_AXI_DATA_WIDTH/8)-1 : 0] s0_axi_wstrb,
		input wire  s0_axi_wvalid,
		output wire  s0_axi_wready,
		output wire [1 : 0] s0_axi_bresp,
		output wire  s0_axi_bvalid,
		input wire  s0_axi_bready,
		input wire [C_S0_AXI_ADDR_WIDTH-1 : 0] s0_axi_araddr,
		input wire [2 : 0] s0_axi_arprot,
		input wire  s0_axi_arvalid,
		output wire  s0_axi_arready,
		output wire [C_S0_AXI_DATA_WIDTH-1 : 0] s0_axi_rdata,
		output wire [1 : 0] s0_axi_rresp,
		output wire  s0_axi_rvalid,
		input wire  s0_axi_rready,

		// Ports of Axi Master Bus Interface M0_AXIS
		input wire  m0_axis_aclk,
		input wire  m0_axis_aresetn,
		output wire  m0_axis_tvalid,
		output wire [C_M0_AXIS_TDATA_WIDTH-1 : 0] m0_axis_tdata,
		//output wire [(C_M0_AXIS_TDATA_WIDTH/8)-1 : 0] m0_axis_tstrb,
		output wire  m0_axis_tlast,
		input wire  m0_axis_tready
	);

	wire        start_packet_generator_d;
	wire [31:0] start_delay_d;
	wire [31:0] delay_between_packets_d;
	wire [31:0] packet_size_d;
	wire [31:0] packets_num_d;
	wire        packet_generator_complete_d;


// Instantiation of Axi Bus Interface S0_AXI
	axis_packet_generator_v1_0_S0_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S0_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S0_AXI_ADDR_WIDTH)
	) axis_packet_generator_v1_0_S0_AXI_inst (
		.S_AXI_ACLK(s0_axi_aclk),
		.S_AXI_ARESETN(s0_axi_aresetn),
		.S_AXI_AWADDR(s0_axi_awaddr),
		.S_AXI_AWPROT(s0_axi_awprot),
		.S_AXI_AWVALID(s0_axi_awvalid),
		.S_AXI_AWREADY(s0_axi_awready),
		.S_AXI_WDATA(s0_axi_wdata),
		.S_AXI_WSTRB(s0_axi_wstrb),
		.S_AXI_WVALID(s0_axi_wvalid),
		.S_AXI_WREADY(s0_axi_wready),
		.S_AXI_BRESP(s0_axi_bresp),
		.S_AXI_BVALID(s0_axi_bvalid),
		.S_AXI_BREADY(s0_axi_bready),
		.S_AXI_ARADDR(s0_axi_araddr),
		.S_AXI_ARPROT(s0_axi_arprot),
		.S_AXI_ARVALID(s0_axi_arvalid),
		.S_AXI_ARREADY(s0_axi_arready),
		.S_AXI_RDATA(s0_axi_rdata),
		.S_AXI_RRESP(s0_axi_rresp),
		.S_AXI_RVALID(s0_axi_rvalid),
		.S_AXI_RREADY(s0_axi_rready),

		.start_packet_generator_o(start_packet_generator_d),
		.start_delay_o(start_delay_d),
		.delay_between_packets_o(delay_between_packets_d),
		.packet_size_o(packet_size_d),
		.packets_num_o(packets_num_d),
		.packet_generator_complete_i(packet_generator_complete_d)
	);

// Instantiation of Axi Bus Interface M0_AXIS
	axis_packet_generator_v1_0_M0_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M0_AXIS_TDATA_WIDTH)
	) axis_packet_generator_v1_0_M0_AXIS_inst (
		.M_AXIS_ACLK(m0_axis_aclk),
		.M_AXIS_ARESETN(m0_axis_aresetn),
		.M_AXIS_TVALID(m0_axis_tvalid),
		.M_AXIS_TDATA(m0_axis_tdata),
		// .M_AXIS_TSTRB(m0_axis_tstrb),
		.M_AXIS_TLAST(m0_axis_tlast),
		.M_AXIS_TREADY(m0_axis_tready),

		.start_packet_generator_i(start_packet_generator_d),
		.start_delay_i(start_delay_d),
		.delay_between_packets_i(delay_between_packets_d),
		.packet_size_i(packet_size_d),
		.packets_num_i(packets_num_d),
		.packet_generator_complete_o(packet_generator_complete_d)
	);

	// Add user logic here

	// User logic ends

	endmodule
