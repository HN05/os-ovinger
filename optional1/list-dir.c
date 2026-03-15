#include <dirent.h>
#include <fcntl.h>
#include <stdatomic.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int compare(const void *a, const void *b) {
	char* chr1 = * (char**) a;
	char* chr2 = * (char**) b;
	return strcmp(chr2, chr1);
}

int main(int argc, char *argv[]) {
	char *path;
	bool doFree = false;
	if (argc < 2) {
		const int maxSize = 100;
		doFree = true;
		path = (char *)malloc(maxSize);
		getcwd(path, maxSize);
	} else {
		path = argv[1];
	}

	DIR *dir = opendir(path);

	if (doFree) {
		free(path);
	}

	if (!dir) {
		fprintf(stderr, "Could not read dir, check permissions and input\n");
		return 1;
	}

	int count = 0;
	while (true) {
		struct dirent *entry = readdir(dir);
		if (entry == NULL) {
			break;
		}
		count++;
	}

	rewinddir(dir);
	char *contents[count];
	int index = 0;

	while (true) {
		struct dirent *entry = readdir(dir);
		if (entry == NULL) {
			break;
		}
		contents[index] = strdup(entry->d_name);
		index++;
	}

	closedir(dir);

	qsort(contents, index, sizeof(char*), &compare);

	for (int i = index-1; i >= 0; i--) {
		printf("%s\n", contents[i]);
		free(contents[i]);
	}

	return 0;
}
