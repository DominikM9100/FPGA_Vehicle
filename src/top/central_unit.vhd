library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity CENTRAL_UNIT is
generic (
REG_LEN         : integer;
US_FRONT_NBR    : integer;
US_BACK_NBR     : integer );
port (
i_rst           : in  std_logic;
i_clk           : in  std_logic;
i_dc_motor_pin  : in  std_logic; -- pwm signal from dc motor
i_us_stop_f     : in  std_logic_vector(US_FRONT_NBR-1 downto 0); -- signal from ultrasonic sensors
i_us_stop_b     : in  std_logic_vector(US_BACK_NBR-1 downto 0); -- signal from ultrasonic sensors
i_mode          : in  std_logic_vector(REG_LEN-1 downto 0); -- decoded mode in which the vehichle should be 
i_servo_pos     : in  std_logic_vector(REG_LEN-1 downto 0); -- position from decoder about position of servos
i_wheel_v       : in  std_logic_vector(REG_LEN-1 downto 0); -- velovity of wheel, value from decoder
i_turn_l        : in  std_logic; -- '1' when the vehicle turns left
i_turn_r        : in  std_logic; -- '1' when the vehicle turns right
o_en_us_f       : out std_logic_vector(US_FRONT_NBR-1 downto 0); -- signals to enable front ultrasonic sensors
o_en_us_b       : out std_logic_vector(US_BACK_NBR-1 downto 0); -- signals to enable back ultrasonic sensors
o_dc_motor_data : out std_logic_vector(REG_LEN-1 downto 0); -- velocity of wheels
o_dc_motor_pin  : out std_logic_vector(7 downto 0); -- pins to dc motors
o_servo_pos     : out std_logic_vector(REG_LEN*4-1 downto 0) ); -- data for servos
end;



architecture arch of CENTRAL_UNIT is

-- states definition -------------------------------------------------------
type STATES is ( STOP, FORWARD, BACKWARD, SPIN_LEFT, SPIN_RIGHT, STOP_AFTER_DETECTION, TRANS_TO_FORWARD, TRANS_TO_BACKWARD );
signal CUR_STATE      : STATES := STOP;
signal NEXT_STATE     : STATES := STOP;
signal NEXT_STATE_REG : STATES := STOP;
--signal NEXT_STATE_REG2 : STATES := STOP;

-- constants for servo position --------------------------------------------
constant servo_mid  : std_logic_vector(REG_LEN-1 downto 0) := x"13";
constant servo_45_l : std_logic_vector(REG_LEN-1 downto 0) := x"1b";
constant servo_45_r : std_logic_vector(REG_LEN-1 downto 0) := x"0b";

-- signals to control peripherals ------------------------------------------
signal servo_lf    : std_logic_vector(REG_LEN-1 downto 0) := servo_mid;
signal servo_rf    : std_logic_vector(REG_LEN-1 downto 0) := servo_mid;
signal servo_lb    : std_logic_vector(REG_LEN-1 downto 0) := servo_mid;
signal servo_rb    : std_logic_vector(REG_LEN-1 downto 0) := servo_mid;
signal dc_motor_lf : std_logic_vector(1 downto 0) := (others=>'0');
signal dc_motor_rf : std_logic_vector(1 downto 0) := (others=>'0');
signal dc_motor_lb : std_logic_vector(1 downto 0) := (others=>'0');
signal dc_motor_rb : std_logic_vector(1 downto 0) := (others=>'0');

-- modes registers ---------------------------------------------------------
signal r_cur_mode  : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');
signal r_prev_mode : std_logic_vector(REG_LEN-1 downto 0) := (others=>'0');

-- velocity registers ------------------------------------------------------
signal r_des_v : unsigned(REG_LEN-1 downto 0) := x"01";
signal r_v     : unsigned(REG_LEN-1 downto 0) := x"01";

-- counters ----------------------------------------------------------------
signal cnt_spin : integer range 0 to 3 := 0;
signal cnt_stop : integer range 0 to 7 := 0;

-- counters impulses -------------------------------------------------------
signal impulse_spin_cnt   : std_logic := '0';
signal impulse_stop_cnt   : std_logic := '0';
signal impulse_spin_v_cnt : std_logic := '0';
signal impulse_stop_v_cnt : std_logic := '0';
signal impulse_trans      : std_logic := '0';

-- control counters and prescalers -----------------------------------------
signal change_state     : std_logic := '0';
signal stop_pres_spin   : std_logic := '0';
signal stop_pres_stop   : std_logic := '0';
signal stop_pres_v      : std_logic := '1';
signal rst_cnt          : std_logic := '0';
signal rst_pres_stop    : std_logic := '0';
signal rst_pres_spin    : std_logic := '0';
signal stop_pres_stop_v : std_logic := '0';
signal stop_pres_spin_v : std_logic := '0';
signal rst_pres_stop_v  : std_logic := '0';
signal rst_pres_spin_v  : std_logic := '0';
signal stop_pres_trans  : std_logic := '0';
signal rst_pres_trans   : std_logic := '0';

-- other signals -----------------------------------------------------------
signal condition_to_f   : std_logic := '0';
signal condition_to_b   : std_logic := '0';

begin



-- signals to peripherals
o_servo_pos(31 downto 24) <= servo_lf;
o_servo_pos(23 downto 16) <= servo_rf;
o_servo_pos(15 downto 8) <= servo_lb;
o_servo_pos(7 downto 0) <= servo_rb;
o_dc_motor_pin(7 downto 6) <= dc_motor_lf;
o_dc_motor_pin(5 downto 4) <= dc_motor_rf;
o_dc_motor_pin(3 downto 2) <= dc_motor_lb;
o_dc_motor_pin(1 downto 0) <= dc_motor_rb;

-- signals for resetting prescalers
rst_pres_stop <= stop_pres_stop or i_rst;
rst_pres_spin <= stop_pres_spin or i_rst;
rst_pres_stop_v <= stop_pres_stop_v or i_rst;
rst_pres_spin_v <= stop_pres_spin_v or i_rst;
rst_pres_trans <= stop_pres_trans or i_rst;

-- signals for transition to FORWARD or BACKGWARD under an obstacle detection
condition_to_f <= ((i_us_stop_f(4) or i_us_stop_f(3)) and not(i_us_stop_f(2)) and not(i_us_stop_f(1)) and not(i_us_stop_f(0)) and i_turn_r) or ((i_us_stop_f(1) or i_us_stop_f(0)) and not(i_us_stop_f(4)) and not(i_us_stop_f(3)) and not(i_us_stop_f(2)) and i_turn_l);
condition_to_b <= ((i_us_stop_b(4) or i_us_stop_b(3)) and not(i_us_stop_b(2)) and not(i_us_stop_b(1)) and not(i_us_stop_b(0)) and i_turn_r) or ((i_us_stop_b(1) or i_us_stop_b(0)) and not(i_us_stop_b(4)) and not(i_us_stop_b(3)) and not(i_us_stop_b(2)) and i_turn_l);



I_PRES_STOP_CNT: entity work.PRESCALER
generic map (
LEN       => 22 ) -- 20
port map (
i_rst     => rst_pres_stop,
i_clk     => i_clk,
o_impulse => impulse_stop_cnt );



I_PRES_STOP_V_CNT: entity work.PRESCALER
generic map (
LEN       => 21 ) -- 19 -- at least one less then I_PRES_STOP_CNT
port map (
i_rst     => rst_pres_stop_v,
i_clk     => i_clk,
o_impulse => impulse_stop_v_cnt );



I_PRES_SPIN_CNT: entity work.PRESCALER
generic map (
LEN       => 20 ) -- 22
port map (
i_rst     => rst_pres_spin,
i_clk     => i_clk,
o_impulse => impulse_spin_cnt );



I_PRES_SPIN_V_CNT: entity work.PRESCALER
generic map (
LEN       => 19 ) -- 21 -- at least one less then I_PRES_SPIN_CNT
port map (
i_rst     => rst_pres_spin_v,
i_clk     => i_clk,
o_impulse => impulse_spin_v_cnt );



I_PRES_TRANS: entity work.PRESCALER
generic map (
LEN       => 22 ) -- 21 -- adjust the langth according to the measurment period of ultrasonic sensors
port map (
i_rst     => rst_pres_trans,
i_clk     => i_clk,
o_impulse => impulse_trans );



STATES_COUNTERS: process (i_rst, i_clk, rst_cnt)
begin
  if i_rst='1' then -- set values of counters if there is a reset from the board
    cnt_spin <= 0;
    cnt_stop <= 0;
  elsif rising_edge(i_clk) then
    case (CUR_STATE) is
      when STOP =>
        cnt_spin <= 0;
        if impulse_stop_cnt='1' then -- check if there is an impulse to increment the counter
          if cnt_stop<7 then
            cnt_stop <= cnt_stop + 1; -- increment the value of the counter
          end if;
        end if;
      when SPIN_LEFT | SPIN_RIGHT =>
        cnt_stop <= 0;
        if impulse_spin_cnt='1' then -- check if there is an impulse to increment the counter
          if cnt_spin<3 then
            cnt_spin <= cnt_spin + 1; -- increment the value of the counter
          end if;
        end if;        
      when others =>
        cnt_spin <= 0;
        cnt_stop <= 0;
    end case;
  end if;
end process;



CHANGE_STATES: process (i_rst, i_clk)
  variable or_gate_f : std_logic := '0';
  variable or_gate_b : std_logic := '0';
begin
  if i_rst='1' then
    NEXT_STATE <= STOP;
    CUR_STATE <= STOP;
  elsif rising_edge(i_clk) then

    or_gate_f := i_us_stop_f(0);
    for i in 1 to US_FRONT_NBR-1 loop
      or_gate_f := or_gate_f or i_us_stop_f(i);
    end loop;
    
    or_gate_b := i_us_stop_b(0);
    for i in 1 to US_BACK_NBR-1 loop
      or_gate_b := or_gate_b or i_us_stop_b(i);
    end loop;

    case (CUR_STATE) is      
      when FORWARD =>
        r_cur_mode <= x"02";

		  if condition_to_f='1' then
          NEXT_STATE <= FORWARD;
        elsif or_gate_f='1' then
          NEXT_STATE <= STOP_AFTER_DETECTION;
        elsif i_mode(0)='1' then
          NEXT_STATE <= STOP;
        end if;
        --if or_gate_f='1' then
          --NEXT_STATE <= STOP_AFTER_DETECTION;
        --elsif i_mode(0)='1' then -- if i_mode(0)='1' or or_gate_f='1' then
          --NEXT_STATE <= STOP;
        --end if;

      when BACKWARD =>
        r_cur_mode <= x"04";

		  if condition_to_b='1' then
          NEXT_STATE <= BACKWARD;
        elsif or_gate_b='1' then
          NEXT_STATE <= STOP_AFTER_DETECTION;
        elsif i_mode(0)='1' then
          NEXT_STATE <= STOP;
        end if;
        --if or_gate_b='1' then
          --NEXT_STATE <= STOP_AFTER_DETECTION;
        --elsif i_mode(0)='1' then -- if i_mode(0)='1' or or_gate_b='1' then
          --NEXT_STATE <= STOP;
        --end if;

      when SPIN_LEFT =>
        r_cur_mode <= x"08";
        if i_mode(0)='1' and change_state='1' then
          NEXT_STATE <= STOP;
        end if;

      when SPIN_RIGHT =>
        r_cur_mode <= x"10";
        if i_mode(0)='1' and change_state='1' then
          NEXT_STATE <= STOP;
        end if;

      when TRANS_TO_FORWARD =>
        r_cur_mode <= x"20";

		  if impulse_trans='1' and condition_to_f='1' then
          NEXT_STATE <= FORWARD;
        elsif impulse_trans='1' and or_gate_f='1' then
          NEXT_STATE <= STOP;
        elsif impulse_trans='1' and or_gate_f='0' then
          NEXT_STATE <= FORWARD;
        end if;
        --if impulse_trans='1' and and_gate_f='1' then
          --NEXT_STATE <= FORWARD;
        --elsif impulse_trans='1' and and_gate_f='0' then
          --NEXT_STATE <= STOP;
        --end if;

      when TRANS_TO_BACKWARD =>
        r_cur_mode <= x"40";

		  if impulse_trans='1' and condition_to_b='1' then
          NEXT_STATE <= BACKWARD;
        elsif impulse_trans='1' and or_gate_b='1' then
          NEXT_STATE <= STOP;
        elsif impulse_trans='1' and or_gate_b='0' then
          NEXT_STATE <= BACKWARD;
        end if;
        --if impulse_trans='1' and and_gate_b='1' then
          --NEXT_STATE <= BACKWARD;
        --elsif impulse_trans='1' and and_gate_b='0' then
          --NEXT_STATE <= STOP;
        --end if;

      when STOP_AFTER_DETECTION =>
        r_cur_mode <= x"80";
        NEXT_STATE <= STOP;
  
      when others => -- CUR_STATE = STOP
        r_cur_mode <= x"01";
        if i_mode(1)='1' and change_state='1' then -- go to transition mode, check area for an obstacle --if i_mode(1)='1' and and_gate_f='1' and change_state='1' then
          NEXT_STATE_REG <= TRANS_TO_FORWARD;
          NEXT_STATE <= NEXT_STATE_REG;
        elsif i_mode(2)='1' and change_state='1' then -- go to transition mode, check area for an obstacle --elsif i_mode(2)='1' and and_gate_b='1' and change_state='1' then
          NEXT_STATE_REG <= TRANS_TO_BACKWARD;
          NEXT_STATE <= NEXT_STATE_REG;
        elsif i_mode(3)='1' and change_state='1' then
          NEXT_STATE <= SPIN_LEFT;
        elsif i_mode(4)='1' and change_state='1' then
          NEXT_STATE <= SPIN_RIGHT;
		  --elsif or_gate_f='1' or or_gate_b='1' then -- stop the vehicle instantly if there was an obstacle detected
		    --NEXT_STATE <= STOP_AFTER_DETECTION;
        --else
          --NEXT_STATE <= STOP;
        end if;
    end case; -- end case (CUR_STATE)
		
    if NEXT_STATE/=CUR_STATE then -- check if the state was changed
      CUR_STATE <= NEXT_STATE; -- change the current state
      NEXT_STATE_REG <= STOP; -- change the reg state
      r_prev_mode <= r_cur_mode; -- update the previos mode register  
    end if;
  end if;
end process;



STATES_DESCRIPTION: process (i_clk)
begin
  if rising_edge(i_clk) then
    case (CUR_STATE) is
      when FORWARD =>
        o_en_us_f <= (others=>'1'); -- enable front ultrasonic sensors
        o_en_us_b <= (others=>'0'); -- disable back ultrasonic sensors
        change_state <= '0'; -- give no permission to change state (drives only STOP state)
        stop_pres_stop <= '1'; -- stop the prescaler
        stop_pres_spin <= '1'; -- stop the prescaler
        stop_pres_trans <= '1'; -- disable the counter for transition
        rst_cnt <= '1'; -- prevent counter from counting
        servo_lf <= i_servo_pos; -- pass decoded value to servo
        servo_rf <= i_servo_pos; -- pass decoded value to servo
        --servo_lb <= i_servo_pos; -- set fixed value for servo
        --servo_rb <= i_servo_pos; -- set fixed value for servo
        servo_lb <= servo_mid; -- set fixed value for servo
        servo_rb <= servo_mid; -- set fixed value for servo
        dc_motor_lf <= '0' & i_dc_motor_pin; -- channel left front dc motor pin
        dc_motor_rf <= i_dc_motor_pin & '0'; -- channel right front dc motor pin
        dc_motor_lb <= '0' & i_dc_motor_pin; -- channel left back dc motor pin
        dc_motor_rb <= i_dc_motor_pin & '0'; -- channel right back dc motor pin
        r_des_v  <= unsigned(i_wheel_v); -- assign the desired value of speed
        o_dc_motor_data <= std_logic_vector(r_v); -- give volcity value to dc motor unit
      
      when BACKWARD =>
        o_en_us_f <= (others=>'0'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'1'); -- enable back ultrasonic sensors
        change_state <= '0'; -- give no permission to change state (drives only STOP state)
        stop_pres_stop <= '1'; -- stop the prescaler
        stop_pres_spin <= '1'; -- stop the prescaler
        stop_pres_trans <= '1'; -- disable the counter for transition
        rst_cnt <= '1'; -- prevent counter from counting
        servo_lf <= i_servo_pos; -- pass decoded value to servo
        servo_rf <= i_servo_pos; -- pass decoded value to servo
        --servo_lb <= i_servo_pos; -- set fixed value for servo
        --servo_rb <= i_servo_pos; -- set fixed value for servo
        servo_lb <= servo_mid; -- set fixed value for servo
        servo_rb <= servo_mid; -- set fixed value for servo
        dc_motor_lf <= i_dc_motor_pin & '0'; -- channel left front dc motor pin
        dc_motor_rf <= '0' & i_dc_motor_pin; -- channel right front dc motor pin
        dc_motor_lb <= i_dc_motor_pin & '0'; -- channel left back dc motor pin
        dc_motor_rb <= '0' & i_dc_motor_pin; -- channel right back dc motor pin
        r_des_v  <= unsigned(i_wheel_v); -- assign the desired value of speed
        o_dc_motor_data <= std_logic_vector(r_v); -- give volcity value to dc motor unit
                
      when SPIN_LEFT =>
        o_en_us_f <= (others=>'0'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'0'); -- disable back ultrasonic sensors
        r_des_v <= unsigned(i_wheel_v); -- assign the desired value of speed
        stop_pres_stop <= '1'; -- stop the stop counter
        stop_pres_trans <= '1'; -- disable the counter for transition
        case (cnt_spin) is
          when 0 => -- make sure that the vehicle is not moving
            stop_pres_spin <= '0'; -- stop the prescaler
            dc_motor_lf <= "00"; -- stop the wheel
            dc_motor_rf <= "00"; -- stop the wheel
            dc_motor_lb <= "00"; -- stop the wheel
            dc_motor_rb <= "00"; -- stop the wheel
            change_state <= '0'; -- give no permission to change state
          when 1|2 =>
            servo_lf <= servo_45_r; -- set the fixed value for servo
            servo_rf <= servo_45_l; -- set the fixed value for servo
            servo_lb <= servo_45_l; -- set the fixed value for servo
            servo_rb <= servo_45_r; -- set the fixed value for servo
            change_state <= '0'; -- give no permission to change state
          when others =>
            stop_pres_spin <= '1'; -- stop the prescaler
            change_state <= '1'; -- enable the change of state
            o_dc_motor_data <= std_logic_vector(r_v); -- pass the speed value
            dc_motor_lf <= i_dc_motor_pin & '0'; -- channel left front dc motor pin
            dc_motor_rf <= i_dc_motor_pin & '0'; -- channel right front dc motor pin
            dc_motor_lb <= i_dc_motor_pin & '0'; -- channel left back dc motor pin
            dc_motor_rb <= i_dc_motor_pin & '0'; -- channel right back dc motor pin
        end case; -- end case (cnt_spin)

      when SPIN_RIGHT =>
        o_en_us_f <= (others=>'0'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'0'); -- disable back ultrasonic sensors
        rst_cnt <= '0'; -- enable the counter
        r_des_v <= unsigned(i_wheel_v); -- assign the desired value of speed
        stop_pres_stop <= '1'; -- stop the stop counter
        stop_pres_trans <= '1'; -- disable the counter for transition
        case (cnt_spin) is
          when 0 => -- make sure that the vehicle is not moving
            stop_pres_spin <= '0'; -- stop the prescaler
            dc_motor_lf <= "00"; -- stop the wheel
            dc_motor_rf <= "00"; -- stop the wheel
            dc_motor_lb <= "00"; -- stop the wheel
            dc_motor_rb <= "00"; -- stop the wheel
            change_state <= '0'; -- give no permission to change state
          when 1|2 =>
            servo_lf <= servo_45_r; -- set the fixed value for servo
            servo_rf <= servo_45_l; -- set the fixed value for servo
            servo_lb <= servo_45_l; -- set the fixed value for servo
            servo_rb <= servo_45_r; -- set the fixed value for servo
          when others =>
            stop_pres_spin <= '1'; -- stop the prescaler
            change_state <= '1'; -- enable the change of state
            o_dc_motor_data <= std_logic_vector(r_v); -- pass the speed value
            dc_motor_lf <= '0' & i_dc_motor_pin; -- channel left front dc motor pin
            dc_motor_rf <= '0' & i_dc_motor_pin; -- channel right front dc motor pin
            dc_motor_lb <= '0' & i_dc_motor_pin; -- channel left back dc motor pin
            dc_motor_rb <= '0' & i_dc_motor_pin; -- channel right back dc motor pin
        end case; -- end case (cnt_spin)

      when TRANS_TO_FORWARD =>
        o_en_us_f <= (others=>'1'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'0'); -- disable back ultrasonic sensors
        stop_pres_trans <= '0'; -- enable the counter for transition
        rst_cnt <= '0'; -- enable the counter

      when TRANS_TO_BACKWARD =>
        o_en_us_f <= (others=>'0'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'1'); -- disable back ultrasonic sensors
        stop_pres_trans <= '0'; -- enable the counter for transition
        rst_cnt <= '1'; -- reset the counter

      when STOP_AFTER_DETECTION =>
        o_en_us_f <= (others=>'0'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'0'); -- disable back ultrasonic sensors
        dc_motor_lf <= "00"; -- stop dc motor
        dc_motor_rf <= "00"; -- stop dc motor
        dc_motor_lb <= "00"; -- stop dc motor
        dc_motor_rb <= "00"; -- stop dc motor

      when others => -- CUR_STATE = STOP
        o_en_us_f <= (others=>'0'); -- disable front ultrasonic sensors
        o_en_us_b <= (others=>'0'); -- disable back ultrasonic sensors
        rst_cnt <= '0'; -- enable the counter
        r_des_v <= unsigned(i_wheel_v); -- set the desired speed
        stop_pres_spin <= '1'; -- stop the spin counter
        case (cnt_stop) is
          when 0|1|2 =>
            stop_pres_stop <= '0'; -- enable the prescaler
            change_state <= '0'; -- disable the change of state
            o_dc_motor_data <= std_logic_vector(r_v); -- pass the velocity data to dc motor unit
            stop_pres_trans <= '1'; -- disable the counter for transition
            case (to_integer(unsigned(r_prev_mode))) is -- rightfully channel the dc motor pins so the vehicle could brake according to the previous mode
              when 16#02# => -- FORWARD
                dc_motor_lf <= '0' & i_dc_motor_pin;
                dc_motor_rf <= i_dc_motor_pin & '0';
                dc_motor_lb <= '0' & i_dc_motor_pin;
                dc_motor_rb <= i_dc_motor_pin & '0';
              when 16#04# => -- BACKWARD
                dc_motor_lf <= i_dc_motor_pin & '0';
                dc_motor_rf <= '0' & i_dc_motor_pin;
                dc_motor_lb <= i_dc_motor_pin & '0';
                dc_motor_rb <= '0' & i_dc_motor_pin;
              when 16#08# => -- SPIN_LEFT
                dc_motor_lf <= i_dc_motor_pin & '0';
                dc_motor_rf <= i_dc_motor_pin & '0';
                dc_motor_lb <= i_dc_motor_pin & '0';
                dc_motor_rb <= i_dc_motor_pin & '0';
              when 16#10# => -- SPIN RIGHT
                dc_motor_lf <= '0' & i_dc_motor_pin;
                dc_motor_rf <= '0' & i_dc_motor_pin;
                dc_motor_lb <= '0' & i_dc_motor_pin;
                dc_motor_rb <= '0' & i_dc_motor_pin;
              when others => -- STOP or STOP_AFTER_DETECTION
                dc_motor_lf <= "00"; -- stop the wheel
                dc_motor_rf <= "00"; -- stop the wheel
                dc_motor_lb <= "00"; -- stop the wheel
                dc_motor_rb <= "00"; -- stop the wheel
            end case; -- end case (r_prev_mode)
          when 3|4 => -- stop the vehicle
            dc_motor_lf <= "00"; -- stop the wheel
            dc_motor_rf <= "00"; -- stop the wheel
            dc_motor_lb <= "00"; -- stop the wheel
            dc_motor_rb <= "00"; -- stop the wheel
          when 5|6 => -- set default position of servos
            servo_lf <= servo_mid; -- set fixed value for servo position
            servo_rf <= servo_mid; -- set fixed value for servo position
            servo_lb <= servo_mid; -- set fixed value for servo position
            servo_rb <= servo_mid; -- set fixed value for servo position
          when others =>
            stop_pres_stop <= '1'; -- stop the prescaler
            change_state <= '1'; -- enable the change of state
        end case; -- end case (cnt_stop)
     end case; -- end case (CUR_STATE)
  end if;
end process;



CHANGE_SPEED: process (i_clk, r_des_v, r_v, CUR_STATE)
begin
  if CUR_STATE=STOP or CUR_STATE=FORWARD or CUR_STATE=BACKWARD then
    stop_pres_spin_v <= '1';
    if r_v=r_des_v then
      stop_pres_stop_v <= '1';
    else
      stop_pres_stop_v <= '0'; 
    end if;
  elsif CUR_STATE=SPIN_LEFT or CUR_STATE=SPIN_RIGHT then
    stop_pres_stop_v <= '1';
    if r_v=r_des_v then
      stop_pres_spin_v <= '1';
    else
      stop_pres_spin_v <= '0'; 
    end if;
  else
    stop_pres_spin_v <= '1';
    stop_pres_stop_v <= '1';
  end if;

  if rising_edge(i_clk) then
    if impulse_stop_v_cnt='1' or impulse_spin_v_cnt='1' then
      if r_v>r_des_v then
        r_v <= '0' & r_v(REG_LEN-1 downto 1); -- shift until speed is equal the desired speed
      elsif r_v<r_des_v then
        r_v <= r_v(REG_LEN-2 downto 0) & '0'; -- shift until speed is equal the desired speed
      else
		  r_v <= r_v;
      end if;
    else
	   r_v <= r_v;
    end if;
  end if;
end process;



end arch;