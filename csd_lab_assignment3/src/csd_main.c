int csd_main()
{
	unsigned* sw_addr = (unsigned*)0x41210000;
	unsigned* timer_out_addr = (unsigned*)0x00101000;

	if (*sw_addr & 0b10000000)
	{
		*timer_out_addr = (unsigned)0x01FCA034; // 0.1 sec
	}
	else if (*sw_addr & 0b01000000)
	{
		*timer_out_addr = (unsigned)0x03F94068; // 0.2s
	}
	else if (*sw_addr & 0b00100000)
	{
		*timer_out_addr = (unsigned)0x05F5E09C; // 0.3s
	}
	else if (*sw_addr & 0b00010000)
	{
		*timer_out_addr = (unsigned)0x07F280D0; // 0.4s
	}
	else if (*sw_addr & 0b00001000)
	{
		*timer_out_addr = (unsigned)0x09EF2104; // 0.5s
	}
	else if (*sw_addr & 0b00000100)
	{
		*timer_out_addr = (unsigned)0x0BEBC138; // 0.6s
	}
	else if (*sw_addr & 0b00000010)
	{
		*timer_out_addr = (unsigned)0x0DE8616C; // 0.7s
	}
	else if (*sw_addr & 0b00000001)
	{
		*timer_out_addr = (unsigned)0x0FE501A0; // 0.8s
	}
	else
	{
		*timer_out_addr = (unsigned)0x13DE4208; // 1 sec , 33.3333MHz
	}

	return 0;
}
