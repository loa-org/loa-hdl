-------------------------------------------------------------------------------
-- Title      : HDLC Busmaster with support
-- Project    : 
-------------------------------------------------------------------------------
-- File       : hdlc_busmaster_with_support.vhd
-- Author     : 
-- Company    : 
-- Created    : 2015-09-15
-- Last update: 2015-09-15
-- Platform   : 
-------------------------------------------------------------------------------
-- Description:
--
--
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.hdlc_pkg.all;
use work.bus_pkg.all;
use work.reset_pkg.all;
use work.fifo_sync_pkg.all;
use work.utils_pkg.all;
use work.uart_pkg.all;

-------------------------------------------------------------------------------

entity hdlc_busmaster_with_support is
  generic (
    DIV_RX     : positive   := 87;
    DIV_TX     : positive   := 434;
    RESET_IMPL : reset_type := sync
    );
  port (
    rx    : in  std_logic;
    tx    : out std_logic;
    bus_o : out busmaster_out_type;
    bus_i : in  busmaster_in_type;
    reset : in  std_logic;
    clk   : in  std_logic
    );
end entity hdlc_busmaster_with_support;

-------------------------------------------------------------------------------

architecture str of hdlc_busmaster_with_support is

  type fifo_link_8bit_type is record
    data   : std_logic_vector(7 downto 0);
    enable : std_logic;
    empty  : std_logic;
  end record;

  -- Connections components used for HDLC link
  signal rx_to_dec            : hdlc_dec_in_type    := (data => (others => '0'), enable => '0');
  signal dec_to_busmaster     : hdlc_dec_out_type   := (data => (others => '0'), enable => '0');
  signal master_to_enc        : hdlc_enc_in_type    := (data => (others => '0'), enable => '0');
  signal enc_to_fifo          : hdlc_enc_out_type   := (data => (others => '0'), enable => '0');
  signal fifo_to_uart_tx      : fifo_link_8bit_type := (data => (others => '0'), enable => '0', empty => '0');
  signal enc_busy             : std_logic           := '0';
  signal clk_rx_en, clk_tx_en : std_logic;

begin  -- architecture str

  -----------------------------------------------------------------------------
  --  Baudrate Generator 
  -----------------------------------------------------------------------------
  baudrate_rx_gen_inst : entity work.clock_divider
    generic map(DIV => DIV_RX)
    port map(
      clk       => clk,
      clk_out_p => clk_rx_en);

  baudrate_tx_gen_inst : entity work.clock_divider
    generic map(DIV => DIV_TX)
    port map(
      clk       => clk,
      clk_out_p => clk_tx_en);

  -----------------------------------------------------------------------------
  -- UART RX
  -----------------------------------------------------------------------------
  uart_rx_inst : entity work.uart_rx
    generic map (RESET_IMPL => RESET_IMPL)
    port map(
      rxd_p     => rx,
      disable_p => '0',
      data_p    => rx_to_dec.data,
      we_p      => rx_to_dec.enable,
      error_p   => open,
      full_p    => '0',
      clk_rx_en => clk_rx_en,
      reset     => reset,
      clk       => clk);

  -----------------------------------------------------------------------------
  --  Decoder
  -----------------------------------------------------------------------------
  hdlc_dec_inst : entity work.hdlc_dec
    port map(
      din_p  => rx_to_dec,
      dout_p => dec_to_busmaster,
      clk    => clk);

  -----------------------------------------------------------------------------
  -- Busmaster
  -----------------------------------------------------------------------------
  bus_master_inst : entity work.hdlc_busmaster
    port map(
      din_p  => dec_to_busmaster,
      dout_p => master_to_enc,
      bus_o  => bus_o,
      bus_i  => bus_i,
      clk    => clk);

  -----------------------------------------------------------------------------
  -- Encoder
  -----------------------------------------------------------------------------
  hdlc_enc_inst : entity work.hdlc_enc
    port map(
      din_p  => master_to_enc,
      dout_p => enc_to_fifo,
      busy_p => open,
      clk    => clk);

  -----------------------------------------------------------------------------
  -- Transmit FIFO
  -----------------------------------------------------------------------------
  tx_fifo_inst : entity work.fifo_sync
    generic map(
      data_width    => 8,
      address_width => 5)
    port map(
      di    => enc_to_fifo.data,
      wr    => enc_to_fifo.enable,
      full  => open,
      do    => fifo_to_uart_tx.data,
      rd    => fifo_to_uart_tx.enable,
      empty => fifo_to_uart_tx.empty,
      valid => open,
      clk   => clk);

  -----------------------------------------------------------------------------
  -- UART TX
  -----------------------------------------------------------------------------
  uart_tx_inst : entity work.uart_tx
    generic map (RESET_IMPL => RESET_IMPL)
    port map(
      txd_p     => tx,
      busy_p    => open,
      data_p    => fifo_to_uart_tx.data,
      empty_p   => fifo_to_uart_tx.empty,
      re_p      => fifo_to_uart_tx.enable,
      clk_tx_en => clk_tx_en,
      reset     => reset,
      clk       => clk);

end architecture str;

