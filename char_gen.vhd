----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:52:36 02/21/2014 
-- Design Name: 
-- Module Name:    char_gen - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity char_gen is
    port ( clk            : in std_logic;
           blank          : in std_logic;
           row            : in std_logic_vector(10 downto 0);
           column         : in std_logic_vector(10 downto 0);
           ascii_to_write : in std_logic_vector(7 downto 0);
           write_en       : in std_logic;
           r,g,b          : out std_logic_vector(7 downto 0)
         );
end char_gen;

architecture structural of char_gen is

signal address_sig : std_logic_vector(6 downto 0);

signal address_cat_row : std_logic_vector(10 downto 0);

signal data_sig : std_logic_vector(7 downto 0);

signal row_buffer : std_logic_vector(3 downto 0);

signal pixel_high : std_logic;

signal count : std_logic_vector(11 downto 0);

begin

	address_cat_row <= address_sig(6 downto 0) & row_buffer(3 downto 0);
	
	--register
	process(clk,row)
	begin
		if rising_edge(clk) then
			row_buffer <= row;
		end if;
	end process;

	screen_buf_inst : entity work.char_screen_buffer(behavioral)
		port map(
		   clk => clk,
		   we => write_en,
		   address_a => count, 
		   address_b => address_sig, 
		   data_in => ascii_to_write, 
		   data_out_a => open, 
		   data_out_b => data_sig
			);
		 
	font_inst : entity work.font_rom(arch)
		port map(
			clk => clk,
			addr => address_cat_row,
			data => data_sig
			);
			
	mux_inst : entity work.MUX81(sel_arch)
		port map(
			sel => column(2 downto 0),
			data => data_sig,
			output => pixel_high
			);
			
	r <= (others => '1') when pixel_high = '1' else
		  (others => '0');
	g <= (others => '0');
	b <= (others => '0');

	
	

end structural;

