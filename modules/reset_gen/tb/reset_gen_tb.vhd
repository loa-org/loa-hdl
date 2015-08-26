-------------------------------------------------------------------------------
-- Title      : Testbench for design "reset_gen"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.reset_gen_pkg.all;

-------------------------------------------------------------------------------
entity reset_gen_tb is
end entity reset_gen_tb;

-------------------------------------------------------------------------------
architecture behavourial of reset_gen_tb is

   -- component ports
   signal clk       : std_logic                    := '0';
begin

   -- component instantiation
   dut : entity work.reset_gen
      port map (
         reset => open,
         clk       => clk);

   -- clock generation
   clk <= not clk after 10 ns;

end architecture behavourial;
