library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package reset_gen_pkg is

   component reset_gen
      port (
         reset  : out std_logic;
         clk       : in std_logic);
   end component;

end reset_gen_pkg;
