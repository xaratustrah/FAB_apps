//
// Sine table generator for barrier bucket
// S. Sanjari
//

M=14; // DAC resolution bits
N=50; // one point more will be generated
P=%pi/2; // phase in radians
P_Flag = 0; // 1 to indicate that a phase other than 0 and 180 deg etc. is specified

u=mopen("..\VHDL\sine_lut_bbsg.vhd", 'w');

mfprintf(u, "-------------------------------------------------------------\n-- Sine LUT Package.\n-- For use with Barrier Bucket Signal Generator\n-- This script is automatically generated\n-- S. Sanjari\n-------------------------------------------------------------\n\n");
mfprintf(u, "library ieee;\nuse ieee.std_logic_1164.all;\nuse ieee.std_logic_unsigned.all;\nuse ieee.numeric_std.all;\nuse ieee.math_real.all;\n\n");
mfprintf(u, "package sine_lut_bbsg_pkg is\n\nconstant SAMPL_WIDTH  : integer := %d;\nconstant NO_OF_POINTS : integer := %d;\n", M, N);
mfprintf(u, "type lut_type is array \(0 to NO_OF_POINTS\) of std_logic_vector \(SAMPL_WIDTH - 1 downto 0\)\;\n\n");
mfprintf(u, "constant sine_lut : lut_type :=\(\n\n");

if P_Flag == 0 then
for i=0:N;
  mfprintf(u, "std_logic_vector\(to_signed\(");
  mfprintf(u, "%d", sin(i*2*%pi/N)*(2^(M-1)-1));
  if i==N then
  mfprintf(u, ", SAMPL_WIDTH\)\)\n");
    else
  mfprintf(u, ", SAMPL_WIDTH\)\),\n");
  end
end
  else
    mfprintf(u, "std_logic_vector\(to_signed\(0, SAMPL_WIDTH\)\),\n");
for i=0:N-2;
  mfprintf(u, "std_logic_vector\(to_signed\(");
  mfprintf(u, "%d", sin(i*2*%pi/N+P)*(2^(M-1)-1));
  if i==N then
  mfprintf(u, ", SAMPL_WIDTH\)\)\n");
    else
  mfprintf(u, ", SAMPL_WIDTH\)\),\n");
  end
end
    mfprintf(u, "std_logic_vector\(to_signed\(0, SAMPL_WIDTH\)\)\n");
end

mfprintf(u, "\);\n");
mfprintf(u, "end sine_lut_bbsg_pkg;\n\npackage body sine_lut_bbsg_pkg is\nend sine_lut_bbsg_pkg;\n");
mclose(u);

