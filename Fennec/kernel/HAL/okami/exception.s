.global __exceptionHandler:
    mfex k0, 0x1 /* OKAMI_TRAP_CAUSE */
    li k1, 2
    bne k0, k1, 1
    b __syscallHandler
    la k1, HalPrevContext
    sw t0, 0(k1)
    sw a0, 4(k1)
    sw a1, 8(k1)
    sw a2, 12(k1)
    sw a3, 16(k1)
    sw a4, 20(k1)
    sw a5, 24(k1)
    sw a6, 28(k1)
    sw a7, 32(k1)
    sw s0, 36(k1)
    sw s1, 40(k1)
    sw s2, 44(k1)
    sw s3, 48(k1)
    sw s4, 52(k1)
    sw s5, 56(k1)
    sw s6, 60(k1)
    sw s7, 64(k1)
    sw s8, 68(k1)
    sw s9, 72(k1)
    sw gp, 76(k1)
    sw fp, 80(k1)
    sw sp, 84(k1)
    sw ra, 88(k1)
    li k1, 1
    beq k0, k1, __intHandler
    mfex a0, 1
    mfex a1, 2
    mfex a2, 3
    mfex a3, 0
    bl HALArchException
    rft
.global __syscallHandler:
    la k1, HalPrevContext
    sw t0, 0(k1)
    sw s0, 36(k1)
    sw s1, 40(k1)
    sw s2, 44(k1)
    sw s3, 48(k1)
    sw s4, 52(k1)
    sw s5, 56(k1)
    sw s6, 60(k1)
    sw s7, 64(k1)
    sw s8, 68(k1)
    sw s9, 72(k1)
    sw gp, 76(k1)
    sw fp, 80(k1)
    sw sp, 84(k1)
    sw ra, 88(k1)
    rft
.global __intHandler:
    rft

.bss
.align 4
HalPrevContext: .resb 92 /* t0 + (a0-a7) + (s0-s9) + gp + fp + sp + ra */
.text
