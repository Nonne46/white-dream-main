/obj/item/reactive_armour_shell
	name = "реактивная броня"
	desc = "Экспериментальный образец, в ожидании установки аномального ядра."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reactive_armour_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/anomaly_armour_types = list(
		/obj/effect/anomaly/grav	                = /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/effect/anomaly/flux 	           		= /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/effect/anomaly/bluespace 	            = /obj/item/clothing/suit/armor/reactive/teleport
		)

	if(istype(I, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/A = I
		var/armour_path = anomaly_armour_types[A.anomaly_type]
		if(!armour_path)
			armour_path = /obj/item/clothing/suit/armor/reactive/stealth //Lets not cheat the player if an anomaly type doesnt have its own armour coded
		to_chat(user, "<span class='notice'>You insert [A] into the chest plate, and the armour gently hums to life.</span>")
		new armour_path(get_turf(src))
		qdel(src)
		qdel(A)

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "реактивная броня"
	desc = "По какой-то причине мало что делает."
	var/active = 0
	var/reactivearmor_cooldown_duration = 0 //cooldown specific to reactive armor
	var/reactivearmor_cooldown = 0
	icon_state = "reactiveoff"
	inhand_icon_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hit_reaction_chance = 50

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !(active)
	if(active)
		to_chat(user, "<span class='notice'>[src] сейчас включен.</span>")
		icon_state = "reactive"
		inhand_icon_state = "reactive"
	else
		to_chat(user, "<span class='notice'>[src] сейчас выключен.</span>")
		icon_state = "reactiveoff"
		inhand_icon_state = "reactiveoff"
	add_fingerprint(user)
	return

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	active = 0
	icon_state = "reactiveoff"
	inhand_icon_state = "reactiveoff"
	reactivearmor_cooldown = world.time + 200

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "реактивная телепортная броня"
	desc = "У директора исследований сорвало голову, чтобы создать это!"
	var/tele_range = 6
	var/rad_amount= 15
	reactivearmor_cooldown_duration = 100

/obj/item/clothing/suit/armor/reactive/teleport/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		var/mob/living/carbon/human/H = owner
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>Телепортная броня перезаряжается! Скачок невозможен [H]!</span>")
			return
		owner.visible_message("<span class='danger'>Сработала телепортная защита брони [H] от [attack_text], система защиты перезаряжается!</span>")
		playsound(get_turf(owner),'sound/magic/blink.ogg', 100, TRUE)
		var/list/turfs = new/list()
		for(var/turf/T in orange(tele_range, H))
			if(T.density)
				continue
			if(T.x>world.maxx-tele_range || T.x<tele_range)
				continue
			if(T.y>world.maxy-tele_range || T.y<tele_range)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(tele_range, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		H.forceMove(picked)
		H.rad_act(rad_amount)
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return 1
	return 0

//Fire

/obj/item/clothing/suit/armor/reactive/fire
	name = "реактивная зажигательная броня"
	desc = "Экспериментальный костюм брони с массивом реактивных датчиков, прикрепленным к источнику пламени. Для стильного пиромана."

/obj/item/clothing/suit/armor/reactive/fire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>Зажигательная броня [owner] активировалась, но заряда нехватило для работы!</span>")
			return
		owner.visible_message("<span class='danger'>[src] блокировал [attack_text], рассылаются струи пламени!</span>")
		playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, TRUE)
		for(var/mob/living/carbon/C in range(6, owner))
			if(C != owner)
				C.fire_stacks += 8
				C.IgniteMob()
		owner.fire_stacks = -20
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return 1
	return 0

//Stealth

/obj/item/clothing/suit/armor/reactive/stealth
	name = "реактивная стелс броня"
	desc = "Экспериментальный костюм брони, который делает владельца невидимым при обнаружении неминуемого вреда и создает приманку, которая убегает от владельца. Вы не можете бороться с тем, чего не видите."

/obj/item/clothing/suit/armor/reactive/stealth/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>Реактивная система на [owner] включилась, но на зарядке!</span>")
			return
		var/mob/living/simple_animal/hostile/illusion/escape/E = new(owner.loc)
		E.Copy_Parent(owner, 50)
		E.GiveTarget(owner) //so it starts running right away
		E.Goto(owner, E.move_to_delay, E.minimum_distance)
		owner.alpha = 0
		owner.visible_message("<span class='danger'>[owner] ударен [attack_text] в грудь!</span>") //We pretend to be hit, since blocking it would stop the message otherwise
		addtimer(VARSET_CALLBACK(owner, alpha, initial(owner.alpha)), 4 SECONDS)
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return 1

//Tesla

/obj/item/clothing/suit/armor/reactive/tesla
	name = "реактивная броня теслы"
	desc = "Экспериментальный комплект брони с чувствительными детекторами, подключенными к огромной конденсаторной сетке, из которой выступают излучатели."
	siemens_coefficient = -1
	var/zap_power = 25000
	var/zap_range = 20
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE

/obj/item/clothing/suit/armor/reactive/tesla/dropped(mob/user)
	..()
	if(istype(user))
		ADD_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/equipped(mob/user, slot)
	..()
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		REMOVE_TRAIT(user, TRAIT_TESLA_SHOCKIMMUNE, "reactive_tesla_armor")

/obj/item/clothing/suit/armor/reactive/tesla/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return FALSE
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
			sparks.set_up(1, 1, src)
			sparks.start()
			owner.visible_message("<span class='danger'>Конденсаторы [owner]'s тесла брони перезаряжаются! Броня просто испускает искры.</span>")
			return
		owner.visible_message("<span class='danger'>[src] блокировала [attack_text], испуская лучи света!</span>")
		tesla_zap(owner, zap_range, zap_power, zap_flags)
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return TRUE

//Repulse

/obj/item/clothing/suit/armor/reactive/repulse
	name = "реактивная броня отталкивания"
	desc = "Экспериментальный образец, отталкивающий людей, которые атакуют вас."
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG

/obj/item/clothing/suit/armor/reactive/repulse/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>The repulse generator is still recharging!</span>")
			return 0
		playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, TRUE)
		owner.visible_message("<span class='danger'>[src] блокировала [attack_text], переводя атаку в мощный силовой импульс!</span>")
		var/turf/T = get_turf(owner)
		var/list/thrown_items = list()
		for(var/atom/movable/A in range(T, 7))
			if(A == owner || A.anchored || thrown_items[A])
				continue
			var/throwtarget = get_edge_target_turf(T, get_dir(T, get_step_away(A, T)))
			A.safe_throw_at(throwtarget, 10, 1, force = repulse_force)
			thrown_items[A] = A

		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return 1

/obj/item/clothing/suit/armor/reactive/table
	name = "реактивная табличная броня"
	desc = "Экспериментальный образец клоунского назначения."
	var/tele_range = 10

/obj/item/clothing/suit/armor/reactive/table/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!active)
		return 0
	if(prob(hit_reaction_chance))
		var/mob/living/carbon/human/H = owner
		if(world.time < reactivearmor_cooldown)
			owner.visible_message("<span class='danger'>Реактивная броня на перезарядке!</span>")
			return
		owner.visible_message("<span class='danger'>Реактивная система телепортации сбрасывает [H] от [attack_text] и бросает [H.p_them()] на созданный стол!</span>")
		owner.visible_message("<font color='red' size='3'>[H] GOES ON THE TABLE!!!</font>")
		owner.Paralyze(40)
		var/list/turfs = new/list()
		for(var/turf/T in orange(tele_range, H))
			if(T.density)
				continue
			if(T.x>world.maxx-tele_range || T.x<tele_range)
				continue
			if(T.y>world.maxy-tele_range || T.y<tele_range)
				continue
			turfs += T
		if(!turfs.len)
			turfs += pick(/turf in orange(tele_range, H))
		var/turf/picked = pick(turfs)
		if(!isturf(picked))
			return
		H.forceMove(picked)
		new /obj/structure/table(get_turf(owner))
		reactivearmor_cooldown = world.time + reactivearmor_cooldown_duration
		return 1
	return 0

/obj/item/clothing/suit/armor/reactive/table/emp_act()
	return
