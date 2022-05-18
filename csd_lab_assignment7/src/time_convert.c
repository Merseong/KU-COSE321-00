char* time_convert(char* addr, unsigned elapsed)
{
	char* addr_copy = addr;

	unsigned hour = (elapsed / 3600) % 100;
	*addr_copy++ = hour / 10 + '0';
	*addr_copy++ = hour % 10 + '0';
	*addr_copy++ = ':';

	unsigned minute = (elapsed / 60) % 60;
	*addr_copy++ = minute / 10 + '0';
	*addr_copy++ = minute % 10 + '0';
	*addr_copy++ = ':';

	unsigned second = elapsed % 60;
	*addr_copy++ = second / 10 + '0';
	*addr_copy++ = second % 10 + '0';

	return addr;
}
