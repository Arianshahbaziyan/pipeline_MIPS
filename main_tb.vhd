library IEEE;
use IEEE.std_logic_1164.all;

entity MAIN_TB is
end MAIN_TB;

architecture test of MAIN_TB is

component main
  port(ck: in std_logic);
end component;

signal clock : std_logic; 

begin

mips: main port map(ck=>clock);

 process
 begin
  for i in 0 to 30 loop
        clock <= '0';
 	wait for 200 ns;
 	clock <= '1';
	wait for 200 ns;
  end loop;
 end process;

end test;
