#!/usr/bin/env sh

# UnicodeData.txt
#
# codepoint character-name general-catagory
# canonical-combining-classes bidirectional-category
# character-decomposition-mapping decimal-digit-value
# digit-value numeric-value mirrored unicode10name
# iso10646-comment-field uppercase-mapping lowercase-mapping
# titlecase-mapping

#generate-module \
#  --mod-name='GeneralCatagory' --cat='Ll,Lu,Lo,Nd,Lm,Mn,Mc' \
#  --cat-field=2 UnicodeData.txt

#generate-module \
#  --mod-name='Bidi' --cat='L,R,AL,AN,EN,ES,CS,ET,ON,BN,NSM' \
#  --table  -cat-field=4 \
#  --fields=codepoint,,general-catagory,,bidirectional-category \
#  UnicodeData.txt

#generate-module \
#  --mod-name='Controls' --cat='Cc' -cat-field=2 UnicodeData.txt

#generate-module \
#  --mod-name='Controls' --cat='Cc' \
#  --fields=codepoint,character-name,general-catagory \
#  --cat-field=2 --table UnicodeData.txt

#generate-module \
#  --mod-name='Controls' --cat='Cc' UCD

#generate-module \
#  --mod-name='JoinControl' --cat='Join_Control' \
#  --fields='codepoint,property' PropList.txt

#generate-module \
#  --mod-name='OldHangulJamo' --cat=V,T,L \
#  --fields=codepoint,property HangulSyllableType.txt

#generate-module \
#  --mod-name='Unassigned' --cat='Cn' \
#  --fields=codepoint,property extracted/DerivedGeneralCategory.txt

generate-module \
  --mod-name='NonCharCodepoint' --cat='Noncharacter_Code_Point' \
  --fields='codepoint,property' PropList.txt

#generate-module \
#  --mod-name='Bidi1stChar' --cat=L,R,AL \
#  --fields=codepoint,property extracted/DerivedBidiClass.txt
