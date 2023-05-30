# target remote localhost:9000
set disassembly-flavor intel
set disassemble-next-line on
set output-radix 16

define dump
    dont-repeat
    set $addr = (char *)($arg0)
    if $argc >= 2
        set $endaddr = $addr + $arg1
    else
        set $endaddr = $addr + 128
    end
    if $argc == 3
        set $width = $arg2
    else
        set $width = 8
    end
    while $addr < $endaddr
        printf "%p: ", $addr
        set $lineendaddr = $addr + $width
        if $lineendaddr > $endaddr
            set $lineendaddr = $endaddr
        end
        set $a = $addr
        while $a < $lineendaddr
            printf "0x%02x ", *(unsigned char *)$a
            set $a++
        end
        while $a < $addr + $width
            printf "     "
            set $a++
        end
        printf "|"
        set $a = $addr
        while $a < $lineendaddr
            printf "%c", *(char *)$a < 32 || *(char *)$a > 126 ? '.' : *(char *)$a
            set $a++
        end
        set $b = $a - 1
        printf "|"
#        while $a < $addr + $width
        printf " 0x"
#            set $a++
#        end
        while $b >= $addr
            printf "%02x", *(unsigned char *)$b
            set $b--
        end
        printf "\n"
        set $addr = $addr + $width
    end
end

document dump
    usage: dump address [count=128] [width=8]
end

define ddump
    dont-repeat
    set $addr = (char *)(*(char **)($arg0))
    if $argc >= 2
        set $endaddr = $addr + $arg1
    else
        set $endaddr = $addr + 128
    end
    if $argc == 3
        set $width = $arg2
    else
        set $width = 8
    end
    while $addr < $endaddr
        printf "%p: ", $addr
        set $lineendaddr = $addr + $width
        if $lineendaddr > $endaddr
            set $lineendaddr = $endaddr
        end
        set $a = $addr
        while $a < $lineendaddr
            printf "0x%02x ", *(unsigned char *)$a
            set $a++
        end
        while $a < $addr + $width
            printf "     "
            set $a++
        end
        printf "|"
        set $a = $addr
        while $a < $lineendaddr
            printf "%c", *(char *)$a < 32 || *(char *)$a > 126 ? '.' : *(char *)$a
            set $a++
        end
        set $b = $a - 1
        printf "|"
#        while $a < $addr + $width
        printf " 0x"
#            set $a++
#        end
        while $b >= $addr
            printf "%02x", *(unsigned char *)$b
            set $b--
        end
        printf "\n"
        set $addr = $addr + $width
    end
end

define dumpd
    dont-repeat
    set $addr = (char *)($arg0)
    if $argc >= 2
        set $endaddr = $addr + $arg1
    else
        set $endaddr = $addr + 128
    end
    if $argc == 3
        set $width = $arg2
    else
        set $width = 8
    end
    while $addr < $endaddr
        printf "%p: ", $addr
        set $lineendaddr = $addr + $width
        if $lineendaddr > $endaddr
            set $lineendaddr = $endaddr
        end
        set $a = $addr
        while $a < $lineendaddr
            printf "0x%02x ", *(unsigned char *)$a
            set $a++
        end
        while $a < $addr + $width
            printf "     "
            set $a++
        end
        printf "|"
        set $a = $addr
        while $a < $lineendaddr
            printf "%c", *(char *)$a < 32 || *(char *)$a > 126 ? '.' : *(char *)$a
            set $a++
        end
        set $b = $a - 1
        printf "|"
#        while $a < $addr + $width
        printf " 0x"
#            set $a++
#        end
        while $b >= $addr
            printf "%02x", *(unsigned char *)$b
            set $b--
        end
        set $c = *(char **)($addr)
#        printf " %p", $c
        if ($c >= 0x444444440000 && $c <= 0x44444543FFFF) || ($c >= 0x200220 && $c < 0x204B50) || ($c >= 0x10000200000 && $c < 0x10000202000)
            printf " |"
            set $i = 0
            while $i < 8
                printf "%c", *(char *)($c + $i) < 32 || *(char *)($c + $i) > 126 ? '.' : *(char *)($c + $i)
                set $i++
            end
            printf "|"
            while $i < 16
                printf "%c", *(char *)($c + $i) < 32 || *(char *)($c + $i) > 126 ? '.' : *(char *)($c + $i)
                set $i++
            end
            printf "|"
        end
        printf "\n"
        set $addr = $addr + $width
    end
end

define regs
    info registers rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 rip eflags
end

define fdlong
    find /b 0x444444440000, 0x44444543FFFF, 'i', 's', 'L', 'i', 'c', 'e', 'n', 's', 'e'
end

define fd
    find /b 0x444444440000, 0x44444543FFFF, 'i', 's', 'L', 'i', 'c', 'e', 'n', 's'
end

define stp
    stepi
    regs
end

define strt
#   enter pressed execute_next
#    break *0x21C501
#   screen update
#    break *0x20A5A2
#   execute_next jump table
#    break *0x21BF00
#   keyboard interrupt enter pressed
    break *0x20DB2C
    awatch *0x200ED8
    awatch *0x444444480300
    disable 3
    continue
#    continue
#    continue
#    continue
#    continue
end

define cp
    b *0x2071FE
    continue
end

define capprog
    set pagination off
    b *0x21FDFA if *($r8) != 1953067639 && *($r8) != 1466001270
        command 2
        silent
        printf "A:%s::%s %d\n", $rdx, $r8, *($r8)
        if *($r8) == 1766617961 || $test == 1
            print "done"
        else
            continue
        end
    end
    b *0x21F9AB if *($r8) != 1953067639 && *($r8) != 1466001270
        command 3
        silent 
        printf "B:%s::%s %d\n", $rdx, $r8, *($r8)
        if *($r8) == 1766617961 || $test == 1
            print "done"
        else
            continue
        end
    end
    set logging on
end

define clnlk
    set pagination off
    disable 1
    set $var1 = 0

#    break *0x21BF81
#    ignore 2 755

    break *0x227A1C if $rbx > 0 && *($r15) == 0x694c7369 && *($r15+0x4) == 0x736e6563
        command 4
        print $var1++
        reg
    end
end

# this is the one to use
define mcplk
    set pagination off
    disable 1
    set $var1 = 0

#    break *0x21BF81
#    ignore 2 755

    break *0x22B220 if $rdi > 1 && *($rsi) == 0x694c7369 && *($rsi+0x4) == 0x736e6563
        command 4
        print $var1++
        reg
    end
end

define ilkv
    set pagination off
    disable 1
    set $var1 = 0

#    break *0x21BF81
#    ignore 2 755

    break *0x21BF81 if *($rdx-0x4) == 0x736e6563 && *($rdx-0x8) == 0x694c7369 && *($rdx) == 0x12
        command 4
        print $var1++
        reg
    end
end

define tracenext
    set pagination off
    python import time
    disable 1
    set $var1 = 0
    set $var2 = 0

#    break *0x21BF81
#    ignore 2 755

    break *0x21BF72 if $var1++ < 800 + 500
        command 4
        silent
        set $index = $rsi
        stepi 3
#        printf "Entry point %d: %p\n", $var1, $rbp
        printf "81:%p rsp=%p index=%p %d\n", $rbp, $rsp, $index, $var1
#        python time.sleep(1)
        if $var1 < 799
            continue
        end
    end

    break *0x21BF8D if $var2++ < (999 - 443) * 10
        command 5
        silent
        set $index = $rsi
        stepi 2
#        printf "Entry point %d: %p\n", $var2, $rbp
        printf "94:%p rsp=%p index=%p %d\n", $rsi, $rsp, $index, $var2
#        python time.sleep(1)
        continue
    end

#0x21e9D1 is return point after isLicenseKeyValid completes
    break *0x21F9D1
        command 6
        info registers $rsp
    end

#until *0x21F9CC
#info registers $rsp
#set $test = 1
#tracenext
#0x21bf86 is pre-execute_next_jump_table_2
#b *0x21bf86
#0x21e919 has r14 and rbp loaded to compare
#b *0x21e919

end

define recomp
    set $loop = 0
    break *0x21e919
        command 7
        silent
        set $reg_1 = $r14
        set $reg_2 = $rbp
        printf "%d:rsp=%p reg_1=%p (", ++$loop, $rsp, $reg_1
        if $reg_1 >= 32 && $reg_1 < 127
            printf "%c", $reg_1
        else
            printf "."
        end
        printf ") reg_2=%p (", $reg_2
        if $reg_2 >= 32 && $reg_2 < 127
            printf "%c", $reg_2
        else
            printf "."
        end
        printf ")\n"
        continue
    end
end

define r14bp1
    set $loop1 = 0
    break *0x21E798
        command 7
        silent
        set $baddr1 = 0x21E798
        if $r14 == 0x27 || $rbp == 0x27
# ($r14 >= 0x30 && $r14 <= 0x39) || ($rbp >= 0x30 && $rbp <= 0x39)
            printf "%d:%p:rsp=%p r14=%p (", ++$loop1, $baddr1, $rsp, $r14
            if $r14 >= 32 && $r14 < 127
                printf "%c", $r14
            else
                printf "."
            end
            printf ") rbp=%p (", $rbp
            if $rbp >= 32 && $rbp < 127
                printf "%c", $rbp
            else
                printf "."
            end
            printf ")\n"
        end
        continue
    end
end

define r14bp2
    set $loop2 = 0
    break *0x21E916
        command 8
        silent
        set $baddr2 = 0x21E916
        if $r14 == 0x27 || $rbp == 0x27
# ($r14 >= 0x30 && $r14 <= 0x39) || ($rbp >= 0x30 && $rbp <= 0x39)
            printf "%d:%p:rsp=%p r14=%p (", ++$loop2, $baddr2, $rsp, $r14
            if $r14 >= 32 && $r14 < 127
                printf "%c", $r14
            else
                printf "."
            end
            printf ") rbp=%p (", $rbp
            if $rbp >= 32 && $rbp < 127
                printf "%c", $rbp
            else
                printf "."
            end
            printf ")\n"
        end
        continue
    end
end

define r14bp3
    set $loop3 = 0
    break *0x21EEF7
        command 9
        silent
        set $baddr3 = 0x21EEF7
        if $r14 == 0x27 || $rbp == 0x27
# ($r14 >= 0x30 && $r14 <= 0x39) || ($rbp >= 0x30 && $rbp <= 0x39)
            printf "%d:%p:rsp=%p r14=%p (", ++$loop3, $baddr3, $rsp, $r14
            if $r14 >= 32 && $r14 < 127
                printf "%c", $r14
            else
                printf "."
            end
            printf ") rbp=%p (", $rbp
            if $rbp >= 32 && $rbp < 127
                printf "%c", $rbp
            else
                printf "."
            end
            printf ")\n"
        end
        continue
    end
end

define r14bp4
    set $loop4 = 0
    break *0x21F075
        command 10
        silent
        set $baddr4 = 0x21F075
        if $r14 == 0x27 || $rbp == 0x27
# ($r14 >= 0x30 && $r14 <= 0x39) || ($rbp >= 0x30 && $rbp <= 0x39)
            printf "%d:%p:rsp=%p r14=%p (", ++$loop4, $baddr4, $rsp, $r14
            if $r14 >= 32 && $r14 < 127
                printf "%c", $r14
            else
                printf "."
            end
            printf ") rbp=%p (", $rbp
            if $rbp >= 32 && $rbp < 127
                printf "%c", $rbp
            else
                printf "."
            end
            printf ")\n"
        end
        continue
    end
end

define r14bp5
    set $loop5 = 0
    break *0x21F1F3
        command 11
        silent
        set $baddr5 = 0x21F1F3
        if $r14 == 0x27 || $rbp == 0x27
# ($r14 >= 0x30 && $r14 <= 0x39) || ($rbp >= 0x30 && $rbp <= 0x39)
            printf "%d:%p:rsp=%p r14=%p (", ++$loop5, $baddr5, $rsp, $r14
            if $r14 >= 32 && $r14 < 127
                printf "%c", $r14
            else
                printf "."
            end
            printf ") rbp=%p (", $rbp
            if $rbp >= 32 && $rbp < 127
                printf "%c", $rbp
            else
                printf "."
            end
            printf ")\n"
        end
        continue
    end
end

define r14bp6
    set $loop6 = 0
    break *0x21F37D
        command 12
        silent
        set $baddr6 = 0x21F37D
        if $r14 == 0x27 || $rbp == 0x27
# ($r14 >= 0x30 && $r14 <= 0x39) || ($rbp >= 0x30 && $rbp <= 0x39)
            printf "%d:%p:rsp=%p r14=%p (", ++$loop6, $baddr6, $rsp, $r14
            if $r14 >= 32 && $r14 < 127
                printf "%c", $r14
            else
                printf "."
            end
            printf ") rbp=%p (", $rbp
            if $rbp >= 32 && $rbp < 127
                printf "%c", $rbp
            else
                printf "."
            end
            printf ")\n"
        end
        continue
    end
end
