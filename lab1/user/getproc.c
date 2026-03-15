#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[]) {
	int info[2]; 
	int exitStatus = getproc(info);
	if (exitStatus != 0) {
		return exitStatus;
	}
	printf("pid: %d, state: %d\n", info[0], info[1]);
	return 0;
}
