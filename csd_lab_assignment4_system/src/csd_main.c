int csd_main()
{
	unsigned* input = (unsigned*)0x00101020;			// address of switch GPIO
	unsigned* timer_out_addr = (unsigned*)0x00101000;	// address of shared memory with assembly

	if (*input == '1')
	{
		*timer_out_addr = (unsigned)0x000CCCCC; // 0.1 sec
	}
	else if (*input == '2')
	{
		*timer_out_addr = (unsigned)0x00199998; // 0.2s
	}
	else if (*input == '3')
	{
		*timer_out_addr = (unsigned)0x00266664; // 0.3s
	}
	else if (*input == '4')
	{
		*timer_out_addr = (unsigned)0x00333330; // 0.4s
	}
	else if (*input == '5')
	{
		*timer_out_addr = (unsigned)0x003FFFFC; // 0.5s
	}
	else if (*input == '6')
	{
		*timer_out_addr = (unsigned)0x004CCCC8; // 0.6s
	}
	else if (*input == '7')
	{
		*timer_out_addr = (unsigned)0x00599994; // 0.7s
	}
	else if (*input == '8')
	{
		*timer_out_addr = (unsigned)0x00800000; // 1 sec
	}

	return 0;
}
