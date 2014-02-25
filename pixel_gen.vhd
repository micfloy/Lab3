----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:29:56 01/29/2014 
-- Design Name: 
-- Module Name:    pixel_gen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_gen is

    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
           ball_x   : in unsigned(10 downto 0);
			  ball_y   : in unsigned(10 downto 0);
           paddle_y : in unsigned(10 downto 0);
           r,g,b        : out std_logic_vector(7 downto 0));
end pixel_gen;

architecture sel_arch of pixel_gen is

constant  PADDLE_W : integer := 10;
constant  PADDLE_H : integer := 60;
constant  BALL_R   : integer := 5;

begin
	process(blank, column, row, paddle_y,ball_x,ball_y)
	begin
		r <= (others => '0');
		g <= (others => '0');
		b <= (others => '0');
		
		if (blank = '0') then
		
		
			-- Draws the ball and paddle
			
			-- Paddle
			if ((column < PADDLE_W + 5) and (column > 5)) and (row <= paddle_y + PADDLE_H) and (row >= paddle_y) then
				r <= (others => '1');
			end if;
			
			-- Ball
			if ((column >= ball_x) and (column <= ball_x + BALL_R)) and ((row >= ball_y) and (row <= ball_y + BALL_R)) then
				r <= (others => '1');
			end if;
			
			
			
			-- Draws the AF logo
			if ((column >= 195) and (column <= 265)) then
			
				if (row >= 120) and (row < 150) then
					b <= (others => '1');
					r <= (others => '0');
				end if;
				
				if (row >= 210) and (row <= 240) then
					b <= (others => '1');
					r <= (others => '0');
				end if;
				
			end if;
			
			if (((column >= 160) and (column < 195)) or ((column >= 265) and (column <= 300))) and ((row >= 120) and (row <= 360)) then
				b <= (others => '1');
				r <= (others => '0');
			end if;
			
			if ((column >= 340) and (column <= 375)) and ((row >= 120) and (row <= 360)) then
				b <= (others => '1');
				r <= (others => '0');
			end if;
			
			if ((row >= 120) and (row <= 150)) and ((column >= 340) and (column <= 480)) then
				b <= (others => '1');
				r <= (others => '0');
			end if;
			
			if ((row >= 210) and (row <= 240)) and ((column >= 340) and (column <= 445)) then
				b <= (others => '1');
				r <= (others => '0');
			end if;	
			
		end if;
		
	end process;

end sel_arch;