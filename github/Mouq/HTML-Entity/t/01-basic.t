use HTML::Entity :ALL;
use Test;
plan 6;

is encode("This <em>needs</em> to be escaped & encoded!"),
    "This &lt;em&gt;needs&lt;/em&gt; to be escaped &amp; encoded!",
    "Basic encoding works";

is decode("4.99 &approx; 5"), "4.99 ≈ 5",
    "Basic decoding works";

is HTML::Entity<&nesim;>, "≂̸", "Can look up entities";

is encode("™"), "&#8482;", "Can encode (appropriate) characters > 127";

is decode("fj&aumlril"), "fjäril", "Decoding works for entities that don't require semicolons";
is decode("&nbsp; &gt; &nbsp&lt;&nbump;"), "  >  <≎̸", "Decoding multiple entities is fine";
