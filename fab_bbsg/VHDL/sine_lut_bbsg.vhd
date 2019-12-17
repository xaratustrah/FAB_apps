-------------------------------------------------------------
-- Sine LUT Package.
-- For use with Barrier Bucket Signal Generator
-- This script is automatically generated
-- S. Sanjari
-------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package sine_lut_bbsg_pkg is

constant SAMPL_WIDTH  : integer := 14;
constant NO_OF_POINTS : integer := 50;
type lut_type is array (0 to NO_OF_POINTS) of std_logic_vector (SAMPL_WIDTH - 1 downto 0);

constant sine_lut : lut_type :=(

std_logic_vector(to_signed(0, SAMPL_WIDTH)),
std_logic_vector(to_signed(1026, SAMPL_WIDTH)),
std_logic_vector(to_signed(2037, SAMPL_WIDTH)),
std_logic_vector(to_signed(3015, SAMPL_WIDTH)),
std_logic_vector(to_signed(3946, SAMPL_WIDTH)),
std_logic_vector(to_signed(4814, SAMPL_WIDTH)),
std_logic_vector(to_signed(5607, SAMPL_WIDTH)),
std_logic_vector(to_signed(6311, SAMPL_WIDTH)),
std_logic_vector(to_signed(6915, SAMPL_WIDTH)),
std_logic_vector(to_signed(7411, SAMPL_WIDTH)),
std_logic_vector(to_signed(7790, SAMPL_WIDTH)),
std_logic_vector(to_signed(8045, SAMPL_WIDTH)),
std_logic_vector(to_signed(8174, SAMPL_WIDTH)),
std_logic_vector(to_signed(8174, SAMPL_WIDTH)),
std_logic_vector(to_signed(8045, SAMPL_WIDTH)),
std_logic_vector(to_signed(7790, SAMPL_WIDTH)),
std_logic_vector(to_signed(7411, SAMPL_WIDTH)),
std_logic_vector(to_signed(6915, SAMPL_WIDTH)),
std_logic_vector(to_signed(6311, SAMPL_WIDTH)),
std_logic_vector(to_signed(5607, SAMPL_WIDTH)),
std_logic_vector(to_signed(4814, SAMPL_WIDTH)),
std_logic_vector(to_signed(3946, SAMPL_WIDTH)),
std_logic_vector(to_signed(3015, SAMPL_WIDTH)),
std_logic_vector(to_signed(2037, SAMPL_WIDTH)),
std_logic_vector(to_signed(1026, SAMPL_WIDTH)),
std_logic_vector(to_signed(0, SAMPL_WIDTH)),
std_logic_vector(to_signed(-1026, SAMPL_WIDTH)),
std_logic_vector(to_signed(-2037, SAMPL_WIDTH)),
std_logic_vector(to_signed(-3015, SAMPL_WIDTH)),
std_logic_vector(to_signed(-3946, SAMPL_WIDTH)),
std_logic_vector(to_signed(-4814, SAMPL_WIDTH)),
std_logic_vector(to_signed(-5607, SAMPL_WIDTH)),
std_logic_vector(to_signed(-6311, SAMPL_WIDTH)),
std_logic_vector(to_signed(-6915, SAMPL_WIDTH)),
std_logic_vector(to_signed(-7411, SAMPL_WIDTH)),
std_logic_vector(to_signed(-7790, SAMPL_WIDTH)),
std_logic_vector(to_signed(-8045, SAMPL_WIDTH)),
std_logic_vector(to_signed(-8174, SAMPL_WIDTH)),
std_logic_vector(to_signed(-8174, SAMPL_WIDTH)),
std_logic_vector(to_signed(-8045, SAMPL_WIDTH)),
std_logic_vector(to_signed(-7790, SAMPL_WIDTH)),
std_logic_vector(to_signed(-7411, SAMPL_WIDTH)),
std_logic_vector(to_signed(-6915, SAMPL_WIDTH)),
std_logic_vector(to_signed(-6311, SAMPL_WIDTH)),
std_logic_vector(to_signed(-5607, SAMPL_WIDTH)),
std_logic_vector(to_signed(-4814, SAMPL_WIDTH)),
std_logic_vector(to_signed(-3946, SAMPL_WIDTH)),
std_logic_vector(to_signed(-3015, SAMPL_WIDTH)),
std_logic_vector(to_signed(-2037, SAMPL_WIDTH)),
std_logic_vector(to_signed(-1026, SAMPL_WIDTH)),
std_logic_vector(to_signed(0, SAMPL_WIDTH))
);
end sine_lut_bbsg_pkg;

package body sine_lut_bbsg_pkg is
end sine_lut_bbsg_pkg;
