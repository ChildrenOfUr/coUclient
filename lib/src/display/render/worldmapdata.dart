part of couclient;

// PART 1: WORLD MAP HUB POSITIONS ////////////////////////////////////////////////////////////////

final Map<String, dynamic> hubPositions = {
	"76": {
		"name": "Alakol",
		"x": 360,
		"y": 129
	},
	"89": {
		"name": "Andra",
		"x": 314,
		"y": 98
	},
	"101": {
		"name": "Aranna",
		"x": 397,
		"y": 24
	},
	"128": {
		"name": "Balzare",
		"x": 80,
		"y": 90
	},
	"86": {
		"name": "Baqala",
		"x": 355,
		"y": 78
	},
	"98": {
		"name": "Besara",
		"x": 404,
		"y": 46
	},
	"75": {
		"name": "Bortola",
		"x": 405,
		"y": 99
	},
	"112": {
		"name": "Brillah",
		"x": 497,
		"y": 74
	},
	"107": {
		"name": "Callopee",
		"x": 449,
		"y": 43
	},
	"120": {
		"name": "Cauda",
		"x": 416,
		"y": 256
	},
	"72": {
		"name": "Chakra Phool",
		"x": 200,
		"y": 240
	},
	"90": {
		"name": "Choru",
		"x": 354,
		"y": 56
	},
	"141": {
		"name": "Drifa",
		"x": 390,
		"y": -2
	},
	"123": {
		"name": "Fenneq",
		"x": 431,
		"y": 225
	},
	"114": {
		"name": "Firozi",
		"x": 375,
		"y": 156
	},
	"119": {
		"name": "Folivoria",
		"x": 258,
		"y": 63
	},
	"56": {
		"name": "Groddle Forest",
		"x": 340,
		"y": 191
	},
	"64": {
		"name": "Groddle Heights",
		"x": 310,
		"y": 171
	},
	"58": {
		"name": "Groddle Meadow",
		"x": 293,
		"y": 194
	},
	"131": {
		"name": "Haoma",
		"x": 78,
		"y": 118
	},
	"116": {
		"name": "Haraiva",
		"x": 519,
		"y": 122
	},
	"27": {
		"name": "Ix",
		"x": 122,
		"y": 53
	},
	"136": {
		"name": "Jal",
		"x": 332,
		"y": 151
	},
	"71": {
		"name": "Jethimadh",
		"x": 241,
		"y": 248
	},
	"85": {
		"name": "Kajuu",
		"x": 358,
		"y": 102
	},
	"99": {
		"name": "Kalavana",
		"x": 196,
		"y": 266
	},
	"88": {
		"name": "Karnata",
		"x": 497,
		"y": 100
	},
	"133": {
		"name": "Kloro",
		"x": 71,
		"y": 143
	},
	"105": {
		"name": "Lida",
		"x": 451,
		"y": 117
	},
	"110": {
		"name": "Massadoe",
		"x": 446,
		"y": 19
	},
	"97": {
		"name": "Muufo",
		"x": 451,
		"y": 92
	},
	"137": {
		"name": "Nottis",
		"x": 344,
		"y": 9
	},
	"102": {
		"name": "Ormonos",
		"x": 407,
		"y": 125
	},
	"106": {
		"name": "Pollokoo",
		"x": 445,
		"y": 66
	},
	"109": {
		"name": "Rasana",
		"x": 261,
		"y": 122
	},
	"126": {
		"name": "Roobrik",
		"x": 120,
		"y": 100
	},
	"93": {
		"name": "Salatu",
		"x": 313,
		"y": 121
	},
	"140": {
		"name": "Samudra",
		"x": 285,
		"y": 147
	},
	"63": {
		"name": "Shimla Mirch",
		"x": 238,
		"y": 219
	},
	"121": {
		"name": "Sura",
		"x": 461,
		"y": 256
	},
	"113": {
		"name": "Tahli",
		"x": 263,
		"y": 94
	},
	"92": {
		"name": "Tamila",
		"x": 400,
		"y": 72
	},
	"51": {
		"name": "Uralia",
		"x": 125,
		"y": 125
	},
	"100": {
		"name": "Vantalu",
		"x": 353,
		"y": 35
	},
	"95": {
		"name": "Xalanga",
		"x": 305,
		"y": 43
	},
	"91": {
		"name": "Zhambu",
		"x": 306,
		"y": 74
	}
};

// PART 2: STREET CONTENTS (USED ON HUB MAPS) /////////////////////////////////////////////////////

/*
Keys:
- "bureaucratic_hall": true
- "machine_room": true
- "mailbox": true
- "shrine": "Giant"
- "subway_station": true
- "vendor": "Vendor Type"
*/

final Map<String, Map<String, dynamic>> streetContentsData = {
	"Aava Plies": {
		"shrine": "Alph",
		"vendor": "Gardening Goods"
	},
	"Aavani Avenue": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Abesh Litcha": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Abhiman Himan": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Acta Probat": {},
	"Adanac": {
		"vendor": "Hardware",
		"shrine": "Pot"
	},
	"Adaya Park": {},
	"Addingfoot Trip": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Addysshot Croft": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Adeno Sierra": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Adspice Lacrimis": {},
	"Afar Whence": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Afra Maf": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Agala Axis": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Agarrec Bowetic": {},
	"Agraha Yana": {
		"vendor": "Alchemical Goods",
		"shrine": "Humbaba"
	},
	"Ahtria Ahcalla": {
		"shrine": "Zille",
		"vendor": "Toy"
	},
	"Aippasi Massy": {
		"vendor": "Animal Goods",
		"shrine": "Lem"
	},
	"Ajiboo Hood": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Ajiga Habitat": {},
	"Akaki Cape": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Akalet Moves": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Akas Apparata": {
		"vendor": "Gardening Goods",
		"shrine": "Pot"
	},
	"Akkawwi Wails": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Akki Blocks": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Alakol Start": {},
	"Alecha Kolo": {
		"vendor": "Mining"
	},
	"Alikos Alder": {
		"mailbox": true,
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Alpine Vista": {
		"vendor": "Hardware",
		"shrine": "Humbaba"
	},
	"Amant Kudos": {
		"shrine": "Lem",
		"vendor": "Mining"
	},
	"Ambo Aims": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Ambu Jal": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Amerran Huddles": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Humbaba"
	},
	"Amika Forca": {
		"vendor": "Produce",
		"shrine": "Cosma"
	},
	"Amlou Amoo": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Anaka Azimuth": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Ander Zen": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Angla Mangle": {
		"vendor": "Alchemical Goods",
		"shrine": "Cosma"
	},
	"Anista Mista": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Annam Angst": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Anor Sapro": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Anrasan Glance": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Anu Afzelii": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Anulis Trisc": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Apadrav Habitat": {},
	"Appam Almost": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Appin Shol": {
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Arago Thaum": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Aratikaya Kaya": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Archimedes Acres": {
		"vendor": "Animal Goods",
		"shrine": "Cosma"
	},
	"Ardent Ave 1": {},
	"Ardent Ave 2": {},
	"Ardent Ave 3": {},
	"Ardent Ave 4": {},
	"Arisa Annex": {
		"mailbox": true,
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Arisi Amble": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Arju Podi": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Arjun Plunge": {
		"shrine": "Tii",
		"vendor": "Mining"
	},
	"Arkose Gabbro": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Armillo Flaria": {},
	"Arom Runce": {
		"vendor": "Toy",
		"shrine": "Zille"
	},
	"Arupu Rupu": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Arvensis Harris": {},
	"Asubo Bolda": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Asvina Vet": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Atrove Grove": {},
	"Atsas Gaque": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Aurivella Odora": {},
	"Awagni Walk": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Awasa Wash": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Awn Terio": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Axis Denyde": {},
	"Azifa Ayib": {
		"vendor": "Mining"
	},
	"Baavai Buraq": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Baby Steppes": {},
	"Baddam Haddam": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Badvi Bist": {
		"vendor": "Toy",
		"shrine": "Lem"
	},
	"Baeli Bray": {
		"bureaucratic_hall": true,
		"shrine": "Spriggan"
	},
	"Baharat Sat": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Bailestorth Shin": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Bakean Stutter": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Mab"
	},
	"Bakti Mahar": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Balbemo Ghee": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Balcam Stacks": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Balin Bastion": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Balkao Blvd": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Balleet Berm": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Balliure Heath": {
		"vendor": "Grocery",
		"shrine": "Friendly"
	},
	"Bangala Bristles": {
		"mailbox": true,
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Bankati Bist": {
		"vendor": "Alchemical Goods"
	},
	"Banya Banya": {
		"shrine": "Cosma"
	},
	"Banya Banya ": {
		"vendor": "Hardware"
	},
	"Banyan Park": {},
	"Bar Bara": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Baram Sum": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Barrak Oak": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Barthigai Broke": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Basabasa": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Basalt Syen": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Basma Asma": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Batata Tata": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Batre Yrarg": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Bayadd Yadding": {
		"vendor": "Grocery",
		"shrine": "Alph"
	},
	"Bebingka Bridge": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Becca Guille": {
		"vendor": "Grocery",
		"shrine": "Humbaba"
	},
	"Beesfast Heave": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Belan Bends": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"BereBere Scald": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Berecroy Woods": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Berunj Mari": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Besara Community Machine Room": {},
	"Bettano Testament": {
		"shrine": "Tii"
	},
	"Bhadra Pada": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Bhuva Lamella": {},
	"Bij Arsul": {
		"vendor": "Hardware"
	},
	"Billore Crys": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Bishop's Arch": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Lem"
	},
	"Blackberry Glebe": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Blottnass": {
		"vendor": "Produce",
		"shrine": "Spriggan"
	},
	"Blue Mountain Bore": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Boan Stravenue": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Grendaline"
	},
	"Bobo Mondo": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Boda Apta": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Bokkeum Habitat": {},
	"Bolesan Ambitions": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Spriggan"
	},
	"Bon'thu Bins": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Bonebottle Sands": {
		"vendor": "Hardware",
		"shrine": "Lem"
	},
	"Bonelington Hole": {
		"vendor": "Produce",
		"shrine": "Cosma"
	},
	"Bongul Beat": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Boonbi Books": {
		"shrine": "Pot",
		"vendor": "Produce"
	},
	"Boor Bane A": {},
	"Boor Bane B": {},
	"Boor Bane C": {},
	"Boor Bane D": {},
	"Boor Bane E": {},
	"Boor Bane F": {},
	"Boorgal Broods": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Borem Summon": {
		"vendor": "Grocery",
		"shrine": "Zille"
	},
	"Bortola Start": {},
	"Bossam Preserve": {},
	"Botchi Etta": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Briarset Croft": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Bright Day": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Brilyn Chelyn": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Brinlow Vale": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Broxhurst Green": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Brunnan Bafflings": {
		"vendor": "Toy",
		"shrine": "Cosma"
	},
	"Buckward Vale": {
		"vendor": "Alchemical Goods",
		"shrine": "Mab"
	},
	"Budae Bada": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Bukovs Gossan": {
		"shrine": "Humbaba",
		"vendor": "Grocery"
	},
	"Bulaa Clacks": {
		"vendor": "Kitchen Tools",
		"shrine": "Spriggan"
	},
	"Bullic Craik": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Bumpkin Tr A": {},
	"Bumpkin Tr B": {},
	"Bumpkin Tr C": {},
	"Bumpkin Tr D": {},
	"Bumpkin Tr E": {},
	"Buna Belt": {
		"vendor": "Grocery",
		"shrine": "Mab"
	},
	"Burbere Keba": {
		"shrine": "Pot",
		"vendor": "Grocery"
	},
	"Burnabee": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Buticha Quach": {
		"vendor": "Mining"
	},
	"Byssus Park": {},
	"Calta Habitat": {},
	"Calvatia Bovista": {},
	"Camsteeple Strat": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Canary Send": {
		"machine_room": true,
		"vendor": "Toy",
		"shrine": "Lem"
	},
	"Cancrin Psam": {
		"shrine": "Pot",
		"vendor": "Grocery"
	},
	"Candy Cane Lane": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Canjeero Cambe": {
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Canjeero Crams": {
		"shrine": "Alph"
	},
	"Canjeero Crams ": {
		"vendor": "Animal Goods"
	},
	"Castan Nella": {},
	"Causa  Aurum": {},
	"Cebarkul": {
		"vendor": "Tool"
	},
	"Chakra Phool Herb Gardens": {},
	"Chalan Vaara": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Chamuc Chance": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Chamuss Knurl": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Chandrika Chimes": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Chapati Rooti": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Chari Chalks": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Charnoc Slag": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Chattra Dileera": {},
	"Chavila Checker": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Chego Chase": {
		"bureaucratic_hall": true,
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Cheiri Ami": {},
	"Chengaav Gavel": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Chermoo Lama": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Chester Way 1A": {},
	"Chester Way 1B": {},
	"Chester Way 1C": {},
	"Chester Way 1D": {},
	"Chester Way 1E": {},
	"Chettar Lings": {
		"shrine": "Pot",
		"vendor": "Grocery"
	},
	"Chettia Churns": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Chilling Light": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Chima Chore": {
		"shrine": "Pot"
	},
	"Chingam Chai": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Chiti Tiga": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Chueo Vegae": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Chuff Chase 1": {},
	"Chuff Chase 2": {},
	"Chuff Chase 3": {},
	"Chuff Chase 4": {},
	"Churni Sanctum": {
		"shrine": "Spriggan",
		"vendor": "Mining"
	},
	"Cinnabar Chibe": {},
	"Clam Calumny": {
		"vendor": "Kitchen Tools",
		"shrine": "Humbaba"
	},
	"Clamber Crag": {
		"vendor": "Hardware",
		"shrine": "Alph"
	},
	"Clarbeare Voya": {
		"vendor": "Animal Goods",
		"shrine": "Grendaline"
	},
	"Clavatus Stippe": {},
	"Climbonyne": {},
	"Coci Muttah": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Coldham Shift": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Pot"
	},
	"Coldthorp Lam": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Tii"
	},
	"Community Gardens": {
		"mailbox": true,
		"vendor": "Gardening Goods"
	},
	"Contour Rd E": {},
	"Contour Rd NE": {},
	"Contour Rd NW": {},
	"Contour Rd W": {},
	"Cornfed Crt A": {},
	"Cornfed Crt B": {},
	"Cornfed Crt C": {},
	"Cornfed Crt D": {},
	"Corniss Sember": {
		"vendor": "Mining"
	},
	"Cotton Cross": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Cranbury Coppice": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Crillic Crit": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Crispaa Esculenta": {},
	"Cryptocrin": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Curling Lake": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Curving Clusters": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Cynque Dent": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Cytron Monn": {},
	"Dalsan Detach": {
		"vendor": "Produce",
		"shrine": "Friendly"
	},
	"Dark Cavern": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Darnefree Air": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Darwin Char": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Dasha Mula": {
		"shrine": "Pot",
		"vendor": "Kitchen Tools"
	},
	"Davana Drive": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Deadpan Dike 1": {},
	"Deadpan Dike 2": {},
	"Deadpan Dike 3": {},
	"Deadpan Dike 4": {},
	"Delika Nudha": {},
	"Deodak Nabak": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Derjo Jo": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Desmona Dr": {
		"shrine": "Mab"
	},
	"Deucher Rudd": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Devi Drape": {
		"vendor": "Mining",
		"shrine": "Friendly"
	},
	"Dhab Habit": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Dhalakk Dalliance": {
		"vendor": "Mining"
	},
	"Dhanu Dhani": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Diami Quarry": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Difo Dabo": {
		"vendor": "Mining"
	},
	"Ding a Lingers": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Dingal Lin": {
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Distant Drag A": {},
	"Distant Drag B": {},
	"Distant Drag C": {},
	"Distant Drag D": {},
	"Distant Drag E": {},
	"Distant Drag F": {},
	"Djur Rhomb": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Dobak Fathom": {
		"shrine": "Lem",
		"vendor": "Mining"
	},
	"Dodol Dwells": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Dofsan Vex": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Dokk Rokk": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Dolla Holla": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Doolshe Teff": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Doon Way": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Doora Dooms": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Dorajii Nakji": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Dore Valore": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Dorji Park": {},
	"Dosaka Moda": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Drooping Drift": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Dunlin Roble": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Durva Dell": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Dusa Tanad": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Dust Path 1A": {},
	"Dust Path 1B": {},
	"Dust Path 1C": {},
	"Dust Path 1D": {},
	"Dust Path 1E": {},
	"Dust Path 1F": {},
	"Dyran Notion": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"East Spice": {},
	"Eastern Approach": {},
	"Ebijab Preserve": {},
	"Echin Gross": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Edavam Vam": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Edodes Peziza": {},
	"Eglesgown Wanks": {
		"vendor": "Produce",
		"shrine": "Tii"
	},
	"Egret Taun": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Egret Taun Towers": {},
	"Egret Taun Towers Basement": {},
	"Ekorran Roughs": {
		"vendor": "Kitchen Tools",
		"shrine": "Grendaline"
	},
	"Elia Sec": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Elios Durr": {
		"shrine": "Mab",
		"vendor": "Gardening Goods"
	},
	"Elysian Slope": {
		"vendor": "Grocery",
		"shrine": "Zille"
	},
	"Empty Via 1": {},
	"Empty Via 2": {},
	"Empty Via 3": {},
	"Empty Via 4": {},
	"Empty Via 5": {},
	"Empty Via 6": {},
	"Enjan Park": {},
	"Ensete Sets": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Eosphr Meso": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Erra Kandi": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Erupekku Rumple": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Essec Zyte": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Estevan Hummock": {
		"vendor": "Kitchen Tools",
		"shrine": "Alph"
	},
	"Estevan Meadows": {
		"vendor": "Grocery",
		"shrine": "Tii"
	},
	"Evanfell Craine": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Evi Effect": {
		"vendor": "Kitchen Tools",
		"shrine": "Mab"
	},
	"Facta Verba": {},
	"Fairgower Lane": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Fanfoot Flare": {
		"vendor": "Kitchen Tools",
		"shrine": "Cosma"
	},
	"Fasena Preserve": {},
	"Felin Pryde": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Feman Falters": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Fenykus Nivalis": {},
	"Fern End": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Ferncaster End": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Fervor Tack A": {},
	"Fervor Tack B": {},
	"Fervor Tack C": {},
	"Fervor Tack D": {},
	"Fervor Tack E": {},
	"Fervor Tack F": {},
	"Fesenjan Freeq": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Festivo Orelbo": {},
	"Finugo Fugue": {
		"shrine": "Zille"
	},
	"Firabiz Flaunts": {
		"vendor": "Grocery",
		"shrine": "Alph"
	},
	"Firdaus Finds": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Firfire Frees": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Fitadara Fry": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Fjarcke": {
		"vendor": "Grocery",
		"shrine": "Zille"
	},
	"Flammeu Pew": {},
	"Flammulina Gigantea": {},
	"Flavus Muss": {},
	"Flipside": {
		"shrine": "Friendly"
	},
	"Flogan Shames": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Fluore Vaes": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Flurry Piles": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Follybottom Stritt": {
		"mailbox": true,
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Footlands Heath": {
		"vendor": "Alchemical Goods"
	},
	"Fort Aban Don": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Fosolia Flaps": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Froughtful Fen": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Pot"
	},
	"Frysta Virki": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Fyran Descant": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Gaare Grims": {
		"shrine": "Friendly",
		"vendor": "Grocery"
	},
	"Gabouta Bouts": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Gaji Preserve": {},
	"Gambir Preserve": {},
	"Ganos Lucidum": {},
	"Garama Sala": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Garillis Fill": {
		"shrine": "Mab",
		"vendor": "Gardening Goods"
	},
	"Gashaalo Lora": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Gavad Park": {},
	"Gavvalu Gasp": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Gedeo Grails": {
		"mailbox": true,
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Geeze Bets": {
		"vendor": "Gardening Goods",
		"shrine": "Humbaba"
	},
	"Gehsho Nuff": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Gemyan Guome": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Gersal Gemony": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Getan Tenets": {
		"vendor": "Alchemical Goods",
		"shrine": "Friendly"
	},
	"Ghara Gulley": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Ghora Chani": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Gibba Gant": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Gigha Glow": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Gimbap Bop": {
		"vendor": "Animal Goods"
	},
	"Gimja Preserve": {},
	"Ginseng Grope": {
		"shrine": "Alph"
	},
	"Glarus Thora": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Glatour Stooir": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Glenti Bulgee": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Goli Grabs": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Gomed Essoni": {
		"vendor": "Toy",
		"shrine": "Alph"
	},
	"Gomen Grap": {
		"vendor": "Mining"
	},
	"Gomphus Comatus": {},
	"Gondata Moo": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Gongura Gamble": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Gooliv Naven": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Goorsh Gam": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Gopchan Habitat": {},
	"Gopra Byle": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Goptan Habitat": {},
	"Gori Blear": {
		"vendor": "Mining",
		"shrine": "Mab"
	},
	"Gosari Habitat": {},
	"Grand Mile": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Greenvern Mend": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Gregarious Grange": {
		"mailbox": true,
		"bureaucratic_hall": true,
		"vendor": "Grocery"
	},
	"Gregarious Towers": {},
	"Gregarious Towers Basement": {},
	"Grimssea Bottom": {
		"mailbox": true,
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Groddle Forest Junction": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Groddle Ladder": {
		"shrine": "Grendaline"
	},
	"Gueis Pumice": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Guillermo Gamera Way": {
		"mailbox": true,
		"shrine": "Pot",
		"vendor": "Special Grocery"
	},
	"Gummadi Gad": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Gurag Green": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Guraibe Gran": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Gutan Preserve": {},
	"Gyerean Park": {},
	"Hackfast Quicks": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Hakusan Heaps": {
		"shrine": "Cosma"
	},
	"Hakusan Heaps Towers": {},
	"Hakusan Heaps Towers Basement": {},
	"Hamli Egza": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Hammar Steadies": {
		"vendor": "Grocery",
		"shrine": "Cosma"
	},
	"Hanmo Hiss": {
		"shrine": "Humbaba"
	},
	"Haqiq Cedony": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Harbinger Heath": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Friendly"
	},
	"Hareesh Sook": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Hari Haring": {
		"vendor": "Mining"
	},
	"Hariali Alley": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Harkan Idiom": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Harrisa Hara": {
		"shrine": "Zille",
		"vendor": "Gardening Goods"
	},
	"Hauki Seeks": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Friendly"
	},
	"Hauki Seeks Manor": {},
	"Hauki Seeks Manor Basement": {},
	"Hayden Seek Alley": {
		"vendor": "Toy",
		"shrine": "Zille"
	},
	"Hayseed Rd 1": {},
	"Hayseed Rd 2": {},
	"Hayseed Rd 3": {},
	"Hayseed Rd 4": {},
	"Hayseed Rd 5": {},
	"Hazy Gate 1": {},
	"Hazy Gate 2": {},
	"Hazy Gate 3": {},
	"Hazy Gate 4": {},
	"Hazy Gate 5": {},
	"Hazy Gate 6": {},
	"Hechey Track": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Heckes": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Heera Amond": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Hellenturret Pass": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Hellinum Dum": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Helvell Morell": {},
	"Hidro Bluu": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Highland Fling": {
		"vendor": "Animal Goods"
	},
	"Hillet Fillet": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Hoari Furgg": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Hobak Habitat": {},
	"Hosta Park": {},
	"Hullis Dalb": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Humus Hollow": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Iable Var": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Ianara Straight": {
		"mailbox": true,
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Icicle Dangles": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Idan Frisk": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Ignee Tye": {},
	"Iljoki Ease": {
		"vendor": "Produce",
		"shrine": "Tii"
	},
	"Ilmenskie": {},
	"Ilmoilan Sequence": {
		"vendor": "Kitchen Tools",
		"shrine": "Tii"
	},
	"Inari Deeps": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Indulcet Fames": {},
	"Injeba Wedge": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Injeer Asour": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Injera Nitre": {
		"shrine": "Mab",
		"vendor": "Gardening Goods"
	},
	"Inkeis Shag": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Insidias Sapienti": {},
	"Insula Silva": {},
	"Intate Treats": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Irron Lavi": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Isalan Interval": {
		"vendor": "Gardening Goods",
		"shrine": "Grendaline"
	},
	"Iso Roine": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Ivalo Trims": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Jacob's Climb": {
		"mailbox": true,
		"vendor": "Toy",
		"shrine": "Cosma"
	},
	"Jadraan Fix": {
		"vendor": "Hardware",
		"shrine": "Alph"
	},
	"Jameeda Meds": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Jamsan Jag": {
		"vendor": "Kitchen Tools",
		"shrine": "Zille"
	},
	"Janagi Elations": {
		"shrine": "Alph",
		"vendor": "Mining"
	},
	"Jansib Preserve": {},
	"Jansin Park": {},
	"Jantik Jog": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Jappa Chae": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Jarjai Binq": {
		"shrine": "Mab",
		"vendor": "Toy"
	},
	"Jazi Kaya": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Jeban Journey": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Jee Guru": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Jellow Diaspora": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Jethimadh Herb Gardens": {},
	"Jigoree Galbee": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Jiireesh Risen": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Jiji Preserve": {},
	"Joklin Seddin": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Jolkan Jank": {
		"vendor": "Animal Goods",
		"shrine": "Pot"
	},
	"Jonku Impressions": {
		"vendor": "Grocery",
		"shrine": "Humbaba"
	},
	"Jonna Jinx": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Jullis Junc": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Juom Guson": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Justitia Coelum": {},
	"Jutuan Central": {
		"vendor": "Animal Goods",
		"shrine": "Pot"
	},
	"Kaavi Kannot": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Kaavin Kit": {
		"mailbox": true,
		"vendor": "Toy",
		"shrine": "Lem"
	},
	"Kaha Haha": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Kaiya Kit": {
		"vendor": "Toy",
		"shrine": "Mab"
	},
	"Kakkasi Uni": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Kala Close": {
		"vendor": "Kitchen Tools",
		"shrine": "Grendaline"
	},
	"Kalix Follows": {
		"vendor": "Gardening Goods",
		"shrine": "Tii"
	},
	"Kalla Chase": {
		"vendor": "Gardening Goods",
		"shrine": "Cosma"
	},
	"Kalp Clips": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Kalware Mare": {
		"shrine": "Alph"
	},
	"Kampung Preserve": {},
	"Kanji Sink": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Kanni Climb": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Kanuka Saus": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Kanun Phothen": {},
	"Kapru Habitat": {},
	"Karka Dakam": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Kartika Crams": {
		"mailbox": true,
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Kash Brah": {
		"vendor": "Produce",
		"shrine": "Cosma"
	},
	"Kategna Kibe": {
		"vendor": "Mining"
	},
	"Katela Ameth": {
		"vendor": "Grocery",
		"shrine": "Cosma"
	},
	"Kattil Natron": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Kazaka Boviss": {},
	"Kebra Glories": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Cosma"
	},
	"Keidler Caims": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Kelba Vallu": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Kenora Gigoki": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Kerivepa Vili": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Kermu Park": {},
	"Keywot Whot": {
		"vendor": "Mining"
	},
	"Khanda Jarra": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Khat Massives": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Khoul Bheens": {
		"vendor": "Gardening Goods",
		"shrine": "Alph"
	},
	"Khubbani Siggara": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Kiehiman Course": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Zille"
	},
	"Kifti Crown": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Kiiminki Stretch": {
		"vendor": "Produce",
		"shrine": "Humbaba"
	},
	"Kikal Kalzo": {
		"vendor": "Mining"
	},
	"Kilamu Lamme": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Kinabarr Kan": {},
	"Kinche Klap": {
		"vendor": "Mining"
	},
	"Kipacre Greens": {
		"vendor": "Gardening Goods",
		"shrine": "Friendly"
	},
	"Kitfo Lega": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Kitkaa Carom": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Klikka Kawer": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Knaphre Crag": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Kobah Habitat": {},
	"Kobbaya Shii": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Kohanger Hang": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Koita Clutter": {
		"vendor": "Kitchen Tools",
		"shrine": "Friendly"
	},
	"Kolan Presence": {
		"vendor": "Hardware",
		"shrine": "Alph"
	},
	"Konemaen Jaunt": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Lem"
	},
	"Kongu Hop": {
		"mailbox": true,
		"shrine": "Alph",
		"subway_station": true,
		"vendor": "Animal Goods"
	},
	"Konka Brink": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Zille"
	},
	"Konkan Carom": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Koozh Sidestep": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Kosi Aracana": {
		"vendor": "Toy",
		"shrine": "Pot"
	},
	"Kotteletti Kota": {
		"vendor": "Mining"
	},
	"Kottima Cast": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Koulato Cluster": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Cosma"
	},
	"Koumbahm Bahm": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Kouris Kauri": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Zille"
	},
	"Kratoch Emer": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Krios Palm": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Kuben Ruben": {},
	"Kumida Middles": {
		"shrine": "Mab"
	},
	"Kura Kura": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Kuri Chil": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Kutu Preserve": {},
	"Kymi Abyss": {
		"vendor": "Hardware",
		"shrine": "Grendaline"
	},
	"Kyron Kreep": {
		"vendor": "Gardening Goods",
		"shrine": "Friendly"
	},
	"Kyy Queries": {
		"vendor": "Gardening Goods",
		"shrine": "Alph"
	},
	"La Kama": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Laccaria Quadrata": {},
	"Lacier Landare": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Lacus Calidus": {},
	"Ladag Mach": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Lagan Lark": {
		"vendor": "Kitchen Tools",
		"shrine": "Cosma"
	},
	"Lampaan Avert": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Langden Abbey": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Languid Line S": {},
	"Languid Line SE": {},
	"Languid Line SW": {},
	"Languid Line W": {},
	"Lapix Lora": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Larceny Ladder": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Laroo Ledge": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Larvik Skarn": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Lavaku Lore": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Lavu Lane": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Lebben Laps": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Ledge Narrows": {},
	"Leeteg": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Leetha Beetha": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Leffe Weff": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Leftmost Graze": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Lemmen Connect": {
		"vendor": "Hardware",
		"shrine": "Pot"
	},
	"Lentua Lane": {
		"vendor": "Kitchen Tools",
		"shrine": "Grendaline"
	},
	"Leonta Park": {},
	"Lethensome Lift": {
		"vendor": "Kitchen Tools",
		"shrine": "Spriggan"
	},
	"Level 2 East": {
		"vendor": "Meal"
	},
	"Level 2 West": {
		"shrine": "Zille"
	},
	"Levyn Gahne": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Lexdistin Guitur": {},
	"Likomärkä": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Limmu Later": {
		"vendor": "Mining"
	},
	"Livo Farce": {
		"vendor": "Animal Goods",
		"shrine": "Cosma"
	},
	"Loimi Linger": {
		"vendor": "Kitchen Tools",
		"shrine": "Alph"
	},
	"Loksa Laarb": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Lolime Kakaneeli": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Lonkari Line": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Lorme Rush": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Lotha Harte": {
		"vendor": "Toy",
		"shrine": "Cosma"
	},
	"Louise Pasture": {
		"mailbox": true,
		"vendor": "Animal Goods",
		"shrine": "Grendaline"
	},
	"Loutish Ln A": {},
	"Loutish Ln B": {},
	"Loutish Ln C": {},
	"Loutish Ln D": {},
	"Lowan Len": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Lowland Slough": {
		"vendor": "Animal Goods",
		"shrine": "Mab"
	},
	"Luiro Run": {
		"vendor": "Produce",
		"shrine": "Tii"
	},
	"Lulu Lim": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Luma Preserve": {},
	"Luminous Night": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Lunae Hubaye": {},
	"Lunu Lane": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Lustan Cautions": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Lutto Lisp": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Luump Yasa": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Maaku Mills": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Maale Bads": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Machaboos Mess": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Macsaaro Fimto": {
		"vendor": "Mining"
	},
	"Madhur Hathur": {},
	"Magha Shank": {
		"vendor": "Hardware"
	},
	"Maiwiwi Don": {
		"shrine": "Mab",
		"vendor": "Produce"
	},
	"Maka Murh": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Makaram Maker": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Malaba Summit": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Maladii Trik": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Malaren Urge": {
		"vendor": "Hardware",
		"shrine": "Grendaline"
	},
	"Malika Whim": {
		"vendor": "Mining",
		"shrine": "Zille"
	},
	"Mallos Means": {
		"vendor": "Alchemical Goods",
		"shrine": "Cosma"
	},
	"Manak Ruba": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Mandu Passo": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Mangane Gaps": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Manggai Mile": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Manggal Haste": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Manoq Preserve": {},
	"Manya Man": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Marga Mooch": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Margazhi Gazzi": {
		"vendor": "Grocery",
		"shrine": "Grendaline"
	},
	"Markas Maarkas": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Marl Pegma": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Marlan Bias": {
		"vendor": "Alchemical Goods",
		"shrine": "Friendly"
	},
	"Maroni Aloe": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Marrakesh Meadow": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Mart's Way 1": {},
	"Mart's Way 2": {},
	"Mart's Way 3": {},
	"Mart's Way 4": {},
	"Marylpole Mount": {
		"vendor": "Toy",
		"shrine": "Spriggan"
	},
	"Masi Step": {
		"vendor": "Toy",
		"shrine": "Tii"
	},
	"Masod Match": {
		"vendor": "Mining"
	},
	"Masquff Greets": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Matara Ara": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Matsia Tia": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Matsua Mossy": {
		"shrine": "Spriggan"
	},
	"Maybe Marsh": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Alph"
	},
	"Mayspeek Moar": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Meade Weeds": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Meadow Community Machine Room": {},
	"Meadow's Edge": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Humbaba"
	},
	"Medam Mads": {
		"vendor": "Produce",
		"shrine": "Zille"
	},
	"Medbim Preserve": {},
	"Meenam Seer": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Meera Dhala": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Megna Burrow": {
		"shrine": "Grendaline",
		"vendor": "Mining"
	},
	"Meion Nsut": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Melalu Mile": {
		"shrine": "Pot"
	},
	"Mellai Nivelare": {},
	"Memento Sana": {},
	"Mens Liber": {},
	"Mercia Mersey": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Mesekel Maybes": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Meskel Move": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Mesob Medium": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Metch Morass": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Mica Nephe": {
		"shrine": "Mab",
		"vendor": "Produce"
	},
	"Middle Arbor": {
		"mailbox": true,
		"vendor": "Gardening Goods",
		"shrine": "Lem"
	},
	"Middle Valley Clearing": {
		"machine_room": true,
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Midtunam Tunam": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Mien Evoke": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Mimosa Mix": {
		"shrine": "Friendly"
	},
	"Mina Misses": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Mincedoathe Formation": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Minichii Chia": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Mino Kree": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Mira Mesh": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"MitMit Meets": {
		"vendor": "Mining"
	},
	"Mmumawwa Wala": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Modati Modes": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Mogari Preserve": {},
	"Mokkar Mill": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Monas Mopane": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Moonga Coral": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Moonlit Grove": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Moraba Plains": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Morben Kin": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Morchella Lepiota": {},
	"Mossed Lim": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Mossystep": {
		"vendor": "Grocery"
	},
	"Motala Dun": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Moti Peral": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Mrandeya Minds": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Mrozia": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Mucid Memes": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Mullangi Meda": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Mullat": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Multum Parvo": {},
	"Murrukku Meander": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Musaka Sakes": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Mussirio Flero": {},
	"Musta Hafsum": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Mutta Maart": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Muufo Start": {},
	"Muuja Jah": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Mycinna Muscarea": {},
	"Mydus Tangere": {},
	"Myndun Snun": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Naama Habitat": {},
	"Naata Garth": {
		"vendor": "Hardware",
		"shrine": "Tii"
	},
	"Naatamo Way": {
		"vendor": "Animal Goods",
		"shrine": "Mab"
	},
	"Naera Needs": {
		"shrine": "Mab",
		"vendor": "Produce"
	},
	"Nagam Truth": {
		"vendor": "Grocery",
		"shrine": "Mab"
	},
	"Nagrjuna Junta": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Nagu Keel": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Naif Lane E": {},
	"Naif Lane S": {},
	"Naif Lane SE": {},
	"Naif Lane SW": {},
	"Naif Lane W": {},
	"Nalla Duva": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Namul Habitat": {},
	"Nana Null": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Nandak Intention": {
		"shrine": "Zille",
		"vendor": "Mining"
	},
	"Nandu Pitha": {
		"shrine": "Pot",
		"vendor": "Kitchen Tools"
	},
	"Nanita Peckita": {},
	"Narasiha Seeha": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Natan Noks": {
		"vendor": "Grocery",
		"shrine": "Grendaline"
	},
	"Navran Dissent": {
		"vendor": "Kitchen Tools",
		"shrine": "Zille"
	},
	"Nawiwa Wend": {
		"vendor": "Mining"
	},
	"Neelam Saff": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Nemo Sana": {},
	"Neurph Turf": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Neva Neva": {},
	"Newcot Close": {
		"vendor": "Grocery",
		"shrine": "Alph"
	},
	"Nia Sra": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Nicosa False": {
		"shrine": "Pot",
		"vendor": "Kitchen Tools"
	},
	"Nightshade Woods": {
		"vendor": "Kitchen Tools"
	},
	"Niiske Kook": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Nila Nila": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Nilpsama": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Nipigon Banc": {
		"vendor": "Toy",
		"shrine": "Mab"
	},
	"Nira Nooks": {
		"shrine": "Cosma"
	},
	"Niten Lytin": {},
	"Nohmin Cents": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Northwest Passage": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Nowaa Holler": {
		"shrine": "Tii"
	},
	"Nutrit  Malorum": {},
	"Odena Odes": {
		"shrine": "Friendly"
	},
	"Odisse Videntur": {},
	"Ojan Repine": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Ojangi Chimi": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Okara Cast": {
		"shrine": "Cosma"
	},
	"Oktyabrya": {
		"mailbox": true,
		"shrine": "Pot"
	},
	"Olani Ohm": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Omnium Prospice": {},
	"Onbo Park": {},
	"Onkamo Ward": {
		"vendor": "Hardware",
		"shrine": "Lem"
	},
	"Onoma Peas": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Onto Parada": {
		"mailbox": true,
		"vendor": "Animal Goods",
		"shrine": "Pot"
	},
	"Ora Soon": {
		"vendor": "Produce",
		"shrine": "Alph"
	},
	"Ortolana": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Osechi Oath": {
		"shrine": "Spriggan"
	},
	"Otterlane": {
		"machine_room": true,
		"mailbox": true,
		"vendor": "Hardware",
		"shrine": "Zille"
	},
	"Oulanka End": {
		"vendor": "Toy"
	},
	"Ounaas Means": {
		"vendor": "Produce",
		"shrine": "Humbaba"
	},
	"Ovgos Lam": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Oyas Yeh": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Ozacosta Avenue": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Paala Latte": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Paatol Press": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Paats Yield": {
		"vendor": "Hardware",
		"shrine": "Humbaba"
	},
	"Paaviri Vent": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Pacca Pax": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Pachi Preach": {
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Pahsmeq Diggs": {
		"vendor": "Animal Goods",
		"shrine": "Mab"
	},
	"Paijanne Feign": {
		"vendor": "Grocery",
		"shrine": "Friendly"
	},
	"Pakodi Prim": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Palguna Muna": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Pallur Runnar": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Palsa Mosch": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Pandhal Pegs": {
		"vendor": "Toy",
		"shrine": "Zille"
	},
	"Pandu Chepa": {
		"vendor": "Produce"
	},
	"Panguni Ploy": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Panko Press": {
		"shrine": "Pot"
	},
	"Panna Meral": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Pannaa Marrim": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Pansanu Insanu": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Paodoo Lets": {
		"vendor": "Mining"
	},
	"Parinosa Apix": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Parsin's Trail E": {},
	"Parsin's Trail SE": {},
	"Parsin's Trail SW": {},
	"Parsin's Trail W": {},
	"Parvana Pungence": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Pasha's Place": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Pasque Ridge": {
		"vendor": "Animal Goods",
		"shrine": "Mab"
	},
	"Patchouli Preamble": {
		"shrine": "Grendaline"
	},
	"Patomi Bunya": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Peatland Moors": {
		"vendor": "Toy"
	},
	"Pedieos Fig": {
		"mailbox": true,
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Peero Peers": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Pendala Pax": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Penglais Nuht": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Pental Leave": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Perhoni Flim": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Petrif Willow": {
		"mailbox": true,
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Phersu Preserve": {},
	"Pholiota Squarros": {},
	"Phrood Kulm": {
		"vendor": "Kitchen Tools",
		"shrine": "Grendaline"
	},
	"Pielis Pass": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Pielus Pleurotus": {},
	"Piene Question": {
		"vendor": "Kitchen Tools",
		"shrine": "Tii"
	},
	"Pikku Precedent": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Pikul Park": {},
	"Pilnjan Plink": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Pinhigh Prose": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Pinnan Glimpse": {
		"vendor": "Gardening Goods",
		"shrine": "Pot"
	},
	"Pipit Throat": {
		"shrine": "Tii",
		"vendor": "Alchemical Goods"
	},
	"Pitika Parse": {
		"vendor": "Hardware",
		"shrine": "Zille"
	},
	"Pitonia Lood": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Piyaz Prone": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Grendaline"
	},
	"Plains Rte A": {},
	"Plains Rte B": {},
	"Plains Rte C": {},
	"Plains Rte D": {},
	"Pokhraj Topa": {
		"vendor": "Grocery",
		"shrine": "Mab"
	},
	"PokiPok Press": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Polapat Patron": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Polenta Qado": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Ponghal Pleats": {
		"mailbox": true,
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Poorna Plea": {
		"mailbox": true,
		"shrine": "Mab",
		"vendor": "Produce"
	},
	"Porcini Bolete": {},
	"Poro Nella": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Posse Laeseris": {},
	"Pourto Ello": {},
	"Pradera Passo": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Prashura Sure": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Prestnash Thrash": {
		"vendor": "Hardware",
		"shrine": "Grendaline"
	},
	"Prutki Pardons": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Puckell Peck": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Punar Grotta": {
		"shrine": "Cosma",
		"vendor": "Mining"
	},
	"Pungent Ponds": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Punpun Snug": {
		"vendor": "Mining",
		"shrine": "Mab"
	},
	"Puran Pills": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Putter Track A": {},
	"Putter Track B": {},
	"Putter Track C": {},
	"Putter Track D": {},
	"Putter Track E": {},
	"Puttu Petty": {
		"mailbox": true,
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Qaado Barrus": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Qabena Quaint": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Qermiz Habitat": {},
	"Quinmchary": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Quluuwaa Luwa": {
		"vendor": "Mining"
	},
	"Quozee Quanta": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Raagi Road": {
		"shrine": "Pot",
		"vendor": "Grocery"
	},
	"Radin Ralis": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Rai Ram": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Ramavata Vata": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Ramble Way 1": {},
	"Ramble Way 2": {},
	"Ramble Way 3": {},
	"Ramble Way 4": {},
	"Ramble Way 5": {},
	"Ramble Way 6": {},
	"Ramfeon Cima": {
		"vendor": "Alchemical Goods",
		"shrine": "Alph"
	},
	"Ramosum Pranum": {},
	"Ramsley Sway": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Ramyeon Kon": {
		"shrine": "Pot",
		"vendor": "Grocery"
	},
	"Range Rd 1": {},
	"Range Rd 2": {},
	"Range Rd 3": {},
	"Range Rd 4": {},
	"Range Rd 5": {},
	"Range Rd 6": {},
	"Range Rd 7": {},
	"Rangu Mumu": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Rappam Rolls": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Rasal Hanoo": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Ratin Jot Jog": {
		"vendor": "Kitchen Tools",
		"shrine": "Alph"
	},
	"Raudan Rasp": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Raudan Sparkle": {
		"vendor": "Grocery",
		"shrine": "Friendly"
	},
	"Rausa Repent": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Ravenelii Mucida": {},
	"Redhorn Rd E": {},
	"Redhorn Rd N": {},
	"Redhorn Rd NE": {},
	"Redhorn Rd NW": {},
	"Redhorn Rd W": {},
	"Rekan Flux": {
		"vendor": "Produce",
		"shrine": "Lem"
	},
	"Revdyo Rake": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Rhyol Dolo": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Rhystosto Motto": {},
	"Rijul Habitat": {},
	"Rikki Regard": {
		"vendor": "Animal Goods",
		"shrine": "Spriggan"
	},
	"Ritzrock Rise": {
		"vendor": "Hardware",
		"shrine": "Lem"
	},
	"Robenaa Range": {
		"vendor": "Gardening Goods",
		"shrine": "Tii"
	},
	"Rocher Joch": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Rook's Way 1": {},
	"Rook's Way 2": {},
	"Rook's Way 3": {},
	"Rook's Way 4": {},
	"Rook's Way 5": {},
	"Rookthills Lay": {
		"vendor": "Gardening Goods",
		"shrine": "Zille"
	},
	"Rube's Way 1": {},
	"Rube's Way 2": {},
	"Rube's Way 3": {},
	"Rube's Way 4": {},
	"Rube's Way 5": {},
	"Rube's Way 6": {},
	"Rudna Barthii": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Rumina Ruma": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Rushlane Steading": {
		"vendor": "Grocery",
		"shrine": "Alph"
	},
	"Russula Involutii": {},
	"Rustic Rd E": {},
	"Rustic Rd N": {},
	"Rustic Rd NE": {},
	"Rustic Rd NW": {},
	"Ruta Asuncion": {
		"shrine": "Cosma"
	},
	"Rutase Preserve": {},
	"Rutyle Scheel": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Saafed Leek": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Saani Shim": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Lem"
	},
	"Sabelli Ochre": {},
	"Sabudana Drama": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Sabudana Drama Towers": {},
	"Sabudana Drama Towers Basement": {},
	"Sadam Savanna": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Saker Mank": {
		"shrine": "Alph",
		"vendor": "Animal Goods"
	},
	"Sakinalu Shreds": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Salatu Start": {},
	"Salix Seach": {
		"shrine": "Mab"
	},
	"Samak Shun": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Sambara Stack": {
		"vendor": "Toy",
		"shrine": "Pot"
	},
	"Sambossa Bossa": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Samdol Habitat": {},
	"Samga Preserve": {},
	"Sanguine Sigg": {},
	"Sankrit Sul": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Sanna Salts": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Sappatu Slinks": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Sapslow Tweeds": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Sarda Rapt": {
		"vendor": "Mining",
		"shrine": "Humbaba"
	},
	"Savi Sense": {
		"vendor": "Alchemical Goods",
		"shrine": "Cosma"
	},
	"Savren Sutch": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Scarletto Fuungoo": {},
	"Scaup Low": {
		"mailbox": true,
		"shrine": "Mab",
		"vendor": "Produce"
	},
	"Scribe's Weald": {},
	"Sculdent Shill": {
		"vendor": "Kitchen Tools",
		"shrine": "Friendly"
	},
	"Seela Latta": {
		"shrine": "Mab",
		"vendor": "Gardening Goods"
	},
	"Seeyam Far": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Seki Shim": {
		"shrine": "Humbaba"
	},
	"Seldom Squish": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Selsi Loss": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Semper Valere": {},
	"Semsan Simile": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Senaga Siren": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Senna Karup": {
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Seugal Elba": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Seva Opens": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Shak Shales": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Sheba Shales": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Shillrigg Tiers": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Shimbra Asa": {
		"vendor": "Mining"
	},
	"Shimla Mirch Herb Gardens": {},
	"Shinso Ello": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Shiro Siga": {
		"vendor": "Mining"
	},
	"Shoga Links": {
		"shrine": "Zille"
	},
	"Sickle Nappo": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Simean Dims": {
		"vendor": "Kitchen Tools",
		"shrine": "Zille"
	},
	"Simo Steer": {
		"vendor": "Grocery",
		"shrine": "Mab"
	},
	"Simpele Slip": {
		"vendor": "Grocery",
		"shrine": "Mab"
	},
	"Sini Shake": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Sinig Safes": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Sinseollo Park": {},
	"Sintin Sess": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Siuruan Untold": {
		"vendor": "Alchemical Goods",
		"shrine": "Friendly"
	},
	"Slappao Kalt": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Sliding Skimmers": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Slippery Climb": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Smallend High": {
		"vendor": "Produce",
		"shrine": "Zille"
	},
	"Smew Yew": {
		"shrine": "Pot",
		"vendor": "Grocery"
	},
	"Smy Mod": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Snullin Ballin": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Sobane Banes": {
		"shrine": "Grendaline"
	},
	"Soggy Bottoms": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Sohan Sheer": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Friendly"
	},
	"Solachi Slims": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Soleu Lucii": {},
	"Somewhat Sump": {
		"vendor": "Kitchen Tools",
		"shrine": "Grendaline"
	},
	"Sorrel Snag": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Spagh Federa": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Spitze Summit": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Splendet Erit": {},
	"Squatter's Quag": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Sri Holik": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Stafli Joli": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Stake Claim Rd A": {},
	"Stake Claim Rd B": {},
	"Stake Claim Rd C": {},
	"Stake Claim Rd D": {},
	"Stake Claim Rd E": {},
	"Stake Claim Rd F": {},
	"Steeha Sham": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Stenina Jora": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Stopan Winnow": {
		"vendor": "Animal Goods",
		"shrine": "Lem"
	},
	"Stora Rede": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Stornur Sezzez": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Strucote Stacks": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Subarna Spells": {
		"shrine": "Cosma",
		"vendor": "Mining"
	},
	"Sulten Kepp": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Sultri Sim": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Sunela Citrine": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Sunsitara Stona": {
		"vendor": "Kitchen Tools",
		"shrine": "Cosma"
	},
	"Suruta Serendipity": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Surx Upx": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Svarta Swale": {
		"vendor": "Hardware",
		"shrine": "Mab"
	},
	"Swain Way 1": {},
	"Swain Way 2": {},
	"Swain Way 3": {},
	"Swain Way 4": {},
	"Swain Way 5": {},
	"Swain Way 6": {},
	"Switchback": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Sylvan Grove": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Sysma Link": {
		"vendor": "Alchemical Goods",
		"shrine": "Cosma"
	},
	"Taboon Tribute": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Tachai Tanbur": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Tachyl Grit": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Tadaa Track": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Humbaba"
	},
	"Taftan Raves": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Takeno Tides": {
		"shrine": "Tii"
	},
	"Takioueen Ween": {
		"shrine": "Spriggan",
		"vendor": "Hardware"
	},
	"Takuan This": {
		"shrine": "Mab"
	},
	"Tallama Trends": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Tallish Crest": {
		"vendor": "Grocery",
		"shrine": "Mab"
	},
	"Tallus Gardens": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Friendly"
	},
	"Tamar Garna": {
		"vendor": "Hardware",
		"shrine": "Grendaline"
	},
	"Tamasco Roko": {},
	"Tambra Tiss": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Tammer Path": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Tamota Trill": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Tana Trample": {
		"vendor": "Grocery",
		"shrine": "Alph"
	},
	"Tandem Flush": {
		"vendor": "Grocery"
	},
	"Tejj Trades": {
		"vendor": "Toy",
		"shrine": "Humbaba"
	},
	"Telanga Tops": {
		"shrine": "Tii",
		"vendor": "Toy"
	},
	"Tella Hella": {
		"vendor": "Hardware",
		"shrine": "Zille"
	},
	"Tennio Spur": {
		"vendor": "Kitchen Tools",
		"shrine": "Mab"
	},
	"Tenten Fure": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Teobocci Shasha": {
		"shrine": "Zille",
		"vendor": "Alchemical Goods"
	},
	"Teok Habitat": {},
	"Tepen Heel": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Tephr Scoria": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Tharon Spelunk": {
		"vendor": "Mining",
		"shrine": "Spriggan"
	},
	"The Great Hole to Ix": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"The Landing": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"The Other Drop": {
		"vendor": "Mining"
	},
	"The forgotten floor": {},
	"Thicket": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Thiruvan Thrive": {
		"vendor": "Toy",
		"shrine": "Spriggan"
	},
	"Thithi Thrust": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Thorai Theme": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Thornfad Layers": {
		"vendor": "Kitchen Tools",
		"shrine": "Tii"
	},
	"Thulam Twist": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Tibsii Wibbs": {
		"vendor": "Mining"
	},
	"Tigrinni Grins": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Tii Street": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Tillymurry Hurry": {
		"vendor": "Alchemical Goods",
		"shrine": "Grendaline"
	},
	"Tilnat Park": {},
	"Tilssii Sill": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Timtim Timm": {
		"vendor": "Mining"
	},
	"Tistel Stock": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Tlemcen": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Toisi Trappings": {
		"vendor": "Kitchen Tools",
		"shrine": "Zille"
	},
	"Tokali Kola": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Toma Traverse": {
		"mailbox": true,
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Tondak Tracks": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Tonga Trips": {
		"vendor": "Produce",
		"shrine": "Humbaba"
	},
	"Tonki Toe": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Toppa Tre": {
		"shrine": "Cosma",
		"vendor": "Hardware"
	},
	"Torpan Cleft": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Totakuru Trample": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Tower St East": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Tower St North": {
		"mailbox": true,
		"vendor": "Animal Goods",
		"shrine": "Zille"
	},
	"Tower St South": {
		"vendor": "Gardening Goods",
		"shrine": "Humbaba"
	},
	"Tower St West": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Trabriz Tale": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Traloma Habitat": {},
	"Tre Oofull": {},
	"Tree Mas": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Tremella Frondosa": {},
	"Tremit Rub": {
		"mailbox": true,
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Trikatu": {
		"shrine": "Friendly",
		"vendor": "Hardware"
	},
	"Tripping Ledges": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Tsava Tsokola": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Tsiree Tsira": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Tsuga Ramaria": {},
	"Tuara Park": {},
	"Tumble Rd 1": {},
	"Tumble Rd 2": {},
	"Tumble Rd 3": {},
	"Tumble Rd 4": {},
	"Tumble Rd 5": {},
	"Tumera Hilda": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Tunglio Bru": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Tuntsa Coze": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Turmali Tourma": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Twaye Monte": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Twickenrill Grotto": {
		"shrine": "Humbaba"
	},
	"Ubas Gracilis": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Uko Grips": {
		"vendor": "Hardware",
		"shrine": "Zille"
	},
	"Ukon Cognate": {
		"vendor": "Produce",
		"shrine": "Humbaba"
	},
	"Umebo Bodes": {
		"shrine": "Zille"
	},
	"Undermine Hollows": {
		"vendor": "Hardware"
	},
	"Unnu Slight": {
		"mailbox": true
	},
	"Uplands Verge": {
		"vendor": "Produce"
	},
	"Upper Valley Heights": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Uppma Uplands": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Uskela Passage": {
		"vendor": "Grocery",
		"shrine": "Grendaline"
	},
	"Ustilago Elata": {},
	"Vaaka Kala": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Vaala Vina": {
		"vendor": "Kitchen Tools",
		"shrine": "Alph"
	},
	"Vada Widens": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Vaikasi Rise": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Vaisakha Sack": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Valia Shede": {
		"shrine": "Spriggan",
		"vendor": "Gardening Goods"
	},
	"Valmiki Vall": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Vamanda Van": {
		"vendor": "Gardening Goods",
		"shrine": "Mab"
	},
	"Vanil Noir": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Varana Na": {
		"vendor": "Toy",
		"shrine": "Pot"
	},
	"Vartula Lura": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Vasko Shift": {
		"vendor": "Grocery",
		"shrine": "Grendaline"
	},
	"Vatch Val": {
		"vendor": "Kitchen Tools",
		"shrine": "Pot"
	},
	"Vattuu Vains": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Vekke Vets": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Velata Lang": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Veldt Balm": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Venet Root": {
		"vendor": "Animal Goods",
		"shrine": "Pot"
	},
	"Venkate Kate": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Verbum Destruit": {},
	"Verdant Green": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Veruppu Vellums": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Via Firozi": {
		"vendor": "Hardware",
		"shrine": "Zille"
	},
	"Via Velaya": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Vibrant Banks": {
		"vendor": "Toy",
		"shrine": "Alph"
	},
	"Viini Vital": {
		"vendor": "Hardware",
		"shrine": "Friendly"
	},
	"Vilong Hari": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Vina Dosh": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Vindel Frowns": {
		"vendor": "Animal Goods",
		"shrine": "Lem"
	},
	"Viscid Pud": {
		"vendor": "Gardening Goods",
		"shrine": "Spriggan"
	},
	"Vivere Aestas": {},
	"Volvacea Grifolla": {},
	"Vragan Boost": {
		"mailbox": true,
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Vrish Chi": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Vuoksi Vale": {
		"vendor": "Toy",
		"shrine": "Cosma"
	},
	"Vuos Bosca": {
		"vendor": "Alchemical Goods",
		"shrine": "Grendaline"
	},
	"Waagel Scad": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Wali Hoppers": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Watta Wayward": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Wawa West": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Waylon Way": {
		"vendor": "Alchemical Goods",
		"shrine": "Lem"
	},
	"Welldale": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"West Spice": {
		"vendor": "Drink"
	},
	"Wettish Walk": {
		"vendor": "Hardware",
		"shrine": "Cosma"
	},
	"Wickdoon Mood": {
		"mailbox": true,
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Wieser Wedge": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Wilhem Borough": {
		"vendor": "Produce",
		"shrine": "Mab"
	},
	"Willim Broun": {
		"vendor": "Animal Goods",
		"shrine": "Humbaba"
	},
	"Willis Brone": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Willo Let": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Wolbane Barrel": {
		"vendor": "Gardening Goods",
		"shrine": "Zille"
	},
	"Wooky Fleet": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Wychwood Leed": {
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Xacut Cross": {
		"vendor": "Alchemical Goods",
		"shrine": "Tii"
	},
	"Xanthien Awn": {},
	"Xhola Mades": {
		"vendor": "Alchemical Goods",
		"shrine": "Zille"
	},
	"Yan Jaggery": {
		"vendor": "Grocery",
		"shrine": "Cosma"
	},
	"Yariam Jam": {
		"vendor": "Grocery",
		"shrine": "Pot"
	},
	"Yebeg Yobs": {
		"vendor": "Mining"
	},
	"Yeoman's Bluff": {
		"vendor": "Produce",
		"shrine": "Friendly"
	},
	"Yeopsul Mumal": {
		"shrine": "Humbaba",
		"vendor": "Animal Goods"
	},
	"Yokel Yarn 1": {},
	"Yokel Yarn 2": {},
	"Yokel Yarn 3": {},
	"Yokel Yarn 4": {},
	"Yokel Yarn 5": {},
	"Yokel Yarn 6": {},
	"Yuca Litt": {
		"mailbox": true,
		"vendor": "Produce",
		"shrine": "Grendaline"
	},
	"Yugadi Yearns": {
		"vendor": "Grocery",
		"shrine": "Lem"
	},
	"Zalaib Labra": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	},
	"Zaruu Zilch": {
		"shrine": "Lem"
	},
	"Zatar Matar": {
		"shrine": "Grendaline",
		"vendor": "Produce"
	},
	"Zayffuun Zona": {
		"shrine": "Mab"
	},
	"Zayffuun Zona ": {
		"vendor": "Gardening Goods"
	},
	"Zaytuun Xalwo": {
		"shrine": "Lem",
		"vendor": "Kitchen Tools"
	},
	"Zealous Rd N": {},
	"Zealous Rd NE": {},
	"Zealous Rd NW": {},
	"Zealous Rd W": {},
	"Zelleri Sulbabi": {},
	"Zigni Zags": {
		"vendor": "Mining"
	},
	"ZilZiil Zeal": {
		"vendor": "Animal Goods",
		"shrine": "Alph"
	},
	"Zug Zug": {
		"vendor": "Kitchen Tools",
		"shrine": "Lem"
	}
};