library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity idex_reg is 
  port (ck    : in std_logic;
	readd1_i: in  std_logic_vector(31 downto 0);
	readd2_i: in  std_logic_vector(31 downto 0);
	eignex_i: in  std_logic_vector(31 downto 0);
	rt_i    : in  std_logic_vector(4 downto 0);
	rd_i    : in  std_logic_vector(4 downto 0);
	func_i  : in  std_logic_vector(5 downto 0);
	mem_to_reg_i : in  std_logic;
	reg_write_i  : in  std_logic;
	memread_i    : in  std_logic;
	memwrite_i   : in  std_logic;
	alusrc_i     : in  std_logic;
	regdest_i    : in  std_logic;
	aluop_i      : in  std_logic_vector(1 downto 0);
-----------------------------------------------------
	readd1_o: out std_logic_vector(31 downto 0);
	readd2_o: out std_logic_vector(31 downto 0);
	eignex_o: out std_logic_vector(31 downto 0);
	rt_o    : out std_logic_vector(4 downto 0);
	rd_o    : out std_logic_vector(4 downto 0);
	func_o  : out std_logic_vector(5 downto 0);
	mem_to_reg_o : out  std_logic;
	reg_write_o  : out  std_logic;
	memread_o    : out  std_logic;
	memwrite_o   : out  std_logic;
	alusrc_o     : out  std_logic;
	regdest_o    : out  std_logic;
	aluop_o      : out  std_logic_vector(1 downto 0));
end idex_reg;

architecture beh of idex_reg is
begin
  process(ck)
  begin
	if ck = '1' and ck'event then
		readd1_o <=readd1_i;
		readd2_o <=readd2_i;
		eignex_o <=eignex_i;
		rt_o     <=rt_i;
		rd_o     <=rd_i;
		func_o   <=func_i;
		mem_to_reg_o <=mem_to_reg_i;
		reg_write_o  <=reg_write_i;
		memread_o    <=memread_i;
		memwrite_o   <=memwrite_i;
		alusrc_o     <=alusrc_i;
		regdest_o    <=regdest_i;
		aluop_o      <=aluop_i;
	end if;
  end process;
end beh;
