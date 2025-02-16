/obj/item/stack/sheet
	name = "лист"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	full_w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	attack_verb_continuous = list("лупит", "бьёт", "разбивает", "вмазывает", "атакует")
	attack_verb_simple = list("лупит", "бьёт", "разбивает", "вмазывает", "атакует")
	novariants = FALSE
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	var/point_value = 0 //turn-in value for the gulag stacker - loosely relative to its rarity.
	///What type of wall does this sheet spawn
	var/walltype

/obj/item/stack/sheet/Initialize(mapload, new_amount, merge)
	. = ..()
	if(loc)
		forceMove(loc, rand(-4, 4), rand(-4, 4))

/**
 * Facilitates sheets being smacked on the floor
 *
 * This is used for crafting by hitting the floor with items.
 * The inital use case is glass sheets breaking in to shards when the floor is hit.
 * Args:
 * * user: The user that did the action
 * * params: paramas passed in from attackby
 */
/obj/item/stack/sheet/proc/on_attack_floor(mob/user, params)
	var/list/shards = list()
	for(var/datum/material/mat in custom_materials)
		if(mat.shard_type)
			var/obj/item/new_shard = new mat.shard_type(user.loc)
			new_shard.add_fingerprint(user)
			shards += "[new_shard.name]"
	if(!shards.len)
		return FALSE
	user.do_attack_animation(src, ATTACK_EFFECT_BOOP)
	playsound(src, "shatter", 70, TRUE)
	use(1)
	user.visible_message("<span class='notice'>[user] shatters the sheet of [name] on the floor, leaving [english_list(shards)].</span>", \
		"<span class='notice'>You shatter the sheet of [name] on the floor, leaving [english_list(shards)].</span>")
	return TRUE
