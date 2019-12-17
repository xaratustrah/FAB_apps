------------------------------------------------------------------------------
--
-- This program tests the adc_dac_interface_pkg code.
-- 11.01.2007/sh
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.adc_dac_interface_pkg.all;
use work.reset_gen_pkg.all;
use work.clk_divider_pkg.all;
use work.sawtooth_pkg.all;
use work.real_time_calculator_pkg.all;
use work.fab_adc_dac_defines_pkg.all;

entity digital_short_rev2_top is
  
  generic (
    system_clk_freq_in_hz      : real    := 70.0E+6;
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
    Piggy_Ack1  : out   std_logic;                     --dds_fsk
    Piggy_Ack2  : out   std_logic;                     --dds_sh_key

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
end digital_short_rev2_top;

architecture digital_short_rev2_top_arch of digital_short_rev2_top is

  -- components

  component internal_pll
    port (
      areset : in  std_logic;
      inclk0 : in  std_logic;
      c0     : out std_logic;
      c1     : out std_logic;
      locked : out std_logic);
  end component;

  -- common signals
  signal global_rst : std_logic;
  signal global_clk : std_logic;  -- a variable for a clock for everything



  -- PLL Signale

  signal areset : std_logic;
  signal clk50  : std_logic;
  signal clk100 : std_logic;
--  signal clk150 : std_logic;
  signal clk70 : std_logic;
--  signal clk200 : std_logic;
  signal locked : std_logic;

  -- signals for the adc_dac_interface_pkg

  constant io_bus_width        : integer := 8;
  constant adr_bus_width       : integer := 6;
  constant data_bus_width      : integer := 16;
  
  constant desired_delay_in_ns : real    := 1.0;  --delay for the adc-dac
                                                   --state machine.

  signal adr_i     : std_logic_vector (adr_bus_width - 1 downto 0);
  signal dat_i     : std_logic_vector (data_bus_width - 1 downto 0);
  signal dat_o     : std_logic_vector (data_bus_width - 1 downto 0);
  signal str_i     : std_logic;
  signal rnw_i     : std_logic;
  signal b8nb16_i  : std_logic;
  signal busy_o    : std_logic;
  signal rst_i     : std_logic;
  signal clk_i     : std_logic;
  signal bus8hi_io : std_logic_vector (io_bus_width - 1 downto 0);
  signal bus8lo_io : std_logic_vector (io_bus_width - 1 downto 0);
  signal ndir8hi_o : std_logic;
  signal ndir8lo_o : std_logic;

  signal piggy_rst : std_logic;

  type states_type is (S1, S2, S3, S4, S5, S6);
  signal next_state, return_to_state : states_type;

  signal local_variable : std_logic_vector (15 downto 0);

--  constant waitstate_delay_in_ns    : real    := 100.0;
--  constant waitstate_delay_in_ticks : integer := get_delay_in_ticks_ceil(system_clk_freq_in_hz, waitstate_delay_in_ns);

--  signal waitstate_delay_cnt : integer range 0 to waitstate_delay_in_ticks;

begin  -- digital_short_rev2_top_arch

  reset_gen_inst : reset_gen
    generic map (
      reset_clks => reset_clks_toplevel)

    port map (
      clk_i => global_clk,
      rst_o => global_rst);

  blinker1 : clk_divider
    generic map (
      clk_divider_width => 24)
    port map (
      clk_div_i => x"EEFFFF",
      rst_i     => global_rst,
      clk_i     => clk0,
      clk_o     => led3);

  internal_pll_inst : internal_pll
    port map (
      areset => areset,
      inclk0 => clk50,
      c0     => clk100,
      c1     => clk70,
      locked => locked);

  adc_dac_interface_1 : adc_dac_interface
    generic map (
      system_clk_freq_in_hz => system_clk_freq_in_hz,
      io_bus_width          => io_bus_width,
      adr_bus_width         => adr_bus_width,
      data_bus_width        => data_bus_width,
      desired_delay_in_ns   => desired_delay_in_ns)
    port map (
      adr_i     => adr_i,
      dat_i     => dat_i,
      dat_o     => dat_o,
      str_i     => str_i,
      rnw_i     => rnw_i,
      b8nb16_i  => b8nb16_i,
      busy_o    => busy_o,
      rst_i     => global_rst,
      clk_i     => global_clk,
      adr_o     => piggy_io (5 downto 0),
      bus8hi_io => uC_Link_A,
      bus8lo_io => uC_Link_D,
      str_o     => Piggy_Strb1,
      rnw_o     => Piggy_RnW1,
      b8nb16_o  => Piggy_Ack1,
      ndir8hi_o => ndir8hi_o,
      ndir8lo_o => ndir8lo_o,
      rst_o     => piggy_rst);

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

  -- PLL signals

  areset <= '0';
  clk50  <= clk0;

  -- Wich value should the global_clk have...
  global_clk <= clk70;


  -- Actual signal interconnection

  piggy_io (6) <= '0';

  uC_Link_DIR_A <= not ndir8hi_o;
  uC_Link_DIR_D <= not ndir8lo_o;
  Piggy_Clk1    <= global_clk;
  piggy_io (7)  <= not piggy_rst;

  Piggy_Ack2 <= '1';


  p_main : process (global_clk, global_rst)
  begin  -- process p_main

    if global_rst = '1' then            -- asynchronous reset (active high)
      adr_i (5 downto 0) <= FAB_ADCDAC_REG_ADC2_ADR;
      str_i              <= '1';
      rnw_i              <= '1';
      b8nb16_i           <= '0';
      next_state         <= S1;

    elsif global_clk'event and global_clk = '1' then  -- rising clock edge

      case next_state is
        when S1 =>
          if busy_o = '1' then
            next_state <= S1;
          else
            local_variable <= dat_o;
            rnw_i          <= '0';
            adr_i          <= FAB_ADCDAC_REG_DAC1_ADR;
            next_state     <= S2;
          end if;

        when S2 =>
          next_state <= S3;

        when S3 =>
          if busy_o = '1' then
            next_state <= S3;
          else
            dat_i      <= local_variable;
            rnw_i      <= '1';
            adr_i      <= FAB_ADCDAC_REG_ADC2_ADR;
            next_state <= S4;
          end if;

        when S4 =>
          next_state <= S1;

        when others => null;
      end case;
      
    end if;
  end process p_main;

--  process (global_clk, global_rst)
--  begin  -- process
--    if global_rst = '1' then            -- asynchronous reset (active high)
--      str_i               <= '1';
--      rnw_i               <= '0';
--      b8nb16_i            <= '0';
--      waitstate_delay_cnt <= waitstate_delay_in_ticks;
--      next_state          <= S1;

--    elsif global_clk'event and global_clk = '1' then  -- rising clock edge

--      case next_state is
-- when S1 =>
--          if busy_o = '1' then
--            next_state <= S1;
--          elsif busy_o = '0' then
--            dat_i      <= local_variable;
--            next_state <= S2;
--          end if;

-- when S2 =>
--          if waitstate_delay_cnt = 0 then
--            rnw_i               <= '1';
--            adr_i (5 downto 0)  <= FAB_ADCDAC_REG_ADC2_ADR;
--            next_state          <= S3;
--            waitstate_delay_cnt <= waitstate_delay_in_ticks;
--          else
--            waitstate_delay_cnt <= waitstate_delay_cnt - 1;
--          end if;

-- when S3 =>
--          if waitstate_delay_cnt = 0 then
--            next_state          <= S4;
--            waitstate_delay_cnt <= waitstate_delay_in_ticks;
--          else
--            waitstate_delay_cnt <= waitstate_delay_cnt - 1;
--          end if;

-- when S4 =>
--          if busy_o = '1' then
--            next_state <= S4;
--          elsif busy_o = '0' then
--            local_variable <= dat_o;
--            next_state     <= S5;
--          end if;

-- when S5 =>
--          if waitstate_delay_cnt = 0 then
--            rnw_i               <= '0';
--            adr_i (5 downto 0)  <= FAB_ADCDAC_REG_DAC1_ADR;
--            next_state          <= S6;
--            waitstate_delay_cnt <= waitstate_delay_in_ticks;
--          else
--            waitstate_delay_cnt <= waitstate_delay_cnt - 1;
--          end if;

-- when S6 =>
--          if waitstate_delay_cnt = 0 then
--            next_state          <= S1;
--            waitstate_delay_cnt <= waitstate_delay_in_ticks;
--          else
--            waitstate_delay_cnt <= waitstate_delay_cnt - 1;
--          end if;

-- when others => null;
--      end case;

--    end if;
--  end process;
end digital_short_rev2_top_arch;
