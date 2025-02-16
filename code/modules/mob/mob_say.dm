//Speech verbs.

///Say verb
/mob/verb/say_verb_wrapper()
	set name = "Say"
	set category = "IC"

	var/list/speech_bubble_recipients = list()
	var/bubble_type = "default"

	if(isliving(src))
		var/mob/living/L = src
		bubble_type = L.bubble_icon

	var/image/I = image('icons/mob/talk.dmi', src, "[bubble_type]0", FLY_LAYER)

	if(!stat || stat == 1)
		/*
		var/list/listening = get_hearers_in_view(9, src)
		for(var/mob/M in listening)
			if(!M.client)
				continue
			var/client/C = M.client
			speech_bubble_recipients.Add(C)
		*/
		speech_bubble_recipients = GLOB.clients
		I.alpha = 0
		animate(I, time = 7, loop = -1, easing = SINE_EASING, alpha = 255)
		animate(time = 7, alpha = 80)
		flick_overlay(I, speech_bubble_recipients, -1)

	var/msg = input("", "Say") as null|text

	if(msg)
		if(speech_bubble_recipients.len)
			remove_images_from_clients(I, speech_bubble_recipients)
		say_verb(msg)
	else if(speech_bubble_recipients.len)
		animate(I, time = 7, loop = 1, alpha = 0)
		spawn(7)
			remove_images_from_clients(I, speech_bubble_recipients)

/mob/verb/say_verb(message as text)
	set name = "Say"
	set hidden = 1

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Не могу говорить.</span>")
		return
	if(message)
		say(message)

///Whisper verb
/mob/verb/whisper_verb_wrapper()
	set name = "Whisper"
	set category = "IC"

	var/msg = input(src, null, "Whisper") as text|null
	if(msg)
		whisper_verb(msg)

/mob/verb/whisper_verb(message as text)
	set name = "Whisper"
	set hidden = 1

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Не могу шептать.</span>")
		return
	whisper(message)

///whisper a message
/mob/proc/whisper(message, datum/language/language=null)
	say(message, language) //only living mobs actually whisper, everything else just talks

///The me emote verb
/mob/verb/me_verb_wrapper()
	set name = "Me"
	set category = "IC"

	var/msg = input(src, null, "Me") as text|null
	if(msg)
		me_verb(msg)

/mob/verb/me_verb(message as text)
	set name = "Me"
	set hidden = 1

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Не могу изображать.</span>")
		return

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	var/ckeyname = "[usr.ckey]/[usr.name]"
	webhook_send_me(ckeyname, message)

	usr.emote("me",1,message,TRUE)

///Speak as a dead person (ghost etc)
/mob/proc/say_dead(message)
	var/name = real_name
	var/alt_name = ""

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='danger'>Не могу говорить</span>")
		return

	var/jb = is_banned_from(ckey, "Deadchat")
	if(QDELETED(src))
		return

	if(jb)
		to_chat(src, "<span class='danger'>Мне нельзя говорить.</span>")
		return



	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='danger'>Не хочу говорить.</span>")
			return

		if(src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	var/mob/dead/observer/O = src
	if(isobserver(src) && O.deadchat_name)
		name = "[O.deadchat_name]"
	else
		if(mind && mind.name)
			name = "[mind.name]"
		else
			name = real_name
		if(name != real_name)
			alt_name = " (died as [real_name])"

	var/spanned = say_quote(message)
	var/source = "<span class='game'><span class='prefix'>Призрак</span> <span class='name'>[name]</span>[alt_name]"
	var/rendered = " <span class='message'>[emoji_parse(spanned)]</span></span>"
	log_talk(message, LOG_SAY, tag="DEAD")
	if(SEND_SIGNAL(src, COMSIG_MOB_DEADSAY, message) & MOB_DEADSAY_SIGNAL_INTERCEPT)
		return
	var/displayed_key = key
	if(client?.holder?.fakekey)
		displayed_key = null
	deadchat_broadcast(rendered, source, follow_target = src, speaker_key = displayed_key)

///Check if this message is an emote
/mob/proc/check_emote(message, forced)
	if(message[1] == "*")
		emote(copytext(message, length(message[1]) + 1), intentional = !forced)
		return TRUE

///Check if the mob has a hivemind channel
/mob/proc/hivecheck()
	return 0

///Check if the mob has a ling hivemind
/mob/proc/lingcheck()
	return LINGHIVE_NONE

///The amount of items we are looking for in the message
#define MESSAGE_MODS_LENGTH 6
/**
  * Extracts and cleans message of any extenstions at the begining of the message
  * Inserts the info into the passed list, returns the cleaned message
  *
  * Result can be
  * * SAY_MODE (Things like aliens, channels that aren't channels)
  * * MODE_WHISPER (Quiet speech)
  * * MODE_SING (Singing)
  * * MODE_HEADSET (Common radio channel)
  * * RADIO_EXTENSION the extension we're using (lots of values here)
  * * RADIO_KEY the radio key we're using, to make some things easier later (lots of values here)
  * * LANGUAGE_EXTENSION the language we're trying to use (lots of values here)
  */
/mob/proc/get_message_mods(message, list/mods)
	for(var/I in 1 to MESSAGE_MODS_LENGTH)
		// Prevents "...text" from being read as a radio message
		if (length(message) > 1 && message[2] == message[1])
			continue

		var/key = message[1]
		var/chop_to = 2 //By default we just take off the first char
		if(key == "#" && !mods[WHISPER_MODE])
			mods[WHISPER_MODE] = MODE_WHISPER
		else if(key == "%" && !mods[MODE_SING])
			mods[MODE_SING] = TRUE
		else if(key == ";" && !mods[MODE_HEADSET])
			mods[MODE_HEADSET] = TRUE
		else if((key in GLOB.department_radio_prefixes) && length(message) > length(key) + 1 && !mods[RADIO_EXTENSION])
			mods[RADIO_KEY] = lowertext(message[1 + length(key)])
			mods[RADIO_EXTENSION] = GLOB.department_radio_keys[mods[RADIO_KEY]]
			chop_to = length(key) + 2
		else if(key == "," && !mods[LANGUAGE_EXTENSION])
			for(var/ld in GLOB.all_languages)
				var/datum/language/LD = ld
				if(initial(LD.key) == message[1 + length(message[1])])
					// No, you cannot speak in xenocommon just because you know the key
					if(!can_speak_language(LD))
						return message
					mods[LANGUAGE_EXTENSION] = LD
					chop_to = length(key) + length(initial(LD.key)) + 1
			if(!mods[LANGUAGE_EXTENSION])
				return message
		else
			return message
		message = trim_left(copytext_char(message, chop_to))
		if(!message)
			return
	return message
