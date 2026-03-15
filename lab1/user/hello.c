#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
	if (argc > 1) {
		printf("Hello %s, nice to meet you!\n", argv[1]);
		return 0;
	}

	printf("Hello World\n");
	return 0;
}
