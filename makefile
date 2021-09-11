ifeq ($(OS),Windows_NT)
	include maketools\windows.mk
else
	include maketools/linux.mk
	include maketools/tools.mk
endif
