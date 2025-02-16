//Not only meat, actually, but also snacks that are almost meat, such as fish meat or tofu


////////////////////////////////////////////FISH////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 4)
	bitesize = 3
	filling_color = "#CD853F"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 4,  /datum/reagent/consumable/capsaicin = 1)
	tastes = list("рыба" = 4, "кляр" = 1, "перцы" = 1)
	foodtype = MEAT
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/toxin/carpotoxin = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	bitesize = 6
	filling_color = "#FA8072"
	tastes = list("рыба" = 1)
	foodtype = MEAT
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/carpmeat/Initialize()
	. = ..()
	eatverb = pick("bite","chew","gnaw","swallow","chomp")
	if(!istype(src, /obj/item/reagent_containers/food/snacks/carpmeat/imitation))
		AddElement(/datum/element/swabable, CELL_LINE_TABLE_CARP, CELL_VIRUS_TABLE_GENERIC_MOB)

/obj/item/reagent_containers/food/snacks/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3)
	bitesize = 1
	filling_color = "#CD853F"
	tastes = list("рыба" = 1, "панировочные сухари" = 1)
	foodtype = MEAT
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 3)
	filling_color = "#FA8072"
	tastes = list("рыба" = 1, "чипсы" = 1)
	foodtype = MEAT | VEGETABLES | FRIED
	value = FOOD_EXOTIC

////////////////////////////////////////////MEATS AND ALIKE////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	filling_color = "#F0E68C"
	tastes = list("тофу" = 1)
	foodtype = VEGETABLES
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/tofu/prison
	name = "soggy tofu"
	desc = "You refuse to eat this strange bean curd."
	tastes = list("кислая, гнилая вода" = 1)
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/toxin = 2)
	cooked_type = /obj/item/reagent_containers/food/snacks/boiledspiderleg
	filling_color = "#000000"
	tastes = list("паутина" = 1)
	foodtype = MEAT | TOXIC
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/cornedbeef
	name = "corned beef and cabbage"
	desc = "Now you can feel like a real tourist vacationing in Ireland."
	icon_state = "cornedbeef"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 4)
	tastes = list("мясо" = 1, "капуста" = 1)
	foodtype = MEAT | VEGETABLES
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/bearsteak
	name = "Filet migrawr"
	desc = "Because eating bear wasn't manly enough."
	icon_state = "bearsteak"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/vitamin = 5, /datum/reagent/consumable/ethanol/manly_dorf = 5)
	tastes = list("мясо" = 1, "лосось" = 1)
	foodtype = MEAT | ALCOHOL
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "meatball"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#800000"
	tastes = list("мясо" = 1)
	foodtype = MEAT
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#CD5C5C"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("мясо" = 1)
	slices_num = 6
	slice_path = /obj/item/reagent_containers/food/snacks/salami
	foodtype = MEAT | BREAKFAST
	var/roasted = FALSE
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/sausage/Initialize()
	. = ..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")

/obj/item/reagent_containers/food/snacks/salami
	name = "salami"
	desc = "A slice of cured salami."
	icon_state = "salami"
	filling_color = "#CD4122"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	tastes = list("мясо" = 1, "дымок" = 1)
	foodtype = MEAT
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/rawkhinkali
	name = "raw khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon_state = "khinkali"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/garlic = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/khinkali
	tastes = list("мясо" = 1, "лук" = 1, "чеснок" = 1)
	foodtype = MEAT
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/khinkali
	name = "khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon_state = "khinkali"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 1)
	bitesize = 3
	filling_color = "#F0F0F0"
	tastes = list("мясо" = 1, "лук" = 1, "чеснок" = 1)
	foodtype = MEAT
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	list_reagents = list(/datum/reagent/monkey_powder = 30)
	filling_color = "#CD853F"
	tastes = list("джунгли" = 1, "бананы" = 1)
	foodtype = MEAT | SUGAR
	var/faction
	var/spawned_mob = /mob/living/carbon/monkey

/obj/item/reagent_containers/food/snacks/monkeycube/proc/Expand()
	var/mob/spammer = get_mob_by_key(fingerprintslast)
	var/mob/living/bananas = new spawned_mob(drop_location()[1], TRUE, spammer)
	if(faction)
		bananas.faction = faction
	if (!QDELETED(bananas))
		visible_message("<span class='notice'>[src] expands!</span>")
		bananas.log_message("Spawned via [src] at [AREACOORD(src)], Last attached mob: [key_name(spammer)].", LOG_ATTACK)
	else if (!spammer) // Visible message in case there are no fingerprints
		visible_message("<span class='notice'>[src] fails to expand!</span>")
	qdel(src)

/obj/item/reagent_containers/food/snacks/monkeycube/suicide_act(mob/living/M)
	M.visible_message("<span class='suicide'>[M] is putting [src] in [M.p_their()] mouth! It looks like [M.p_theyre()] trying to commit suicide!</span>")
	var/eating_success = do_after(M, 10, TRUE, src, TRUE)
	if(QDELETED(M)) //qdeletion: the nuclear option of self-harm
		return SHAME
	if(!eating_success || QDELETED(src)) //checks if src is gone or if they failed to wait for a second
		M.visible_message("<span class='suicide'>[M] chickens out!</span>")
		return SHAME
	if(HAS_TRAIT(M, TRAIT_NOHUNGER)) //plasmamen don't have saliva/stomach acid
		M.visible_message("<span class='suicide'>[M] realizes [M.p_their()] body won't activate [src]!</span>"
		,"<span class='warning'>Your body won't activate [src]...</span>")
		return SHAME
	playsound(M, 'sound/items/eatfood.ogg', rand(10,50), TRUE)
	M.temporarilyRemoveItemFromInventory(src) //removes from hands, keeps in M
	addtimer(CALLBACK(src, .proc/finish_suicide, M), 15) //you've eaten it, you can run now
	return MANUAL_SUICIDE

/obj/item/reagent_containers/food/snacks/monkeycube/proc/finish_suicide(mob/living/M) ///internal proc called by a monkeycube's suicide_act using a timer and callback. takes as argument the mob/living who activated the suicide
	if(QDELETED(M) || QDELETED(src))
		return
	if((src.loc != M)) //how the hell did you manage this
		to_chat(M, "<span class='warning'>Something happened to [src]...</span>")
		return
	Expand()
	M.visible_message("<span class='danger'>[M]'s torso bursts open as a primate emerges!</span>")
	M.gib(null, TRUE, null, TRUE)

/obj/item/reagent_containers/food/snacks/monkeycube/syndicate
	faction = list("neutral", ROLE_SYNDICATE)

/obj/item/reagent_containers/food/snacks/monkeycube/gorilla
	name = "gorilla cube"
	desc = "A Waffle Co. brand gorilla cube. Now with extra molecules!"
	bitesize = 20
	list_reagents = list(/datum/reagent/monkey_powder = 30, /datum/reagent/medicine/strange_reagent = 5)
	tastes = list("джунгли" = 1, "бананы" = 1, "jimmies" = 1)
	spawned_mob = /mob/living/simple_animal/hostile/gorilla
	value = FOOD_ILLEGAL

/obj/item/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	bitesize = 4
	filling_color = "#FFA07A"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/capsaicin = 6)
	tastes = list("перцы" = 1, "мясо" = 3, "сыр" = 1, "сметана" = 1)
	foodtype = MEAT
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 5)
	filling_color = "#D2691E"
	tastes = list("соя" = 1, "овощи" = 1)
	foodtype = VEGETABLES
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/stewedsoymeat/Initialize()
	. = ..()
	eatverb = pick("slurp","sip","inhale","drink")

/obj/item/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/capsaicin = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/capsaicin = 2)
	filling_color = "#000000"
	tastes = list("перцы" = 1, "паутина" = 1)
	foodtype = MEAT
	value = FOOD_JUNK

/obj/item/reagent_containers/food/snacks/spidereggsham
	name = "зелёный eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 6)
	bitesize = 4
	filling_color = "#7FFF00"
	tastes = list("мясо" = 1, "зелёный цвет" = 1)
	foodtype = MEAT
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/capsaicin = 4, /datum/reagent/consumable/nutriment/vitamin = 4)
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/capsaicin = 5)
	filling_color = "#FA8072"
	tastes = list("рыба" = 1, "перцы" = 1)
	foodtype = MEAT | TOXIC
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/sashimi/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CARP, CELL_VIRUS_TABLE_GENERIC_MOB)
/obj/item/reagent_containers/food/snacks/nugget
	name = "chicken nugget"
	filling_color = "#B22222"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("\"цыплёнок\"" = 1)
	foodtype = MEAT
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/nugget/Initialize()
	. = ..()
	var/shape = pick("lump", "star", "lizard", "corgi")
	desc = "A 'chicken' nugget vaguely shaped like a [shape]."
	icon_state = "nugget_[shape]"

/obj/item/reagent_containers/food/snacks/pigblanket
	name = "pig in a blanket"
	desc = "A tiny sausage wrapped in a flakey, buttery roll. Free this pig from its blanket prison by eating it."
	icon_state = "pigblanket"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#800000"
	tastes = list("мясо" = 1, "масло" = 1)
	foodtype = MEAT | DAIRY
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/bbqribs
	name = "bbq ribs"
	desc = "BBQ ribs, slathered in a healthy coating of BBQ sauce. The least vegan thing to ever exist."
	icon_state = "ribs"
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/bbqsauce = 5)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/bbqsauce = 5) //loose reagents included in the recipe do not get added to the finished food automatically.
	tastes = list("мясо" = 3, "дымный соус" = 1)
	foodtype = MEAT
	value = FOOD_EXOTIC

/obj/item/reagent_containers/food/snacks/meatclown
	name = "meat clown"
	desc = "A delicious, round piece of meat clown. How horrifying."
	icon_state = "meatclown"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/banana = 2)
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	tastes = list("meat" = 5, "clowns" = 3, "sixteen teslas" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meatclown/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 30)

//////////////////////////////////////////// KEBABS AND OTHER SKEWERS ////////////////////////////////////////////

/obj/item/reagent_containers/food/snacks/kebab
	trash = /obj/item/stack/rods
	icon_state = "kebab"
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 12)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("мясо" = 3, "металл" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/kebab/human
	name = "human-kebab"
	desc = "A human meat, on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 6)
	tastes = list("нежное мясо" = 3, "металл" = 1)
	foodtype = MEAT | GROSS
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/kebab/monkey
	name = "meat-kebab"
	desc = "Delicious meat, on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein  = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("мясо" = 3, "металл" = 1)
	foodtype = MEAT
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/kebab/tofu
	name = "tofu-kebab"
	desc = "Vegan meat, on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	tastes = list("тофу" = 3, "металл" = 1)
	foodtype = VEGETABLES
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/kebab/tail
	name = "lizard-tail kebab"
	desc = "Severed lizard tail on a stick."
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 16, /datum/reagent/consumable/nutriment/vitamin = 4) //lizard tails are not reagent containers, so the bonus_reagents need to be set higher.
	tastes = list("мясо" = 8, "металл" = 4, "чешуйки" = 1)
	foodtype = MEAT
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/kebab/rat
	name = "rat-kebab"
	desc = "Not so delicious rat meat, on a stick."
	icon_state = "ratkebab"
	w_class = WEIGHT_CLASS_NORMAL
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/nutriment/vitamin = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("крысятина" = 1, "металл" = 1)
	foodtype = MEAT | GROSS
	value = FOOD_FAST

/obj/item/reagent_containers/food/snacks/kebab/rat/double
	name = "double rat-kebab"
	icon_state = "doubleratkebab"
	tastes = list("крысятина" = 2, "металл" = 1)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	value = FOOD_RARE

/obj/item/reagent_containers/food/snacks/kebab/fiesta
	name = "fiesta skewer"
	icon_state = "fiestaskewer"
	tastes = list("tex-mex" = 3, "тмин" = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/capsaicin = 3)
	value = FOOD_EXOTIC
