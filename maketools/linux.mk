run: output/linux
	output/linux/STD
compile: cleancontent output
release: compile output/STD.zip

runwin: output/win64
	wine output/windows64/STD.exe
dbgwin: output/win64
	wine winedbg output/windows64/STD.exe
dbg: output/linux
	gdb output/linux/STD

sources := $(wildcard src/*/*.nim src/*.nim)

# tools edit to add tools
tools/bin/%: tools/src/%.nim
	mkdir -p tools/bin
	nim c -o:$@ $^

tools/bin/%.sh: tools/src/%.sh
	mkdir -p tools/bin
	cp $^ $@

# content stuff edit this to add content
content: content/rounds.bin content/paths.bin content/sprites.bmp content/click.wav content/hover.wav content/poland.ttf content/map1.map content/map2.map content/map3.map content/map4.map content/map5.map

content/%.bin: rawContent/%.csv tools/bin/%File
	mkdir -p content
	tools/bin/$*File $< $@

content/%.bmp: tools/bin/gimpExportBmp.sh rawContent/images/%.xcf
	mkdir -p content
	tools/bin/gimpExportBmp.sh rawContent/images/$*.xcf content/$*.bmp


content/%.ico: tools/bin/gimpExportIco.sh rawContent/images/%.xcf
	mkdir -p content
	tools/bin/gimpExportIco.sh rawContent/images/$*.xcf content/$*.ico

content/%.wav: rawContent/audio/%.wav
	mkdir -p content
	ffmpeg -i $< -acodec pcm_s16le -ac 2 -ar 48000 $@

content/%.ttf: rawContent/%.ttf
	mkdir -p content
	cp $^ $@

content/%.map: rawContent/maps/%.dat
	mkdir -p content
	cp $^ $@

# end of content this is for building

output/my.rc: tools/bin/rcmaker.sh
	tools/bin/rcmaker.sh rawContent/version.txt output/my.rc

output/my32.res: output/my.rc
	mkdir -p output
	i686-w64-mingw32-windres output/my.rc -O coff output/my32.res

output/my64.res: output/my.rc
	mkdir -p output
	x86_64-w64-mingw32-windres output/my.rc -O coff output/my64.res

output/STD.zip: output
	zip -r output/STD-linux.zip output/linux
	zip -r output/STD-win32.zip output/windows32
	zip -r output/STD-win64.zip output/windows64

deps:
	nimble install -y http://github.com/bob16795/gin crc32
	rm -rf output/*/STD*

output/windows32/content: content
	mkdir output/windows32/content -p
	cp content/ output/windows32 -r

output/windows64/content: content
	mkdir output/windows64/content -p
	cp content/ output/windows64 -r

output/linux/content: content
	mkdir output/linux/content -p
	cp content/ output/linux -r

output/windows32/SDL2.dll:
	mkdir -p output/windows32/
	rm -f SDL2-2.0.14-win32-x86.zip
	wget https://www.libsdl.org/release/SDL2-2.0.14-win32-x86.zip
	unzip -o -d tmp SDL2-2.0.14-win32-x86.zip
	mv tmp/SDL2.dll output/windows32
	rm -rf tmp
	rm -f SDL2-2.0.14-win32-x86.zip

output/windows32/SDL2_ttf.dll:
	mkdir -p output/windows32/
	rm -f SDL2_ttf-2.0.14-win32-x86.zip
	wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.14-win32-x86.zip
	unzip -o -d tmp SDL2_ttf-2.0.14-win32-x86.zip
	mv tmp/*.dll output/windows32
	rm -rf tmp
	rm -f SDL2_ttf-2.0.14-win32-x86.zip

output/windows64/SDL2.dll:
	mkdir -p output/windows64/
	rm -f SDL2-2.0.14-win32-x64.zip
	wget https://www.libsdl.org/release/SDL2-2.0.14-win32-x64.zip
	unzip -o -d tmp SDL2-2.0.14-win32-x64.zip
	mv tmp/SDL2.dll output/windows64
	rm -rf tmp
	rm -f SDL2-2.0.14-win32-x64.zip

output/windows64/SDL2_ttf.dll:
	mkdir -p output/windows64/
	rm -f SDL2_ttf-2.0.14-win32-x64.zip
	wget https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-2.0.14-win32-x64.zip
	unzip -o -d tmp SDL2_ttf-2.0.14-win32-x64.zip
	mv tmp/*.dll output/windows64
	rm -rf tmp
	rm -f SDL2_ttf-2.0.14-win32-x64.zip

output/windows32/STD.exe: $(sources) content/icon.ico output/my32.res
	nim c -o:output/windows32/STD.exe --app:gui -d:release -t:"-g -D_FORTIFY_SOURCE=0" -d:mingw --gc:markAndSweep --threads:on --cpu:i386 -l:"output/my32.res -Wl,-O1,--sort-common,--as-needed; echo " src/main.nim

output/windows64/STD.exe: $(sources) content/icon.ico output/my64.res
	nim c -o:output/windows64/STD.exe --app:gui -d:release -t:"-g -D_FORTIFY_SOURCE=0" -d:mingw --gc:markAndSweep --threads:on --cpu:amd64 -l:"output/my64.res -Wl,-O1,--sort-common,--as-needed; echo " src/main.nim

output/linux/STD: $(sources) tools/bin/version.sh
	nim c -o:output/linux/STD --app:gui -d:release --gc:markAndSweep --threads:on src/main.nim
	tools/bin/version.sh

output/linux: output/linux/STD copycontent
output/win32: output/windows32/SDL2.dll output/windows32/SDL2_ttf.dll output/windows32/STD.exe copycontent
output/win64: output/windows64/SDL2.dll output/windows64/SDL2_ttf.dll output/windows64/STD.exe copycontent

copycontent: output/linux/content output/windows32/content output/windows64/content

output: output/win32 output/win64 output/linux rawContent/version.txt

cleancontent:
	rm -rf output/*/content
	rm -rf content

clean:
	rm -rf content/
	rm -rf output/
	rm -rf tools/bin

cleanexec:
	rm -rf output/*/STD*
