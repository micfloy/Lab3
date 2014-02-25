----------------------------------------------------------------------------------
-- Company: 
-- Engineer: C2C Michael Bentley
-- 
-- Create Date:    10:27:27 01/29/2014 
-- Design Name: 
-- Module Name:    h_sync_gen - Behavioral 
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

entity h_sync_gen is
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           h_sync    : out std_logic;
           blank     : out std_logic;
           completed : out std_logic;
           column    : out unsigned(10 downto 0)
     );
end h_sync_gen;


architecture moore of h_sync_gen is
	type h_sync_state is
		(a_video, f_porch, sync_pulse, b_porch, completed_state);
	signal state_reg, state_next : h_sync_state;	
	
	signal count_reg, column_buf_reg : unsigned(10 downto 0);
	signal count_next, column_next : unsigned(10 downto 0);
	
	signal h_sync_buf_reg, blank_buf_reg, completed_buf_reg : std_logic;
	signal h_sync_next, blank_next, completed_next : std_logic;
	
begin

	-- state register
	process (clk, reset)
   begin
      if reset = '1' then
         state_reg <= a_video;
      elsif rising_edge(clk) then
         state_reg <= state_next;
      end if;
   end process;
	
	-- count register
	process(clk, reset)
	begin
		if(reset='1') then
			count_reg <= (others => '0');
		elsif rising_edge(clk) then
			count_reg <= count_next;
		end if;
	end process;
	
	-- output buffer
	process(clk, reset)
	begin
		if (reset='1') then
			h_sync_buf_reg <= '0';
			blank_buf_reg <= '0';
			completed_buf_reg <= '0';
			column_buf_reg <= (others => '0');
		elsif rising_edge(clk) then
			h_sync_buf_reg <= h_sync_next;
			blank_buf_reg <= blank_next;
			completed_buf_reg <= completed_next;
			column_buf_reg <= column_next;
		end if;
	end process;
	
	count_next <= (others => '0') when state_reg /= state_next else
						count_reg + 1;
	
	-- next-state logic
	process(state_reg, count_reg)
	begin
	
		state_next <= state_reg;
		
		case state_reg is
			when a_video =>
				if count_reg = (640 - 1) then
					state_next <= f_porch;
				end if;
			when f_porch =>
				if count_reg = (16 - 1) then
					state_next <= sync_pulse;
				end if;
			when sync_pulse =>
				if count_reg = (96 - 1) then
					state_next <= b_porch;
				end if;
			when b_porch =>
				if count_reg = (47 - 1) then
					state_next <= completed_state;
				end if;
			when completed_state =>
					state_next <= a_video;
		end case;
	end process;
		
	-- look-ahead output logic
	process(state_next, count_next)
	begin
		h_sync_next <= '0';
		blank_next <= '0';
		completed_next <= '0';
		column_next <= (others => '0');
		case state_next is
		
			when a_video =>
				h_sync_next <= '1';
				column_next <= count_next;
				
			when f_porch =>
				h_sync_next <= '1';
				blank_next <= '1';
			when sync_pulse =>
				blank_next <= '1';

	
			when b_porch =>
				h_sync_next <= '1';
				blank_next <= '1';

				
			when completed_state =>
				h_sync_next <= '1';
				blank_next <= '1';
				completed_next <= '1';

		end case;
	end process;
					
	-- Outputs 				
	h_sync <= h_sync_buf_reg;
	blank <= blank_buf_reg;
	completed <= completed_buf_reg;
	column <= column_buf_reg;

end moore;
