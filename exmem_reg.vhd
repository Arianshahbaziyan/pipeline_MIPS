library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity exmem_reg is 
  port (ck    : in std_logic;
	aluresualt_i : in  std_logic_vector(31 downto 0);
	readd2_i     : in  std_logic_vector(31 downto 0);
	rtrd_i       : in  std_logic_vector(4 downto 0);
	mem_to_reg_i : in  std_logic;
	reg_write_i  : in  std_logic;
	memread_i    : in  std_logic;
	memwrite_i   : in  std_logic;
-----------------------------------------------------
	aluresualt_o : out std_logic_vector(31 downto 0);
	readd2_o     : out std_logic_vector(31 downto 0);
	rtrd_o       : out std_logic_vector(4 downto 0);
	mem_to_reg_o : out  std_logic;
	reg_write_o  : out  std_logic;
	memread_o    : out  std_logic;
	memwrite_o   : out  std_logic);
end exmem_reg;

architecture beh of exmem_reg is
begin
  process(ck)
  begin
	if ck = '1' and ck'event then
		readd2_o     <= readd2_i;
		aluresualt_o <= aluresualt_i;
		rtrd_o       <= rtrd_i;
		mem_to_reg_o <= mem_to_reg_i;
		reg_write_o  <= reg_write_i;
		memread_o    <= memread_i;
		memwrite_o   <= memwrite_i;
	end if;
  end process;
end beh;