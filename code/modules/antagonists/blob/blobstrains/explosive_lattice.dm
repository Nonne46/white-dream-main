//does aoe brute damage when hitting targets, is immune to explosions
/datum/blobstrain/reagent/explosive_lattice
	name = "Explosive Lattice"
	description = "will do brute damage in an area around targets."
	effectdesc = "will also resist explosions, but takes increased damage from fire and other energy sources."
	analyzerdescdamage = "Does medium brute damage and causes damage to everyone near its targets.  Spores explode on death."
	analyzerdesceffect = "Is highly resistant to explosions, but takes increased damage from fire and other energy sources."
	color = "#8B2500"
	complementary_color = "#00668B"
	blobbernaut_message = "blasts"
	message = "The blob blasts you"
	reagent = /datum/reagent/blob/explosive_lattice

/datum/blobstrain/reagent/explosive_lattice/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_flag == BOMB)
		return 0
	else if(damage_flag != MELEE && damage_flag != BULLET && damage_flag != LASER)
		return damage * 1.5
	return ..()
	
/datum/blobstrain/reagent/explosive_lattice/on_sporedeath(mob/living/spore)
	var/obj/effect/temp_visual/explosion/fast/effect = new /obj/effect/temp_visual/explosion/fast(get_turf(spore))
	effect.alpha = 150
	for(var/mob/living/actor in orange(get_turf(spore), 1))
		if(ROLE_BLOB in actor.faction) //no friendly fire
			continue
		actor.apply_damage(20, BRUTE, wound_bonus=CANT_WOUND)

/datum/reagent/blob/explosive_lattice
	name = "Explosive Lattice"
	taste_description = "бомба"
	color = "#8B2500"

/datum/reagent/blob/explosive_lattice/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/O)
	var/initial_volume = reac_volume
	reac_volume = ..()
	if(reac_volume >= 10) //if it's not a spore cloud, bad time incoming
		var/obj/effect/temp_visual/explosion/fast/E = new /obj/effect/temp_visual/explosion/fast(get_turf(M))
		E.alpha = 150
		for(var/mob/living/L in orange(get_turf(M), 1))
			if(ROLE_BLOB in L.faction) //no friendly fire
				continue
			var/aoe_volume = ..(L, TOUCH, initial_volume, 0, L.get_permeability_protection(), O)
			L.apply_damage(0.4*aoe_volume, BRUTE, wound_bonus=CANT_WOUND)
		if(M)
			M.apply_damage(0.6*reac_volume, BRUTE, wound_bonus=CANT_WOUND)
	else
		M.apply_damage(0.6*reac_volume, BRUTE, wound_bonus=CANT_WOUND)
