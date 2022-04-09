int csd_main()
{
	unsigned* input = (unsigned*)0x00101020;			// address of switch GPIO
	unsigned* timer_out_addr = (unsigned*)0x00101000;	// address of shared memory with assembly

	if (*input & '1')
	{
		*timer_out_addr = (unsigned)0x01FCA034; // 0.1 sec
	}
	else if (*input & '2')
	{
		*timer_out_addr = (unsigned)0x03F94068; // 0.2s
	}
	else if (*input & '3')
	{
		*timer_out_addr = (unsigned)0x05F5E09C; // 0.3s
	}
	else if (*input & '4')
	{
		*timer_out_addr = (unsigned)0x07F280D0; // 0.4s
	}
	else if (*input & '5')
	{
		*timer_out_addr = (unsigned)0x09EF2104; // 0.5s
	}
	else if (*input & '6')
	{
		*timer_out_addr = (unsigned)0x0BEBC138; // 0.6s
	}
	else if (*input & '7')
	{
		*timer_out_addr = (unsigned)0x0DE8616C; // 0.7s
	}
	else if (*input & '8')
	{
		*timer_out_addr = (unsigned)0x13DE4208; // 1 sec
	}

	return 0;
}
