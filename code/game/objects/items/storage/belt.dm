/obj/item/storage/belt
	name = "пояс"
	desc = "Может хранить разные штуки."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utility"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("шлёпает", "учит", "совращает")
	attack_verb_simple = list("шлёпает", "учит", "совращает")
	max_integrity = 300
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	var/content_overlays = FALSE //If this is true, the belt will gain overlays based on what it's holding

/obj/item/storage/belt/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins belting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/storage/belt/update_overlays()
	. = ..()
	if(content_overlays)
		for(var/obj/item/I in contents)
			. += I.get_belt_overlay()

/obj/item/storage/belt/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/belt/utility
	name = "пояс с инструментами" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Хранит инструменты."
	icon_state = "utility"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	content_overlays = TRUE
	custom_premium_price = 300
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbelt_pickup.ogg'

/obj/item/storage/belt/utility/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21
	STR.set_holdable(list(
		/obj/item/multitool/tricorder,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/holosign_creator/atmos,
		/obj/item/holosign_creator/engineering,
		/obj/item/forcefield_projector,
		/obj/item/assembly/signaler,
		/obj/item/lightreplacer,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/inducer,
		/obj/item/plunger,
		/obj/item/airlock_painter,
		/obj/item/pipe_painter
		))

/obj/item/storage/belt/utility/chief
	name = "пояс старшего инженера" //"the Chief Engineer's toolbelt", because "Chief Engineer's toolbelt" is not a proper noun
	desc = "Хранит инструменты, классно смотрится."
	icon_state = "utility_ce"
	inhand_icon_state = "utility_ce"
	worn_icon_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full/PopulateContents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)//This can be changed if this is too much
	new /obj/item/multitool/tricorder(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/analyzer(src)
	//much roomier now that we've managed to remove two tools

/obj/item/storage/belt/utility/full/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

/obj/item/storage/belt/utility/full/engi/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)


/obj/item/storage/belt/utility/atmostech/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/extinguisher/mini(src)

/obj/item/storage/belt/utility/syndicate/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench/combat(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)
	new /obj/item/inducer/syndicate(src)

/obj/item/storage/belt/medical
	name = "медицинский пояс"
	desc = "Может хранить различные медицинские штуки."
	icon_state = "medical"
	inhand_icon_state = "medical"
	worn_icon_state = "medical"

/obj/item/storage/belt/medical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21
	STR.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medigel,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves/,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/surgical_drapes, //for true paramedics
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical,
		/obj/item/construction/plumbing,
		/obj/item/plunger,
		/obj/item/reagent_containers/spray,
		/obj/item/shears,
		/obj/item/stack/sticky_tape //surgical tape
		))

/obj/item/storage/belt/medical/paramedic/PopulateContents()
	new /obj/item/sensor_device(src)
	new /obj/item/pinpointer/crew/prox(src)
	new /obj/item/stack/medical/gauze/twelve(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/stack/medical/bone_gel(src)
	new /obj/item/stack/sticky_tape/surgical(src)
	new /obj/item/reagent_containers/glass/bottle/formaldehyde(src)
	update_icon()

/obj/item/storage/belt/security
	name = "пояс офицера"
	desc = "Может хранить наручники, флэшки, но не преступников."
	icon_state = "security"
	inhand_icon_state = "security"//Could likely use a better one.
	worn_icon_state = "security"
	content_overlays = TRUE

/obj/item/storage/belt/security/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/melee/baton,
		/obj/item/melee/classic_baton,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife/combat,
		/obj/item/flashlight/seclite,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/holosign_creator/security
		))

/obj/item/storage/belt/security/full/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/loaded(src)
	update_icon()

/obj/item/storage/belt/security/webbing
	name = "разгрузка офицера"
	desc = "Уникальный и универсальный нагрудник, способный удерживать снаряжение офицера."
	icon_state = "securitywebbing"
	inhand_icon_state = "securitywebbing"
	worn_icon_state = "securitywebbing"
	content_overlays = FALSE
	custom_premium_price = 900

/obj/item/storage/belt/security/webbing/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6

/obj/item/storage/belt/mining
	name = "разгрузка исследователя"
	desc = "Универсальная разгрузка, которую ценят как шахтеры, так и охотники."
	icon_state = "explorer1"
	inhand_icon_state = "explorer1"
	worn_icon_state = "explorer1"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/mining/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 20
	STR.set_holdable(list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/shovel,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/sinew,
		/obj/item/stack/sheet/bone,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/reagent_containers/food/drinks/bottle,
		/obj/item/stack/medical,
		/obj/item/kitchen/knife,
		/obj/item/reagent_containers/hypospray,
		/obj/item/gps,
		/obj/item/storage/bag/ore,
		/obj/item/survivalcapsule,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/ore,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/organ/regenerative_core,
		/obj/item/wormhole_jaunter,
		/obj/item/stack/marker_beacon,
		/obj/item/key/lasso
		))


/obj/item/storage/belt/mining/vendor
	contents = newlist(/obj/item/survivalcapsule)

/obj/item/storage/belt/mining/alt
	icon_state = "explorer2"
	inhand_icon_state = "explorer2"
	worn_icon_state = "explorer2"

/obj/item/storage/belt/mining/primitive
	name = "пояс охотника"
	desc = "Универсальный ремень, сотканный из сухожилий."
	icon_state = "ebelt"
	inhand_icon_state = "ebelt"
	worn_icon_state = "ebelt"

/obj/item/storage/belt/mining/primitive/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5

/obj/item/storage/belt/soulstone
	name = "пояс для камней душ"
	desc = "Предназначен для облегчения доступа к осколкам во время боя, чтобы не пропустить ни одного вражеского духа."
	icon_state = "soulstonebelt"
	inhand_icon_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"

/obj/item/storage/belt/soulstone/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(
		/obj/item/soulstone
		))

/obj/item/storage/belt/soulstone/full/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone(src)

/obj/item/storage/belt/soulstone/full/chappy/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone/anybody/chaplain(src)

/obj/item/storage/belt/champion
	name = "пояс чемпиона"
	desc = "Доказывает миру, что ты сильнее всех!"
	icon_state = "championbelt"
	inhand_icon_state = "championbelt"
	worn_icon_state = "championbelt"
	custom_materials = list(/datum/material/gold=400)

/obj/item/storage/belt/champion/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.set_holdable(list(
		/obj/item/clothing/mask/luchador
		))

/obj/item/storage/belt/military
	name = "разгрузка"
	desc = "Набор тактических ременьев, которые носят осадные группы синдиката."
	icon_state = "militarywebbing"
	inhand_icon_state = "militarywebbing"
	worn_icon_state = "militarywebbing"
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/military/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/military/snack
	name = "тактическая закусочная"

/obj/item/storage/belt/military/snack/Initialize()
	. = ..()
	var/sponsor = pick("DonkCo", "Waffle Co.", "Roffle Co.", "Gorlax Marauders", "Tiger Cooperative")
	desc = "Набор закусок, которые носят спортсмены спортивного отдела ВР [sponsor]."

/obj/item/storage/belt/military/snack/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.set_holdable(list(
		/obj/item/reagent_containers/food/snacks,
		/obj/item/reagent_containers/food/drinks
		))

	var/amount = 5
	var/rig_snacks
	while(contents.len <= amount)
		rig_snacks = pick(list(
		/obj/item/reagent_containers/food/snacks/candy,
		/obj/item/reagent_containers/food/drinks/dry_ramen,
		/obj/item/reagent_containers/food/snacks/chips,
		/obj/item/reagent_containers/food/snacks/sosjerky,
		/obj/item/reagent_containers/food/snacks/syndicake,
		/obj/item/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/reagent_containers/food/snacks/nachos,
		/obj/item/reagent_containers/food/snacks/cheesynachos,
		/obj/item/reagent_containers/food/snacks/cubannachos,
		/obj/item/reagent_containers/food/snacks/nugget,
		/obj/item/reagent_containers/food/snacks/spaghetti/pastatomato,
		/obj/item/reagent_containers/food/snacks/rofflewaffles,
		/obj/item/reagent_containers/food/snacks/donkpocket,
		/obj/item/reagent_containers/food/drinks/soda_cans/cola,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind,
		/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb,
		/obj/item/reagent_containers/food/drinks/soda_cans/starkist,
		/obj/item/reagent_containers/food/drinks/soda_cans/space_up,
		/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game,
		/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime,
		/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola
		))
		new rig_snacks(src)

/obj/item/storage/belt/military/abductor
	name = "пояс агента"
	desc = "Пояс, используемый агентами похитителей."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	inhand_icon_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/military/abductor/full/PopulateContents()
	new /obj/item/screwdriver/abductor(src)
	new /obj/item/wrench/abductor(src)
	new /obj/item/weldingtool/abductor(src)
	new /obj/item/crowbar/abductor(src)
	new /obj/item/wirecutters/abductor(src)
	new /obj/item/multitool/abductor(src)
	new /obj/item/stack/cable_coil(src)

/obj/item/storage/belt/military/army
	name = "армейский пояс"
	desc = "Пояс, используемый вооруженными силами."
	icon_state = "grenadebeltold"
	inhand_icon_state = "security"
	worn_icon_state = "grenadebeltold"

/obj/item/storage/belt/military/assault
	name = "штурмовой пояс"
	desc = "Тактический штурмовой пояс."
	icon_state = "assaultbelt"
	inhand_icon_state = "security"
	worn_icon_state = "assault"

/obj/item/storage/belt/military/assault/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6

/obj/item/storage/belt/grenade
	name = "пояс гренадёра"
	desc = "Пояс хранящий гранаты. Бабах."
	icon_state = "grenadebeltnew"
	inhand_icon_state = "security"
	worn_icon_state = "grenadebeltnew"

/obj/item/storage/belt/grenade/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 30
	STR.display_numerical_stacking = TRUE
	STR.max_combined_w_class = 60
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/grenade,
		/obj/item/screwdriver,
		/obj/item/lighter,
		/obj/item/multitool,
		/obj/item/reagent_containers/food/drinks/bottle/molotov,
		/obj/item/grenade/c4,
		/obj/item/reagent_containers/food/snacks/grown/cherry_bomb,
		/obj/item/reagent_containers/food/snacks/grown/firelemon
		))

/obj/item/storage/belt/grenade/full/PopulateContents()
	var/static/items_inside = list(
		/obj/item/grenade/flashbang = 1,
		/obj/item/grenade/smokebomb = 4,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/grenade/frag = 10,
		/obj/item/grenade/gluon = 4,
		/obj/item/grenade/chem_grenade/incendiary = 2,
		/obj/item/grenade/chem_grenade/facid = 1,
		/obj/item/grenade/syndieminibomb = 2,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1)
	generate_items_inside(items_inside,src)


/obj/item/storage/belt/wands
	name = "пояс для посохов"
	desc = "Ремень, предназначенный для удержания различных силовых стержней. Настоящая задница экзотической волшебной пачки."
	icon_state = "soulstonebelt"
	inhand_icon_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"

/obj/item/storage/belt/wands/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(
		/obj/item/gun/magic/wand
		))

/obj/item/storage/belt/wands/full/PopulateContents()
	new /obj/item/gun/magic/wand/death(src)
	new /obj/item/gun/magic/wand/resurrection(src)
	new /obj/item/gun/magic/wand/polymorph(src)
	new /obj/item/gun/magic/wand/teleport(src)
	new /obj/item/gun/magic/wand/door(src)
	new /obj/item/gun/magic/wand/fireball(src)

	for(var/obj/item/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

/obj/item/storage/belt/janitor
	name = "убор-пояс"
	desc = "На ремне хранится большинство принадлежностей для уборки."
	icon_state = "janibelt"
	inhand_icon_state = "janibelt"
	worn_icon_state = "janibelt"

/obj/item/storage/belt/janitor/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_NORMAL // Set to this so the  light replacer can fit.
	STR.set_holdable(list(
		/obj/item/grenade/chem_grenade,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/holosign_creator,
		/obj/item/forcefield_projector,
		/obj/item/key/janitor,
		/obj/item/clothing/gloves,
		/obj/item/melee/flyswatter,
		/obj/item/assembly/mousetrap,
		/obj/item/paint/paint_remover,
		/obj/item/pushbroom
		))

/obj/item/storage/belt/janitor/full/PopulateContents()
	new /obj/item/lightreplacer(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/soap/nanotrasen(src)
	new /obj/item/holosign_creator(src)
	new /obj/item/melee/flyswatter(src)

/obj/item/storage/belt/bandolier
	name = "бандольер"
	desc = "Бандольером для хранения боеприпасов к дробовикам."
	icon_state = "bandolier"
	inhand_icon_state = "bandolier"
	worn_icon_state = "bandolier"

/obj/item/storage/belt/bandolier/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 18
	STR.max_combined_w_class = 18
	STR.display_numerical_stacking = TRUE
	STR.set_holdable(list(
		/obj/item/ammo_casing/shotgun
		))

/obj/item/storage/belt/fannypack
	name = "рюкзачок"
	desc = "Унылый рюкзак для хранения мелких вещей."
	icon_state = "fannypack_leather"
	inhand_icon_state = "fannypack_leather"
	worn_icon_state = "fannypack_leather"
	dying_key = DYE_REGISTRY_FANNYPACK
	custom_price = 100

/obj/item/storage/belt/fannypack/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/fannypack/black
	name = "чёрный рюкзачок"
	icon_state = "fannypack_black"
	inhand_icon_state = "fannypack_black"
	worn_icon_state = "fannypack_black"

/obj/item/storage/belt/fannypack/red
	name = "красный рюкзачок"
	icon_state = "fannypack_red"
	inhand_icon_state = "fannypack_red"
	worn_icon_state = "fannypack_red"

/obj/item/storage/belt/fannypack/purple
	name = "фиолетовый рюкзачок"
	icon_state = "fannypack_purple"
	inhand_icon_state = "fannypack_purple"
	worn_icon_state = "fannypack_purple"

/obj/item/storage/belt/fannypack/blue
	name = "синий рюкзачок"
	icon_state = "fannypack_blue"
	inhand_icon_state = "fannypack_blue"
	worn_icon_state = "fannypack_blue"

/obj/item/storage/belt/fannypack/orange
	name = "оранжевый рюкзачок"
	icon_state = "fannypack_orange"
	inhand_icon_state = "fannypack_orange"
	worn_icon_state = "fannypack_orange"

/obj/item/storage/belt/fannypack/white
	name = "белый рюкзачок"
	icon_state = "fannypack_white"
	inhand_icon_state = "fannypack_white"
	worn_icon_state = "fannypack_white"

/obj/item/storage/belt/fannypack/green
	name = "зелёный рюкзачок"
	icon_state = "fannypack_green"
	inhand_icon_state = "fannypack_green"
	worn_icon_state = "fannypack_green"

/obj/item/storage/belt/fannypack/pink
	name = "розовый рюкзачок"
	icon_state = "fannypack_pink"
	inhand_icon_state = "fannypack_pink"
	worn_icon_state = "fannypack_pink"

/obj/item/storage/belt/fannypack/cyan
	name = "голубой рюкзачок"
	icon_state = "fannypack_cyan"
	inhand_icon_state = "fannypack_cyan"
	worn_icon_state = "fannypack_cyan"

/obj/item/storage/belt/fannypack/yellow
	name = "жёлтый рюкзачок"
	icon_state = "fannypack_yellow"
	inhand_icon_state = "fannypack_yellow"
	worn_icon_state = "fannypack_yellow"

/obj/item/storage/belt/sabre
	name = "ножны сабли"
	desc = "Декоративные ножны, предназначенные для хранения сабли офицера."
	icon_state = "sheath"
	inhand_icon_state = "sheath"
	worn_icon_state = "sheath"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/sabre/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.set_holdable(list(
		/obj/item/melee/sabre
		))

/obj/item/storage/belt/sabre/examine(mob/user)
	. = ..()
	. += "<hr>"
	if(length(contents))
		. += "<span class='notice'>Alt-клик, чтобы немедленно достать саблю.</span>"

/obj/item/storage/belt/sabre/AltClick(mob/user)
	if(!iscarbon(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message("<span class='notice'>[user] достаёт [I] из [src].</span>", "<span class='notice'>Достаю [I] из [src].</span>")
		user.put_in_hands(I)
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] пустой!</span>")

/obj/item/storage/belt/sabre/update_icon_state()
	icon_state = initial(inhand_icon_state)
	inhand_icon_state = initial(inhand_icon_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		inhand_icon_state += "-sabre"
		worn_icon_state += "-sabre"

/obj/item/storage/belt/sabre/PopulateContents()
	new /obj/item/melee/sabre(src)
	update_icon()

/obj/item/storage/belt/plant
	name = "botanical belt"
	desc = "A belt used to hold most hydroponics supplies. Suprisingly, not green."
	icon_state = "plantbelt"
	inhand_icon_state = "plantbelt"
	worn_icon_state = "plantbelt"
	content_overlays = TRUE

/obj/item/storage/belt/plant/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/plant_analyzer,
		/obj/item/seeds,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/cultivator,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/hatchet,
		/obj/item/graft,
		/obj/item/secateurs,
		/obj/item/geneshears,
		/obj/item/shovel/spade,
		/obj/item/gun/energy/floragun
		))
