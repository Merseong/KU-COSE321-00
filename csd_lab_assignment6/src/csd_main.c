#pragma GCC target ("thumb")
//#pragma GCC target ("arm")

int sorted[32];	// buffer for merge
void merge(int data[], int left, int mid, int right)
{
	int i = left, l = left, r = mid + 1;

	// merge until one half end
	while (l <= mid)
	{
		// append smaller data into buffer
		if (r <= right && data[r] < data[l])
		{
			sorted[i++] = data[r++];
		}
		else
		{
			sorted[i++] = data[l++];
		}
	}

	// append leftover numbers
	while (r <= right)
	{
		sorted[i++] = data[r++];
	}

	// copy sorted data into output data
	for (i = left; i <= right; ++i)
	{
		data[i] = sorted[i];
	}
}

void merge_sort_ascending(int data[], int left, int right)
{
	int mid;

	if (left < right)
	{
		// set mid point to divide array
		mid = (left + right) / 2;

		// sort divided array 1 (left ~ mid)
		merge_sort_ascending(data, left, mid);
		// sort divided array 2 (mid + 1 ~ right)
		merge_sort_ascending(data, mid + 1, right);

		// merge sorted divided array into one array
		merge(data, left, mid, right);
	}
}

void* csd_main()
{
	// sort data in ascending order (from smallest to largest)
	int indata[32] = { 2, 0, -7, -1, 3, 8, -4, 10,
	 -9, -16, 15, 13, 1, 4, -3, 14,
	 -8, -10, -15, 6, -13, -5, 9, 12,
	 -11, -14, -6, 11, 5, 7, -2, -12 }; // 0x10C020
	int outdata[32]; // 0x10BFA0

	int a = 10;	// for breakpoint

	for (int i = 0; i < 32; ++i)
	{
		outdata[i] = indata[i];	// copy indata into outdata
	}

	merge_sort_ascending(outdata, 0, 31);	// start sorting

	a = a + a;	// for breakpoint

	return outdata;	// return address of outdata
}
