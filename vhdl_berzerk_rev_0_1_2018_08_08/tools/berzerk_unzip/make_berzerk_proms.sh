#!/bin/bash
# converted from make_berzerk_proms.bat by Red~Bote (Glenn Neidermeier) 10/2024

#copy /B berzerk_rc31_1d.rom1.1d + berzerk_rc31_3d.rom2.3d + berzerk_rc31_5d.rom3.5d + berzerk_rc31_6d.rom4.6d + berzerk_rc31_5c.rom5.5c prog2.bin
#copy /B berzerk_r_vo_1c.1c + berzerk_r_vo_2c.2c speech.bin

#make_vhdl_prom berzerk_rc31_1c.rom0.1c berzerk_program1.vhd
#make_vhdl_prom prog2.bin berzerk_program2.vhd
#make_vhdl_prom speech.bin berzerk_speech_rom.vhd

# 1c    berzerk_r_vo_1c.1c
# 1c-0  berzerk_rc31_1c.rom0.1c
# 1d-1  berzerk_rc31_1d.rom1.1d
# 2c    berzerk_r_vo_2c.2c
# 3d-2  berzerk_rc31_3d.rom2.3d
# 5c-5  berzerk_rc31_5c.rom5.5c
# 5d-3  berzerk_rc31_5d.rom3.5d
# 6d-4  berzerk_rc31_6d.rom4.6d

# rom0.1c  
# rom1.1d  berzerk_rc31_1d.rom1.1d
# rom2.3d  berzerk_rc31_3d.rom2.3d
# rom3.5d  berzerk_rc31_5d.rom3.5d
# rom4.6d  berzerk_rc31_6d.rom4.6d
# rom5.5c  berzerk_rc31_5c.rom5.5c


cat  1d-1  3d-2  5d-3  6d-4  5c-5 > prog2.bin
cat  1c 2c  > speech.bin

./make_vhdl_prom  1c-0       berzerk_program1.vhd
./make_vhdl_prom  prog2.bin  berzerk_program2.vhd
./make_vhdl_prom  speech.bin berzerk_speech_rom.vhd

rm prog2.bin speech.bin




