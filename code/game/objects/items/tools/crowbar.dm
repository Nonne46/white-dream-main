/obj/item/crowbar
	name = "карманный ломик"
	desc = "Маленький ломик. Этот удобный инструмент полезен для многих вещей, например, для снятия напольной плитки или открывания дверей без электропитания."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/items/crowbar.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'

	attack_verb_continuous = list("атакует", "колотит", "бьёт", "ударяет", "вмазывает")
	attack_verb_simple = list("атакует", "колотит", "бьёт", "ударяет", "вмазывает")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)
	var/force_opens = FALSE

/obj/item/crowbar/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/abductor
	name = "чужеродный ломик"
	desc = "Жесткий лёгкий ломик. Похоже, он работает сам по себе, даже не нужно прилагать никаких усилий."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1


/obj/item/crowbar/large
	name = "ломик"
	desc = "Это большой ломик. Он не помещается в карманы, потому что он большой."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	custom_materials = list(/datum/material/iron=70)
	icon_state = "crowbar_large"
	inhand_icon_state = "crowbar"
	toolspeed = 0.7

/obj/item/crowbar/power
	name = "челюсти жизни"
	desc = "Набор челюстей жизни, сжатых через магию науки."
	icon_state = "jaws_pry"
	inhand_icon_state = "jawsoflife"
	worn_icon_state = "jawsoflife"
	icon = 'white/valtos/icons/items.dmi'
	lefthand_file = 'white/valtos/icons/lefthand.dmi'
	righthand_file = 'white/valtos/icons/righthand.dmi'
	custom_materials = list(/datum/material/iron=150,/datum/material/silver=50,/datum/material/titanium=25)
	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.7
	force_opens = TRUE

/obj/item/crowbar/power/get_belt_overlay()
	return mutable_appearance('white/valtos/icons/belt_overlays.dmi', icon_state)

/obj/item/crowbar/power/syndicate
	name = "Syndicate jaws of life"
	desc = "A rengineered copy of Nanotrasen's standard jaws of life. Can be used to force open airlocks in it's crowbar configuration."
	icon_state = "jaws_pry_syndie"
	toolspeed = 0.5
	force_opens = TRUE

/obj/item/crowbar/power/examine()
	. = ..()
	. += "<hr>На конце установлен [tool_behaviour == TOOL_CROWBAR ? "открывака" : "кусака"]."

/obj/item/crowbar/power/suicide_act(mob/user)
	if(tool_behaviour == TOOL_CROWBAR)
		user.visible_message("<span class='suicide'>[user] is putting [user.p_their()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(loc, 'sound/items/jaws_pry.ogg', 50, TRUE, -1)
	else
		user.visible_message("<span class='suicide'>[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!</span>")
		playsound(loc, 'sound/items/jaws_cut.ogg', 50, TRUE, -1)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
			if(BP)
				BP.drop_limb()
				playsound(loc, "desecration", 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_CROWBAR)
		tool_behaviour = TOOL_WIRECUTTER
		to_chat(user, "<span class='notice'>Меняю открываку на кусаку.</span>")
		usesound = 'sound/items/jaws_cut.ogg'
		update_icon()

	else
		tool_behaviour = TOOL_CROWBAR
		to_chat(user, "<span class='notice'>Меняю кусаку на открываку.</span>")
		usesound = 'sound/items/jaws_pry.ogg'
		update_icon()

/obj/item/crowbar/power/update_icon()
	if(tool_behaviour == TOOL_WIRECUTTER)
		icon_state = "jaws_cutter"
	else
		icon_state = "jaws_pry"

/obj/item/crowbar/power/syndicate/update_icon()
	if(tool_behaviour == TOOL_WIRECUTTER)
		icon_state = "jaws_cutter_syndie"
	else
		icon_state = "jaws_pry_syndie"

/obj/item/crowbar/power/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message("<span class='notice'>[user] перекусывает наручи [C] используя [src]!</span>")
		qdel(C.handcuffed)
		return
	else
		..()

/obj/item/crowbar/cyborg
	name = "гидравлический ломик"
	desc = "Гидравлический инструмент, простой, но мощный."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5
