
/obj/item/bodypart
	name = "конечность"
	desc = "Почему так нахуй..."
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/mob/human_parts.dmi'
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/status = BODYPART_ORGANIC
	var/needs_processing = FALSE

	var/body_zone //BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/aux_zone // used for hands
	var/aux_layer
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/use_digitigrade = NOT_DIGITIGRADE //Used for alternate legs, useless elsewhere
	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!
	var/is_pseudopart = FALSE //For limbs that don't really exist, eg chainsaws

	var/disabled = BODYPART_NOT_DISABLED //If disabled, limb is as good as missing
	var/body_damage_coeff = 1 //Multiplier of the limb's damage that gets applied to the mob
	var/stam_damage_coeff = 0.75
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_stamina_damage = 0
	var/max_damage = 0

	var/cremation_progress = 0 //Gradually increases while burning when at full damage, destroys the limb when at 100

	var/brute_reduction = 0 //Subtracted to brute damage taken
	var/burn_reduction = 0	//Subtracted to burn damage taken

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/should_draw_gender = FALSE
	var/should_draw_greyscale = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0

	var/animal_origin = null //for nonhuman bodypart (e.g. monkey)
	var/dismemberable = 1 //whether it can be dismembered with a weapon.

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	var/dmg_overlay_type //the type of damage overlay (if any) to use when this bodypart is bruised/burned.

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "травмирована"
	var/medium_brute_msg = "повреждена"
	var/heavy_brute_msg = "разорвана"

	var/light_burn_msg = "обгорела"
	var/medium_burn_msg = "поджарена"
	var/heavy_burn_msg = "отваливается"

	/// The wounds currently afflicting this body part
	var/list/wounds

	/// The scars currently afflicting this body part
	var/list/scars
	/// Our current stored wound damage multiplier
	var/wound_damage_multiplier = 1

	/// This number is subtracted from all wound rolls on this bodypart, higher numbers mean more defense, negative means easier to wound
	var/wound_resistance = 0
	/// When this bodypart hits max damage, this number is added to all wound rolls. Obviously only relevant for bodyparts that have damage caps.
	var/disabled_wound_penalty = 15

	/// A hat won't cover your face, but a shirt covering your chest will cover your... you know, chest
	var/scars_covered_by_clothes = TRUE
	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed
	/// How much generic bleedstacks we have on this bodypart
	var/generic_bleedstacks
	/// If we have a gauze wrapping currently applied (not including splints)
	var/obj/item/stack/current_gauze


/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam > DAMAGE_PRECISION)
		. += "<span class='warning'>Конечность имеет [brute_dam > 30 ? "серьёзные" : "незначительные"] травмы.</span>"
	if(burn_dam > DAMAGE_PRECISION)
		. += "<span class='warning'>Конечность имеет [burn_dam > 30 ? "серьёзные" : "незначительные"] ожоги.</span>"

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone) && !animal_origin)
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				if(!attach_limb(C))
					to_chat(user, "<span class='warning'>[H]'s body rejects [src]!</span>")
					forceMove(H.loc)
				if(H == user)
					H.visible_message("<span class='warning'>[H] впихивает [src] в себя!</span>",\
					"<span class='notice'>Впихиваю [src] в себя и оно вроде как стоит как надо!</span>")
				else
					H.visible_message("<span class='warning'>[user] впихивает [src] в [H]!</span>",\
					"<span class='notice'>[user] впихивает в меня [src] и оно вроде стоит как надо!</span>")
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, "<span class='warning'>А внутри [src] ничего и нет!</span>")
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message("<span class='warning'>[user] начинает вскрывать [src].</span>",\
			"<span class='notice'>Начинаю вскрывать [src]...</span>")
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(status != BODYPART_ROBOTIC)
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, TRUE, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(status != BODYPART_ROBOTIC)
		playsound(T, 'sound/misc/splort.ogg', 50, TRUE, -1)
	if(current_gauze)
		QDEL_NULL(current_gauze)
	for(var/obj/item/organ/drop_organ in get_organs())
		drop_organ.transfer_to_limb(src, owner)
	for(var/obj/item/I in src)
		I.forceMove(T)

///since organs aren't actually stored in the bodypart themselves while attached to a person, we have to query the owner for what we should have
/obj/item/bodypart/proc/get_organs()
	if(!owner)
		return
	. = list()
	for(var/i in owner.internal_organs) //internal organs inside the dismembered limb are dropped.
		var/obj/item/organ/organ_check = i
		if(check_zone(organ_check.zone) == body_zone)
			. += organ_check

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam > DAMAGE_PRECISION)
		. = TRUE
	//else if.. else if.. so on.
	else
		. = FALSE
	needs_processing = .

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(stam_regen)
	if(stamina_dam > DAMAGE_PRECISION && stam_regen)					//DO NOT update health here, it'll be done in the carbon's life.
		heal_damage(0, 0, INFINITY, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE) // maybe separate BRUTE_SHARP and BRUTE_OTHER eventually somehow hmm
	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && (owner.status_flags & GODMODE))
		return FALSE	//godmode

	if(required_status && (status != required_status))
		return FALSE

	var/dmg_mlt = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	brute *= wound_damage_multiplier
	burn *= wound_damage_multiplier

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	/*
	// START WOUND HANDLING
	*/

	// what kind of wounds we're gonna roll for, take the greater between brute and burn, then if it's brute, we subdivide based on sharpness
	var/wounding_type = (brute > burn ? WOUND_BLUNT : WOUND_BURN)
	var/wounding_dmg = max(brute, burn)

	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	if(wounding_type == WOUND_BLUNT)
		if(sharpness == SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if(sharpness == SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Handling for bone only/flesh only(none right now)/flesh and bone targets
	switch(bio_state)
		// if we're bone only, all cutting attacks go straight to the bone
		if(BIO_JUST_BONE)
			if(wounding_type == WOUND_SLASH)
				wounding_type = WOUND_BLUNT
				wounding_dmg *= (easy_dismember ? 1 : 0.5)
			else if(wounding_type == WOUND_PIERCE)
				wounding_type = WOUND_BLUNT
				wounding_dmg *= (easy_dismember ? 1 : 0.75)
			if((mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// note that there's no handling for BIO_JUST_FLESH since we don't have any that are that right now (slimepeople maybe someday)
		// standard humanoids
		if(BIO_FLESH_BONE)
			// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
			// So a big sharp weapon is still all you need to destroy a limb
			if(mangled_state == BODYPART_MANGLED_FLESH && sharpness)
				playsound(src, "sound/effects/wounds/crackandbleed.ogg", 100)
				if(wounding_type == WOUND_SLASH && !easy_dismember)
					wounding_dmg *= 0.5 // edged weapons pass along 50% of their wounding damage to the bone since the power is spread out over a larger area
				if(wounding_type == WOUND_PIERCE && !easy_dismember)
					wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
				wounding_type = WOUND_BLUNT
			else if(mangled_state == BODYPART_MANGLED_BOTH && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
				return

	// now we have our wounding_type and are ready to carry on with wounds and dealing the actual damage
	if(owner && wounding_dmg >= WOUND_MINIMUM_DAMAGE && wound_bonus != CANT_WOUND)
		check_wounding(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)

	for(var/i in wounds)
		var/datum/wound/iter_wound = i
		iter_wound.receive_damage(wounding_type, wounding_dmg, wound_bonus)

	/*
	// END WOUND HANDLING
	*/

	//back to our regularly scheduled program, we now actually apply damage if there's room below limb damage cap
	var/can_inflict = max_damage - get_damage()
	var/total_damage = brute + burn
	if(total_damage > can_inflict && total_damage > 0) // TODO: the second part of this check should be removed once disabling is all done
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	if(can_inflict <= 0)
		return FALSE

	brute_dam += brute
	burn_dam += burn

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	stamina_dam += round(clamp(stamina, 0, max_stamina_damage - stamina_dam), DAMAGE_PRECISION)

	if(owner && updating_health)
		owner.updatehealth()
		if(stamina > DAMAGE_PRECISION)
			owner.update_stamina()
			owner.stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME
			. = TRUE
	consider_processing()
	update_disabled()
	return update_bodypart_damage_state() || .

/// Allows us to roll for and apply a wound without actually dealing damage. Used for aggregate wounding power with pellet clouds
/obj/item/bodypart/proc/painless_wound_roll(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus, sharpness=SHARP_NONE)
	if(!owner || phantom_wounding_dmg <= WOUND_MINIMUM_DAMAGE || wound_bonus == CANT_WOUND)
		return

	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	if(wounding_type == WOUND_BLUNT)
		if(sharpness == SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if(sharpness == SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Handling for bone only/flesh only(none right now)/flesh and bone targets
	switch(bio_state)
		// if we're bone only, all cutting attacks go straight to the bone
		if(BIO_JUST_BONE)
			if(wounding_type == WOUND_SLASH)
				wounding_type = WOUND_BLUNT
				phantom_wounding_dmg *= (easy_dismember ? 1 : 0.5)
			else if(wounding_type == WOUND_PIERCE)
				wounding_type = WOUND_BLUNT
				phantom_wounding_dmg *= (easy_dismember ? 1 : 0.75)
			if((mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// note that there's no handling for BIO_JUST_FLESH since we don't have any that are that right now (slimepeople maybe someday)
		// standard humanoids
		if(BIO_FLESH_BONE)
			// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
			// So a big sharp weapon is still all you need to destroy a limb
			if(mangled_state == BODYPART_MANGLED_FLESH && sharpness)
				playsound(src, "sound/effects/wounds/crackandbleed.ogg", 100)
				if(wounding_type == WOUND_SLASH && !easy_dismember)
					phantom_wounding_dmg *= 0.5 // edged weapons pass along 50% of their wounding damage to the bone since the power is spread out over a larger area
				if(wounding_type == WOUND_PIERCE && !easy_dismember)
					phantom_wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
				wounding_type = WOUND_BLUNT
			else if(mangled_state == BODYPART_MANGLED_BOTH && try_dismember(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus))
				return

	check_wounding(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus)

/**
  * check_wounding() is where we handle rolling for, selecting, and applying a wound if we meet the criteria
  *
  * We generate a "score" for how woundable the attack was based on the damage and other factors discussed in [/obj/item/bodypart/proc/check_wounding_mods], then go down the list from most severe to least severe wounds in that category.
  * We can promote a wound from a lesser to a higher severity this way, but we give up if we have a wound of the given type and fail to roll a higher severity, so no sidegrades/downgrades
  *
  * Arguments:
  * * woundtype- Either WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE, or WOUND_BURN based on the attack type.
  * * damage- How much damage is tied to this attack, since wounding potential scales with damage in an attack (see: WOUND_DAMAGE_EXPONENT)
  * * wound_bonus- The wound_bonus of an attack
  * * bare_wound_bonus- The bare_wound_bonus of an attack
  */
/obj/item/bodypart/proc/check_wounding(woundtype, damage, wound_bonus, bare_wound_bonus)
	// actually roll wounds if applicable
	if(HAS_TRAIT(owner, TRAIT_EASYLIMBWOUND))
		damage *= 1.5
	else
		damage = min(damage, WOUND_MAX_CONSIDERED_DAMAGE)
	if(HAS_TRAIT(owner,TRAIT_HARDLIMBWOUND))
		damage *= 0.9

	if(HAS_TRAIT(owner, TRAIT_EASYDISMEMBER))
		damage *= 1.25

	var/base_roll = rand(1, round(damage ** WOUND_DAMAGE_EXPONENT))
	var/injury_roll = base_roll
	injury_roll += check_woundings_mods(woundtype, damage, wound_bonus, bare_wound_bonus)
	var/list/wounds_checking = GLOB.global_wound_types[woundtype]

	// quick re-check to see if bare_wound_bonus applies, for the benefit of log_wound(), see about getting the check from check_woundings_mods() somehow
	if(ishuman(owner))
		var/mob/living/carbon/human/human_wearer = owner
		var/list/clothing = human_wearer.clothingonpart(src)
		for(var/i in clothing)
			var/obj/item/clothing/clothes_check = i
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			if(clothes_check.armor.getRating(WOUND))
				bare_wound_bonus = 0
				break

	//cycle through the wounds of the relevant category from the most severe down
	for(var/PW in wounds_checking)
		var/datum/wound/possible_wound = PW
		var/datum/wound/replaced_wound
		for(var/i in wounds)
			var/datum/wound/existing_wound = i
			if(existing_wound.type in wounds_checking)
				if(existing_wound.severity >= initial(possible_wound.severity))
					return
				else
					replaced_wound = existing_wound

		if(initial(possible_wound.threshold_minimum) < injury_roll)
			var/datum/wound/new_wound
			if(replaced_wound)
				new_wound = replaced_wound.replace_wound(possible_wound)
				log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll) // dismembering wounds are logged in the apply_wound() for loss wounds since they delete themselves immediately, these will be immediately returned
			else
				new_wound = new possible_wound
				new_wound.apply_wound(src)
				log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll)
			return new_wound

// try forcing a specific wound, but only if there isn't already a wound of that severity or greater for that type on this bodypart
/obj/item/bodypart/proc/force_wound_upwards(specific_woundtype, smited = FALSE)
	var/datum/wound/potential_wound = specific_woundtype
	for(var/i in wounds)
		var/datum/wound/existing_wound = i
		if(existing_wound.wound_type == initial(potential_wound.wound_type))
			if(existing_wound.severity < initial(potential_wound.severity)) // we only try if the existing one is inferior to the one we're trying to force
				existing_wound.replace_wound(potential_wound, smited)
			return

	var/datum/wound/new_wound = new potential_wound
	new_wound.apply_wound(src, smited = smited)

/**
  * check_wounding_mods() is where we handle the various modifiers of a wound roll
  *
  * A short list of things we consider: any armor a human target may be wearing, and if they have no wound armor on the limb, if we have a bare_wound_bonus to apply, plus the plain wound_bonus
  * We also flick through all of the wounds we currently have on this limb and add their threshold penalties, so that having lots of bad wounds makes you more liable to get hurt worse
  * Lastly, we add the inherent wound_resistance variable the bodypart has (heads and chests are slightly harder to wound), and a small bonus if the limb is already disabled
  *
  * Arguments:
  * * It's the same ones on [receive_damage]
  */
/obj/item/bodypart/proc/check_woundings_mods(wounding_type, damage, wound_bonus, bare_wound_bonus)
	var/armor_ablation = 0
	var/injury_mod = 0

	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/list/clothing = H.clothingonpart(src)
		for(var/c in clothing)
			var/obj/item/clothing/C = c
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			armor_ablation += C.armor.getRating(WOUND)
			if(wounding_type == WOUND_SLASH)
				C.take_damage_zone(body_zone, damage, BRUTE, armour_penetration)
			else if(wounding_type == WOUND_BURN && damage >= 10) // lazy way to block freezing from shredding clothes without adding another var onto apply_damage()
				C.take_damage_zone(body_zone, damage, BURN, armour_penetration)

		if(!armor_ablation)
			injury_mod += bare_wound_bonus

	injury_mod -= armor_ablation
	injury_mod += wound_bonus

	for(var/thing in wounds)
		var/datum/wound/W = thing
		injury_mod += W.threshold_penalty

	var/part_mod = -wound_resistance
	if(get_damage(TRUE) >= max_damage)
		part_mod += disabled_wound_penalty

	injury_mod += part_mod

	return injury_mod

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)

	if(required_status && (status != required_status)) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	brute_dam	= round(max(brute_dam - brute, 0), DAMAGE_PRECISION)
	burn_dam	= round(max(burn_dam - burn, 0), DAMAGE_PRECISION)
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	consider_processing()
	update_disabled()
	cremation_progress = min(0, cremation_progress - ((brute_dam + burn_dam)*(100/max_damage)))
	return update_bodypart_damage_state()

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	if(!owner)
		return
	set_disabled(is_disabled())

/obj/item/bodypart/proc/is_disabled()
	if(!owner)
		return
	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		return BODYPART_DISABLED_PARALYSIS
	for(var/i in wounds)
		var/datum/wound/W = i
		if(W.disabling)
			return BODYPART_DISABLED_WOUND
	if(can_dismember() && !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
		. = disabled //inertia, to avoid limbs healing 0.1 damage and being re-enabled

		if(get_damage(TRUE) >= max_damage * (HAS_TRAIT(owner, TRAIT_EASYLIMBWOUND) ? 0.6 : 1)) //Easy limb disable disables the limb at 40% health instead of 0%
			if(!last_maxed)
				owner.emote("scream")
				last_maxed = TRUE
			if(!is_organic_limb() || stamina_dam >= max_damage)
				return BODYPART_DISABLED_DAMAGE
		else if(disabled && (get_damage(TRUE) <= (max_damage * 0.8))) // reenabled at 80% now instead of 50% as of wounds update
			last_maxed = FALSE
			return BODYPART_NOT_DISABLED
	else
		return BODYPART_NOT_DISABLED
	return BODYPART_NOT_DISABLED

/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(disabled == new_disabled || !owner)
		return
	disabled = new_disabled
	if(disabled && owner.get_item_for_held_index(held_index))
		owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	owner.update_health_hud() //update the healthdoll
	owner.update_body()
	owner.update_mobility()
	return TRUE //if there was a change.

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//Change organ status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default)
	status = new_limb_status
	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0

	if(change_icon_to_default)
		if(status == BODYPART_ORGANIC)
			icon = DEFAULT_BODYPART_ICON_ORGANIC
		else if(status == BODYPART_ROBOTIC)
			icon = DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()

/obj/item/bodypart/proc/is_organic_limb()
	return (status == BODYPART_ORGANIC)

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
	else
		C = owner
		if(original_owner && owner != original_owner) //Foreign limb
			no_update = TRUE
		else
			no_update = FALSE

	if(HAS_TRAIT(C, TRAIT_HUSK) && is_organic_limb())
		species_id = "husk" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when husked
		should_draw_gender = FALSE
		should_draw_greyscale = FALSE
		no_update = TRUE

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/H = C
		should_draw_greyscale = FALSE

		var/datum/species/S = H.dna.species
		species_id = S.limbs_id
		species_flags_list = H.dna.species.species_traits

		if(S.use_skintones)
			skin_tone = H.skin_tone
			should_draw_greyscale = TRUE
		else
			skin_tone = ""

		body_gender = H.body_type
		should_draw_gender = S.sexes

		if((MUTCOLORS in S.species_traits) || (DYNCOLORS in S.species_traits))
			if(S.fixed_mut_color)
				species_color = S.fixed_mut_color
			else
				species_color = H.dna.features["mcolor"]
			should_draw_greyscale = TRUE
		else
			species_color = ""

		if(!dropping_limb && H.dna.check_mutation(HULK))
			mutation_color = "00aa00"
		else
			mutation_color = ""

		dmg_overlay_type = S.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(status == BODYPART_ROBOTIC)
		dmg_overlay_type = "robotic"

	if(dropping_limb)
		no_update = TRUE //when attached, the limb won't be affected by the appearance changes of its mob owner.

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(1)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

//Gives you a proper icon appearance for the dismembered limb
/obj/item/bodypart/proc/get_limb_icon(dropped)
	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/image/aux
	. += limb

	if(animal_origin)
		if(is_organic_limb())
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		return

	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if((body_zone != BODY_ZONE_HEAD && body_zone != BODY_ZONE_CHEST))
		should_draw_gender = FALSE

	if(is_organic_limb())
		if(should_draw_greyscale)
			limb.icon = 'icons/mob/human_parts_greyscale.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else if(use_digitigrade)
				limb.icon_state = "digitigrade_[use_digitigrade]_[body_zone]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		else
			limb.icon = 'icons/mob/human_parts.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		// hippie start -- Hippie races (e.g. Avians)
		if(should_draw_hippie)
			limb.icon = 'white/valtos/icons/dwarfs/mutant_bodyparts.dmi'
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else
				limb.icon_state = "[species_id]_[body_zone]"
		// hippie end
		if(aux_zone)
			aux = image(limb.icon, "[species_id]_[aux_zone]", -aux_layer, image_dir)
			. += aux

	else
		limb.icon = icon
		if(should_draw_gender)
			limb.icon_state = "[body_zone]_[icon_gender]"
		else
			limb.icon_state = "[body_zone]"
		if(aux_zone)
			aux = image(limb.icon, "[aux_zone]", -aux_layer, image_dir)
			. += aux
		if(should_draw_white)
			limb.icon = 'white/valtos/icons/android_skins.dmi'
			limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
		return

	if(should_draw_greyscale)
		var/draw_color = mutation_color || species_color || (skin_tone && skintone2hex(skin_tone))
		if(draw_color)
			limb.color = "#[draw_color]"
			if(aux_zone)
				aux.color = "#[draw_color]"

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/// Get whatever wound of the given type is currently attached to this limb, if any
/obj/item/bodypart/proc/get_wound_type(checking_type)
	if(isnull(wounds))
		return

	for(var/i in wounds)
		if(istype(i, checking_type))
			return i

/**
  * update_wounds() is called whenever a wound is gained or lost on this bodypart, as well as if there's a change of some kind on a bone wound possibly changing disabled status
  *
  * Covers tabulating the damage multipliers we have from wounds (burn specifically), as well as deleting our gauze wrapping if we don't have any wounds that can use bandaging
  *
  * Arguments:
  * * replaced- If true, this is being called from the remove_wound() of a wound that's being replaced, so the bandage that already existed is still relevant, but the new wound hasn't been added yet
  */
/obj/item/bodypart/proc/update_wounds(replaced = FALSE)
	var/dam_mul = 1 //initial(wound_damage_multiplier)

	// we can (normally) only have one wound per type, but remember there's multiple types (smites like :B:loodless can generate multiple cuts on a limb)
	for(var/i in wounds)
		var/datum/wound/iter_wound = i
		dam_mul *= iter_wound.damage_mulitplier_penalty

	if(!LAZYLEN(wounds) && current_gauze && !replaced)
		owner.visible_message("<span class='notice'>\The [current_gauze] on [owner]'s [name] fall away.</span>", "<span class='notice'>The [current_gauze] on your [name] fall away.</span>")
		QDEL_NULL(current_gauze)

	wound_damage_multiplier = dam_mul
	update_disabled()

/obj/item/bodypart/proc/get_bleed_rate()
	if(status != BODYPART_ORGANIC) // maybe in the future we can bleed oil from aug parts, but not now
		return

	var/bleed_rate = 0
	if(generic_bleedstacks > 0)
		bleed_rate++

	//We want an accurate reading of .len
	listclearnulls(embedded_objects)
	for(var/obj/item/embeddies in embedded_objects)
		if(!embeddies.isEmbedHarmless())
			bleed_rate += 0.5

	for(var/thing in wounds)
		var/datum/wound/W = thing
		bleed_rate += W.blood_flow

	if(owner.mobility_flags & ~MOBILITY_STAND)
		bleed_rate *= 0.75
	return bleed_rate

/**
  * apply_gauze() is used to- well, apply gauze to a bodypart
  *
  * As of the Wounds 2 PR, all bleeding is now bodypart based rather than the old bleedstacks system, and 90% of standard bleeding comes from flesh wounds (the exception is embedded weapons).
  * The same way bleeding is totaled up by bodyparts, gauze now applies to all wounds on the same part. Thus, having a slash wound, a pierce wound, and a broken bone wound would have the gauze
  * applying blood staunching to the first two wounds, while also acting as a sling for the third one. Once enough blood has been absorbed or all wounds with the ACCEPTS_GAUZE flag have been cleared,
  * the gauze falls off.
  *
  * Arguments:
  * * gauze- Just the gauze stack we're taking a sheet from to apply here
  */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/gauze)
	if(!istype(gauze) || !gauze.absorption_capacity)
		return
	QDEL_NULL(current_gauze)
	current_gauze = new gauze.type(src, 1)
	gauze.use(1)

/**
  * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
  *
  * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages fall off and we're left with nothing.
  *
  * Arguments:
  * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
  */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	if(current_gauze.absorption_capacity < 0)
		owner.visible_message("<span class='danger'>\The [current_gauze] on [owner]'s [name] fall away in rags.</span>", "<span class='warning'>\The [current_gauze] on your [name] fall away in rags.</span>", vision_distance=COMBAT_MESSAGE_RANGE)
		QDEL_NULL(current_gauze)
