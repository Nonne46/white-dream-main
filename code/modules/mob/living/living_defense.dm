
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = MELEE, absorb_text = null, soften_text = null, armour_penetration, penetrated_text, silent=FALSE)
	var/armor = getarmor(def_zone, attack_flag)

	if(armor <= 0)
		return armor
	if(silent)
		return max(0, armor - armour_penetration)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armour_penetration)
		armor = max(0, armor - armour_penetration)
		if(penetrated_text)
			to_chat(src, "<span class='userdanger'>[penetrated_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Моя броня пробита!</span>")
	else if(armor >= 100)
		if(absorb_text)
			to_chat(src, "<span class='notice'>[absorb_text]</span>")
		else
			to_chat(src, "<span class='notice'>Моя броня поглотила удар!</span>")
	else
		if(soften_text)
			to_chat(src, "<span class='warning'>[soften_text]</span>")
		else
			to_chat(src, "<span class='warning'>Моя броня смягчает удар!</span>")
	return armor

/mob/living/proc/getarmor(def_zone, type)
	return 0

//this returns the mob's protection against eye damage (number between -1 and 2) from bright lights
/mob/living/proc/get_eye_protection()
	return 0

//this returns the mob's protection against ear damage (0:no protection; 1: some ear protection; 2: has no ears)
/mob/living/proc/get_ear_protection()
	return 0

/mob/living/proc/is_mouth_covered(head_only = 0, mask_only = 0)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = 1, check_head = 1, check_mask = 1)
	return FALSE
/mob/living/proc/is_pepper_proof(check_head = TRUE, check_mask = TRUE)
	return FALSE
/mob/living/proc/on_hit(obj/projectile/P)
	return BULLET_ACT_HIT

/mob/living/bullet_act(obj/projectile/P, def_zone)
	var/armor = run_armor_check(def_zone, P.flag, "","",P.armour_penetration)
	var/on_hit_state = P.on_hit(src, armor)

	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)

	if(isliving(P.firer))
		var/mob/living/L = P.firer
		lastattacker = L.real_name
		if(L.ckey)
			lastattackerckey = L.ckey

	if(!P.nodamage && on_hit_state != BULLET_ACT_BLOCK)
		apply_damage(P.damage, P.damage_type, def_zone, armor, wound_bonus=P.wound_bonus, bare_wound_bonus=P.bare_wound_bonus, sharpness = P.sharpness)
		apply_effects(P.stun, P.knockdown, P.unconscious, P.irradiate, P.slur, P.stutter, P.eyeblur, P.drowsy, armor, P.stamina, P.jitter, P.paralyze, P.immobilize)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return on_hit_state ? BULLET_ACT_HIT : BULLET_ACT_BLOCK

/mob/living/proc/check_projectile_dismemberment(obj/projectile/P, def_zone)
	return 0

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
		if(throwforce && w_class)
				return clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
		else if(w_class)
				return clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
		else
				return 0


/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		var/obj/item/thrown_item = AM
		var/zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
		var/nosell_hit = SEND_SIGNAL(thrown_item, COMSIG_MOVABLE_IMPACT_ZONE, src, zone, throwingdatum) // TODO: find a better way to handle hitpush and skipcatch for humans
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE

		if(blocked)
			return TRUE

		if(thrown_item.thrownby)
			log_combat(thrown_item.thrownby, src, "threw and hit", thrown_item)
		if(nosell_hit)
			return ..()
		visible_message("<span class='danger'>В <b>[src]</b> попадает <b>[thrown_item.name]</b>!</span>", \
						"<span class='userdanger'>В <b>меня</b> попадает [thrown_item.name]!</span>")
		if(!thrown_item.throwforce)
			return
		var/armor = run_armor_check(zone, MELEE, "Моя броня отражает попадание в [ru_parse_zone(parse_zone(zone))].", "Моя броня смягчает попадание в [ru_parse_zone(parse_zone(zone))].", thrown_item.armour_penetration)
		apply_damage(thrown_item.throwforce, thrown_item.damtype, zone, armor, sharpness = thrown_item.get_sharpness(), wound_bonus = (nosell_hit * CANT_WOUND))
		if(QDELETED(src)) //Damage can delete the mob.
			return
		return ..()

	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1) //Item sounds are handled in the item itself
	return ..()


/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == BRUTE)
			step_away(src,M,15)
		switch(M.damtype)
			if(BRUTE)
				Unconscious(20)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if(BURN)
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if(TOX)
				M.mech_toxin_damage(src)
			else
				return
		updatehealth()
		visible_message("<span class='danger'><b>[M.name]</b> бьёт <b>[src]</b>!</span>", \
						"<span class='userdanger'><b>[M.name]</b> бьёт меня!</span>", "<span class='hear'>Слышу как что-то сильно бьёт по плоти!</span>", null, COMBAT_MESSAGE_RANGE)
		to_chat(M, "<span class='danger'>Бью [src]!</span>")
		log_combat(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
	else
		step_away(src,M)
		log_combat(M.occupant, src, "pushed", M)
		visible_message("<span class='warning'><b>[M.name]</b> отталкивает <b>[src]</b> с пути.</span>", \
						"<span class='warning'><b>[M.name]</b> отталкивает меня с пути.</span>", "<span class='hear'>Слышу агрессивную потасовку сопровождающуюся громким стуком!</span>", 5, M)
		to_chat(M, "<span class='danger'>Отталкиваю [src] с пути.</span>")

/mob/living/fire_act()
	adjust_fire_stacks(3)
	IgniteMob()

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	if(user == src || anchored || !isturf(user.loc))
		return FALSE
	if(!user.pulling || user.pulling != src)
		user.start_pulling(src, supress_message = supress_message)
		return

	if(!(status_flags & CANPUSH) || HAS_TRAIT(src, TRAIT_PUSHIMMUNE))
		to_chat(user, "<span class='warning'>Не могу схватить <b>[src]</b> сильнее!</span>")
		return FALSE

	if(user.grab_state >= GRAB_AGGRESSIVE && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>Не хочу случайно навредить <b>[src]</b>!</span>")
		return FALSE
	grippedby(user)

//proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/carbon/user, instant = FALSE)
	if(user.grab_state < GRAB_KILL)
		user.changeNext_move(CLICK_CD_GRABBING)
		var/sound_to_play = 'sound/weapons/thudswoosh.ogg'
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.dna.species.grab_sound)
				sound_to_play = H.dna.species.grab_sound
		playsound(src.loc, sound_to_play, 50, TRUE, -1)

		if(user.grab_state) //only the first upgrade is instantaneous
			var/old_grab_state = user.grab_state
			var/grab_upgrade_time = instant ? 0 : 30
			visible_message("<span class='danger'><b>[user]</b> начинает брать <b>[src]</b> в более крепкий захват!</span>", \
				"<span class='userdanger'><b>[user]</b> начинает брать меня <b>[src]</b> в более крепкий захват!</span>", "<span class='hear'>Слышу агрессивную потасовку!</span>", null, user)
			to_chat(user, "<span class='danger'>Начинаю брать [src] в более крепкий захват!</span>")
			switch(user.grab_state)
				if(GRAB_AGGRESSIVE)
					log_combat(user, src, "attempted to neck grab", addition="neck grab")
				if(GRAB_NECK)
					log_combat(user, src, "attempted to strangle", addition="kill grab")
			if(!do_mob(user, src, grab_upgrade_time))
				return 0
			if(!user.pulling || user.pulling != src || user.grab_state != old_grab_state)
				return 0
			if(user.a_intent != INTENT_GRAB)
				to_chat(user, "<span class='warning'>Надо бы сосредоточиться на захвате, чтобы схватить сильнее!</span>")
				return 0
		user.setGrabState(user.grab_state + 1)
		switch(user.grab_state)
			if(GRAB_AGGRESSIVE)
				var/add_log = ""
				if(HAS_TRAIT(user, TRAIT_PACIFISM))
					visible_message("<span class='danger'><b>[user]</b> крепко хватает <b>[src]</b>!</span>",
									"<span class='danger'><b>[user]</b> крепко держит меня!</span>", "<span class='hear'>Слышу агрессивную потасовку!</span>", null, user)
					to_chat(user, "<span class='danger'>Крепко хватаю [src]!</span>")
					add_log = " (pacifist)"
				else
					visible_message("<span class='danger'><b>[user]</b> хватает <b>[src]</b> крепче!</span>", \
									"<span class='userdanger'><b>[user]</b> хватает меня крепче!</span>", "<span class='hear'>Слышу агрессивную потасовку!</span>", null, user)
					to_chat(user, "<span class='danger'>Хватаю [src] крепче!</span>")
				drop_all_held_items()
				stop_pulling()
				log_combat(user, src, "grabbed", addition="aggressive grab[add_log]")
			if(GRAB_NECK)
				log_combat(user, src, "grabbed", addition="neck grab")
				visible_message("<span class='danger'><b>[user]</b> хватает <b>[src]</b> за шею!</span>",\
								"<span class='userdanger'><b>[user]</b> хватает меня за шею!</span>", "<span class='hear'>Слышу агрессивную потасовку!</span>", null, user)
				to_chat(user, "<span class='danger'>Хватаю [src] за шею!</span>")
				update_mobility() //we fall down
				if(!buckled && !density)
					Move(user.loc, NONE, user.step_x, user.step_y)
			if(GRAB_KILL)
				log_combat(user, src, "strangled", addition="kill grab")
				visible_message("<span class='danger'><b>[user]</b> душит <b>[src]</b>!</span>", \
								"<span class='userdanger'><b>[user]</b> душит меня!</span>", "<span class='hear'>Слышу агрессивную потасовку!</span>", null, user)
				to_chat(user, "<span class='danger'>Душу [src]!</span>")
				update_mobility() //we fall down
				if(!buckled && !density)
					Move(user.loc, NONE, user.step_x, user.step_y)
		user.set_pull_offsets(src, grab_state)
		return 1


/mob/living/attack_slime(mob/living/simple_animal/slime/M)
	if(!SSticker.HasRoundStarted())
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>Не хочу вредить!</span>")
		return FALSE

	if (stat != DEAD)
		log_combat(M, src, "атакует")
		M.do_attack_animation(src)
		visible_message("<span class='danger'><b>[M.name]</b> кушает <b>[src]</b>!</span>", \
				"<span class='userdanger'><b>[M.name]</b> кушает меня!</span>", "<span class='hear'>Слышу как что-то сильно бьёт по плоти!</span>", COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='danger'>Кушаю [src]!</span>")
		return TRUE

/mob/living/attack_animal(mob/living/simple_animal/M)
	M.face_atom(src)
	if(M.melee_damage_upper == 0)
		visible_message("<span class='notice'><b>[M]</b> [M.friendly_verb_continuous] <b>[src]</b>!</span>", \
						"<span class='notice'><b>[M]</b> [M.friendly_verb_continuous] меня!</span>", null, COMBAT_MESSAGE_RANGE, M)
		to_chat(M, "<span class='notice'>Я [M.friendly_verb_simple] <b>[src]</b>!</span>")
		return FALSE
	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, "<span class='warning'>Не хочу вредить!</span>")
		return FALSE
	else
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='warning'>Не хочу вредить!</span>")
			return FALSE

	if(M.attack_sound)
		playsound(loc, M.attack_sound, 50, TRUE, TRUE)
	M.do_attack_animation(src)
	visible_message("<span class='danger'><b>[M]</b> [M.attack_verb_continuous] <b>[src]</b>!</span>", \
					"<span class='userdanger'><b>[M]</b> [M.attack_verb_continuous] меня!</span>", null, COMBAT_MESSAGE_RANGE, M)
	to_chat(M, "<span class='danger'>Я [M.attack_verb_simple] <b>[src]</b>!</span>")
	log_combat(M, src, "attacked")
	return TRUE


/mob/living/attack_paw(mob/living/carbon/monkey/M)
	if(isturf(loc) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return FALSE

	if (M.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='warning'>Не хочу вредить!</span>")
			return FALSE

		if(M.is_muzzled() || M.is_mouth_covered(FALSE, TRUE))
			to_chat(M, "<span class='warning'>Мой рот закрыт!</span>")
			return FALSE
		M.do_attack_animation(src, ATTACK_EFFECT_BITE)
		if (prob(75))
			log_combat(M, src, "атакует")
			playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
			visible_message("<span class='danger'><b>[M.name]</b> кусает <b>[src]</b>!</span>", \
					"<span class='userdanger'><b>[M.name]</b> кусает меня!</span>", "<span class='hear'>Слышу кусь!</span>", COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>Я кусаю [src]!</span>")
			return TRUE
		else
			visible_message("<span class='danger'><b>[M.name]</b> пытается укусить <b>[src]</b>!</span>", \
				"<span class='userdanger'><b>[M.name]</b> пытается укусить меня!</span>", "<span class='hear'>Слышу как защелкиваются челюсти!</span>", COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>Пытаюсь укусить [src]!</span>")
	return FALSE

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if("help")
			visible_message("<span class='notice'><b>[L.name]</b> трётся своей головой о <b>[src]</b>.</span>", \
							"<span class='notice'><b>[L.name]</b> трётся своей головой о меня.</span>", null, null, L)
			to_chat(L, "<span class='notice'>Тру свою голову о [src].</span>")
			return FALSE

		else
			if(HAS_TRAIT(L, TRAIT_PACIFISM))
				to_chat(L, "<span class='warning'>Не хочу вредить!</span>")
				return

			L.do_attack_animation(src)
			if(prob(90))
				log_combat(L, src, "атакует")
				visible_message("<span class='danger'><b>[L.name]</b> кусает [src]!</span>", \
								"<span class='userdanger'><b>[L.name]</b> кусает меня!</span>", "<span class='hear'>Слышу кусь!</span>", COMBAT_MESSAGE_RANGE, L)
				to_chat(L, "<span class='danger'>Кусаю [src]!</span>")
				playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
				return TRUE
			else
				visible_message("<span class='danger'><b>[L.name]</b> пытается укусить <b>[src]</b>!</span>", \
								"<span class='userdanger'><b>[L.name]</b> пытается укусить меня!</span>", "<span class='hear'>Слышу как защелкиваются челюсти!</span>", COMBAT_MESSAGE_RANGE, L)
				to_chat(L, "<span class='danger'>Пытаюсь укусить [src]!</span>")
	return FALSE

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M)
	switch(M.a_intent)
		if ("help")
			visible_message("<span class='notice'><b>[M]</b> cобнимает <b>[src]</b> своей клешнёй.</span>", \
				"<span class='notice'><b>[M]</b> обнимает меня своей клешнёй.</span>", null, null, M)
			to_chat(M, "<span class='notice'>Обнимаю [src] своей клешнёй.</span>")
			return FALSE
		if ("grab")
			grabbedby(M)
			return FALSE
		if("harm")
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='warning'>Не хочу вредить!</span>")
				return FALSE
			M.do_attack_animation(src)
			return TRUE
		if("disarm")
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE

/mob/living/attack_hulk(mob/living/carbon/human/user)
	..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>Не хочу вредить <b>[src]</b>!</span>")
		return FALSE
	return TRUE

/mob/living/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()

//Looking for irradiate()? It's been moved to radiation.dm under the rad_act() for mobs.

/mob/living/acid_act(acidpwr, acid_volume)
	take_bodypart_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	shock_damage *= siemens_coeff
	if((flags & SHOCK_TESLA) && HAS_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		adjustFireLoss(shock_damage)
	else
		adjustStaminaLoss(shock_damage)
	visible_message(
		"<span class='danger'><b>[src]</b> ловит разряд тока от <b>[source]</b>!</span>", \
		"<span class='userdanger'>Меня ударило током! <b>ЭТО ОЧЕНЬ БОЛЬНО!</b></span>", \
		"<span class='italics'>Слышу щёлканье электрических разрядов.</span>" \
	)
	return shock_damage

/mob/living/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in contents)
		O.emp_act(severity)

///Logs, gibs and returns point values of whatever mob is unfortunate enough to get eaten.
/mob/living/singularity_act()
	investigate_log("([key_name(src)]) has been consumed by the singularity.", INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return 20

/mob/living/narsie_act()
	if(status_flags & GODMODE || QDELETED(src))
		return

	if(GLOB.cult_narsie && GLOB.cult_narsie.souls_needed[src])
		GLOB.cult_narsie.souls_needed -= src
		GLOB.cult_narsie.souls += 1
		if((GLOB.cult_narsie.souls == GLOB.cult_narsie.soul_goal) && (GLOB.cult_narsie.resolved == FALSE))
			GLOB.cult_narsie.resolved = TRUE
			sound_to_playing_players('sound/machines/alarm.ogg')
			addtimer(CALLBACK(GLOBAL_PROC, .proc/cult_ending_helper, 1), 120)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/ending_helper), 270)
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, cultoverride = TRUE)
	else
		switch(rand(1, 4))
			if(1)
				new /mob/living/simple_animal/hostile/construct/juggernaut/hostile(get_turf(src))
			if(2)
				new /mob/living/simple_animal/hostile/construct/wraith/hostile(get_turf(src))
			if(3)
				new /mob/living/simple_animal/hostile/construct/artificer/hostile(get_turf(src))
			if(4)
				new /mob/living/simple_animal/hostile/construct/proteon/hostile(get_turf(src))
	spawn_dust()
	gib()
	return TRUE

//called when the mob receives a bright flash
/mob/living/proc/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(HAS_TRAIT(src, TRAIT_NOFLASH))
		return FALSE
	if(get_eye_protection() < intensity && (override_blindness_check || !is_blind()))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, .proc/clear_fullscreen, "flash", 25), 25)
		return TRUE
	return FALSE

//called when the mob receives a loud bang
/mob/living/proc/soundbang_act()
	return 0

//to damage the clothes worn by a mob
/mob/living/proc/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	return


/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_held_item()
	..()
	setMovetype(movement_type & ~FLOATING) // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

/** Handles exposing a mob to reagents.
  *
  * If the method is INGEST the mob tastes the reagents.
  * If the method is VAPOR it incorporates permiability protection.
  */
/mob/living/expose_reagents(list/reagents, datum/reagents/source, method=TOUCH, volume_modifier=1, show_message=TRUE)
	if((. = ..()) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	if(method == INGEST)
		taste(source)

	var/touch_protection = (method == VAPOR) ? get_permeability_protection() : 0
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_mob(src, method, reagents[R], show_message, touch_protection)
