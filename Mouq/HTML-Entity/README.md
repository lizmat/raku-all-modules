# HTML::Entity

Generated from the official list of valid HTML entities and can decode
entity-laden text via `&decode-entities` (or `&decode` if `use … :ALL` is given)

Can also encode basic entities via `&encode-entities`/`&encode`.

## Synopsis

    use HTML::Entity;
    
    say encode-entities "This <em>needs</em> to be escaped & encoded!";
        # This &lt;em&gt;needs&lt;/em&gt; to be escaped &amp; encoded!
    say decode-entities "4.99 &approx; 5"; # 4.99 ≈ 5
    say HTML::Entity<&nesim;>              # ≂̸

    use HTML::Entity :ALL;
    
    say decode "fj&aumlril"; # fjäril
    say encode "A & B < C";  # A &amp; B &lt; C
