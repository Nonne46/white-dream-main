GLOBAL_LIST_EMPTY(station_turfs)
/turf
	icon = 'icons/turf/floors.dmi'
	flags_1 = CAN_BE_DIRTY_1
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE // Important for interaction with and visualization of openspace.
	luminosity = 1

	var/intact = 1

	// baseturfs can be either a list or a single turf type.
	// In class definition like here it should always be a single type.
	// A list will be created in initialization that figures out the baseturf's baseturf etc.
	// In the case of a list it is sorted from bottom layer to top.
	// This shouldn't be modified directly, use the helper procs.
	var/list/baseturfs = /turf/baseturf_bottom

	var/temperature = T20C
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

	var/blocks_air = FALSE

	var/list/image/blueprint_data //for the station blueprints, images of objects eg: pipes

	var/explosion_level = 0	//for preventing explosion dodging
	var/explosion_id = 0
	var/list/explosion_throw_details

	var/requires_activation	//add to air processing after initialize?
	var/changing_turf = FALSE

	var/bullet_bounce_sound = 'sound/weapons/gun/general/mag_bullet_remove.ogg' //sound played when a shell casing is ejected ontop of the turf.
	var/bullet_sizzle = FALSE //used by ammo_casing/bounce_away() to determine if the shell casing should make a sizzle sound when it's ejected over the turf
							//IE if the turf is supposed to be water, set TRUE.

	var/tiled_dirt = FALSE // use smooth tiled dirt decal

	///Icon-smoothing variable to map a diagonal wall corner with a fixed underlay.
	var/list/fixed_underlay = null

	///Lumcount added by sources other than lighting datum objects, such as the overlay lighting component.
	var/dynamic_lumcount = 0

	var/dynamic_lighting = TRUE

	var/tmp/lighting_corners_initialised = FALSE

	///List of light sources affecting this turf.
	var/tmp/list/datum/light_source/affecting_lights
	///Our lighting object.
	var/tmp/atom/movable/lighting_object/lighting_object
	var/tmp/list/datum/lighting_corner/corners

	///Which directions does this turf block the vision of, taking into account both the turf's opacity and the movable opacity_sources.
	var/directional_opacity = NONE
	///Lazylist of movable atoms providing opacity sources.
	var/list/atom/movable/opacity_sources


/turf/vv_edit_var(var_name, new_value)
	var/static/list/banned_edits = list("x", "y", "z")
	if(var_name in banned_edits)
		return FALSE
	. = ..()

/**
  * Turf Initialize
  *
  * Doesn't call parent, see [/atom/proc/Initialize]
  */
/turf/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	// by default, vis_contents is inherited from the turf that was here before
	vis_contents.Cut()

	assemble_baseturfs()

	levelupdate()

	if (length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if (length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)
	if (smoothing_flags)
		QUEUE_SMOOTH(src)

	visibilityChanged()

	for(var/atom/movable/AM in src)
		Entered(AM)

	var/area/A = loc
	if(!IS_DYNAMIC_LIGHTING(src) && IS_DYNAMIC_LIGHTING(A))
		add_overlay(/obj/effect/fullbright)

	if(requires_activation)
		CALCULATE_ADJACENT_TURFS(src)
		SSair.add_to_active(src)

	if (light_power && light_range)
		update_light()

	var/turf/T = SSmapping.get_turf_above(src)
	if(T)
		T.multiz_turf_new(src, DOWN)
		SEND_SIGNAL(T, COMSIG_TURF_MULTIZ_NEW, src, DOWN)
	T = SSmapping.get_turf_below(src)
	if(T)
		T.multiz_turf_new(src, UP)
		SEND_SIGNAL(T, COMSIG_TURF_MULTIZ_NEW, src, UP)

	if (opacity)
		directional_opacity = ALL_CARDINALS

	// apply materials properly from the default custom_materials value
	set_custom_materials(custom_materials)

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

/turf/proc/Initalize_Atmos(times_fired)
	CALCULATE_ADJACENT_TURFS(src)

/turf/Destroy(force)
	. = QDEL_HINT_IWILLGC
	if(!changing_turf)
		stack_trace("Incorrect turf deletion")
	changing_turf = FALSE
	var/turf/T = SSmapping.get_turf_above(src)
	if(T)
		T.multiz_turf_del(src, DOWN)
	T = SSmapping.get_turf_below(src)
	if(T)
		T.multiz_turf_del(src, UP)
	if(force)
		..()
		//this will completely wipe turf state
		var/turf/B = new world.turf(src)
		for(var/A in B.contents)
			qdel(A)
		return
	SSair.remove_from_active(src)
	visibilityChanged()
	QDEL_LIST(blueprint_data)
	flags_1 &= ~INITIALIZED_1
	requires_activation = FALSE
	..()

/turf/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src, user.client?.mouseParams)

/turf/proc/multiz_turf_del(turf/T, dir)

/turf/proc/multiz_turf_new(turf/T, dir)

///returns if the turf has something dense inside it. if exclude_mobs is true, skips dense mobs like fat yoshi.
/turf/proc/is_blocked_turf(exclude_mobs)
	if(density)
		return TRUE
	for(var/i in contents)
		var/atom/thing = i
		if(thing.density && (!exclude_mobs || !ismob(thing)))
			return TRUE
	return FALSE

//zPassIn doesn't necessarily pass an atom!
//direction is direction of travel of air
/turf/proc/zPassIn(atom/movable/A, direction, turf/source)
	return FALSE

//direction is direction of travel of air
/turf/proc/zPassOut(atom/movable/A, direction, turf/destination)
	return FALSE

//direction is direction of travel of air
/turf/proc/zAirIn(direction, turf/source)
	return FALSE

//direction is direction of travel of air
/turf/proc/zAirOut(direction, turf/source)
	return FALSE

/turf/proc/zImpact(atom/movable/A, levels = 1, turf/prev_turf)
	var/flags = NONE
	var/mov_name = A.name
	for(var/i in contents)
		var/atom/thing = i
		flags |= thing.intercept_zImpact(A, levels)
		if(flags & FALL_STOP_INTERCEPTING)
			break
	if(prev_turf && !(flags & FALL_NO_MESSAGE))
		prev_turf.visible_message("<span class='danger'>[mov_name] falls through [prev_turf]!</span>")
	if(flags & FALL_INTERCEPTED)
		return
	if(zFall(A, ++levels))
		return FALSE
	A.visible_message("<span class='danger'>[A] crashes into [src]!</span>")
	A.onZImpact(src, levels)
	return TRUE

/turf/proc/can_zFall(atom/movable/A, levels = 1, turf/target)
	SHOULD_BE_PURE(TRUE)
	return zPassOut(A, DOWN, target) && target.zPassIn(A, DOWN, src)

/turf/proc/zFall(atom/movable/A, levels = 1, force = FALSE)
	var/turf/target = get_step_multiz(src, DOWN)
	if(!target || (!isobj(A) && !ismob(A)))
		return FALSE
	if(!force && (!can_zFall(A, levels, target) || !A.can_zFall(src, levels, target, DOWN)))
		return FALSE
	A.zfalling = TRUE
	A.forceMove(target)
	A.zfalling = FALSE
	target.zImpact(A, levels, src)
	return TRUE

/turf/proc/handleRCL(obj/item/rcl/C, mob/user)
	if(C.loaded)
		for(var/obj/structure/pipe_cleaner/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.handlecable(C, user)
				return
		C.loaded.place_turf(src, user)
		if(C.wiring_gui_menu)
			C.wiringGuiUpdate(user)
		C.is_empty(user)

/turf/attackby(obj/item/C, mob/user, params)
	if(..())
		return TRUE
	if(can_lay_cable() && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		coil.place_turf(src, user)
		return TRUE
	else if(can_have_cabling() && istype(C, /obj/item/stack/pipe_cleaner_coil))
		var/obj/item/stack/pipe_cleaner_coil/coil = C
		for(var/obj/structure/pipe_cleaner/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.attackby(C, user)
				return
		coil.place_turf(src, user)
		return TRUE

	else if(istype(C, /obj/item/rcl))
		handleRCL(C, user)

	return FALSE

/turf/Cross(atom/movable/mover)
	return CanPass(mover, src)


/turf/open/Entered(atom/movable/AM)
	..()
	//melting
	if(isobj(AM) && air && air.return_temperature() > T0C)
		var/obj/O = AM
		if(O.obj_flags & FROZEN)
			O.make_unfrozen()
	if(!AM.zfalling)
		zFall(AM)

// A proc in case it needs to be recreated or badmins want to change the baseturfs
/turf/proc/assemble_baseturfs(turf/fake_baseturf_type)
	var/static/list/created_baseturf_lists = list()
	var/turf/current_target
	if(fake_baseturf_type)
		if(length(fake_baseturf_type)) // We were given a list, just apply it and move on
			baseturfs = fake_baseturf_type
			return
		current_target = fake_baseturf_type
	else
		if(length(baseturfs))
			return // No replacement baseturf has been given and the current baseturfs value is already a list/assembled
		if(!baseturfs)
			current_target = initial(baseturfs) || type // This should never happen but just in case...
			stack_trace("baseturfs var was null for [type]. Failsafe activated and it has been given a new baseturfs value of [current_target].")
		else
			current_target = baseturfs

	// If we've made the output before we don't need to regenerate it
	if(created_baseturf_lists[current_target])
		var/list/premade_baseturfs = created_baseturf_lists[current_target]
		if(length(premade_baseturfs))
			baseturfs = premade_baseturfs.Copy()
		else
			baseturfs = premade_baseturfs
		return baseturfs

	var/turf/next_target = initial(current_target.baseturfs)
	//Most things only have 1 baseturf so this loop won't run in most cases
	if(current_target == next_target)
		baseturfs = current_target
		created_baseturf_lists[current_target] = current_target
		return current_target
	var/list/new_baseturfs = list(current_target)
	for(var/i=0;current_target != next_target;i++)
		if(i > 100)
			// A baseturfs list over 100 members long is silly
			// Because of how this is all structured it will only runtime/message once per type
			stack_trace("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			message_admins("A turf <[type]> created a baseturfs list over 100 members long. This is most likely an infinite loop.")
			break
		new_baseturfs.Insert(1, next_target)
		current_target = next_target
		next_target = initial(current_target.baseturfs)

	baseturfs = new_baseturfs
	created_baseturf_lists[new_baseturfs[new_baseturfs.len]] = new_baseturfs.Copy()
	return new_baseturfs

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.flags_1 & INITIALIZED_1)
			SEND_SIGNAL(O, COMSIG_OBJ_HIDE, intact)

// override for space turfs, since they should never hide anything
/turf/open/space/levelupdate()
	return

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L && (L.flags_1 & INITIALIZED_1))
		qdel(L)

/turf/proc/Bless()
	new /obj/effect/blessing(src)

/turf/storage_contents_dump_act(datum/component/storage/src_object, mob/user)
	. = ..()
	if(.)
		return
	if(length(src_object.contents()))
		to_chat(usr, "<span class='notice'>You start dumping out the contents...</span>")
		if(!do_after(usr,20,target=src_object.parent))
			return FALSE

	var/list/things = src_object.contents()
	var/datum/progressbar/progress = new(user, things.len, src)
	while (do_after(usr, 10, TRUE, src, FALSE, CALLBACK(src_object, /datum/component/storage.proc/mass_remove_from_storage, src, things, progress)))
		stoplag(1)
	progress.end_progress()

	return TRUE

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T)
		return FALSE
	return abs(x - T.x) + abs(y - T.y)

////////////////////////////////////////////////////

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
				O.singularity_act()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	return(2)

/turf/proc/can_have_cabling()
	return TRUE

/turf/proc/can_lay_cable()
	return can_have_cabling() & !intact

/turf/proc/visibilityChanged()
	GLOB.cameranet.updateVisibility(src)
	// The cameranet usually handles this for us, but if we've just been
	// recreated we should make sure we have the cameranet vis_contents.
	var/datum/camerachunk/C = GLOB.cameranet.chunkGenerated(x, y, z)
	if(C)
		if(C.obscuredTurfs[src])
			vis_contents += GLOB.cameranet.vis_contents_objects
		else
			vis_contents -= GLOB.cameranet.vis_contents_objects

/turf/proc/burn_tile()

/turf/proc/is_shielded()


/turf/contents_explosion(severity, target)
	for(var/thing in contents)
		var/atom/movable/movable_thing = thing
		if(QDELETED(movable_thing))
			continue
		if(!movable_thing.ex_check(explosion_id))
			continue
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += movable_thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += movable_thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += movable_thing


/turf/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/proc/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = icon
	underlay_appearance.icon_state = icon_state
	underlay_appearance.dir = adjacency_dir
	return TRUE

/turf/proc/add_blueprints(atom/movable/AM)
	var/image/I = new
	I.appearance = AM.appearance
	I.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	I.loc = src
	I.setDir(AM.dir)
	I.alpha = 128
	LAZYADD(blueprint_data, I)

/turf/proc/add_blueprints_preround(atom/movable/AM)
	if(!SSticker.HasRoundStarted())
		if(AM.layer == WIRE_LAYER)	//wires connect to adjacent positions after its parent init, meaning we need to wait (in this case, until smoothing) to take its image
			SSicon_smooth.blueprint_queue += AM
		else
			add_blueprints(AM)

/turf/proc/is_transition_turf()
	return

/turf/acid_act(acidpwr, acid_volume)
	. = 1
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = FALSE
	for(var/obj/O in src)
		if(intact && HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			return
		if(istype(O, acid_type))
			var/obj/effect/acid/A = O
			A.acid_level = min(acid_volume * acidpwr, 12000)//capping acid level to limit power of the acid
			has_acid_effect = 1
			continue
		O.acid_act(acidpwr, acid_volume)
	if(!has_acid_effect)
		new acid_type(src, acidpwr, acid_volume)

/turf/proc/acid_melt()
	return

/turf/handle_fall(mob/faller)
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, TRUE)
	faller.drop_all_held_items()

/turf/proc/photograph(limit=20)
	var/image/I = new()
	I.add_overlay(src)
	for(var/V in contents)
		var/atom/A = V
		if(A.invisibility)
			continue
		I.add_overlay(A)
		if(limit)
			limit--
		else
			return I
	return I

/turf/AllowDrop()
	return TRUE

/turf/proc/add_vomit_floor(mob/living/M, toxvomit = NONE, purge = FALSE)

	var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(src, M.get_static_viruses())
	V.forceStep(null, M.step_x, M.step_y)

	//if the vomit combined, apply toxicity and reagents to the old vomit
	if (QDELETED(V))
		V = locate() in src
	if(!V)
		return
	// Make toxins and blazaam vomit look different
	if(toxvomit == VOMIT_PURPLE)
		V.icon_state = "vomitpurp_[pick(1,4)]"
	else if (toxvomit == VOMIT_TOXIC)
		V.icon_state = "vomittox_[pick(1,4)]"
	if (iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.reagents)
			clear_reagents_to_vomit_pool(C,V, purge)

/proc/clear_reagents_to_vomit_pool(mob/living/carbon/M, obj/effect/decal/cleanable/vomit/V, purge = FALSE)
	var/chemicals_lost = M.reagents.total_volume / 10
	if(purge)
		chemicals_lost = (2 * M.reagents.total_volume)/3				//For detoxification surgery, we're manually pumping the stomach out of chemcials, so it's far more efficient.
	M.reagents.trans_to(V, chemicals_lost, transfered_by = M)
	for(var/datum/reagent/R in M.reagents.reagent_list)                //clears the stomach of anything that might be digested as food
		if(istype(R, /datum/reagent/consumable) || purge)
			var/datum/reagent/consumable/nutri_check = R
			if(nutri_check.nutriment_factor >0)
				M.reagents.remove_reagent(R.type, min(R.volume, 10))

//Whatever happens after high temperature fire dies out or thermite reaction works.
//Should return new turf
/turf/proc/Melt()
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/bullet_act(obj/projectile/P)
	. = ..()
	if(. != BULLET_ACT_FORCE_PIERCE)
		. =  BULLET_ACT_TURF

/// Handles exposing a turf to reagents.
/turf/expose_reagents(list/reagents, datum/reagents/source, method=TOUCH, volume_modifier=1, show_message=TRUE)
	if((. = ..()) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_turf(src, reagents[R])

/**
  * Called when this turf is being washed. Washing a turf will also wash any mopable floor decals
  */
/turf/wash(clean_types)
	. = ..()

	for(var/am in src)
		if(am == src)
			continue
		var/atom/movable/movable_content = am
		if(!ismopable(movable_content))
			continue
		movable_content.wash(clean_types)
