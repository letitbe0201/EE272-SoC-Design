//`include "m55.sv"
module perm_blk (
	input clk,
	input rst,
	input pushin,
	output reg stopin,
	input firstin,
	input [63:0] din,
	output reg [2:0] m1rx,
	output reg [2:0] m1ry,
	input [63:0] m1rd,
	output reg [2:0] m1wx,
	output reg [2:0] m1wy,
	output reg m1wr,
	output reg [63:0] m1wd,
	output reg [2:0] m2rx,
	output reg [2:0] m2ry,
	input [63:0] m2rd,
	output reg [2:0] m2wx,
	output reg [2:0] m2wy,
	output reg m2wr,
	output reg [63:0] m2wd,
	output reg [2:0] m3rx,
	output reg [2:0] m3ry,
	input [63:0] m3rd,
	output reg [2:0] m3wx,
	output reg [2:0] m3wy,
	output reg m3wr,
	output reg [63:0] m3wd,
	output reg [2:0] m4rx,
	output reg [2:0] m4ry,
	input [63:0] m4rd,
	output reg [2:0] m4wx,
	output reg [2:0] m4wy,
	output reg m4wr,
	output reg [63:0] m4wd,
	output reg pushout,
	input stopout,
	output reg firstout,
	output reg [63:0] dout);
	
	reg vstopin, vstopin_d, vpushout, vpushout_d, vfirstout, vfirstout_d;
	reg [63:0] vdout, vdout_d, vm1wd, vm1wd_d, vm2wd, vm2wd_d, vm3wd, vm3wd_d, vm4wd, vm4wd_d;
	reg [2:0] vm1rx, vm1rx_d, vm1ry, vm1ry_d, vm1wx, vm1wx_d, vm1wy, vm1wy_d, vm1wr, vm1wr_d, vm2rx, vm2rx_d, vm2ry, vm2ry_d, vm2wx, vm2wx_d, vm2wy, vm2wy_d, vm2wr, vm2wr_d, vm3rx, vm3rx_d, vm3ry, vm3ry_d, vm3wx, vm3wx_d, vm3wy, vm3wy_d, vm3wr, vm3wr_d, vm4rx, vm4rx_d, vm4ry, vm4ry_d, vm4wx, vm4wx_d, vm4wy, vm4wy_d, vm4wr, vm4wr_d;

	enum reg [3:0] {
		IDLE,
		DATA_IN,
		THETA,
		RHO,
		PI,
		CHI,
		IOTA,
		DATA_OUT
	} current_state, next_state;

	m55 in_buffer (clk, rst, m1rx, m1ry, m1rd, m1wx, m1wy, m1wr, m1wd);
	m55 out_buffer (clk, rst, m2rx, m2ry, m2rd, m2wx, m2wy, m2wr, m2wd);
	m55 work_mem1 (clk, rst, m3rx, m3ry, m3rd, m3wx, m3wy, m3wr, m3wd);
	m55 work_mem2 (clk, rst, m4rx, m4ry, m4rd, m4wx, m4wy, m4wr, m4wd);

	always @ (*) begin
		next_state = current_state;
		vstopin_d = vstopin;
		vpushout_d = vpushout;
		vfirstout_d = vfirstout;
		vdout_d = vdout;	
		vm1wx_d = vm1wx;
		vm1wy_d = vm1wy;
		vm1wr_d = vm1wr;
		vm1wd_d = vm1wd;
		vm1rx_d = vm1rx;
		vm1ry_d = vm1ry;
		stopin = vstopin;
		pushout = vpushout;
		firstout = vfirstout;
		dout = vdout;
		m1wx = vm1wx;
		m1wy = vm1wy;
		m1wr = vm1wr;
		m1wd = vm1wd;
		m1rx = vm1rx;
		m1ry = vm1ry;
		case (current_state)
			IDLE: begin
				if (pushin && firstin) begin
					vm1wx_d = 3'b000;
					vm1wy_d = 3'b000;
					vm1wr_d = 1;
					vm1wd_d = din; // WRITE DATA TO INPUT BUFFER
					next_state = DATA_IN;
				end
				else begin
					next_state = IDLE;
				end
			end
			DATA_IN: begin
				if (pushin) begin
					vm1wx_d = vm1wx + 3'b001;
					if (vm1wx_d == 3'b101) begin
						vm1wy_d = vm1wy + 3'b001;
						if (vm1wy_d == 3'b101) begin
							vm1wr_d = 0;
							vstopin_d = 1; // STOP THE INPUT STREAM
							next_state = THETA;
						end
						else begin
							vm1wx_d = 3'b000;
							vm1wr_d = 1;
							vm1wd_d = din;
						end
					end
					else begin
						vm1wr_d = 1;
						vm1wd_d = din;
					end
				end
			end
			THETA: begin
				$display("%b %b %b", m1rx, m1ry, m1rd);
				vm1rx_d = vm1rx + 3'b001;
				if (vm1rx == 3'b100) begin
					vm1ry_d = vm1ry + 3'b001;
					if (m1ry == 3'b100) begin
						vm1rx_d = 0;
						vm1ry_d = 0;
						next_state = RHO;
					end
					else begin
						vm1rx_d = 3'b000;
					end
				end
//				else begin
//					next_state = THETA;
//				end	
			end
			RHO: begin
				next_state = PI;
			end
			PI: begin
				next_state = CHI;
			end
			CHI: begin
				next_state = IOTA;
			end
			IOTA: begin
				next_state = DATA_OUT;
			end
			DATA_OUT: begin
				vstopin_d = 0;
				next_state = IDLE;
			end
			default:
				$display("STATE MACHINE ERROR AT %b %b | %t", current_state, next_state, $time);
		endcase
	end

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			current_state <= IDLE;
			vstopin <= 0;
			vpushout <= 64'b0;
			vfirstout <= 0;
			vdout <= 0;
			vm1wx <= 0;
			vm1wy <= 0;
			vm1wr <= 0;
			vm1wd <= 0;
			vm1rx <= 0;
			vm1ry <= 0;
		end
		else begin
			current_state <= #1 next_state;
			vstopin <= #1 vstopin_d;
			vpushout <= #1 vpushout_d;
			vfirstout <= #1 vfirstout_d;
			vdout <= #1 vdout_d;
			vm1wx <= #1 vm1wx_d;
			vm1wy <= #1 vm1wy_d;
			vm1wr <= #1 vm1wr_d;
			vm1wd <= #1 vm1wd_d;
			vm1rx <= #1 vm1rx_d;
			vm1ry <= #1 vm1ry_d;
		end
	end

endmodule : perm_blk
