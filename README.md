# MakefileProjectWizard
A small program to automatically create a project with a Makefile

## How To Install:
clone the git repository
type make
The Program is created in the same folder

## How to use:
The executable has to remain in the git folder, otherwise it won't find the base Makefile
Simply run ./create-proj <Name> <Folder> and a new Project will be created.

In the new Project source Files should be placed inside the src folder.
To Build release type make or make release, for Debug run make debug
In debug mode DBG will be defined in the Program
Run make clean to remove .o and .d files

The Makefile works with [YCM-Generator](https://github.com/rdnetto/YCM-Generator), but you have to remove the default one before creating a new .ycm_extra_conf.py
