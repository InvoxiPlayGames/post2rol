post2rol by Emma / InvoxiPlayGames 2026

xenon bootloader patch that redirects POST codes to the Ring of Light board via
the SMC

credits/greetz:
- tmbinc et al. for the original king kong Ring of Light shellcode
- ikari for freeBOOT
- cOz for xeBuild
- Free60 and contributors for libxenon

TODOs:
- xebuild patch generator
- hypervisor equivalent
- still emit over POST bus for POST/JTAG monitoring
(see also the .S file)

---

to apply this manually, append the shellcode to the end of the bootloader in
question, adjust the size in the header, and replace the POST output function
with relative branches to the shellcode

the POST output function can be found by looking for:
  rldicr    %r4, %r4, 56, 7
  std       %r4, 0(%r3)
  blr
so you would replace the rldicr instruction with a relative, unlinked branch to
the shellcode

some other POST codes can be found by searching for the
  rldicr    %r4, %r4, 56, 7
instruction by itself, and replacing that instruction with a relative *linked*
branch to the shellcode function, making sure to nop out the "std" instruction
afterwards
