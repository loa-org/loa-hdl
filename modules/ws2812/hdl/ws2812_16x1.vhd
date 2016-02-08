-------------------------------------------------------------------------------
-- Title      : 8x1 Pixel Controller
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-15
-------------------------------------------------------------------------------
-- Copyright (c) 2014, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ws2812_pkg.all;
use work.ws2812_cfg_pkg.all;
use work.reset_pkg.all;

entity ws2812_16x1 is
  generic (
    RESET_IMPL : reset_type := none);
  port (
    pixels     : in  ws2812_16x1_in_type;
    ws2812_in  : out ws2812_in_type;
    ws2812_out : in  ws2812_out_type;
    reset      : in  std_logic;
    clk        : in  std_logic);
end ws2812_16x1;

architecture rtl of ws2812_16x1 is

  type ws2812_16x1_states is (idle, write1, write2, write3, finish1, finish2);

  type ws2812_16x1_state_type is record
    o         : ws2812_in_type;
    pixel_cnt : integer range 0 to 15;
    state     : ws2812_16x1_states;
  end record;

  constant ws2812_16x1_state_type_initial : ws2812_16x1_state_type := (
    o         => (d => (others => '0'), we => '0', send_reset => '0'),
    pixel_cnt => 0,
    state     => idle);

  signal r, rin : ws2812_16x1_state_type := ws2812_16x1_state_type_initial;

begin  -- ws2812_16x1

  ws2812_in <= r.o;

  comb : process(pixels, r, ws2812_out, reset)
    variable v : ws2812_16x1_state_type;
  begin
    v := r;

    case v.state is
      when idle =>
        -- busy := '0';

        if pixels.refresh = '1' then
          v.state     := write1;
          v.pixel_cnt := 15;
        --busy    := '1';
        end if;

      -------------------------------------------------------------------------
      -- Write loop sequence
      -------------------------------------------------------------------------  
      when write1 =>
        v.o.d   := pixels.pixel(v.pixel_cnt);
        v.o.we  := '1';
        v.state := write2;

      when write2 =>
        v.o.we  := '0';
        v.state := write3;

      when write3 =>
        if ws2812_out.busy = '0' then
          if v.pixel_cnt = 0 then
            v.state        := finish1;
            v.o.send_reset := '1';
          else
            v.pixel_cnt := v.pixel_cnt - 1;
            v.state     := write1;
          end if;
        end if;

      -----------------------------------------------------------------------
      -- Send a reset seqence to update transfered data to output registers
      -- of the LEDs
      -----------------------------------------------------------------------
      when finish1 =>
        v.o.send_reset := '0';
        v.state        := finish2;
      when finish2 =>
        if ws2812_out.busy = '0' then
          v.state := idle;
        end if;


      when others => null;
    end case;

    -- sync reset
    if RESET_IMPL = sync and reset = '1' then
      v := ws2812_16x1_state_type_initial;
    end if;
    rin <= v;
  end process comb;

  async_reset : if RESET_IMPL = async generate
    seq : process (clk, reset) is
    begin  -- process seq
      if reset = '0' then                 -- asynchronous reset (active low)
        r <= ws2812_16x1_state_type_initial;
      elsif clk'event and clk = '1' then  -- rising clock edge
        r <= rin;
      end if;
    end process seq;
  end generate;

  sync_reset : if RESET_IMPL /= async generate
    seq : process (clk) is
    begin  -- process seq
      if clk'event and clk = '1' then   -- rising clock edge
        r <= rin;
      end if;
    end process seq;
  end generate;


end rtl;
