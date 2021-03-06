----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:55:30 02/21/2014 
-- Design Name: 
-- Module Name:    input_to_pulse - Behavioral 
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

entity input_to_pulse is
    port ( clk          : in std_logic;
           reset        : in std_logic;
           input        : in std_logic;
           pulse        : out std_logic
         );
end input_to_pulse;

architecture moore of input_to_pulse is

	type button_state is
	(idle, button_pushed, button_held);
	
	signal button_reg, button_next : button_state;
	
	signal count : unsigned(12 downto 0);
	
	signal pulse_reg, pulse_next, button_old, button_new, button_debounced : std_logic;

begin


	-- shift register
	process(clk,reset,input)
	begin
		if( reset = '1') then
			button_old <= '0';
		elsif(rising_edge(clk)) then
			button_old <= input;
		end if;
	end process;
	
	process(clk,reset,button_old)
	begin
		
		if( reset = '1') then
			count <= (others => '0');
			button_new <= '0';			
		elsif( rising_edge(clk)) then
		
			button_debounced <= '0';
			
			if(button_new = button_old) then
				count <= count + 1;
			else
				button_new <= button_old;
				count <= (others => '0');
			end if;
			
			if( count >= 1000 ) then
				button_debounced <= '1';
				count <= (others => '0');
			end if;
		end if;
		
	end process;




	-- button state register
	process(clk,reset)
	begin
		if( reset = '1') then
			button_reg <= idle;
		elsif (rising_edge(clk)) then
			button_reg <= button_next;
		end if;
	end process;
	
	process(button_reg,input,button_debounced)
	begin
		button_next <= button_reg;
		
		case button_reg is
			when  idle =>
				if(input = '1') then
					button_next <= button_pushed;
				end if;
			when button_pushed =>
				button_next <= button_held;
			when button_held =>
				if(input = '0' and button_debounced = '1') then
					button_next <= idle;
				end if;
		end case;
					
	end process;
	
	process (clk, reset)
	begin
		if(reset = '1') then
			pulse_reg <= '0';
		elsif(rising_edge(clk)) then
			pulse_reg <= pulse_next;
		end if;
	end process;	
	
	pulse_next <= 	'1' when button_next = button_pushed else
						'0';

	pulse <= pulse_reg;

end moore;

