-------------------------------------------------------------------------------
-- Title      : Reset Generator
-------------------------------------------------------------------------------
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 C. Treudler
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reset_gen_pkg.all;


-------------------------------------------------------------------------------
entity reset_gen is
    
   port (
   	 reset : out std_logic;
     clk   : in std_logic);
      
end reset_gen;

-------------------------------------------------------------------------------
architecture behavioural of reset_gen is
   
   signal r : std_logic_vector(1 downto 0) := (others => '1');
   
begin

	process (clk) begin
		if rising_edge(clk) then
			r <= '0' & r(1);
		end if;
	end process;
		
	reset <= r(0);
		
end behavioural;
