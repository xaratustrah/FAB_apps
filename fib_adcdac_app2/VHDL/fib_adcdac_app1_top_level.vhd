library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.busdriver_pkg.all;
use work.clk_divider_pkg.all;
use work.reset_gen_pkg.all;

entity fib_adcdac_app1_top_level is
  generic(
    firmware_id                : integer := 1;  --ID of the firmware (is displayed first)
    firmware_version           : integer := 3;  --Version of the firmware (is displayed after)
    clk_divider_width_toplevel : integer := 16;  -- width of the divider in bits
    reset_clks_toplevel        : integer := 2  -- Tells how many clocks the POR takes
    );

  port (
    --common signals
    trig1_in  : in  std_logic;          --rst
    trig2_out : out std_logic;
    clk0      : in  std_logic;
    hf_in     : in  std_logic;

    --FAB signals
    uC_Link_D   : inout std_logic_vector(7 downto 0);  -- FAB Lower Byte
    uC_Link_A   : inout std_logic_vector(7 downto 0);  -- FAB Upper Byte
    Piggy_Clk1  : out   std_logic;                     -- FAB Clock
    Piggy_RnW1  : out   std_logic;                     --dds_wr
    --    Piggy_RnW2  : in  std_logic;                     --dds_vout_comp 
    --    Piggy_Strb2 : out std_logic;                     --dds_rst
    Piggy_Strb1 : out   std_logic;                     --dds_update_o
    Piggy_Ack1  : in    std_logic;                     --dds_fsk
    --    Piggy_Ack2  : out std_logic;                     --dds_sh_key

    --static dds-buffer signals
    uC_Link_DIR_D, uC_Link_DIR_A : out std_logic;
    nuC_Link_EN_CTRL_A           : out std_logic;
    uC_Link_EN_DA                : out std_logic;

    --backplane signals
    A2nSW8      : in  std_logic;
    A3nSW9      : in  std_logic;
    A0nSW10     : in  std_logic;
    A1nSW11     : in  std_logic;
    Sub_A6nSW12 : in  std_logic;
    Sub_A7nSW13 : in  std_logic;
    Sub_A4nSW14 : in  std_logic;
    Sub_A5nSW15 : in  std_logic;
    nResetnSW0  : in  std_logic;
    SW1         : in  std_logic;
    nDSnSW2     : in  std_logic;
    BClocknSW3  : in  std_logic;
    RnWnSW4     : in  std_logic;
    SW5         : in  std_logic;
    A4nSW6      : in  std_logic;
    SW7         : in  std_logic;
    NEWDATA     : in  std_logic;
    FC_Str      : in  std_logic;
    FC0         : in  std_logic;
    FC1         : in  std_logic;
    FC2         : in  std_logic;
    FC3         : in  std_logic;
    FC4         : in  std_logic;
    FC5         : in  std_logic;
    VG_A3nFC6   : in  std_logic;
    FC7         : in  std_logic;
    SD          : in  std_logic;
    nDRQ2       : out std_logic;

    --static backplane-buffer signals
    BBA_DIR : out std_logic;
    BBB_DIR : out std_logic;
    BBC_DIR : out std_logic;
    BBD_DIR : out std_logic;
    BBE_DIR : out std_logic;
    BBG_DIR : out std_logic;
    BBH_DIR : out std_logic;
    nBB_EN  : out std_logic;

    --static backplane open-collector outputs
    DRDY     : out std_logic;
    SRQ3     : out std_logic;
    DRQ      : out std_logic;
    INTERL   : out std_logic;
    DTACK    : out std_logic;
    nDRDY2   : out std_logic;
    SEND_EN  : out std_logic;
    SEND_STR : out std_logic;

    --dsp-link signals (read)
    DSP_CRDY_W : out std_logic;
    DSP_CREQ_W : out std_logic;
    DSP_CACK_R : in  std_logic;
    DSP_CSTR_R : in  std_logic;

    DSP_D_R0 : in std_logic;
    DSP_D_R1 : in std_logic;
    DSP_D_R2 : in std_logic;
    DSP_D_R3 : in std_logic;
    DSP_D_R4 : in std_logic;
    DSP_D_R5 : in std_logic;
    DSP_D_R6 : in std_logic;
    DSP_D_R7 : in std_logic;

    --dsp-link signals (write)          
    DSP_CRDY_R : in  std_logic;
    DSP_CREQ_R : in  std_logic;
    DSP_CACK_W : out std_logic;
    DSP_CSTR_W : out std_logic;

    DSP_D_W0 : out std_logic;
    DSP_D_W1 : out std_logic;
    DSP_D_W2 : out std_logic;
    DSP_D_W3 : out std_logic;
    DSP_D_W4 : out std_logic;
    DSP_D_W5 : out std_logic;
    DSP_D_W6 : out std_logic;
    DSP_D_W7 : out std_logic;

    -- leds
    led1 : out std_logic;
    led2 : out std_logic;
    led3 : out std_logic;
    led4 : out std_logic;

    -- only for debug
    piggy_io : out std_logic_vector(7 downto 0);

    --adressing pins via FC
    VG_A4 : in std_logic;               --FC(0)
    VG_A1 : in std_logic;               --FC(1)

    -- dsp-link buffer enable signals

    DSP_DIR_D      : out std_logic;
    DSP_DIR_STRACK : out std_logic;
    DSP_DIR_REQRDY : out std_logic

    );
end entity fib_adcdac_app1_top_level;

architecture fib_adcdac_app1_top_level_arch of fib_adcdac_app1_top_level is

  -- components

  component internal_pll
    port (
      areset : in  std_logic;
      inclk0 : in  std_logic;
      c0     : out std_logic;
      e0     : out std_logic;
      locked : out std_logic);
  end component;

  component digital_short
    generic (
      clk_freq_in_hz : real := 200000000.0;  --system clock frequency
      delay_in_ns    : real := 15.0);        -- delay of the wait state

    port (
      rst_i : in std_logic;             -- reset in
      clk_i : in std_logic;             -- clock in

      rnw_o    : out std_logic;
      strobe_o : out std_logic;
      ack_i    : in  std_logic;

      ext_driver_dir : out std_logic;

      adr_o : out std_logic_vector (5 downto 0);

      en_write_to_bus : out std_logic;

      data_to_bus   : out std_logic_vector (15 downto 0);
      data_from_bus : in  std_logic_vector (15 downto 0)
      );

  end component;

  -- common signals
  signal global_rst : std_logic;

  -- FAB related signals

  signal data_bus : std_logic_vector (15 downto 0);  -- FAB Data bus mapped to uCLinuk Address and Databus

  signal adr_o          : std_logic_vector (5 downto 0);  -- Address bus for FAB
  signal ext_driver_dir : std_logic;

  signal areset : std_logic;
  signal inclk0 : std_logic;
  signal c0     : std_logic;
  signal e0     : std_logic;
  signal locked : std_logic;

  signal en_write_to_bus : std_logic;
  signal data_to_bus     : std_logic_vector (15 downto 0);
  signal data_from_bus   : std_logic_vector (15 downto 0);

begin

  reset_gen_inst : reset_gen
    generic map (
      reset_clks => reset_clks_toplevel)

    port map (
      clk_i => clk0,
      rst_o => global_rst);

  blinker1 : clk_divider
    generic map (
      clk_divider_width => 24)
    port map (
      clk_div_i => x"EEFFFF",
      rst_i     => global_rst,
      clk_i     => clk0,
      clk_o     => led4);

  internal_pll_inst : internal_pll
    port map (
      areset => areset,
      inclk0 => inclk0,
      c0     => c0,
      e0     => e0,
      locked => locked);

  busdriver_inst : busdriver
    port map (
      en_write_to_bus_i => en_write_to_bus,
      data_bus_io       => data_bus,
      data_to_bus_i     => data_to_bus,
      data_from_bus_o   => data_from_bus);

  digital_short_inst : digital_short
    port map (
      rst_i           => global_rst,
      clk_i           => clk0,
      rnw_o           => Piggy_RnW1,
      strobe_o        => Piggy_Strb1,
      ack_i           => Piggy_Ack1,
      ext_driver_dir  => ext_driver_dir,
      adr_o           => adr_o,
      en_write_to_bus => en_write_to_bus,
      data_to_bus     => data_to_bus,
      data_from_bus   => data_from_bus
      );

  --static backplane buffer settings
  BBA_DIR <= '0';
  BBB_DIR <= '0';
  BBC_DIR <= '0';
  BBD_DIR <= '0';
  BBE_DIR <= '0';
  BBG_DIR <= '0';
  BBH_DIR <= '0';
  nBB_EN  <= '0';

  --static backplane open-collector output settings
  DRDY     <= '0';
  SRQ3     <= '0';
  DRQ      <= '0';
  INTERL   <= '0';
  DTACK    <= '0';
  nDRDY2   <= '0';
  SEND_EN  <= '0';
  SEND_STR <= '0';

  --static uC-Link buffer settings

  nuC_Link_EN_CTRL_A <= '1';
  uC_Link_EN_DA      <= '0';

  -- unused buffers get warm!

  DSP_DIR_D      <= '1';
  DSP_DIR_REQRDY <= '1';
  DSP_DIR_STRACK <= '1';

  -- Actual signal interconnection

  uC_Link_D <= data_bus (7 downto 0)  when en_write_to_bus = '1' else (others => 'Z');
  uC_Link_A <= data_bus (15 downto 8) when en_write_to_bus = '1' else (others => 'Z');

  data_bus (7 downto 0)  <= uC_Link_D when en_write_to_bus = '0' else (others => 'Z');
  data_bus (15 downto 8) <= uC_Link_A when en_write_to_bus = '0' else (others => 'Z');

--  data_bus <= test;

  piggy_io (5 downto 0) <= adr_o;

  uC_Link_DIR_A <= ext_driver_dir;
  uC_Link_DIR_D <= ext_driver_dir;

-- PLL signals

  areset <= '0';
  inclk0 <= clk0;

  Piggy_Clk1 <= c0;

--  process (clk0)
--  begin  -- process
--    if clk0'event and clk0 = '1' then  -- rising clock edge

--      data_bus (7 downto 0) <= uC_Link_D;

--    end if;
--  end process;

end architecture fib_adcdac_app1_top_level_arch;

