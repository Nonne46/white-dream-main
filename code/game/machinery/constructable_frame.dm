/obj/structure/frame
	name = "рама"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = TRUE
	max_integrity = 250
	var/obj/item/circuitboard/machine/circuit = null
	var/state = 1

/obj/structure/frame/examine(user)
	. = ..()
	if(circuit)
		. += "<hr>Имеет [circuit] в себе."


/obj/structure/frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 5)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	qdel(src)


/obj/structure/frame/machine
	name = "machine frame"
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null // user-friendly names of components

/obj/structure/frame/machine/examine(user)
	. = ..()
	if(state == 3 && req_components && req_component_names)
		var/hasContent = 0
		var/requires = "It requires"

		for(var/i = 1 to req_components.len)
			var/tname = req_components[i]
			var/amt = req_components[tname]
			if(amt == 0)
				continue
			var/use_and = i == req_components.len
			requires += "[(hasContent ? (use_and ? ", и" : ",") : "")] [amt] [amt == 1 ? req_component_names[tname] : "[req_component_names[tname]]\s"]"
			hasContent = 1

		if(hasContent)
			. +=  "<hr>[requires]."
		else
			. += "<hr>Более не требует никаких компонентов и готово к сборке."

/obj/structure/frame/machine/proc/update_namelist()
	if(!req_components)
		return

	req_component_names = new()
	for(var/tname in req_components)
		if(ispath(tname, /obj/item/stack))
			var/obj/item/stack/S = tname
			var/singular_name = initial(S.singular_name)
			if(singular_name)
				req_component_names[tname] = singular_name
			else
				req_component_names[tname] = initial(S.name)
		else
			var/obj/O = tname
			req_component_names[tname] = initial(O.name)

/obj/structure/frame/machine/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/structure/frame/machine/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(1)
			if(istype(P, /obj/item/circuitboard/machine))
				to_chat(user, "<span class='warning'>Нужны провода!</span>")
				return
			else if(istype(P, /obj/item/circuitboard))
				to_chat(user, "<span class='warning'>Эта плата не подходит для этого типа машинерии!</span>")
				return
			if(istype(P, /obj/item/stack/cable_coil))
				if(!P.tool_start_check(user, amount=5))
					return

				to_chat(user, "<span class='notice'>Начинаю добавлять провода...</span>")
				if(P.use_tool(src, user, 20, volume=50, amount=5))
					to_chat(user, "<span class='notice'>Добавляю провода.</span>")
					state = 2
					icon_state = "box_1"

				return
			if(P.tool_behaviour == TOOL_SCREWDRIVER && !anchored)
				user.visible_message("<span class='warning'>[user] разбирает раму.</span>", \
									"<span class='notice'>Начинаю разбирать раму...</span>", "<span class='hear'>Слышу лязг метала.</span>")
				if(P.use_tool(src, user, 40, volume=50))
					if(state == 1)
						to_chat(user, "<span class='notice'>Разбираю раму.</span>")
						var/obj/item/stack/sheet/metal/M = new (loc, 5)
						M.add_fingerprint(user)
						qdel(src)
				return
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>Начинаю [anchored ? "от" : "при"]кручивать [src.name]...</span>")
				if(P.use_tool(src, user, 40, volume=75))
					if(state == 1)
						to_chat(user, "<span class='notice'>[anchored ? "От" : "При"]кручиваю [src.name].</span>")
						set_anchored(!anchored)
				return

		if(2)
			if(P.tool_behaviour == TOOL_WRENCH)
				to_chat(user, "<span class='notice'>>Начинаю [anchored ? "от" : "при"]кручивать [src.name]...</span>")
				if(P.use_tool(src, user, 40, volume=75))
					to_chat(user, "<span class='notice'>[anchored ? "От" : "При"]кручиваю [src.name].</span>")
					set_anchored(!anchored)
				return

			if(istype(P, /obj/item/circuitboard/machine))
				var/obj/item/circuitboard/machine/B = P
				if(!B.build_path)
					to_chat(user, "<span class='warning'>Эта плата повреждена судя по всему.</span>")
					return
				if(!anchored && B.needs_anchored)
					to_chat(user, "<span class='warning'>Рама должна быть прикручена для работы!</span>")
					return
				if(!user.transferItemToLoc(B, src))
					return
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
				to_chat(user, "<span class='notice'>Добавляю плату.</span>")
				circuit = B
				icon_state = "box_2"
				state = 3
				components = list()
				req_components = B.req_components.Copy()
				update_namelist()
				return

			else if(istype(P, /obj/item/circuitboard))
				to_chat(user, "<span class='warning'>Эта плата не подходит для этого типа машинерии!</span>")
				return

			if(P.tool_behaviour == TOOL_WIRECUTTER)
				P.play_tool_sound(src)
				to_chat(user, "<span class='notice'>Убираю провода.</span>")
				state = 1
				icon_state = "box_0"
				new /obj/item/stack/cable_coil(drop_location()[1], 5)
				return

		if(3)
			if(P.tool_behaviour == TOOL_CROWBAR)
				P.play_tool_sound(src)
				state = 2
				circuit.forceMove(drop_location())
				components.Remove(circuit)
				circuit = null
				if(components.len == 0)
					to_chat(user, "<span class='notice'>Убираю плату.</span>")
				else
					to_chat(user, "<span class='notice'>Убираю плату и другие компоненты.</span>")
					for(var/atom/movable/AM in components)
						AM.forceMove(drop_location())
				desc = initial(desc)
				req_components = null
				components = null
				icon_state = "box_1"
				return

			if(P.tool_behaviour == TOOL_WRENCH && !circuit.needs_anchored)
				to_chat(user, "<span class='notice'>Начинаю [anchored ? "при" : "от"]кручивать [src.name]...</span>")
				if(P.use_tool(src, user, 40, volume=75))
					to_chat(user, "<span class='notice'>[anchored ? "От" : "При"]кручиваю [src.name].</span>")
					set_anchored(!anchored)
				return

			if(P.tool_behaviour == TOOL_SCREWDRIVER)
				var/component_check = 1
				for(var/R in req_components)
					if(req_components[R] > 0)
						component_check = 0
						break
				if(component_check)
					P.play_tool_sound(src)
					var/obj/potential_machine = new circuit.build_path(loc)
					if(ismachinery(potential_machine))
						var/obj/machinery/new_machine = potential_machine
						if(new_machine.circuit)
							QDEL_NULL(new_machine.circuit)
						new_machine.circuit = circuit
						new_machine.set_anchored(anchored)
						new_machine.on_construction()
						for(var/obj/O in new_machine.component_parts)
							qdel(O)
						new_machine.component_parts = list()
						for(var/obj/O in src)
							O.moveToNullspace()
							new_machine.component_parts += O
						circuit.moveToNullspace()
						new_machine.RefreshParts()
					qdel(src)
				return

			if(istype(P, /obj/item/storage/part_replacer) && P.contents.len && get_req_components_amt())
				var/obj/item/storage/part_replacer/replacer = P
				var/list/added_components = list()
				var/list/part_list = list()

				//Assemble a list of current parts, then sort them by their rating!
				for(var/obj/item/co in replacer)
					part_list += co
				//Sort the parts. This ensures that higher tier items are applied first.
				part_list = sortTim(part_list, /proc/cmp_rped_sort)

				for(var/path in req_components)
					while(req_components[path] > 0 && (locate(path) in part_list))
						var/obj/item/part = (locate(path) in part_list)
						part_list -= part
						if(istype(part,/obj/item/stack))
							var/obj/item/stack/S = part
							var/used_amt = min(round(S.get_amount()), req_components[path])
							if(!used_amt || !S.use(used_amt))
								continue
							var/NS = new S.merge_type(src, used_amt)
							added_components[NS] = path
							req_components[path] -= used_amt
						else
							added_components[part] = path
							if(SEND_SIGNAL(replacer, COMSIG_TRY_STORAGE_TAKE, part, src))
								req_components[path]--

				for(var/obj/item/part in added_components)
					if(istype(part,/obj/item/stack))
						var/obj/item/stack/S = part
						var/obj/item/stack/NS = locate(S.merge_type) in components //find a stack to merge with
						if(NS)
							S.merge(NS)
					if(!QDELETED(part)) //If we're a stack and we merged we might not exist anymore
						components += part
					to_chat(user, "<span class='notice'>[capitalize(part.name)] применён.</span>")
				if(added_components.len)
					replacer.play_rped_sound()
				return

			if(isitem(P) && get_req_components_amt())
				for(var/I in req_components)
					if(istype(P, I) && (req_components[I] > 0))
						if(istype(P, /obj/item/stack))
							var/obj/item/stack/S = P
							var/used_amt = min(round(S.get_amount()), req_components[I])

							if(used_amt && S.use(used_amt))
								var/obj/item/stack/NS = locate(S.merge_type) in components

								if(!NS)
									NS = new S.merge_type(src, used_amt)
									components += NS
								else
									NS.add(used_amt)

								req_components[I] -= used_amt
								to_chat(user, "<span class='notice'>Добавляю [P.name] к [src.name].</span>")
							return
						if(!user.transferItemToLoc(P, src))
							break
						to_chat(user, "<span class='notice'>Добавляю [P.name] к [src.name].</span>")
						components += P
						req_components[I]--
						return 1
				to_chat(user, "<span class='warning'>Это сюда не помещается!</span>")
				return 0
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/structure/frame/machine/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(state >= 2)
			new /obj/item/stack/cable_coil(loc , 5)
		for(var/X in components)
			var/obj/item/I = X
			I.forceMove(loc)
	..()
