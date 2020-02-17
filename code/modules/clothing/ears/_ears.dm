
//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "уши"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_EARS
	resistance_flags = NONE

/obj/item/clothing/ears/earmuffs
	name = "защитные наушники"
	desc = "Защищают владельца от нытья из внешнего мира."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	strip_delay = 15
	equip_delay_other = 25
	resistance_flags = FLAMMABLE
	custom_price = 250

/obj/item/clothing/ears/earmuffs/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/earhealing)
	AddComponent(/datum/component/wearertargeting/earprotection, list(ITEM_SLOT_EARS))

/obj/item/clothing/ears/earmuffs/equipped(mob/user, slot)
	. = ..()
	if(ishuman(user) && slot == ITEM_SLOT_EARS)
		ADD_TRAIT(user, TRAIT_DEAF, CLOTHING_TRAIT)

/obj/item/clothing/ears/earmuffs/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_DEAF, CLOTHING_TRAIT)

/obj/item/clothing/ears/earmuffs/spacepods
	name = "Спейсподы"
	desc = "И пусть весь мир подождет..."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "spacepods"
	item_state = "spacepods"
	strip_delay = 100 //air pods don't fall out
	custom_premium_price = 1800
