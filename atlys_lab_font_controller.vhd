----------------------------------------------------------------------------------
-- Company: 
-- Engineer: C2C Michael Bentley
-- 
-- Create Date:    09:47:04 02/21/2014 
-- Design Name: 
-- Module Name:    atlys_lab_font_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Top-level component of a font controller.
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

entity atlys_lab_font_controller is
    port ( 
             clk    : in  std_logic; -- 100 MHz
             reset  : in  std_logic;
             start  : in  std_logic;
				 button_input : std_logic;
             switch : in  std_logic_vector(7 downto 0);
             led    : out std_logic_vector(7 downto 0);
             tmds   : out std_logic_vector(3 downto 0);
             tmdsb  : out std_logic_vector(3 downto 0)
         );
end atlys_lab_font_controller;

architecture bentley of atlys_lab_font_controller is

	 signal serialize_clk, serialize_clk_n : std_logic;
	 
	 signal button, pixel_clk, h_sync, v_sync, blank, v_comp : std_logic;
	 
	 signal h_sync1, h_sync2, v_sync1, v_sync2, blank1, blank2 : std_logic;
	 
	 signal red_s, green_s, blue_s, clock_s : std_logic;
	 
	 signal red, green, blue : std_logic_vector(7 downto 0);
	 
	 signal row_sig, col_sig : unsigned(10 downto 0);

begin

    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
             );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

	 vga_inst: entity work.vga_sync(moore)
			port map(
							clk  => pixel_clk,
							reset => reset,
							h_sync => h_sync,
							v_sync => v_sync,
							v_completed => v_comp,
							blank => blank,
							row => row_sig,
							column => col_sig
						);
						
	 char_gen_inst: entity work.char_gen(structural)
			port map(
							clk => pixel_clk,
							blank => blank,
							reset => reset,
							row => std_logic_vector(row_sig),
							column => std_logic_vector(col_sig),
							ascii_to_write => switch,
							write_en => button,
							r => red,
							g => green,
							b => blue
						);
				
				
	 button_inst: entity work.input_to_pulse(moore)
			port map(
							clk => pixel_clk,
							reset => reset,
							input => button_input,
							pulse => button
						);
						
	--Signal piping
	
	process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			h_sync1 <= h_sync;
			v_sync1 <= v_sync;
			blank1 <= blank;
		end if;
	end process;
	
	process(pixel_clk)
	begin
		if(rising_edge(pixel_clk)) then
			h_sync2 <= h_sync1;
			v_sync2 <= v_sync1;
			blank2 <= blank1;
		end if;
	end process;
	 

    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => blank2,
                hsync     => h_sync2,
                vsync     => v_sync2,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end bentley;
