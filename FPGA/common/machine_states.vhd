package machine_states_common is

	type top_state is (IDLE, RECV, FILL_BUFFER, 
	PRE_CRC, CRC_FEED, CRC_COUNT, LOAD_ACK, 
	START_RESPONSE, SEND_RESPONSE, CHANGE_MODE,
	FILL_OUTPUT, LOAD_PINS, LOAD_CRC, COUNT_CLEAR, 
	COUNT_SENT,	WAIT_RESPONSE, RECV_RESPONSE, 
	CHECK_RESPONSE, RESET_MACH);
	attribute syn_encoding : string;
	attribute syn_encoding of top_state :  type is "safe";

end machine_states_common;

package body machine_states_common is
end machine_states_common;