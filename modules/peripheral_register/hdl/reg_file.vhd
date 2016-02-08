-------------------------------------------------------------------------------
-- Title      : Register File
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file.vhd
-- Author     : Calle  <calle@Alukiste>
-- Created    : 2012-03-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-- Multiple 16-bit registers at the internal parallel data bus with address
-- decoding. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012, 2016 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.reset_pkg.all;

entity reg_file is
  generic (
    BASE_ADDRESS : integer range 0 to 16#7FFF#;  -- Base address of the registers
    REG_ADDR_BIT : natural    := 0;     -- number of bits not to compare in
    -- address. Gives 2**n registers
    RESET_IMPL   : reset_type := none
    );
  port (
    bus_o : out busdevice_out_type;
    bus_i : in  busdevice_in_type;
    reg_o : out reg_file_type(2**REG_ADDR_BIT-1 downto 0);
    reg_i : in  reg_file_type(2**REG_ADDR_BIT-1 downto 0);
    reset : in  std_logic;
    clk   : in  std_logic);
end reg_file;

-------------------------------------------------------------------------------

architecture str of reg_file is
  constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) := std_logic_vector(to_unsigned(BASE_ADDRESS, 15));

  type reg_file_state_type is record
    reg      : reg_file_type(2**REG_ADDR_BIT-1 downto 0);
    data_out : std_logic_vector(15 downto 0);
  end record;

  constant reg_file_state_type_initial : reg_file_state_type := (reg => (others => (others => '0')), data_out => (others => '0'));

  signal r, rin : reg_file_state_type := reg_file_state_type_initial;

begin  -- str
  bus_o.data <= r.data_out;
  reg_o      <= r.reg;

  comb : process (bus_i.addr, bus_i.data, bus_i.re, bus_i.we, r, reg_i, reset) is
    variable v     : reg_file_state_type;
    variable index : integer := 0;
  begin  -- process comb
    v     := r;
    index := to_integer(unsigned(bus_i.addr(REG_ADDR_BIT-1 downto 0)));

    if bus_i.addr(14 downto REG_ADDR_BIT) = BASE_ADDRESS_VECTOR(14 downto REG_ADDR_BIT) then
      if bus_i.we = '1' then
        v.reg(index) := bus_i.data;
      end if;
    end if;

    if (bus_i.addr(14 downto REG_ADDR_BIT) = BASE_ADDRESS_VECTOR(14 downto REG_ADDR_BIT)) and bus_i.re = '1' then
      v.data_out := reg_i(index);
    else
      v.data_out := (others => '0');
    end if;

    -- sync reset
    if RESET_IMPL = sync and reset = '1' then
      v := reg_file_state_type_initial;
    end if;
    rin <= v;
  end process comb;

  async_reset : if RESET_IMPL = async generate
    seq : process (clk, reset) is
    begin  -- process seq
      if reset = '0' then                 -- asynchronous reset (active low)
        r <= reg_file_state_type_initial;
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

end str;
