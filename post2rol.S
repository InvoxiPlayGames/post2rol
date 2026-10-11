# post2rol - code to replace the POST output function in xenon bootloaders with
# one that emits the POST codes via the ring of light board
# by Emma / InvoxiPlayGames 2026

.globl post2rol
post2rol:
    # r3 is POST addy
    # r4 is POST code
    # build the address for real-mode PCI registers
    # TODO simplify this since r3 will always be 0x8000020000061010
	li		%r3, 0x200
	oris	%r3, %r3, 0x8000
	sldi	%r3, %r3, 32
	oris	%r3, %r3, 0xEA00    # 0x80000200_EA000000

    # check if it's a panic
    cmpwi   %r4, 0x80
    bge its_a_panic

not_a_panic:
    # convert POST code to SMC LED command
    # TODO encode the upper nibble as well so you dont have to guess
    clrldi  %r4, %r4, 60       # Mask off all except the latter nibble (0x22 -> 0x02)
    sldi    %r4, %r4, 12       # Shift up by 12 (so 0x02 -> 0x2000, which means P2 green lit)
    oris    %r4, %r4, 0x9901   # SMC LED command (0x99 = set led, 0x01 = override enable)
    b smc_msg_send

its_a_panic:
    # alternative code for rebooting the box on panic (i use a slim BTW)
    #lis %r4, 0x8204           # SMC reboot command
    #ori %r4, %r4, 0x3000

    # convert POST to SMC LED commands but red this time
    # TODO figure out how to make the middle dot red for slim
    clrldi  %r4, %r4, 60       # Mask off all except the latter nibble (0xF2 -> 0x02)
    sldi    %r4, %r4, 8        # Shift up by 8 (so 0x02 -> 0x0200, which means P2 red lit)
    oris    %r4, %r4, 0x9901   # SMC LED command (0x99 = set led, 0x01 = override enable)
    b smc_msg_send

smc_msg_send:
	# send the SMC message
	lis		%r12, 0x0400        # TODO make sure r12 is actually free in bootloader context
	stw		%r12, 0x1084(%r3)	# 00000004, little endian
	stw		%r4, 0x1080(%r3)	# 9901xx00, where XX is the POST value
	stw		%r0, 0x1080(%r3)	# 00000000, under assumption r0 is 0
	stw		%r0, 0x1080(%r3)	# 00000000
	stw		%r0, 0x1080(%r3)	# 00000000
	stw		%r0, 0x1084(%r3)	# 00000000

end:
    # TODO delays + blanking out to make it easier to see
    blr

.globl post2rol_end
post2rol_end:
    nop
