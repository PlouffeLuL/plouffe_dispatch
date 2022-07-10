local Utils = exports.plouffe_lib:Get("Utils")

local inVehicle, vehicleId = false, 0
local isArmed, currentWeapon = false, 0
local loggedInOfficiers = {}
local loggedInEms = {}
local activeAlerts = {}
local activeBlips = {}
local weaponsClass = {}
local officiersJobs = {police = true}
local emsJobs = {ambulance = true}
local show = false
local holding = false
local playsound = true
local inNoWeaponsZones = false
local myBadge = nil
local lastCopDown = 0
local copDownInterval = 1000 * 60

local exportsZones = {
    sandypd = {
		name = "sandypd",
		coords = vector3(1831.4150390625, 3680.2834472656, 30.231922149658),
        maxZ = 10.0,
		protectEvents = true,
		isZone = true,
        type = "box",
		box = {
			A = vector2(1856.5745849609, 3718.4802246094),
			B = vector2(1876.0183105469, 3685.6511230469),
			C = vector2(1814.8037109375, 3650.7475585938),
			D = vector2(1796.6965332031, 3684.08984375)
		},
        zoneMap = {
            inEvent = "plouffe_dispatch:inNoWeaponZone",
            outEvent = "plouffe_dispatch:leftNoWeaponZone"
        }
	},

    mrpd = {
		name = "mrpd",
		coords = vector3(452.27655029297, -985.40698242188, 25.689577102661),
        maxZ = 50.0,
		protectEvents = true,
		isZone = true,
        type = "box",
		box = {
			A = vector2(409.74295043945, -962.47650146484),
			B = vector2(406.63394165039, -1033.1315917969),
			C = vector2(493.26895141602, -1026.4166259766),
			D = vector2(492.05783081055, -962.689453125)
		},
        zoneMap = {
            inEvent = "plouffe_dispatch:inNoWeaponZone",
            outEvent = "plouffe_dispatch:leftNoWeaponZone"
        }
	},

    rangerpd = {
		name = "rangerpd",
		coords = vector3(381.41262817383, 795.55981445313, 180.46153259277),
        maxZ = 30.0,
		protectEvents = true,
		isZone = true,
        type = "box",
		box = {
			A = vector2(394.69119262695, 783.80981445313),
			B = vector2(367.3903503418, 784.35876464844),
			C = vector2(365.90768432617, 803.73150634766),
			D = vector2(397.05169677734, 808.3125)
		},
        zoneMap = {
            inEvent = "plouffe_dispatch:inNoWeaponZone",
            outEvent = "plouffe_dispatch:leftNoWeaponZone"
        }
	},

    paletopd = {
		name = "paletopd",
		coords = vector3(-446.16168212891, 6006.6772460938, 28.288688659668),
        maxZ = 30.0,
		protectEvents = true,
		isZone = true,
        type = "box",
		box = {
			A = vector2(-453.31185913086, 5940.2490234375),
			B = vector2(-515.43060302734, 6003.998046875),
			C = vector2(-450.94458007813, 6071.3618164063),
			D = vector2(-393.32992553711, 6007.7431640625)
		},
        zoneMap = {
            inEvent = "plouffe_dispatch:inNoWeaponZone",
            outEvent = "plouffe_dispatch:leftNoWeaponZone"
        }
	},

    paletoEr = {
		name = "paletoEr",
		coords = vector3(-256.21728515625, 6322.267578125, 28.840915679932),
        maxZ = 20.0,
		protectEvents = true,
		isZone = true,
        type = "box",
		box = {
			A = vector2(-254.1164855957, 6292.1455078125),
			B = vector2(-221.98374938965, 6326.9321289063),
			C = vector2(-256.38323974609, 6354.189453125),
			D = vector2(-287.46356201172, 6322.2900390625)
		},
        zoneMap = {
            inEvent = "plouffe_dispatch:inNoWeaponZone",
            outEvent = "plouffe_dispatch:leftNoWeaponZone"
        }
	},

    pillboxEr = {
		name = "pillboxEr",
		coords = vector3(330.11022949219, -579.32104492188, 20.684061050415),
        maxZ = 50.0,
		protectEvents = true,
		isZone = true,
        type = "box",
		box = {
			A = vector2(296.62823486328, -530.70953369141),
			B = vector2(264.15063476563, -610.36553955078),
			C = vector2(351.138671875, -637.17913818359),
			D = vector2(412.75738525391, -539.26837158203)
		},
        zoneMap = {
            inEvent = "plouffe_dispatch:inNoWeaponZone",
            outEvent = "plouffe_dispatch:leftNoWeaponZone"
        }
	}
}

local blacklistGunshotZones = {
    cayoPerico = {coords = vector3(4988.7192382813, -4992.6948242188, 25.246885299683), maxDst = 1500},
    island = {coords = vector3(-2183.291015625, 5178.2802734375, 15.680931091309), maxDst = 25.0},
    missionRowAmmunation = {coords = vector3(12.747532844543, -1098.0404052734, 29.796762466431), maxDst = 15.0},
    industrielAmmunation = {coords = vector3(821.25988769531, -2162.6984863281, 29.618825912476), maxDst = 15.0},
    porteAvion = {coords = vector3(3057.2102050781, -4711.3999023438, 15.261606216431), maxDst = 1000}
}

local zoneNames = {
    AIRP = "Los Santos International Airport",
    ALAMO = "Alamo Sea",
    ALTA = "Alta",
    ARMYB = "Fort Zancudo",
    BANHAMC = "Banham Canyon Dr",
    BANNING = "Banning",
    BAYTRE = "Baytree Canyon",
    BEACH = "Vespucci Beach",
    BHAMCA = "Banham Canyon",
    BRADP = "Braddock Pass",
    BRADT = "Braddock Tunnel",
    BURTON = "Burton",
    CALAFB = "Calafia Bridge",
    CANNY = "Raton Canyon",
    CCREAK = "Cassidy Creek",
    CHAMH = "Chamberlain Hills",
    CHIL = "Vinewood Hills",
    CHU = "Chumash",
    CMSW = "Chiliad Mountain State Wilderness",
    CYPRE = "Cypress Flats",
    DAVIS = "Davis",
    DELBE = "Del Perro Beach",
    DELPE = "Del Perro",
    DELSOL = "La Puerta",
    DESRT = "Grand Senora Desert",
    DOWNT = "Downtown",
    DTVINE = "Downtown Vinewood",
    EAST_V = "East Vinewood",
    EBURO = "El Burro Heights",
    ELGORL = "El Gordo Lighthouse",
    ELYSIAN = "Elysian Island",
    GALFISH = "Galilee",
    GALLI = "Galileo Park",
    golf = "GWC and Golfing Society",
    GRAPES = "Grapeseed",
    GREATC = "Great Chaparral",
    HARMO = "Harmony",
    HAWICK = "Hawick",
    HORS = "Vinewood Racetrack",
    HUMLAB = "Humane Labs and Research",
    JAIL = "Bolingbroke Penitentiary",
    KOREAT = "Little Seoul",
    LACT = "Land Act Reservoir",
    LAGO = "Lago Zancudo",
    LDAM = "Land Act Dam",
    LEGSQU = "Legion Square",
    LMESA = "La Mesa",
    LOSPUER = "La Puerta",
    MIRR = "Mirror Park",
    MORN = "Morningwood",
    MOVIE = "Richards Majestic",
    MTCHIL = "Mount Chiliad",
    MTGORDO = "Mount Gordo",
    MTJOSE = "Mount Josiah",
    MURRI = "Murrieta Heights",
    NCHU = "North Chumash",
    NOOSE = "N.O.O.S.E",
    OCEANA = "Pacific Ocean",
    PALCOV = "Paleto Cove",
    PALETO = "Paleto Bay",
    PALFOR = "Paleto Forest",
    PALHIGH = "Palomino Highlands",
    PALMPOW = "Palmer-Taylor Power Station",
    PBLUFF = "Pacific Bluffs",
    PBOX = "Pillbox Hill",
    PROCOB = "Procopio Beach",
    RANCHO = "Rancho",
    RGLEN = "Richman Glen",
    RICHM = "Richman",
    ROCKF = "Rockford Hills",
    RTRAK = "Redwood Lights Track",
    SanAnd = "San Andreas",
    SANCHIA = "San Chianski Mountain Range",
    SANDY = "Sandy Shores",
    SKID = "Mission Row",
    SLAB = "Stab City",
    STAD = "Maze Bank Arena",
    STRAW = "Strawberry",
    TATAMO = "Tataviam Mountains",
    TERMINA = "Terminal",
    TEXTI = "Textile City",
    TONGVAH = "Tongva Hills",
    TONGVAV = "Tongva Valley",
    VCANA = "Vespucci Canals",
    VESP = "Vespucci",
    VINE = "Vinewood",
    WINDF = "Ron Alternates Wind Farm",
    WVINE = "West Vinewood",
    ZANCUDO = "Zancudo River",
    ZP_ORT = "Port of South Los Santos",
    ZQ_UAR = "Davis Quartz"
}

local alerts = {
    ["PlayerDead"] = {
        blip = {name = "10-10", sprite = 84, scale = 1.0, color = 1},
        job = {ambulance = true, police = true},
        street = true,
        code = "10-10",
        name = "Un civil est blesser! "
    },
    ["CopDown"] = {
        blip = {name = "10-13", sprite = 137, scale = 1.0, color = 1},
        job = {ambulance = true, police = true},
        street = true,
        code = "10-13",
        name = "URGENT: Officier au sol"
    },
    ["GunShot"] = {
        blip = {name = "10-52", sprite = 9, scale = 1.0, color = 1, radius = 100.0},
        job = {police = true},
        street = true,
        weapon = true,
        randomizeCoords = true,
        code = "10-52",
        name = "Coup de feu entendu"
    },
    ["VehicleGunShot"] = {
        blip = {name = "10-52", sprite = 56, scale = 1.0, color = 1},
        job = {police = true},
        weapon = true,
        vehicle = true,
        street = true,
        code = "10-52",
        name = "Coup de feu entendu d'un véhicule"
    },
    ["RefusedDrugDeal"] = {
        blip = {name = "10-79", sprite = 9, scale = 1.0, color = 1, radius = 250.0},
        job = {police = true},
        street = true,
        randomizeCoords = true,
        code = "10-79",
        name = "Vente de drogue en cours"
    },
    ["StolenCopCar"] = {
        blip = {name = "10-83", sprite = 56, scale = 1.0, color = 1},
        job = {police = true},
        plate = true,
        vehicle = true,
        street = true,
        code = "10-83",
        name = "Vol de véhicule d'urgence"
    },
    ["FlyingHeli"] = {
        blip = {name = "10-83H", sprite = 43, scale = 1.0, color = 3},
        job = {police = true},
        plate = true,
        vehicle = true,
        street = true,
        altitude = true,
        code = "10-83H",
        name = "Hélicoptère non identifié en vol"
    },
    ["FlyingPlane"] = {
        blip = {name = "10-83A", sprite = 16, scale = 1.0, color = 3},
        job = {police = true},
        plate = true,
        vehicle = true,
        street = true,
        altitude = true,
        code = "10-83A",
        name = "Avion non identifié en vol"
    },
    ["StolenCar"] = {
        blip = {name = "10-83", sprite = 596, scale = 1.0, color = 3},
        job = {police = true},
        plate = true,
        vehicle = true,
        street = true,
        code = "10-83",
        name = "Vol de véhicule"
    },
    ["StolenCarIgnoreDriver"] = {
        blip = {name = "10-83", sprite = 596, scale = 1.0, color = 3},
        job = {police = true},
        street = true,
        plate = true,
        vehicle = true,
        code = "10-83",
        name = "Vol de véhicule"
    },
    ["CopDanger"] = {
        blip = {name = "10-54", sprite = 137, scale = 1.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-54",
        name = "URGENT: Officier en danger"
    },
    ["CopBackup"] = {
        blip = {name = "10-14", sprite = 137, scale = 1.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-14",
        name = "Demande de renfort"
    },
    ["CopLocation"] = {
        blip = {name = "10-20", sprite = 137, scale = 1.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-20",
        name = "Position de l'agent"
    },
    ["CopPursuit"] = {
        blip = {name = "10-39", sprite = 56, scale = 1.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-39",
        name = "Poursuite en cours"
    },
    ["Houserob"] = {
        blip = {name = "10-74", sprite = 414, scale = 1.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-74",
        name = "Intrusion de propriété privée"
    },
    ["UnhautorizedZone"] = {
        blip = {name = "10-89 A", sprite = 418, scale = 1.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-89 A",
        name = "Individu dans une zone restreinte"
    },
    ["PublicArmedZone"] = {
        blip = {name = "10-89", sprite = 418, scale = 1.0, color = 1},
        job = {police = true},
        weapon = true,
        street = true,
        code = "10-89",
        name = "Individu armé"
    },
    ["10-90 A"] = {
        blip = {name = "10-90 A", sprite = 52, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-90 A",
        name = "Braquage de magasin en cours",
        style = "red"
    },
    ["10-90 B"] = {
        blip = {name = "10-90 B", sprite = 272, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-90 B",
        name = "Braquage d'une banque en cours",
        style = "red"
    },
    ["10-90 C"] = {
        blip = {name = "10-90 C", sprite = 272, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-90 C",
        name = "Braquage de la pacifique en cours",
        style = "red"
    },
    ["10-90 D"] = {
        blip = {name = "10-90 D", sprite = 304, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-90 D",
        name = "Braquage de la bijouterie en cours",
        style = "red"
    },
    ["10-90 E"] = {
        blip = {name = "10-90 E", sprite = 795, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-90 E",
        name = "Braquage d'un train en cours",
        style = "red"
    },
    ["10-90 F"] = {
        blip = {name = "10-90 F", sprite = 795, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-90 F",
        name = "Vole du manoir de Cayo Perico",
        style = "red"
    },
    ["10-74"] = {
        blip = {name = "10-74", sprite = 161, scale = 2.0, color = 1},
        job = {police = true},
        street = true,
        code = "10-74",
        name = "Introduction par effraction en cours"
    },
    ["IllegalActivity"] = {
        blip = {name = "10-65A", sprite = 9, scale = 1.0, color = 1, radius = 250.0},
        job = {police = true},
        street = true,
        code = "10-65A",
        randomizeCoords = true,
        name = "Activité douteuse en cours",
        style = "yellow"
    },
    ["StreetRace"] = {
        blip = {name = "10-65A", sprite = 9, scale = 1.0, color = 1, radius = 400.0},
        job = {police = true},
        street = true,
        vehicle = true,
        randomizeCoords = true,
        code = "10-65B",
        name = "Courses de rue en cours",
        style = "yellow"
    }
}

local colorNames = {
    "Metallic Black",
    "Metallic Graphite Black",
    "Metallic Black Steal",
    "Metallic Dark Silver",
    "Metallic Silver",
    "Metallic Blue Silver",
    "Metallic Steel Gray",
    "Metallic Shadow Silver",
    "Metallic Stone Silver",
    "Metallic Midnight Silver",
    "Metallic Gun Metal",
    "Metallic Anthracite Grey",
    "Matte Black",
    "Matte Gray",
    "Matte Light Grey",
    "Util Black",
    "Util Black Poly",
    "Util Dark silver",
    "Util Silver",
    "Util Gun Metal",
    "Util Shadow Silver",
    "Worn Black",
    "Worn Graphite",
    "Worn Silver Grey",
    "Worn Silver",
    "Worn Blue Silver",
    "Worn Shadow Silver",
    "Metallic Red",
    "Metallic Torino Red",
    "Metallic Formula Red",
    "Metallic Blaze Red",
    "Metallic Graceful Red",
    "Metallic Garnet Red",
    "Metallic Desert Red",
    "Metallic Cabernet Red",
    "Metallic Candy Red",
    "Metallic Sunrise Orange",
    "Metallic Classic Gold",
    "Metallic Orange",
    "Matte Red",
    "Matte Dark Red",
    "Matte Orange",
    "Matte Yellow",
    "Util Red",
    "Util Bright Red",
    "Util Garnet Red",
    "Worn Red",
    "Worn Golden Red",
    "Worn Dark Red",
    "Metallic Dark Green",
    "Metallic Racing Green",
    "Metallic Sea Green",
    "Metallic Olive Green",
    "Metallic Green",
    "Metallic Gasoline Blue Green",
    "Matte Lime Green",
    "Util Dark Green",
    "Util Green",
    "Worn Dark Green",
    "Worn Green",
    "Worn Sea Wash",
    "Metallic Midnight Blue",
    "Metallic Dark Blue",
    "Metallic Saxony Blue",
    "Metallic Blue",
    "Metallic Mariner Blue",
    "Metallic Harbor Blue",
    "Metallic Diamond Blue",
    "Metallic Surf Blue",
    "Metallic Nautical Blue",
    "Metallic Bright Blue",
    "Metallic Purple Blue",
    "Metallic Spinnaker Blue",
    "Metallic Ultra Blue",
    "Metallic Bright Blue",
    "Util Dark Blue",
    "Util Midnight Blue",
    "Util Blue",
    "Util Sea Foam Blue",
    "Uil Lightning blue",
    "Util Maui Blue Poly",
    "Util Bright Blue",
    "Matte Dark Blue",
    "Matte Blue",
    "Matte Midnight Blue",
    "Worn Dark blue",
    "Worn Blue",
    "Worn Light blue",
    "Metallic Taxi Yellow",
    "Metallic Race Yellow",
    "Metallic Bronze",
    "Metallic Yellow Bird",
    "Metallic Lime",
    "Metallic Champagne",
    "Metallic Pueblo Beige",
    "Metallic Dark Ivory",
    "Metallic Choco Brown",
    "Metallic Golden Brown",
    "Metallic Light Brown",
    "Metallic Straw Beige",
    "Metallic Moss Brown",
    "Metallic Biston Brown",
    "Metallic Beechwood",
    "Metallic Dark Beechwood",
    "Metallic Choco Orange",
    "Metallic Beach Sand",
    "Metallic Sun Bleeched Sand",
    "Metallic Cream",
    "Util Brown",
    "Util Medium Brown",
    "Util Light Brown",
    "Metallic White",
    "Metallic Frost White",
    "Worn Honey Beige",
    "Worn Brown",
    "Worn Dark Brown",
    "Worn straw beige",
    "Brushed Steel",
    "Brushed Black steel",
    "Brushed Aluminium",
    "Chrome",
    "Worn Off White",
    "Util Off White",
    "Worn Orange",
    "Worn Light Orange",
    "Metallic Securicor Green",
    "Worn Taxi Yellow",
    "police car blue",
    "Matte Green",
    "Matte Brown",
    "Worn Orange",
    "Matte White",
    "Worn White",
    "Worn Olive Army Green",
    "Pure White",
    "Hot Pink",
    "Salmon pink",
    "Metallic Vermillion Pink",
    "Orange",
    "Green",
    "Blue",
    "Mettalic Black Blue",
    "Metallic Black Purple",
    "Metallic Black Red",
    "hunter green",
    "Metallic Purple",
    "Metaillic V Dark Blue",
    "MODSHOP BLACK1",
    "Matte Purple",
    "Matte Dark Purple",
    "Metallic Lava Red",
    "Matte Forest Green",
    "Matte Olive Drab",
    "Matte Desert Brown",
    "Matte Desert Tan",
    "Matte Foilage Green",
    "DEFAULT ALLOY COLOR",
    "Epsilon Blue"
}

local weapons = {
    {
        class = 0,
        classStr = "Classe 0",
        type = "Contondante",
        list = {
            {
                hash = GetHashKey("weapon_crowbar"),
                name = "weapon_crowbar"
            },
            {
                hash = GetHashKey("WEAPON_BAT"),
                name = "weapon_bat"
            },
            {
                hash = GetHashKey("weapon_unarmed"),
                name = "weapon_unarmed"
            },
            {
                hash = GetHashKey("weapon_flashlight"),
                name = "weapon_flashlight"
            },
            {
                hash = GetHashKey("weapon_golfclub"),
                name = "weapon_golfclub"
            },
            {
                hash = GetHashKey("weapon_hammer"),
                name = "weapon_hammer"
            },
            {
                hash = GetHashKey("weapon_knuckle"),
                name = "weapon_knuckle"
            },
            {
                hash = GetHashKey("weapon_nightstick"),
                name = "weapon_nightstick"
            },
            {
                hash = GetHashKey("weapon_wrench"),
                name = "weapon_wrench"
            },
            {
                hash = GetHashKey("weapon_poolcue"),
                name = "weapon_poolcue"
            }
        }
    },
    {
        class = 0,
        classStr = "Classe 0",
        type = "Tranchante",
        list = {
            {
                hash = GetHashKey("weapon_dagger"),
                name = "weapon_dagger"
            },
            {
                hash = GetHashKey("weapon_bottle"),
                name = "weapon_bottle"
            },
            {
                hash = GetHashKey("weapon_hatchet"),
                name = "weapon_hatchet"
            },
            {
                hash = GetHashKey("weapon_knife"),
                name = "weapon_knife"
            },
            {
                hash = GetHashKey("weapon_machete"),
                name = "weapon_machete"
            },
            {
                hash = GetHashKey("weapon_switchblade"),
                name = "weapon_switchblade"
            },
            {
                hash = GetHashKey("weapon_battleaxe"),
                name = "weapon_battleaxe"
            },
            {
                hash = GetHashKey("weapon_stone_hatchet"),
                name = "weapon_stone_hatchet"
            }
        }
    },
    {
        class = 1,
        classStr = "Classe 1",
        type = "Pistolet",
        list = {
            {
                hash = GetHashKey("weapon_pistol"),
                name = "weapon_pistol"
            },
            {
                hash = GetHashKey("weapon_pistol_mk2"),
                name = "weapon_pistol_mk2"
            },
            {
                hash = GetHashKey("weapon_combatpistol"),
                name = "weapon_combatpistol"
            },
            {
                hash = GetHashKey("weapon_snspistol"),
                name = "weapon_snspistol"
            },
            {
                hash = GetHashKey("weapon_snspistol_mk2"),
                name = "weapon_snspistol_mk2"
            },
            {
                hash = GetHashKey("weapon_vintagepistol"),
                name = "weapon_vintagepistol"
            },
            {
                hash = GetHashKey("weapon_ceramicpistol"),
                name = "weapon_ceramicpistol"
            },
            {
                hash = GetHashKey("weapon_gadgetpistol"),
                name = "weapon_gadgetpistol"
            },
            {
                hash = GetHashKey("weapon_dp9"),
                name = "weapon_dp9"
            },
            {
                hash = GetHashKey("weapon_browning"),
                name = "weapon_browning"
            },
            {
                hash = GetHashKey("WEAPON_M45A1"),
                name = "WEAPON_M45A1"
            },
            {
                hash = GetHashKey("WEAPON_P320B"),
                name = "WEAPON_P320B"
            },
        }
    },
    {
        class = 1,
        classStr = "Classe 1",
        type = "Pistolet lourd",
        list = {
            {
                hash = GetHashKey("weapon_pistol50"),
                name = "weapon_pistol50"
            },
            {
                hash = GetHashKey("weapon_heavypistol"),
                name = "weapon_heavypistol"
            },
            {
                hash = GetHashKey("weapon_marksmanpistol"),
                name = "weapon_marksmanpistol"
            },
            {
                hash = GetHashKey("weapon_revolver"),
                name = "weapon_revolver"
            },
            {
                hash = GetHashKey("weapon_revolver_mk2"),
                name = "weapon_revolver_mk2"
            },
            {
                hash = GetHashKey("weapon_doubleaction"),
                name = "weapon_doubleaction"
            },
            {
                hash = GetHashKey("weapon_navyrevolver"),
                name = "weapon_navyrevolver"
            },
            {
                hash = GetHashKey("WEAPON_DEAGLE"),
                name = "WEAPON_DEAGLE"
            }
        }
    },
    {
        class = 2,
        classStr = "Classe 2",
        type = "Smg",
        list = {
            {
                hash = GetHashKey("weapon_appistol"),
                name = "weapon_appistol"
            },
            {
                hash = GetHashKey("weapon_microsmg"),
                name = "weapon_microsmg"
            },
            {
                hash = GetHashKey("weapon_machinepistol"),
                name = "weapon_machinepistol"
            },
            {
                hash = GetHashKey("weapon_minismg"),
                name = "weapon_minismg"
            },
            {
                hash = GetHashKey("weapon_glock18c"),
                name = "weapon_glock18c"
            },
            {
                hash = GetHashKey("weapon_scorpionevo"),
                name = "weapon_scorpionevo"
            },
            {
                hash = GetHashKey("WEAPON_MP9A"),
                name = "WEAPON_MP9A"
            }
        }
    },
    {
        class = 2,
        classStr = "Classe 2",
        type = "Smg lourd",
        list = {
            {
                hash = GetHashKey("weapon_smg"),
                name = "weapon_smg"
            },
            {
                hash = GetHashKey("weapon_smg_mk2"),
                name = "weapon_smg_mk2"
            },
            {
                hash = GetHashKey("weapon_assaultsmg"),
                name = "weapon_assaultsmg"
            },
            {
                hash = GetHashKey("weapon_combatpdw"),
                name = "weapon_combatpdw"
            },
            {
                hash = GetHashKey("weapon_compactrifle"),
                name = "weapon_compactrifle"
            },
            {
                hash = GetHashKey("weapon_gusenberg"),
                name = "weapon_gusenberg"
            },
            {
                hash = GetHashKey("weapon_draco"),
                name = "weapon_draco"
            },
            {
                hash = GetHashKey("weapon_mpx"),
                name = "weapon_mpx"
            },
            {
                hash = GetHashKey("WEAPON_P90FM"),
                name = "WEAPON_P90FM"
            },
            {
                hash = GetHashKey("WEAPON_AKS74U"),
                name = "WEAPON_AKS74U"
            },
            {
                hash = GetHashKey("WEAPON_PMXFM"),
                name = "WEAPON_PMXFM"
            },
            {
                hash = GetHashKey("WEAPON_SCARSC"),
                name = "WEAPON_SCARSC"
            }
        }
    },
    {
        class = 3,
        classStr = "Classe 3",
        type = "Fusil d'assault",
        list = {
            {
                hash = GetHashKey("weapon_assaultrifle"),
                name = "weapon_assaultrifle"
            },
            {
                hash = GetHashKey("weapon_assaultrifle_mk2"),
                name = "weapon_assaultrifle_mk2"
            },
            {
                hash = GetHashKey("weapon_carbinerifle"),
                name = "weapon_carbinerifle"
            },
            {
                hash = GetHashKey("weapon_carbinerifle_mk2"),
                name = "weapon_carbinerifle_mk2"
            },
            {
                hash = GetHashKey("weapon_advancedrifle"),
                name = "weapon_advancedrifle"
            },
            {
                hash = GetHashKey("weapon_specialcarbine"),
                name = "weapon_specialcarbine"
            },
            {
                hash = GetHashKey("weapon_specialcarbine_mk2"),
                name = "weapon_specialcarbine_mk2"
            },
            {
                hash = GetHashKey("weapon_bullpuprifle"),
                name = "weapon_bullpuprifle"
            },
            {
                hash = GetHashKey("weapon_bullpuprifle_mk2"),
                name = "weapon_bullpuprifle_mk2"
            },
            {
                hash = GetHashKey("weapon_militaryrifle"),
                name = "weapon_militaryrifle"
            },
            {
                hash = GetHashKey("weapon_scarh"),
                name = "weapon_scarh"
            },
            {
                hash = GetHashKey("weapon_akm"),
                name = "weapon_akm"
            },
            {
                hash = GetHashKey("WEAPON_M4A1FM"),
                name = "WEAPON_M4A1FM"
            },
            {
                hash = GetHashKey("WEAPON_SCAR17FM"),
                name = "WEAPON_SCAR17FM"
            },
            {
                hash = GetHashKey("WEAPON_50BEOWULF"),
                name = "WEAPON_50BEOWULF"
            },
            {
                hash = GetHashKey("WEAPON_MK47FM"),
                name = "WEAPON_MK47FM"
            },
            {
                hash = GetHashKey("WEAPON_SR25"),
                name = "WEAPON_SR25"
            },
            {
                hash = GetHashKey("WEAPON_G36"),
                name = "WEAPON_G36"
            },
            {
                hash = GetHashKey("WEAPON_MDR"),
                name = "WEAPON_MDR"
            },
            {
                hash = GetHashKey("WEAPON_MCXSPEAR"),
                name = "WEAPON_MCXSPEAR"
            }
        }
    },
    {
        class = 3,
        classStr = "Classe 3",
        type = "Shotgun",
        list = {
            {
                hash = GetHashKey("weapon_pumpshotgun"),
                name = "weapon_pumpshotgun"
            },
            {
                hash = GetHashKey("weapon_pumpshotgun_mk2"),
                name = "weapon_pumpshotgun_mk2"
            },
            {
                hash = GetHashKey("weapon_sawnoffshotgun"),
                name = "weapon_sawnoffshotgun"
            },
            {
                hash = GetHashKey("weapon_assaultshotgun"),
                name = "weapon_assaultshotgun"
            },
            {
                hash = GetHashKey("weapon_bullpupshotgun"),
                name = "weapon_bullpupshotgun"
            },
            {
                hash = GetHashKey("weapon_heavyshotgun"),
                name = "weapon_heavyshotgun"
            },
            {
                hash = GetHashKey("weapon_dbshotgun"),
                name = "weapon_dbshotgun"
            },
            {
                hash = GetHashKey("weapon_autoshotgun"),
                name = "weapon_autoshotgun"
            },
            {
                hash = GetHashKey("weapon_combatshotgun"),
                name = "weapon_combatshotgun"
            },
            {
                hash = GetHashKey("weapon_ltl"),
                name = "weapon_ltl"
            }
        }
    },
    {
        class = 3,
        classStr = "Classe 3",
        type = "Fusil d'assault lourd",
        list = {
            {
                hash = GetHashKey("weapon_mg"),
                name = "weapon_mg"
            },
            {
                hash = GetHashKey("weapon_combatmg"),
                name = "weapon_combatmg"
            },
            {
                hash = GetHashKey("weapon_combatmg_mk2"),
                name = "weapon_combatmg_mk2"
            }
        }
    },
    {
        class = 4,
        classStr = "Classe 4",
        type = "Fusil Sniper",
        list = {
            {
                hash = GetHashKey("weapon_musket"),
                name = "weapon_musket"
            },
            {
                hash = GetHashKey("weapon_sniperrifle"),
                name = "weapon_sniperrifle"
            },
            {
                hash = GetHashKey("weapon_heavysniper"),
                name = "weapon_heavysniper"
            },
            {
                hash = GetHashKey("weapon_heavysniper_mk2"),
                name = "weapon_heavysniper_mk2"
            },
            {
                hash = GetHashKey("weapon_marksmanrifle"),
                name = "weapon_marksmanrifle"
            },
            {
                hash = GetHashKey("weapon_marksmanrifle_mk2"),
                name = "weapon_marksmanrifle_mk2"
            },
            {
                hash = GetHashKey("WEAPON_REMOTESNIPER"),
                name = "WEAPON_REMOTESNIPER"
            },
            {
                hash = GetHashKey("WEAPON_ASSAULTSNIPER"),
                name = "WEAPON_ASSAULTSNIPER"
            }
        }
    },
    {
        class = 5,
        classStr = "Classe 5",
        type = "Fusil tres tres lourd",
        list = {
            {
                hash = GetHashKey("weapon_raycarbine"),
                name = "weapon_raycarbine"
            },
            {
                hash = GetHashKey("weapon_rpg"),
                name = "weapon_rpg"
            },
            {
                hash = GetHashKey("weapon_grenadelauncher"),
                name = "weapon_grenadelauncher"
            },
            {
                hash = GetHashKey("weapon_grenadelauncher_smoke"),
                name = "weapon_grenadelauncher_smoke"
            },
            {
                hash = GetHashKey("weapon_minigun"),
                name = "weapon_minigun"
            },
            {
                hash = GetHashKey("weapon_firework"),
                name = "weapon_firework"
            },
            {
                hash = GetHashKey("weapon_railgun"),
                name = "weapon_railgun"
            },
            {
                hash = GetHashKey("weapon_hominglauncher"),
                name = "weapon_hominglauncher"
            },
            {
                hash = GetHashKey("weapon_compactlauncher"),
                name = "weapon_compactlauncher"
            },
            {
                hash = GetHashKey("weapon_rayminigun"),
                name = "weapon_rayminigun"
            }
        }
    },
    {
        class = 6,
        classStr = "Classe 6",
        type = "Explosifs",
        list = {
            {
                hash = GetHashKey("weapon_grenade"),
                name = "weapon_grenade"
            },
            {
                hash = GetHashKey("weapon_bzgas"),
                name = "weapon_bzgas"
            },
            {
                hash = GetHashKey("weapon_molotov"),
                name = "weapon_molotov"
            },
            {
                hash = GetHashKey("weapon_stickybomb"),
                name = "weapon_stickybomb"
            },
            {
                hash = GetHashKey("weapon_proxmine"),
                name = "weapon_proxmine"
            },
            {
                hash = GetHashKey("weapon_snowball"),
                name = "weapon_snowball"
            },
            {
                hash = GetHashKey("weapon_pipebomb"),
                name = "weapon_pipebomb"
            },
            {
                hash = GetHashKey("weapon_ball"),
                name = "weapon_ball"
            },
            {
                hash = GetHashKey("weapon_smokegrenade"),
                name = "weapon_smokegrenade"
            },
            {
                hash = GetHashKey("weapon_flare"),
                name = "weapon_flare"
            }
        }
    },
    {
        class = 7,
        classStr = "Classe 7",
        type = "Autres",
        list = {
            {
                hash = GetHashKey("weapon_petrolcan"),
                name = "weapon_petrolcan"
            },
            {
                hash = GetHashKey("gadget_parachute"),
                name = "gadget_parachute"
            },
            {
                hash = GetHashKey("weapon_fireextinguisher"),
                name = "weapon_fireextinguisher"
            },
            {
                hash = GetHashKey("weapon_hazardcan"),
                name = "weapon_hazardcan"
            },
            {
                hash = GetHashKey("weapon_flaregun"),
                name = "weapon_flaregun"
            },
            {
                hash = GetHashKey("WEAPON_STUNGUN"),
                name = "WEAPON_STUNGUN"
            }
        }
    },
    {
        class = 8,
        classStr = "Classe 8",
        type = "Véhicule",
        list = {
            {
                hash = GetHashKey("VEHICLE_WEAPON_ROTORS"),
                name = "VEHICLE_WEAPON_ROTORS"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TANK"),
                name = "VEHICLE_WEAPON_TANK"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SEARCHLIGHT"),
                name = "VEHICLE_WEAPON_SEARCHLIGHT"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_RADAR"),
                name = "VEHICLE_WEAPON_RADAR"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLAYER_BULLET"),
                name = "VEHICLE_WEAPON_PLAYER_BULLET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLAYER_LAZER"),
                name = "VEHICLE_WEAPON_PLAYER_LAZER"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_ENEMY_LASER"),
                name = "VEHICLE_WEAPON_ENEMY_LASER"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLAYER_BUZZARD"),
                name = "VEHICLE_WEAPON_PLAYER_BUZZARD"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLAYER_HUNTER"),
                name = "VEHICLE_WEAPON_PLAYER_HUNTER"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLANE_ROCKET"),
                name = "VEHICLE_WEAPON_PLANE_ROCKET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SPACE_ROCKET"),
                name = "VEHICLE_WEAPON_SPACE_ROCKET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TURRET_INSURGENT"),
                name = "VEHICLE_WEAPON_TURRET_INSURGENT"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLAYER_SAVAGE"),
                name = "VEHICLE_WEAPON_PLAYER_SAVAGE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TURRET_TECHNICAL"),
                name = "VEHICLE_WEAPON_TURRET_TECHNICAL"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_NOSE_TURRET_VALKYRIE"),
                name = "VEHICLE_WEAPON_NOSE_TURRET_VALKYRIE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TURRET_VALKYRIE"),
                name = "VEHICLE_WEAPON_TURRET_VALKYRIE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_CANNON_BLAZER"),
                name = "VEHICLE_WEAPON_CANNON_BLAZER"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TURRET_BOXVILLE"),
                name = "VEHICLE_WEAPON_TURRET_BOXVILLE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_RUINER_BULLET"),
                name = "VEHICLE_WEAPON_RUINER_BULLET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_RUINER_ROCKET"),
                name = "VEHICLE_WEAPON_RUINER_ROCKET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HUNTER_MG"),
                name = "VEHICLE_WEAPON_HUNTER_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HUNTER_MISSILE"),
                name = "VEHICLE_WEAPON_HUNTER_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HUNTER_CANNON"),
                name = "VEHICLE_WEAPON_HUNTER_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HUNTER_BARRAGE"),
                name = "VEHICLE_WEAPON_HUNTER_BARRAGE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TULA_NOSEMG"),
                name = "VEHICLE_WEAPON_TULA_NOSEMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TULA_MG"),
                name = "VEHICLE_WEAPON_TULA_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TULA_DUALMG"),
                name = "VEHICLE_WEAPON_TULA_DUALMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TULA_MINIGUN"),
                name = "VEHICLE_WEAPON_TULA_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SEABREEZE_MG"),
                name = "VEHICLE_WEAPON_SEABREEZE_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_MICROLIGHT_MG"),
                name = "VEHICLE_WEAPON_MICROLIGHT_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DOGFIGHTER_MG"),
                name = "VEHICLE_WEAPON_DOGFIGHTER_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DOGFIGHTER_MISSILE"),
                name = "VEHICLE_WEAPON_DOGFIGHTER_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_MOGUL_NOSE"),
                name = "VEHICLE_WEAPON_MOGUL_NOSE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_MOGUL_DUALNOSE"),
                name = "VEHICLE_WEAPON_MOGUL_DUALNOSE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_MOGUL_TURRET"),
                name = "VEHICLE_WEAPON_MOGUL_TURRET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_MOGUL_DUALTURRET"),
                name = "VEHICLE_WEAPON_MOGUL_DUALTURRET"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_ROGUE_MG"),
                name = "VEHICLE_WEAPON_ROGUE_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_ROGUE_CANNON"),
                name = "VEHICLE_WEAPON_ROGUE_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_ROGUE_MISSILE"),
                name = "VEHICLE_WEAPON_ROGUE_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BOMBUSHKA_DUALMG"),
                name = "VEHICLE_WEAPON_BOMBUSHKA_DUALMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BOMBUSHKA_CANNON"),
                name = "VEHICLE_WEAPON_BOMBUSHKA_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HAVOK_MINIGUN"),
                name = "VEHICLE_WEAPON_HAVOK_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_VIGILANTE_MG"),
                name = "VEHICLE_WEAPON_VIGILANTE_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_VIGILANTE_MISSILE"),
                name = "VEHICLE_WEAPON_VIGILANTE_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TURRET_LIMO"),
                name = "VEHICLE_WEAPON_TURRET_LIMO"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DUNE_MG"),
                name = "VEHICLE_WEAPON_DUNE_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DUNE_GRENADELAUNCHER"),
                name = "VEHICLE_WEAPON_DUNE_GRENADELAUNCHER"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DUNE_MINIGUN"),
                name = "VEHICLE_WEAPON_DUNE_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TAMPA_MISSILE"),
                name = "VEHICLE_WEAPON_TAMPA_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TAMPA_MORTAR"),
                name = "VEHICLE_WEAPON_TAMPA_MORTAR"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TAMPA_FIXEDMINIGUN"),
                name = "VEHICLE_WEAPON_TAMPA_FIXEDMINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TAMPA_DUALMINIGUN"),
                name = "VEHICLE_WEAPON_TAMPA_DUALMINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HALFTRACK_DUALMG"),
                name = "VEHICLE_WEAPON_HALFTRACK_DUALMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_HALFTRACK_QUADMG"),
                name = "VEHICLE_WEAPON_HALFTRACK_QUADMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_APC_CANNON"),
                name = "VEHICLE_WEAPON_APC_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_APC_MISSILE"),
                name = "VEHICLE_WEAPON_APC_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_APC_MG"),
                name = "VEHICLE_WEAPON_APC_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_ARDENT_MG"),
                name = "VEHICLE_WEAPON_ARDENT_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TECHNICAL_MINIGUN"),
                name = "VEHICLE_WEAPON_TECHNICAL_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_INSURGENT_MINIGUN"),
                name = "VEHICLE_WEAPON_INSURGENT_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TRAILER_QUADMG"),
                name = "VEHICLE_WEAPON_TRAILER_QUADMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TRAILER_MISSILE"),
                name = "VEHICLE_WEAPON_TRAILER_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_TRAILER_DUALAA"),
                name = "VEHICLE_WEAPON_TRAILER_DUALAA"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_NIGHTSHARK_MG"),
                name = "VEHICLE_WEAPON_NIGHTSHARK_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_OPPRESSOR_MG"),
                name = "VEHICLE_WEAPON_OPPRESSOR_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_OPPRESSOR_MISSILE"),
                name = "VEHICLE_WEAPON_OPPRESSOR_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_MOBILEOPS_CANNON"),
                name = "VEHICLE_WEAPON_MOBILEOPS_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_AKULA_TURRET_SINGLE"),
                name = "VEHICLE_WEAPON_AKULA_TURRET_SINGLE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_AKULA_MISSILE"),
                name = "VEHICLE_WEAPON_AKULA_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_AKULA_TURRET_DUAL"),
                name = "VEHICLE_WEAPON_AKULA_TURRET_DUAL"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_AKULA_MINIGUN"),
                name = "VEHICLE_WEAPON_AKULA_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_AKULA_BARRAGE"),
                name = "VEHICLE_WEAPON_AKULA_BARRAGE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_AVENGER_CANNON"),
                name = "VEHICLE_WEAPON_AVENGER_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BARRAGE_TOP_MG"),
                name = "VEHICLE_WEAPON_BARRAGE_TOP_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BARRAGE_TOP_MINIGUN"),
                name = "VEHICLE_WEAPON_BARRAGE_TOP_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BARRAGE_REAR_MG"),
                name = "VEHICLE_WEAPON_BARRAGE_REAR_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BARRAGE_REAR_MINIGUN"),
                name = "VEHICLE_WEAPON_BARRAGE_REAR_MINIGUN"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_BARRAGE_REAR_GL"),
                name = "VEHICLE_WEAPON_BARRAGE_REAR_GL"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_CHERNO_MISSILE"),
                name = "VEHICLE_WEAPON_CHERNO_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_COMET_MG"),
                name = "VEHICLE_WEAPON_COMET_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DELUXO_MG"),
                name = "VEHICLE_WEAPON_DELUXO_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_DELUXO_MISSILE"),
                name = "VEHICLE_WEAPON_DELUXO_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_KHANJALI_CANNON"),
                name = "VEHICLE_WEAPON_KHANJALI_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_KHANJALI_CANNON_HEAVY"),
                name = "VEHICLE_WEAPON_KHANJALI_CANNON_HEAVY"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_KHANJALI_MG"),
                name = "VEHICLE_WEAPON_KHANJALI_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_KHANJALI_GL"),
                name = "VEHICLE_WEAPON_KHANJALI_GL"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_REVOLTER_MG"),
                name = "VEHICLE_WEAPON_REVOLTER_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_WATER_CANNON"),
                name = "VEHICLE_WEAPON_WATER_CANNON"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SAVESTRA_MG"),
                name = "VEHICLE_WEAPON_SAVESTRA_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SUBCAR_MG"),
                name = "VEHICLE_WEAPON_SUBCAR_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SUBCAR_MISSILE"),
                name = "VEHICLE_WEAPON_SUBCAR_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_SUBCAR_TORPEDO"),
                name = "VEHICLE_WEAPON_SUBCAR_TORPEDO"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_THRUSTER_MG"),
                name = "VEHICLE_WEAPON_THRUSTER_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_THRUSTER_MISSILE"),
                name = "VEHICLE_WEAPON_THRUSTER_MISSILE"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_VISERIS_MG"),
                name = "VEHICLE_WEAPON_VISERIS_MG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_VOLATOL_DUALMG"),
                name = "VEHICLE_WEAPON_VOLATOL_DUALMG"
            },
            {
                hash = GetHashKey("VEHICLE_WEAPON_PLAYER_LASER"),
                name = "VEHICLE_WEAPON_PLAYER_LASER"
            }
        }
    },
    {
        class = 9,
        classStr = "Classe 9",
        type = "Explosifs Autres",
        list = {
            {
                hash = GetHashKey("GRENADE"),
                name = "GRENADE"
            },
            {
                hash = GetHashKey("GRENADELAUNCHER"),
                name = "GRENADELAUNCHER"
            },
            {
                hash = GetHashKey("STICKYBOMB"),
                name = "STICKYBOMB"
            },
            {
                hash = GetHashKey("MOLOTOV"),
                name = "MOLOTOV"
            },
            {
                hash = GetHashKey("ROCKET"),
                name = "ROCKET"
            },
            {
                hash = GetHashKey("TANKSHELL"),
                name = "TANKSHELL"
            },
            {
                hash = GetHashKey("HI_OCTANE"),
                name = "HI_OCTANE"
            },
            {
                hash = GetHashKey("CAR"),
                name = "CAR"
            },
            {
                hash = GetHashKey("PLANE"),
                name = "PLANE"
            },
            {
                hash = GetHashKey("PETROL_PUMP"),
                name = "PETROL_PUMP"
            },
            {
                hash = GetHashKey("BIKE"),
                name = "BIKE"
            },
            {
                hash = GetHashKey("DIR_STEAM"),
                name = "DIR_STEAM"
            },
            {
                hash = GetHashKey("DIR_FLAME"),
                name = "DIR_FLAME"
            },
            {
                hash = GetHashKey("DIR_WATER_HYDRANT"),
                name = "DIR_WATER_HYDRANT"
            },
            {
                hash = GetHashKey("DIR_GAS_CANISTER"),
                name = "DIR_GAS_CANISTER"
            },
            {
                hash = GetHashKey("BOAT"),
                name = "BOAT"
            },
            {
                hash = GetHashKey("SHIP_DESTROY"),
                name = "SHIP_DESTROY"
            },
            {
                hash = GetHashKey("TRUCK"),
                name = "TRUCK"
            },
            {
                hash = GetHashKey("BULLET"),
                name = "BULLET"
            },
            {
                hash = GetHashKey("SMOKEGRENADELAUNCHER"),
                name = "SMOKEGRENADELAUNCHER"
            },
            {
                hash = GetHashKey("SMOKEGRENADE"),
                name = "SMOKEGRENADE"
            },
            {
                hash = GetHashKey("BZGAS"),
                name = "BZGAS"
            },
            {
                hash = GetHashKey("FLARE"),
                name = "FLARE"
            },
            {
                hash = GetHashKey("GAS_CANISTER"),
                name = "GAS_CANISTER"
            },
            {
                hash = GetHashKey("EXTINGUISHER"),
                name = "EXTINGUISHER"
            },
            {
                hash = GetHashKey("PROGRAMMABLEAR"),
                name = "PROGRAMMABLEAR"
            },
            {
                hash = GetHashKey("TRAIN"),
                name = "TRAIN"
            },
            {
                hash = GetHashKey("BARREL"),
                name = "BARREL"
            },
            {
                hash = GetHashKey("PROPANE"),
                name = "PROPANE"
            },
            {
                hash = GetHashKey("BLIMP"),
                name = "BLIMP"
            },
            {
                hash = GetHashKey("DIR_FLAME_EXPLODE"),
                name = "DIR_FLAME_EXPLODE"
            },
            {
                hash = GetHashKey("TANKER"),
                name = "TANKER"
            },
            {
                hash = GetHashKey("PLANE_ROCKET"),
                name = "PLANE_ROCKET"
            },
            {
                hash = GetHashKey("VEHICLE_BULLET"),
                name = "VEHICLE_BULLET"
            },
            {
                hash = GetHashKey("GAS_TANK"),
                name = "GAS_TANK"
            },
            {
                hash = GetHashKey("WEAPON_EXPLOSION"),
                name = "WEAPON_EXPLOSION"
            },
            {
                hash = GetHashKey("FIREWORK"),
                name = "FIREWORK"
            }
        }
    },
    {
        class = 10,
        classStr = "Classe 10",
        type = "Autres / Uknown",
        list = {
            {
                hash = GetHashKey("WEAPON_RUN_OVER_BY_CAR"),
                name = "WEAPON_RUN_OVER_BY_CAR"
            },
            {
                hash = GetHashKey("WEAPON_RAMMED_BY_CAR"),
                name = "WEAPON_RAMMED_BY_CAR"
            },
            {
                hash = GetHashKey("WEAPON_STINGER"),
                name = "WEAPON_STINGER"
            },
            {
                hash = GetHashKey("OBJECT"),
                name = "OBJECT"
            },
            {
                hash = GetHashKey("AMMO_RPG"),
                name = "AMMO_RPG"
            },
            {
                hash = GetHashKey("AMMO_TANK"),
                name = "AMMO_TANK"
            },
            {
                hash = GetHashKey("AMMO_SPACE_ROCKET"),
                name = "AMMO_SPACE_ROCKET"
            },
            {
                hash = GetHashKey("AMMO_PLAYER_LASER"),
                name = "AMMO_PLAYER_LASER"
            },
            {
                hash = GetHashKey("AMMO_ENEMY_LASER"),
                name = "AMMO_ENEMY_LASER"
            },
            {
                hash = GetHashKey("WEAPON_PASSENGER_ROCKET"),
                name = "WEAPON_PASSENGER_ROCKET"
            },
            {
                hash = GetHashKey("WEAPON_AIRSTRIKE_ROCKET"),
                name = "WEAPON_AIRSTRIKE_ROCKET"
            },
            {
                hash = GetHashKey("WEAPON_HELI_CRASH"),
                name = "WEAPON_HELI_CRASH"
            },
            {
                hash = GetHashKey("WEAPON_HIT_BY_WATER_CANNON"),
                name = "WEAPON_HIT_BY_WATER_CANNON"
            },
            {
                hash = GetHashKey("WEAPON_EXHAUSTION"),
                name = "WEAPON_EXHAUSTION"
            },
            {
                hash = GetHashKey("WEAPON_ELECTRIC_FENCE"),
                name = "WEAPON_ELECTRIC_FENCE"
            },
            {
                hash = GetHashKey("WEAPON_BLEEDING"),
                name = "WEAPON_BLEEDING"
            },
            {
                hash = GetHashKey("WEAPON_DROWNING_IN_VEHICLE"),
                name = "WEAPON_DROWNING_IN_VEHICLE"
            },
            {
                hash = GetHashKey("WEAPON_DROWNING"),
                name = "WEAPON_DROWNING"
            },
            {
                hash = GetHashKey("WEAPON_BARBED_WIRE"),
                name = "WEAPON_BARBED_WIRE"
            },
            {
                hash = GetHashKey("WEAPON_VEHICLE_ROCKET"),
                name = "WEAPON_VEHICLE_ROCKET"
            },
            {
                hash = GetHashKey("WEAPON_AIR_DEFENCE_GUN"),
                name = "WEAPON_AIR_DEFENCE_GUN"
            },
            {
                hash = GetHashKey("WEAPON_ANIMAL"),
                name = "WEAPON_ANIMAL"
            },
            {
                hash = GetHashKey("WEAPON_COUGAR"),
                name = "WEAPON_COUGAR"
            },
            {
                hash = GetHashKey("WEAPON_FALL"),
                name = "WEAPON_FALL"
            }
        }
    }
}

local whitelistedWeapons = {
    GetHashKey("WEAPON_STUNGUN"),
    GetHashKey("weapon_flaregun"),
    GetHashKey("weapon_fireextinguisher"),
    GetHashKey("weapon_firework"),
    GetHashKey("weapon_combatpdw"),
    GetHashKey("weapon_paintball"),
    GetHashKey("weapon_staff"),
    GetHashKey("weapon_ltl"),
    GetHashKey("WEAPON_ASVAL")
}

local function isPolice()
    return exports.plouffe_lib:hasGroup("police")
end

local function isEms()
    return exports.plouffe_lib:hasGroup("ambulance")
end

local function startScript()
    TriggerEvent('ooc_core:getCore', function(Core)
        while not Core.Player:IsPlayerLoaded() do
            Wait(500)
        end

        playerData = Core.Player:GetPlayerData()
    end)
end

local function blipThread(newBlip, radius)
    if #activeBlips > 0 then
        table.insert(activeBlips, {blip = newBlip, alpha = radius and 150 or 255, radius = radius or nil})
        return
    end

    table.insert(activeBlips, {blip = newBlip, alpha = radius and 150 or 255, radius = radius or nil})

    CreateThread(function()
        while #activeBlips > 0 do
            Wait(1000)

            for k,v in pairs(activeBlips) do
                if v.alpha <= 0 then
                    RemoveBlip(v.blip)
                    table.remove(activeBlips, k)
                else
                    v.alpha = v.alpha - 2
                    SetBlipAlpha(v.blip, v.alpha)
                end
            end
        end
    end)
end

local function createBlip(blipData,coords)
    local blip = nil

    if blipData.radius then
        blip = AddBlipForRadius(coords.x, coords.y, coords.z, blipData.radius)
    else
        blip = AddBlipForCoord(coords)
        SetBlipScale(blip, blipData.scale or 1.0)
        SetBlipAsShortRange(blip, true)
    end

    SetBlipAlpha(blip, blipData.radius and 150 or 255)
    SetBlipSprite(blip, blipData.sprite or 137)
    SetBlipColour(blip, blipData.color or 1)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(blipData.name)
    EndTextCommandSetBlipName(blip)

    for k,v in pairs(activeBlips) do
        local blipCoords = GetBlipInfoIdCoord(v.blip)
        local dstCheck = #(blipCoords - coords)

        if dstCheck <= 10 and v.blip ~= blip then
            RemoveBlip(v.blip)
            table.remove(activeBlips, k)
        end
    end

    blipThread(blip, blipData.radius)
end

local function getStreetName(coords)
    local coords = coords or GetEntityCoords(PlayerPedId())
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(coords.x,coords.y,coords.z, currentStreetHash, intersectStreetHash)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    local zone = tostring(GetNameOfZone(coords))
    local playerStreetsLocation = zoneNames[tostring(zone)]

    if not zone then
        zone = "UNKNOWN"
        zoneNames['UNKNOWN'] = zone
    elseif not zoneNames[tostring(zone)] then
        local undefinedZone = zone .. " " .. coords.x .. " " .. coords.y .. " " .. coords.z
        zoneNames[tostring(zone)] = "Undefined Zone"
    end

    if intersectStreetName ~= nil and intersectStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. " | " .. intersectStreetName .. " | " .. zoneNames[tostring(zone)]
    elseif currentStreetName ~= nil and currentStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. " | " .. zoneNames[tostring(zone)]
    else
        playerStreetsLocation = zoneNames[tostring(zone)]
    end

    return playerStreetsLocation
end

local function getCurrentVehicleAlt(vehicle)
    local vehicle = vehicle or GetVehiclePedIsIn(PlayerPedId())
    local heigh = GetEntityHeightAboveGround(vehicle)
    local alt = string.format("%.1f", heigh * 3.28084)

    return alt
end

local function isCoordsInBlacklistGunshotZone(coords)
    for k,v in pairs(blacklistGunshotZones) do
        if #(coords - v.coords) < v.maxDst then
            return true
        end
    end
    return false
end

local function getVehicleInfo(vehicle)
    local vehicle = vehicle or GetVehiclePedIsIn(PlayerPedId())
    local vehModel = GetEntityModel(vehicle)
    local vehName = GetDisplayNameFromVehicleModel(vehModel)
    local vehNameNameText = GetLabelText(vehName)
    local plate = GetVehicleNumberPlateText(vehicle)
    local primary, secondary = GetVehicleColours(vehicle)

    return vehNameNameText, plate, colorNames[primary], colorNames[secondary]
end
exports("GetVehicleInfo", getVehicleInfo)

local function getWeaponClass(weapon)
    local weapon = weapon or currentWeapon

    if not weapon or not weaponsClass[weapon] then
        return nil
    end

    return weaponsClass[weapon].info
end
exports("GetWeaponClass", getWeaponClass)

local function sendAlert(index,vehicle,delay)
    if (type(index) == "string" and not alerts[index]) or type(index) == "number" then
        print(("Alerte invalide %s"):format(index))
        return
    end

    local alert
    local alertData = {}
    local vehicleModel, plate, primaryColor, secondaryColor
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    if type(index) == "table" then
        alert = index
    else
        alert = alerts[index]
    end

    if alert.vehicle then
        vehicleModel, plate, primaryColor, secondaryColor = getVehicleInfo(vehicle)
    end

    if alert.randomizeCoords then
        pedCoords = vector3(math.random(-75, 75) + pedCoords.x, math.random(-75, 75) + pedCoords.y, pedCoords.z)
    end

    local alertData = {
        index = index,
        coords = pedCoords,
        job = alert.job,
        code = alert.code or "10-0",
        name = alert.name or "Inconnue",
        location = alert.street and getStreetName() or nil,
        style = alert.style or nil,
        fa = alert.fa or "fa-exclamation-triangle",
        weapon = alert.weapon and isArmed and getWeaponClass() or nil,
        model = alert.vehicle and vehicleModel or nil,
        plate = alert.vehicle and alert.plate and plate or nil,
        color = alert.vehicle and primaryColor or nil,
        color2 = alert.vehicle and secondaryColor or nil,
        altitude = alert.altitude and getCurrentVehicleAlt() or nil
    }

    if delay then
        CreateThread(function()
            Wait(delay)
            TriggerServerEvent('plouffe_dispatch:server:sendAlert', alertData)
        end)
    else
        TriggerServerEvent('plouffe_dispatch:server:sendAlert', alertData)
    end
end
exports("SendAlert", sendAlert)

local function inVehicleThread()
    CreateThread(function()
        local emergencyVehicleInterval = 1000 * 10
        local lastEmergencyAlert = 0

        local flyingVehicleInterval = 1000 * 10
        local lastFlyingAlert = 0

        while inVehicle do
            local sleepTimer = 1000
            local ped = PlayerPedId()
            local class = GetVehicleClass(vehicleId)
            local driver = GetPedInVehicleSeat(vehicleId, -1)
            local time = GetGameTimer()

            if driver == ped and class == 18 and GetIsVehicleEngineRunning(vehicleId) and not isPolice() and time - lastEmergencyAlert > emergencyVehicleInterval then
                lastEmergencyAlert = time
                sendAlert("StolenCopCar")
            end

            if class == 15 or class == 16 then
                if time - lastFlyingAlert > flyingVehicleInterval and not isPolice() then
                    local height = GetEntityHeightAboveGround(vehicleId)

                    if (class == 15 and height >= 140) or (class == 16 and height >= 190) then
                        lastFlyingAlert = time

                        if class == 15 then
                            sendAlert("FlyingHeli")
                        else
                            sendAlert("FlyingPlane")
                        end
                    end
                end
            end

            Wait(sleepTimer)
        end
    end)
end

local function isArmnedThread()
    CreateThread(function()
        local lastAlert = 0
        local interval = 1000 * 60

        while isArmed do
            local sleepTimer = 1000
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            local time = GetGameTimer()

            if not whitelistedWeapons[currentWeapon] and not IsPedCurrentWeaponSilenced(ped) and time - lastAlert > interval and not isCoordsInBlacklistGunshotZone(pedCoords) then
                sleepTimer = 0

                if IsPedShooting(ped) then
                    local randi = math.random(0,100)

                    if randi <= 40 then
                        lastAlert = time

                        if inVehicle then
                            sendAlert('VehicleGunShot', nil, 10000)
                        else
                            sendAlert('GunShot', nil, 10000)
                        end
                    end
                end
            end

            Wait(sleepTimer)
        end
    end)
end

local function inNoWeaponsZonesThread()
    if inNoWeaponsZones then
        return
    end

    inNoWeaponsZones = true

    local lastAlert = 0
    local alertInterval = 1000 * 30

    CreateThread(function()
        while inNoWeaponsZones do
            if isArmed and currentWeapon ~= GetHashKey("weapon_fireextinguisher") and not isPolice() then
                if GetGameTimer() - lastAlert > alertInterval then
                    sendAlert("PublicArmedZone")
                    lastAlert = GetGameTimer()
                end
            end
            Wait(2500)
        end
    end)
end

RegisterNetEvent("plouffe_dispatch:deadCop", function()
    if not myBadge then
        exports.ooc_dialog:Open({
            rows = {
                {
                    id = 0,
                    txt = "Votre matricule "
                }
            }
        }, function(data)
            if not data then return end

            if not data[1].input then
                return Utils:Notify("error", "Informations invalide", 5000)
            end

            myBadge = tostring(data[1].input)

            alerts.CopDown.name = "URGENT: ["..tostring(myBadge).."] est au sol"
        end)
    end

    if GetGameTimer() - lastCopDown > copDownInterval then
        sendAlert('CopDown')
        lastCopDown = GetGameTimer()
    end
end)

RegisterNetEvent('plouffe_dispatch:inNoWeaponZone', function()
    inNoWeaponsZonesThread()
end)

RegisterNetEvent('plouffe_dispatch:leftNoWeaponZone', function()
    inNoWeaponsZones = false
end)

AddEventHandler('plouffe_lib:setGroup', function(data)
    playerData[data.type] = data
end)

RegisterNetEvent("plouffe_lib:inVehicle", function(Vehicle, id)
    inVehicle, vehicleId = Vehicle, id
    inVehicleThread()
end)

RegisterNetEvent("plouffe_lib:hasWeapon", function(armed,weaponHash)
    isArmed, currentWeapon = armed, weaponHash
    isArmnedThread()
end)

RegisterNetEvent("plouffe_dispatch:client:sendAlert", function(alert)
    if exports.plouffe_lib:hasGroup(alert.job) then
        if playsound then
            if alert.soundUrl then
                local name = ("./sounds/%s"):format(alert.soundFile)
                local url = ("./sounds/%s.ogg"):format(alert.soundFile)

                exports.xsound:PlayUrl("Alert", alert.soundUrl , 0.1)
            elseif alert.soundFile then
                local name = ("./sounds/%s"):format(alert.soundFile)
                local url = ("./sounds/%s.ogg"):format(alert.soundFile)

                exports.xsound:PlayUrl(name, url, 0.1)
            end
        end

        alert.location = alert.location or getStreetName(alert.coords)

        if alert.blip then
            createBlip(alert.blip,alert.coords)
        elseif alerts[alert.index] and alerts[alert.index].blip then
            createBlip(alerts[alert.index].blip,alert.coords)
        end

        lastAlertId = alert.id
        activeAlerts[alert.id] = alert

        SendNUIMessage({notification = alert})
    end
end)

RegisterNetEvent("plouffe_dispatch:client:spawned", function(trackedJobs)
    for job,v in pairs(trackedJobs) do
        for playerId,playerData in pairs(v) do
            if officiersJobs[job] then
                local officiersData = {}
                table.insert(officiersData, playerData)
                loggedInOfficiers[playerData.id] = playerData
                SendNUIMessage({officiers = officiersData})
                playerData.action = "Entré en service"
                SendNUIMessage({service = playerData})
            elseif emsJobs[job] then
                loggedInEms[playerData.id] = playerData
                SendNUIMessage({ems = playerData})
                playerData.action = "Entré en service"
                SendNUIMessage({service = playerData})
            end
        end
    end

end)

RegisterNetEvent("plouffe_dispatch:client:loggedIn", function(targetPlayerData, job)

    if officiersJobs[job] then
        local officiersData = {}
        table.insert(officiersData, targetPlayerData)
        loggedInOfficiers[targetPlayerData.id] = targetPlayerData
        SendNUIMessage({officiers = officiersData})
        targetPlayerData.action = "Entré en service"
        SendNUIMessage({service = targetPlayerData})
    elseif emsJobs[job] then
        loggedInEms[targetPlayerData.id] = targetPlayerData
        SendNUIMessage({ems = targetPlayerData})
        targetPlayerData.action = "Entré en service"
        SendNUIMessage({service = targetPlayerData})
    end
end)

RegisterNetEvent("plouffe_dispatch:client:loggedOut", function(targetPlayerData)
    SendNUIMessage({removeOfficier = targetPlayerData.id})

    loggedInOfficiers[targetPlayerData.id] = nil
    loggedInEms[targetPlayerData.id] = nil

    targetPlayerData.action = "Fin de service"
    targetPlayerData.style = "offservice"

    SendNUIMessage({service = targetPlayerData})
end)

RegisterNetEvent("plouffe_dispatch:client:updateTargetRadio", function(playerId,radio)
    SendNUIMessage({radio = {id = tonumber(playerId), radio = radio}})
end)

RegisterNUICallback("close",function()
    show = false
    SendNUIMessage({show = show})
    SetNuiFocus(false, false)
end)

RegisterNUICallback("refreshofficiers", function()
    print("refreshofficiers")
end)

RegisterNUICallback("switchsound", function()
    playsound = not playsound
end)

RegisterNUICallback("clearAllNotifications", function()
    activeAlerts = {}
end)

RegisterNUICallback("removeNotification", function(data)
    if not data then
        activeAlerts = {}
        return
    end
    activeAlerts[tonumber(data.id)] = nil
end)

RegisterNUICallback("setgpsroute", function(data)
    SetNewWaypoint(activeAlerts[tonumber(data.id)].coords.x, activeAlerts[tonumber(data.id)].coords.y)
end)

RegisterCommand("+show-basic-ui", function(s,a,r)
    if not isPolice() or GetEntityAlpha(PlayerPedId()) <= 60 then
        return
    end

    holding = true

    show = not show

    Wait(250)

    if holding then
        show = true
        SetNuiFocus(true, true)
        SetCursorLocation(0.9,0.05)
        SendNUIMessage({show = show, complet = true})
    else
        SendNUIMessage({show = show})
    end
end)

RegisterCommand("-show-basic-ui", function(s,a,r)
    holding = false
end)
RegisterKeyMapping("+show-basic-ui", "Show dispatch ui", "keyboard", "z")

RegisterCommand("answerLast", function(s,a,r)
    if activeAlerts and activeAlerts[tonumber(lastAlertId)] then
        SetNewWaypoint(activeAlerts[tonumber(lastAlertId)].coords.x, activeAlerts[tonumber(lastAlertId)].coords.y)
    end
end)
RegisterKeyMapping("answerLast", "Repondre au dernier call", "keyboard", "6")

CreateThread(function()
    local tempdata = {}

    for k,v in pairs(whitelistedWeapons) do
        tempdata[v] = true
    end

    whitelistedWeapons = tempdata

    for id, info in pairs(weapons) do
        for k, v in pairs(info.list) do
            weaponsClass[v.hash] = {
                class = info.class,
                info = info.classStr .. " / " .. info.type,
                name = v.name,
                hash = v.hash
            }
        end
    end

    for k,v in pairs(exportsZones) do
        exports.plouffe_lib:ValidateZoneData(v)
    end

    startScript()
end)