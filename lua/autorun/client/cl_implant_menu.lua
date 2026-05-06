LocalInventory = LocalInventory or {}
local sw, sh = ScrW(), ScrH()
local inventoryFrame = nil
local _harvestFrame = nil
CHROMA = CHROMA or {}
CHROMA.values = CHROMA.values or {}

local cyan       = Color(255, 40, 60, 255) 
local cyandim    = Color(255, 100, 110, 200)
local cyanfaint  = Color(100, 15, 25, 255)  
local col_bg     = Color(8, 2, 4, 250)      
local col_panel  = Color(20, 5, 8, 255)  
local col_border = Color(255, 40, 60, 60)    
local col_hover  = Color(255, 40, 60, 30)   
local col_active = Color(255, 20, 40, 60)     
local col_red    = Color(255, 50, 50, 255)    
local col_locked = Color(80, 60, 65, 180)   
local col_owned  = Color(90, 255, 140, 255)
local col_matrix = Color(255, 40, 60, 255)

surface.CreateFont("NL_Menu_Title", {
    font = "Ari-W9500", size = ScreenScale(14),
    weight = 700, extended = true, antialias = true,
})
surface.CreateFont("NL_Menu_Sub", {
    font = "Ari-W9500", size = ScreenScale(6),
    weight = 500, extended = true, antialias = true,
})
surface.CreateFont("NL_Menu_Tiny", {
    font = "Ari-W9500", size = ScreenScale(4.5),
    weight = 400, extended = true, antialias = true,
})
surface.CreateFont("NL_Menu_Harvest", {
    font = "Sjz",
    size = ScreenScale(6),
    weight = 700,
    extended = true,
    antialias = true,
})
surface.CreateFont("NL_Menu_Harvest_Title", {
    font = "Sjz",
    size = ScreenScale(23),
    weight = 700,
    extended = true,
    antialias = true,
})
surface.CreateFont("NL_Menu_Harvest_Sub", {
    font = "Sjz",
    size = ScreenScale(12),
    weight = 700,
    extended = true,
    antialias = true,
})

-- Implants grouped by type, tiers as sub-list
-- netvar = true means SetNetVar, otherwise organism flag
SLOTS = {
    { label = "HEAD", implants = {
    { name = "NeuroLink", desc = "Neural interface for HUD integration.", tiers = {
        { id = "implant_neurolink_scrap",    label = "Scrap",    netvar = true, desc = "A very low-effort neurolink rip-off.\n\nRescued from an e-waste bin. Permanently smells like burnt plastic. HUD flickers like a candle in a storm. Sometimes it just shows you a blue screen of death mid-firefight. Hopes and prayers gng." },
        { id = "implant_neurolink_diy",      label = "DIY",      netvar = true, desc = "Assembled from a YouTube tutorial and a Dreamcast.\n\nThe most commonly used optic in all the New US of A, not for being good but for being cheap and reliable. It works and gets the job done, sometimes." },
        { id = "implant_neurolink_blackmarket", label = "Black Market", netvar = true, desc = "Hotter than a reactor core. Literally stolen from Neurolink's R&D.\n\nWorks perfectly, but every third ad is a threat from corporate recovery agents. Got rewired a bit by some local thug, and it shows." },
        { id = "implant_neurolink_basic",        label = "Basic",    netvar = true, desc = "Standard issue for anyone with a pulse. Reads your pulse.\n\nSees your heartbeat spike when a pretty face passes. Corpo marketing now knows your type and sells it to dating apps. Romance is dead, holmes." },
        { id = "implant_neurolink_military",     label = "Military", netvar = true, desc = "Mil-spec HUD. Tracks stamina and rounds.\n\nDisplays ammo you're about to waste. Spoiler: it's always 'all of it.' Also counts your guns weight and nags you when your ammo's low." },
        { id = "implant_neurolink_militaryplus", label = "Mil+",     netvar = true, desc = "Adds a crosshair and night vision.\n\nWow, a literal crosshair? What's next, the game aiming for you? Oh wait, that's aim assist. Never mind, you're still a filthy casual." },
    }},
    { name = "Compass", desc = "Tactical directional overlay.", tiers = {
        { id = "implant_compass_scrap", label = "Scrap", netvar = true, desc = "A kid's toy compass glued to a circuit board. NeurolinkCo. would sue if they cared.\n\nPoints somewhere, maybe north, maybe your doom. Fluctuates when near magnets or bad decisions. And it's always bad decisions when you're around, dumbass." },
        { id = "implant_compass_diy", label = "DIY", netvar = true, desc = "Built from an old smartphone's gyro.\n\nWorks, but thinks you're moving at grandma speed. Directional updates lag like a 20s dial-up." },
        { id = "implant_compass_blackmarket", label = "Black Market", netvar = true, desc = "Shows friendly and hostile dots.\n\nDisplays contacts real and imaginary. That flickering 'enemy' blip might just be a particularly aggressive squirrel. Allegedly obtained from a paranoid ex-soldier" },
        { id = "implant_compass_1", label = "T1", netvar = true, desc = "Basic N, S, E, W.\n\nShows which way the corpo tower is so you can avoid it. Or run towards it if you're feeling spicy. Groundbreaking, I know." },
        { id = "implant_compass_2", label = "T2", netvar = true, desc = "Pings lifeforms within range.\n\nNow you can see every single entity that wants to kill you. Or just the pizza delivery drone. Both equally dangerous." },
        { id = "implant_compass_3", label = "T3", netvar = true, desc = "Full wallhack radar.\n\nSee enemies through walls. Feel like a god. Until you realize they have this too and are already aiming at your dumb highlighted silhouette." },
    }},
    { name = "OTHER", desc = "Visual augmentations for NeuroLink.", tiers = {
        { id = "implant_nvg",     label = "NVG",     netvar = true, desc = "Night vision.\n\nSee in the dark like a cat. A cat with a 2000-euro loan and an unhealthy obsession with white phosphor." },
        { id = "implant_thermal", label = "Thermal", netvar = true, desc = "Thermal overlay. Heat signatures glow like neon.\n\nSee body heat through walls. Walls are still walls, but now you can spot the guard hiding behind one before he spots you. Probably." },
        { id = "implant_mp3",     label = "MP3 Player", netvar = true, desc = "Neural music player. Streams directly into your auditory cortex.\n\nPlay your own soundtrack while committing crimes. Nothing says 'cyberpsycho' like murdering to jazz." },
    }},
    { name = "CyberDeck", desc = "Hacking interface. Requires NeuroLink.", tiers = {
        { id = "implant_cyberdeck_basic", label = "WIP", netvar = true, desc = "WIP" },
        { id = "implant_cyberdeck_advanced", label = "WIP", netvar = true, desc = "WIP" },
        { id = "implant_cyberdeck_pro", label = "WIP", netvar = true, desc = "WIP." },
    }},
}},
    { label = "TORSO", implants = {
        { name = "Cardiac Implant", desc = "Prevents cardiac arrest.", tiers = {
            { id = "implant_cardiac_1", label = "T1", desc = "Basic defibrillator implant. Prevents instant cardiac death.\n\nGives you a rude electrical slap back to life. Like an alarm clock for your heart that screams 'not today, motherfucker'." },
            { id = "implant_cardiac_2", label = "T2", desc = "Improved voltage regulation and rhythm correction.\n\nNow survives heart attacks that would drop a normal person. Your heart still complains, but at least it keeps beating." },
            { id = "implant_cardiac_3", label = "T3", desc = "Precision cardiac regulator with real-time monitoring.\n\nKeeps perfect rhythm even under extreme stress. Some users report occasional 'hiccups'. Usually non-lethal." },
            { id = "implant_cardiac_4", label = "T4", desc = "Advanced cybernetic heart support system.\n\nYour heart is now stronger than the rest of your fragile meat body. Could probably power a small scooter." },
            { id = "implant_cardiac_5", label = "T5", desc = "Total cardiac independence. Heart functions as a self-sustaining micro-reactor.\n\nYou are now immortal from the sternum down. Headshots remain an effective countermeasure." },
        }},
        { name = "Blood Filter", desc = "Removes blood toxins.", tiers = {
            { id = "implant_bloodfilter_1", label = "T1", desc = "Slowly filters carbon monoxide and mild toxins.\n\nLike that cheap robot vacuum, it bumps around your bloodstream, occasionally cleaning something. It'll get there eventually. Probably." },
            { id = "implant_bloodfilter_2", label = "T2", desc = "Moderate filtration speed.\n\nGets rid of booze, low-grade nerve agents, and that questionable street meat you ate. Still won't undo your other life choices." },
            { id = "implant_bloodfilter_3", label = "T3", desc = "Good toxin scrubbing.\n\nLike a single pristine drop in an ocean of poison, but hey, every drop counts. Your liver is sending thank-you notes." },
            { id = "implant_bloodfilter_4", label = "T4", desc = "Fast toxin removal.\n\nSomehow prevents you from bleeding out internally. You're now unnervingly durable. Go ahead, get shot for fun." },
            { id = "implant_bloodfilter_5", label = "T5", desc = "Rapidly clears all contaminants.\n\nVampires would write sonnets about your hemoglobin. Toxins flee your body in terror. You're basically a walking detox ad." },
        }},
        { name = "Blood Refill", desc = "Regenerates blood supply.", tiers = {
            { id = "implant_bloodrefill_1", label = "T1", desc = "1000ml onboard emergency blood reserve.\n\nSmall top-up so you don't faceplant after minor bleeding." },
            { id = "implant_bloodrefill_2", label = "T2", desc = "2-liter emergency blood reserve.\n\nNow you can bleed stylishly for twice as long." },
            { id = "implant_bloodrefill_3", label = "T3", desc = "3-liter blood reservoir with slow regeneration.\n\nYou're officially a walking blood bag." },
            { id = "implant_bloodrefill_4", label = "T4", desc = "Large-capacity blood regeneration tank.\n\nIntroduced by ARCOM during the Second African Conflict. Nobody asks where they got that much extra blood." },
            { id = "implant_bloodrefill_5", label = "T5", desc = "Massive self-replenishing blood reservoir.\n\n'I'm out of blood' is now a lie you tell yourself. Even a severed artery is a minor inconvenience." },
        }},
        { name = "Pain Dampener", desc = "Reduces pain and shock.", tiers = {
            { id = "implant_paindampener_1", label = "T1", desc = "10% pain reduction.\n\nStill ow, but a more dignified ow. You'll still cry, but the tears will be slightly less salty." },
            { id = "implant_paindampener_2", label = "T2", desc = "20% pain reduction.\n\nYou can now endure a mild mauling without immediately reconsidering your life choices.  Certified for 3 curb bites. Progress." },
            { id = "implant_paindampener_3", label = "T3", desc = "Good dampening.\n\nYour pain threshold is now 'feral dog attack' level. You'll still feel it, but your screams become more of a polite complaint. Up to 6 curb bites tolerance." },
            { id = "implant_paindampener_4", label = "T4", desc = "Strong numbing.\n\nYou feel nothing. Not the bullet wound, not the sunset." },
            { id = "implant_paindampener_5", label = "T5", desc = "Near-total pain immunity.\n\nThis implant is also made by corpos, but the irony is lost on your unfeeling nervous system. Pain is a corpo myth, and you're woke." },
        }},
        { name = "Subdermal Armor", desc = "Armor plating under skin.", tiers = {
            { id = "implant_subdermal_scrap",  label = "Scrap",   desc = "40% chance to fail spectacularly. When it fails, it doubles incoming damage.\n\nLike wearing a 'kick me' sign made of glass. Provides negative protection. You'll wish you were naked." },
            { id = "implant_subdermal_diy",    label = "DIY",     desc = "Random armor rating. Literally rolls dice every time you're hit.\n\nOne moment a tank, next moment a wet paper bag. Unpredictable, like your mood swings, psychotic prick." },
            { id = "implant_subdermal_blackmarket", label = "Black Market", desc = "Stolen mil-spec weave. Good protection.\n\nActually a reliable low-price alternative, however it is ceramic and may shatter on impact causing SEVERE bleeding. What a trade tho." },
            { id = "implant_subdermal_zeta",  label = "ZetaTech", desc = "ZetaTech light armor.\n\nStops BB guns, harsh language, and light insults. Anything bigger and you're a modern art installation of red." },
            { id = "implant_subdermal_osha",  label = "OSHA",     desc = "OSHA-approved workplace armor.\n\n For when your job involves getting shot. Medium plating. Now compliant with workplace safety for mercenaries. Where the hell do you work, a warzone? Oh, right." },
            { id = "implant_subdermal_arcom", label = "ARCOM",    desc = "ARCOM heavy armor.\n\nHOW IS HE ALIVE I SHOT HIM 12 TIMES IN THE HEAD. But for real tho, try and shoot yourself. The label on the back claims: 'Protects from every caliber'" },
        }},
        { name = "Temp Regulator", desc = "Regulates body temperature.", tiers = {
            { id = "implant_temp", label = "T1", desc = "Maintains a cozy 36.7°C no matter the climate.\n\nStand in a freezer to impress your friends. In a fire, you get 20 seconds to realize you're still flammable. A cool trick, literally, until you're well-done." },
        }},
        { name = "Adrenaline", desc = "Adrenaline injection system.", tiers = {
            { id = "implant_adrenal", label = "T1", desc = "Auto-injects adrenaline in life-threatening situations.\n\nYou'll definitely try to trigger it manually for a rush. It'll either save you or fry your adrenal glands. Janky but fun." },
        }},
        { name = "Morphine", desc = "Auto pain management.", tiers = {
            { id = "implant_morphine", label = "T1", desc = "Auto-administers morphine upon severe injury. Legal-ish.\n\nYou'll feel a warm hug from the inside as you bleed out. Your last words might be 'wheeee' but at least they're painless. Probably legal, don't ask." },
        }},
        { name = "Fury Implant", desc = "Combat stimulants. Mutually exclusive.", tiers = {
            { id = "implant_fury13", label = "Fury-13", desc = "Combat stim. Sends you into a berserker rage.\n\nYou'll feel invincible and will definitely get your ass kicked. Side effects include loving being stomped. Don't ask why you're smiling while getting curbstomped." },
            { id = "implant_fury16", label = "Fury-16", desc = "Pure noradrenaline spike. Time slows, logic leaves.\n\nOne moment you're tactical, the next you're screaming incoherently and punching a tank. You'll love it, your squad will hate it." },
        }},
    }},
    { label = "LEGS", implants = {
        { name = "Air Jump", desc = "Secondary jump mid-air.", tiers = {
            { id = "implant_airjump_scrap",   label = "Scrap",   desc = "A spring from a broken bed and a prayer.\n\nSometimes gives a second jump. Sometimes just kicks you in the shins. 50/50 gamble, and the house always wins." },
            { id = "implant_airjump_diy",     label = "DIY",     desc = "Home-brewed jump jets made from aerosol cans and a car battery.\n\nHeight varies wildly. You might clear a fence or launch yourself into low orbit. Wear a helmet." },
            { id = "implant_airjump_blackmarket", label = "Black Market", desc = "Stolen military prototype. Works well but leaves a bright exhaust trail saying 'shoot me here'.\n\nGreat for stylish escapes, terrible for stealth. Everyone will see your majestic double jump and then fill you with lead." },
            { id = "implant_airjump_low",   label = "T1 Low",   desc = "Low double jump. Slight leg singe included.\n\nBarely gets you over a small box. Might burn your calves. Still, you can now say you double-jumped. So there's that." },
            { id = "implant_airjump_mid",   label = "T2 Mid",   desc = "Medium boost. Less fiery, more lofty.\n\nNow you can reach that slightly higher ledge without third-degree burns. Progress." },
            { id = "implant_airjump_high",  label = "T3 High",  desc = "High jump with fall protection. Protects against impact, allegedly.\n\nWill break your legs on landing regardless of 'protection.' You'll soar like an eagle and land like a sack of bricks." },
            { id = "implant_airjump_black", label = "T4 Black", desc = "Extreme height boost. You can practically touch the skybox.\n\n'I CAN SEE MY HOUSE FROM UP HERE!' followed by 'I CAN'T FEEL MY LEGS FROM DOWN HERE!' Worth it." },
        }},
        { name = "Dash", desc = "Burst speed on double-tap.", tiers = {
            { id = "implant_dash_scrap",  label = "Scrap", desc = "A coin flip that either dashes you forward or introduces your face to the floor.\n\n50% tripping hazard, 50% barely moving. Whichever happens, humiliation is guaranteed." },
            { id = "implant_dash_diy",    label = "DIY", desc = "Random speed generator. Sometimes you Nyoom, sometimes you get stuck mid-animation.\n\nGlitches out frequently, leaving you frozen in a Naruto run pose. Enemies will laugh before they shoot." },
            { id = "implant_dash_blackmarket", label = "Black Market", desc = "Smooth dash with a dramatic smoke trail. Stolen from a street magician.\n\nUseful but leaves a cloud of glittery smoke. You'll escape, but everyone will know which way you went. Fabulous." },
            { id = "implant_dash_low",  label = "T1", desc = "Short lateral dash. Nyoom.\n\nA quick sidestep that might dodge a melee attack if you time it perfectly. Spoiler: you won't." },
            { id = "implant_dash_2",    label = "T2", desc = "Medium ground dash.\n\n Tested to dodge headcrabs on a good day. On a bad day, the headcrab is already mid-air and you dash directly into its loving embrace." },
            { id = "implant_dash_high", label = "T3", desc = "Long ground dash.\n\n Can outmaneuver an Antlion Guard, theoretically. Requires quick reflexes and a prayer. You'll still get charged into a wall, but at least you'll look cool trying." },
            { id = "implant_dash_4",    label = "T4", desc = "Aerial dash.\n\n You can now dash mid-air. Extremely unsafe. 'Fly' is a strong word. More like 'controlled falling with style.' Do NOT use unless you know DAMN WELL what you're doing." },
            { id = "implant_dash_5",    label = "T5", desc = "Extended aerial dash.\n\nYou are now a fighter jet with a bad attitude. 'Don't talk to me.' Soars across the map, leaving a message: 'I'm better than you.' Also leaves a crater if you miss the landing." },
        }},
        { name = "Charge Jump", desc = "Hold to charge, release to launch.", tiers = {
            { id = "implant_chargejump_scrap",   label = "Scrap",   desc = "Overcharged springs from a broken pogo stick. Long charge time, 30% chance to explode.\n\nThe explosion launches you. Whether that's up or into pieces is up to the RNG gods." },
            { id = "implant_chargejump_diy",     label = "DIY",     desc = "Unstable charged leap. Power varies wildly; sometimes sends you laterally into a wall.\n\nYou wanted to go up. Now you're embedded in a brick facade. At least the wall broke your fall." },
            { id = "implant_chargejump_blackmarket", label = "Black Market", desc = "Smuggled charge jump. Works beautifully but overheats if you charge too long.\n\nHold it for max power and your legs catch fire. But hey, you'll reach that rooftop with a stylish smoke trail." },
            { id = "implant_chargejump_1", label = "T1", desc = "Basic charge jump. Half a story high.\n\nEnough to reach a low balcony or escape a bad date. Through tedious tests, it sometimes works exactly as advertised. Sometimes." },
            { id = "implant_chargejump_2", label = "T2", desc = "Improved leap. One full story.\n\nCharges longer, so you have time to contemplate your life choices while crouching. Then you spring up like a startled cat." },
            { id = "implant_chargejump_3", label = "T3", desc = "Strong charge. About three stories. The dev forgot the exact number.\n\n'I think it's three? Just go test, idc.' You'll either clear the building or become a cautionary tale." },
            { id = "implant_chargejump_4", label = "T4", desc = "MOAB-grade launch. You are the Mother of All Bounces.\n\nYou'll soar over small buildings. The landing is your problem. Gravity called, it wants its inevitability back." },
            { id = "implant_chargejump_5", label = "T5", desc = "Eclipse-tech rocket jump. Literally a controlled explosion under your feet.\n\nDangerous for the user, and anyone standing nearby. You'll reach the stratosphere. Re-entry is a you problem." },
        }},
        { name = "Bone Lacing", desc = "Reinforces skeletal structure.", tiers = {
            { id = "implant_bone_lacing_1", label = "T1", desc = "Minor skeletal reinforcement. Bones knit slowly.\n\nA great gift for grandma who keeps falling. She'll now only break three bones instead of four. Progress." },
            { id = "implant_bone_lacing_2", label = "T2", desc = "Moderate lacing. Faster healing, but joints still pop out like a cheap doll.\n\nDislocations become a minor nuisance. You'll learn to pop your shoulder back in with a shrug." },
            { id = "implant_bone_lacing_3", label = "T3", desc = "Good reinforcement. Joints stay in place, where they belong.\n\nNo more accidental stretch goals. Arms and legs remain attached and oriented correctly. Revolutionary." },
            { id = "implant_bone_lacing_4", label = "T4", desc = "Strong titanium lacing. Pelvis reinforced for... activities.\n\nYou're welcome. You can now take a sledgehammer to the hip and ask for another. Breakdancing on concrete is now viable." },
            { id = "implant_bone_lacing_5", label = "T5", desc = "Full skeleton replacement. Literal titanium replica.\n\nYour bones are now indestructible. The meat around them? Still squishy. But your skeleton will survive the apocalypse." },
        }},
        { name = "Kinetic Stabilizer", desc = "WIP", tiers = {
            { id = "implant_kinetic_1", label = "T1", desc = "WIP. Supposed to stabilize you on uneven ground.\n\nI literally have no idea how to make it work. Right now it just vibrates your feet. Possibly a massage function." },
            { id = "implant_kinetic_2", label = "T2", desc = "WIP. Tried velocity magic, still trips over a pebble.\n\nYou'll still faceplant on a 2-degree slope. I'm convinced the engine hates me. And you." },
            { id = "implant_kinetic_3", label = "T3", desc = "WIP. Attempted to reduce 'fake-on-impact' falls. Failed.\n\nThe code is a labyrinth of spaghetti. Every fix breaks something else. I'm this close to making it just play a cartoon slip sound." },
            { id = "implant_kinetic_4", label = "T4", desc = "WIP. My brain is too smooth for this.\n\nI don't think I'll ever finish it. It's too hard for my wawawawwa brain. Maybe I'll just make it a meme implant that makes you scream when you trip." },
            { id = "implant_kinetic_5", label = "T5", desc = "WIP. This sucks. The implant, the development, life.\n\nIt still doesn't work. At this point I'd rather replace your legs with wheels. Just... don't install this." },
        }},
        { name = "Synth Lungs", desc = "Enhanced stamina system.", tiers = {
            { id = "implant_synth_lungs_scrap",   label = "Scrap",   desc = "Rusty synth lungs from a totaled bike. Weak stamina boost, random choking.\n\nYou'll gasp for air at the worst moments. Your lungs might play a funny squeaky noise during a stealth mission. Not so stealthy." },
            { id = "implant_synth_lungs_diy",     label = "DIY",     desc = "Homemade bellows. Every 10-30 seconds you get a random burst of stamina, or a coughing fit.\n\nLike playing stamina roulette. Will you sprint like a cheetah or hack up a lung? The suspense is thrilling." },
            { id = "implant_synth_lungs_blackmarket", label = "Black Market", desc = "Addictive synth lungs. Amazing stamina, but withdrawal is a nightmare.\n\nYou'll run forever, then miss a dose and feel like you're breathing through a straw. Better keep a spare inhaler." },
            { id = "implant_synth_lungs_1", label = "T1", desc = "Basic lung upgrade. +20% stamina regen.\n\nRun slightly farther before collapsing. You'll still be winded after climbing stairs, but now you can climb slightly more stairs." },
            { id = "implant_synth_lungs_2", label = "T2", desc = "Better breathing. Cardio is still the worst.\n\nYou have more stamina, but the sheer boredom of running is unchanged. At least you can outrun your responsibilities." },
            { id = "implant_synth_lungs_3", label = "T3", desc = "Good stamina capacity. Mildly athletic.\n\nYour job application for 'North African Sand Soldier' might get a second look. Don't celebrate yet. Enough to be a corpo merc in a B-tier conflict" },
            { id = "implant_synth_lungs_4", label = "T4", desc = "High-capacity synth lungs. Double the stamina.\n\nMarathon runners hate you. You can run for days and only stop because you're psychologically bored, not physically tired." },
            { id = "implant_synth_lungs_5", label = "T5", desc = "Max stamina regen and capacity.\n\n The cops won't catch you now. Unless they have aerial drones, helicopters, or roadblocks. But on foot? You're a ghost, a myth, a very sweaty legend." }
        }},
    }},
}

local CHROMA_VALUES = (ZC_IMPLANTS and ZC_IMPLANTS.CHROMA_VALUES) or {}

-- Auto-append chroma cost to descriptions
for _, sec in ipairs(SLOTS) do
    for _, imp in ipairs(sec.implants) do
        for _, tier in ipairs(imp.tiers) do
            local cost = CHROMA_VALUES[tier.id]
            if cost then
                tier.desc = tier.desc .. "\n[+" .. cost .. " CHROMA]"
            end
        end
    end
end

-- Matrix background
local matrixX, matrixY = 80, 42
local matrixText  = {}
local matrixAlpha = {}
for x = 1, matrixX do
    matrixText[x]  = {}
    matrixAlpha[x] = {}
    for y = 1, matrixY do
        matrixText[x][y]  = math.random(0, 1) == 1 and "1" or "0"
        matrixAlpha[x][y] = math.Rand(0.02, 0.08)
    end
end

local function drawMatrix(w, h)
    surface.SetFont("NL_OSMatrix")
    local cellW = w / matrixX
    local cellH = h / matrixY
    for x = 1, matrixX do
        for y = 1, matrixY do
            if math.random(1, 600) == 1 then
                matrixText[x][y] = matrixText[x][y] == "0" and "1" or "0"
            end
            draw.SimpleText(matrixText[x][y], "NL_OSMatrix",
                cellW * (x-1), cellH * (y-1),
                Color(col_matrix.r, col_matrix.g, col_matrix.b, matrixAlpha[x][y] * 255))
        end
    end
end

local function getTierValue(ply, tier)
    -- Все импланты теперь netvar
    local val = ply:GetNetVar(tier.id)
    return val == true
end

-- Returns which tier id is active for this implant group, or nil
local function getActiveTier(ply, implant)
    for _, tier in ipairs(implant.tiers) do
        if getTierValue(ply, tier) then return tier.id end
    end
    return nil
end

local function fadeAndClose(frame)
    frame:SetMouseInputEnabled(false)
    frame:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(false)
    frame:AlphaTo(0, 0.5, 0, function()
        if IsValid(frame) then frame:Remove() end
    end)
end

local function isImplantInInventory(ply, id)
    local inv = ply.Inventory or {}
    for _, item in ipairs(inv) do
        if item.type == "implant" and item.id == id then return true end
    end
    return false
end

local function openImplantMenu(target)
    local ply         = LocalPlayer()
    local isRipperdoc = ply:GetNWBool("zc_ripperdoc", false)
    local showApplyFooter = isRipperdoc or (IsValid(target) and target == ply)

    if IsValid(hg.implantmenu) then
        hg.implantmenu:AlphaTo(0, 0.2, 0, function()
            if IsValid(hg.implantmenu) then hg.implantmenu:Remove() end
        end)
    end

    local frame = vgui.Create("EditablePanel")
    local pending = {}
    frame:SetSize(sw, sh)
    frame:SetPos(0, 0)
    frame:MakePopup()
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.3, 0)
    surface.PlaySound("menu_open.wav")
    timer.Create("menu_loop_sfx", 10, 0, function()
    if not IsValid(frame) then 
        timer.Remove("menu_loop_sfx")
        return 
    end
    surface.PlaySound("loop.mp3")
end)
    hg.implantmenu = frame

    if true then
    local themes = {"red", "cold", "venom", "default"}
    local themeIndex = 1

    local saved = file.Read("zcity_implants/theme.txt", "DATA")
    if saved then
        for i, t in ipairs(themes) do
            if t == saved then themeIndex = i break end
        end
    end

    local themeBtn = vgui.Create("DButton", frame)
    themeBtn:SetSize(ScreenScale(30), ScreenScale(12))
    themeBtn:SetPos(ScreenScale(10), sh - ScreenScale(25))
    themeBtn:SetText("")

    themeBtn.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(col_panel.r, col_panel.g, col_panel.b, 200))
        draw.DrawText(themes[themeIndex], "NL_Menu_Tiny", w*0.5, h*0.5-1, cyan, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    themeBtn.DoClick = function()
        themeIndex = themeIndex + 1
        if themeIndex > #themes then themeIndex = 1 end
        surface.PlaySound("buttons/button15.wav")
        local theme = themes[themeIndex]

        file.Write("zcity_implants/theme.txt", theme)
        RunConsoleCommand("implant_theme", theme)
    end
end

    local pending      = {}  -- implant_id -> true/false
    local expanded     = {}  -- implant name -> bool
    local rowPanels    = {}  -- list of {header, tiers={}} for rebuilding

    local function GetPreviewChroma()
    local total = 0

    for _, sec in ipairs(SLOTS) do
        for _, imp in ipairs(sec.implants) do
            for _, tier in ipairs(imp.tiers) do
                local active = getTierValue(target, tier)
                local pendingVal = pending[tier.id]

                local final = pendingVal
                if final == nil then final = active end

                if final then
                    total = total + (CHROMA_VALUES[tier.id] or 0)
                end
            end
        end
    end

    return total
end

    local hoveredImplant = nil
    local hoveredTier = nil

    local CW = sw
    local CH = sh
    local CX = 0
    local CY = 0

    local currentPending = pending

    frame.Paint = function(self, w, h)
    -- background
    surface.SetDrawColor(col_bg.r, col_bg.g, col_bg.b, 254)
    surface.DrawRect(0, 0, w, h)

    -- matrix (faint)
    cam.Start2D()
        drawMatrix(w, h)
    cam.End2D()

    -- LEFT PANEL
    local panelW = w * 0.45

    surface.SetDrawColor(col_panel.r, col_panel.g, col_panel.b, 240)
    surface.DrawRect(0, 0, panelW, h)

    surface.SetDrawColor(cyan.r, cyan.g, cyan.b, 40)
    surface.DrawRect(panelW, 0, 1, h)

        -- Implant description with animations
    if hoveredImplant then
        descAlpha = math.min(255, (descAlpha or 0) + FrameTime() * 600)
    else
        descAlpha = math.max(0, (descAlpha or 255) - FrameTime() * 600)
    end
    
    if descAlpha and descAlpha > 5 and hoveredImplant then
        local descX = panelW + ScreenScale(15)
        local descY = sh * 0.15
        local descW = w - panelW - ScreenScale(30)
        local descH = ScreenScale(45)
        
        -- Slide from right
        local slideOffset = (1 - descAlpha/255) * ScreenScale(40)
        
        -- Glitch effect - random horizontal offset
        local glitchX = 0
        if math.random(1, 30) == 1 then
            glitchX = math.random(-3, 3)
        end
        
        -- Background with glitch artifacts
        draw.RoundedBox(3, descX + slideOffset + glitchX, descY, descW, descH, 
            Color(col_panel.r, col_panel.g, col_panel.b, 240 * (descAlpha/255)))
        
        -- Glitch lines
        if math.random(1, 20) == 1 then
            surface.SetDrawColor(cyan.r, cyan.g, cyan.b, descAlpha * 0.5)
            surface.DrawRect(descX + slideOffset, descY + math.random(0, descH), descW, 1)
        end
        
        -- Border
        draw.RoundedBox(3, descX + slideOffset + glitchX, descY, descW, 1, 
            Color(cyan.r, cyan.g, cyan.b, descAlpha))
        draw.RoundedBox(3, descX + slideOffset + glitchX, descY + descH - 1, descW, 1, 
            Color(cyan.r, cyan.g, cyan.b, descAlpha * 0.5))
        
        -- Left accent line
        surface.SetDrawColor(cyan.r, cyan.g, cyan.b, descAlpha)
        surface.DrawRect(descX + slideOffset + glitchX, descY, 2, descH)
        
        -- Implant name
        draw.DrawText(hoveredImplant.name, "NL_Menu_Sub",
            descX + ScreenScale(14) + slideOffset + glitchX, descY + ScreenScale(6),
            Color(cyan.r, cyan.g, cyan.b, descAlpha), TEXT_ALIGN_LEFT)
        
        -- Description
        local desc = hoveredImplant.desc or ""
        if hoveredTier then
            desc = hoveredTier.label .. ": " .. (hoveredTier.desc or hoveredImplant.desc)
        end
        
        draw.DrawText(string.sub(desc, 1, 5000), "NL_Menu_Tiny",
            descX + ScreenScale(14) + slideOffset + glitchX, descY + ScreenScale(15),
            Color(cyan.r, cyan.g, cyan.b, descAlpha), TEXT_ALIGN_LEFT)
        
        -- Active tier
        local activeTier = getActiveTier(target, hoveredImplant)
        if activeTier then
            for _, t in ipairs(hoveredImplant.tiers) do
                if t.id == activeTier then
                    -- Gold dot with pulse
                    local pulse = math.sin(CurTime() * 4) * 0.3 + 0.7
                    draw.RoundedBox(99, descX + ScreenScale(12) + slideOffset, 
                        descY + ScreenScale(37), 5, 5, 
                        Color(255, 180, 20, descAlpha * pulse))
                    
                    draw.DrawText("ACTIVE: " .. t.label, "NL_Menu_Tiny",
                        descX + ScreenScale(22) + slideOffset + glitchX, descY + ScreenScale(34),
                        Color(255, 180, 20, descAlpha), TEXT_ALIGN_LEFT)
                    break
                end
            end
        end
        
        -- Bottom scan line
        local scanPos = (CurTime() * 80) % descW
        surface.SetDrawColor(255, 40, 60, descAlpha * 0.4)
        surface.DrawRect(descX + slideOffset + scanPos, descY + descH - 2, 
            math.min(descW * 0.3, descW - scanPos), 1)
        
        -- Random red artifacts
        if math.random(1, 25) == 1 then
            surface.SetDrawColor(255, 20, 40, descAlpha * 0.3)
            local rx = descX + slideOffset + math.random(10, descW - 10)
            surface.DrawRect(rx, descY + math.random(5, descH - 5), math.random(5, 15), 1)
        end
    end

    -- TITLE (center top)
    -- Chroma Load bar (bottom-right, RIGHT-aligned, wider & taller)
if isRipperdoc or target == LocalPlayer() then
    local clLoad = GetPreviewChroma()
    local maxLoad = 200
    local segments = 60
    local maxWidth = ScreenScale(100)  -- 2.5x wider
    local segmentH = ScreenScale(4)    -- slightly taller
    local barX = w - ScreenScale(15)
    local barY = sh - ScreenScale(11)  -- lower
    local filledSegments = math.floor(clLoad / maxLoad * segments)
    
    if not ply._chromaAnimTarget then ply._chromaAnimTarget = filledSegments 
    else ply._chromaAnimTarget = Lerp(FrameTime() * 5, ply._chromaAnimTarget, filledSegments) end
    local animSegments = ply._chromaAnimTarget
    
    local gx = 0
    if math.random(100) <= 5 then gx = math.random(-1, 1) end
    
    for i = 1, segments do
        local progress = (i - 1) / (segments - 1)
        local segW = math.max(maxWidth * (1 - progress)^2, 4)
        local segY = barY - (i * segmentH)
        local segX = barX - segW + gx
        
        if i <= animSegments then
    local col = Color(cyan.r, cyan.g, cyan.b, 180 + progress * 75)
    draw.RoundedBox(6, segX, segY, math.max(segW, 3), segmentH - 1, col)
else
    draw.RoundedBox(6, segX, segY, math.max(segW, 3), segmentH - 1, Color(col_panel.r, col_panel.g, col_panel.b, 150))
end
    end
end
    draw.DrawText("CYBER IMPLANTS", "NL_Menu_Title",
        w * 0.2, 20, cyan, TEXT_ALIGN_CENTER)

    draw.DrawText("PATIENT: " .. (IsValid(target) and target:GetPlayerName() or "?"),
        "NL_Menu_Sub", w * 0.2, 80, cyandim, TEXT_ALIGN_CENTER)

    local roleStr = isRipperdoc and "[ RIPPERDOC — EDIT MODE ]"
        or (target == ply and "[ SELF INSTALL — USE ITEMS FROM INVENTORY ]" or "[ VIEW ONLY ]")
    draw.DrawText(roleStr, "NL_Menu_Tiny",
        w * 0.2, 63,
        isRipperdoc and cyan or (target == ply and col_owned or col_locked),
        TEXT_ALIGN_CENTER)
end

    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(ScreenScale(16), ScreenScale(16))
    closeBtn:SetPos(CX + CW - ScreenScale(20), CY + 8)
    closeBtn:SetText("")
    closeBtn.Paint = function(self, w, h)
        draw.DrawText("✕", "NL_Menu_Sub", w*0.5, h*0.5,
            self:IsHovered() and col_red or cyandim,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        if next(pending) and (isRipperdoc or target == ply) then
            for implant_id, value in pairs(pending) do
                net.Start("zc_implant_set")
                net.WriteEntity(target)
                net.WriteString(implant_id)
                net.WriteBool(value)
                net.SendToServer()
            end
            table.Empty(pending)
            vgui.Create("ZC_ImplantLoading")
        end
        surface.PlaySound("menu_close.wav")
        timer.Remove("menu_loop_sfx")
        fadeAndClose(frame)
    end

    local headerH = ScreenScale(30)
    local footerH = showApplyFooter and ScreenScale(18) or 0
    local panelW = sw * 0.35

    local scrollX = ScreenScale(20)
    local scrollY = ScreenScale(60)
    local scrollW = panelW
    local scrollH = sh - ScreenScale(100)

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(scrollX, scrollY)
    scroll:SetSize(scrollW, scrollH)

    local sbar = scroll:GetVBar()
    sbar:SetWide(3)
    sbar.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,cyanfaint) end
    sbar.btnUp.Paint   = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,cyan) end

    local layout = vgui.Create("DListLayout", scroll)
    layout:SetWide(scrollW - 6)

    for _, sec in ipairs(SLOTS) do
        -- Section header
        local secHeader = vgui.Create("DPanel", layout)
        secHeader:SetTall(ScreenScale(11))
        secHeader.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, col_panel)
            draw.RoundedBox(2, 0, 0, 3, h, cyan)
            draw.DrawText(sec.label, "NL_Menu_Sub", 12, h*0.3,
                cyan, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        for _, imp in ipairs(sec.implants) do
            -- Main implant row (collapsed by default)
            local impRow = vgui.Create("DButton", layout)
            impRow:SetTall(ScreenScale(13))
            impRow:SetText("")
            impRow.OnCursorEntered = function()
               surface.PlaySound("hover.wav")
               hoveredImplant = imp
               hoveredTier = nil
            end
            impRow.OnCursorExited = function()
               hoveredImplant = nil
            end
            expanded[imp.name] = expanded[imp.name] or false

            -- Container for tier rows (hidden when collapsed)
            local tierContainer = vgui.Create("DPanel", layout)
            tierContainer:SetTall(0)
            tierContainer.Paint = function() end

            local tierRows = {}

            local function rebuildTiers()
                -- Clear old tier rows
    for _, r in ipairs(tierRows) do
        if IsValid(r) then r:Remove() end
    end
    tierRows = {}
    tierContainer:Clear()

    if not expanded[imp.name] then
        tierContainer:SetTall(0)
        layout:InvalidateLayout(true)
        return
end

                local tH = ScreenScale(12)
                tierContainer:SetTall(#imp.tiers * tH + 2)

                for i, tier in ipairs(imp.tiers) do
        -- Проверяем, есть ли этот тир в инвентаре (только для не-рипперов)
        local inInventory = false
        if not isRipperdoc then
            local inv = ply.Inventory or {}
            for _, invItem in ipairs(inv) do
                if invItem.type == "implant" and invItem.id == tier.id then
                    inInventory = true
                    break
                end
            end
        end

        local installedBase = getTierValue(target, tier)
        local canInstall = isRipperdoc or inInventory or installedBase
        local isInstalled = installedBase or pending[tier.id]

        local tr = vgui.Create("DButton", tierContainer)
        tr:SetPos(ScreenScale(12), (i-1) * tH + 1)
        tr:SetSize(tierContainer:GetWide() - ScreenScale(12), tH)
        tr:SetText("")
                    tierRows[i] = tr

        tr.Paint = function(self, w, h)
                        -- крутая штука подсвечивает активный имплант 
            local pendingVal = pending[tier.id]
                        local liveVal
                        if pendingVal ~= nil then
                            liveVal = pendingVal
                        else
                            liveVal = getTierValue(target, tier)
                        end

                        local hov = self:IsHovered() and canInstall and (isRipperdoc or target == ply or liveVal)
                        local bg  = liveVal and col_active or (hov and col_hover or Color(0,0,0,0))
            draw.RoundedBox(2, 0, 0, w, h, bg)

                        if inInventory and not liveVal and not isRipperdoc then
                            draw.RoundedBox(2, 0, 1, 3, h - 2, Color(col_owned.r, col_owned.g, col_owned.b, 220))
                        end

                        local dotCol = liveVal and cyan or (inInventory and not isRipperdoc and col_owned or col_locked)
            draw.RoundedBox(99, 4, h*0.5-3, 6, 6, dotCol)
                        local lblCol = liveVal and cyan or (inInventory and not isRipperdoc and col_owned or col_locked)
            draw.DrawText(tier.label, "NL_Menu_Sub", 16, h*0.25,
                            lblCol,
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.DrawText(tier.desc, "NL_Menu_Tiny", w-4, h*0.35,
                            liveVal and cyandim or (inInventory and not isRipperdoc and Color(col_owned.r * 0.55, col_owned.g * 0.65, col_owned.b * 0.55) or col_locked),
                TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            local cl = CHROMA_VALUES[tier.id] or 0
            if cl > 0 then
                local clColor = cl<=15 and Color(50,255,50,200) or cl<=25 and Color(255,200,50,200) or Color(255,50,50,200)
                draw.DrawText("+"..cl.." CHROMA", "NL_Menu_Tiny", w-4, h*0.5+ScreenScale(8), clColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
            if inInventory and not liveVal and not isRipperdoc then
                draw.DrawText("(in inventory)", "NL_Menu_Tiny", w - 507, h*0.9 - ScreenScale(7),
                    col_owned, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            surface.SetDrawColor(col_border)
            surface.DrawLine(0, h-1, w, h-1)
        end

        tr.OnCursorEntered = function()
                hoveredImplant = imp
                hoveredTier = tier
                surface.PlaySound("hover.wav")
        end
        tr.OnCursorExited = function()
            hoveredImplant = nil
            hoveredTier = nil
        end

                    tr:SetCursor((isRipperdoc or canInstall) and (target == ply or isRipperdoc) and "hand" or "no")
        tr.DoClick = function()
            if target ~= ply and not isRipperdoc then return end
            surface.PlaySound("select.wav")
            local pendingVal = pending[tier.id]
                            local cur
                            if pendingVal ~= nil then
                                cur = pendingVal
                            else
                                cur = getTierValue(target, tier)
                            end

            if not cur then
                if not isRipperdoc and not inInventory then
                    surface.PlaySound("buttons/button10.wav")
                    return
                end
                                -- Enabling this tier: disable all other tiers of this implant
                for _, otherTier in ipairs(imp.tiers) do
                    pending[otherTier.id] = false
                end
                pending[tier.id] = true
            else
                if not isRipperdoc and target ~= ply then return end
                                -- Toggling off (self or ripper on patient)
                pending[tier.id] = false
            end
        end
    end

    layout:InvalidateLayout(true)
end

            impRow.Paint = function(self, w, h)
                local activeTier = getActiveTier(target, imp)
                -- also check pending
                local pendingActive = nil
                for _, tier in ipairs(imp.tiers) do
                    if pending[tier.id] == true then
                        pendingActive = tier
                        break
                    end
                end

                local isOn = pendingActive ~= nil or activeTier ~= nil
                local hov  = self:IsHovered()
                local isExp = expanded[imp.name]

                local bg = isOn and col_active or (hov and col_hover or Color(0,0,0,0))
                draw.RoundedBox(2, 0, 0, w, h, bg)

                -- Arrow indicator
                draw.DrawText(isExp and "▼" or "▶", "NL_Menu_Tiny", 6, h*0.5,
                    isOn and cyan or col_locked, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Status dot
if isOn then
    local pulse = math.sin(CurTime() * 4) * 0.4 + 0.6
    draw.RoundedBox(99, 14 - pulse*2, h*0.5-5 - pulse*2, 10 + pulse*4, 10 + pulse*4, Color(cyan.r, cyan.g, cyan.b, 30 * pulse))
end
draw.RoundedBox(99, 16, h*0.5-3, 6, 6, isOn and cyan or col_locked)

                -- Name
                draw.DrawText(imp.name, "NL_Menu_Sub", 28, h*0.5,
                    isOn and cyan or col_locked,
                    TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Active tier label or description
                local rightTxt
                if pendingActive then
                    rightTxt = "* " .. pendingActive.label
                elseif activeTier then
                    for _, t in ipairs(imp.tiers) do
                        if t.id == activeTier then rightTxt = t.label break end
                    end
                else
                    rightTxt = imp.desc
                end
                draw.DrawText(rightTxt or "", "NL_Menu_Tiny", w-6, h*0.5,
                    isOn and cyandim or col_locked,
                    TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                surface.SetDrawColor(col_border)
                surface.DrawLine(0, h-1, w, h-1)
            end

            impRow.DoClick = function()
                expanded[imp.name] = not expanded[imp.name]
                rebuildTiers()
            end

            rebuildTiers()
        end
    end
    
    -- Loadout system
if isRipperdoc then
    local loadoutY = sh - ScreenScale(25)
    local rightX = sw * 0.48

    -- Load existing loadouts
    local loadoutFiles = file.Find("zcity_implants/loadouts/*.txt", "DATA")
local loadoutList = {}

for _, fname in ipairs(loadoutFiles) do
    local name = string.StripExtension(fname)
    loadoutList[#loadoutList + 1] = name
end
    -- Derma Menu for loadout selection
    local loadoutMenu = nil

    -- Loadout selection button (shows list)
    local selectBtn = vgui.Create("DButton", frame)
    selectBtn:SetSize(ScreenScale(130), ScreenScale(14))
    selectBtn:SetPos(rightX, loadoutY)
    selectBtn:SetText("")
    selectBtn:SetMouseInputEnabled(true)
    selectBtn:SetZPos(100)
    local selectedLoadout = ""
    selectBtn.Paint = function(self, w, h)
        local hov = self:IsHovered()
        draw.RoundedBox(2, 0, 0, w, h, hov and Color(col_panel.r, col_panel.g, col_panel.b, 220) or Color(col_panel.r, col_panel.g, col_panel.b, 60))
        draw.RoundedBox(2, 0, 0, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, h-1, w, 1, Color(cyan.r, cyan.g, cyan.b, 60))
        draw.RoundedBox(2, 0, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, w-1, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 60))
        local txt = selectedLoadout ~= "" and selectedLoadout or "Select loadout..."
        draw.DrawText(txt, "NL_Menu_Tiny", ScreenScale(5), h*0.5 - ScreenScale(2),
            selectedLoadout ~= "" and Color(cyandim.r, cyandim.g, cyandim.b, 200) or Color(col_locked.r, col_locked.g, col_locked.b, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    selectBtn.DoClick = function()
        if loadoutMenu then
            loadoutMenu:Remove()
            loadoutMenu = nil
            return
        end
        
        loadoutMenu = DermaMenu(frame)
        for _, name in ipairs(loadoutList) do
            loadoutMenu:AddOption(name, function()
                selectedLoadout = name
                loadoutMenu:Remove()
                loadoutMenu = nil
            end)
        end
        if #loadoutList == 0 then
            loadoutMenu:AddOption("No loadouts saved", function() end)
        end
        local mx, my = selectBtn:LocalToScreen(0, 0)

local menuW = 200
local menuH = #loadoutList * 20 + 20

local x = mx + selectBtn:GetWide()
local y = my

if y + menuH > ScrH() then
    y = ScrH() - menuH - 10
end

if x + menuW > ScrW() then
    x = mx - menuW
end

loadoutMenu:SetPos(x, y)
loadoutMenu:MakePopup()
loadoutMenu:MoveToFront()
loadoutMenu:SetZPos(99999)
    end

    -- Loadout name input for save
    local loadoutName = vgui.Create("DTextEntry", frame)
    loadoutName:SetSize(ScreenScale(130), ScreenScale(14))
    loadoutName:SetPos(rightX, loadoutY - ScreenScale(18))
    loadoutName:SetPlaceholderText("Name for save...")
    loadoutName:SetFont("NL_Menu_Tiny")
    loadoutName:SetTextInset(4, 3)
    loadoutName.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(col_panel.r, col_panel.g, col_panel.b, 220))
        draw.RoundedBox(2, 0, 0, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, h-1, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, w-1, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        self:DrawTextEntryText(Color(cyan.r, cyan.g, cyan.b, 200), Color(cyan.r, cyan.g, cyan.b, 255), Color(cyan.r, cyan.g, cyan.b, 200))
    end

    -- Save button
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetSize(ScreenScale(50), ScreenScale(14))
    saveBtn:SetPos(rightX + ScreenScale(135), loadoutY - ScreenScale(18))
    saveBtn:SetText("")
    saveBtn:SetMouseInputEnabled(true)
    saveBtn:SetZPos(100)
    saveBtn.Paint = function(self, w, h)
        local hov = self:IsHovered()
        draw.RoundedBox(2, 0, 0, w, h, hov and Color(cyan.r, cyan.g, cyan.b, 60) or Color(col_panel.r, col_panel.g, col_panel.b, 220))
        draw.RoundedBox(2, 0, 0, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, h-1, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, w-1, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.DrawText("SAVE", "NL_Menu_Tiny", w*0.5, h*0.5 - ScreenScale(2),
            Color(cyandim.r, cyandim.g, cyandim.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    saveBtn.DoClick = function()
    local name = loadoutName:GetValue():Trim()
    if name == "" then return end

    local saveData = {}

    for _, sec in ipairs(SLOTS) do
        for _, imp in ipairs(sec.implants) do
            for _, tier in ipairs(imp.tiers) do
                if getTierValue(target, tier) then
                    saveData[tier.id] = true
                end
            end
        end
    end

    for id, val in pairs(pending) do
        saveData[id] = val
    end

    file.CreateDir("zcity_implants/loadouts")
    file.Write("zcity_implants/loadouts/" .. name .. ".txt", util.TableToJSON(saveData))

    surface.PlaySound("select.wav")
    loadoutName:SetValue("")
    selectedLoadout = name
    print("[LOADOUT SAVE] name =", name)
print("[LOADOUT SAVE] data =", util.TableToJSON(saveData))
end

    -- Load button
    local loadBtn = vgui.Create("DButton", frame)
    loadBtn:SetSize(ScreenScale(50), ScreenScale(14))
    loadBtn:SetPos(rightX + ScreenScale(135), loadoutY)
    loadBtn:SetText("")
    loadBtn:SetMouseInputEnabled(true)
    loadBtn:SetZPos(100)
    loadBtn.Paint = function(self, w, h)
        local hov = self:IsHovered()
        draw.RoundedBox(2, 0, 0, w, h, hov and Color(cyan.r, cyan.g, cyan.b, 60) or Color(col_panel.r, col_panel.g, col_panel.b, 220))
        draw.RoundedBox(2, 0, 0, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, h-1, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, w-1, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.DrawText("LOAD", "NL_Menu_Tiny", w*0.5, h*0.5 - ScreenScale(2),
            Color(cyandim.r, cyandim.g, cyandim.b, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    loadBtn.DoClick = function()
    if selectedLoadout == "" then return end
    surface.PlaySound("select.wav")

    local json = file.Read("zcity_implants/loadouts/" .. selectedLoadout .. ".txt")
    if not json then return end

    local loadData = util.JSONToTable(json)
    if not loadData then return end

    table.Empty(pending)

    for _, sec in ipairs(SLOTS) do
        for _, imp in ipairs(sec.implants) do
            for _, tier in ipairs(imp.tiers) do
                pending[tier.id] = false
            end
        end
    end

    for implant_id, value in pairs(loadData) do
        pending[implant_id] = value
    end

    local files = file.Find("zcity_implants/loadouts/*.txt", "DATA")
print("[LOADOUT LOAD] files:", #files)
PrintTable(files)

end

    -- Delete button
    local deleteBtn = vgui.Create("DButton", frame)
    deleteBtn:SetSize(ScreenScale(20), ScreenScale(14))
    deleteBtn:SetPos(rightX + ScreenScale(190), loadoutY)
    deleteBtn:SetText("")
    deleteBtn:SetMouseInputEnabled(true)
    deleteBtn:SetZPos(100)
    deleteBtn.Paint = function(self, w, h)
        local hov = self:IsHovered()
        draw.RoundedBox(2, 0, 0, w, h, hov and Color(cyan.r, cyan.g, cyan.b, 60) or Color(col_panel.r, col_panel.g, col_panel.b, 220))
        draw.RoundedBox(2, 0, 0, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, h-1, w, 1, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, 0, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.RoundedBox(2, w-1, 0, 1, h, Color(cyan.r, cyan.g, cyan.b, 150))
        draw.DrawText("X", "NL_Menu_Tiny", w*0.5, h*0.5 - ScreenScale(2),
            hov and Color(cyandim.r, cyandim.g, cyandim.b, 255) or Color(col_locked.r, col_locked.g, col_locked.b, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    deleteBtn.DoClick = function()
        if selectedLoadout == "" then return end
        file.Delete("zcity_implants/loadouts/" .. selectedLoadout .. ".txt")
        surface.PlaySound("menu_close.wav")
        selectedLoadout = ""
        for i, name in ipairs(loadoutList) do
            if name == selectedLoadout then
                table.remove(loadoutList, i)
                break
            end
        end
    end
end

        -- Apply button (ripperdocs or self-install from inventory)
    if showApplyFooter then
    local applyBtn = vgui.Create("DButton", frame)
    applyBtn:SetSize(CW - ScreenScale(500), ScreenScale(14))
    applyBtn:SetPos(CX + ScreenScale(60), CY + CH - ScreenScale(25))
    applyBtn:SetText("")
    applyBtn.Paint = function(self, w, h)
        local hasChanges = next(pending) ~= nil
        local col = hasChanges and (isRipperdoc and cyan or col_owned) or col_locked
        draw.RoundedBox(30, 0, 0, w, h, Color(col_panel.r, col_panel.g, col_panel.b, 220))
        local count = 0
        for _ in pairs(pending) do count = count + 1 end
        local txt
        if isRipperdoc then
            txt = hasChanges
                and ("APPLY " .. count .. " CHANGE" .. (count > 1 and "S" or ""))
                or "NO PENDING CHANGES — CLICK AN IMPLANT TO EXPAND"
        else
            txt = hasChanges
                and ("INSTALL / REMOVE — APPLY " .. count .. " CHANGE" .. (count > 1 and "S" or ""))
                or "SELECT AN IMPLANT YOU OWN IN YOUR INVENTORY, THEN APPLY"
        end
        draw.DrawText(txt, "NL_Menu_Sub", w*0.5, h*0.5 - ScreenScale(2),
            col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    applyBtn.DoClick = function()
        surface.PlaySound("install.wav")
            -- Repair cracked Neurolink optics
            if hg.neurocrack then
               hg.neurocrack = {}
            end
        if not next(pending) then return end
            for implant_id, value in pairs(pending) do
                net.Start("zc_implant_set")
                net.WriteEntity(target)
                net.WriteString(implant_id)
                net.WriteBool(value)
                net.SendToServer()
            end

        table.Empty(pending)
        vgui.Create("ZC_ImplantLoading")
        fadeAndClose(frame)
        surface.PlaySound("menu_close.wav")
        end
    end
end

-- Radial menu
hook.Add("radialOptions", "zc_implants_radial", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply.organism or ply.organism.otrub then return end

    hg.radialOptions[#hg.radialOptions + 1] = {
        function() openImplantMenu(ply) end,
        "Cyber\nImplants"
    }

    local carryent = ply:GetNetVar("carryent")
    if IsValid(carryent) and carryent:IsRagdoll() then
        local owner = hg.RagdollOwner(carryent)
        if IsValid(owner) and owner:IsPlayer() and owner ~= ply then
            hg.radialOptions[#hg.radialOptions + 1] = {
                function() openHarvestMenu(owner) end,
                "Harvest\nthe Body"
            }
        end
    end
end)

hook.Add("radialOptions", "mp3_player", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_mp3") then return end
    if ply.organism and ply.organism.otrub then return end
    hg.radialOptions[#hg.radialOptions + 1] = {function() RunConsoleCommand("implant_mp3_menu") end, "MP3\nRadio"}
end)

net.Receive("zc_implant_open_target", function()
    local target = net.ReadEntity()
    if not IsValid(target) then return end
    openImplantMenu(target)
end)

net.Receive("zc_nl_boot", function()
    vgui.Create("ZC_ImplantLoading")
end)

function CalculateChromaLoad(ply)
    if ZC_IMPLANTS and ZC_IMPLANTS.CalculateChromaLoad then
        return ZC_IMPLANTS.CalculateChromaLoad(ply, pending)
    end
    return 0
end

concommand.Add("implant_theme", function(ply, cmd, args)
    local theme = args[1]
    if not theme then return end

    file.Write("zcity_implants/theme.txt", theme)

    if theme == "red" then
        cyan       = Color(255, 40, 60, 255)
        cyandim    = Color(255, 100, 110, 200)
        cyanfaint  = Color(100, 15, 25, 255)
        col_bg     = Color(8, 2, 4, 250)
        col_panel  = Color(20, 5, 8, 255)
        col_border = Color(255, 40, 60, 60)
        col_hover  = Color(255, 40, 60, 30)
        col_active = Color(255, 20, 40, 60)
        col_locked = Color(80, 60, 65, 180)
        col_matrix = Color(255, 40, 60, 255)

    elseif theme == "cold" then
        cyan       = Color(200, 210, 230, 255)
        cyandim    = Color(150, 160, 180, 200)
        cyanfaint  = Color(20, 20, 30, 255)
        col_bg     = Color(8, 8, 14, 250)
        col_panel  = Color(15, 15, 22, 255)
        col_border = Color(60, 65, 85, 50)
        col_hover  = Color(180, 190, 210, 20)
        col_active = Color(100, 120, 160, 40)
        col_locked = Color(35, 38, 55, 180)
        col_matrix = Color(100, 120, 160, 255)

    elseif theme == "venom" then
        cyan       = Color(100, 255, 50, 255)
        cyandim    = Color(150, 255, 120, 200)
        cyanfaint  = Color(20, 60, 15, 255)
        col_bg     = Color(2, 8, 2, 250)
        col_panel  = Color(5, 20, 5, 255)
        col_border = Color(100, 255, 50, 60)
        col_hover  = Color(100, 255, 50, 25)
        col_active = Color(50, 255, 20, 50)
        col_locked = Color(60, 80, 60, 180)
        col_matrix = Color(50, 255, 100, 255)

    elseif theme == "default" then
        cyan       = Color(255, 255, 255, 255)
        cyandim    = Color(180, 180, 180, 200)
        cyanfaint  = Color(30, 30, 30, 255)
        col_bg     = Color(2, 2, 2, 250)
        col_panel  = Color(12, 12, 12, 255)
        col_border = Color(100, 100, 100, 50)
        col_hover  = Color(200, 200, 200, 20)
        col_active = Color(150, 150, 150, 40)
        col_locked = Color(50, 50, 50, 180)
        col_matrix = Color(0, 255, 100, 255)
    end
end)

local harvesting = false
local harvestTimer = 0
local harvestTarget = nil
local harvestOrganID = nil
local harvestImplantID = nil
local harvestFrame = nil
local harvestAlpha = 0

hook.Add("Think", "Harvesting_DarkScreen", function()
    if harvesting then
        -- Fade in
        harvestAlpha = math.min(255, harvestAlpha + FrameTime() * 300)

            -- Start meat sounds
    if not harvestSoundPlaying then
        harvestSoundPlaying = true
        surface.PlaySound("npc/barnacle/barnacle_gulp1.wav")
        timer.Create("HarvestMeatLoop", 1.2, 0, function()
            if not harvesting then timer.Remove("HarvestMeatLoop") return end
            local squish = {"physics/flesh/flesh_impact_bullet1.wav", "physics/flesh/flesh_impact_bullet2.wav", "npc/barnacle/barnacle_gulp2.wav"}
            surface.PlaySound(squish[math.random(#squish)])
        end)
    end
        
        if not IsValid(harvestFrame) then
            harvestFrame = vgui.Create("EditablePanel")
            harvestFrame:SetSize(sw, sh)
            harvestFrame:SetPos(0, 0)
            harvestFrame:MakePopup()
            harvestFrame.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, harvestAlpha))
                local alpha = math.sin(CurTime() * 3) * 50 + 200
                draw.DrawText("HARVESTING", "NL_Menu_Harvest_Title", w*0.5, h*0.45, Color(180, 20, 30, alpha), TEXT_ALIGN_CENTER)
                local timeLeft = math.max(harvestTimer - CurTime(), 0)
                draw.DrawText(math.Round(timeLeft) .. "s", "NL_Menu_Harvest_Sub", w*0.5, h*0.55, Color(200, 80, 80, alpha), TEXT_ALIGN_CENTER)
            end
        end
        
        if CurTime() >= harvestTimer then
            harvesting = false
            harvestSoundPlaying = false
            timer.Remove("HarvestMeatLoop")
            surface.PlaySound("npc/barnacle/barnacle_gulp1.wav")
            -- Fade out
            harvestAlpha = math.max(0, harvestAlpha - FrameTime() * 500)
            if harvestAlpha <= 0 then
                if IsValid(harvestFrame) then harvestFrame:Remove() harvestFrame = nil end
                gui.EnableScreenClicker(false)
            end
            return
        end
    else
        if IsValid(harvestFrame) and harvestAlpha > 0 then
            harvestAlpha = math.max(0, harvestAlpha - FrameTime() * 500)
            harvestFrame.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, harvestAlpha))
            end
            if harvestAlpha <= 0 then
                harvestFrame:Remove() harvestFrame = nil
                gui.EnableScreenClicker(false)
                
                surface.PlaySound("physics/flesh/flesh_impact_bullet1.wav")
                if harvestOrganID then
                    net.Start("HarvestOrgan")
                    net.WriteEntity(harvestTarget)
                    net.WriteString(harvestOrganID)
                    net.SendToServer()
                    harvestTarget._harvestedOrgans = harvestTarget._harvestedOrgans or {}
                    harvestTarget._harvestedOrgans[harvestOrganID] = true
                elseif harvestImplantID then
                    net.Start("HarvestImplant")
                    net.WriteEntity(harvestTarget)
                    net.WriteString(harvestImplantID)
                    net.SendToServer()
                end
                
                harvestOrganID = nil
                harvestImplantID = nil
                harvestTarget = nil
            end
        end
    end
end)

function openHarvestMenu(target)
    if IsValid(_harvestFrame) then _harvestFrame:Remove() end
    local ply = LocalPlayer()
    if not IsValid(target) or not target:IsPlayer() then return end
    if not target.organism then return end
    target._harvestedOrgans = target._harvestedOrgans or {}
    
    local frame = vgui.Create("EditablePanel")
    _harvestFrame = frame
    frame:SetSize(sw * 0.3, sh * 0.7)
    frame:SetPos(sw * 0.35, sh * 0.15)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(12, 2, 3, 250))
        surface.SetDrawColor(120, 8, 15, 150)
        for i = 1, 15 do surface.DrawRect(math.random(5,w-5), math.random(5,h-5), math.random(2,6), math.random(10,40)) end
        draw.DrawText("HARVEST BODY", "NL_Menu_Harvest_Title", w*.5, ScreenScale(4), Color(180,20,30,255), TEXT_ALIGN_CENTER)
        draw.DrawText(target:Nick(), "NL_Menu_Harvest_Sub", w*.5, ScreenScale(24), Color(200,80,80,200), TEXT_ALIGN_CENTER)
    end
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:SetPos(ScreenScale(10), ScreenScale(50))
    scroll:SetSize(frame:GetWide()-ScreenScale(20), frame:GetTall()-ScreenScale(110))
    local layout = vgui.Create("DListLayout", scroll)
    layout:SetWide(scroll:GetWide()-ScreenScale(10))
    
    local orgH = vgui.Create("DPanel", layout)
    orgH:SetTall(ScreenScale(14))
    orgH.Paint = function(self,w,h) draw.DrawText("ORGANS","NL_Menu_Harvest_Sub",ScreenScale(8),h*.10,Color(200,50,50,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER) surface.SetDrawColor(150,25,30,100) surface.DrawRect(0,h-1,w,1) end
    
    local HARV = {"brain","heart","liver","stomach","intestines","jaw","spine1","spine2","spine3","pelvis","skull","lleg","rleg","larm","rarm"}
    local N = {brain="Brain",heart="Heart",liver="Liver",stomach="Stomach",intestines="Intestines",jaw="Jaw",spine1="Spine Upper",spine2="Spine Middle",spine3="Spine Lower",pelvis="Pelvis",skull="Skull",lleg="Left Leg",rleg="Right Leg",larm="Left Arm",rarm="Right Arm"}
    
    for _, id in ipairs(HARV) do
        if not (target._harvestedOrgans and target._harvestedOrgans[id]) then
            local r = vgui.Create("DButton", layout)
            r:SetTall(ScreenScale(15)); r:SetText("")
            r.Paint = function(self,w,h)
                if self:IsHovered() then draw.RoundedBox(2,0,0,w,h,Color(100,15,20,100)) surface.SetDrawColor(200,30,40,150) surface.DrawRect(0,0,3,h) end
                draw.DrawText(N[id],"NL_Menu_Harvest_Sub",ScreenScale(10),h*.05,Color(200,120,120,255),TEXT_ALIGN_LEFT)
                draw.DrawText("EXTRACT","NL_Menu_Tiny",w-ScreenScale(6),h*.35,Color(255,80,80,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end
            r.DoClick = function()
                harvestTarget=target; harvestOrganID=id; harvestTimer=CurTime()+5; harvesting=true
                frame:Remove(); _harvestFrame=nil; gui.EnableScreenClicker(false)
            end
            layout:Add(r)
        end
    end
    
    local impH = vgui.Create("DPanel", layout)
    impH:SetTall(ScreenScale(14))
    impH.Paint = function(self,w,h) draw.DrawText("IMPLANTS","NL_Menu_Harvest_Sub",ScreenScale(8),h*.10,Color(200,200,50,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER) surface.SetDrawColor(150,150,25,100) surface.DrawRect(0,h-1,w,1) end
    
    for _, sec in ipairs(SLOTS) do for _, imp in ipairs(sec.implants) do for _, tier in ipairs(imp.tiers) do
        if target:GetNetVar(tier.id) then
            local r = vgui.Create("DButton", layout)
            r:SetTall(ScreenScale(15)); r:SetText("")
            r.Paint = function(self,w,h)
                if self:IsHovered() then draw.RoundedBox(2,0,0,w,h,Color(100,80,15,100)) surface.SetDrawColor(200,200,40,150) surface.DrawRect(0,0,3,h) end
                draw.DrawText(imp.name.." ("..tier.label..")","NL_Menu_Harvest_Sub",ScreenScale(10),h*.05,Color(200,200,100,255),TEXT_ALIGN_LEFT)
                draw.DrawText("EXTRACT","NL_Menu_Tiny",w-ScreenScale(6),h*.35,Color(255,200,50,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
            end
            r.DoClick = function()
                harvestTarget=target; harvestImplantID=tier.id; harvestTimer=CurTime()+5; harvesting=true
                frame:Remove(); _harvestFrame=nil; gui.EnableScreenClicker(false)
            end
            layout:Add(r)
        end
    end end end
    
    local cb = vgui.Create("DButton", frame)
    cb:SetSize(ScreenScale(60),ScreenScale(14)); cb:SetPos(frame:GetWide()/2-ScreenScale(30),frame:GetTall()-ScreenScale(40)); cb:SetText("")
    cb.Paint = function(self,w,h) draw.RoundedBox(2,0,0,w,h,Color(80,10,15,200)) draw.DrawText("CLOSE","NL_Menu_Tiny",w*.5,h*.5,Color(200,100,100,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    cb.DoClick = function() frame:Remove(); _harvestFrame=nil; gui.EnableScreenClicker(false) end
    
    gui.EnableScreenClicker(true)
end

print("cl_implant_menu loaded")