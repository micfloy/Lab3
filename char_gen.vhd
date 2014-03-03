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
			  reset			  : in std_logic;
           row            : in std_logic_vector(10 downto 0);
           column         : in std_logic_vector(10 downto 0);
           ascii_to_write : in std_logic_vector(7 downto 0);
           write_en       : in std_logic;
           r,g,b          : out std_logic_vector(7 downto 0)
         );
end char_gen;

architecture structural of char_gen is

signal address_sig, data_from_font : std_logic_vector(7 downto 0);

signal data_sig : std_logic_vector(6 downto 0);

signal data_cat_row : std_logic_vector(10 downto 0);

signal row_col_sig : std_logic_vector(11 downto 0);

signal row_buffer : std_logic_vector(3 downto 0);

signal pixel_high : std_logic;

signal count, count_next, row_col_sig : std_logic_vector(11 downto 0);

signal sel_reg1, sel_reg2, sel_next1, sel_next2 : std_logic_vector(2 downto 0);

begin
	
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
		   address_b => row_col_sig, 
		   data_in => ascii_to_write, 
		   data_out_a => open, 
		   data_out_b => data_sig
			);
			
	count <= std_logic_vector(unsigned(count_next) + 1) when rising_edge(write_en) else
				count_next;
				
	count_next <= (others => '0') when reset = '1' else
						count;
	
	--Had this explained to me but the math still does not make sense to me.
	row_col_sig <= std_logic_vector(unsigned(row(10 downto 4))* 80 + unsigned(column(10 downto 3)));
						
	data_cat_row <= data_sig(6 downto 0) & row_buffer;

		 
	font_inst : entity work.font_rom(arch)
		port map(
			clk => clk,
			addr => data_cat_row,
			data => data_from_font
			);

	-- Column delay registers
	sel_next1 <= column(2 downto 0);
	sel_next2 <= sel_reg1;
	
	process(clk)
	begin
		if (rising_edge(clk)) then
			sel_reg1 <= sel_next1;
		end if;
	end process;
	
	process(clk)
	begin
		if (rising_edge(clk)) then
			sel_reg2 <= sel_next2;
		end if;
	end process;
	
	mux_inst : entity work.MUX81(sel_arch)
		port map(
			sel => sel_reg2,
			data => data_from_font,
			output => pixel_high
			);
			
	--Outputs
	r <= (others => '0');
	g <= (others => '1') when pixel_high = '1' and blank = '0' else
		  (others => '0');
	b <= (others => '0');

	
	

end structural;

