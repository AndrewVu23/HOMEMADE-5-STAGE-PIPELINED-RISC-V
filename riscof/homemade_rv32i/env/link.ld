/* DUT Linker Script
 * Base address at 0x00000000 — matches our processor's reset PC.
 * The standard RISC-V test base is 0x80000000, but our processor starts at 0x0,
 * so we place everything here to avoid modifying the processor.
 * Spike uses its own linker script (spike/env/link.ld) with 0x80000000.
 *
 * .tohost section is where the halt signal gets written — the testbench monitors
 * this address. Its position varies depending on .text.init size due to ALIGN(0x1000).
 */
OUTPUT_ARCH( "riscv" )
ENTRY(rvtest_entry_point)

SECTIONS
{
  . = 0x00000000;
  .text.init : { *(.text.init) }
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  . = ALIGN(0x1000);
  .text : { *(.text) }
  . = ALIGN(0x1000);
  .data : { *(.data) }
  .data.string : { *(.data.string)}
  .bss : { *(.bss) }
  _end = .;
}
