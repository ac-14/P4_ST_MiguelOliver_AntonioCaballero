library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sma_filter is
    generic (
        N     : integer := 8;
        WIDTH : integer := 8
    );
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        din  : in  std_logic_vector(WIDTH-1 downto 0);
        load : in  std_logic;
        dout : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture rtl of sma_filter is
    function log2(n : integer) return integer is
        variable result : integer := 0;
        variable value  : integer := n - 1;
    begin
        while value > 0 loop
            value := value / 2;
            result := result + 1;
        end loop;
        return result;
    end function;

    constant MAX_N : integer := 16;
    constant SUM_WIDTH : integer := WIDTH + log2(MAX_N);
    type data_array is array (0 to N-1) of std_logic_vector(WIDTH-1 downto 0);
    signal data_buffer : data_array := (others => (others => '0'));
    signal sum         : unsigned(SUM_WIDTH-1 downto 0) := (others => '0');
    signal count       : integer range 0 to N := 0;
    signal index       : integer range 0 to N-1 := 0;
begin

    process(clk, rst)
    begin
        if rst = '1' then
            data_buffer <= (others => (others => '0'));
            sum         <= (others => '0');
            count       <= 0;
            index       <= 0;
            dout        <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                sum <= sum - unsigned(data_buffer(index)) + unsigned(din);
                data_buffer(index) <= din;
                index <= (index + 1) mod N;

                if count < N then
                    count <= count + 1;
                end if;
            end if;

            if count > 0 then
                dout <= std_logic_vector((sum + to_unsigned(count/2, sum'length)) / to_unsigned(count, sum'length));
            else
                dout <= (others => '0');
            end if;
        end if;
    end process;

end architecture;