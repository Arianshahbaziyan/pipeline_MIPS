------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main is
  port(ck: in std_logic);
end main;

architecture beh of main is

	signal instr_address: std_logic_vector(31 downto 0); 
	signal next_address: std_logic_vector(31 downto 0); 
	signal instruction0,instruction1: std_logic_vector(31 downto 0); 
	signal FIBsqu: std_logic_vector(31 downto 0);
	signal write_data, shifted_immediate, alu_in_2, alu_result, alu_result_exmem, alu_result_memwb, last_instr_address, incremented_address, add2_result, mux4_result, concatenated_pc_and_jump_address, mem_read_data, mem_read_data_memwb: std_logic_vector(31 downto 0):= "00000000000000000000000000000000"; -- vhdl does not allow me to port map " y => incremented_address(31 downto 28) & shifted_jump_address "

	signal read_data_1,read_data_1_idex, read_data_2, read_data_2_idex, read_data_2_exmem, extended_immediate,extended_immediate_idex : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";

	signal shifted_jump_address: std_logic_vector(27 downto 0);
	signal jump_address: std_logic_vector(25 downto 0);
	signal immediate: std_logic_vector(15 downto 0);

	signal opcode, funct, funct_idex : std_logic_vector(5 downto 0);
	signal rs, rt, rt_idex, rd, rd_idex, shampt, write_reg, write_reg_exmem, write_reg_memwb: std_logic_vector(4 downto 0);

	signal alu_control_fuct: std_logic_vector(3 downto 0);

	signal reg_dest, reg_dest_idex,  mem_read, mem_read_idex, mem_read_exmem, mem_to_reg, mem_to_reg_idex, mem_to_reg_exmem, mem_to_reg_memwb, mem_write, mem_write_idex, mem_write_exmem, alu_src, alu_src_idex, reg_write, reg_write_idex, reg_write_exmem, reg_write_memwb : std_logic:= '0';
	signal alu_op, alu_op_idex: std_logic_vector(1 downto 0);
	signal jump, branch, alu_zero, branch_and_alu_zero: std_logic:= '0';

	 -- Enum for checking if the instructions have loaded
	type state is (loading, running, done);
	signal s: state:= loading;
	-- The clock for the other components; starts when the state is ready
	signal en: std_logic:= '0';
-------------------------------------------------------------------------------------------------
	component pc
		port (
			ck: in std_logic;
			address_to_load: in std_logic_vector(31 downto 0);
			current_address: out std_logic_vector(31 downto 0));
	end component;
---------------------------------------------------------------------------------------------------------------------
	component ifid_reg
 	  port (ck    : in std_logic;
		inst_i: in std_logic_vector(31 downto 0);
		inst_o: out std_logic_vector(31 downto 0));
	end component;
---------------------------------------------------------------------------------------------------------------------
	component idex_reg
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
	end component;
---------------------------------------------------------------------------------------------------------------------
	component exmem_reg
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
	end component;
---------------------------------------------------------------------------------------------------------------------
	component memwb_reg
	  port (ck    : in std_logic;
		aluresualt_i : in  std_logic_vector(31 downto 0);
		readdata_i   : in  std_logic_vector(31 downto 0);
		rtrd_i       : in  std_logic_vector(4 downto 0);
		mem_to_reg_i : in  std_logic;
		reg_write_i  : in  std_logic;
		-----------------------------------------------------
		aluresualt_o : out std_logic_vector(31 downto 0);
		readdata_o   : out std_logic_vector(31 downto 0);
		rtrd_o       : out std_logic_vector(4 downto 0);
		mem_to_reg_o : out  std_logic;
		reg_write_o  : out  std_logic);
	end component;
---------------------------------------------------------------------------------------------------------------------
	component instruction_memory
		port (
			read_address: in STD_LOGIC_VECTOR (31 downto 0);
			instruction, last_instr_address: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component registers
		port (ck: in std_logic;
			reg_write: in std_logic;
			read_reg_1, read_reg_2, write_reg: in std_logic_vector(4 downto 0);
			write_data: in std_logic_vector(31 downto 0);
			read_data_1, read_data_2: out std_logic_vector(31 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component control
		port (
			opcode: in std_logic_vector(5 downto 0);
			reg_dest,jump, branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write: out std_logic;
			alu_op: out std_logic_vector(1 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component mux
		generic (n: natural:= 1);
		port (
			x,y: in std_logic_vector(n-1 downto 0);
			s: in std_logic;
			z: out std_logic_vector(n-1 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component alu_control
		port (
			funct: in std_logic_vector(5 downto 0);
			alu_op: in std_logic_vector(1 downto 0);
			alu_control_fuct: out std_logic_vector(3 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component sign_extend
		port (
			x: in std_logic_vector(15 downto 0);
			y: out std_logic_vector(31 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component alu
	  port (in_1 :in std_logic_vector(31 downto 0);
		in_2 :in std_logic_vector(31 downto 0);
		alu_control_fuct: in std_logic_vector(3 downto 0);
		zero            : out std_logic;
		alu_result      : out std_logic_vector(31 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component shifter
		generic (n1: natural:= 32; n2: natural:= 32; k: natural:= 2);
		port (
			x: in std_logic_vector(n1-1 downto 0);
			y: out std_logic_vector(n2-1 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
	component adder 
		port (
			x,y: in std_logic_vector(31 downto 0);
			z: out std_logic_vector(31 downto 0));		
	end component;
-------------------------------------------------------------------------------------------------	
	component memory is
	port (
		address, write_data: in STD_LOGIC_VECTOR (31 downto 0);
		MemWrite, MemRead,ck: in STD_LOGIC;
		fibsqu  : out STD_LOGIC_VECTOR (31 downto 0);
		read_data: out STD_LOGIC_VECTOR (31 downto 0));
	end component;
-------------------------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------------------------
	process(ck)
		begin
		case s is
			when running =>
				en <= ck;
			when others =>
				en <= '0';
		end case;

		if ck='1' and ck'event then
			case s is
				when loading =>
					s <= running; -- give 1 cycle to load the instructions into memory
				when running =>
					if instr_address > last_instr_address then
						s <= done; -- stop moving the pc after it has passed the last instruction
						en <= '0';
					end if;
				when others =>
					null;
			end case;
		end if;
	end process;
-------------------------------------------------------------------------------------------------
	opcode <= instruction1(31 downto 26);
	rs <= instruction1(25 downto 21);
	rt <= instruction1(20 downto 16);
	rd <= instruction1(15 downto 11);
	shampt <= instruction1(10 downto 6);
	funct <= instruction1(5 downto 0);
	immediate <= instruction1(15 downto 0);
	jump_address <= instruction1(25 downto 0);
-------------------------------------------------------------------------------------------------
	Prog_Count: pc port map ( ck => en, address_to_load => incremented_address, current_address => instr_address); 
-------------------------------------------------------------------------------------------------
	IM: instruction_memory port map (read_address =>instr_address, instruction => instruction0, last_instr_address => last_instr_address);
-------------------------------------------------------------------------------------------------
	ifid: ifid_reg port map (ck     => en, 
				 inst_i => instruction0, 
				 inst_o => instruction1);
-------------------------------------------------------------------------------------------------
	CONTROL1: control port map (
		opcode => opcode,
		reg_dest => reg_dest, 
		jump => jump,
		branch => branch, 
		mem_read => mem_read, 
		mem_to_reg => mem_to_reg,
		mem_write => mem_write,
		alu_src => alu_src,
		reg_write => reg_write,
		alu_op => alu_op );
-------------------------------------------------------------------------------------------------
	-- This mux is going into Register's Write Register port; chooses between rt and rd
	MUX1: mux generic map(5) port map (
		x => rt_idex, 
		y => rd_idex, 
		s => reg_dest_idex,
		z => write_reg);
-------------------------------------------------------------------------------------------------
	REG: registers port map (
		ck => en,
		reg_write   => reg_write_memwb,
		read_reg_1  => rs,
		read_reg_2  => rt,
		write_reg   => write_reg_memwb, 
		write_data  => write_data, 
		read_data_1 => read_data_1, 
		read_data_2 => read_data_2);
-------------------------------------------------------------------------------------------------
	SGN_EXT: sign_extend port map (immediate, extended_immediate);
-------------------------------------------------------------------------------------------------
	idex: idex_reg port map (ck    => en,
				readd1_i =>read_data_1,
				readd2_i =>read_data_2,
				eignex_i =>extended_immediate,
				rt_i    =>rt,
				rd_i    =>rd,
				func_i  =>funct,
				mem_to_reg_i =>mem_to_reg,
				reg_write_i  =>reg_write,
				memread_i    =>mem_read,
				memwrite_i   =>mem_write,
				alusrc_i     =>alu_src,
				regdest_i    =>reg_dest,
				aluop_i      =>alu_op,
				-----------------------------------------------------
				readd1_o =>read_data_1_idex,
				readd2_o =>read_data_2_idex,
				eignex_o =>extended_immediate_idex,
				rt_o     =>rt_idex,
				rd_o     =>rd_idex,
				func_o   =>funct_idex,
				mem_to_reg_o =>mem_to_reg_idex,
				reg_write_o  =>reg_write_idex,
				memread_o    =>mem_read_idex,
				memwrite_o   =>mem_write_idex,
				alusrc_o     =>alu_src_idex,
				regdest_o    =>reg_dest_idex,
				aluop_o      =>alu_op_idex);
-------------------------------------------------------------------------------------------------
	ALU_CONTRL: alu_control port map (funct  => funct_idex,
					  alu_op => alu_op_idex,
					  alu_control_fuct => alu_control_fuct);
-------------------------------------------------------------------------------------------------
	MUX2: mux generic map(32) port map (x => read_data_2_idex, 
					    y => extended_immediate_idex, 
				            s => alu_src_idex,
				            z => alu_in_2);
-------------------------------------------------------------------------------------------------
	ALU1: alu port map (in_1 => read_data_1_idex,
		            in_2 => alu_in_2,
			    alu_control_fuct => alu_control_fuct,
                            zero => alu_zero,
			    alu_result => alu_result);
-------------------------------------------------------------------------------------------------
	exmem: exmem_reg port map (ck    => en,
				aluresualt_i => alu_result,
				readd2_i     => read_data_2_idex,
				rtrd_i       => write_reg,
				mem_to_reg_i => mem_to_reg_idex,
				reg_write_i  => reg_write_idex,
				memread_i    => mem_read_idex,
				memwrite_i   => mem_write_idex,
				-----------------------------------------------------
				aluresualt_o => alu_result_exmem,
				readd2_o     => read_data_2_exmem,
				rtrd_o       => write_reg_exmem,
				mem_to_reg_o => mem_to_reg_exmem,
				reg_write_o  => reg_write_exmem,
				memread_o    => mem_read_exmem,
				memwrite_o   => mem_write_exmem);
-------------------------------------------------------------------------------------------------
	-- This mux is going into the Register's Write Data; chooses between the alu_result and read_data from data memory
	MUX3: mux generic map (32) port map (
		x => alu_result_memwb, 
		y => mem_read_data_memwb,
		s => mem_to_reg_memwb,
		z => write_data);
-------------------------------------------------------------------------------------------------
	-- The +4 adder for the pc
	ADD1: adder port map (
		x => instr_address,
		y => "00000000000000000000000000000100",
		z => incremented_address);
-------------------------------------------------------------------------------------------------	
	MEM: memory port map (ck => en,
		address => alu_result_exmem,
		write_data => read_data_2_exmem,
		MemWrite => mem_write_exmem,
		MemRead => mem_read_exmem,
		fibsqu => FIBsqu,
		read_data => mem_read_data);
-------------------------------------------------------------------------------------------------	
	memwb: memwb_reg port map (ck    => en,
				aluresualt_i => alu_result_exmem,
				readdata_i   => mem_read_data,
				rtrd_i       => write_reg_exmem,
				mem_to_reg_i => mem_to_reg_exmem,
				reg_write_i  => reg_write_exmem,
				-----------------------------------------------------
				aluresualt_o => alu_result_memwb,
				readdata_o   => mem_read_data_memwb,
				rtrd_o       => write_reg_memwb,
				mem_to_reg_o => mem_to_reg_memwb,
				reg_write_o  => reg_write_memwb);

end beh;