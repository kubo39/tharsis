build/kernel.elf: kernel/*.d kernel/kernel.ld
	mkdir -p build
	ldc2 \
		-mtriple=riscv64-unknown-none-elf \
		-mattr=+m,+c,+relax \
		-code-model=medium \
		--checkaction=C \
		--relocation-model=static \
		--transition=tls \
		-g \
		--force-dwarf-frame-section \
		--frame-pointer=all \
		-betterC \
		-O2 \
		-c \
		-od=build \
		-op kernel/*.d
	ld.lld \
		--discard-locals \
		--gc-sections \
		-T kernel/kernel.ld \
		--orphan-handling=warn \
		-o $@ \
		$$(find build -name '*.o')

# make run-qemu DEBUG=1 で gdb の接続を待つ (localhost:1234)
QEMU_DEBUG := $(if $(filter 1,$(DEBUG)),-s -S)

.PHONY: run-qemu
run-qemu: build/kernel.elf
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-nographic \
		-serial mon:stdio \
		--no-reboot \
		-smp 1 \
		-d int,guest_errors -D qemu.log \
		$(QEMU_DEBUG) \
		-kernel $<

.PHONY: clean
clean:
	rm -rf build
