library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ifid_reg is 
  port (ck    : in std_logic;
	inst_i: in std_logic_vector(31 downto 0);
	inst_o: out std_logic_vector(31 downto 0));
end ifid_reg;

architecture beh of ifid_reg is
begin
  process(ck)
  begin
	if ck = '1' and ck'event then
		inst_o <= inst_i;
	end if;
  end process;
end beh;
