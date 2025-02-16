/obj/structure/window
	name = "окно"
	desc = "Окно. Невероятно."
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1 | RAD_PROTECT_CONTENTS_1
	max_integrity = 25
	can_be_unanchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 100)
	CanAtmosPass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION

	bound_height = 7
	bound_width = 32
	bound_x = 0
	bound_y = 25

	var/ini_dir = null
	var/state = WINDOW_OUT_OF_FRAME
	var/reinf = FALSE
	var/heat_resistance = 800
	var/decon_speed = 30
	var/wtype = "glass"
	var/fulltile = FALSE
	var/glass_type = /obj/item/stack/sheet/glass
	var/glass_amount = 1
	var/mutable_appearance/crack_overlay
	var/real_explosion_block	//ignore this, just use explosion_block
	var/breaksound = "shatter"
	var/hitsound = 'sound/effects/Glasshit.ogg'
	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.4


/obj/structure/window/examine(mob/user)
	. = ..()
	. += "<hr>"
	if(reinf)
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += "<span class='notice'>Окно <b>прикручено</b> к рамке.</span>"
		else if(anchored && state == WINDOW_IN_FRAME)
			. += "<span class='notice'>Окно <i>откручено</i> от рамки, но всё ещё <b>пристыковано</b> к ней.</span>"
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += "<span class='notice'>Окно вышло из рамки, но может быть <i>пристыковано</i> к ней. Оно <b>прикручено</b> к полу.</span>"
		else if(!anchored)
			. += "<span class='notice'>Окно <i>окручено</i> от пола, и может быть разобрано <b>раскручиванием</b>.</span>"
	else
		if(anchored)
			. += "<span class='notice'>Окно <b>прикручено</b> к полу.</span>"
		else
			. += "<span class='notice'>Окно <i>окручено</i> от пола, и может быть разобрано <b>раскручиванием</b>.</span>"

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = RWINDOW_SECURE

	ini_dir = dir
	air_update_turf(1)

	if(fulltile)
		setDir()

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

/obj/structure/window/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS ,null,CALLBACK(src, .proc/can_be_rotated),CALLBACK(src,.proc/after_rotation))

/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/obj/structure/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>Разбираю окно.</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/setDir(direct)
	if(fulltile)
		direct = FULLTILE_WINDOW_DIR
	return ..()

/obj/structure/window/update_bounds(olddir, newdir)
	if(newdir == FULLTILE_WINDOW_DIR)
		bound_width = 32
		bound_height = 32
		bound_x = 0
		bound_y = 0
	else if(olddir == FULLTILE_WINDOW_DIR)
		olddir = dir = initial(dir)
		bound_width = initial(bound_width)
		bound_height = initial(bound_height)
		bound_x = initial(bound_x)
		bound_y = initial(bound_y)
	return ..()

/obj/structure/window/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSGLASS))
		return TRUE

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>Что-то стучит по [sklonenie(src.name, VINITELNI, src.gender)].</span>")
	add_fingerprint(user)
	playsound(src, 'sound/effects/Glassknock.ogg', 50, TRUE)

/obj/structure/window/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(!can_be_reached(user))
		return
	. = ..()

/obj/structure/window/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='notice'>[user] стучит по [sklonenie(src.name, VINITELNI, src.gender)].</span>", \
		"<span class='notice'>Стучу по [sklonenie(src.name, VINITELNI, src.gender)].</span>")
	add_fingerprint(user)
	playsound(src, 'sound/effects/Glassknock.ogg', 50, TRUE)

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, params)
	if(!can_be_reached(user))
		return 1 //skip the afterattack

	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>Начинаю чинить [src.name]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				obj_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, "<span class='notice'>Чиню [src.name].</span>")
		else
			to_chat(user, "<span class='warning'>[capitalize(sklonenie(src.name, VINITELNI, src.gender))] не требуется починка!</span>")
		return

	if(!(flags_1&NODECONSTRUCT_1) && !(reinf && state >= RWINDOW_FRAME_BOLTED))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			to_chat(user, "<span class='notice'>Начинаю [anchored ? "откручивать окно от пола":"прикручивать окно к полу"]...</span>")
			if(I.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, .proc/check_anchored, anchored)))
				set_anchored(!anchored)
				to_chat(user, "<span class='notice'>[anchored ? "Прикручиваю к полу":"Откручиваю от пола"].</span>")
			return
		else if(I.tool_behaviour == TOOL_WRENCH && !anchored)
			to_chat(user, "<span class='notice'>Начинаю разбирать [src.name]...</span>")
			if(I.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
				G.add_fingerprint(user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>Разбираю [src.name].</span>")
				qdel(src)
			return
		else if(I.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME) && anchored)
			to_chat(user, "<span class='notice'>Начинаю вставлять окно в рамку...</span>")
			if(I.use_tool(src, user, 100, volume = 75, extra_checks = CALLBACK(src, .proc/check_state_and_anchored, state, anchored)))
				state = RWINDOW_SECURE
				to_chat(user, "<span class='notice'>Вставляю окно в рамку.</span>")
			return

	return ..()

/obj/structure/window/set_anchored(anchorvalue)
	..()
	air_update_turf(TRUE)
	update_nearby_icons()

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/mech_melee_attack(obj/mecha/M)
	if(!can_be_reached(M))
		return
	..()

/obj/structure/window/proc/can_be_reached(mob/user)
	if(!fulltile)
		if(GET_PIXELDIR(user,src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user) && O != src)
					return FALSE
	return TRUE

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, TRUE)


/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, TRUE)
		if(!(flags_1 & NODECONSTRUCT_1))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()[1]))
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	. += new /obj/item/shard(location)
	. += new /obj/effect/decal/cleanable/glass(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))

/obj/structure/window/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>[capitalize(src.name)] не может быть повёрнуто. Оно прикручено к полу!</span>")
		return FALSE

	var/target_dir = turn(dir, rotation_type == ROTATION_CLOCKWISE ? -90 : 90)

	if(!valid_window_location(loc, target_dir))
		to_chat(user, "<span class='warning'>[capitalize(src.name)] не может быть повёрнуто в этом направлении!</span>")
		return FALSE
	return TRUE

/obj/structure/window/proc/after_rotation(mob/user,rotation_type)
	air_update_turf(1)
	ini_dir = dir
	add_fingerprint(user)

/obj/structure/window/Destroy()
	density = FALSE
	air_update_turf(1)
	update_nearby_icons()
	return ..()


/obj/structure/window/Move(atom/newloc, direct = 0, _step_x, _step_y)
	var/turf/T = loc
	direct = ini_dir
	. = ..()
	move_update_air(T)

/obj/structure/window/CanAtmosPass(turf/T)
	if(!anchored || !density)
		return TRUE
	return !(FULLTILE_WINDOW_DIR == dir || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_icon()
	if(smoothing_flags)
		QUEUE_SMOOTH_NEIGHBORS(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_overlays()
	. = ..()
	if(!QDELETED(src))
		if(!fulltile)
			return

		var/ratio = obj_integrity / max_integrity
		ratio = CEILING(ratio*4, 1) * 25

		if(smoothing_flags)
			QUEUE_SMOOTH(src)

		cut_overlay(crack_overlay)
		if(ratio > 75)
			return
		crack_overlay = mutable_appearance('icons/obj/structures.dmi', "damage[ratio]", -(layer+0.1))
		. += crack_overlay

/obj/structure/window/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	if(exposed_temperature > (T0C + heat_resistance))
		take_damage(round(exposed_volume / 100), BURN, 0, 0)
	..()

/obj/structure/window/get_dumping_location(obj/item/storage/source,mob/user)
	return null

/obj/structure/window/CanAStarPass(ID, to_dir)
	if(!density)
		return 1
	if((dir == FULLTILE_WINDOW_DIR) || (dir == to_dir))
		return 0

	return 1

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

/obj/structure/window/spawner/east
	dir = EAST

/obj/structure/window/spawner/west
	dir = WEST

/obj/structure/window/spawner/north
	dir = NORTH

/obj/structure/window/unanchored
	anchored = FALSE

/obj/structure/window/reinforced
	name = "армированное окно"
	desc = "Окно, которое укреплено стальными прутьями."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 80, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 25, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	max_integrity = 75
	explosion_block = 1
	damage_deflection = 11
	state = RWINDOW_SECURE
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_HEAVY_INSULATION
	ricochet_chance_mod = 0.8

//this is shitcode but all of construction is shitcode and needs a refactor, it works for now
//If you find this like 4 years later and construction still hasn't been refactored, I'm so sorry for this
/obj/structure/window/reinforced/attackby(obj/item/I, mob/living/user, params)
	switch(state)
		if(RWINDOW_SECURE)
			if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HARM)
				user.visible_message("<span class='notice'>[user] направляет [sklonenie(I.name, VINITELNI, I.gender)] на защищённые винтики [sklonenie(src.name, VINITELNI, src.gender)]...</span>",
										"<span class='notice'>Начинаю нагревать винтики [sklonenie(src.name, VINITELNI, src.gender)]...</span>")
				if(I.use_tool(src, user, 180, volume = 100))
					to_chat(user, "<span class='notice'>Винтики раскалены до бела, похоже можно открутить их прямо сейчас..</span>")
					state = RWINDOW_BOLTS_HEATED
					addtimer(CALLBACK(src, .proc/cool_bolts), 300)
				return
		if(RWINDOW_BOLTS_HEATED)
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user] втыкает отвёртку в раскалённые винтики и начинает их выкручивать...</span>",
										"<span class='notice'>Втыкаю отвёртку в раскалённые винтики и начинаешь их выкручивать...</span>")
				if(I.use_tool(src, user, 80, volume = 50))
					state = RWINDOW_BOLTS_OUT
					to_chat(user, "<span class='notice'>Винтики удалены и теперь окно можно подпереть</span>")
				return
		if(RWINDOW_BOLTS_OUT)
			if(I.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("<span class='notice'>[user] вставляет [sklonenie(I.name, VINITELNI, I.gender)] в щель и начинает подпирать окно...</span>",
										"<span class='notice'>Вставляю [sklonenie(I.name, VINITELNI, I.gender)] в щель и начинаю подпирать окно...</span>")
				if(I.use_tool(src, user, 50, volume = 50))
					state = RWINDOW_POPPED
					to_chat(user, "<span class='notice'>Основная плита вышла из рамки и стали видны прутья, которые можно откусить.</span>")
				return
		if(RWINDOW_POPPED)
			if(I.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message("<span class='notice'>[user] начинает откусывать доступные прутья [sklonenie(src.name, VINITELNI, src.gender)]...</span>",
										"<span class='notice'>Начинаю откусывать доступные прутья [sklonenie(src.name, VINITELNI, src.gender)]...</span>")
				if(I.use_tool(src, user, 30, volume = 50))
					state = RWINDOW_BARS_CUT
					to_chat(user, "<span class='notice'>Основная плита отделена от рамки и теперь её удерживает только несколько болтов.</span>")
				return
		if(RWINDOW_BARS_CUT)
			if(I.tool_behaviour == TOOL_WRENCH)
				user.visible_message("<span class='notice'>[user] начинает откручивать [sklonenie(src.name, VINITELNI, src.gender)] от рамки...</span>",
					"<span class='notice'>Начинаю откручивать болты...</span>")
				if(I.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>Снимаю окно с болтов и теперь оно может быть свободно перемещено.</span>")
					state = WINDOW_OUT_OF_FRAME
					set_anchored(FALSE)
				return
	return ..()

/obj/structure/window/proc/cool_bolts()
	if(state == RWINDOW_BOLTS_HEATED)
		state = RWINDOW_SECURE
		visible_message("<span class='notice'>Винтики в [sklonenie(src.name, DATELNI, src.gender)] выглядят остывшими...</span>")

/obj/structure/window/reinforced/examine(mob/user)
	. = ..()
	. += "<hr>"
	switch(state)
		if(RWINDOW_SECURE)
			. += "<span class='notice'>Похоже окно вкручено одноразовыми винтами. Придётся <b>нагреть их</b>, чтобы получить хоть какой-то шанс выкрутить их обратно.</span>"
		if(RWINDOW_BOLTS_HEATED)
			. += "<span class='notice'>Винтики раскалены до бела, похоже можно <b>открутить их</b> прямо сейчас.</span>"
		if(RWINDOW_BOLTS_OUT)
			. += "<span class='notice'>Винтики удалены и теперь окно можно <b>подпереть</b> сквозь доступную щель.</span>"
		if(RWINDOW_POPPED)
			. += "<span class='notice'>Основная плита вышла из рамки и стали видны прутья, которые можно <b>откусить</b>.</span>"
		if(RWINDOW_BARS_CUT)
			. += "<span class='notice'>Основная плита отделена от рамки и теперь её удерживает только несколько <b>болтов</b>.</span>"

/obj/structure/window/reinforced/spawner/east
	dir = EAST

/obj/structure/window/reinforced/spawner/west
	dir = WEST

/obj/structure/window/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/reinforced/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	reinf = FALSE
	heat_resistance = 25000
	armor = list(MELEE = 80, BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 100, RAD = 100, FIRE = 99, ACID = 100)
	max_integrity = 200
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/plasmaglass
	rad_insulation = RAD_NO_INSULATION

/obj/structure/window/plasma/spawner/east
	dir = EAST

/obj/structure/window/plasma/spawner/west
	dir = WEST

/obj/structure/window/plasma/spawner/north
	dir = NORTH

/obj/structure/window/plasma/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor = list(MELEE = 80, BULLET = 20, LASER = 0, ENERGY = 0, BOMB = 60, BIO = 100, RAD = 100, FIRE = 99, ACID = 100)
	max_integrity = 500
	damage_deflection = 21
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass

//entirely copypasted code
//take this out when construction is made a component or otherwise modularized in some way
/obj/structure/window/plasma/reinforced/attackby(obj/item/I, mob/living/user, params)
	switch(state)
		if(RWINDOW_SECURE)
			if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HARM)
				user.visible_message("<span class='notice'>[user] holds \the [I] to the security screws on \the [src]...</span>",
										"<span class='notice'>You begin heating the security screws on \the [src]...</span>")
				if(I.use_tool(src, user, 180, volume = 100))
					to_chat(user, "<span class='notice'>The security screws are glowing white hot and look ready to be removed.</span>")
					state = RWINDOW_BOLTS_HEATED
					addtimer(CALLBACK(src, .proc/cool_bolts), 300)
				return
		if(RWINDOW_BOLTS_HEATED)
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user] digs into the heated security screws and starts removing them...</span>",
										"<span class='notice'>You dig into the heated screws hard and they start turning...</span>")
				if(I.use_tool(src, user, 80, volume = 50))
					state = RWINDOW_BOLTS_OUT
					to_chat(user, "<span class='notice'>The screws come out, and a gap forms around the edge of the pane.</span>")
				return
		if(RWINDOW_BOLTS_OUT)
			if(I.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("<span class='notice'>[user] wedges \the [I] into the gap in the frame and starts prying...</span>",
										"<span class='notice'>You wedge \the [I] into the gap in the frame and start prying...</span>")
				if(I.use_tool(src, user, 50, volume = 50))
					state = RWINDOW_POPPED
					to_chat(user, "<span class='notice'>The panel pops out of the frame, exposing some thin metal bars that looks like they can be cut.</span>")
				return
		if(RWINDOW_POPPED)
			if(I.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message("<span class='notice'>[user] starts cutting the exposed bars on \the [src]...</span>",
										"<span class='notice'>You start cutting the exposed bars on \the [src]</span>")
				if(I.use_tool(src, user, 30, volume = 50))
					state = RWINDOW_BARS_CUT
					to_chat(user, "<span class='notice'>The panels falls out of the way exposing the frame bolts.</span>")
				return
		if(RWINDOW_BARS_CUT)
			if(I.tool_behaviour == TOOL_WRENCH)
				user.visible_message("<span class='notice'>[user] starts unfastening \the [src] from the frame...</span>",
					"<span class='notice'>You start unfastening the bolts from the frame...</span>")
				if(I.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You unfasten the bolts from the frame and the window pops loose.</span>")
					state = WINDOW_OUT_OF_FRAME
					set_anchored(FALSE)
				return
	return ..()

/obj/structure/window/plasma/reinforced/examine(mob/user)
	. = ..()
	. += "<hr>"
	switch(state)
		if(RWINDOW_SECURE)
			. += "<span class='notice'>It's been screwed in with one way screws, you'd need to <b>heat them</b> to have any chance of backing them out.</span>"
		if(RWINDOW_BOLTS_HEATED)
			. += "<span class='notice'>The screws are glowing white hot, and you'll likely be able to <b>unscrew them</b> now.</span>"
		if(RWINDOW_BOLTS_OUT)
			. += "<span class='notice'>The screws have been removed, revealing a small gap you could fit a <b>prying tool</b> in.</span>"
		if(RWINDOW_POPPED)
			. += "<span class='notice'>The main plate of the window has popped out of the frame, exposing some bars that look like they can be <b>cut</b>.</span>"
		if(RWINDOW_BARS_CUT)
			. += "<span class='notice'>The main pane can be easily moved out of the way to reveal some <b>bolts</b> holding the frame in.</span>"

/obj/structure/window/plasma/reinforced/spawner/east
	dir = EAST

/obj/structure/window/plasma/reinforced/spawner/west
	dir = WEST

/obj/structure/window/plasma/reinforced/spawner/north
	dir = NORTH

/obj/structure/window/plasma/reinforced/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow"
	opacity = TRUE
/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "fwindow"

/* Full Tile Windows (more obj_integrity) */

/obj/structure/window/fulltile
	icon = 'white/valtos/icons/window_glass.dmi'
	icon_state = "window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 50
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	glass_amount = 2

/obj/structure/window/fulltile/attackby(obj/item/W, mob/user, params)
	if(is_glass_sheet(W))
		var/obj/item/stack/ST = W
		if (ST.get_amount() < 2)
			to_chat(user, "<span class='warning'>Надо бы хотя бы парочку листов стекла!</span>")
			return
		if(!anchored)
			to_chat(user, "<span class='warning'>Надо бы прикрутить [src] к полу!</span>")
			return
		for(var/obj/machinery/door/firedoor/window/FD in loc)
			to_chat(user, "<span class='warning'>Здесь уже есть окно!</span>")
			return
		to_chat(user, "<span class='notice'>Начинаю ставить запасное окно...</span>")
		if(do_after(user,30, target = src))
			if(!src.loc || !anchored)
				return
			for(var/obj/machinery/door/firedoor/window/FD in loc)
				to_chat(user, "<span class='warning'>Здесь уже есть запасное окно!</span>")
				return
			new/obj/machinery/door/firedoor/window(drop_location())
			ST.use(2)
			to_chat(user, "<span class='notice'>Ставлю запасное окно на [src].</span>")
		return
	. = ..()

/obj/structure/window/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/fulltile
	icon = 'icons/obj/smooth_structures/plasma_window.dmi'
	icon_state = "plasmawindow"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 300
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	glass_amount = 2

/obj/structure/window/plasma/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced/fulltile
	icon = 'white/valtos/icons/window_rplasma.dmi'
	icon_state = "rplasmawindow"
	dir = FULLTILE_WINDOW_DIR
	state = RWINDOW_SECURE
	max_integrity = 1000
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	glass_amount = 2

/obj/structure/window/plasma/reinforced/fulltile/attackby(obj/item/W, mob/user, params)
	if(is_glass_sheet(W))
		var/obj/item/stack/ST = W
		if (ST.get_amount() < 2)
			to_chat(user, "<span class='warning'>Надо бы хотя бы парочку листов стекла!</span>")
			return
		if(!anchored)
			to_chat(user, "<span class='warning'>Надо бы прикрутить [src] к полу!</span>")
			return
		for(var/obj/machinery/door/firedoor/window/FD in loc)
			to_chat(user, "<span class='warning'>Здесь уже есть окно!</span>")
			return
		to_chat(user, "<span class='notice'>Начинаю ставить запасное окно...</span>")
		if(do_after(user,30, target = src))
			if(!src.loc || !anchored)
				return
			for(var/obj/machinery/door/firedoor/window/FD in loc)
				to_chat(user, "<span class='warning'>Здесь уже есть запасное окно!</span>")
				return
			new/obj/machinery/door/firedoor/window(drop_location())
			ST.use(2)
			to_chat(user, "<span class='notice'>Ставлю запасное окно на [src].</span>")
		return
	. = ..()

/obj/structure/window/plasma/reinforced/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/fulltile
	icon = 'white/valtos/icons/window_rglass.dmi'
	icon_state = "r_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 150
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	state = RWINDOW_SECURE
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/attackby(obj/item/W, mob/user, params)
	if(is_glass_sheet(W))
		var/obj/item/stack/ST = W
		if (ST.get_amount() < 2)
			to_chat(user, "<span class='warning'>Надо бы хотя бы парочку листов стекла!</span>")
			return
		if(!anchored)
			to_chat(user, "<span class='warning'>Надо бы прикрутить [src] к полу!</span>")
			return
		for(var/obj/machinery/door/firedoor/window/FD in loc)
			to_chat(user, "<span class='warning'>Здесь уже есть окно!</span>")
			return
		to_chat(user, "<span class='notice'>Начинаю ставить запасное окно...</span>")
		if(do_after(user,30, target = src))
			if(!src.loc || !anchored)
				return
			for(var/obj/machinery/door/firedoor/window/FD in loc)
				to_chat(user, "<span class='warning'>Здесь уже есть запасное окно!</span>")
				return
			new/obj/machinery/door/firedoor/window(drop_location())
			ST.use(2)
			to_chat(user, "<span class='notice'>Ставлю запасное окно на [src].</span>")
		return
	. = ..()

/obj/structure/window/reinforced/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/tinted_window.dmi'
	icon_state = "tinted_window"
	dir = FULLTILE_WINDOW_DIR
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/rice_window.dmi'
	icon_state = "ice_window"
	max_integrity = 150
	glass_amount = 2

/obj/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/shuttle_window.dmi'
	icon_state = "shuttle_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 150
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor = list(MELEE = 90, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = null
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	ricochet_chance_mod = 0.9

/obj/structure/window/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/shuttle/tinted
	opacity = TRUE

/obj/structure/window/shuttle/unanchored
	anchored = FALSE

/obj/structure/window/plasma/reinforced/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of of plasma and titanium."
	icon = 'icons/obj/smooth_structures/plastitanium_window.dmi'
	icon_state = "plastitanium_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 200
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	heat_resistance = 1600
	armor = list(MELEE = 95, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 100)
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = null
	explosion_block = 3
	damage_deflection = 11 //The same as normal reinforced windows.3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2
	rad_insulation = RAD_HEAVY_INSULATION

/obj/structure/window/plasma/reinforced/plastitanium/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/paperframe
	name = "paper frame"
	desc = "A fragile separator made of thin wood and paper."
	icon = 'icons/obj/smooth_structures/paperframes.dmi'
	icon_state = "frame"
	dir = FULLTILE_WINDOW_DIR
	opacity = TRUE
	max_integrity = 15
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_PAPERFRAME)
	canSmoothWith = list(SMOOTH_GROUP_PAPERFRAME)
	glass_amount = 2
	glass_type = /obj/item/stack/sheet/paperframes
	heat_resistance = 233
	decon_speed = 10
	CanAtmosPass = ATMOS_PASS_YES
	resistance_flags = FLAMMABLE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	breaksound = 'sound/items/poster_ripped.ogg'
	hitsound = 'sound/weapons/slashmiss.ogg'
	var/static/mutable_appearance/torn = mutable_appearance('icons/obj/smooth_structures/paperframes.dmi',icon_state = "кромсает", layer = ABOVE_OBJ_LAYER - 0.1)
	var/static/mutable_appearance/paper = mutable_appearance('icons/obj/smooth_structures/paperframes.dmi',icon_state = "paper", layer = ABOVE_OBJ_LAYER - 0.1)

/obj/structure/window/paperframe/Initialize()
	. = ..()
	update_icon()

/obj/structure/window/paperframe/examine(mob/user)
	. = ..()
	if(obj_integrity < max_integrity)
		. += "<hr><span class='info'>It looks a bit damaged, you may be able to fix it with some <b>paper</b>.</span>"

/obj/structure/window/paperframe/spawnDebris(location)
	. = list(new /obj/item/stack/sheet/mineral/wood(location))
	for (var/i in 1 to rand(1,4))
		. += new /obj/item/paper/natural(location)

/obj/structure/window/paperframe/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(user.a_intent != INTENT_HARM)
		user.changeNext_move(CLICK_CD_MELEE)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>")
		playsound(src, "pageturn", 50, TRUE)
	else
		take_damage(4,BRUTE,MELEE, 0)
		playsound(src, hitsound, 50, TRUE)
		if(!QDELETED(src))
			user.visible_message("<span class='danger'>[user] tears a hole in [src].</span>")
			update_icon()

/obj/structure/window/paperframe/update_icon()
	if(obj_integrity < max_integrity)
		cut_overlay(paper)
		add_overlay(torn)
		set_opacity(FALSE)
	else
		cut_overlay(torn)
		add_overlay(paper)
		set_opacity(TRUE)
	QUEUE_SMOOTH(src)


/obj/structure/window/paperframe/attackby(obj/item/W, mob/user)
	if(W.get_temperature())
		fire_act(W.get_temperature())
		return
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(istype(W, /obj/item/paper) && obj_integrity < max_integrity)
		user.visible_message("<span class='notice'>[user] starts to patch the holes in \the [src].</span>")
		if(do_after(user, 20, target = src))
			obj_integrity = min(obj_integrity+4,max_integrity)
			qdel(W)
			user.visible_message("<span class='notice'>[user] patches some of the holes in \the [src].</span>")
			if(obj_integrity == max_integrity)
				update_icon()
			return
	..()
	update_icon()

/obj/structure/window/bronze
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass. Nevermind, this is just weak bronze!"
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	glass_type = /obj/item/stack/tile/bronze

/obj/structure/window/bronze/unanchored
	anchored = FALSE

/obj/structure/window/bronze/fulltile
	icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = null
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 50
	glass_amount = 2

/obj/structure/window/bronze/fulltile/unanchored
	anchored = FALSE
