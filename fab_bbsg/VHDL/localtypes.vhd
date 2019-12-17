-- Local Types Declaration
-- S. Sanjari

library ieee;
use ieee.std_logic_1164.all;

package localtypes is

  constant SAWTOOTH_GEN : integer := 0;
  constant MLS_GEN      : integer := 1;
  constant DDS_GEN      : integer := 2;
  constant THRU_GEN     : integer := 3;
  constant GND_GEN      : integer := 4;
  constant VDD_GEN      : integer := 5;
  constant VSS_GEN      : integer := 6;
  constant BBS_GEN		: integer := 7;

end localtypes;

package body localtypes is

end localtypes;
