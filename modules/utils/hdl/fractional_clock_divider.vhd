-------------------------------------------------------------------------------
-- Title      : Generic clock divider
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description:
-- Generates a clock enable signal.
--
-- MUL must be smaller than DIV. 
-- 
-- Example:
-- @code
-- process (clk)
-- begin
--    if rising_edge(clk) then
--       if enable = '1' then
--          ... do something with the period of the divided frequency ...
--       end if;
--    end if;
-- end process;
-- @endcode
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fractional_clock_divider is
   generic (
      DIV : positive := 1;
      MUL : positive := 1;
      WIDTH : positive
      );
   port (
      clk_out_p : out std_logic;
      clk       : in  std_logic
      );
end fractional_clock_divider;

-- ----------------------------------------------------------------------------

architecture behavior of fractional_clock_divider is

    signal cnt : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
begin 

   process(clk) 
   begin
      if rising_edge(clk) then
--	report "div: " & integer'image(DIV);
        if unsigned(cnt) >= to_unsigned(DIV, WIDTH) then
           clk_out_p <= '1';
           cnt <= std_logic_vector(unsigned(cnt) - DIV);
        else
           clk_out_p <= '0';
           cnt <= std_logic_vector(unsigned(cnt) + MUL);         
        end if;
      end if;
   end process;
end behavior;




