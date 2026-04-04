/*
 * Model Test Header — defines macros that the arch tests call.
 *
 * RVMODEL_HALT:       writes 1 to 'tohost', then spins. The Riscof_tb.sv testbench
 *                     monitors tohost and calls $finish + signature dump when it sees 1.
 *
 * RVMODEL_DATA_BEGIN: marks the start of the signature region in memory.
 * RVMODEL_DATA_END:   marks the end. RISCOF compares this region between DUT and reference.
 *
 * All IO macros are empty — our processor has no debug output interface.
 */
#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

#define RVMODEL_DATA_SECTION \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 8; .global tohost; tohost: .dword 0;                     \
        .align 8; .global fromhost; fromhost: .dword 0;                 \
        .popsection;                                                    \
        .align 8; .global begin_regstate; begin_regstate:               \
        .word 128;                                                      \
        .align 8; .global end_regstate; end_regstate:                   \
        .word 4;

// Halt: write 1 to tohost, then spin. Testbench watches tohost and dumps signature.
#define RVMODEL_HALT                                                    \
  li x1, 1;                                                             \
  write_tohost:                                                         \
    sw x1, tohost, t5;                                                  \
    j write_tohost;

#define RVMODEL_BOOT

#define RVMODEL_DATA_BEGIN                                              \
  RVMODEL_DATA_SECTION                                                  \
  .align 4;                                                             \
  .global begin_signature; begin_signature:

#define RVMODEL_DATA_END                                                \
  .align 4;                                                             \
  .global end_signature; end_signature:

#define RVMODEL_IO_INIT
#define RVMODEL_IO_WRITE_STR(_R, _STR)
#define RVMODEL_IO_CHECK()
#define RVMODEL_IO_ASSERT_GPR_EQ(_S, _R, _I)
#define RVMODEL_IO_ASSERT_SFPR_EQ(_F, _R, _I)
#define RVMODEL_IO_ASSERT_DFPR_EQ(_D, _R, _I)

#define RVMODEL_SET_MSW_INT
#define RVMODEL_CLEAR_MSW_INT
#define RVMODEL_CLEAR_MTIMER_INT
#define RVMODEL_CLEAR_MEXT_INT

#endif // _COMPLIANCE_MODEL_H
