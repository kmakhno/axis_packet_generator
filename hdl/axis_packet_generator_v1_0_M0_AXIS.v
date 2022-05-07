
`timescale 1 ns / 1 ps

	module axis_packet_generator_v1_0_M0_AXIS #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
		input        start_packet_generator_i,
		input [31:0] start_delay_i,
		input [31:0] delay_between_packets_i,
		input [31:0] packet_size_i,
		input [31:0] packets_num_i,
		output       packet_generator_complete_o,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global ports
		input wire  M_AXIS_ACLK,
		// 
		input wire  M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		output wire  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		// output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire  M_AXIS_TREADY
	);

	localparam [1:0] IDLE = 2'b00,
					 D0   = 2'b01,
					 P0   = 2'b10,
					 D1   = 2'b11;

	wire start_packet_generator_strobe_d;

	reg [1:0]  state_q;
	reg [31:0] start_delay_cnt_q;
	reg [31:0] packet_num_cnt_q;
	reg [31:0] delay_between_packets_cnt_q;
	reg [31:0] clk_cnt_q;
	reg [31:0] data_gen_q;
	reg [1:0]  start_packet_generator_sync_q;
	reg        packet_generator_complete_q;

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN)
			start_packet_generator_sync_q <= 2'b00;
		else
			start_packet_generator_sync_q <= {start_packet_generator_sync_q[0], start_packet_generator_i};
	end

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN)
			start_delay_cnt_q <= 0;
		else if (state_q == D0) begin
			start_delay_cnt_q <= start_delay_cnt_q + 1'b1;
			if (start_delay_cnt_q == start_delay_i-1) begin
				start_delay_cnt_q <= 0;
			end
		end else
			start_delay_cnt_q <= 0;
	end

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN)
			delay_between_packets_cnt_q <= 0;
		else if (state_q == D1) begin
			delay_between_packets_cnt_q <= delay_between_packets_cnt_q + 1'b1;
			if (delay_between_packets_cnt_q == delay_between_packets_i-1) begin
				delay_between_packets_cnt_q <= 0;
			end
		end else
			delay_between_packets_cnt_q <= 0;
	end

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN)
			clk_cnt_q <= 0;
		else if (state_q == P0) begin
			if (M_AXIS_TREADY)
				clk_cnt_q <= clk_cnt_q + 1;

			if (clk_cnt_q == packet_size_i-1)
				clk_cnt_q <= 0;
		end
	end

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN)
			data_gen_q <= 0;
		else if (state_q == IDLE)
			data_gen_q <= 0;
		else if (state_q == P0 && M_AXIS_TREADY)
			data_gen_q <= data_gen_q + 1'b1;
	end

	always @(posedge M_AXIS_ACLK) begin
		if (!M_AXIS_ARESETN) begin
			state_q <= IDLE;
			packet_generator_complete_q <= 1'b0;
			packet_num_cnt_q <= 0;
		end else begin
			case (state_q)
				IDLE: begin
					packet_generator_complete_q <= 1'b0;
					packet_num_cnt_q <= 0;
					if (start_packet_generator_strobe_d)
						state_q <= D0;
				end

				D0: begin
					if ((start_delay_cnt_q == start_delay_i-1) || (start_delay_i == 0))
						state_q <= P0;
				end

				P0: begin
					if (M_AXIS_TLAST) begin
						packet_num_cnt_q <= packet_num_cnt_q + 1'b1;
						state_q <= D1;
					end
				end

				D1: begin
					if (packet_num_cnt_q == packets_num_i) begin
						packet_generator_complete_q <= 1'b1;
						state_q <= IDLE;
					end else begin
						if ((delay_between_packets_cnt_q == delay_between_packets_i-1) || (delay_between_packets_i == 0)) begin
							state_q <= P0;
						end
					end
				end
			endcase
		end
	end

	assign start_packet_generator_strobe_d = (start_packet_generator_sync_q == 2'b01);
	assign packet_generator_complete_o = packet_generator_complete_q;
	assign M_AXIS_TVALID = (state_q == P0);
	assign M_AXIS_TLAST = (clk_cnt_q == packet_size_i-1);
	assign M_AXIS_TDATA = data_gen_q;

	endmodule
