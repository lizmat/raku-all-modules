use v6;
unit module C::Parser::Utils;

our sub fake_indent (Str $input --> Str) {
    my regex three_liner {
        $<line>=['('   <-[()\n]>*]
        <.ws> $<line>=[<-[()\n]>*]
        <.ws> $<line>=[<-[()\n]>* ')']
    };

    my sub one_liner($/) {
        return @<line>.join;
    }

    my $out = $input;
    $out.=subst("(", "(\n", :g);
    $out.=subst(")", "\n)", :g);
    $out.=subst(rx{',' <.ws>}, ",\n", :g);
    $out.=subst("\n\n", "\n", :g);
    $out.=subst("(\n)", "()", :g);
    $out.=subst(&three_liner, &one_liner, :g);
    our $count = 0;
    our @inlines = $out.lines;
    our @outlines = @();
    for @inlines -> $line {
        if $line ~~ rx{^ ')'} {
            $count -= $line.split(")").elems - 1;
            @outlines.push($line.indent(4*$count));
        }
        else {
            @outlines.push($line.indent(4*$count));
            $count -= $line.split(")").elems - 1;
        }
        $count += $line.split("(").elems - 1;
    }
    $out = @outlines.join("\n");
    return $out;
}

our sub get_builtin_types() {
    return qw<<<
        __builtin_va_list
        gboolean
        gchar
        gconstpointer
        gdouble
        gfloat
        gint
        gint16
        gint32
        gint64
        gint8
        glong
        gpointer
        gshort
        gsize
        gssize
        guchar
        guint
        guint16
        guint32
        guint64
        guint8
        gulong
        gushort
        qint8
        qint16
        qint32
        qint64
        qlonglong
        qptrdiff
        qreal
        quint8
        quint16
        quint32
        quint64
        quintptr
        qulonglong
        uchar
        uint
        ulong
        ushort
        DIR
        FILE
        blkcnt_t
        blksize_t
        cc_t
        char16_t
        char32_t
        clock_t
        clockid_t
        cnd_t
        dev_t
        div_t
        double_t
        fenv_t
        fexcept_t
        float_t
        fpos_t
        fsblkcnt_t
        fsfilcnt_t
        gid_t
        glob_t
        id_t
        idtype_t
        imaxdiv_t
        in_addr_t
        in_port_t
        ino_t
        int16_t
        int32_t
        int64_t
        int8_t
        int_fast16_t
        int_fast32_t
        int_fast64_t
        int_fast8_t
        int_least16_t
        int_least32_t
        int_least64_t
        int_least8_t
        intmax_t
        intptr_t
        key_t
        ldiv_t
        lldiv_t
        locale_t
        mbstate_t
        mode_t
        msglen_t
        msgqnum_t
        mtx_t
        nlink_t
        off_t
        off_t
        once_flag
        pid_t
        pthread_attr_t
        pthread_barrier_t
        pthread_barrierattr_t
        pthread_cond_t
        pthread_condattr_t
        pthread_key_t
        pthread_mutex_t
        pthread_mutexattr_t
        pthread_once_t
        pthread_rwlock_t
        pthread_rwlockattr_t
        pthread_spinlock_t
        pthread_t
        ptrdiff_t
        regex_t
        regmatch_t
        regoff_t
        rsize_t
        sa_family_t
        sem_t
        sig_atomic_t
        siginfo_t
        sigset_t
        size_t
        socklen_t
        speed_t
        ssize_t
        suseconds_t
        tcflag_t
        thrd_start_t
        thrd_t
        time_t
        timer_t
        trace_attr_t
        trace_event_id_t
        trace_event_set_t
        trace_id_t
        tss_dtor_t
        tss_t
        uid_t
        uint16_t
        uint32_t
        uint64_t
        uint8_t
        uint_fast16_t
        uint_fast32_t
        uint_fast64_t
        uint_fast8_t
        uint_least16_t
        uint_least32_t
        uint_least64_t
        uint_least8_t
        uintmax_t
        uintptr_t
        useconds_t
        va_list
        wchar_t
        wctrans_t
        wctype_t
        wint_t
        wordexp_t
		half
		quad
    >>>;
}