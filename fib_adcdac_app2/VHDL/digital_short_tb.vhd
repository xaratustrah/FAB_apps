-------------------------------------------------------------------------------
-- Title      : Testbench for design "digital_short"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : digital_short_tb.vhd
-- Author     :   <hfaccnt4@BTPC66>
-- Company    : 
-- Created    : 2006-07-31
-- Last update: 2006-08-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2006-07-31  1.0      hfaccnt4        Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity digital_short_tb is

end digital_short_tb;

-------------------------------------------------------------------------------

architecture digital_short_tb_arch of digital_short_tb is

  component digital_short
    generic (
      clk_freq_in_hz : real;
      delay_in_ns    : real);
    port (
      rst_i    : in    std_logic;
      clk_i    : in    std_logic;
      rnw_o    : out   std_logic;
      strobe_o : out   std_logic;
      ack_i    : in    std_logic;
      adr_o    : out   std_logic_vector (5 downto 0);
      dat_io   : inout std_logic_vector (15 downto 0));
  end component;

  -- component generics
  constant clk_freq_in_hz : real := 200000000.0;
  constant delay_in_ns    : real := 40.0;

  -- component ports
  signal rst       : std_logic;
  signal clk       : std_logic := '1';
  signal rnw       : std_logic;
  signal strobe    : std_logic;
  signal ack       : std_logic;
  signal adr       : std_logic_vector (5 downto 0);
  signal dat_io_tb : std_logic_vector (15 downto 0);


begin  -- digital_short_tb_arch

  -- component instantiation
  DUT : digital_short
    generic map (
      clk_freq_in_hz => clk_freq_in_hz,
      delay_in_ns    => delay_in_ns)
    port map (
      rst_i    => rst,
      clk_i    => clk,
      rnw_o    => rnw,
      strobe_o => strobe,
      ack_i    => ack,
      adr_o    => adr,
      dat_io   => dat_io_tb);

  -- clock generation
  
  clk       <= not clk after 2500 ps;
  rst       <= '1', '0' after 30 ns;
  ack       <= '0';
  dat_io_tb <= (others => 'Z'), "1010101010101010" after 100 ns, (others => 'Z') after 120 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here

    wait;
--    wait until Clk = '1';
  end process WaveGen_Proc;

end digital_short_tb_arch;
-------------------------------------------------------------------------------
