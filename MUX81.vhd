----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:49:34 02/21/2014 
-- Design Name: 
-- Module Name:    MUX81 - Behavioral 
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

entity MUX81 is
    Port ( sel : in  STD_LOGIC_VECTOR (2 downto 0);
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           output : out  STD_LOGIC);
end MUX81;

architecture sel_arch of MUX81 is

signal output_sig : std_logic;

begin
	
	
	with sel select
		output	<= data(7) when "000",
				      data(6) when "001",
					   data(5) when "010",
					   data(4) when "011",
						data(3) when "100",
					   data(2) when "101",
					   data(1) when "110",
					   data(0) when others;
				 
end sel_arch;

