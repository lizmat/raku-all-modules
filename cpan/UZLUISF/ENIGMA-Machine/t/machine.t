v6;
use Test;
use ENIGMA::Machine;

{
    my $m =  Machine.from-key-sheet(
        :rotors('III II I'),
        :plugboard-setting(''),
    );

    $m.set-display('KDO');

    my @truth_data = 'KDP', 'KDQ', 'KER', 'LFS', 'LFT', 'LFU';

    for @truth_data -> $expected {
        $m.key-press('A');
        is $m.get-display(), $expected, "testing display setting";
    }
}

{
    my $PLAIN_TEXT  = 'A' x 5;
    my $CIPHER_TEXT = 'BDZGO';

    my $machine = Machine.from-key-sheet(:rotors('I II III'));
    $machine.set-display('AAA');

    my $cipher_text = $machine.process-text($PLAIN_TEXT);
    is $cipher_text, $CIPHER_TEXT, "testing encryption of plaintext";

    $machine.set-display('AAA');

    my $plain_text = $machine.process-text($CIPHER_TEXT);
    is $plain_text, $PLAIN_TEXT, "testing decryption of ciphertext";
    
}

{
    my $machine = Machine.from-key-sheet(
        :rotors('II IV V'),
        :ring-settings('B U L'),
        :reflector-setting('B'),
        :plugboard-setting('AV BS CG DL FU HZ IN KM OW RX'),
    );

    sub decrypt( $start, $enc_key, $block_ct, $truth_data, $num ) {
        # remove spaces & Kenngruppen from the ciphertext
        my $cipher_text = $block_ct.substr(5, *).comb(/\w/).join;

        # remove spaces from the truth  data
        my $truthdata = $truth_data.comb(/\w/).join;

        # decrypt the message key
        $machine.set-display($start);
        my $msg_key = $machine.process-text($enc_key);

        # decrypt the ciphertext with the decoded message key
        $machine.set-display($msg_key);
        my $plain_text = $machine.process-text($cipher_text);

        # say $plain_text;
        is $plain_text, $truthdata, "testing decryption of long ciphertext $num";
    }

    # decryption #1
    {
        my $ciphertext = Q:to/END/; 
        RFUGZ EDPUD NRGYS ZRCXN
        UYTPO MRMBO FKTBZ REZKM
        LXLVE FGUEY SIOZV EQMIK
        UBPMM YLKLT TDEIS MDICA
        GYKUA CTCDO MOHWX MUUIA
        UBSTS LRNBZ SZWNR FXWFY
        SSXJZ VIJHI DISHP RKLKA
        YUPAD TXQSP INQMA TLPIF
        SVKDA SCTAC DPBOP VHJK
        END

        my $truthdata = Q:to/END/; 
        AUFKL XABTE ILUNG XVONX 
        KURTI NOWAX KURTI NOWAX
        NORDW ESTLX SEBEZ XSEBE
        ZXUAF FLIEG ERSTR ASZER
        IQTUN GXDUB ROWKI XDUBR
        OWKIX OPOTS CHKAX OPOTS
        CHKAX UMXEI NSAQT DREIN
        ULLXU HRANG ETRET ENXAN
        GRIFF XINFX RGTX
        END

        decrypt('WXC', 'KCH', $ciphertext, $truthdata, 1);
    }
    
    # decryption #2
    {

        my $ciphertext = Q:to/END/; 
        FNJAU SFBWD NJUSE GQOBH
        KRTAR EEZMW KPPRB XOHDR
        OEQGB BGTQV PGVKB VVGBI
        MHUSZ YDAJQ IROAX SSSNR
        EHYGG RPISE ZBOVM QIEMM
        ZCYSG QDGRE RVBIL EKXYQ
        IRGIR QNRDN VRXCY YTNJR
        END

        my $truthdata = Q:to/END/; 
        DREIG EHTLA NGSAM ABERS 
        IQERV ORWAE RTSXE INSSI 
        EBENN ULLSE QSXUH RXROE 
        MXEIN SXINF RGTXD REIXA 
        UFFLI EGERS TRASZ EMITA 
        NFANG XEINS SEQSX KMXKM 
        XOSTW XKAME NECXK
        END

        decrypt('CRS', 'YPJ', $ciphertext, $truthdata, 2);
    }

}

{

    my $stecker ='1/20 2/12 4/6 7/10 8/13 14/23 15/16 17/25 18/26 22/24';

    my $machine = Machine.from-key-sheet(
        :rotors('Beta II V I'),
        :ring-settings('A A A V'),
        :reflector-setting('B-Thin'),
        :plugboard-setting($stecker)
    );
    
    my $ciphertext = 
    "FCLC QRKN OWDO SGCI HTXG LFJD CEXL JJTW URVW HVPJ CHJN DRQM RXAF YFLR
     ULNY LOPH ROPZ WVLJ QAQR DUCO FVKC FQFU XDBF OAIM DOQO TMMX KHWB XLGH
     QDWW RNJQ IWUW COOK MZRI ZOVL PTIZ QSMG YCWI MZLG RIKN IIKU FDHC AYIJ
     SVKL TTBY UNCN EFME ARJZ MCPZ SOGF CQRP LGTF PNXG LXSU HFVT RKUX YROP
     GQNP MFCY LUXY BLFB FCLC QRKM VA".comb(/\w/).join();
 
    # remove the message indicators from the message (the first and last 2
    # groups of the message -- it appears the last partial group 'VA' should
    # be removed also)
    $ciphertext = $ciphertext.substr(8, *-10);

    $machine.set-display('VJNA');
    my $plaintext = $machine.process-text($ciphertext);

    my $truthdata = 
    "VONV ONJL OOKS JHFF TTTE
    INSE INSD REIZ WOYY QNNS
    NEUN INHA LTXX BEIA NGRI
    FFUN TERW ASSE RGED RUEC
    KTYW ABOS XLET ZTER GEGN
    ERST ANDN ULAC HTDR EINU
    LUHR MARQ UANT ONJO TANE
    UNAC HTSE YHSD REIY ZWOZ
    WONU LGRA DYAC HTSM YSTO
    SSEN ACHX EKNS VIER MBFA
    ELLT YNNN NNNO OOVI ERYS
    ICHT EINS NULL".comb(/\w/).join();

    is $plaintext, $truthdata,
    "testing decryption of message using Kriegsmarine style";
}

done-testing;
