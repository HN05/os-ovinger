#include "kernel/types.h"
#include "user/user.h"

int hex_int(char c)
{
    if (c >= '0' && c <= '9')
    {
	return c - '0';
    }
    else if (c >= 'a' && c <= 'f')
    {
	return c - 'a';
    }
    else if (c >= 'A' && c <= 'F')
    {
	return c - 'A';
    }
    printf("virtual address must be in hex\n");
    exit(1);
}

uint64 str_hex(char* str)
{
    int start = 0;
    if (str[0] == '0' || str[1] == 'x') {
	start = 2;
    }
    char *c = str + start;
    int offset = -1;
    while (*c != '\0') {
	offset++;
	c++;
    }

    uint64 num = 0;

    for (c = str + start; offset >= 0; offset--)
    {
	int val = hex_int(*c);
	num |= val << (offset * 4);
	c++;
    }
    return num;
}

int str_int(char* str)
{
    char *c = str;
    int offset = -1;
    while (*c != '\0') {
	offset++;
	c++;
    }

    int num = 0;
    for (c = str; offset >= 0; offset--)
    {
	if (*c > '9' || *c < '0')
	{
	    printf("pid must be a num\n");
	    exit(1);
	}
	int val = *c - '0';
	num *= 10;
	num += val;
	c++;
    }
    return num;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
	printf("Usage: vatopa virtual_address [pid]\n");
	exit(1);
    }

    uint64 vaddr = str_hex(argv[1]);

    int pid = 0;
    if (argc == 3) {
	pid = str_int(argv[2]);		
    }
    printf("0x%x\n", va2pa(vaddr, pid));
    exit(0);
}
