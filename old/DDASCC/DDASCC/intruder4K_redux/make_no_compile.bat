


cd MSX-O-Mizer
MSX-O-Mizer.exe -r ..\game2k.bin game2k.bin.miz
cd ..

sjasm.exe -S -i. MSX-O-Mizer\loader.asm MSX-O-Mizer\loader.bin


dir MSX-O-Mizer\*.bin

move MSX-O-Mizer\*.bin .