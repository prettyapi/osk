OS := $(shell uname)

ifeq ($(OS), Linux)
	AS=as 
	ASFLAGS= -g -Iinclude --32 -march=i486
	LD=ld -m elf_i386
	CC=gcc
	CPP=gcc
	CFLAGS= -g -O0 -march=i486 -m32 -Wall -pedantic -W -nostdlib -nostdinc -Wno-long-long -I include -fomit-frame-pointer -fno-builtin -fno-stack-protector -fno-pie -fstrength-reduce
	OBJCOPY=objcopy
	NM=nm
	STRIP=strip
	GDB=gdb
endif
ifeq ($(OS), Darwin)
	AS=i386-elf-as
	ASFLAGS= -g -Iinclude --32 -march=i486
	LD=i386-elf-ld -m elf_i386
	CC=i386-elf-gcc
	CPP=i386-elf-gcc
	CFLAGS= -g -O0 -march=i486 -m32 -Wall -pedantic -W -nostdlib -nostdinc -Wno-long-long -I include -fomit-frame-pointer -fno-builtin -fno-stack-protector -fno-pie -fstrength-reduce
	OBJCOPY=i386-elf-objcopy
	NM=i386-elf-nm
	STRIP=i386-elf-strip
	GDB=i386-elf-gdb
endif

KERNEL_OBJS= load.o init.o isr.o timer.o libcc.o scr.o kb.o task.o kprintf.o hd.o exceptions.o fs.o

.s.o:
	${AS} ${ASFLAGS} -a $< -o $*.o >$*.map

all: final.img

final.img: bootsect kernel
	dd if=/dev/zero of=final.img bs=512 count=2880
	cat bootsect kernel > temp.img
	dd if=temp.img of=final.img bs=512 conv=notrunc
	rm -rf temp.img
	@wc -c final.img

bootsect: bootsect.o
	${LD} -N -e start -Ttext 0x7c00 -o bootsect $<
	cp -f bootsect bootsect.sym
	${NM} bootsect.sym | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)'| sort > bootsect.map
	${OBJCOPY} -R .pdr -R .comment -R.note -S -O binary bootsect

kernel.sym:${KERNEL_OBJS}
	${LD} -N -e pm_mode -Ttext 0x0000 -o $@ ${KERNEL_OBJS}
	${NM} kernel.sym | grep -v '\(compiled\)\|\(\.o$$\)\|\( [aU] \)\|\(\.\.ng$$\)\|\(LASH[RL]DI\)'| sort > kernel.map

kernel:kernel.sym
	cp -f kernel.sym kernel.tmp
	${STRIP} kernel.tmp
	${OBJCOPY} -R .note -R .comment kernel.tmp -O binary kernel
	rm kernel.tmp
# kernel: ${KERNEL_OBJS}
# 	${LD} --oformat binary -N -e pm_mode -Ttext 0x0000 -o $@ ${KERNEL_OBJS}
# 	@wc -c kernel

clean:
	rm -f final.img kernel bootsect *.o *.sym *.map .gdbinit

dep:
	sed '/\#\#\# Dependencies/q' < Makefile > tmp_make
	(for i in *.c;do ${CPP} -M $$i;done) >> tmp_make
	mv tmp_make Makefile

run: final.img
	rm -rf hda.qcow2
	cp -f hda.qcow2.bak hda.qcow2
	qemu-system-i386 -fda final.img -boot a -hda hda.qcow2 -cpu 486 -m 16M

gdbinit:
	echo "add-auto-load-safe-path .gdbinit" > $(HOME)/.gdbinit
	rm -rf .gdbinit
	cp .kernel_gdbinit .gdbinit
ifeq ($(findstring kernel,$(DST)),kernel)
	cp .kernel_gdbinit .gdbinit
else
	cp .boot_gdbinit .gdbinit
endif

debug-kernel: final.img
	rm -rf hda.qcow2
	cp -f hda.qcow2.bak hda.qcow2
	# qemu-system-i386 -fda final.img -boot a -hda hda.qcow2 -cpu 486 -m 4m -S -s &
	bochs -f bochsrc.bxrc -q &
	${GDB} kernel.sym \
		-ex 'target remote localhost:1234' \
		-ex 'set architecture i8086' \
		-ex 'layout src' \
		-ex 'layout regs' \
		-ex 'break pm_mode' \
		-ex 'continue'

debug-boot: final.img
	rm -rf hda.qcow2
	cp -f hda.qcow2.bak hda.qcow2
	# qemu-system-i386 -fda final.img -boot a -hda hda.qcow2 -cpu 486 -m 4m -S -s &
	bochs -f bochsrc.bxrc -q &
	${GDB} bootsect.sym \
		-ex 'target remote localhost:1234' \
		-ex 'set architecture i8086' \
		-ex 'layout src' \
		-ex 'layout regs' \
		-ex 'break start' \
		-ex 'continue'

### Dependencies:
exceptions.o: exceptions.c include/kprintf.h include/scr.h include/asm.h \
  include/task.h include/kernel.h
fs.o: fs.c include/fs.h include/hd.h include/kprintf.h include/scr.h \
  include/kernel.h include/asm.h include/libcc.h
hd.o: hd.c include/hd.h include/asm.h include/kprintf.h include/scr.h \
  include/kernel.h
init.o: init.c include/scr.h include/isr.h include/asm.h include/kernel.h \
  include/task.h include/libcc.h include/timer.h include/hd.h \
  include/kprintf.h include/kb.h include/fs.h
kb.o: kb.c include/asm.h include/scr.h
kprintf.o: kprintf.c include/scr.h include/asm.h include/kprintf.h
libcc.o: libcc.c include/libcc.h
scr.o: scr.c include/asm.h include/scr.h include/libcc.h
task.o: task.c include/task.h include/kernel.h include/asm.h
timer.o: timer.c include/asm.h include/task.h include/kernel.h \
  include/scr.h include/kprintf.h
