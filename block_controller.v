`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block1;
	wire block2;
	wire block3;
	wire block4;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos, x2, x3, x4, y2, y3, y4;
	reg [3:0] pause;
	// checks if you can go right, left, spin(down), spin(up), or drop
	reg [1:0] xR, xL, xD, xU, xBtm;
	
	//playing bounds
	// 34 - 514
	parameter top = 64;
	parameter btm = 444;
	// 150 - 800
	parameter Lside = 375;
	parameter Rside = 575;
	
	parameter speed = 4;
	
	parameter RED = 12'b1111_0000_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
		///*TODO1*/if(~bright||vCount==top||vCount==btm||hCount==Lside||hCount==Rside)	//force black if not inside the display area	
    	if(~bright||rEdge||lEdge||tEdge||bEdge)	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block1||block2||block3||block4) 
			rgb = RED; 
		else	
			rgb=background;
	end
	
	//the +-10 for the positions give the dimension of the block (i.e. it will be 20x20 pixels)
	assign block1=vCount>=(ypos-10) && vCount<=(ypos+10) && hCount>=(xpos-10) && hCount<=(xpos+10);
	assign block2=vCount>=(ypos-10+y2) && vCount<=(ypos+10+y2) && hCount>=(xpos-10+x2) && hCount<=(xpos+10+x2);
	assign block3=vCount>=(ypos-10+y3) && vCount<=(ypos+10+y3) && hCount>=(xpos-10+x3) && hCount<=(xpos+10+x3);
	assign block4=vCount>=(ypos-10+y4) && vCount<=(ypos+10+y4) && hCount>=(xpos-10+x4) && hCount<=(xpos+10+x4);
	
	//TODO1
	assign rEdge=vCount==(top-10)
	assign lEdge=hCount==(Lside-10)
	assign tEdge=vCount==(btm+10)
	assign bEdge=hCount==(Rside+10)
	//TODO1
	
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for top center of screen
			xpos<=475;
			ypos<=top;
			// test with one block style
			x2 <= 20;
			x3 <= 0;
			x4 <= 0;
			y2 <= 0;
			y3 <= 20;
			y4 <= 40;
			// TODO: RESET BOARD ARRAY
		end
		else begin
			case(state)
				MOVE:
					/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
					synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
					the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
					the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
					corresponds to ~(783,515).  
					*/
					if(right) begin
					///*TODO2*/if(right && xR) begin
						if(~(xpos==Rside)) //these are rough values to attempt to not cross bounds
							xpos<=xpos+10; //change the amount you increment to make the speed faster 
					end
					else if(left) begin
					///*TODO2*/else if(left && xL) begin
						if(~(xpos==Lside))
							xpos<=xpos-10;
					end
					else if(down) begin	// rotates the block clockwise
					///*TODO2*/else if(down && xD) begin	// rotates the block clockwise
						y2 <= -x2;
						y3 <= -x3;
						y4 <= -x4;
						x2 <= y2;
						x3 <= y3;
						x4 <= y4;			
					end
					else if(up)begin	// rotates the block counter-clockwise
					///*TODO2*/else if(up && xU)begin	// rotates the block counter-clockwise
						y2 <= x2;
						y3 <= x3;
						y4 <= x4;
						x2 <= -y2;
						x3 <= -y3;
						x4 <= -y4;			
					end
					// goes down at speed determined by "speed" using pause as a counter
					if(pause == speed) begin
						if(xBtm) begin
							ypos<=ypos+20;
						end
						pause <= 0;
					end
					pause <= pause + 1;
					state <= CHECK;
				CHECK:
					if()	//TODO: the block isn't at the bottom
						state <= MOVE;
					else
						state <= NEW_BLOCK;
				NEW_BLOCK:
					// TODO: make old block part of board array
					// put new block at top
					//rough values for top center of screen
					xpos<=475;
					ypos<=top;
					// TODO: choose random number in very beginning, and generate new random number here and determine block type by the number
					x2 <= 20;
					x3 <= 0;
					x4 <= 0;
					y2 <= 0;
					y3 <= 20;
					y4 <= 40;
					if()	//TODO board array doesn't reach top
						state <= MOVE;
					else
						state <= END;
				END:
					// display end
				default:	state <= END;
			endcase
		
			
			
		end
	end
	
	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b1111_1111_1111;
		else 
			if(right)
				background <= 12'b1111_1111_0000;
			else if(left)
				background <= 12'b0000_1111_1111;
			else if(down)
				background <= 12'b0000_1111_0000;
			else if(up)
				background <= 12'b0000_0000_1111;
	end

	
	
endmodule
