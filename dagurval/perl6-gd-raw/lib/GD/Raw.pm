use NativeCall;

sub LIB {
    #return "/home/dagurval/libgd/src/.libs/libgd";
    given $*VM.name {
       when 'parrot' {
           given $*VM.config<load_ext> {
               when '.so' { return 'libgd.so' }	# Linux
	            when '.bundle' { return 'libgd.dylib' }	# Mac OS
	            default { return 'libgd' }
           }
       }
       default {
          return 'libgd';
       }
    }
}

constant gdAlphaMax is export = 127;
constant gdAlphaOpaque is export = 0;
constant gdAlphaTransparent is export = 127;
constant gdRedMax is export = 255;
constant gdGreenMax is export = 255;
constant gdBlueMax is export = 255;
sub gdTrueColorGetAlpha($c) is export {
    ((($c) +& 0x7F000000) +> 24)
}
sub gdTrueColorGetRed($c) is export {
    ((($c) +& 0xFF0000) +> 16)
}
sub gdTrueColorGetGreen($c) is export {
    ((($c) +& 0x00FF00) +> 8)
}
sub gdTrueColorGetBlue($c) is export {
    (($c) +& 0x0000FF)
}

enum gdInterpolationMethod (
	GD_DEFAULT          => 0,
	GD_BELL => 1,
	GD_BESSEL => 2,
	GD_BILINEAR_FIXED => 3,
	GD_BICUBIC => 4,
	GD_BICUBIC_FIXED => 5,
	GD_BLACKMAN => 6,
	GD_BOX => 7,
	GD_BSPLINE => 8,
	GD_CATMULLROM => 9,
	GD_GAUSSIAN => 10,
	GD_GENERALIZED_CUBIC => 11,
	GD_HERMITE => 12,
	GD_HAMMING => 13,
	GD_HANNING => 14,
	GD_MITCHELL => 15,
	GD_NEAREST_NEIGHBOUR => 16,
	GD_POWER => 17,
	GD_QUADRATIC => 18,
	GD_SINC => 19,
	GD_TRIANGLE => 20,
    GD_WEIGHTED4 => 21,
	GD_METHOD_COUNT => 21
);

constant gdEffectReplace is export = 0;
constant gdEffectAlphaBlend is export = 1;
constant gdEffectNormal is export = 2;
constant gdEffectOverlay is export = 3;

class gdImageStruct is repr('CStruct') is export {
    has OpaquePointer $.pixels;
    has int32 $.sx;
    has int32 $.sy;
	has int32 $.colorsTotal;

    # NativeCall doesn't support int red[gdMaxColors] yet.
    # Hack a placeholder.
    has int32 ($.red0, $.red1, $.red2, $.red3, $.red4, $.red5, $.red6, $.red7,
        $.red8, $.red9, $.red10, $.red11, $.red12, $.red13, $.red14, $.red15,
        $.red16, $.red17, $.red18, $.red19, $.red20, $.red21, $.red22, $.red23,
        $.red24, $.red25, $.red26, $.red27, $.red28, $.red29, $.red30, $.red31, $.red32, $.red33, $.red34, $.red35, $.red36, $.red37, $.red38, $.red39, $.red40, $.red41, $.red42, $.red43, $.red44, $.red45, $.red46, $.red47, $.red48, $.red49, $.red50, $.red51, $.red52, $.red53, $.red54, $.red55, $.red56, $.red57, $.red58, $.red59, $.red60, $.red61, $.red62, $.red63, $.red64, $.red65, $.red66, $.red67, $.red68, $.red69, $.red70, $.red71, $.red72, $.red73, $.red74, $.red75, $.red76, $.red77, $.red78, $.red79, $.red80, $.red81, $.red82, $.red83, $.red84, $.red85, $.red86, $.red87, $.red88, $.red89, $.red90, $.red91, $.red92, $.red93, $.red94, $.red95, $.red96, $.red97, $.red98, $.red99, $.red100, $.red101, $.red102, $.red103, $.red104, $.red105, $.red106, $.red107, $.red108, $.red109, $.red110, $.red111, $.red112, $.red113, $.red114, $.red115, $.red116, $.red117, $.red118, $.red119, $.red120, $.red121, $.red122, $.red123, $.red124, $.red125, $.red126, $.red127, $.red128, $.red129, $.red130, $.red131, $.red132, $.red133, $.red134, $.red135, $.red136, $.red137, $.red138, $.red139, $.red140, $.red141, $.red142, $.red143, $.red144, $.red145, $.red146, $.red147, $.red148, $.red149, $.red150, $.red151, $.red152, $.red153, $.red154, $.red155, $.red156, $.red157, $.red158, $.red159, $.red160, $.red161, $.red162, $.red163, $.red164, $.red165, $.red166, $.red167, $.red168, $.red169, $.red170, $.red171, $.red172, $.red173, $.red174, $.red175, $.red176, $.red177, $.red178, $.red179, $.red180, $.red181, $.red182, $.red183, $.red184, $.red185, $.red186, $.red187, $.red188, $.red189, $.red190, $.red191, $.red192, $.red193, $.red194, $.red195, $.red196, $.red197, $.red198, $.red199, $.red200, $.red201, $.red202, $.red203, $.red204, $.red205, $.red206, $.red207, $.red208, $.red209, $.red210, $.red211, $.red212, $.red213, $.red214, $.red215, $.red216, $.red217, $.red218, $.red219, $.red220, $.red221, $.red222, $.red223, $.red224, $.red225, $.red226, $.red227, $.red228, $.red229, $.red230, $.red231, $.red232, $.red233, $.red234, $.red235, $.red236, $.red237, $.red238, $.red239, $.red240, $.red241, $.red242, $.red243, $.red244, $.red245, $.red246, $.red247, $.red248, $.red249, $.red250, $.red251, $.red252, $.red253, $.red254, $.red255, );
    has int32 ($.green0, $.green1, $.green2, $.green3, $.green4, $.green5, $.green6, $.green7, $.green8, $.green9, $.green10, $.green11, $.green12, $.green13, $.green14, $.green15, $.green16, $.green17, $.green18, $.green19, $.green20, $.green21, $.green22, $.green23, $.green24, $.green25, $.green26, $.green27, $.green28, $.green29, $.green30, $.green31, $.green32, $.green33, $.green34, $.green35, $.green36, $.green37, $.green38, $.green39, $.green40, $.green41, $.green42, $.green43, $.green44, $.green45, $.green46, $.green47, $.green48, $.green49, $.green50, $.green51, $.green52, $.green53, $.green54, $.green55, $.green56, $.green57, $.green58, $.green59, $.green60, $.green61, $.green62, $.green63, $.green64, $.green65, $.green66, $.green67, $.green68, $.green69, $.green70, $.green71, $.green72, $.green73, $.green74, $.green75, $.green76, $.green77, $.green78, $.green79, $.green80, $.green81, $.green82, $.green83, $.green84, $.green85, $.green86, $.green87, $.green88, $.green89, $.green90, $.green91, $.green92, $.green93, $.green94, $.green95, $.green96, $.green97, $.green98, $.green99, $.green100, $.green101, $.green102, $.green103, $.green104, $.green105, $.green106, $.green107, $.green108, $.green109, $.green110, $.green111, $.green112, $.green113, $.green114, $.green115, $.green116, $.green117, $.green118, $.green119, $.green120, $.green121, $.green122, $.green123, $.green124, $.green125, $.green126, $.green127, $.green128, $.green129, $.green130, $.green131, $.green132, $.green133, $.green134, $.green135, $.green136, $.green137, $.green138, $.green139, $.green140, $.green141, $.green142, $.green143, $.green144, $.green145, $.green146, $.green147, $.green148, $.green149, $.green150, $.green151, $.green152, $.green153, $.green154, $.green155, $.green156, $.green157, $.green158, $.green159, $.green160, $.green161, $.green162, $.green163, $.green164, $.green165, $.green166, $.green167, $.green168, $.green169, $.green170, $.green171, $.green172, $.green173, $.green174, $.green175, $.green176, $.green177, $.green178, $.green179, $.green180, $.green181, $.green182, $.green183, $.green184, $.green185, $.green186, $.green187, $.green188, $.green189, $.green190, $.green191, $.green192, $.green193, $.green194, $.green195, $.green196, $.green197, $.green198, $.green199, $.green200, $.green201, $.green202, $.green203, $.green204, $.green205, $.green206, $.green207, $.green208, $.green209, $.green210, $.green211, $.green212, $.green213, $.green214, $.green215, $.green216, $.green217, $.green218, $.green219, $.green220, $.green221, $.green222, $.green223, $.green224, $.green225, $.green226, $.green227, $.green228, $.green229, $.green230, $.green231, $.green232, $.green233, $.green234, $.green235, $.green236, $.green237, $.green238, $.green239, $.green240, $.green241, $.green242, $.green243, $.green244, $.green245, $.green246, $.green247, $.green248, $.green249, $.green250, $.green251, $.green252, $.green253, $.green254, $.green255, );
has int32 ($.blue0, $.blue1, $.blue2, $.blue3, $.blue4, $.blue5, $.blue6, $.blue7, $.blue8, $.blue9, $.blue10, $.blue11, $.blue12, $.blue13, $.blue14, $.blue15, $.blue16, $.blue17, $.blue18, $.blue19, $.blue20, $.blue21, $.blue22, $.blue23, $.blue24, $.blue25, $.blue26, $.blue27, $.blue28, $.blue29, $.blue30, $.blue31, $.blue32, $.blue33, $.blue34, $.blue35, $.blue36, $.blue37, $.blue38, $.blue39, $.blue40, $.blue41, $.blue42, $.blue43, $.blue44, $.blue45, $.blue46, $.blue47, $.blue48, $.blue49, $.blue50, $.blue51, $.blue52, $.blue53, $.blue54, $.blue55, $.blue56, $.blue57, $.blue58, $.blue59, $.blue60, $.blue61, $.blue62, $.blue63, $.blue64, $.blue65, $.blue66, $.blue67, $.blue68, $.blue69, $.blue70, $.blue71, $.blue72, $.blue73, $.blue74, $.blue75, $.blue76, $.blue77, $.blue78, $.blue79, $.blue80, $.blue81, $.blue82, $.blue83, $.blue84, $.blue85, $.blue86, $.blue87, $.blue88, $.blue89, $.blue90, $.blue91, $.blue92, $.blue93, $.blue94, $.blue95, $.blue96, $.blue97, $.blue98, $.blue99, $.blue100, $.blue101, $.blue102, $.blue103, $.blue104, $.blue105, $.blue106, $.blue107, $.blue108, $.blue109, $.blue110, $.blue111, $.blue112, $.blue113, $.blue114, $.blue115, $.blue116, $.blue117, $.blue118, $.blue119, $.blue120, $.blue121, $.blue122, $.blue123, $.blue124, $.blue125, $.blue126, $.blue127, $.blue128, $.blue129, $.blue130, $.blue131, $.blue132, $.blue133, $.blue134, $.blue135, $.blue136, $.blue137, $.blue138, $.blue139, $.blue140, $.blue141, $.blue142, $.blue143, $.blue144, $.blue145, $.blue146, $.blue147, $.blue148, $.blue149, $.blue150, $.blue151, $.blue152, $.blue153, $.blue154, $.blue155, $.blue156, $.blue157, $.blue158, $.blue159, $.blue160, $.blue161, $.blue162, $.blue163, $.blue164, $.blue165, $.blue166, $.blue167, $.blue168, $.blue169, $.blue170, $.blue171, $.blue172, $.blue173, $.blue174, $.blue175, $.blue176, $.blue177, $.blue178, $.blue179, $.blue180, $.blue181, $.blue182, $.blue183, $.blue184, $.blue185, $.blue186, $.blue187, $.blue188, $.blue189, $.blue190, $.blue191, $.blue192, $.blue193, $.blue194, $.blue195, $.blue196, $.blue197, $.blue198, $.blue199, $.blue200, $.blue201, $.blue202, $.blue203, $.blue204, $.blue205, $.blue206, $.blue207, $.blue208, $.blue209, $.blue210, $.blue211, $.blue212, $.blue213, $.blue214, $.blue215, $.blue216, $.blue217, $.blue218, $.blue219, $.blue220, $.blue221, $.blue222, $.blue223, $.blue224, $.blue225, $.blue226, $.blue227, $.blue228, $.blue229, $.blue230, $.blue231, $.blue232, $.blue233, $.blue234, $.blue235, $.blue236, $.blue237, $.blue238, $.blue239, $.blue240, $.blue241, $.blue242, $.blue243, $.blue244, $.blue245, $.blue246, $.blue247, $.blue248, $.blue249, $.blue250, $.blue251, $.blue252, $.blue253, $.blue254, $.blue255, );

has int32 ($.open0, $.open1, $.open2, $.open3, $.open4, $.open5, $.open6, $.open7, $.open8, $.open9, $.open10, $.open11, $.open12, $.open13, $.open14, $.open15, $.open16, $.open17, $.open18, $.open19, $.open20, $.open21, $.open22, $.open23, $.open24, $.open25, $.open26, $.open27, $.open28, $.open29, $.open30, $.open31, $.open32, $.open33, $.open34, $.open35, $.open36, $.open37, $.open38, $.open39, $.open40, $.open41, $.open42, $.open43, $.open44, $.open45, $.open46, $.open47, $.open48, $.open49, $.open50, $.open51, $.open52, $.open53, $.open54, $.open55, $.open56, $.open57, $.open58, $.open59, $.open60, $.open61, $.open62, $.open63, $.open64, $.open65, $.open66, $.open67, $.open68, $.open69, $.open70, $.open71, $.open72, $.open73, $.open74, $.open75, $.open76, $.open77, $.open78, $.open79, $.open80, $.open81, $.open82, $.open83, $.open84, $.open85, $.open86, $.open87, $.open88, $.open89, $.open90, $.open91, $.open92, $.open93, $.open94, $.open95, $.open96, $.open97, $.open98, $.open99, $.open100, $.open101, $.open102, $.open103, $.open104, $.open105, $.open106, $.open107, $.open108, $.open109, $.open110, $.open111, $.open112, $.open113, $.open114, $.open115, $.open116, $.open117, $.open118, $.open119, $.open120, $.open121, $.open122, $.open123, $.open124, $.open125, $.open126, $.open127, $.open128, $.open129, $.open130, $.open131, $.open132, $.open133, $.open134, $.open135, $.open136, $.open137, $.open138, $.open139, $.open140, $.open141, $.open142, $.open143, $.open144, $.open145, $.open146, $.open147, $.open148, $.open149, $.open150, $.open151, $.open152, $.open153, $.open154, $.open155, $.open156, $.open157, $.open158, $.open159, $.open160, $.open161, $.open162, $.open163, $.open164, $.open165, $.open166, $.open167, $.open168, $.open169, $.open170, $.open171, $.open172, $.open173, $.open174, $.open175, $.open176, $.open177, $.open178, $.open179, $.open180, $.open181, $.open182, $.open183, $.open184, $.open185, $.open186, $.open187, $.open188, $.open189, $.open190, $.open191, $.open192, $.open193, $.open194, $.open195, $.open196, $.open197, $.open198, $.open199, $.open200, $.open201, $.open202, $.open203, $.open204, $.open205, $.open206, $.open207, $.open208, $.open209, $.open210, $.open211, $.open212, $.open213, $.open214, $.open215, $.open216, $.open217, $.open218, $.open219, $.open220, $.open221, $.open222, $.open223, $.open224, $.open225, $.open226, $.open227, $.open228, $.open229, $.open230, $.open231, $.open232, $.open233, $.open234, $.open235, $.open236, $.open237, $.open238, $.open239, $.open240, $.open241, $.open242, $.open243, $.open244, $.open245, $.open246, $.open247, $.open248, $.open249, $.open250, $.open251, $.open252, $.open253, $.open254, $.open255, );

    has int32 $.transparent;
	has OpaquePointer $.polyInts;
	has int32 $.polyAllocated;
	has gdImageStruct $.brush;
	has gdImageStruct $.tile;
has int32 ($.brushColorMap, $.bcm1, $.bcm2, $.bcm3, $.bcm4, $.bcm5, $.bcm6, $.bcm7, $.bcm8, $.bcm9, $.bcm10, $.bcm11, $.bcm12, $.bcm13, $.bcm14, $.bcm15, $.bcm16, $.bcm17, $.bcm18, $.bcm19, $.bcm20, $.bcm21, $.bcm22, $.bcm23, $.bcm24, $.bcm25, $.bcm26, $.bcm27, $.bcm28, $.bcm29, $.bcm30, $.bcm31, $.bcm32, $.bcm33, $.bcm34, $.bcm35, $.bcm36, $.bcm37, $.bcm38, $.bcm39, $.bcm40, $.bcm41, $.bcm42, $.bcm43, $.bcm44, $.bcm45, $.bcm46, $.bcm47, $.bcm48, $.bcm49, $.bcm50, $.bcm51, $.bcm52, $.bcm53, $.bcm54, $.bcm55, $.bcm56, $.bcm57, $.bcm58, $.bcm59, $.bcm60, $.bcm61, $.bcm62, $.bcm63, $.bcm64, $.bcm65, $.bcm66, $.bcm67, $.bcm68, $.bcm69, $.bcm70, $.bcm71, $.bcm72, $.bcm73, $.bcm74, $.bcm75, $.bcm76, $.bcm77, $.bcm78, $.bcm79, $.bcm80, $.bcm81, $.bcm82, $.bcm83, $.bcm84, $.bcm85, $.bcm86, $.bcm87, $.bcm88, $.bcm89, $.bcm90, $.bcm91, $.bcm92, $.bcm93, $.bcm94, $.bcm95, $.bcm96, $.bcm97, $.bcm98, $.bcm99, $.bcm100, $.bcm101, $.bcm102, $.bcm103, $.bcm104, $.bcm105, $.bcm106, $.bcm107, $.bcm108, $.bcm109, $.bcm110, $.bcm111, $.bcm112, $.bcm113, $.bcm114, $.bcm115, $.bcm116, $.bcm117, $.bcm118, $.bcm119, $.bcm120, $.bcm121, $.bcm122, $.bcm123, $.bcm124, $.bcm125, $.bcm126, $.bcm127, $.bcm128, $.bcm129, $.bcm130, $.bcm131, $.bcm132, $.bcm133, $.bcm134, $.bcm135, $.bcm136, $.bcm137, $.bcm138, $.bcm139, $.bcm140, $.bcm141, $.bcm142, $.bcm143, $.bcm144, $.bcm145, $.bcm146, $.bcm147, $.bcm148, $.bcm149, $.bcm150, $.bcm151, $.bcm152, $.bcm153, $.bcm154, $.bcm155, $.bcm156, $.bcm157, $.bcm158, $.bcm159, $.bcm160, $.bcm161, $.bcm162, $.bcm163, $.bcm164, $.bcm165, $.bcm166, $.bcm167, $.bcm168, $.bcm169, $.bcm170, $.bcm171, $.bcm172, $.bcm173, $.bcm174, $.bcm175, $.bcm176, $.bcm177, $.bcm178, $.bcm179, $.bcm180, $.bcm181, $.bcm182, $.bcm183, $.bcm184, $.bcm185, $.bcm186, $.bcm187, $.bcm188, $.bcm189, $.bcm190, $.bcm191, $.bcm192, $.bcm193, $.bcm194, $.bcm195, $.bcm196, $.bcm197, $.bcm198, $.bcm199, $.bcm200, $.bcm201, $.bcm202, $.bcm203, $.bcm204, $.bcm205, $.bcm206, $.bcm207, $.bcm208, $.bcm209, $.bcm210, $.bcm211, $.bcm212, $.bcm213, $.bcm214, $.bcm215, $.bcm216, $.bcm217, $.bcm218, $.bcm219, $.bcm220, $.bcm221, $.bcm222, $.bcm223, $.bcm224, $.bcm225, $.bcm226, $.bcm227, $.bcm228, $.bcm229, $.bcm230, $.bcm231, $.bcm232, $.bcm233, $.bcm234, $.bcm235, $.bcm236, $.bcm237, $.bcm238, $.bcm239, $.bcm240, $.bcm241, $.bcm242, $.bcm243, $.bcm244, $.bcm245, $.bcm246, $.bcm247, $.bcm248, $.bcm249, $.bcm250, $.bcm251, $.bcm252, $.bcm253, $.bcm254, $.bcm255, );
has int32 ($.tileColorMap, $.tcm1, $.tcm2, $.tcm3, $.tcm4, $.tcm5, $.tcm6, $.tcm7, $.tcm8, $.tcm9, $.tcm10, $.tcm11, $.tcm12, $.tcm13, $.tcm14, $.tcm15, $.tcm16, $.tcm17, $.tcm18, $.tcm19, $.tcm20, $.tcm21, $.tcm22, $.tcm23, $.tcm24, $.tcm25, $.tcm26, $.tcm27, $.tcm28, $.tcm29, $.tcm30, $.tcm31, $.tcm32, $.tcm33, $.tcm34, $.tcm35, $.tcm36, $.tcm37, $.tcm38, $.tcm39, $.tcm40, $.tcm41, $.tcm42, $.tcm43, $.tcm44, $.tcm45, $.tcm46, $.tcm47, $.tcm48, $.tcm49, $.tcm50, $.tcm51, $.tcm52, $.tcm53, $.tcm54, $.tcm55, $.tcm56, $.tcm57, $.tcm58, $.tcm59, $.tcm60, $.tcm61, $.tcm62, $.tcm63, $.tcm64, $.tcm65, $.tcm66, $.tcm67, $.tcm68, $.tcm69, $.tcm70, $.tcm71, $.tcm72, $.tcm73, $.tcm74, $.tcm75, $.tcm76, $.tcm77, $.tcm78, $.tcm79, $.tcm80, $.tcm81, $.tcm82, $.tcm83, $.tcm84, $.tcm85, $.tcm86, $.tcm87, $.tcm88, $.tcm89, $.tcm90, $.tcm91, $.tcm92, $.tcm93, $.tcm94, $.tcm95, $.tcm96, $.tcm97, $.tcm98, $.tcm99, $.tcm100, $.tcm101, $.tcm102, $.tcm103, $.tcm104, $.tcm105, $.tcm106, $.tcm107, $.tcm108, $.tcm109, $.tcm110, $.tcm111, $.tcm112, $.tcm113, $.tcm114, $.tcm115, $.tcm116, $.tcm117, $.tcm118, $.tcm119, $.tcm120, $.tcm121, $.tcm122, $.tcm123, $.tcm124, $.tcm125, $.tcm126, $.tcm127, $.tcm128, $.tcm129, $.tcm130, $.tcm131, $.tcm132, $.tcm133, $.tcm134, $.tcm135, $.tcm136, $.tcm137, $.tcm138, $.tcm139, $.tcm140, $.tcm141, $.tcm142, $.tcm143, $.tcm144, $.tcm145, $.tcm146, $.tcm147, $.tcm148, $.tcm149, $.tcm150, $.tcm151, $.tcm152, $.tcm153, $.tcm154, $.tcm155, $.tcm156, $.tcm157, $.tcm158, $.tcm159, $.tcm160, $.tcm161, $.tcm162, $.tcm163, $.tcm164, $.tcm165, $.tcm166, $.tcm167, $.tcm168, $.tcm169, $.tcm170, $.tcm171, $.tcm172, $.tcm173, $.tcm174, $.tcm175, $.tcm176, $.tcm177, $.tcm178, $.tcm179, $.tcm180, $.tcm181, $.tcm182, $.tcm183, $.tcm184, $.tcm185, $.tcm186, $.tcm187, $.tcm188, $.tcm189, $.tcm190, $.tcm191, $.tcm192, $.tcm193, $.tcm194, $.tcm195, $.tcm196, $.tcm197, $.tcm198, $.tcm199, $.tcm200, $.tcm201, $.tcm202, $.tcm203, $.tcm204, $.tcm205, $.tcm206, $.tcm207, $.tcm208, $.tcm209, $.tcm210, $.tcm211, $.tcm212, $.tcm213, $.tcm214, $.tcm215, $.tcm216, $.tcm217, $.tcm218, $.tcm219, $.tcm220, $.tcm221, $.tcm222, $.tcm223, $.tcm224, $.tcm225, $.tcm226, $.tcm227, $.tcm228, $.tcm229, $.tcm230, $.tcm231, $.tcm232, $.tcm233, $.tcm234, $.tcm235, $.tcm236, $.tcm237, $.tcm238, $.tcm239, $.tcm240, $.tcm241, $.tcm242, $.tcm243, $.tcm244, $.tcm245, $.tcm246, $.tcm247, $.tcm248, $.tcm249, $.tcm250, $.tcm251, $.tcm252, $.tcm253, $.tcm254, $.tcm255, );

	has int32 $.styleLength;
	has int32 $.stylePos;
	has OpaquePointer $.style;
	has int32 $.interlace;
	has int32 $.thick;
has int32 ($.alpha0, $.alpha1, $.alpha2, $.alpha3, $.alpha4, $.alpha5, $.alpha6, $.alpha7, $.alpha8, $.alpha9, $.alpha10, $.alpha11, $.alpha12, $.alpha13, $.alpha14, $.alpha15, $.alpha16, $.alpha17, $.alpha18, $.alpha19, $.alpha20, $.alpha21, $.alpha22, $.alpha23, $.alpha24, $.alpha25, $.alpha26, $.alpha27, $.alpha28, $.alpha29, $.alpha30, $.alpha31, $.alpha32, $.alpha33, $.alpha34, $.alpha35, $.alpha36, $.alpha37, $.alpha38, $.alpha39, $.alpha40, $.alpha41, $.alpha42, $.alpha43, $.alpha44, $.alpha45, $.alpha46, $.alpha47, $.alpha48, $.alpha49, $.alpha50, $.alpha51, $.alpha52, $.alpha53, $.alpha54, $.alpha55, $.alpha56, $.alpha57, $.alpha58, $.alpha59, $.alpha60, $.alpha61, $.alpha62, $.alpha63, $.alpha64, $.alpha65, $.alpha66, $.alpha67, $.alpha68, $.alpha69, $.alpha70, $.alpha71, $.alpha72, $.alpha73, $.alpha74, $.alpha75, $.alpha76, $.alpha77, $.alpha78, $.alpha79, $.alpha80, $.alpha81, $.alpha82, $.alpha83, $.alpha84, $.alpha85, $.alpha86, $.alpha87, $.alpha88, $.alpha89, $.alpha90, $.alpha91, $.alpha92, $.alpha93, $.alpha94, $.alpha95, $.alpha96, $.alpha97, $.alpha98, $.alpha99, $.alpha100, $.alpha101, $.alpha102, $.alpha103, $.alpha104, $.alpha105, $.alpha106, $.alpha107, $.alpha108, $.alpha109, $.alpha110, $.alpha111, $.alpha112, $.alpha113, $.alpha114, $.alpha115, $.alpha116, $.alpha117, $.alpha118, $.alpha119, $.alpha120, $.alpha121, $.alpha122, $.alpha123, $.alpha124, $.alpha125, $.alpha126, $.alpha127, $.alpha128, $.alpha129, $.alpha130, $.alpha131, $.alpha132, $.alpha133, $.alpha134, $.alpha135, $.alpha136, $.alpha137, $.alpha138, $.alpha139, $.alpha140, $.alpha141, $.alpha142, $.alpha143, $.alpha144, $.alpha145, $.alpha146, $.alpha147, $.alpha148, $.alpha149, $.alpha150, $.alpha151, $.alpha152, $.alpha153, $.alpha154, $.alpha155, $.alpha156, $.alpha157, $.alpha158, $.alpha159, $.alpha160, $.alpha161, $.alpha162, $.alpha163, $.alpha164, $.alpha165, $.alpha166, $.alpha167, $.alpha168, $.alpha169, $.alpha170, $.alpha171, $.alpha172, $.alpha173, $.alpha174, $.alpha175, $.alpha176, $.alpha177, $.alpha178, $.alpha179, $.alpha180, $.alpha181, $.alpha182, $.alpha183, $.alpha184, $.alpha185, $.alpha186, $.alpha187, $.alpha188, $.alpha189, $.alpha190, $.alpha191, $.alpha192, $.alpha193, $.alpha194, $.alpha195, $.alpha196, $.alpha197, $.alpha198, $.alpha199, $.alpha200, $.alpha201, $.alpha202, $.alpha203, $.alpha204, $.alpha205, $.alpha206, $.alpha207, $.alpha208, $.alpha209, $.alpha210, $.alpha211, $.alpha212, $.alpha213, $.alpha214, $.alpha215, $.alpha216, $.alpha217, $.alpha218, $.alpha219, $.alpha220, $.alpha221, $.alpha222, $.alpha223, $.alpha224, $.alpha225, $.alpha226, $.alpha227, $.alpha228, $.alpha229, $.alpha230, $.alpha231, $.alpha232, $.alpha233, $.alpha234, $.alpha235, $.alpha236, $.alpha237, $.alpha238, $.alpha239, $.alpha240, $.alpha241, $.alpha242, $.alpha243, $.alpha244, $.alpha245, $.alpha246, $.alpha247, $.alpha248, $.alpha249, $.alpha250, $.alpha251, $.alpha252, $.alpha253, $.alpha254, $.alpha255, );

	has int32 $.trueColor;
	has OpaquePointer $.tpixels;
	has int32 $.alphaBlendingFlag;
    has int32 $.saveAlphaFlag;
	has int32 $.AA;
	has int32 $.AA_color;
	has int32 $.AA_dont_blend;

	has int32 $.cx1;
	has int32 $.cy1;
	has int32 $.cx2;
	has int32 $.cy2;

	has uint32 $.res_x;
	has uint32 $.res_y;

	has int32 $.paletteQuantizationMethod;
	has int32 $.paletteQuantizationSpeed;
	has int32 $.paletteQuantizationMinQuality;
	has int32 $.paletteQuantizationMaxQuality;
	has int32 $.interpolation_id;
}
class gdImagePtr is repr('CStruct') is gdImageStruct { }

constant gdAntiAliased is export = -7;

sub gdImageSX($img) is export {
    return $img.sx;
}

sub gdImageSY($img) is export {
    return $img.sy;
}

sub gdImageColorsTotal($im) { $im.colorsTotal }
sub gdImageRed($im, Int $c) is export {
    $im.trueColor ?? gdTrueColorGetRed($c) !! EVAL "\$im.red$c"
}
sub gdImageGreen($im, Int $c) is export {
    $im.trueColor ?? gdTrueColorGetGreen($c) !! EVAL "\$im.green$c"
}
sub gdImageBlue($im, Int $c) is export {
    $im.trueColor ?? gdTrueColorGetBlue($c) !! EVAL "\$im.blue$c"
}
sub gdImageAlpha($im, Int $c) is export {
    $im.trueColor ?? gdTrueColorGetAlpha($c) !! EVAL "\$im.alpha$c"
}

sub fopen( Str $filename, Str $mode )
    returns OpaquePointer
    is native(LIB) is export { ... }

sub fclose(OpaquePointer)
    is native(LIB) is export { ... }

sub gdImageCreateFromJpeg(OpaquePointer $file)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreateFromPng(OpaquePointer $file)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreateFromGif(OpaquePointer $file)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreateFromBmp(OpaquePointer $file)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreateTrueColor(int32, int32)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreate(int32, int32)
    returns gdImagePtr
    is native(LIB) is export { ... }

sub gdImageCreatePalette($x, $y) is export { gdImageCreate($x, $y) }

sub gdFree(OpaquePointer $m)
    # returns void
    is native(LIB) is export { * }

sub gdImageJpeg(gdImageStruct $image, OpaquePointer $file, Int $quality where { $_ <= 95 })
    is native(LIB) is export { ... }

sub gdImagePng(gdImageStruct $image, OpaquePointer $file)
    is native(LIB) is export { ... }

sub gdImageGif(gdImageStruct $im, OpaquePointer $f)
    is native(LIB) is export { ... }

sub gdImageBmp(gdImageStruct $im, OpaquePointer $f, int32)
    is native(LIB) is export { ... }

sub gdImageArc (gdImagePtr $im, int32 $cx, int32 $cy, int32 $w, int32 $h,
    int32 $s, int32 $e, int32 $color) is export
    # returns void
    is native(LIB) is export { * }

sub gdImageFilledEllipse (gdImagePtr $im, int32 $cx, int32 $cy, int32 $w, int32 $h,
                                        int32 $color)
    # returns void
    is native(LIB) is export { * }

sub gdImageCopyResized(gdImageStruct $dst, gdImageStruct $src,
        int32 $dstX, int32 $dstY,
        int32 $srcX, int32 $srcY,
        int32 $dstW, int32 $dstH, int32 $srcW, int32 $srcH)
    is native(LIB) is export { ... }

sub gdImageCopyResampled(gdImageStruct $dst, gdImageStruct $src,
    Int $dstX, Int $dstY, Int $srcX, Int $srcY, Int $dstW, Int $dstH, Int $srcW, Int $srcH)
    is native(LIB) is export { ... }

sub gdImageSetAntiAliased (gdImagePtr $im, int32 $c) is export
    #returns void
    is native(LIB) is export { * }

enum gdPixelateMode (
	GD_PIXELATE_UPPERLEFT => 0,
	GD_PIXELATE_AVERAGE => 1
);

sub gdImagePixelate(gdImagePtr $im, int32 $block_size, uint32 $mode)
    returns int32
    is native(LIB) is export { * }

sub gdImageSetThickness(gdImagePtr $im, int32 $thickness)
    #returns void
    is native(LIB) is export { * }

sub gdImageDestroy(gdImageStruct)
    is native(LIB) is export { ... }

sub gdImageGetTrueColorPixel(gdImagePtr $im, int32 $x, int32 $y)
    returns int
    is native(LIB) is export { * }

sub gdImageSetPixel(gdImagePtr $im, int32 $x, int32 $y, int32 $color)
    # returns void
    is native(LIB) is export { * }

sub gdImageGetPixel(gdImagePtr $im, int32 $x, int32 $y)
    returns int32
    is native(LIB) is export { * }

sub gdImageLine (gdImagePtr $im, int32 $x1, int32 $y1, int32 $x2, int32 $y2, int32 $color) is export
    #returns void
    is native(LIB) is export { * }


sub gdTrueColorAlpha($r, $g, $b, $a) is export {
    ((($a) +< 24) +
	 (($r) +< 16) +
	 (($g) +< 8) +
	 ($b));
}

sub gdImageColorAllocate(gdImagePtr $im, int32 $r, int32 $g, int32 $b)
    returns int32
    is native(LIB) is export { * }

sub gdImageFilledRectangle(gdImagePtr $im, int32 $x1, int32 $y1, int32 $x2, int32 $y2, int $color)
    #returns void
    is native(LIB) is export { * }

class gdPoint is repr('CStruct') is export {
    has int32 $.x is rw = 0;
    has int32 $.y is rw = 0;
}

class gdPointPtr is repr('CStruct') is gdPoint { }

## Re-implement gdImagePolygon until NativeCall has a way
## to pass array of gdPointPtr
sub gdImagePolygon(gdImagePtr $im, @p, int32 $n, int32 $c) is export
{
	return if $n <= 0;

	gdImageLine($im, @p[0].x, @p[0].y, @p[$n - 1].x, @p[$n - 1].y, $c);
	gdImageOpenPolygon($im, @p, $n, $c);
}

sub gdImageOpenPolygon(gdImagePtr $im, @p, int32 $n, int32 $c) is export
{
	return if $n <= 0;

	my $lx = @p[0].x;
	my $ly = @p[0].y;
    for 1..($n-1) -> $i {
        my ($x, $y) = (@p[$i].x, @p[$i].y);
        gdImageLine($im, $lx, $ly, $x, $y, $c);
        ($lx, $ly) = ($x, $y);
    }
}

## Re-implementation - until there is a way to properly pass gdPointPtr array with NativeCall.
##
## This re-implementation has some hacks. Some sanity checks are removed. It does
## not allocate and modify im.polyInts as it does in the original implementation.
##
## It does however pass the unittests from libgd, so I guess it's OK-ish
sub gdImageFilledPolygon($im is rw, @p, int32 $n, int32 $c) is export {

    return if $n <= 0;

    my $fill_color = $c == gdAntiAliased ?? $im.AA_color !! $c;

    sub gdMalloc($size) {
        sub malloc(uint32) returns OpaquePointer is native(LIB) { * }
        return malloc($size);
    }

    sub gdRealloc($ptr, uint32 $size)
    {
        sub realloc(OpaquePointer $ptr, uint32 $size)
            returns OpaquePointer is native(LIB) { * }

        return realloc($ptr, $size);
    }

    sub gdReallocEx ($ptr, $size)
    {
        my $newPtr = gdRealloc($ptr, $size);
        gdFree $ptr if (!$newPtr && $ptr);
        return $newPtr;
    }

    my $sizeofint = 32;

	if (!$im.polyAllocated) {
        #$im.polyInts = gdMalloc($sizeofint * $n);
        #if (!$im.polyInts) {
		#	return;
		#}
        #$im.polyAllocated = $n;
	}
	if ($im.polyAllocated < $n) {
        #while ($im.polyAllocated < $n) {
		#	$im.polyAllocated *= 2;
		#}
		#$im.polyInts = gdReallocEx($im.polyInts, $sizeofint * $im.polyAllocated);
		#return unless $im.polyInts;
	}
	my $miny = @p[0].y;
	my $maxy = @p[0].y;
	loop (my $i = 1; ($i < $n); $i++) {
		if (@p[$i].y < $miny) {
			$miny = @p[$i].y;
		}
		if (@p[$i].y > $maxy) {
			$maxy = @p[$i].y;
		}
	}
	my $pmaxy = $maxy;
    # 2.0.16: Optimization by Ilia Chipitsine -- don't waste time offscreen */
    # 2.0.26: clipping rectangle is even better
	if ($miny < $im.cy1) {
		$miny = $im.cy1;
	}
	if ($maxy > $im.cy2) {
		$maxy = $im.cy2;
	}
    # Fix in 1.3: count a vertex only once
	loop (my $y = $miny; ($y <= $maxy); $y++) {
		my $ints = 0;
        my @polyInts; # HACK
		loop (my $i = 0; ($i < $n); $i++) {
            my ($x1, $x2);
            my $ind1 = $i ?? $i - 1 !! $n - 1;
            my $ind2 = $i ?? $i !! 0;
			my $y1 = @p[$ind1].y;
			my $y2 = @p[$ind2].y;
			if ($y1 < $y2) {
				$x1 = @p[$ind1].x;
				$x2 = @p[$ind2].x;
			}
            elsif ($y1 > $y2) {
				$y2 = @p[$ind1].y;
				$y1 = @p[$ind2].y;
				$x2 = @p[$ind1].x;
				$x1 = @p[$ind2].x;
			} else {
				next;
			}

            # Do the following math as float intermediately, and round to ensure
            # that Polygon and FilledPolygon for the same set of points have the
            # same footprint.

			if (($y >= $y1) && ($y < $y2)) {
				@polyInts[$ints++] = floor ( (($y - $y1) * ($x2 - $x1)) /
				                               ($y2 - $y1) + 0.5 + $x1);
			} elsif (($y == $pmaxy) && ($y == $y2)) {
				@polyInts[$ints++] = $x2;
			}
		}

        #  2.0.26: polygons pretty much always have less than 100 points,
		#  and most of the time they have considerably less. For such trivial
		#  cases, insertion sort is a good choice. Also a good choice for
		#  future implementations that may wish to indirect through a table.
		loop ($i = 1; ($i < $ints); $i++) {
			my $index = @polyInts[$i];
			my $j = $i;
			while (($j > 0) && (@polyInts[$j - 1] > $index)) {
				@polyInts[$j] = @polyInts[$j - 1];
				$j--;
			}
			@polyInts[$j] = $index;
		}
		loop ($i = 0; ($i < ($ints - 1)); $i += 2) {
            # 2.0.29: back to gdImageLine to prevent segfaults when
            #performing a pattern fill
            gdImageLine($im, @polyInts[$i], $y, @polyInts[$i + 1], $y,
            $fill_color);
		}
	}
    # If we are drawing this AA, then redraw the border with AA lines.
    # This doesn't work as well as I'd like, but it doesn't clash either.
	if ($c == gdAntiAliased) {
		gdImagePolygon($im, @p, $n, $c);
	}
}


sub gdImageColorExactAlpha(gdImagePtr $im, int32 $r, int32 $g, int32 $b, int32 $a)
    returns int32
    is native(LIB) is export { * }

sub gdImageColorResolve(gdImagePtr $im, int32 $r, int32 $g, int32 $b)
    returns int32
    is native(LIB) is export { * }

# Based on gdImageColorExactAlpha and gdImageColorClosestAlpha
sub gdImageColorResolveAlpha(gdImagePtr $im, int32 $r, int32 $g, int32 $b, int32 $a)
    returns int32
    is native(LIB) is export { * }

sub gdImageSetInterpolationMethod(gdImagePtr $im, int32 $id) #gdInterpolationMethod $id)
    returns int32
    is native(LIB) is export { * }

# Segfaults with GD 2.1 (for me). Works with 2.2
sub gdImageScale(gdImagePtr $src, uint32 $new_width, uint32 $new_height)
    returns gdImagePtr
    is native(LIB) is export { * }

sub gdImageRotateInterpolated(gdImagePtr $src, num32 $angle, int32 $bgcolor)
    returns gdImagePtr
    is native(LIB) is export { * }


# Need GD 2.2 for these.
sub gdMajorVersion()
    returns int
    is native(LIB) is export { * }

sub gdMinorVersion()
    returns int
    is native(LIB) is export { * }

sub gdReleaseVersion()
    returns int
    is native(LIB) is export { * }
sub gdExtraVersion(void)
    returns Str
    is native(LIB) is export { * }

sub gdVersionString()
    returns int
    is native(LIB) is export { * }

sub gdImageCopyGaussianBlurred(gdImagePtr $src, int32 $radius, num64 $sigma)
    returns gdImagePtr
    is native(LIB) is export { * }

=begin pod

=head1 NAME

GD::Raw - Low level language bindings to GD Graphics Library

=head1 SYNOPSIS

    use GD::Raw;

    my $fh = fopen("my-image.png", "rb");
    my $img = gdImageCreateFromPng($fh);

    say "Image resolution is ", gdImageSX($img), "x", gdImageSX($img);

    gdImageDestroy($img);

=head1 DESCRIPTION

C<GD::Raw> is a low level language bindings to LibGD. It does not attempt to
provide you with an perlish interface, but tries to stay as close to it's C
origin as possible.

LibGD is large and this module far from covers it all. Feel free to add anything
your missing and submit a pull request!

=end pod
