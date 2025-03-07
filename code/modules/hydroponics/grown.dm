// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir.
/obj/item/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/obj/item/seeds/seed = null // type path, gets converted to item on Initialize(). It's safe to assume it's always a seed item.
	var/plantname = ""
	var/bitesize_mod = 0 	// If set, bitesize = 1 + round(reagents.total_volume / bitesize_mod)
	var/splat_type = /obj/effect/decal/cleanable/plant_smudge
	var/can_distill = TRUE //If FALSE, this object cannot be distilled into an alcohol.
	var/distill_reagent //If NULL and this object can be distilled, it uses a generic fruit_wine reagent and adjusts its variables.
	var/wine_flavor //If NULL, this is automatically set to the fruit's flavor. Determines the flavor of the wine if distill_reagent is NULL.
	var/wine_power = 0.1 //Determines the boozepwr of the wine if distill_reagent is NULL. Uses 0.1 - 1.2 not tg's boozepower (divide by 100) else you'll end up with 1000% proof alcohol!
	dried_type = -1 // Saves us from having to define each stupid grown's dried_type as itself. If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	resistance_flags = FLAMMABLE
	origin_tech = "biotech=1"

/obj/item/reagent_containers/food/snacks/grown/Initialize(mapload, obj/item/seeds/new_seed = null)
	. = ..()
	if(!tastes)
		tastes = list("[name]" = 1)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	if(dried_type == -1)
		dried_type = type

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src)
		seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!
		add_juice()
		if(seed.variant)
			name += " \[[seed.variant]]"

/obj/item/reagent_containers/food/snacks/grown/Destroy()
	QDEL_NULL(seed)
	return ..()

/obj/item/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents)
		if(bitesize_mod)
			bitesize = 1 + round(reagents.total_volume / bitesize_mod)
		return 1
	return 0

/obj/item/reagent_containers/food/snacks/grown/examine(user)
	. = ..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				. += T.examine_line


/obj/item/reagent_containers/food/snacks/grown/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(is_sharp(I) && slices_num && slice_path)
		add_fingerprint(user)
		if(!isturf(loc))
			to_chat(user, span_warning("You cannot slice [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
			return .

		var/static/list/acceptable_surfaces = typecacheof(list(
			/obj/structure/table,
			/obj/machinery/optable,
			/obj/item/storage/bag/tray,
		))
		var/acceptable = FALSE
		for(var/thing in loc)
			if(is_type_in_typecache(thing, acceptable_surfaces))
				acceptable = TRUE
				break
		if(!acceptable)
			to_chat(user, span_warning("You cannot slice [src] here! You need a table or at least a tray to do it."))
			return .

		var/slices_lost = 0
		if(istype(I, /obj/item/kitchen/knife) || istype(I, /obj/item/scalpel))
			user.visible_message(
				span_notice("[user] slices [src] with [I]."),
				span_notice("You have sliced [src]."),
			)
		else
			slices_lost = rand(1, min(1, round(slices_num / 2)))
			user.visible_message(
				span_notice("[user] crudely slices [src] with [I]."),
				span_notice("You have crudely sliced [src]."),
			)

		var/reagents_per_slice = reagents.total_volume / slices_num
		for(var/i = 1 to (slices_num - slices_lost))
			var/obj/slice = new slice_path(loc)
			reagents.trans_to(slice, reagents_per_slice)
		qdel(src)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/plant_analyzer))
		send_plant_details(user)
		return .|ATTACK_CHAIN_SUCCESS

	if(seed)
		for(var/datum/plant_gene/trait/trait in seed.genes)
			if(!QDELETED(src) && !QDELETED(I))
				trait.on_attackby(src, I, user)




// Various gene procs
/obj/item/reagent_containers/food/snacks/grown/attack_self(mob/user)
	if(seed && seed.get_gene(/datum/plant_gene/trait/squash))
		if(!do_after(user, 1 SECONDS, user))
			return
		squash(user, user)
	..()

/obj/item/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		if(seed)
			var/mob/thrower = locateUID(thrownby)
			log_action(thrower, hit_atom, "Thrown [src] at")
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)
			if(seed.get_gene(/datum/plant_gene/trait/squash))
				squash(hit_atom, thrower)

/obj/item/reagent_containers/food/snacks/grown/proc/squash(atom/target, mob/thrower)
	var/turf/T = get_turf(src)
	if(ispath(splat_type, /obj/effect/decal/cleanable/plant_smudge))
		if(filling_color)
			var/obj/O = new splat_type(T)
			O.color = filling_color
			O.name = "[name] smudge"
	else if(splat_type)
		new splat_type(T)

	if(trash)
		generate_trash(T)

	visible_message("<span class='warning'>[src] has been squashed.</span>","<span class='italics'>You hear a smack.</span>")
	if(seed)
		for(var/datum/plant_gene/trait/trait in seed.genes)
			trait.on_squash(src, target, thrower)

	reagents.reaction(T)
	for(var/A in T)
		if(reagents)
			reagents.reaction(A)

	qdel(src)

/obj/item/reagent_containers/food/snacks/grown/On_Consume(mob/M, mob/user)
	if(iscarbon(M))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, M)
	..()

// Glow gene procs
/obj/item/reagent_containers/food/snacks/grown/generate_trash(atom/location)
	if(trash && ispath(trash, /obj/item/grown))
		. = new trash(location, seed)
		trash = null
		return
	return ..()

/obj/item/reagent_containers/food/snacks/grown/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["wood"] += 4
	qdel(src)
	return TRUE

// For item-containing growns such as eggy or gatfruit
/obj/item/reagent_containers/food/snacks/grown/shell/attack_self(mob/user)
	user.temporarily_remove_item_from_inventory(src)
	if(trash)
		var/obj/item/T = generate_trash()
		user.put_in_hands(T)
		to_chat(user, "<span class='notice'>You open [src]\'s shell, revealing \a [T].</span>")
	qdel(src)

// Diona Nymphs can eat these as well as weeds to gain nutrition.
/obj/item/reagent_containers/food/snacks/grown/attack_animal(mob/living/simple_animal/M)
	if(isnymph(M))
		var/mob/living/simple_animal/diona/D = M
		D.consume(src)
	else
		return ..()

/obj/item/reagent_containers/food/snacks/grown/proc/log_action(mob/user, atom/target, what_done)
	var/reagent_str = reagents.log_list()
	var/genes_str = "No genes"
	if(seed && length(seed.genes))
		var/list/plant_gene_names = list()
		for(var/thing in seed.genes)
			var/datum/plant_gene/G = thing
			if(G.dangerous)
				plant_gene_names += G.name
		genes_str = english_list(plant_gene_names)

	add_attack_logs(user, target, "[what_done] ([reagent_str] | [genes_str])")


/obj/item/reagent_containers/food/snacks/grown/extinguish_light(force = FALSE)
	if(!force)
		return
	if(seed.get_gene(/datum/plant_gene/trait/glow/shadow))
		return
	set_light_on(FALSE)

/obj/item/reagent_containers/food/snacks/grown/proc/send_plant_details(mob/user)
	var/msg = "<span class='info'>This is \a <span class='name'>[src].</span>\n"
	if(seed)
		msg += seed.get_analyzer_text()
		for(var/reagent_id in seed.reagents_add)
			var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
			var/amt = reagents.get_reagent_amount(reagent_id)
			msg += "\n<span class='info'>- [R.name]: [amt]</span>"
	to_chat(user, msg)

/obj/item/reagent_containers/food/snacks/grown/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.plant_analyzer)
		send_plant_details(user)
