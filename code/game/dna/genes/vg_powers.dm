///////////////////Vanilla Morph////////////////////////////////////

/datum/dna/gene/basic/grant_spell/morph
	name = "Morphism"
	desc = "Enables the subject to reconfigure their appearance to that of any human."
	spelltype = /obj/effect/proc_holder/spell/morph
	activation_messages = list("Your body feels if can alter its appearance.")
	deactivation_messages = list("Your body doesn't feel capable of altering its appearance.")
	instability = GENE_INSTABILITY_MINOR


/datum/dna/gene/basic/grant_spell/morph/New()
	..()
	block = GLOB.morphblock

/obj/effect/proc_holder/spell/morph
	name = "Morph"
	desc = "Mimic the appearance of your choice!"
	base_cooldown = 3 MINUTES

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_morph"


/obj/effect/proc_holder/spell/morph/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/morph/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return

	if(ismob(user.loc))
		to_chat(user, "<span class='warning'>You can't change your appearance right now!</span>")
		return
	var/mob/living/carbon/human/M = user
	var/obj/item/organ/external/head/head_organ = M.get_organ(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/eyes/eyes_organ = M.get_int_organ(/obj/item/organ/internal/eyes)

	var/new_gender = tgui_alert(user, "Please select gender.", "Character Generation", list("Male", "Female"))
	if(new_gender)
		if(new_gender == "Male")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	if(eyes_organ)
		var/new_eyes = input("Please select eye color.", "Character Generation", eyes_organ.eye_colour) as null|color
		if(new_eyes)
			M.change_eye_color(new_eyes)

	if(istype(head_organ))
		//Alt heads.
		if(head_organ.dna.species.bodyflags & HAS_ALT_HEADS)
			var/list/valid_alt_heads = M.generate_valid_alt_heads()
			var/new_alt_head = input("Please select alternate head", "Character Generation", head_organ.alt_head) as null|anything in valid_alt_heads
			if(new_alt_head)
				M.change_alt_head(new_alt_head)

		// hair
		var/list/valid_hairstyles = M.generate_valid_hairstyles()
		var/new_style = input("Please select hair style", "Character Generation", head_organ.h_style) as null|anything in valid_hairstyles

		// if new style selected (not cancel)
		if(new_style)
			M.change_hair(new_style)

		var/new_hair = input("Please select hair color.", "Character Generation", head_organ.hair_colour) as null|color
		if(new_hair)
			M.change_hair_color(new_hair)

		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_public_list[head_organ.h_style]
		if(hair_style.secondary_theme && !hair_style.no_sec_colour)
			new_hair = input("Please select secondary hair color.", "Character Generation", head_organ.sec_hair_colour) as null|color
			if(new_hair)
				M.change_hair_color(new_hair, TRUE)

		// facial hair
		var/list/valid_facial_hairstyles = M.generate_valid_facial_hairstyles()
		new_style = input("Please select facial style", "Character Generation", head_organ.f_style) as null|anything in valid_facial_hairstyles

		if(new_style)
			M.change_facial_hair(new_style)

		var/new_facial = input("Please select facial hair color.", "Character Generation", head_organ.facial_colour) as null|color
		if(new_facial)
			M.change_facial_hair_color(new_facial)

		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[head_organ.f_style]
		if(facial_hair_style.secondary_theme && !facial_hair_style.no_sec_colour)
			new_facial = input("Please select secondary facial hair color.", "Character Generation", head_organ.sec_facial_colour) as null|color
			if(new_facial)
				M.change_facial_hair_color(new_facial, TRUE)

		//Head accessory.
		if(head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
			var/list/valid_head_accessories = M.generate_valid_head_accessories()
			var/new_head_accessory = input("Please select head accessory style", "Character Generation", head_organ.ha_style) as null|anything in valid_head_accessories
			if(new_head_accessory)
				M.change_head_accessory(new_head_accessory)

			var/new_head_accessory_colour = input("Please select head accessory colour.", "Character Generation", head_organ.headacc_colour) as null|color
			if(new_head_accessory_colour)
				M.change_head_accessory_color(new_head_accessory_colour)

	//Body accessory.
	if((M.dna.species.tail && M.dna.species.bodyflags & (HAS_TAIL)) || (M.dna.species.wing && M.dna.species.bodyflags & (HAS_WING)))
		var/list/valid_body_accessories = M.generate_valid_body_accessories()
		if(valid_body_accessories.len > 1) //By default valid_body_accessories will always have at the very least a 'none' entry populating the list, even if the user's species is not present in any of the list items.
			var/new_body_accessory = input("Please select body accessory style", "Character Generation", M.body_accessory) as null|anything in valid_body_accessories
			if(new_body_accessory)
				M.change_body_accessory(new_body_accessory)

	if(istype(head_organ))
		//Head markings.
		if(M.dna.species.bodyflags & HAS_HEAD_MARKINGS)
			var/list/valid_head_markings = M.generate_valid_markings("head")
			var/new_marking = input("Please select head marking style", "Character Generation", M.m_styles["head"]) as null|anything in valid_head_markings
			if(new_marking)
				M.change_markings(new_marking, "head")

			var/new_marking_colour = input("Please select head marking colour.", "Character Generation", M.m_colours["head"]) as null|color
			if(new_marking_colour)
				M.change_marking_color(new_marking_colour, "head")

	//Body markings.
	if(M.dna.species.bodyflags & HAS_BODY_MARKINGS)
		var/list/valid_body_markings = M.generate_valid_markings("body")
		var/new_marking = input("Please select body marking style", "Character Generation", M.m_styles["body"]) as null|anything in valid_body_markings
		if(new_marking)
			M.change_markings(new_marking, "body")

		var/new_marking_colour = input("Please select body marking colour.", "Character Generation", M.m_colours["body"]) as null|color
		if(new_marking_colour)
			M.change_marking_color(new_marking_colour, "body")
	//Tail markings.
	if(M.dna.species.bodyflags & HAS_TAIL_MARKINGS)
		var/list/valid_tail_markings = M.generate_valid_markings("tail")
		var/new_marking = input("Please select tail marking style", "Character Generation", M.m_styles["tail"]) as null|anything in valid_tail_markings
		if(new_marking)
			M.change_markings(new_marking, "tail")

		var/new_marking_colour = input("Please select tail marking colour.", "Character Generation", M.m_colours["tail"]) as null|color
		if(new_marking_colour)
			M.change_marking_color(new_marking_colour, "tail")

	//Skin tone.
	if(M.dna.species.bodyflags & HAS_SKIN_TONE)
		var/new_tone = input("Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 35
		else
			new_tone = 35 - max(min(round(text2num(new_tone)), 220), 1)
			M.change_skin_tone(new_tone)

	if(M.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/prompt = "Please select skin tone: 1-[M.dna.species.icon_skin_tones.len] ("
		for(var/i = 1 to M.dna.species.icon_skin_tones.len)
			prompt += "[i] = [M.dna.species.icon_skin_tones[i]]"
			if(i != M.dna.species.icon_skin_tones.len)
				prompt += ", "
		prompt += ")"

		var/new_tone = input(prompt, "Character Generation", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 0
		else
			new_tone = max(min(round(text2num(new_tone)), M.dna.species.icon_skin_tones.len), 1)
			M.change_skin_tone(new_tone)

	//Skin colour.
	if(M.dna.species.bodyflags & HAS_SKIN_COLOR)
		var/new_body_colour = input("Please select body colour.", "Character Generation", M.skin_colour) as null|color
		if(new_body_colour)
			M.change_skin_color(new_body_colour)

	M.update_dna()

	M.visible_message("<span class='notice'>[M] morphs and changes [M.p_their()] appearance!</span>", "<span class='notice'>You change your appearance!</span>", "<span class='warning'>Oh, god!  What the hell was that?  It sounded like flesh getting squished and bone ground into a different shape!</span>")


/datum/dna/gene/basic/grant_spell/remotetalk
	name = "Telepathy"
	activation_messages = list("You feel you can project your thoughts.")
	deactivation_messages = list("You no longer feel you can project your thoughts.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/remotetalk


/datum/dna/gene/basic/grant_spell/remotetalk/New()
	..()
	block = GLOB.remotetalkblock


/datum/dna/gene/basic/grant_spell/remotetalk/activate(mob/living/mutant, flags)
	. = ..()
	var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
	mutant.AddSpell(new /obj/effect/proc_holder/spell/mindscan(null))
	hud.manage_hud(mutant, THOUGHTS_HUD_PRECISE)


/datum/dna/gene/basic/grant_spell/remotetalk/deactivate(mob/living/mutant, flags)
	. = ..()
	var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
	for(var/obj/effect/proc_holder/spell/mindscan/spell in mutant.mob_spell_list)
		mutant.RemoveSpell(spell)
	hud.manage_hud(mutant, THOUGHTS_HUD_DISPERSE)


/obj/effect/proc_holder/spell/remotetalk
	name = "Project Mind"
	desc = "Make people understand your thoughts!"
	base_cooldown = 0

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_project"

/obj/effect/proc_holder/spell/remotetalk/create_new_targeting()
	return new /datum/spell_targeting/telepathic


/obj/effect/proc_holder/spell/remotetalk/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!ishuman(user))
		return
	if(user.mind?.miming) // Dont let mimes telepathically talk
		to_chat(user,"<span class='warning'>You can't communicate without breaking your vow of silence.</span>")
		return
	for(var/mob/living/target in targets)
		var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
		hud.manage_hud(target, THOUGHTS_HUD_PRECISE)
		// user.hud_typing = TRUE do not know what to do
		user.thoughts_hud_set(TRUE)
		var/say = tgui_input_text(user, "What do you wish to say?", "Project Mind")
		// user.hud_typing = FALSE
		user.typing = FALSE
		if(!say || usr.stat)
			hud.manage_hud(target, THOUGHTS_HUD_DISPERSE)
			user.thoughts_hud_set(FALSE)
			return
		user.thoughts_hud_set(TRUE, say_test(say))
		addtimer(CALLBACK(hud, TYPE_PROC_REF(/datum/atom_hud/thoughts/, manage_hud), target, THOUGHTS_HUD_DISPERSE), 3 SECONDS)
		say = strip_html(say)
		say = pencode_to_html(say, usr, format = 0, fields = 0)
		log_say("(TPATH to [key_name(target)]) [say]", user)
		user.create_log(SAY_LOG, "Telepathically said '[say]' using [src]", target)
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			target.show_message("<span class='abductor'>You hear [user.real_name]'s voice: [say]</span>")
		else
			target.show_message("<span class='abductor'>You hear a voice that seems to echo around the room: [say]</span>")
		user.show_message("<span class='abductor'>You project your mind into [(target in user.get_visible_mobs()) ? target.name : "the unknown entity"]: [say]</span>")
		for(var/mob/dead/observer/G in GLOB.player_list)
			G.show_message("<i>Telepathic message from <b>[user]</b> ([ghost_follow_link(user, ghost=G)]) to <b>[target]</b> ([ghost_follow_link(target, ghost=G)]): [say]</i>")


/obj/effect/proc_holder/spell/mindscan
	name = "Scan Mind"
	desc = "Offer people a chance to share their thoughts!"
	base_cooldown = 45 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	action_icon_state = "genetic_mindscan"
	var/list/available_targets = list()


/obj/effect/proc_holder/spell/mindscan/create_new_targeting()
	return new /datum/spell_targeting/telepathic


/obj/effect/proc_holder/spell/mindscan/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return
	for(var/mob/living/target in targets)
		var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
		var/message = "You feel your mind expand briefly... (Click to send a message.)"
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			message = "You feel [user.real_name] request a response from you... (Click here to project mind.)"
		user.show_message("<span class='abductor'>You offer your mind to [(target in user.get_visible_mobs()) ? target.name : "the unknown entity"].</span>")
		target.show_message("<span class='abductor'><a href='byond://?src=[UID()];target=[target.UID()];user=[user.UID()]'>[message]</a></span>")
		available_targets += target
		hud.manage_hud(target, THOUGHTS_HUD_PRECISE)
		addtimer(CALLBACK(src, PROC_REF(removeAvailability), target), 45 SECONDS)


/obj/effect/proc_holder/spell/mindscan/proc/removeAvailability(mob/living/target)
	if(target in available_targets)
		var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
		available_targets -= target
		hud.manage_hud(target, THOUGHTS_HUD_DISPERSE)
		target.show_message("<span class='abductor'>You feel the sensation fade...</span>")


/obj/effect/proc_holder/spell/mindscan/Topic(href, href_list)
	var/mob/living/user
	if(href_list["user"])
		user = locateUID(href_list["user"])
	if(href_list["target"])
		if(!user)
			return
		var/mob/living/target = locateUID(href_list["target"])
		if(!(target in available_targets))
			return
		// target.hud_typing = TRUE
		target.thoughts_hud_set(TRUE)
		var/say = tgui_input_text(user, "What do you wish to say?", "Scan Mind")
		// target.hud_typing = FALSE
		target.typing = FALSE
		if(!say || target.stat)
			target.thoughts_hud_set(FALSE)
			return
		target.thoughts_hud_set(TRUE, say_test(say))
		say = strip_html(say)
		say = pencode_to_html(say, target, format = 0, fields = 0)
		user.create_log(SAY_LOG, "Telepathically responded '[say]' using [src]", target)
		log_say("(TPATH to [key_name(target)]) [say]", user)
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			target.show_message("<span class='abductor'>You project your mind into [user.name]: [say]</span>")
		else
			target.show_message("<span class='abductor'>You fill the space in your thoughts: [say]</span>")
		user.show_message("<span class='abductor'>You hear [target.name]'s voice: [say]</span>")
		for(var/mob/dead/observer/G in GLOB.player_list)
			G.show_message("<i>Telepathic response from <b>[target]</b> ([ghost_follow_link(target, ghost=G)]) to <b>[user]</b> ([ghost_follow_link(user, ghost=G)]): [say]</i>")


/obj/effect/proc_holder/spell/mindscan/Destroy()
	for(var/mob/living/target in available_targets)
		removeAvailability(target)
	return ..()


/datum/dna/gene/basic/grant_spell/remoteview
	name = "Remote Viewing"
	activation_messages = list("Your mind can see things from afar.")
	deactivation_messages = list("Your mind can no longer can see things from afar.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/remoteview
	traits_to_add = list(TRAIT_OPEN_MIND)


/datum/dna/gene/basic/grant_spell/remoteview/New()
	..()
	block = GLOB.remoteviewblock


/obj/effect/proc_holder/spell/remoteview
	name = "Remote View"
	desc = "Spy on people from any range!"
	base_cooldown = 10 SECONDS

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_view"


/obj/effect/proc_holder/spell/remoteview/create_new_targeting()
	return new /datum/spell_targeting/remoteview


/obj/effect/proc_holder/spell/remoteview/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H
	if(ishuman(user))
		H = user
	else
		return

	var/mob/target

	if(istype(H.l_hand, /obj/item/tk_grab) || istype(H.r_hand, /obj/item/tk_grab))
		to_chat(H, "<span class='warning'>Your mind is too busy with that telekinetic grab.</span>")
		H.remoteview_target = null
		H.reset_perspective()
		return

	if(H.client.eye != user.client.mob)
		H.remoteview_target = null
		H.reset_perspective()
		return

	for(var/mob/living/L in targets)
		target = L

	if(target)
		H.remoteview_target = target
		H.reset_perspective(target)
	else
		H.remoteview_target = null
		H.reset_perspective()

