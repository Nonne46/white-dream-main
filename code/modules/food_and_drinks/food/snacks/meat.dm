/obj/item/reagent_containers/food/snacks/meat
	var/subjectname = ""
	var/subjectjob = null
	custom_materials = list(/datum/material/meat = MINERAL_MATERIAL_AMOUNT * 4)
	material_flags = MATERIAL_NO_EFFECTS //Remove this once we refactor food, prevents meat literaly being eaten twice

/obj/item/reagent_containers/food/snacks/meat/slab
	name = "meat"
	desc = "A slab of meat."
	icon_state = "meat"
	dried_type = /obj/item/reagent_containers/food/snacks/sosjerky/healthy
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/cooking_oil = 2) //Meat has fats that a food processor can process into cooking oil
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/plain
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain
	slices_num = 3
	filling_color = "#FF0000"
	tastes = list("мясо" = 1)
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/slab/initialize_slice(obj/item/reagent_containers/food/snacks/meat/rawcutlet/slice, reagents_per_slice)
	..()
	var/mutable_appearance/filling = mutable_appearance(icon, "rawcutlet_coloration")
	filling.color = filling_color
	slice.add_overlay(filling)
	slice.filling_color = filling_color
	slice.name = "raw [name] cutlet"
	slice.meat_type = name

/obj/item/reagent_containers/food/snacks/meat/slab/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	S.name = "[name] steak"

///////////////////////////////////// HUMAN MEATS //////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/slab/human
	name = "meat"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/plain/human
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human
	tastes = list("человечина" = 1)
	foodtype = MEAT | RAW | GROSS
	value = FOOD_MEAT_HUMAN

/obj/item/reagent_containers/food/snacks/meat/slab/human/initialize_slice(obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human/slice, reagents_per_slice)
	..()
	slice.subjectname = subjectname
	slice.subjectjob = subjectjob
	if(subjectname)
		slice.name = "raw [subjectname] cutlet"
	else if(subjectjob)
		slice.name = "raw [subjectjob] cutlet"

/obj/item/reagent_containers/food/snacks/meat/slab/human/initialize_cooked_food(obj/item/reagent_containers/food/snacks/meat/S, cooking_efficiency)
	..()
	S.subjectname = subjectname
	S.subjectjob = subjectjob
	if(subjectname)
		S.name = "[subjectname] meatsteak"
	else if(subjectjob)
		S.name = "[subjectjob] meatsteak"


/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	icon_state = "slimemeat"
	desc = "Because jello wasn't offensive enough to vegans."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/toxin/slimejelly = 3)
	filling_color = "#00FFFF"
	tastes = list("слаймы" =1, "желе" =1)
	foodtype = MEAT | RAW | TOXIC
	value = FOOD_MEAT_MUTANT_RARE

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem
	icon_state = "golemmeat"
	desc = "Edible rocks, welcome to the future."
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/iron = 3)
	filling_color = "#A9A9A9"
	tastes = list("камни" = 1)
	foodtype = MEAT | RAW | GROSS
	value = FOOD_MEAT_MUTANT_RARE

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine
	icon_state = "agolemmeat"
	desc = "From the slime pen to the rune to the kitchen, science."
	filling_color = "#66CDAA"
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	icon_state = "lizardmeat"
	desc = "Delicious dino damage."
	filling_color = "#6B8E23"
	tastes = list("мясо" = 4, "чешуйки" = 1)
	foodtype = MEAT | RAW
	value = FOOD_MEAT_MUTANT

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	icon_state = "plantmeat"
	desc = "All the joys of healthy eating with all the fun of cannibalism."
	filling_color = "#E9967A"
	tastes = list("салат" =1, "дерево" =1)
	foodtype = VEGETABLES
	value = FOOD_MEAT_MUTANT_RARE

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	icon_state = "shadowmeat"
	desc = "Ow, the edge."
	filling_color = "#202020"
	tastes = list("тьма" = 1, "мясо" = 1)
	foodtype = MEAT | RAW
	value = FOOD_MEAT_MUTANT_RARE

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/fly
	icon_state = "flymeat"
	desc = "Nothing says tasty like maggot filled radioactive mutant flesh."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/uranium = 3)
	tastes = list("личинки" = 1, "внутренности реактора" = 1)
	foodtype = MEAT | RAW | GROSS
	value = FOOD_MEAT_MUTANT

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	icon_state = "mothmeat"
	desc = "Unpleasantly powdery and dry. Kind of pretty, though."
	filling_color = "#BF896B"
	tastes = list("пыль" = 1, "порох" = 1, "мясо" = 2)
	foodtype = MEAT | RAW
	value = FOOD_MEAT_MUTANT

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	name = "bone"
	icon_state = "skeletonmeat"
	desc = "There's a point where this needs to stop, and clearly we have passed it."
	filling_color = "#F0F0F0"
	tastes = list("кости" = 1)
	slice_path = null  //can't slice a bone into cutlets
	foodtype = GROSS
	value = FOOD_MEAT_MUTANT_RARE

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	name = " meat (rotten)"
	icon_state = "rottenmeat"
	desc = "Halfway to becoming fertilizer for your garden."
	filling_color = "#6B8E23"
	tastes = list("мозги" = 1, "мясо" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ethereal
	icon_state = "etherealmeat"
	desc = "So shiny you feel like ingesting it might make you shine too"
	filling_color = "#97ee63"
	list_reagents = list(/datum/reagent/consumable/liquidelectricity = 3)
	tastes = list("электричество" = 2, "мясо" = 1)
	foodtype = RAW | MEAT | TOXIC
	value = FOOD_MEAT_MUTANT

////////////////////////////////////// OTHER MEATS ////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/slab/synthmeat
	name = "synthmeat"
	desc = "A synthetic slab of meat."
	foodtype = RAW | MEAT //hurr durr chemicals we're harmed in the production of this meat thus its non-vegan.

/obj/item/reagent_containers/food/snacks/meat/slab/meatproduct
	name = "meat product"
	desc = "A slab of station reclaimed and chemically processed meat product."
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/monkey
	name = "monkey meat"
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/mouse
	name = "mouse meat"
	desc = "A slab of mouse meat. Best not eat it raw."
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/mouse/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOUSE, CELL_VIRUS_TABLE_GENERIC_MOB)

/obj/item/reagent_containers/food/snacks/meat/slab/corgi
	name = "corgi meat"
	desc = "Tastes like... well you know..."
	tastes = list("мясо" = 4, "любовь к ношению шляп" = 1)
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/corgi/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CORGI, CELL_VIRUS_TABLE_GENERIC_MOB)

/obj/item/reagent_containers/food/snacks/meat/slab/pug
	name = "pug meat"
	desc = "Tastes like... well you know..."
	foodtype = RAW | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/slab/pug/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_PUG, CELL_VIRUS_TABLE_GENERIC_MOB)

/obj/item/reagent_containers/food/snacks/meat/slab/killertomato
	name = "killer tomato meat"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	filling_color = "#FF0000"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/killertomato
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/killertomato
	tastes = list("томаты" = 1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/slab/bear
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 16, /datum/reagent/medicine/morphine = 5, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/cooking_oil = 6)
	filling_color = "#FFB6C1"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/bear
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/bear
	tastes = list("мясо" = 1, "лосось" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/bear/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BEAR, CELL_VIRUS_TABLE_GENERIC_MOB)

/obj/item/reagent_containers/food/snacks/meat/slab/xeno
	name = "xeno meat"
	desc = "A slab of meat."
	icon_state = "xenomeat"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 8, /datum/reagent/consumable/nutriment/vitamin = 3)
	bitesize = 4
	filling_color = "#32CD32"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/xeno
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/xeno
	tastes = list("мясо" = 1, "кислота" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/spider
	name = "spider meat"
	desc = "A slab of spider meat. That is so Kafkaesque."
	icon_state = "spidermeat"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/toxin = 3, /datum/reagent/consumable/nutriment/vitamin = 1)
	filling_color = "#7CFC00"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/spider
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/spider
	tastes = list("паутина" = 1)
	foodtype = RAW | MEAT | TOXIC


/obj/item/reagent_containers/food/snacks/meat/slab/goliath
	name = "goliath meat"
	desc = "A slab of goliath meat. It's not very edible now, but it cooks great in lava."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/toxin = 5, /datum/reagent/consumable/cooking_oil = 3)
	icon_state = "goliathmeat"
	tastes = list("мясо" = 1)
	foodtype = RAW | MEAT | TOXIC

/obj/item/reagent_containers/food/snacks/meat/slab/goliath/burn()
	visible_message("<span class='notice'>[src] finishes cooking!</span>")
	new /obj/item/reagent_containers/food/snacks/meat/steak/goliath(loc)
	qdel(src)

/obj/item/reagent_containers/food/snacks/meat/slab/meatwheat
	name = "meatwheat clump"
	desc = "This doesn't look like meat, but your standards aren't <i>that</i> high to begin with."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/blood = 5, /datum/reagent/consumable/cooking_oil = 1)
	filling_color = rgb(150, 0, 0)
	icon_state = "meatwheat_clump"
	bitesize = 4
	tastes = list("мясо" = 1, "пшеница" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/meat/slab/gorilla
	name = "gorilla meat"
	desc = "Much meatier than monkey meat."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 7, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 5) //Plenty of fat!

/obj/item/reagent_containers/food/snacks/meat/rawbacon
	name = "raw piece of bacon"
	desc = "A raw piece of bacon."
	icon_state = "bacon"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/bacon
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/cooking_oil = 3)
	filling_color = "#B22222"
	tastes = list("бекон" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/bacon
	name = "piece of bacon"
	desc = "A delicious piece of bacon."
	icon_state = "baconcooked"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/consumable/cooking_oil = 2)
	filling_color = "#854817"
	tastes = list("бекон" = 1)
	foodtype = MEAT | BREAKFAST

/obj/item/reagent_containers/food/snacks/meat/slab/gondola
	name = "gondola meat"
	desc = "According to legends of old, consuming raw gondola flesh grants one inner peace."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/tranquility = 5, /datum/reagent/consumable/cooking_oil = 3)
	tastes = list("мясо" = 4, "спокойствие" = 1)
	filling_color = "#9A6750"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/gondola
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/gondola
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/penguin
	name = "penguin meat"
	desc = "A slab of penguin meat."
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 4, /datum/reagent/consumable/cooking_oil = 3)
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/penguin
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/penguin
	filling_color = "#B22222"
	tastes = list("говядина" = 1, "треска" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcrab
	name = "raw crab meat"
	desc = "A pile of raw crab meat."
	icon_state = "crabmeatraw"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/crab
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/cooking_oil = 3)
	filling_color = "#EAD079"
	tastes = list("сырой краб" = 1)
	foodtype = RAW | MEAT

/obj/item/reagent_containers/food/snacks/meat/crab
	name = "crab meat"
	desc = "Some deliciously cooked crab meat."
	icon_state = "crabmeat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/cooking_oil = 2)
	filling_color = "#DFB73A"
	tastes = list("краб" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/slab/chicken
	name = "chicken meat"
	desc = "A slab of raw chicken. Remember to wash your hands!"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 6) //low fat
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/steak/chicken
	slice_path = /obj/item/reagent_containers/food/snacks/meat/rawcutlet/chicken
	tastes = list("цыплёнок" = 1)

/obj/item/reagent_containers/food/snacks/meat/slab/chicken/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB)
////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/snacks/meat/steak
	name = "steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 6)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	trash = /obj/item/trash/plate
	filling_color = "#B22222"
	foodtype = MEAT
	tastes = list("мясо" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/plain/human
	tastes = list("нежное мясо" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/steak/killertomato
	name = "killer tomato steak"
	tastes = list("томаты" =1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/steak/bear
	name = "bear steak"
	tastes = list("мясо" = 1, "лосось" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/xeno
	name = "xeno steak"
	tastes = list("мясо" = 1, "кислота" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/spider
	name = "spider steak"
	tastes = list("паутина" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/goliath
	name = "goliath steak"
	desc = "A delicious, lava cooked steak."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash = null
	tastes = list("мясо" = 1, "камни" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/steak/gondola
	name = "gondola steak"
	tastes = list("мясо" = 1, "спокойствие" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/penguin
	name = "penguin steak"
	tastes = list("говядина" = 1, "треска" = 1)

/obj/item/reagent_containers/food/snacks/meat/steak/chicken
	name = "chicken steak" //Can you have chicken steaks? Maybe this should be renamed once it gets new sprites.
	tastes = list("цыплёнок" = 1)

//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////

//Raw cutlets

/obj/item/reagent_containers/food/snacks/meat/rawcutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon_state = "rawcutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	filling_color = "#B22222"
	tastes = list("мясо" = 1)
	var/meat_type = "meat"
	foodtype = MEAT | RAW

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	S.name = "[meat_type] cutlet"


/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain
    foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	tastes = list("нежное мясо" = 1)
	foodtype = MEAT | RAW | GROSS

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/plain/human/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency)
	..()
	if(subjectname)
		S.name = "[subjectname] [initial(S.name)]"
	else if(subjectjob)
		S.name = "[subjectjob] [initial(S.name)]"

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/killertomato
	name = "raw killer tomato cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato
	tastes = list("томаты" =1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/bear
	name = "raw bear cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	tastes = list("мясо" = 1, "лосось" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/bear/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BEAR, CELL_VIRUS_TABLE_GENERIC_MOB)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/xeno
	name = "raw xeno cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	tastes = list("мясо" = 1, "кислота" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/spider
	name = "raw spider cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/spider
	tastes = list("паутина" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/gondola
	name = "raw gondola cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/gondola
	tastes = list("мясо" = 1, "спокойствие" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/penguin
	name = "raw penguin cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/penguin
	tastes = list("говядина" = 1, "треска" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/chicken
	name = "raw chicken cutlet"
	cooked_type = /obj/item/reagent_containers/food/snacks/meat/cutlet/chicken
	tastes = list("цыплёнок" = 1)

/obj/item/reagent_containers/food/snacks/meat/rawcutlet/chicken/Initialize()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB)

//Cooked cutlets

/obj/item/reagent_containers/food/snacks/meat/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	bonus_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	filling_color = "#B22222"
	tastes = list("мясо" = 1)
	foodtype = MEAT

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain

/obj/item/reagent_containers/food/snacks/meat/cutlet/plain/human
	tastes = list("нежное мясо" = 1)
	foodtype = MEAT | GROSS

/obj/item/reagent_containers/food/snacks/meat/cutlet/killertomato
	name = "killer tomato cutlet"
	tastes = list("томаты" =1)
	foodtype = FRUIT

/obj/item/reagent_containers/food/snacks/meat/cutlet/bear
	name = "bear cutlet"
	tastes = list("мясо" = 1, "лосось" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/xeno
	name = "xeno cutlet"
	tastes = list("мясо" = 1, "кислота" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/spider
	name = "spider cutlet"
	tastes = list("паутина" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/gondola
	name = "gondola cutlet"
	tastes = list("мясо" = 1, "спокойствие" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/penguin
	name = "penguin cutlet"
	tastes = list("говядина" = 1, "треска" = 1)

/obj/item/reagent_containers/food/snacks/meat/cutlet/chicken
	name = "chicken cutlet"
	tastes = list("цыплёнок" = 1)
