sub ווו is export {
    put joke;
    put pic;
}

given ^6 .pick {
    my &s = sub (|) { ווו(); nextsame };
    when 0 { &say         .wrap: &s }
    when 1 { &infix:<+>   .wrap: &s }
    when 2 { &infix:<->   .wrap: &s }
    when 3 { &infix:</>   .wrap: &s }
    when 4 { &infix:<*>   .wrap: &s }
    when 5 { &postfix:<++>.wrap: &s }
}

sub joke {
    return (
        q:to/END/,
        Why will you never see Satan in an Armani suit?
        The Devil Wears Prada.
        END

        q:to/END/,
        I joined a satanic cult the other day, just for the hell of it.
        END

        q:to/END/,
            Q: What do demons have for breakfast?
            A: Devilled eggs!
        END

        q:to/END/,
        "And God said, "Let there be Satan, so people don't blame
        everything on me. And let there be lawyers, so people don't blame everything on Satan."—George Burns
        END

        q:to/END/,
        Jesus and Satan were having an ongoing argument about who was better
        on his computer. They had been going at it for days, and God was
        tired of hearing all of the bickering.

        Finally God said, "Cool it. I am going to set up a test that will
        run two hours and I will judge who does the better job."

        So Satan and Jesus sat down at the keyboards and typed away. They
        moused. They did spreadsheets. They wrote reports. They sent faxes.
        They sent e-mail. They sent out e-mail with attachments. They
        downloaded. They did some genealogy reports. They made cards. They
        did every known job. But ten minutes before their time was up,
        lightning suddenly flashed across the sky, thunder rolled, the rain
        poured and, of course, the electricity went off.

        Satan stared at his blank screen and screamed every curse word known
        in the underworld. Jesus just sighed. The electricity finally
        flickered back on and each of them restarted their computers.

        Satan started searching frantically, screaming "It's gone! It's all
        gone! I lost everything when the power went out!"

        Meanwhile, Jesus quietly started printing out all of his files from
        the past two hours. Satan observed this and became irate.

        "Wait! He cheated, how did he do it?"

        God shrugged and said, "Jesus saves."
        END

        q:to/END/,
        A man goes to hell and the devil greets him. He takes him to a
        hallway which has three different doors and tells the man he'll have
        to choose one room to spend the rest of eternity in.

        So he takes him to the first door and he opens it and sees everyone
        standing on their heads on wooden floors. The man thought that would
        be pretty terrible to spend the rest of eternity on his head on such
        a hard floor and asked the devil to show him the second door.

        Everyone in the second room was standing on their heads on concrete.
        The man thought that was even worse to spend the rest of eternity on
        his head on an even harder floor.

        Finally the devil takes him to the third door and in that room
        everyone is up to their knees in dog shit and drinking coffee. The
        man thought that was pretty bad, but at least they could drink
        coffee so he told the devil he chose the third room to spend the
        rest of eternity in. So the man, up to his knees in dog shit, drank
        coffee for a few minutes. Then the devil came back into the room and
        said "Coffee break is over. Back on your heads."
        END
    ).pick;
}

sub pic {
    return (
        Q:to/END/,
                                     *
                              *
                   (\___/)     (
                   \ (- -)     )\ *
                   c\   >'    ( #
                     )-_/      '
              _______| |__    ,|//
             # ___ `  ~   )  ( /
             \,|  | . ' .) \ /#
            _( /  )   , / \ / |
             //  ;;,,;,;   \,/
              _,#;,;;,;,
             /,i;;;,,;#,;
            ((  %;;,;,;;,;
             ))  ;#;,;%;;,,
           _//    ;,;; ,#;,
          /_)     #,;  //
                 //    \|_
                 \|_    |#\
                  |#\    -"  b'ger
                   -"
        END
        Q:to/END/,
         *                       *
            *                 *
           )       (\___/)     (
        * /(       \ (. .)     )\ *
          # )      c\   >'    ( #
           '         )-_/      '
         \\|,    ____| |__    ,|//
           \ )  (  `  ~   )  ( /
            #\ / /| . ' .) \ /#
            | \ / )   , / \ / |
             \,/ ;;,,;,;   \,/
              _,#;,;;,;,
             /,i;;;,,;#,;
            //  %;;,;,;;,;
           ((    ;#;,;%;;,,
          _//     ;,;; ,#;,
         /_)      #,;    ))
                 //      \|_
                 \|_      |#\
                  |#\      -"  b'ger
                   -"
        END
        Q:to/END/,
                                       *
                                       _
                                      /,\_
                                      |___)
                                      ,
                         (\___/)   * (
                         \ (. .)      \ *
                         c\   >'      #
                           )`_/      '
                    _______| |__    ,|//
                   # ___ `  ~   )  ( /
                   \,|  | . ' .) \ /#
                  _( /  )   , / \ / |
                   // ,#;,,;,;   \,/
           __,,    ,#;,;;,;;
           \__(    i;;;,,;;
              \\,;;,%;;,;#
               %,;;:,%;,;%
                      ;,;;
                      #,;
                     //
                     \|_
                      |#\   b'ger
                       -"
        END
    ).pick;
}
