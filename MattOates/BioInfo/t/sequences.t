use v6;
use Test;
plan 13;

use BioInfo::Seq::DNA;
use BioInfo::Seq::Amino;

{
    my $dna = BioInfo::Seq::DNA.new(id=>'AT4G03560.1', comment=>'atTPC1 Channel', sequence=>'ATGGAAGACCCGTTGATTGGTAGAGATAGTCTTGGTGGTGGTGGTACGGATCGGGTTCGTCGATCAGAAGCTATCACGCATGGTACTCCGTTTCAGAAAGCAGCTGCACTCGTTGATCTGGCTGAAGATGGTATTGGTCTTCCTGTGGAAATACTTGATCAGTCGAGTTTCGGGGAGTCTGCTAGGTATTACTTCATCTTCACACGTTTGGATCTGATCTGGTCACTCAACTATTTCGCTCTGCTTTTCCTTAACTTCTTCGAGCAACCATTGTGGTGTGAAAAAAACCCTAAACCGTCTTGCAAAGATAGAGATTACTATTACCTGGGAGAGTTACCGTACTTGACCAATGCAGAATCCATTATCTATGAGGTGATTACCCTGGCTATACTCCTTGTACATACTTTCTTCCCGATATCCTATGAAGGTTCCCGAATCTTTTGGACTAGTCGCCTGAATCTAGTGAAGGTTGCTTGCGTGGTAATTTTGTTTGTTGATGTGCTGGTTGACTTTCTGTATCTGTCTCCACTGGCTTTCGACTTTCTCCCTTTTAGAATCGCCCCATACGTGAGAGTTATCATATTCATCCTCAGCATAAGGGAACTTCGGGACACCCTTGTCCTTCTGTCTGGAATGCTTGGCACATACTTGAATATCTTGGCTCTATGGATGCTGTTCCTTCTATTTGCCAGTTGGATTGCTTTTGTTATGTTTGAGGACACGCAGCAGGGCCTCACGGTCTTCACTTCATATGGTGCAACTCTTTACCAGATGTTTATTTTGTTCACAACATCCAACAATCCTGATGTCTGGATTCCTGCATACAAGTCTTCTCGCTGGTCTTCGGTGTTCTTCGTGCTCTACGTGCTAATTGGCGTCTACTTTGTCACAAACTTGATTCTTGCCGTTGTTTATGACAGTTTCAAAGAACAGCTCGCAAAGCAAGTATCTGGAATGGATCAAATGAAGAGAAGAATGTTGGAGAAAGCCTTTGGTCTTATAGACTCAGACAAAAACGGGGAGATTGATAAGAACCAATGCATTAAGCTCTTTGAACAGTTGACTAATTACAGGACGTTGCCGAAGATATCAAAAGAAGAATTCGGATTGATATTTGATGAGCTTGACGATACTCGTGACTTTAAGATAAACAAGGATGAGTTTGCTGACCTCTGCCAGGCCATTGCTTTAAGATTCCAAAAGGAGGAAGTACCGTCTCTCTTTGAACATTTTCCGCAAATTTACCATTCCGCCTTATCACAACAACTGAGAGCCTTTGTTCGAAGCCCCAACTTTGGCTACGCTATTTCTTTCATCCTCATTATCAATTTCATTGCTGTCGTTGTTGAAACAACGCTTGATATCGAAGAAAGCTCGGCTCAGAAGCCATGGCAGGTTGCCGAGTTTGTCTTTGGTTGGATATATGTGTTGGAGATGGCTCTGAAGATCTATACATATGGATTTGAGAATTATTGGAGAGAGGGTGCTAACCGATTTGATTTTCTAGTCACATGGGTCATAGTTATTGGGGAAACAGCTACCTTCATAACTCCAGACGAGAATACTTTCTTCTCAAATGGAGAATGGATCCGGTACCTTCTCCTGGCGAGAATGTTAAGACTGATAAGGCTTCTTATGAACGTCCAGCGATACCGAGCATTTATTGCGACGTTCATAACTCTTATTCCAAGTTTGATGCCATATTTAGGGACCATTTTCTGCGTGCTGTGTATCTACTGCTCTATTGGCGTACAGGTCTTTGGAGGGCTTGTGAATGCTGGGAACAAAAAGCTCTTTGAAACCGAATTGGCTGAGGATGACTACCTTTTGTTCAACTTCAATGACTACCCCAATGGAATGGTCACACTCTTCAATCTGCTAGTTATGGGTAACTGGCAAGTATGGATGGAGAGCTACAAAGATTTGACGGGCACGTGGTGGAGCATTACATATTTCGTCAGTTTCTATGTCATCACTATTTTACTTCTGTTGAATTTGGTTGTTGCCTTTGTCTTGGAGGCGTTCTTTACTGAGCTGGATCTTGAAGAAGAAGAAAAATGTCAAGGACAGGATTCTCAAGAAAAAAGAAACAGGCGTCGATCTGCAGGGTCGAAGTCTCGGAGTCAGAGAGTTGATACACTTCTTCATCACATGTTGGGTGATGAACTCAGCAAACCAGAGTGTTCCACTTCTGACACATAA');
    isa-ok $dna, BioInfo::Seq::DNA, 'Created DNA Seq successfully.';

    ok ~$dna eq ">AT4G03560.1 atTPC1 Channel\nATGGAAGACCCGTTGATTGGTAGAGATAGTCTTGGTGGTGGTGGTACGGATCGGGTTCGTCGATCAGAAGCTATCACGCATGGTACTCCGTTTCAGAAAGCAGCTGCACTCGTTGATCTGGCTGAAGATGGTATTGGTCTTCCTGTGGAAATACTTGATCAGTCGAGTTTCGGGGAGTCTGCTAGGTATTACTTCATCTTCACACGTTTGGATCTGATCTGGTCACTCAACTATTTCGCTCTGCTTTTCCTTAACTTCTTCGAGCAACCATTGTGGTGTGAAAAAAACCCTAAACCGTCTTGCAAAGATAGAGATTACTATTACCTGGGAGAGTTACCGTACTTGACCAATGCAGAATCCATTATCTATGAGGTGATTACCCTGGCTATACTCCTTGTACATACTTTCTTCCCGATATCCTATGAAGGTTCCCGAATCTTTTGGACTAGTCGCCTGAATCTAGTGAAGGTTGCTTGCGTGGTAATTTTGTTTGTTGATGTGCTGGTTGACTTTCTGTATCTGTCTCCACTGGCTTTCGACTTTCTCCCTTTTAGAATCGCCCCATACGTGAGAGTTATCATATTCATCCTCAGCATAAGGGAACTTCGGGACACCCTTGTCCTTCTGTCTGGAATGCTTGGCACATACTTGAATATCTTGGCTCTATGGATGCTGTTCCTTCTATTTGCCAGTTGGATTGCTTTTGTTATGTTTGAGGACACGCAGCAGGGCCTCACGGTCTTCACTTCATATGGTGCAACTCTTTACCAGATGTTTATTTTGTTCACAACATCCAACAATCCTGATGTCTGGATTCCTGCATACAAGTCTTCTCGCTGGTCTTCGGTGTTCTTCGTGCTCTACGTGCTAATTGGCGTCTACTTTGTCACAAACTTGATTCTTGCCGTTGTTTATGACAGTTTCAAAGAACAGCTCGCAAAGCAAGTATCTGGAATGGATCAAATGAAGAGAAGAATGTTGGAGAAAGCCTTTGGTCTTATAGACTCAGACAAAAACGGGGAGATTGATAAGAACCAATGCATTAAGCTCTTTGAACAGTTGACTAATTACAGGACGTTGCCGAAGATATCAAAAGAAGAATTCGGATTGATATTTGATGAGCTTGACGATACTCGTGACTTTAAGATAAACAAGGATGAGTTTGCTGACCTCTGCCAGGCCATTGCTTTAAGATTCCAAAAGGAGGAAGTACCGTCTCTCTTTGAACATTTTCCGCAAATTTACCATTCCGCCTTATCACAACAACTGAGAGCCTTTGTTCGAAGCCCCAACTTTGGCTACGCTATTTCTTTCATCCTCATTATCAATTTCATTGCTGTCGTTGTTGAAACAACGCTTGATATCGAAGAAAGCTCGGCTCAGAAGCCATGGCAGGTTGCCGAGTTTGTCTTTGGTTGGATATATGTGTTGGAGATGGCTCTGAAGATCTATACATATGGATTTGAGAATTATTGGAGAGAGGGTGCTAACCGATTTGATTTTCTAGTCACATGGGTCATAGTTATTGGGGAAACAGCTACCTTCATAACTCCAGACGAGAATACTTTCTTCTCAAATGGAGAATGGATCCGGTACCTTCTCCTGGCGAGAATGTTAAGACTGATAAGGCTTCTTATGAACGTCCAGCGATACCGAGCATTTATTGCGACGTTCATAACTCTTATTCCAAGTTTGATGCCATATTTAGGGACCATTTTCTGCGTGCTGTGTATCTACTGCTCTATTGGCGTACAGGTCTTTGGAGGGCTTGTGAATGCTGGGAACAAAAAGCTCTTTGAAACCGAATTGGCTGAGGATGACTACCTTTTGTTCAACTTCAATGACTACCCCAATGGAATGGTCACACTCTTCAATCTGCTAGTTATGGGTAACTGGCAAGTATGGATGGAGAGCTACAAAGATTTGACGGGCACGTGGTGGAGCATTACATATTTCGTCAGTTTCTATGTCATCACTATTTTACTTCTGTTGAATTTGGTTGTTGCCTTTGTCTTGGAGGCGTTCTTTACTGAGCTGGATCTTGAAGAAGAAGAAAAATGTCAAGGACAGGATTCTCAAGAAAAAAGAAACAGGCGTCGATCTGCAGGGTCGAAGTCTCGGAGTCAGAGAGTTGATACACTTCTTCATCACATGTTGGGTGATGAACTCAGCAAACCAGAGTGTTCCACTTCTGACACATAA\n", 'String coerced Seq produces FASTA output.';

    ok $dna.complement.sequence eq 'TACCTTCTGGGCAACTAACCATCTCTATCAGAACCACCACCACCATGCCTAGCCCAAGCAGCTAGTCTTCGATAGTGCGTACCATGAGGCAAAGTCTTTCGTCGACGTGAGCAACTAGACCGACTTCTACCATAACCAGAAGGACACCTTTATGAACTAGTCAGCTCAAAGCCCCTCAGACGATCCATAATGAAGTAGAAGTGTGCAAACCTAGACTAGACCAGTGAGTTGATAAAGCGAGACGAAAAGGAATTGAAGAAGCTCGTTGGTAACACCACACTTTTTTTGGGATTTGGCAGAACGTTTCTATCTCTAATGATAATGGACCCTCTCAATGGCATGAACTGGTTACGTCTTAGGTAATAGATACTCCACTAATGGGACCGATATGAGGAACATGTATGAAAGAAGGGCTATAGGATACTTCCAAGGGCTTAGAAAACCTGATCAGCGGACTTAGATCACTTCCAACGAACGCACCATTAAAACAAACAACTACACGACCAACTGAAAGACATAGACAGAGGTGACCGAAAGCTGAAAGAGGGAAAATCTTAGCGGGGTATGCACTCTCAATAGTATAAGTAGGAGTCGTATTCCCTTGAAGCCCTGTGGGAACAGGAAGACAGACCTTACGAACCGTGTATGAACTTATAGAACCGAGATACCTACGACAAGGAAGATAAACGGTCAACCTAACGAAAACAATACAAACTCCTGTGCGTCGTCCCGGAGTGCCAGAAGTGAAGTATACCACGTTGAGAAATGGTCTACAAATAAAACAAGTGTTGTAGGTTGTTAGGACTACAGACCTAAGGACGTATGTTCAGAAGAGCGACCAGAAGCCACAAGAAGCACGAGATGCACGATTAACCGCAGATGAAACAGTGTTTGAACTAAGAACGGCAACAAATACTGTCAAAGTTTCTTGTCGAGCGTTTCGTTCATAGACCTTACCTAGTTTACTTCTCTTCTTACAACCTCTTTCGGAAACCAGAATATCTGAGTCTGTTTTTGCCCCTCTAACTATTCTTGGTTACGTAATTCGAGAAACTTGTCAACTGATTAATGTCCTGCAACGGCTTCTATAGTTTTCTTCTTAAGCCTAACTATAAACTACTCGAACTGCTATGAGCACTGAAATTCTATTTGTTCCTACTCAAACGACTGGAGACGGTCCGGTAACGAAATTCTAAGGTTTTCCTCCTTCATGGCAGAGAGAAACTTGTAAAAGGCGTTTAAATGGTAAGGCGGAATAGTGTTGTTGACTCTCGGAAACAAGCTTCGGGGTTGAAACCGATGCGATAAAGAAAGTAGGAGTAATAGTTAAAGTAACGACAGCAACAACTTTGTTGCGAACTATAGCTTCTTTCGAGCCGAGTCTTCGGTACCGTCCAACGGCTCAAACAGAAACCAACCTATATACACAACCTCTACCGAGACTTCTAGATATGTATACCTAAACTCTTAATAACCTCTCTCCCACGATTGGCTAAACTAAAAGATCAGTGTACCCAGTATCAATAACCCCTTTGTCGATGGAAGTATTGAGGTCTGCTCTTATGAAAGAAGAGTTTACCTCTTACCTAGGCCATGGAAGAGGACCGCTCTTACAATTCTGACTATTCCGAAGAATACTTGCAGGTCGCTATGGCTCGTAAATAACGCTGCAAGTATTGAGAATAAGGTTCAAACTACGGTATAAATCCCTGGTAAAAGACGCACGACACATAGATGACGAGATAACCGCATGTCCAGAAACCTCCCGAACACTTACGACCCTTGTTTTTCGAGAAACTTTGGCTTAACCGACTCCTACTGATGGAAAACAAGTTGAAGTTACTGATGGGGTTACCTTACCAGTGTGAGAAGTTAGACGATCAATACCCATTGACCGTTCATACCTACCTCTCGATGTTTCTAAACTGCCCGTGCACCACCTCGTAATGTATAAAGCAGTCAAAGATACAGTAGTGATAAAATGAAGACAACTTAAACCAACAACGGAAACAGAACCTCCGCAAGAAATGACTCGACCTAGAACTTCTTCTTCTTTTTACAGTTCCTGTCCTAAGAGTTCTTTTTTCTTTGTCCGCAGCTAGACGTCCCAGCTTCAGAGCCTCAGTCTCTCAACTATGTGAAGAAGTAGTGTACAACCCACTACTTGAGTCGTTTGGTCTCACAAGGTGAAGACTGTGTATT', 'Complement of DNA is correctly created.';

    ok ($dna.complement :reverse).sequence eq 'TTATGTGTCAGAAGTGGAACACTCTGGTTTGCTGAGTTCATCACCCAACATGTGATGAAGAAGTGTATCAACTCTCTGACTCCGAGACTTCGACCCTGCAGATCGACGCCTGTTTCTTTTTTCTTGAGAATCCTGTCCTTGACATTTTTCTTCTTCTTCAAGATCCAGCTCAGTAAAGAACGCCTCCAAGACAAAGGCAACAACCAAATTCAACAGAAGTAAAATAGTGATGACATAGAAACTGACGAAATATGTAATGCTCCACCACGTGCCCGTCAAATCTTTGTAGCTCTCCATCCATACTTGCCAGTTACCCATAACTAGCAGATTGAAGAGTGTGACCATTCCATTGGGGTAGTCATTGAAGTTGAACAAAAGGTAGTCATCCTCAGCCAATTCGGTTTCAAAGAGCTTTTTGTTCCCAGCATTCACAAGCCCTCCAAAGACCTGTACGCCAATAGAGCAGTAGATACACAGCACGCAGAAAATGGTCCCTAAATATGGCATCAAACTTGGAATAAGAGTTATGAACGTCGCAATAAATGCTCGGTATCGCTGGACGTTCATAAGAAGCCTTATCAGTCTTAACATTCTCGCCAGGAGAAGGTACCGGATCCATTCTCCATTTGAGAAGAAAGTATTCTCGTCTGGAGTTATGAAGGTAGCTGTTTCCCCAATAACTATGACCCATGTGACTAGAAAATCAAATCGGTTAGCACCCTCTCTCCAATAATTCTCAAATCCATATGTATAGATCTTCAGAGCCATCTCCAACACATATATCCAACCAAAGACAAACTCGGCAACCTGCCATGGCTTCTGAGCCGAGCTTTCTTCGATATCAAGCGTTGTTTCAACAACGACAGCAATGAAATTGATAATGAGGATGAAAGAAATAGCGTAGCCAAAGTTGGGGCTTCGAACAAAGGCTCTCAGTTGTTGTGATAAGGCGGAATGGTAAATTTGCGGAAAATGTTCAAAGAGAGACGGTACTTCCTCCTTTTGGAATCTTAAAGCAATGGCCTGGCAGAGGTCAGCAAACTCATCCTTGTTTATCTTAAAGTCACGAGTATCGTCAAGCTCATCAAATATCAATCCGAATTCTTCTTTTGATATCTTCGGCAACGTCCTGTAATTAGTCAACTGTTCAAAGAGCTTAATGCATTGGTTCTTATCAATCTCCCCGTTTTTGTCTGAGTCTATAAGACCAAAGGCTTTCTCCAACATTCTTCTCTTCATTTGATCCATTCCAGATACTTGCTTTGCGAGCTGTTCTTTGAAACTGTCATAAACAACGGCAAGAATCAAGTTTGTGACAAAGTAGACGCCAATTAGCACGTAGAGCACGAAGAACACCGAAGACCAGCGAGAAGACTTGTATGCAGGAATCCAGACATCAGGATTGTTGGATGTTGTGAACAAAATAAACATCTGGTAAAGAGTTGCACCATATGAAGTGAAGACCGTGAGGCCCTGCTGCGTGTCCTCAAACATAACAAAAGCAATCCAACTGGCAAATAGAAGGAACAGCATCCATAGAGCCAAGATATTCAAGTATGTGCCAAGCATTCCAGACAGAAGGACAAGGGTGTCCCGAAGTTCCCTTATGCTGAGGATGAATATGATAACTCTCACGTATGGGGCGATTCTAAAAGGGAGAAAGTCGAAAGCCAGTGGAGACAGATACAGAAAGTCAACCAGCACATCAACAAACAAAATTACCACGCAAGCAACCTTCACTAGATTCAGGCGACTAGTCCAAAAGATTCGGGAACCTTCATAGGATATCGGGAAGAAAGTATGTACAAGGAGTATAGCCAGGGTAATCACCTCATAGATAATGGATTCTGCATTGGTCAAGTACGGTAACTCTCCCAGGTAATAGTAATCTCTATCTTTGCAAGACGGTTTAGGGTTTTTTTCACACCACAATGGTTGCTCGAAGAAGTTAAGGAAAAGCAGAGCGAAATAGTTGAGTGACCAGATCAGATCCAAACGTGTGAAGATGAAGTAATACCTAGCAGACTCCCCGAAACTCGACTGATCAAGTATTTCCACAGGAAGACCAATACCATCTTCAGCCAGATCAACGAGTGCAGCTGCTTTCTGAAACGGAGTACCATGCGTGATAGCTTCTGATCGACGAACCCGATCCGTACCACCACCACCAAGACTATCTCTACCAATCAACGGGTCTTCCAT', 'Reverse complement of DNA is correctly created.';

    my $aa = $dna.translate;
    isa-ok $aa, BioInfo::Seq::Amino, 'Translating DNA created an Amino acid sequence.';

    ok +$aa == 734, 'Translated Amino acid sequence has the correct length when coerced to Numeric.';
    ok $aa.Bag eqv ("P"=>23,"I"=>54,"S"=>46,"F"=>62,"Y"=>34,"C"=>10,""=>2,"L"=>96,"V"=>51,"Q"=>25,"E"=>47,"W"=>16,"G"=>37,"R"=>35,"T"=>41,"H"=>6,"K"=>27,"*"=>1,"M"=>16,"A"=>40,"D"=>38,"N"=>29).Bag, 'Producing a Bag from a sequence yields the Amino acid composition as a bag model.';

    my @orfs = $dna.three-frame-translate;
    ok +@orfs == 3, '3frame translating produces three Amino acid sequences, upto one for each frame.';

    @orfs = $dna.three-frame-translate :break-on-stop;
    ok +@orfs == 81, '3frame breaking-on-stop translating produces the necessary number of sequence objects.';

    @orfs = $dna.three-frame-translate :break-on-stop :min-length(7);
    ok +@orfs == 53, '3frame breaking-on-stop and filtering by min-length correct number of sequence objects.';

    @orfs = $dna.six-frame-translate;
    ok +@orfs == 6, '6frame translating produces six Amino acid sequences, upto one for each frame.';

    @orfs = $dna.six-frame-translate :break-on-stop;
    ok +@orfs == 180, '6frame breaking-on-stop translating produces the necessary number of sequence objects.';

    @orfs = $dna.six-frame-translate :break-on-stop :min-length(7);
    ok +@orfs == 123, '6frame breaking-on-stop and filtering by min-length correct number of sequence objects.';
}

done;
