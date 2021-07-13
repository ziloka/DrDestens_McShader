

//////////////////////////////////////////////////////
//              BLUR KERNELS
//////////////////////////////////////////////////////


const vec2 circle_blur_polar_4[4] = vec2[4](
    vec2(0.3535533905932738, 0),
    vec2(0.6123724356957945, 2.399963229728653),
    vec2(0.7905694150420949, 4.799926459457306),
    vec2(0.9354143466934853, 7.199889689185959)
);

const vec2 circle_blur_polar_8[8] = vec2[8](
    vec2(0.25, 0),
    vec2(0.43301270189221924, 2.399963229728653),
    vec2(0.5590169943749475, 4.799926459457306),
    vec2(0.6614378277661476, 7.199889689185959),
    vec2(0.7499999999999999, 9.599852918914612),
    vec2(0.82915619758885, 11.999816148643266),
    vec2(0.9013878188659972, 14.399779378371917),
    vec2(0.9682458365518541, 16.799742608100573)
);

const vec2 circle_blur_polar_16[16] = vec2[16](
    vec2(0.1767766952966369, 0),
    vec2(0.30618621784789724, 2.399963229728653),
    vec2(0.39528470752104744, 4.799926459457306),
    vec2(0.46770717334674267, 7.199889689185959),
    vec2(0.5303300858899106, 9.599852918914612),
    vec2(0.5863019699779287, 11.999816148643266),
    vec2(0.6373774391990981, 14.399779378371917),
    vec2(0.6846531968814576, 16.799742608100573),
    vec2(0.7288689868556626, 19.199705837829224),
    vec2(0.770551750371122, 21.599669067557876),
    vec2(0.8100925873009825, 23.99963229728653),
    vec2(0.8477912478906585, 26.399595527015183),
    vec2(0.8838834764831844, 28.799558756743835),
    vec2(0.9185586535436918, 31.19952198647249),
    vec2(0.9519716382329886, 33.599485216201145),
    vec2(0.9842509842514764, 35.999448445929794)
);

const vec2 circle_blur_polar_32[32] = vec2[32](
    vec2(0.125, 0),
    vec2(0.21650635094610962, 2.399963229728653),
    vec2(0.2795084971874737, 4.799926459457306),
    vec2(0.3307189138830738, 7.199889689185959),
    vec2(0.37499999999999994, 9.599852918914612),
    vec2(0.414578098794425, 11.999816148643266),
    vec2(0.4506939094329986, 14.399779378371917),
    vec2(0.48412291827592707, 16.799742608100573),
    vec2(0.5153882032022076, 19.199705837829224),
    vec2(0.5448623679425841, 21.599669067557876),
    vec2(0.57282196186948, 23.99963229728653),
    vec2(0.5994789404140899, 26.399595527015183),
    vec2(0.625, 28.799558756743835),
    vec2(0.649519052838329, 31.19952198647249),
    vec2(0.673145600891813, 33.599485216201145),
    vec2(0.6959705453537527, 35.999448445929794),
    vec2(0.7180703308172536, 38.39941167565845),
    vec2(0.739509972887452, 40.799374905387104),
    vec2(0.7603453162872774, 43.19933813511575),
    vec2(0.7806247497997998, 45.59930136484441),
    vec2(0.8003905296791061, 47.99926459457306),
    vec2(0.81967981553775, 50.39922782430171),
    vec2(0.8385254915624211, 52.799191054030366),
    vec2(0.8569568250501305, 55.19915428375902),
    vec2(0.8749999999999999, 57.59911751348767),
    vec2(0.8926785535678562, 59.999080743216325),
    vec2(0.9100137361600648, 62.39904397294498),
    vec2(0.9270248108869578, 64.79900720267364),
    vec2(0.9437293044088436, 67.19897043240229),
    vec2(0.960143218483576, 69.59893366213093),
    vec2(0.9762812094883317, 71.99889689185959),
    vec2(0.9921567416492214, 74.39886012158824)
);

const vec2 circle_blur_polar_64[64] = vec2[64](
    vec2(0.08838834764831845, 0),
    vec2(0.15309310892394862, 2.399963229728653),
    vec2(0.19764235376052372, 4.799926459457306),
    vec2(0.23385358667337133, 7.199889689185959),
    vec2(0.2651650429449553, 9.599852918914612),
    vec2(0.29315098498896436, 11.999816148643266),
    vec2(0.31868871959954903, 14.399779378371917),
    vec2(0.3423265984407288, 16.799742608100573),
    vec2(0.3644344934278313, 19.199705837829224),
    vec2(0.385275875185561, 21.599669067557876),
    vec2(0.4050462936504913, 23.99963229728653),
    vec2(0.42389562394532926, 26.399595527015183),
    vec2(0.4419417382415922, 28.799558756743835),
    vec2(0.4592793267718459, 31.19952198647249),
    vec2(0.4759858191164943, 33.599485216201145),
    vec2(0.4921254921257382, 35.999448445929794),
    vec2(0.5077524002897476, 38.39941167565845),
    vec2(0.5229125165837972, 40.799374905387104),
    vec2(0.5376453291901642, 43.19933813511575),
    vec2(0.5519850541454905, 45.59930136484441),
    vec2(0.5659615711335886, 47.99926459457306),
    vec2(0.5796011559684815, 50.39922782430171),
    vec2(0.5929270612815711, 52.799191054030366),
    vec2(0.6059599821770412, 55.19915428375902),
    vec2(0.6187184335382291, 57.59911751348767),
    vec2(0.6312190586476298, 59.999080743216325),
    vec2(0.6434768838116876, 62.39904397294498),
    vec2(0.6555055301063447, 64.79900720267364),
    vec2(0.667317390751957, 67.19897043240229),
    vec2(0.6789237807000135, 69.59893366213093),
    vec2(0.6903350635742038, 71.99889689185959),
    vec2(0.701560760020114, 74.39886012158824),
    vec2(0.7126096406869612, 76.7988233513169),
    vec2(0.7234898064243891, 79.19878658104555),
    vec2(0.7342087577794206, 81.59874981077421),
    vec2(0.7447734554883115, 83.99871304050286),
    vec2(0.7551903733496608, 86.3986762702315),
    vec2(0.7654655446197431, 88.79863949996016),
    vec2(0.7756046028744286, 91.19860272968882),
    vec2(0.7856128181235335, 93.59856595941747),
    vec2(0.795495128834866, 95.99852918914613),
    vec2(0.8052561704203204, 98.39849241887478),
    vec2(0.8149003006503311, 100.79845564860342),
    vec2(0.8244316223920575, 103.19841887833208),
    vec2(0.8338540040078959, 105.59838210806073),
    vec2(0.8431710977020026, 107.99834533778939),
    vec2(0.852386356061616, 110.39830856751804),
    vec2(0.8615030470056388, 112.7982717972467),
    vec2(0.8705242673240075, 115.19823502697534),
    vec2(0.879452954966893, 117.598198256704),
    vec2(0.8882919002219934, 119.99816148643265),
    vec2(0.8970437559004577, 122.3981247161613),
    vec2(0.9057110466368399, 124.79808794588996),
    vec2(0.9142961773954871, 127.19805117561862),
    vec2(0.9228014412645875, 129.59801440534727),
    vec2(0.9312290266094587, 131.99797763507593),
    vec2(0.9395810236483068, 134.39794086480458),
    vec2(0.9478594305064438, 136.79790409453324),
    vec2(0.9560661587986472, 139.19786732426186),
    vec2(0.9642030387838445, 141.59783055399052),
    vec2(0.9722718241315028, 143.99779378371917),
    vec2(0.9802741963348827, 146.39775701344783),
    vec2(0.9882117688026185, 148.79772024317649),
    vec2(0.9960860906568267, 151.19768347290514)
);

const vec2 circle_blur_4[4] = vec2[4](
    vec2(0.3535533905932738, 0),
    vec2(-0.451544375875096, 0.4136516367857983),
    vec2(0.06911610404911818, -0.7875423570583817),
    vec2(0.5691424396454711, 0.7423455283049809)
);

const vec2 circle_blur_8[8] = vec2[8](
    vec2(0.25, 0),
    vec2(-0.31929009018792764, 0.2924958774201527),
    vec2(0.048872465862326464, -0.556876541147619),
    vec2(0.40244447853436793, 0.5249175570479621),
    vec2(-0.7385351139865715, -0.1306364627844837),
    vec2(0.6996049319421064, -0.4450313912549099),
    vec2(-0.23400415816337608, 0.870483804537597),
    vec2(-0.44627130771622225, -0.8592682467712005)
);

const vec2 circle_blur_16[16] = vec2[16](
    vec2(0.1767766952966369, 0),
    vec2(-0.225772187937548, 0.20682581839289915),
    vec2(0.03455805202455909, -0.39377117852919086),
    vec2(0.28457121982273553, 0.37117276415249045),
    vec2(-0.5222231872442845, -0.09237392870513249),
    vec2(0.4946953915278165, -0.3146847145972304),
    vec2(-0.16546592706317265, 0.6155250011016001),
    vec2(-0.31556146793512924, -0.6075944041501916),
    vec2(0.6846421615837076, 0.25003021933756037),
    vec2(-0.7122560862297537, 0.294008958415681),
    vec2(0.34335449874552143, -0.7337286202617503),
    vec2(0.2537302409112575, 0.8089319902483244),
    vec2(-0.7647458919689066, -0.4431858760347418),
    vec2(0.897133983572641, -0.19723238962980807),
    vec2(-0.5475069048541611, 0.7787722318733614),
    vec2(-0.12648677292149527, -0.9760896968393356)
);

const vec2 circle_blur_32[32] = vec2[32](
    vec2(0.125, 0),
    vec2(-0.15964504509396382, 0.14624793871007635),
    vec2(0.024436232931163232, -0.2784382705738095),
    vec2(0.20122223926718397, 0.26245877852398103),
    vec2(-0.36926755699328573, -0.06531823139224185),
    vec2(0.3498024659710532, -0.22251569562745496),
    vec2(-0.11700207908168804, 0.4352419022687985),
    vec2(-0.22313565385811113, -0.42963412338560025),
    vec2(0.48411511514205563, 0.17679806359514877),
    vec2(-0.5036411085144491, 0.20789572822532165),
    vec2(0.2427882944138661, -0.5188244829377329),
    vec2(0.17941437394044654, 0.5720012958233203),
    vec2(-0.5407570060957687, -0.31337973827026655),
    vec2(0.6343695234171152, -0.13946436017686456),
    vec2(-0.38714584516883516, 0.5506751261574362),
    vec2(-0.08943965486319227, -0.6901996436814155),
    vec2(0.5490717571262015, 0.46275825819356864),
    vec2(-0.7388784713095301, 0.03055494453098949),
    vec2(0.5389551252122559, -0.5363323344787647),
    vec2(-0.03605818593008708, 0.7797915152317517),
    vec2(-0.5128175319077373, -0.6145267927178252),
    vec2(0.8123595934142241, 0.10930183432987865),
    vec2(-0.6883106405074308, 0.4789086156713513),
    vec2(0.18808605734703482, -0.8360613823348426),
    vec2(0.4350332655946333, 0.75919105489071),
    vec2(-0.8504484103424857, -0.27131623863296295),
    vec2(0.8261024011261134, -0.3816802625937971),
    vec2(-0.3578882017213956, 0.8551555619117643),
    vec2(-0.31940733428433593, -0.8880337576947028),
    vec2(0.8499086353959916, 0.4466881590990781),
    vec2(-0.9440346462300179, 0.2488445030885048),
    vec2(0.536595808250202, -0.8345297709299007)
);

const vec2 circle_blur_64[64] = vec2[64](
    vec2(0.08838834764831845, 0),
    vec2(-0.112886093968774, 0.10341290919644958),
    vec2(0.017279026012279545, -0.19688558926459543),
    vec2(0.14228560991136777, 0.18558638207624523),
    vec2(-0.26111159362214226, -0.046186964352566244),
    vec2(0.24734769576390825, -0.1573423572986152),
    vec2(-0.08273296353158632, 0.30776250055080007),
    vec2(-0.15778073396756462, -0.3037972020750958),
    vec2(0.3423210807918538, 0.12501510966878018),
    vec2(-0.35612804311487684, 0.1470044792078405),
    vec2(0.17167724937276072, -0.36686431013087517),
    vec2(0.12686512045562875, 0.4044659951241622),
    vec2(-0.3823729459844533, -0.2215929380173709),
    vec2(0.4485669917863205, -0.09861619481490404),
    vec2(-0.27375345242708055, 0.3893861159366807),
    vec2(-0.06324338646074763, -0.4880448484196678),
    vec2(0.3882523628219502, 0.32721950241874764),
    vec2(-0.5224659775357187, 0.02160560847664148),
    vec2(0.3810988237928309, -0.37924423067954616),
    vec2(-0.025496987788449936, 0.5513958683321046),
    vec2(-0.3626167543233098, -0.4345360623515941),
    vec2(0.5744249772651445, 0.07728806825078578),
    vec2(-0.48670912146566037, 0.3386395297098746),
    vec2(0.13299692659673018, -0.591184672937166),
    vec2(0.3076149721436936, 0.5368291431293896),
    vec2(-0.6013578380024912, -0.19184955218339567),
    vec2(0.5841426097907643, -0.2698887019251361),
    vec2(-0.2530651743438579, 0.6046862967972011),
    vec2(-0.2258550920331724, -0.6279346919884959),
    vec2(0.6009761594775107, 0.31585622637469357),
    vec2(-0.6675333000242891, 0.17595963559487854),
    vec2(0.3794305347699942, -0.5901016601265889),
    vec2(0.12069909342891681, 0.7023134833145649),
    vec2(-0.5720078077939695, -0.44299499751434795),
    vec2(0.731701930078265, -0.06062000923574415),
    vec2(-0.5057602714083884, 0.5467120337663267),
    vec2(0.003684027952365215, -0.7551813874414849),
    vec2(0.514304945229712, 0.5669461379286951),
    vec2(-0.7722948658519765, -0.07157611458215449),
    vec2(0.6257873078318013, -0.47495025566539767),
    vec2(-0.14238056851320097, 0.782649521631399),
    vec2(-0.42888394095723925, -0.6815394817536159),
    vec2(0.785920133036245, 0.21538812522581444),
    vec2(-0.7334855212372673, 0.3764126593717251),
    vec2(0.2898616761608319, -0.7818521015468547),
    vec2(0.31791146893355565, 0.7809416098022366),
    vec2(-0.77026392317357, -0.3650424477471912),
    vec2(0.8232633014643855, -0.2538208747561163),
    vec2(-0.44015653024869994, 0.751049085532647),
    vec2(-0.1846432401149469, -0.8598513673187094),
    vec2(0.7241773560320561, 0.5144216723762915),
    vec2(-0.8901573611276761, 0.11093859756735677),
    vec2(0.5870542621401351, -0.6896954351763548),
    vec2(0.033319899649036984, 0.913688833404118),
    vec2(-0.6477269570369681, -0.6572764175958464),
    vec2(0.9300141309321251, 0.047552247755117134),
    vec2(-0.7243231135792285, 0.5984718265172488),
    vec2(0.1309753226146144, -0.9387667254786982),
    vec2(0.5422048902753999, 0.7874492726274129),
    vec2(-0.9396490219009803, -0.21621104421497742),
    vec2(0.8459367503175589, -0.47927394511090204),
    vec2(-0.3024918972101173, 0.9324356021314415),
    vec2(-0.41009709429808805, -0.8991011473957005),
    vec2(0.9169758677396763, 0.3890279655539787)
);




const float gaussian_6[6] = float[6](
    0.03125,
    0.15625,
    0.3125,
    0.3125,
    0.15625,
    0.03125
);

const float gaussian_10[10] = float[10](
    0.001953125,
    0.017578125,
    0.0703125,
    0.1640625,
    0.24609375,
    0.24609375,
    0.1640625,
    0.0703125,
    0.017578125,
    0.001953125
);

const float gaussian_16[16] = float[16](
    0.000030517578125,
    0.000457763671875,
    0.003204345703125,
    0.013885498046875,
    0.041656494140625,
    0.091644287109375,
    0.152740478515625,
    0.196380615234375,
    0.196380615234375,
    0.152740478515625,
    0.091644287109375,
    0.041656494140625,
    0.013885498046875,
    0.003204345703125,
    0.000457763671875,
    0.000030517578125
);


//////////////////////////////////////////////////////
//              SSAO KERNELS
//////////////////////////////////////////////////////

const vec3 half_sphere_8[8] = vec3[8](
    vec3(0.4841229182759271, 0, 0.875),
    vec3(-0.5756083959600474, 0.5273044419500952, 0.625),
    vec3(0.08104581592239497, -0.923475270768781, 0.375),
    vec3(0.603666717801552, 0.7873763355719433, 0.12500000000000006),
    vec3(-0.9769901230486042, -0.17281579634244423, 0.12499999999999994),
    vec3(0.7821820926083319, -0.497560221483642, 0.375),
    vec3(-0.20265354556067547, 0.7538610883124871, 0.6249999999999999),
    vec3(-0.22313565385811115, -0.42963412338560025, 0.875)
);

const vec3 half_sphere_16[16] = vec3[16](
    vec3(0.34798527267687634, 0, 0.9375),
    vec3(-0.42985743923670755, 0.3937846263287336, 0.8125),
    vec3(0.0634871954735437, -0.7234038471081724, 0.6875),
    vec3(0.50305559816796, 0.6561469463099526, 0.5625),
    vec3(-0.8854724951825381, -0.156627616578974, 0.4375),
    vec3(0.8014981392972829, -0.5098475092642832, 0.31250000000000006),
    vec3(-0.25500011945061624, 0.9485877339920497, 0.18749999999999994),
    vec3(-0.46000593484912655, -0.8857134355442402, 0.062499999999999986),
    vec3(0.9374848892962336, 0.3423679779728655, 0.062499999999999986),
    vec3(-0.9079519205901849, 0.3747893540331617, 0.18749999999999994),
    vec3(0.4026188380305669, -0.8603730709773035, 0.31249999999999994),
    vec3(0.26912156091066985, 0.8580019437349805, 0.4374999999999999),
    vec3(-0.7153542789226215, -0.41456242669481796, 0.5625000000000001),
    vec3(0.709246688607407, -0.15592589489699188, 0.6875),
    vec3(-0.33527813688580826, 0.4768986484845404, 0.8125),
    vec3(-0.04471982743159614, -0.34509982184070775, 0.9375)
);


//////////////////////////////////////////////////////
//              OTHER KERNELS
//////////////////////////////////////////////////////

// This kernel is progressive. Any sample count will return an even spread of noise
const vec2 blue_noise_disk[64] = vec2[64](
    vec2(0.478712,0.875764),
    vec2(-0.337956,-0.793959),
    vec2(-0.955259,-0.028164),
    vec2(0.864527,0.325689),
    vec2(0.209342,-0.395657),
    vec2(-0.106779,0.672585),
    vec2(0.156213,0.235113),
    vec2(-0.413644,-0.082856),
    vec2(-0.415667,0.323909),
    vec2(0.141896,-0.939980),
    vec2(0.954932,-0.182516),
    vec2(-0.766184,0.410799),
    vec2(-0.434912,-0.458845),
    vec2(0.415242,-0.078724),
    vec2(0.728335,-0.491777),
    vec2(-0.058086,-0.066401),
    vec2(0.202990,0.686837),
    vec2(-0.808362,-0.556402),
    vec2(0.507386,-0.640839),
    vec2(-0.723494,-0.229240),
    vec2(0.489740,0.317826),
    vec2(-0.622663,0.765301),
    vec2(-0.010640,0.929347),
    vec2(0.663146,0.647618),
    vec2(-0.096674,-0.413835),
    vec2(0.525945,-0.321063),
    vec2(-0.122533,0.366019),
    vec2(0.195235,-0.687983),
    vec2(-0.563203,0.098748),
    vec2(0.418563,0.561335),
    vec2(-0.378595,0.800367),
    vec2(0.826922,0.001024),
    vec2(-0.085372,-0.766651),
    vec2(-0.921920,0.183673),
    vec2(-0.590008,-0.721799),
    vec2(0.167751,-0.164393),
    vec2(0.032961,-0.562530),
    vec2(0.632900,-0.107059),
    vec2(-0.464080,0.569669),
    vec2(-0.173676,-0.958758),
    vec2(-0.242648,-0.234303),
    vec2(-0.275362,0.157163),
    vec2(0.382295,-0.795131),
    vec2(0.562955,0.115562),
    vec2(0.190586,0.470121),
    vec2(0.770764,-0.297576),
    vec2(0.237281,0.931050),
    vec2(-0.666642,-0.455871),
    vec2(-0.905649,-0.298379),
    vec2(0.339520,0.157829),
    vec2(0.701438,-0.704100),
    vec2(-0.062758,0.160346),
    vec2(-0.220674,0.957141),
    vec2(0.642692,0.432706),
    vec2(-0.773390,-0.015272),
    vec2(-0.671467,0.246880),
    vec2(0.158051,0.062859),
    vec2(0.806009,0.527232),
    vec2(-0.057620,-0.247071),
    vec2(0.333436,-0.516710),
    vec2(-0.550658,-0.315773),
    vec2(-0.652078,0.589846),
    vec2(0.008818,0.530556),
    vec2(-0.210004,0.519896) 
);

const float sobel_horizontal[9] = float[](
    -1, 0, 1,
    -2, 0, 2,
    -1, 0, 1
);

const float sobel_vertical[9] = float[](
    -1, -2, -1,
    0, 0, 0,
    1, 2, 1
);