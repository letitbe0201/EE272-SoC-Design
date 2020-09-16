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
	reg [4:0][63:0] theta_c = 0;
	reg buf_cnt = 0;

	enum reg [3:0] {
		IDLE,
		DATA_IN,
		THETA_C,
		BUFFER_1,
//		BUFFER_2,
		THETA_D,
		RHO,
		PI,
		CHI,
		IOTA,
		DATA_OUT
	} current_state, next_state;

/*	m55 in_buffer (clk, rst, m1rx, m1ry, m1rd, m1wx, m1wy, m1wr, m1wd);
	m55 out_buffer (clk, rst, m2rx, m2ry, m2rd, m2wx, m2wy, m2wr, m2wd);
	m55 work_mem1 (clk, rst, m3rx, m3ry, m3rd, m3wx, m3wy, m3wr, m3wd);
	m55 work_mem2 (clk, rst, m4rx, m4ry, m4rd, m4wx, m4wy, m4wr, m4wd);
*/
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
		vm2wx_d = vm2wx;
		vm2wy_d = vm2wy;
		vm2wr_d = vm2wr;
		vm2wd_d = vm2wd;
		vm2rx_d = vm2rx;
		vm2ry_d = vm2ry;
		vm3wx_d = vm3wx;
		vm3wy_d = vm3wy;
		vm3wr_d = vm3wr;
		vm3wd_d = vm3wd;
		vm3rx_d = vm3rx;
		vm3ry_d = vm3ry;
		vm4wx_d = vm4wx;
		vm4wy_d = vm4wy;
		vm4wr_d = vm4wr;
		vm4wd_d = vm4wd;
		vm4rx_d = vm4rx;
		vm4ry_d = vm4ry;
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
		m2wx = vm2wx;
		m2wy = vm2wy;
		m2wr = vm2wr;
		m2wd = vm2wd;
		m2rx = vm2rx;
		m2ry = vm2ry;
		m3wx = vm3wx;
		m3wy = vm3wy;
		m3wr = vm3wr;
		m3wd = vm3wd;
		m3rx = vm3rx;
		m3ry = vm3ry;
		m4wx = vm4wx;
		m4wy = vm4wy;
		m4wr = vm4wr;
		m4wd = vm4wd;
		m4rx = vm4rx;
		m4ry = vm4ry;
//		$display("x:%b y:%b DATA:%h STOP:%b 1st:%b DIN:%h", m1wx, m1wy, m1wd, stopin, firstin, din);
		case (current_state)
			IDLE: begin
				if (pushin && firstin) begin
					vm1wx_d = 3'b000;
					vm1wy_d = 3'b000;
					vm1wr_d = 1;
					vm1wd_d = din; // WRITE DATA TO INPUT BUFFER
					vm2wr_d = 1;
					vm2wd_d = 0; // CLEANING DATA IN M2
					vm3wr_d = 1;
					vm3wd_d = 0; // CLEANING DATA IN M3
					next_state = DATA_IN;
				end
				else begin
					next_state = IDLE;
				end
//				$display("%b %h %h %b %b", firstin, din, m2wd, m2wx, m2wy);
			end
			DATA_IN: begin
				if (pushin) begin
					vm1wx_d = vm1wx + 3'b001;
					vm2wx_d = vm2wx + 3'b001;
					vm3wx_d = vm3wx + 3'b001;
					if (vm1wx == 3'b100) begin
						vm1wy_d = vm1wy + 3'b001;
						vm2wy_d = vm2wy + 3'b001;
						vm3wy_d = vm3wy + 3'b001;
						if (vm1wy == 3'b100) begin
							vm1wx_d = 0;
							vm1wy_d = 0;
							vm2wx_d = 0;
							vm2wy_d = 0;
							vm3wx_d = 0;
							vm3wy_d = 0;
							vm1wr_d = 0;
							vm2wr_d = 0;
							vm3wr_d = 0;
							vstopin_d = 1; 
							next_state = THETA_C;
						end
						else begin
							vm1wx_d = 3'b000;
							vm1wr_d = 1;
							vm1wd_d = din;
							vm2wx_d = 3'b000;
							vm2wr_d = 1;
							vm2wd_d = 64'b0;
							vm3wx_d = 3'b000;
							vm3wr_d = 1;
							vm3wd_d = 64'b0;
//							$display("%b %h %h %b %b", firstin, din, m2wd, m2wx, m2wy);
						end
					end
					else begin
						if (vm1wx==3'b010 && vm1wy==3'b100)  //STOP INPUT BEFORE 100/100
							vstopin_d = 1;
						vm1wr_d = 1;
						vm1wd_d = din;
						vm2wr_d = 1;
						vm2wd_d = 64'b0;
//						$display("%b %h %h %b %b", firstin, din, m2rd, m2wd, m2wy);
					end
				end
//				$display("%b %b %h", m2wx, m2wy, m2wd);
			end
			THETA_C: begin
//				$display("vm1rx %b | %b %b | %b %b%t", vm1rx, m2rx, m2ry, m1rx, m1ry, $time);
				$display("theta[%b] %h | vm2wd %h | x%b y%b m2rd %h | m1rd %h%t", vm1rx, theta_c[vm1rx], vm2wd_d, m2rx, m2ry, m2rd, m1rd, $time);
				if (vm1ry != 3'b100)
					theta_c[vm1rx] = m2rd ^ m1rd;
				vm2wr_d = 1;
				vm2wd_d = theta_c[vm1rx];
				next_state = BUFFER_1;
//				$display("m2rd%h m2rx%b m2ry%b m1rd%h m1rx%b m1ry%b", m2rd, m2rx, m2ry, m1rd, m1rx, m1ry);	
				vm1ry_d = vm1ry + 3'b001;
				if (vm1ry == 3'b100) begin
					vm2wd_d = 0;
					vm1ry_d = 0;
					vm1rx_d = vm1rx + 1;
					vm2rx_d = vm2rx + 1;
					vm2wx_d = vm2wx + 1;
					if (vm1rx == 3'b100) begin
						vm1rx_d = 0;
						vm1ry_d = 0;
						vm2wr_d = 0;
						vm2wx_d = 0;
						vm2rx_d = 0;
						next_state = THETA_D;
					end
				end
//				$display("vm2wd %h | m2rd %h | m1rd %h%t", vm2wd_d, m2rd, m1rd, $time);
			end
			BUFFER_1: begin
				next_state = THETA_C;
			end
/*			BUFFER_2: begin
					next_state = THETA_C;
			end
*/			THETA_D: begin
/*				$display("theta_c[%b] %h | m2rd %h%t", vm1rx, theta_c[vm1rx], m2rd, $time);
//				vm1rx_d = vm1rx + 1;
				vm2rx_d = vm2rx + 1;
				if (vm1rx==3'b101) begin
					vm1rx_d = 0;
					next_state = RHO;
				end
				$display("%b %b %b", vm1rx_d, m1rx, m1ry);
*/
				vm3wr_d = 1;
				case (vm1rx)
					3'b000: begin
						vm3wd_d = (theta_c[4] ^ {theta_c[1][62:0], theta_c[1][63]}) ^ m1rd;
					end
					3'b100: begin
						vm3wd_d = (theta_c[3] ^ {theta_c[0][62:0], theta_c[0][63]}) ^ m1rd;
					end
					default: begin
						vm3wd_d = (theta_c[vm1rx-1] ^ {theta_c[vm1rx+1][62:0], theta_c[vm1rx+1][63]}) ^ m1rd;
					end
				endcase
//				$display("vm3wd_d %h | m1rd %h x%b y%b", vm3wd_d, m1rd, m1rx, m1ry);
				// THETA ENDS
				case (vm1rx)
					0: begin
						case (vm1ry)
							0: begin
								vm2wd_d = vm3wd_d;
								vm3wx_d = 0;
								vm3wy_d = 0;
							end
							1: begin
								vm2wd_d = {vm3wd_d[27:0], vm3wd_d[63:28]};
								vm3wx_d = 1;
								vm3wy_d = 3;
							end
							2: begin
								vm2wd_d = {vm3wd_d[60:0], vm3wd_d[63:61]};
								vm3wx_d = 2;
								vm3wy_d = 1;
							end
							3: begin
								vm2wd_d = {vm3wd_d[22:0], vm3wd_d[63:23]};
								vm3wx_d = 3;
								vm3wy_d = 4;
							end
							4: begin
								vm2wd_d = {vm3wd_d[45:0], vm3wd_d[63:46]};
								vm3wx_d = 4;
								vm3wy_d = 2;
							end
							default: begin
								$display("CASE ERROR 1");
							end
						endcase
					end
					1: begin
						case (vm1ry)
							0: begin
								vm2wd_d = {vm3wd_d[62:0], vm3wd_d[63]};
								vm3wx_d = 0;
								vm3wy_d = 2;
							end
							1: begin
								vm2wd_d = {vm3wd_d[19:0], vm3wd_d[63:20]};
								vm3wx_d = 1;
								vm3wy_d = 0;
							end
							2: begin
								vm2wd_d = {vm3wd_d[53:0], vm3wd_d[63:54]};
								vm3wx_d = 2;
								vm3wy_d = 3;
							end
							3: begin
								vm2wd_d = {vm3wd_d[18:0], vm3wd_d[63:19]};
								vm3wx_d = 3;
								vm3wy_d = 1;
							end
							4: begin
								vm2wd_d = {vm3wd_d[61:0], vm3wd_d[63:62]};
								vm3wx_d = 4;
								vm3wy_d = 4;
							end
							default: begin
								$display("CASE ERROR 1");
							end
						endcase
					end
					2: begin
						case (vm1ry)
							0: begin
								vm2wd_d = {vm3wd_d[1:0], vm3wd_d[63:2]};
								vm3wx_d = 0;
								vm3wy_d = 4;
							end
							1: begin
								vm2wd_d = {vm3wd_d[57:0], vm3wd_d[63:58]};
								vm3wx_d = 1;
								vm3wy_d = 2;
							end
							2: begin
								vm2wd_d = {vm3wd_d[20:0], vm3wd_d[63:21]};
								vm3wx_d = 2;
								vm3wy_d = 0;
							end
							3: begin
								vm2wd_d = {vm3wd_d[48:0], vm3wd_d[63:49]};
								vm3wx_d = 3;
								vm3wy_d = 3;
							end
							4: begin
								vm2wd_d = {vm3wd_d[2:0], vm3wd_d[63:3]};
								vm3wx_d = 4;
								vm3wy_d = 1;
							end
							default: begin
								$display("CASE ERROR 1");
							end
						endcase
					end
					3: begin
						case (vm1ry)
							0: begin
								vm2wd_d = {vm3wd_d[35:0], vm3wd_d[63:36]};
								vm3wx_d = 0;
								vm3wy_d = 1;
							end
							1: begin
								vm2wd_d = {vm3wd_d[8:0], vm3wd_d[63:9]};
								vm3wx_d = 1;
								vm3wy_d = 4;
							end
							2: begin
								vm2wd_d = {vm3wd_d[38:0], vm3wd_d[63:39]};
								vm3wx_d = 2;
								vm3wy_d = 2;
							end
							3: begin
								vm2wd_d = {vm3wd_d[42:0], vm3wd_d[63:43]};
								vm3wx_d = 3;
								vm3wy_d = 0;
							end
							4: begin
								vm2wd_d = {vm3wd_d[7:0], vm3wd_d[63:8]};
								vm3wx_d = 4;
								vm3wy_d = 3;
							end
							default: begin
								$display("CASE ERROR 1");
							end
						endcase
					end
					4: begin
						case (vm1ry)
							0: begin
								vm2wd_d = {vm3wd_d[36:0], vm3wd_d[63:37]};
								vm3wx_d = 0;
								vm3wy_d = 3;
							end
							1: begin
								vm2wd_d = {vm3wd_d[43:0], vm3wd_d[63:44]};
								vm3wx_d = 1;
								vm3wy_d = 1;
							end
							2: begin
								vm2wd_d = {vm3wd_d[24:0], vm3wd_d[63:25]};
								vm3wx_d = 2;
								vm3wy_d = 4;
							end
							3: begin
								vm2wd_d = {vm3wd_d[55:0], vm3wd_d[63:56]};
								vm3wx_d = 3;
								vm3wy_d = 2;
							end
							4: begin
								vm2wd_d = {vm3wd_d[49:0], vm3wd_d[63:50]};
								vm3wx_d = 4;
								vm3wy_d = 0;
							end
							default: begin
								$display("CASE ERROR 1");
							end
						endcase
					end
					default: begin
						$display("CASE ERROR 2");
					end
				endcase
				vm3wd_d = vm2wd_d;
//				$display("%b %b %h%t", vm3wx_d, vm3wy_d, vm3wd_d, $time);

				vm1ry_d = vm1ry + 3'b001;
				if (vm1ry == 3'b100) begin
					vm1rx_d = vm1rx + 1;
					vm1ry_d = 0;
					if (vm1rx == 3'b100) begin
						vm1rx_d = 0;
						vm1ry_d = 0;
						
						next_state = RHO;
					end
				end
			end
			RHO: begin
				vm3wx_d = 0;
				vm3wy_d = 0;
				vm3wr_d = 0;
				$display("x%b y%b | %h%t", m3rx, m3ry, m3rd, $time);
				vm3ry_d = vm3ry + 1;
				if (vm3ry == 3'b100) begin
					vm3ry_d = 0;
					vm3rx_d = vm3rx + 1;
					if (vm3rx == 3'b100) begin
						vm3rx_d = 0;
						vm3ry_d = 0;
						next_state = PI;
					end
				end
			end
			PI: begin
				next_state = PI;
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
			vm2wx <= 0;
			vm2wy <= 0;
			vm2wr <= 0;
			vm2wd <= 0;
			vm2rx <= 0;
			vm2ry <= 0;
			vm3wx <= 0;
			vm3wy <= 0;
			vm3wr <= 0;
			vm3wd <= 0;
			vm3rx <= 0;
			vm3ry <= 0;
			vm4wx <= 0;
			vm4wy <= 0;
			vm4wr <= 0;
			vm4wd <= 0;
			vm4rx <= 0;
			vm4ry <= 0;
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
			vm2wx <= #1 vm2wx_d;
			vm2wy <= #1 vm2wy_d;
			vm2wr <= #1 vm2wr_d;
			vm2wd <= #1 vm2wd_d;
			vm2rx <= #1 vm2rx_d;
			vm2ry <= #1 vm2ry_d;
			vm3wx <= #1 vm3wx_d;
			vm3wy <= #1 vm3wy_d;
			vm3wr <= #1 vm3wr_d;
			vm3wd <= #1 vm3wd_d;
			vm3rx <= #1 vm3rx_d;
			vm3ry <= #1 vm3ry_d;
			vm4wx <= #1 vm4wx_d;
			vm4wy <= #1 vm4wy_d;
			vm4wr <= #1 vm4wr_d;
			vm4wd <= #1 vm4wd_d;
			vm4rx <= #1 vm4rx_d;
			vm4ry <= #1 vm4ry_d;
		end
	end

endmodule : perm_blk
