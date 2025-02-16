/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	layer = BELOW_OBJ_LAYER
	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.5

	var/climb_time = 20
	var/climb_stun = 20
	var/climbable = FALSE
	var/mob/living/structureclimber
	var/broken = 0 //similar to machinery's stat BROKEN


/obj/structure/Initialize()
	if (!armor)
		armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	. = ..()
	if(smoothing_flags)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
		icon_state = ""
	GLOB.cameranet.updateVisibility(src)

/obj/structure/Destroy()
	GLOB.cameranet.updateVisibility(src)
	if(smoothing_flags)
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/structure/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(structureclimber && structureclimber != user)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		structureclimber.Paralyze(40)
		structureclimber.visible_message("<span class='warning'><b>[structureclimber]</b> сваливается с <b>[src.name]</b>.", "Падаю с [src.name]!", "Вижу как [structureclimber] падает с [src.name].</span>")

/obj/structure/ui_act(action, params)
	. = ..()
	add_fingerprint(usr)

/obj/structure/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(user == O && isliving(O))
		var/mob/living/L = O
		if(isanimal(L))
			var/mob/living/simple_animal/A = L
			if (!A.dextrous)
				return
		if(L.mobility_flags & MOBILITY_MOVE)
			climb_structure(user)
			return
	if(!istype(O, /obj/item) || user.get_active_held_item() != O)
		return
	if(iscyborg(user))
		return
	if(!user.dropItemToGround(O))
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/structure/proc/do_climb(atom/movable/A)
	if(climbable)
		if(loc in A.locs)
			var/turf/where_to_climb = get_step(A,dir)
			if(!where_to_climb.is_blocked_turf())
				A.forceMove(where_to_climb, step_x, step_y)
				return TRUE
		passtable_on(A, src)
		density = FALSE
		. = step(A , GET_PIXELDIR(A,loc), (bounds_dist(A, src)) + 16)
		passtable_off(A, src)
		density = TRUE

/obj/structure/proc/climb_structure(mob/living/user)
	src.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] начинает взбираться на [src.name].</span>", \
								"<span class='notice'>Начинаю взбираться на [src.name]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	structureclimber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if structure has been destroyed
			if(do_climb(user))
				user.visible_message("<span class='warning'>[user] взбирается на [src.name].</span>", \
									"<span class='notice'>Взбираюсь на [src.name].</span>")
				log_combat(user, src, "climbed onto")
				if(climb_stun)
					user.Stun(climb_stun)
				. = 1
			else
				to_chat(user, "<span class='warning'>У меня не вышло взобраться на [src.name].</span>")
	structureclimber = null

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += "<hr><span class='warning'>Оно горит!</span>"
		if(broken)
			. += "<hr><span class='notice'>Оно сломано.</span>"
		var/examine_status = examine_status(user)
		if(examine_status)
			. += "<hr>"
			. += examine_status

/obj/structure/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover.pass_flags & PASSSTRUCTURE)
		return TRUE

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			return  "Виднеются следы царапин."
		if(25 to 50)
			return  "Вмятины видны невооруженным глазом."
		if(0 to 25)
			if(!broken)
				return  "<span class='warning'>Кажется эта штука сейчас развалится!</span>"

/obj/structure/rust_heretic_act()
	take_damage(500, BRUTE, MELEE, 1)
