module noc_intf (input clk, input rst, input noc_to_dev_ctl, input [7:0] noc_to_dev_data,
	output reg noc_from_dev_ctl, output reg [7:0] noc_from_dev_data,
    output reg pushin, output reg firstin, input stopin, output reg [63:0] din,
    input pushout, input firstout, output reg stopout, input [63:0] dout);

	enum reg [3:0] {Idle, Get_Read, Get_Write, Read_Resp, Write_Resp} current_state = Idle, next_state = Idle;

	//State Machine Buffer
	reg noc_from_dev_ctl_d, pushin_d, firstin_d, stopout_d;
	reg [7:0] noc_from_dev_data_d;
	reg [63:0] din_d;

	//NOC Message Info
	reg [1:0] Alen;
	reg [3:0] Atimes_d, Atimes;
	reg [2:0] Dlen;
	reg [7:0] Dtimes_d, Dtimes;

	//Control Signal for Read/Write Command
	reg Get_DID, Get_SID;

	//NOC Dest and Src
	reg [7:0] Dest_ID, Src_ID;

	//Address of Read/Write Command
	reg [7:0][7:0] Addr;
	reg [2:0] Addr_pos_d, Addr_pos;

	//Read/Write Data
	union packed {
		reg [199:0][7:0] Dev;
		reg [24:0][63:0] Per;
	} data_in;
	reg [7:0] Din_pos_d, Din_pos;

	//Control Signal for Read/Write Response
	reg Send_SID, Send_data;
	reg [7:0] Actual_data_d, Actual_data;
	reg [7:0] Resp_data;

	always @(posedge clk or posedge rst) begin
		case(current_state)
			Idle: begin
				noc_from_dev_ctl_d = 1;
				noc_from_dev_data_d = 0;
				pushin_d = 0;
				firstin_d = 0;
				stopout_d = 1;
				din_d = 0;
				Alen = noc_to_dev_data[7:6];
				Dlen = noc_to_dev_data[5:3];

				Get_DID = 0;
				Get_SID = 0;
				if(noc_to_dev_ctl) begin
					case(noc_to_dev_data[2:0])
						3'b000: next_state = Idle;
						3'b001: begin
							Dtimes_d = 0;
							Atimes_d = 0;
							Addr_pos_d = 0;
							Actual_data_d = 0;
							Get_DID = 1;
							Get_SID = 0;
							Send_SID = 0;
							Send_data = 0;
							next_state = Get_Read;
						end
						3'b010: begin
							Dtimes_d = 0;
							Atimes_d = 0;
							Addr_pos_d = 0;
							Actual_data_d = 0;
							Get_DID = 1;
							Get_SID = 0;
							Send_SID = 0;
							Send_data = 0;
							next_state = Get_Write;
						end
						default: begin
							$display("Wrong CMD %b @ %t", noc_to_dev_data, $time());
							next_state = Idle;
						end
					endcase
				end
			end
			Get_Read: begin
				// It is important that execution order is bottom top
				next_state = Idle;
			end
			Get_Write: begin
				if(noc_to_dev_ctl) begin
					$display("ctlprb %b, indata %b @ %t", noc_to_dev_ctl, noc_to_dev_data, $time());
					next_state = Idle;
				end
				if(stopin) begin
					next_state = Write_Resp;
					noc_from_dev_ctl_d = 1;
					noc_from_dev_data_d = 
					Resp_data = 8'h02;
				end
				if(Dtimes == 1) begin
					$display("Write_Done!");
					Dtimes_d = 0;
					data_in.Dev[Din_pos] = noc_to_dev_data;
					Din_pos_d = Din_pos+1;
					next_state = Write_Resp;

					noc_from_dev_ctl_d = 1;
					noc_from_dev_data_d = 8'b00000100;
					Resp_data = Actual_data+1;
				end
				if(Dtimes > 1) begin//Still need to handle Din_pos > 199
					Dtimes_d = Dtimes-1;
					data_in.Dev[Din_pos] = noc_to_dev_data;
					Din_pos_d = Din_pos+1;
					Actual_data_d = Actual_data+1;
					next_state = Get_Write;
				end
				if(Atimes) begin
					Atimes_d = Atimes-1;
					case (Dlen)
						3'b000: Dtimes_d = 1;
						3'b001: Dtimes_d = 2;
						3'b010: Dtimes_d = 4;
						3'b011: Dtimes_d = 8;
						3'b100: Dtimes_d = 16;
						3'b101: Dtimes_d = 32;
						3'b110: Dtimes_d = 64;
						3'b111: Dtimes_d = 128;
						default: Dtimes_d = 0;
					endcase
					$display("Addr is %h, indata is %h", Addr, noc_to_dev_data);
					Addr[Addr_pos] = noc_to_dev_data;
					$display("Addr is %h", Addr);
					Addr_pos_d = Addr_pos+1;
					next_state = Get_Write;
				end
				if(Get_SID) begin
					Addr_pos_d = 0;
					case (Alen)
						2'b00: Atimes_d = 1;
						2'b01: Atimes_d = 2;
						2'b10: Atimes_d = 4;
						2'b11: Atimes_d = 8;
						default: Atimes_d = 0;
					endcase
					Get_SID = 0;
					Src_ID = noc_to_dev_data;
					next_state = Get_Write;
				end
				if(Get_DID) begin
					Get_DID = 0;
					Get_SID = 1;
					Dest_ID = noc_to_dev_data;
					next_state = Get_Write;
				end
			end
			Read_Resp: begin
			end
			Write_Resp: begin
				if(Send_data) begin
					Send_data = 0;
					noc_from_dev_data_d = Resp_data;
					next_state = Idle;
				end
				if(Send_SID) begin
					Send_SID = 0;
					Send_data = 1;
					noc_from_dev_data_d = Dest_ID;
					next_state = Write_Resp;
				end
				if(noc_from_dev_ctl) begin
					Send_SID = 1;
					noc_from_dev_ctl_d = 0;
					noc_from_dev_data_d = Src_ID;
					next_state = Write_Resp;
				end
			end
		endcase
	end

	always @(posedge clk or posedge rst) begin
		if(noc_to_dev_data) $display("inctl %b, indata %b @ %t", noc_to_dev_ctl, noc_to_dev_data, $time());
		if(rst) begin
			current_state = Idle;
			next_state = Idle;
			noc_from_dev_ctl = 1;
			noc_from_dev_data = 0;
			pushin = 0;
			firstin = 0;
			stopout = 1;
			din = 0;

			Get_DID = 0;
			Get_SID = 0;
			Alen = 0;
			Atimes = 0;
			Dlen = 0;
			Dtimes = 0;
			Addr_pos = 0;
			Din_pos = 0;
			Actual_data = 0;
		end else begin
			current_state = next_state;
			noc_from_dev_ctl = noc_from_dev_ctl_d;
			noc_from_dev_data = noc_from_dev_data_d;
			pushin = pushin_d;
			firstin = firstin_d;
			stopout = stopout_d;
			din = din_d;

			Atimes = Atimes_d;
			Dtimes = Dtimes_d;
			Addr_pos = Addr_pos_d;
			Din_pos = Din_pos_d;
			Actual_data = Actual_data_d;
		end
	end

endmodule : noc_intf