# Lingua::Unihan

[![Build Status](https://travis-ci.org/fayland/perl6-Lingua-Unihan.svg?branch=master)](https://travis-ci.org/fayland/perl6-Lingua-Unihan)

```
    use Lingua::Unihan;

    my $codepoint = unihan_codepoint('你'); # 4f60

    my $mandarin = unihan_query('kMandarin', '林'); # 'lín'
    my $strokes  = unihan_query('kTotalStrokes', '林'); # 8
```

## Supported Filed Type

 * kCangjie
 * kCantonese
 * kCheungBauer
 * kCihaiT
 * kDefinition
 * kFenn
 * kFourCornerCode
 * kFrequency
 * kGradeLevel
 * kHDZRadBreak
 * kHKGlyph
 * kHangul
 * kHanyuPinlu
 * kHanyuPinyin
 * kJapaneseKun
 * kJapaneseOn
 * kKorean
 * kMandarin
 * kPhonetic
 * kTang
 * kTotalStrokes
 * kVietnamese
 * kXHC1983