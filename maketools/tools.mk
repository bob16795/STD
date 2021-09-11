push: output/win32 output/win64 output/linux
	butler push output/windows32 prestosilver/sleep-to-defend:win32 --userversion-file rawContent/version.txt
	butler push output/windows64 prestosilver/sleep-to-defend:win64 --userversion-file rawContent/version.txt
	butler push output/linux prestosilver/sleep-to-defend:linux --userversion-file rawContent/version.txt
	butler status prestosilver/sleep-to-defend

status:	
	butler status prestosilver/sleep-to-defend

win32prop: output/win32
	exiftool output/windows32/STD.exe

win64prop: output/win64
	exiftool output/windows64/STD.exe