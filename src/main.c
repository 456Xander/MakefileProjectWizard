#include <errno.h>
#include "pch.h"
#include <limits.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include "mkdir_p.h"

#define ERROR_FILE_NOT_FOUND 3
#define ERROR_FOLDER_NAME 2
#define ERROR_WRONG_USAGE 1

#define src_mkfile "/Makefile"
#define dest_mkfile "/Makefile"

//just use 4k max path
#define PATH_MAX 4096

const char *PROJ_NAME = "EXEC_NAME := create-proj\n";
int main(int argc, char **argv) {
	// Check if correct arguments are supplied
	// Should be PROGRAM ProjName ProjFolder
	if (argc != 3) {
		fprintf(stderr, "Usage: %s <Project Name> <Project Folder>\n", argv[0]);
		exit(ERROR_WRONG_USAGE);
	}
	char *mainFile = argv[0];
	char *name = argv[1];
	char *folder = argv[2];
#ifdef DBG
	printf("Folder: %s\n", folder);
	printf("Name: %s\n", name);
#endif
	char buffer[PATH_MAX];
	if ((strlen(mainFile) + strlen(src_mkfile)) > sizeof(buffer)) {
		fprintf(stderr, "Folder name too long!!!\n");
		exit(ERROR_FOLDER_NAME);
	}
	// Find last occurence of / in mainFile and remove it to get folder
	char *ptr = strrchr(mainFile, '/');
	if (ptr) {
		*ptr = '\0';
	} else {
		// no / in the file name, so we are in the root dir
		mainFile = ".";
	}
	strcpy(buffer, mainFile);
	strcat(buffer, src_mkfile);
	// The Makefile, which contains the code
	FILE *srcMakefile = fopen(buffer, "r");
	if (srcMakefile == NULL) {
		fprintf(stderr, "ERROR, source Makefile %s could not be openened\n",
		        buffer);
		exit(ERROR_FILE_NOT_FOUND);
	}
	if ((strlen(folder) + strlen(dest_mkfile)) > sizeof(buffer)) {
		fprintf(stderr, "Folder name too long!!!\n");
		exit(ERROR_FOLDER_NAME);
	}
	strcpy(buffer, folder);
	strcat(buffer, dest_mkfile);
#ifdef DBG
	printf("dest: %s\n", buffer);
#endif
	// The Dest Makefile
	FILE *destMakefile = fopen(buffer, "w");
	if (destMakefile == NULL) {
		// try creating folder first
		if (mkdir_p(folder) != 0) {
			// Could not create folder either
			fprintf(stderr, "ERROR, target Makefile %s could not be openend\n",
			        buffer);
		}
		destMakefile = fopen(buffer, "w");
	}
	char line[256];
	printf("beginning Copy\n");
	while ((fgets(line, 256, srcMakefile)) != NULL) {
		if (strcmp(PROJ_NAME, line) == 0) {
			
			fputs("EXEC_NAME := ", destMakefile);
			fputs(name, destMakefile);
			fputs("\n", destMakefile);
		} else
			fputs(line, destMakefile);
	}

	if (strlen(folder) + strlen("/src") > sizeof(buffer)) {
		fprintf(stderr, "Folder name too long!!!\n");
		exit(ERROR_FOLDER_NAME);
	}
	strcpy(buffer, folder);
	strcat(buffer, "/src");
	mkdir(buffer, S_IRWXU);

	printf("finished creating Project %s\n", name);

	fclose(srcMakefile);
	fclose(destMakefile);
	return 0;
}
