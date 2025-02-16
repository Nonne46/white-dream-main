/atom/movable
	var/can_buckle = 0
	var/buckle_lying = -1 //bed-like behaviour, forces mob.lying = buckle_lying if != -1
	var/buckle_requires_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/list/mob/living/buckled_mobs = null //list()
	var/max_buckled_mobs = 1
	var/buckle_prevents_pull = FALSE

//Interaction
/atom/movable/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(can_buckle && has_buckled_mobs())
		if(buckled_mobs.len > 1)
			var/unbuckled = input(user, "Кого высаживаем?","А?") as null|mob in sortNames(buckled_mobs)
			if(user_unbuckle_mob(unbuckled,user))
				return 1
		else
			if(user_unbuckle_mob(buckled_mobs[1],user))
				return 1

/atom/movable/attackby(obj/item/W, mob/user, params)
	if(!can_buckle || !istype(W, /obj/item/riding_offhand) || !user.Adjacent(src))
		return ..()

	var/obj/item/riding_offhand/riding_item = W
	var/mob/living/carried_mob = riding_item.rider
	if(carried_mob == user) //Piggyback user.
		return
	user.unbuckle_mob(carried_mob)
	carried_mob.forceMove(get_turf(src))
	return mouse_buckle_handling(carried_mob, user)

//literally just the above extension of attack_hand(), but for silicons instead (with an adjacency check, since attack_robot() being called doesn't mean that you're adjacent to something)
/atom/movable/attack_robot(mob/living/user)
	. = ..()
	if(.)
		return
	if(Adjacent(user) && can_buckle && has_buckled_mobs())
		if(buckled_mobs.len > 1)
			var/unbuckled = input(user, "Who do you wish to unbuckle?","Unbuckle Who?") as null|mob in sortNames(buckled_mobs)
			if(user_unbuckle_mob(unbuckled,user))
				return TRUE
		else
			if(user_unbuckle_mob(buckled_mobs[1],user))
				return TRUE

/atom/movable/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	return mouse_buckle_handling(M, user)

/atom/movable/proc/mouse_buckle_handling(mob/living/M, mob/living/user)
	if(can_buckle && istype(M) && istype(user))
		if(user_buckle_mob(M, user))
			return TRUE

/atom/movable/proc/has_buckled_mobs()
	if(!buckled_mobs)
		return FALSE
	if(buckled_mobs.len)
		return TRUE

//procs that handle the actual buckling and unbuckling
/atom/movable/proc/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!buckled_mobs)
		buckled_mobs = list()

	if(!istype(M))
		return FALSE

	if(check_loc && nearest_turf(M) != nearest_turf(src))
		return FALSE

	if((!can_buckle && !force) || M.buckled || (buckled_mobs.len >= max_buckled_mobs) || (buckle_requires_restraints && !M.restrained()) || M == src)
		return FALSE
	M.buckling = src
	if(!M.can_buckle() && !force)
		if(M == usr)
			to_chat(M, "<span class='warning'>Не могу сесть на [src]!</span>")
		else
			to_chat(usr, "<span class='warning'>Не могу усадить [M] на [src]!</span>")
		M.buckling = null
		return FALSE

	if(M.pulledby)
		if(buckle_prevents_pull)
			M.pulledby.stop_pulling()
		else if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.reset_pull_offsets(M, TRUE)

	if(!check_loc && M.loc != loc)
		M.forceMove(loc, step_x, step_y)

	M.forceStep(null, step_x, step_y)
	M.buckling = null
	M.set_buckled(src)
	M.setDir(dir)
	buckled_mobs |= M
	M.update_mobility()
	M.throw_alert("buckled", /obj/screen/alert/restrained/buckled)
	M.update_movespeed()
	post_buckle_mob(M)

	SEND_SIGNAL(src, COMSIG_MOVABLE_BUCKLE, M, force)
	return TRUE

/obj/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	. = ..()
	if(.)
		if(resistance_flags & ON_FIRE) //Sets the mob on fire if you buckle them to a burning atom/movableect
			M.adjust_fire_stacks(1)
			M.IgniteMob()

/atom/movable/proc/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
	if(istype(buckled_mob) && buckled_mob.buckled == src && (buckled_mob.can_unbuckle() || force))
		. = buckled_mob
		buckled_mob.set_buckled(null)
		buckled_mob.set_anchored(initial(buckled_mob.anchored))
		buckled_mob.update_mobility()
		buckled_mob.clear_alert("buckled")
		buckled_mobs -= buckled_mob
		buckled_mob.update_movespeed()
		SEND_SIGNAL(src, COMSIG_MOVABLE_UNBUCKLE, buckled_mob, force)

		post_unbuckle_mob(.)

/atom/movable/proc/unbuckle_all_mobs(force=FALSE)
	if(!has_buckled_mobs())
		return
	for(var/m in buckled_mobs)
		unbuckle_mob(m, force)

//Handle any extras after buckling
//Called on buckle_mob()
/atom/movable/proc/post_buckle_mob(mob/living/M)

//same but for unbuckle
/atom/movable/proc/post_unbuckle_mob(mob/living/M)

//Wrapper procs that handle sanity and user feedback
/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !isturf(user.loc) || user.incapacitated() || M.anchored)
		return FALSE

	add_fingerprint(user)
	. = buckle_mob(M, check_loc = check_loc)
	if(.)
		if(M == user)
			M.visible_message("<span class='notice'>[M] присаживается на [src].</span>",\
				"<span class='notice'>Присаживаюсь на [src].</span>",\
				"<span class='hear'>Слышу лязг метала.</span>")
		else
			M.visible_message("<span class='warning'>[user] усаживает [M] на [src]!</span>",\
				"<span class='warning'>[user] усаживает меня на [src]!</span>",\
				"<span class='hear'>Слышу лязг метала.</span>")

/atom/movable/proc/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	var/mob/living/M = unbuckle_mob(buckled_mob)
	if(M)
		if(M != user)
			M.visible_message("<span class='notice'>[user] поднимает [M] с [src].</span>",\
				"<span class='notice'>[user] поднмает меня с [src].</span>",\
				"<span class='hear'>Слышу лязг метала.</span>")
		else
			M.visible_message("<span class='notice'>[M] встаёт с [src].</span>",\
				"<span class='notice'>Встаю с [src].</span>",\
				"<span class='hear'>Слышу лязг метала.</span>")
		add_fingerprint(user)
		if(isliving(M.pulledby))
			var/mob/living/L = M.pulledby
			L.set_pull_offsets(M, L.grab_state)
	return M
