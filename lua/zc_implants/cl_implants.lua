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
    local val = ply:GetNetVar(tier.id)
    return val == true
end

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

    local pending      = {}
    local expanded     = {}
    local rowPanels    = {}

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
    surface.SetDrawColor(col_bg.r, col_bg.g, col_bg.b, 254)
    surface.DrawRect(0, 0, w, h)

    cam.Start2D()
        drawMatrix(w, h)
    cam.End2D()

    local panelW = w * 0.45

    surface.SetDrawColor(col_panel.r, col_panel.g, col_panel.b, 240)
    surface.DrawRect(0, 0, panelW, h)

    surface.SetDrawColor(cyan.r, cyan.g, cyan.b, 40)
    surface.DrawRect(panelW, 0, 1, h)

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
        
        local slideOffset = (1 - descAlpha/255) * ScreenScale(40)
        
        local glitchX = 0
        if math.random(1, 30) == 1 then
            glitchX = math.random(-3, 3)
        end
        
        draw.RoundedBox(3, descX + slideOffset + glitchX, descY, descW, descH, 
            Color(col_panel.r, col_panel.g, col_panel.b, 240 * (descAlpha/255)))
        
        if math.random(1, 20) == 1 then
            surface.SetDrawColor(cyan.r, cyan.g, cyan.b, descAlpha * 0.5)
            surface.DrawRect(descX + slideOffset, descY + math.random(0, descH), descW, 1)
        end
        
        draw.RoundedBox(3, descX + slideOffset + glitchX, descY, descW, 1, 
            Color(cyan.r, cyan.g, cyan.b, descAlpha))
        draw.RoundedBox(3, descX + slideOffset + glitchX, descY + descH - 1, descW, 1, 
            Color(cyan.r, cyan.g, cyan.b, descAlpha * 0.5))
        
        surface.SetDrawColor(cyan.r, cyan.g, cyan.b, descAlpha)
        surface.DrawRect(descX + slideOffset + glitchX, descY, 2, descH)
        
        draw.DrawText(hoveredImplant.name, "NL_Menu_Sub",
            descX + ScreenScale(14) + slideOffset + glitchX, descY + ScreenScale(6),
            Color(cyan.r, cyan.g, cyan.b, descAlpha), TEXT_ALIGN_LEFT)
        
        local desc = hoveredImplant.desc or ""
        if hoveredTier then
            desc = hoveredTier.label .. ": " .. (hoveredTier.desc or hoveredImplant.desc)
        end
        
        draw.DrawText(string.sub(desc, 1, 5000), "NL_Menu_Tiny",
            descX + ScreenScale(14) + slideOffset + glitchX, descY + ScreenScale(15),
            Color(cyan.r, cyan.g, cyan.b, descAlpha), TEXT_ALIGN_LEFT)
        
        local activeTier = getActiveTier(target, hoveredImplant)
        if activeTier then
            for _, t in ipairs(hoveredImplant.tiers) do
                if t.id == activeTier then
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
        
        local scanPos = (CurTime() * 80) % descW
        surface.SetDrawColor(255, 40, 60, descAlpha * 0.4)
        surface.DrawRect(descX + slideOffset + scanPos, descY + descH - 2, 
            math.min(descW * 0.3, descW - scanPos), 1)
        
        if math.random(1, 25) == 1 then
            surface.SetDrawColor(255, 20, 40, descAlpha * 0.3)
            local rx = descX + slideOffset + math.random(10, descW - 10)
            surface.DrawRect(rx, descY + math.random(5, descH - 5), math.random(5, 15), 1)
        end
    end

if isRipperdoc or target == LocalPlayer() then
    local clLoad = GetPreviewChroma()
    local maxLoad = 200
    local segments = 60
    local maxWidth = ScreenScale(100)
    local segmentH = ScreenScale(4)
    local barX = w - ScreenScale(15)
    local barY = sh - ScreenScale(11)
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
        local secHeader = vgui.Create("DPanel", layout)
        secHeader:SetTall(ScreenScale(11))
        secHeader.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, col_panel)
            draw.RoundedBox(2, 0, 0, 3, h, cyan)
            draw.DrawText(sec.label, "NL_Menu_Sub", 12, h*0.3,
                cyan, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        for _, imp in ipairs(sec.implants) do
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

            local tierContainer = vgui.Create("DPanel", layout)
            tierContainer:SetTall(0)
            tierContainer.Paint = function() end

            local tierRows = {}

            local function rebuildTiers()
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
                for _, otherTier in ipairs(imp.tiers) do
                    pending[otherTier.id] = false
                end
                pending[tier.id] = true
            else
                if not isRipperdoc and target ~= ply then return end
                pending[tier.id] = false
            end
        end
    end

    layout:InvalidateLayout(true)
end

            impRow.Paint = function(self, w, h)
                local activeTier = getActiveTier(target, imp)
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

                draw.DrawText(isExp and "▼" or "▶", "NL_Menu_Tiny", 6, h*0.5,
                    isOn and cyan or col_locked, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

if isOn then
    local pulse = math.sin(CurTime() * 4) * 0.4 + 0.6
    draw.RoundedBox(99, 14 - pulse*2, h*0.5-5 - pulse*2, 10 + pulse*4, 10 + pulse*4, Color(cyan.r, cyan.g, cyan.b, 30 * pulse))
end
draw.RoundedBox(99, 16, h*0.5-3, 6, 6, isOn and cyan or col_locked)

                draw.DrawText(imp.name, "NL_Menu_Sub", 28, h*0.5,
                    isOn and cyan or col_locked,
                    TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

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
    
if isRipperdoc then
    local loadoutY = sh - ScreenScale(25)
    local rightX = sw * 0.48

    local loadoutFiles = file.Find("zcity_implants/loadouts/*.txt", "DATA")
local loadoutList = {}

for _, fname in ipairs(loadoutFiles) do
    local name = string.StripExtension(fname)
    loadoutList[#loadoutList + 1] = name
end
    local loadoutMenu = nil

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
        harvestAlpha = math.min(255, harvestAlpha + FrameTime() * 300)

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
include("outline.lua")
local mp3LastClick = 0

surface.CreateFont("NLFontDefault", {
    font = "Roboto Light",
    extended = true,
    size = ScreenScale(24),
    weight = 500,
    scanlines = 3,
    antialias = true
})

surface.CreateFont("NLFontDefaultBG", {
    font = "Roboto Light",
    extended = true,
    size = ScreenScale(24.5),
    weight = 500,
    blursize = 2,
    scanlines = 3,
    antialias = true
})

surface.CreateFont("NLFontSmall", {
    font = "Roboto Light",
    extended = true,
    size = ScreenScale(7.5),
    weight = 1500,
    scanlines = 3,
    antialias = true
})

surface.CreateFont("NLFontSmallBG", {
    font = "Roboto Light",
    extended = true,
    size = ScreenScale(7.5),
    weight = 500,
    blursize = 2,
    scanlines = 3,
    antialias = true
})

surface.CreateFont("NL_Scanner", {
    font = "Montserrat",
    size = 18,
    weight = 500,
    antialias = true
})

local CrackMat = Material("effects/shaders/zb_shattered_ps30")

if not hg.neurocrack then
    hg.neurocrack = {}
end

net.Receive("NeurolinkCrack", function()
    local ply = LocalPlayer()
    local intensity = net.ReadFloat()

    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or 
                         ply:GetNetVar("implant_neurolink_military") or 
                         ply:GetNetVar("implant_neurolink_militaryplus") or
                         ply:GetNetVar("implant_neurolink_scrap") or
                         ply:GetNetVar("implant_neurolink_diy") or
                         ply:GetNetVar("implant_neurolink_blackmarket")

    if not hasNeurolink then return end

    hg.neurocrack = {
        x = math.Rand(0.1, 0.9),
        y = math.Rand(0.1, 0.9),
        intensity = (hg.neurocrack.intensity or 0) + intensity,
        lastDamage = CurTime(),
        rnd1 = math.Rand(1, 999),
        rnd2 = math.Rand(1, 999),
        rnd3 = math.Rand(1, 999),
        rnd4 = math.Rand(1, 999),
    }

    if intensity > 0.1 then
        surface.PlaySound("crack.wav")
    end
end)

local color_main  = Color(0, 230, 230, 220)
local color_glow  = Color(0, 180, 180, 80)
local color_shadow = Color(0, 0, 0, 220)
local pos_sight   = Vector(ScrW() * 0.5, ScrH() * 0.5, 0)
local wallet_smooth = 0
local bank_smooth = 0
local wallet_prev = 0
local bank_prev = 0
local wallet_color = Color(0, 255, 0, 220)
local bank_color = Color(0, 255, 0, 220)
local color_money_shadow = Color(0, 0, 0, 220)
local crit_flash = 0
local pulse_flash = 0
local last_heartbeat_time = 0

local function drawBigStat(number, label, pos_x, pos_y)
    local numStr = tostring(number)
    local labStr = tostring(label)

    draw.DrawText(numStr, "NLFontDefault",   pos_x + 2,  pos_y + 2, color_shadow, TEXT_ALIGN_LEFT)
    draw.DrawText(numStr, "NLFontDefault",   pos_x + 3,  pos_y + 1, color_shadow, TEXT_ALIGN_LEFT)
    draw.DrawText(numStr, "NLFontDefaultBG", pos_x + 1,  pos_y + 1, color_glow,   TEXT_ALIGN_LEFT)
    draw.DrawText(numStr, "NLFontDefault",   pos_x,      pos_y,     color_main,   TEXT_ALIGN_LEFT)

    surface.SetFont("NLFontDefault")
    local nw, nh = surface.GetTextSize(numStr)

    local lx = pos_x + nw + 4
    local ly = pos_y + nh - ScreenScale(9)

    draw.DrawText(labStr, "NLFontSmall",   lx + 2, ly + 1, color_shadow, TEXT_ALIGN_LEFT)
    draw.DrawText(labStr, "NLFontSmallBG", lx + 1, ly + 1, color_glow,   TEXT_ALIGN_LEFT)
    draw.DrawText(labStr, "NLFontSmall",   lx,     ly,     color_main,   TEXT_ALIGN_LEFT)
end

local function drawSmallStat(number, label, pos_x, pos_y)
    local numStr = tostring(number)
    local labStr = tostring(label)

    draw.DrawText(numStr, "NLFontSmall",   pos_x + 2, pos_y + 1, color_shadow, TEXT_ALIGN_LEFT)
    draw.DrawText(numStr, "NLFontSmallBG", pos_x + 1, pos_y + 1, color_glow,   TEXT_ALIGN_LEFT)
    draw.DrawText(numStr, "NLFontSmall",   pos_x,     pos_y,     color_main,   TEXT_ALIGN_LEFT)

    surface.SetFont("NLFontSmall")
    local nw, _ = surface.GetTextSize(numStr)

    local lx = pos_x + nw + 4

    draw.DrawText(labStr, "NLFontSmall",   lx + 2, pos_y + 1, color_shadow, TEXT_ALIGN_LEFT)
    draw.DrawText(labStr, "NLFontSmallBG", lx + 1, pos_y + 1, color_glow,   TEXT_ALIGN_LEFT)
    draw.DrawText(labStr, "NLFontSmall",   lx,     pos_y,     color_main,   TEXT_ALIGN_LEFT)
end

hook.Add("Think", "implant_nvg_thermal_toggle", function()
    local ply = LocalPlayer()
    nvg_enabled = nvg_enabled or false
    thermalMode = thermalMode or false
    
    if not ply:Alive() then
        if nvg_enabled then
            nvg_enabled = false
            thermalMode = false
            hook.Remove("RenderScreenspaceEffects", "implant_nvg_effect")
            if IsValid(nvg_light) then nvg_light:Remove() nvg_light = nil end
        end
        return
    end
    
    local hasNVG = ply:GetNetVar("implant_nvg")
    local hasThermal = ply:GetNetVar("implant_thermal")
    
    if not hasNVG and not hasThermal then
        if nvg_enabled then
            nvg_enabled = false
            thermalMode = false
            hook.Remove("RenderScreenspaceEffects", "implant_nvg_effect")
            if IsValid(nvg_light) then nvg_light:Remove() nvg_light = nil end
        end
        return
    end
    
    if input.IsKeyDown(KEY_N) and not ply._nvg_held then
        ply._nvg_held = true
        
        if hasNVG then
            nvg_enabled = not nvg_enabled
            thermalMode = false
            if nvg_enabled then
                surface.PlaySound("items/nvg_on.wav")
                hook.Add("RenderScreenspaceEffects", "implant_nvg_effect", function()
                    nvg_transition = math.min(nvg_transition + FrameTime() * 2, 1)
                    local cc = table.Copy(nvg_color)
                    for k, v in pairs(cc) do cc[k] = v * nvg_transition end
                    DrawColorModify(cc)
                    DrawBloom(0.1 * nvg_transition, 1 * nvg_transition, 2, 2, 1, 0.4 * nvg_transition, 1, 1, 1)
                    if not IsValid(nvg_light) then
                        nvg_light = ProjectedTexture()
                        nvg_light:SetTexture("effects/flashlight001")
                        nvg_light:SetBrightness(2)
                        nvg_light:SetEnableShadows(false)
                        nvg_light:SetFOV(70)
                    end
                    nvg_light:SetPos(LocalPlayer():EyePos())
                    nvg_light:SetAngles(LocalPlayer():EyeAngles())
                    nvg_light:Update()
                end)
            else
                surface.PlaySound("items/nvg_off.wav")
                nvg_transition = 0
                hook.Remove("RenderScreenspaceEffects", "implant_nvg_effect")
                if IsValid(nvg_light) then nvg_light:Remove() nvg_light = nil end
            end
        elseif hasThermal then
            thermalMode = not thermalMode
            nvg_enabled = thermalMode
            surface.PlaySound(thermalMode and "items/nvg_on.wav" or "items/nvg_off.wav")
        end
    elseif not input.IsKeyDown(KEY_N) then
        ply._nvg_held = false
    end
end)

hook.Add("HUDPaint", "implant_thermal_vision", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_thermal") then return end
    if not nvg_enabled then return end
    if not thermalMode then return end
    
    local eyePos = ply:EyePos()
    
    for _, ent in ipairs(ents.FindInSphere(eyePos, 3000)) do
        if ent == ply then continue end
        if not ent:IsPlayer() and not ent:IsNPC() then continue end
        if (ent:IsPlayer() or ent:IsNPC()) and not ent:Alive() then continue end
        
        local mins, maxs = ent:GetRenderBounds()
        local center = ent:GetPos() + (mins + maxs) / 2
        local size = maxs - mins
        
        local corners = {
            center + Vector(-size.x/2, -size.y/2, -size.z/2),
            center + Vector(size.x/2, -size.y/2, -size.z/2),
            center + Vector(size.x/2, size.y/2, -size.z/2),
            center + Vector(-size.x/2, size.y/2, -size.z/2),
            center + Vector(-size.x/2, -size.y/2, size.z/2),
            center + Vector(size.x/2, -size.y/2, size.z/2),
            center + Vector(size.x/2, size.y/2, size.z/2),
            center + Vector(-size.x/2, size.y/2, size.z/2),
        }
        
        local minX, minY = ScrW(), ScrH()
        local maxX, maxY = 0, 0
        local visible = false
        for _, corner in ipairs(corners) do
            local scr = corner:ToScreen()
            if not scr.visible then continue end
            visible = true
            minX = math.min(minX, scr.x)
            minY = math.min(minY, scr.y)
            maxX = math.max(maxX, scr.x)
            maxY = math.max(maxY, scr.y)
        end
        
        if not visible then continue end
        
        local dist = eyePos:Distance(ent:GetPos())
        local alpha = math.Clamp(1 - dist / 3000, 0, 1) * 150
        local color = ent:IsPlayer() and Color(255, 200, 50, alpha) or Color(255, 100, 30, alpha)
        
        draw.RoundedBox(2, minX, minY, maxX - minX, maxY - minY, color)
    end
end)

hook.Add("RenderScreenspaceEffects", "implant_thermal_color", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_thermal") then return end
    if not nvg_enabled then return end
    
    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0.15,
        ["$pp_colour_contrast"] = 1.5,
        ["$pp_colour_colour"] = 0,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0,
    })
    
    surface.SetDrawColor(255, 255, 255, 20)
    for i = 0, ScrH(), 3 do
        surface.DrawRect(0, i, ScrW(), 1)
    end
    
    draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 100))
end)

local function drawHUD(ply, hasStamina)
    surface.SetFont("NLFontDefault")
    local _, bigH = surface.GetTextSize("0")
    surface.SetFont("NLFontSmall")
    local _, smallH = surface.GetTextSize("0")

    local baseY      = ScrH() - 50
    local bloodcount = math.Round(100 * ply.organism.blood / 5000, 0)
    local pulse      = math.Round(ply.organism.heartbeat or 70, 0)

    drawBigStat(bloodcount, "% | BLOOD", ScrW() * 0.03, baseY - bigH)

   local y = baseY - bigH - smallH - -2

    drawSmallStat(pulse, "| HEART B/MIN", ScrW() * 0.03, y)
    y = y - smallH - 4

if hasStamina then
    local stamina = math.Round(ply.organism.stamina and ply.organism.stamina[1] or 180, 0)
    drawSmallStat(stamina, "| STAMINA", ScrW() * 0.03, y)
    y = y - smallH - 10
end

local wallet = tonumber(ply:GetNWString("WalletMoney") or "0") or 0
wallet_smooth = wallet_smooth == 0 and wallet or wallet_smooth

if wallet ~= wallet_prev then
    if wallet_prev ~= 0 and wallet_prev ~= nil then
        surface.PlaySound("money_transfer.wav")
    end
    if wallet < wallet_prev then
        wallet_color = Color(255, 50, 50, 220)
    else
        wallet_color = Color(50, 255, 50, 220)
    end
    wallet_prev = wallet
else
    wallet_color.r = math.Approach(wallet_color.r, wallet_color.r > 100 and 0 or 0, FrameTime() * 100)
    wallet_color.g = math.Approach(wallet_color.g, 255, FrameTime() * 100)
end

wallet_smooth = Lerp(FrameTime() * 2.5, wallet_smooth, wallet)

local walletNum = string.Comma(math.Round(wallet_smooth))
local walletText = walletNum .. " | WALLET"
local walletY = ScrH() * 0.904
local walletX = ScrW() * 0.22

draw.DrawText(walletText, "NLFontSmall", walletX + 2, walletY + 2, color_shadow, TEXT_ALIGN_RIGHT)
draw.DrawText(walletText, "NLFontSmall", walletX + 1, walletY + 1, color_shadow, TEXT_ALIGN_RIGHT)
draw.DrawText(walletText, "NLFontSmall", walletX, walletY, wallet_color, TEXT_ALIGN_RIGHT)

local bank = tonumber(ply:GetNWString("BankMoney") or "0") or 0
bank_smooth = bank_smooth == 0 and bank or bank_smooth

if bank ~= bank_prev then
    if bank_prev ~= 0 and bank_prev ~= nil then
        surface.PlaySound("money_transfer.wav")
    end
    if bank < bank_prev then
        bank_color = Color(255, 50, 50, 220)
    else
        bank_color = Color(50, 255, 50, 220)
    end
    bank_prev = bank
else
    bank_color.r = math.Approach(bank_color.r, 0, FrameTime() * 100)
    bank_color.g = math.Approach(bank_color.g, 255, FrameTime() * 100)
end

bank_smooth = Lerp(FrameTime() * 2.5, bank_smooth, bank)

local bankNum = string.Comma(math.Round(bank_smooth))
local bankText = bankNum .. " | BANK"
local bankY = walletY + smallH + 4
local bankX = ScrW() * 0.2085

draw.DrawText(bankText, "NLFontSmall", bankX + 2, bankY + 2, color_shadow, TEXT_ALIGN_RIGHT)
draw.DrawText(bankText, "NLFontSmall", bankX + 1, bankY + 1, color_shadow, TEXT_ALIGN_RIGHT)
draw.DrawText(bankText, "NLFontSmall", bankX, bankY, bank_color, TEXT_ALIGN_RIGHT)
end

hook.Add("RenderScreenspaceEffects", "implant_neurolink_scrap", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_scrap") then return end
    
    if not ply._scrapInit then
        ply._scrapNextGlitch = 0
        ply._scrapNextFlicker = 0
        ply._scrapNextTear = 0
        ply._scrapNextGhost = 0
        ply._scrapNextShift = 0
        ply._scrapNextBlackout = 0
        ply._scrapInit = true
    end
    
    surface.SetDrawColor(0, 0, 0, 70)
    for i = 0, ScrH(), 2 do surface.DrawRect(0, i, ScrW(), 1) end
    surface.SetDrawColor(0, 0, 0, 40)
    for i = 0, ScrH(), 3 do surface.DrawRect(0, i, ScrW(), 1) end
    surface.SetDrawColor(0, 0, 0, 20)
    for i = 0, ScrH(), 5 do surface.DrawRect(0, i, ScrW(), 1) end
    surface.SetDrawColor(0, 0, 0, 70)
    for i = 0, ScrH(), 2 do surface.DrawRect(0, i, ScrW(), 1) end
    
    local gX, gY = 0, 0
    if math.random(100) <= 15 then gX = math.random(-6, 6); gY = math.random(-4, 4) end
    
local vignetteMat = Material("effects/shaders/zb_vignette")
if not vignetteMat:IsError() then
    render.UpdateScreenEffectTexture()
    vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
    vignetteMat:SetFloat("$c0_z", 2)
    vignetteMat:SetFloat("$c1_y", 8)
    render.SetMaterial(vignetteMat)
    render.DrawScreenQuad()
end

    local scrapPhrases = {"ERROR: SIGNAL CORRUPTED","0x00000FATAL","STACK OVERFLOW","NULL REFERENCE","MEMORY LEAK DETECTED","BAD ALLOCATION","SEGMENTATION FAULT","BUFFER OVERRUN","INVALID POINTER","UNHANDLED EXCEPTION","DUMPING CORE...","REBOOT REQUIRED"}
    ply._scrapBannerText = ""
    for i = 1, #scrapPhrases do ply._scrapBannerText = ply._scrapBannerText .. " // " .. scrapPhrases[i] end
    if not ply._scrapBannerX or ply._scrapBannerX < -ScrW()*3 then ply._scrapBannerX = ScrW() end
    ply._scrapBannerX = ply._scrapBannerX - FrameTime() * 150
    local bannerH, bannerY = ScreenScale(8), ScreenScale(2)
    draw.RoundedBox(0, 0, bannerY-1, ScrW(), bannerH+2, Color(30,0,0,160))
    draw.DrawText(ply._scrapBannerText, "NL_Menu_Tiny", ply._scrapBannerX + gX, bannerY + bannerH/2 - 6 + gY, Color(255,50,50,120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
    draw.DrawText("NEUROLINK v" .. math.random(0, 9999), "NL_Menu_Tiny", ScrW()-ScreenScale(8)+gX, ScrH()-ScreenScale(16)+gY, Color(255,30,30,90), TEXT_ALIGN_RIGHT)
    draw.DrawText("NO CORPO AFFILIATION FOUND", "NL_Menu_Tiny", ScrW()-ScreenScale(8)+gX, ScrH()-ScreenScale(8)+gY, Color(255,30,30,70), TEXT_ALIGN_RIGHT)
    
local pulse = ply.organism.heartbeat or 0
local blood = ply.organism.blood or 0
local bloodPct = (blood/5000)*100
local wallet = tonumber(ply:GetNWString("WalletMoney")or"0")or 0
local bank = tonumber(ply:GetNWString("BankMoney")or"0")or 0
wallet_smooth = wallet_smooth==0 and wallet or wallet_smooth
bank_smooth = bank_smooth==0 and bank or bank_smooth
wallet_smooth = Lerp(FrameTime()*2.5,wallet_smooth,wallet)
bank_smooth = Lerp(FrameTime()*2.5,bank_smooth,bank)
surface.SetFont("NLFontSmall")
local _,smallH = surface.GetTextSize("0")

if not ply._scrapGlitchVal or CurTime() > (ply._scrapNextGlitchVal or 0) then
    ply._scrapNextGlitchVal = CurTime() + math.Rand(3, 8)
    if math.random(100) <= 40 then
        ply._scrapGlitchVal = math.Rand(0.5, 1.5)
        ply._scrapGlitchOffset = math.random(-20, 20)
    else
        ply._scrapGlitchVal = 1
        ply._scrapGlitchOffset = 0
    end
end

local gVal = ply._scrapGlitchVal or 1
local gOff = ply._scrapGlitchOffset or 0

local hudX = ScrW()*0.03

local bloodVal = math.Round(bloodPct * gVal + gOff)
draw.DrawText(bloodVal .. "% | BLOOD", "NLFontSmall", hudX+gX+2, ScrH()*0.78+gY+2, color_shadow, TEXT_ALIGN_LEFT)
draw.DrawText(bloodVal .. "% | BLOOD", "NLFontSmall", hudX+gX+1, ScrH()*0.78+gY+1, color_shadow, TEXT_ALIGN_LEFT)
draw.DrawText(bloodVal .. "% | BLOOD", "NLFontSmall", hudX+gX, ScrH()*0.78+gY, color_main, TEXT_ALIGN_LEFT)

local heartVal = math.Round(pulse * gVal + gOff)
draw.DrawText(heartVal .. " | HEART B/MIN", "NLFontSmall", hudX+gX+2, ScrH()*0.82+gY+2, color_shadow, TEXT_ALIGN_LEFT)
draw.DrawText(heartVal .. " | HEART B/MIN", "NLFontSmall", hudX+gX+1, ScrH()*0.82+gY+1, color_shadow, TEXT_ALIGN_LEFT)
draw.DrawText(heartVal .. " | HEART B/MIN", "NLFontSmall", hudX+gX, ScrH()*0.82+gY, color_main, TEXT_ALIGN_LEFT)

local walletVal = math.Round(wallet_smooth * gVal + gOff * 100)
local walletText = string.Comma(walletVal) .. " | WALLET"
local walletY = ScrH()*0.904
local walletX = ScrW()*0.22
draw.DrawText(walletText,"NLFontSmall",walletX+gX+2,walletY+gY+2,color_shadow,TEXT_ALIGN_RIGHT)
draw.DrawText(walletText,"NLFontSmall",walletX+gX+1,walletY+gY+1,color_shadow,TEXT_ALIGN_RIGHT)
draw.DrawText(walletText,"NLFontSmall",walletX+gX,walletY+gY,wallet_color,TEXT_ALIGN_RIGHT)

local bankVal = math.Round(bank_smooth * gVal + gOff * 100)
local bankText = string.Comma(bankVal) .. " | BANK"
local bankY = walletY+smallH+4
local bankX = ScrW()*0.2085
draw.DrawText(bankText,"NLFontSmall",bankX+gX+2,bankY+gY+2,color_shadow,TEXT_ALIGN_RIGHT)
draw.DrawText(bankText,"NLFontSmall",bankX+gX+1,bankY+gY+1,color_shadow,TEXT_ALIGN_RIGHT)
draw.DrawText(bankText,"NLFontSmall",bankX+gX,bankY+gY,color_main,TEXT_ALIGN_RIGHT)
    
    if CurTime()>(ply._scrapNextGlitch or 0) then ply._scrapNextGlitch=CurTime()+math.Rand(3,15); ply._scrapGlitchTime=CurTime()+math.Rand(0.05,0.2); ply._scrapGlitchY=math.random(0,ScrH()) end
    if ply._scrapGlitchTime and CurTime()<ply._scrapGlitchTime then surface.SetDrawColor(255,40,60,150) surface.DrawRect(0,ply._scrapGlitchY,ScrW(),math.random(2,6)) surface.SetDrawColor(0,255,200,100) surface.DrawRect(math.random(-20,20),ply._scrapGlitchY+2,ScrW(),math.random(1,3)) end
    
    if CurTime()>(ply._scrapNextFlicker or 0) then ply._scrapNextFlicker=CurTime()+math.Rand(5,20); ply._scrapFlickerTime=CurTime()+math.Rand(0.05,0.25) end
    if ply._scrapFlickerTime and CurTime()<ply._scrapFlickerTime then surface.SetDrawColor(0,0,0,math.random(60,200)) surface.DrawRect(0,0,ScrW(),ScrH()) end
    
    if CurTime()>(ply._scrapNextTear or 0) then ply._scrapNextTear=CurTime()+math.Rand(8,30); ply._scrapTearY=math.random(ScrH()*0.2,ScrH()*0.8); ply._scrapTearTime=CurTime()+math.Rand(0.1,0.4) end
    if ply._scrapTearTime and CurTime()<ply._scrapTearTime then local o=math.random(-20,20) surface.SetDrawColor(0,255,100,80) surface.DrawRect(0,ply._scrapTearY,ScrW(),2) surface.DrawRect(o,ply._scrapTearY+3,ScrW(),1) end
    
    if CurTime()>(ply._scrapNextGhost or 0) then ply._scrapNextGhost=CurTime()+math.Rand(15,45); ply._scrapGhostTime=CurTime()+math.Rand(0.2,0.6); ply._scrapGhostX=math.random(-40,40); ply._scrapGhostY=math.random(-15,15) end
    if ply._scrapGhostTime and CurTime()<ply._scrapGhostTime then surface.SetDrawColor(255,255,255,40) surface.DrawRect(ply._scrapGhostX,ply._scrapGhostY,ScrW(),ScrH()) end
    
    if CurTime()>(ply._scrapNextShift or 0) then ply._scrapNextShift=CurTime()+math.Rand(10,35); ply._scrapShiftTime=CurTime()+math.Rand(0.05,0.12); ply._scrapShiftX=math.random(-10,10); ply._scrapShiftY=math.random(-6,6) end
    if ply._scrapShiftTime and CurTime()<ply._scrapShiftTime then surface.SetDrawColor(0,0,0,80) surface.DrawRect(ply._scrapShiftX,ply._scrapShiftY,ScrW(),ScrH()) end
    
    if CurTime()>(ply._scrapNextBlackout or 0) then 
        ply._scrapNextBlackout=CurTime()+math.Rand(45,120)
        ply._scrapBlackoutTime=CurTime()+1.5
    end
    if ply._scrapBlackoutTime and CurTime()<ply._scrapBlackoutTime then 
        surface.SetDrawColor(0,0,0,255) 
        surface.DrawRect(0,0,ScrW()+10,ScrH()+10) 
        local elapsed = ply._scrapBlackoutTime - CurTime()
        if elapsed > 0.7 then
            draw.DrawText("SIGNAL LOST","NL_Menu_Sub",ScrW()*0.5,ScrH()*0.4,Color(255,0,0,220),TEXT_ALIGN_CENTER)
        else
            draw.DrawText("REBOOTING...","NL_Menu_Sub",ScrW()*0.5+math.random(-8,8),ScrH()*0.4+math.random(-4,4),Color(255,100,50,220),TEXT_ALIGN_CENTER)
            for i=1,8 do surface.SetDrawColor(255,40,60,math.random(100,255)) surface.DrawRect(0,math.random(0,ScrH()),ScrW(),math.random(1,4)) end
        end
    end
end)

hook.Add("RenderScreenspaceEffects", "implant_neurolink_diy", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_diy") then return end
    
    if not ply._diyInit then
        ply._diyNextGlitch = 0
        ply._diyNextFlicker = 0
        ply._diyNextShift = 0
        ply._diyInit = true
    end
    
    surface.SetDrawColor(0,0,0,50) for i=0,ScrH(),2 do surface.DrawRect(0,i,ScrW(),1) end
    surface.SetDrawColor(0,0,0,30) for i=0,ScrH(),4 do surface.DrawRect(0,i,ScrW(),1) end
    surface.SetDrawColor(0,0,0,15) for i=0,ScrH(),6 do surface.DrawRect(0,i,ScrW(),1) end
    
    local gX, gY = 0, 0
    if math.random(100)<=10 then gX=math.random(-4,4); gY=math.random(-2,2) end
    
local vignetteMat = Material("effects/shaders/zb_vignette")
if not vignetteMat:IsError() then
    render.UpdateScreenEffectTexture()
    vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
    vignetteMat:SetFloat("$c0_z", 1)
    vignetteMat:SetFloat("$c1_y", 4)
    render.SetMaterial(vignetteMat)
    render.DrawScreenQuad()
end

if not ply._diyPopupTimer or CurTime() > ply._diyPopupTimer then
    ply._diyPopupTimer = CurTime() + math.Rand(40, 80)
    ply._diyPopupText = "FIRMWARE UPDATE AVAILABLE v" .. math.random(1,9) .. "." .. math.random(0,9) .. " - DOWNLOAD NOW"
    ply._diyPopupTime = CurTime() + 4
    ply._diyPopupSlide = -ScreenScale(20)
end

if ply._diyPopupTime and CurTime() < ply._diyPopupTime then
    local targetY = ScreenScale(50)
    local elapsed = 4 - (ply._diyPopupTime - CurTime())
    if elapsed < 0.3 then
        ply._diyPopupSlide = Lerp(elapsed/0.3, -ScreenScale(20), targetY)
    elseif elapsed > 3.7 then
        local fadeOut = (elapsed - 3.7) / 0.3
        ply._diyPopupSlide = Lerp(fadeOut, targetY, -ScreenScale(20))
    else
        ply._diyPopupSlide = targetY
    end
    
    local popupW = ScrW() * 0.45
    local popupH = ScreenScale(12)
    local popupX = (ScrW() - popupW) / 2
    
    draw.RoundedBox(2, popupX, ply._diyPopupSlide, popupW, popupH, Color(20, 20, 0, 200))
    draw.RoundedBox(2, popupX, ply._diyPopupSlide, popupW, 1, Color(255, 200, 50, 150))
    draw.RoundedBox(2, popupX, ply._diyPopupSlide+popupH-1, popupW, 1, Color(255, 200, 50, 150))
    surface.SetDrawColor(255, 200, 50, 150)
    surface.DrawRect(popupX, ply._diyPopupSlide, 2, popupH)
    surface.DrawRect(popupX+popupW-2, ply._diyPopupSlide, 2, popupH)
    
    draw.DrawText(ply._diyPopupText, "NL_Menu_Tiny", popupX + popupW/2, ply._diyPopupSlide + popupH/2 - 1,
        Color(255, 200, 50, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("Think", "DIY_OtrubMessage", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_diy") then return end
    
    if ply.organism and ply.organism.otrub then
        if not ply._diyOtrubShown then
            ply._diyOtrubShown = true
            chat.AddText(Color(255, 200, 50), "[DIY NEUROLINK] CRITICAL ERROR: PLEASE REBOOT USER")
        end
    else
        ply._diyOtrubShown = false
    end
end)

    local diyPhrases = {"TODO: FIX THIS LATER","IT WORKS ON MY MACHINE","NO IDEA WHY THIS WORKS","DONT TOUCH THIS","MAGIC. DO NOT REMOVE.","THIS IS FINE :)","SOLDERED WHILE DRUNK","WARRANTY VOID IF USED","MADE IN A GARAGE","MY GRANDMA COULD CODE BETTER","PLEASE DONT CRASH","// FIXME: TOMORROW","COMMIT: 'STUFF'","WORKS 60% OF THE TIME"}
    ply._diyBannerText = ""
    for i=1,#diyPhrases do ply._diyBannerText = ply._diyBannerText.." | "..diyPhrases[i] end
    if not ply._diyBannerX or ply._diyBannerX<-ScrW()*3 then ply._diyBannerX=ScrW() end
    ply._diyBannerX = ply._diyBannerX - FrameTime()*130
    local bannerH, bannerY = ScreenScale(8), ScreenScale(2)
    draw.RoundedBox(0,0,bannerY-1,ScrW(),bannerH+2,Color(20,20,0,160))
    draw.DrawText(ply._diyBannerText,"NL_Menu_Tiny",ply._diyBannerX+gX,bannerY+bannerH/2-6+gY,Color(255,200,50,120),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
    
    draw.DrawText("this uses i think neurolink v0.2","NL_Menu_Tiny",ScrW()-ScreenScale(8)+gX,ScrH()-ScreenScale(16)+gY,Color(255,200,50,90),TEXT_ALIGN_RIGHT)
    draw.DrawText("so it's really beta but WORKS YIPPEE // REPORT BUGS TO MY EMAIL = AlexMyersTheRipperdoc@proton.me","NL_Menu_Tiny",ScrW()-ScreenScale(8)+gX,ScrH()-ScreenScale(8)+gY,Color(255,200,50,70),TEXT_ALIGN_RIGHT)
    
    local pulse = ply.organism.heartbeat or 0
    local blood = ply.organism.blood or 0
    local bloodPct = (blood/5000)*100
    local wallet = tonumber(ply:GetNWString("WalletMoney")or"0")or 0
    local bank = tonumber(ply:GetNWString("BankMoney")or"0")or 0
    wallet_smooth = wallet_smooth==0 and wallet or wallet_smooth
    bank_smooth = bank_smooth==0 and bank or bank_smooth
    wallet_smooth = Lerp(FrameTime()*2.5,wallet_smooth,wallet)
    bank_smooth = Lerp(FrameTime()*2.5,bank_smooth,bank)
    surface.SetFont("NLFontSmall")
    local _,smallH = surface.GetTextSize("0")
    
    local heartX, heartY = ScrW()*0.03, ScrH()*0.85
    local heartText = tostring(pulse).." | HEART B/MIN"
    if math.random(100)<=10 then heartText = tostring(math.random(40,200)).." | HEART B/MIN" end
    draw.DrawText(heartText,"NLFontSmall",heartX+gX+2,heartY+gY+2,color_shadow,TEXT_ALIGN_LEFT)
    draw.DrawText(heartText,"NLFontSmall",heartX+gX+1,heartY+gY+1,color_shadow,TEXT_ALIGN_LEFT)
    draw.DrawText(heartText,"NLFontSmall",heartX+gX,heartY+gY,color_main,TEXT_ALIGN_LEFT)
    
    local bloodText = string.format("%.1f",bloodPct).."% | BLOOD"
    draw.DrawText(bloodText,"NLFontSmall",heartX+gX+2,heartY-smallH-2+gY+2,color_shadow,TEXT_ALIGN_LEFT)
    draw.DrawText(bloodText,"NLFontSmall",heartX+gX+1,heartY-smallH-2+gY+1,color_shadow,TEXT_ALIGN_LEFT)
    draw.DrawText(bloodText,"NLFontSmall",heartX+gX,heartY-smallH-2+gY,color_main,TEXT_ALIGN_LEFT)
    
    local walletNum = string.Comma(math.Round(wallet_smooth))
    local walletText = walletNum.." | WALLET"
    local walletY = ScrH()*0.904
    local walletX = ScrW()*0.22
    draw.DrawText(walletText,"NLFontSmall",walletX+gX+2,walletY+gY+2,color_shadow,TEXT_ALIGN_RIGHT)
    draw.DrawText(walletText,"NLFontSmall",walletX+gX+1,walletY+gY+1,color_shadow,TEXT_ALIGN_RIGHT)
    draw.DrawText(walletText,"NLFontSmall",walletX+gX,walletY+gY,wallet_color,TEXT_ALIGN_RIGHT)
    
    local bankNum = string.Comma(math.Round(bank_smooth))
    local bankText = bankNum.." | BANK"
    local bankY = walletY+smallH+4
    local bankX = ScrW()*0.2085
    draw.DrawText(bankText,"NLFontSmall",bankX+gX+2,bankY+gY+2,color_shadow,TEXT_ALIGN_RIGHT)
    draw.DrawText(bankText,"NLFontSmall",bankX+gX+1,bankY+gY+1,color_shadow,TEXT_ALIGN_RIGHT)
    draw.DrawText(bankText,"NLFontSmall",bankX+gX,bankY+gY,color_main,TEXT_ALIGN_RIGHT)
    
    if CurTime()>(ply._diyNextGlitch or 0) then ply._diyNextGlitch=CurTime()+math.Rand(10,30); ply._diyGlitchTime=CurTime()+math.Rand(0.05,0.15); ply._diyGlitchY=math.random(0,ScrH()) end
    if ply._diyGlitchTime and CurTime()<ply._diyGlitchTime then surface.SetDrawColor(0,200,255,100) surface.DrawRect(0,ply._diyGlitchY,ScrW(),math.random(1,3)) end
    
    if CurTime()>(ply._diyNextFlicker or 0) then ply._diyNextFlicker=CurTime()+math.Rand(20,50); ply._diyFlickerTime=CurTime()+math.Rand(0.05,0.15) end
    if ply._diyFlickerTime and CurTime()<ply._diyFlickerTime then surface.SetDrawColor(0,0,0,math.random(30,100)) surface.DrawRect(0,0,ScrW(),ScrH()) end
    
    if CurTime()>(ply._diyNextShift or 0) then ply._diyNextShift=CurTime()+math.Rand(30,60); ply._diyShiftTime=CurTime()+math.Rand(0.05,0.1); ply._diyShiftX=math.random(-5,5); ply._diyShiftY=math.random(-3,3) end
    if ply._diyShiftTime and CurTime()<ply._diyShiftTime then surface.SetDrawColor(0,0,0,40) surface.DrawRect(ply._diyShiftX,ply._diyShiftY,ScrW(),ScrH()) end
end)

hook.Add("RenderScreenspaceEffects", "implant_neurolink_blackmarket", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_blackmarket") then return end
    
    if not ply._bmInit then
       ply._bmNextPing = CurTime() + 10
       ply._bmNextData = CurTime() + 10
       ply._bmNextKillswitch = CurTime() + 5
       ply._bmNextBackdoor = CurTime() + 10
       ply._bmInit = true
end
    
    surface.SetDrawColor(0, 0, 0, 30)
    for i = 0, ScrH(), 2 do
        surface.DrawRect(0, i, ScrW(), 1)
    end
    surface.SetDrawColor(0, 0, 0, 15)
    for i = 0, ScrH(), 5 do
        surface.DrawRect(0, i, ScrW(), 1)
    end

local gX = 0
local gY = 0
if math.random(100) <= 8 then
    gX = math.random(-3, 3)
    gY = math.random(-2, 2)
end

    local vignetteMat = Material("effects/shaders/zb_vignette")
if not vignetteMat:IsError() then
    render.UpdateScreenEffectTexture()
    vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
    vignetteMat:SetFloat("$c0_z", 0.5)
    vignetteMat:SetFloat("$c1_y", 1)
    render.SetMaterial(vignetteMat)
    render.DrawScreenQuad()
end
    
    drawHUD(ply, true)

local phrases = {
    "WARNING: STOLEN CORPO PROPERTY",
    "TRACKING ACTIVE",
    "UNIT ID: " .. math.random(1000, 9999),
    "SIGNAL RELAY: ".. math.random(1000, 9999),
    "NEUROLINK v2.17",
    "UNAUTHORIZED USE DETECTED",
    "IMMEDIATE TERMINATION AUTHORIZED",
    "ALL RIGHTS RESERVED",
    "REPORT TO ENFORCEMENT",
    "HAVE A SAFE DAY CITIZEN",
    "NEUROL" .. math.random(1000, 9999),
    "FUCK CORPO SHIT",
    "BURN CORPO SHIT",
    "KILL CORPO SHIT",
    "NUKE CORPO SHIT",
    "YOUR COOPERATION IS APPRECIATED",
}
ply._bmBannerText = ""
for i = 1, #phrases do
    ply._bmBannerText = ply._bmBannerText .. " /// " .. phrases[i]
end
if not ply._bmBannerX or ply._bmBannerX < -ScrW() * 3 then 
    ply._bmBannerX = ScrW() 
end
ply._bmBannerX = ply._bmBannerX - FrameTime() * 50

local bannerH = ScreenScale(8)
local bannerY = ScreenScale(2)
draw.RoundedBox(0, 0, bannerY - 1, ScrW(), bannerH + 2, Color(20, 0, 0, 160))
draw.DrawText(ply._bmBannerText, "NL_Menu_Tiny", ply._bmBannerX, bannerY + bannerH/2 - 6,
    Color(255, 180, 180, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

draw.DrawText("SOUTH BATALLION", "NL_Menu_Tiny", ScrW() - ScreenScale(8) + gX, ScrH() - ScreenScale(16) + gY,
    Color(255, 40, 60, 110), TEXT_ALIGN_RIGHT)
draw.DrawText("NEUROLINK v2.17", "NL_Menu_Tiny", ScrW() - ScreenScale(8) + gX, ScrH() - ScreenScale(8) + gY,
    Color(255, 40, 60, 90), TEXT_ALIGN_RIGHT)

if not ply._bmPopupTimer or CurTime() > ply._bmPopupTimer then
    ply._bmPopupTimer = CurTime() + math.Rand(45, 90)
    local ads = {
        "UPGRADE TO PREMIUM TODAY - UNLOCK ADVANCED FEATURES",
        "BIOMETRIC SCAN REQUIRED - PLEASE LOOK INTO THE CAMERA",
        "FIRMWARE UPDATE v3.0 AVAILABLE - DOWNLOAD NOW",
        "YOUR TRIAL IS EXPIRING - SUBSCRIBE FOR CONTINUED USE",
        "AD-FREE EXPERIENCE - ONLY $999/MONTH",
        "NEUROLINK PRO - THE ULTIMATE COMBAT HUD",
        "WARNING: UNLICENSED COPY DETECTED - REPORT TO NEUROLINK",
        "VERIFY YOUR IDENTITY - MANDATORY COMPLIANCE CHECK",
        "NEW UPDATE: NIGHT VISION v2.1 AVAILABLE",
        "SYSTEM DIAGNOSTICS: ALL SYSTEMS NOMINAL",
        "SECURITY ALERT: UNVERIFIED USER DETECTED",
        "MAINTENANCE SCHEDULED - UPDATE YOUR FIRMWARE",
        "OPTIC CALIBRATION RECOMMENDED - CLICK HERE",
        "YOUR DATA IS SAFE WITH US - TRUST THE CORPO",
        "NEURAL LINK ESTABLISHED - WELCOME BACK USER",
        "CRITICAL: BIOMETRIC DATA OUTDATED",
        "ENJOYING YOUR IMPLANT? RATE US 5 STARS",
        "NEW FEATURE: THREAT DETECTION ENHANCED",
        "SYNAPSE BOOST ACTIVATED - THINK FASTER"
    }
    ply._bmPopupText = "/// CORPO NOTICE: " .. ads[math.random(#ads)] .. " ///"
    ply._bmPopupTime = CurTime() + 6
    ply._bmPopupSlide = -ScreenScale(20)
end

if ply._bmPopupTime and CurTime() < ply._bmPopupTime then
    local targetY = ScreenScale(30)
    local elapsed = 4 - (ply._bmPopupTime - CurTime())
    if elapsed < 0.3 then
        ply._bmPopupSlide = Lerp(elapsed/0.3, -ScreenScale(20), targetY)
    elseif elapsed > 3.7 then
        local fadeOut = (elapsed - 3.7) / 0.3
        ply._bmPopupSlide = Lerp(fadeOut, targetY, -ScreenScale(20))
    else
        ply._bmPopupSlide = targetY
    end
    
    local popupW = ScrW() * 0.55
    local popupH = ScreenScale(14)
    local popupX = (ScrW() - popupW) / 2
    
    draw.RoundedBox(3, popupX, ply._bmPopupSlide, popupW, popupH, Color(0, 8, 20, 210))
draw.RoundedBox(3, popupX, ply._bmPopupSlide, popupW, 1, Color(0, 200, 255, 180))
draw.RoundedBox(3, popupX, ply._bmPopupSlide+popupH-1, popupW, 1, Color(0, 200, 255, 180))
surface.SetDrawColor(0, 200, 255, 180)
surface.DrawRect(popupX, ply._bmPopupSlide, 3, popupH)
surface.DrawRect(popupX+popupW-3, ply._bmPopupSlide, 3, popupH)
    
    draw.DrawText(ply._bmPopupText, "NL_Menu_Tiny", popupX + popupW/2, ply._bmPopupSlide + popupH/2 - 5,
        Color(0, 220, 255, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

if not ply._bmScanTimer or CurTime() > ply._bmScanTimer then
    ply._bmScanTimer = CurTime() + math.Rand(30, 60)
    ply._bmScanTime = CurTime() + 10
    ply._bmScanTarget = "USER_" .. math.random(1000, 9999)
    ply._bmScanSlide = -ScreenScale(90)
end

if ply._bmScanTime and CurTime() < ply._bmScanTime then
    local targetX = ScreenScale(10)
    local elapsed = 3 - (ply._bmScanTime - CurTime())
    if elapsed < 0.3 then
        ply._bmScanSlide = Lerp(elapsed/0.3, -ScreenScale(90), targetX)
    elseif elapsed > 2.7 then
        local fadeOut = (elapsed - 2.7) / 0.3
        ply._bmScanSlide = Lerp(fadeOut, targetX, -ScreenScale(90))
    else
        ply._bmScanSlide = targetX
    end
    
    local scanW = ScreenScale(85)
    local scanH = ScreenScale(28)
    local scanY = ScrH() - ScreenScale(90)
    
    draw.RoundedBox(2, ply._bmScanSlide, scanY, scanW, scanH, Color(0, 5, 15, 190))
    draw.RoundedBox(2, ply._bmScanSlide, scanY, scanW, 1, Color(0, 255, 200, 120))
    surface.SetDrawColor(0, 255, 200, 120)
    surface.DrawRect(ply._bmScanSlide, scanY, 2, scanH)
    
    draw.DrawText("BIOMETRIC SCAN", "NL_Menu_Tiny", ply._bmScanSlide + 6, scanY + 5,
        Color(0, 255, 200, 160), TEXT_ALIGN_LEFT)
    draw.DrawText("TARGET: " .. ply._bmScanTarget, "NL_Menu_Tiny", ply._bmScanSlide + 6, scanY + 16,
        Color(0, 255, 200, 110), TEXT_ALIGN_LEFT)
    
    local scanLine = math.sin(CurTime() * 12) * scanW * 0.35 + scanW * 0.5
    surface.SetDrawColor(0, 255, 200, 90)
    surface.DrawRect(ply._bmScanSlide + scanLine, scanY, 1, scanH)
end
    
if not ply._bmNextPing or CurTime() > ply._bmNextPing then
    ply._bmNextPing = CurTime() + math.Rand(120, 365)
    ply._bmPingTime = CurTime() + 3
end
if ply._bmPingTime and CurTime() < ply._bmPingTime then
    local oldColor = color_main
    color_main = Color(255, 30, 30, 255)
    
    drawHUD(ply, true)
    
    color_main = oldColor
    
    draw.DrawText("TRACKING ACTIVE", "NL_Menu_Title", ScrW()*0.5, ScrH()*0.4, Color(255, 30, 30, 255), TEXT_ALIGN_CENTER)
    draw.DrawText("YOUR LOCATION IS BEING MONITORED", "NL_Menu_Sub", ScrW()*0.5, ScrH()*0.48, Color(255, 80, 80, 220), TEXT_ALIGN_CENTER)
end

if CurTime() > ply._bmNextData then
    ply._bmNextData = CurTime() + math.Rand(120, 600)
    ply._bmDataTime = CurTime() + 0.5
end
if ply._bmDataTime and CurTime() < ply._bmDataTime then
    surface.SetDrawColor(0, 255, 200, 80)
    for i = 1, 8 do
        surface.DrawRect(math.random(0, ScrW()), math.random(0, ScrH()), math.random(5, 15), math.random(1, 3))
    end
    if math.random(3) == 1 then
        draw.DrawText("DATA STREAM", "NL_Menu_Tiny", ScrW()*math.random(0.3,0.7), ScrH()*math.random(0.3,0.7), Color(0, 255, 200, 120), TEXT_ALIGN_CENTER)
    end
end
    
if CurTime() > ply._bmNextKillswitch then
    ply._bmNextKillswitch = CurTime() + math.Rand(300, 600)
    ply._bmKillswitchTime = CurTime() + 2
end
if ply._bmKillswitchTime and CurTime() < ply._bmKillswitchTime then
    draw.DrawText("UNAUTHORIZED USER", "NL_Menu_Sub", ScrW()*0.5 + math.random(-2,2), ScrH()*0.3 + math.random(-1,1), Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
    draw.DrawText("CORPO LOCKDOWN ACTIVE", "NL_Menu_Tiny", ScrW()*0.5 + math.random(-1,1), ScrH()*0.4 + math.random(-1,1), Color(255, 50, 50, 220), TEXT_ALIGN_CENTER)
    draw.DrawText("DO NOT RESIST", "NL_Menu_Tiny", ScrW()*0.5 + math.random(-1,1), ScrH()*0.45 + math.random(-1,1), Color(255, 80, 80, 200), TEXT_ALIGN_CENTER)
end

if CurTime() > ply._bmNextBackdoor then
    ply._bmNextBackdoor = CurTime() + math.Rand(600, 1200)
    ply._bmBackdoorTime = CurTime() + 2
end
if ply._bmBackdoorTime and CurTime() < ply._bmBackdoorTime then
    surface.SetDrawColor(0, 255, 0, 100)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    draw.DrawText("BACKDOOR ACTIVE", "NL_Menu_Sub", ScrW()*0.5, ScrH()*0.5, Color(0, 255, 0, 220), TEXT_ALIGN_CENTER)
    draw.DrawText("UNKNOWN CONNECTION ESTABLISHED", "NL_Menu_Tiny", ScrW()*0.5, ScrH()*0.55, Color(0, 255, 100, 180), TEXT_ALIGN_CENTER)
    draw.DrawText("ALL DATA TRANSMITTED", "NL_Menu_Tiny", ScrW()*0.5, ScrH()*0.6, Color(0, 255, 100, 150), TEXT_ALIGN_CENTER)
end
end)

hook.Add("RenderScreenspaceEffects", "implant_neurolink_basic", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_basic") then return end
    
    if not ply._basicInit then
        ply._basicNextPopup = CurTime() + math.Rand(90, 630)
        ply._basicInit = true
    end
    if not ply._basicUserID then
        ply._basicUserID = "USER_" .. math.random(100000, 999999)
    end
    
    surface.SetDrawColor(0, 0, 0, 15)
    for i = 0, ScrH(), 4 do surface.DrawRect(0, i, ScrW(), 1) end
    
draw.DrawText("NEUROLINK v.3", "NL_Menu_Tiny", ScrW()-ScreenScale(8), ScrH()-ScreenScale(20), Color(255, 80, 100, 100), TEXT_ALIGN_RIGHT)
draw.DrawText("ID: " .. ply._basicUserID, "NL_Menu_Tiny", ScrW()-ScreenScale(8), ScrH()-ScreenScale(12), Color(255, 80, 100, 85), TEXT_ALIGN_RIGHT)
    
if not ply._basicScanTimer or CurTime() > ply._basicScanTimer then
    ply._basicScanTimer = CurTime() + math.Rand(30, 360)
    ply._basicScanTime = CurTime() + 16
end

if ply._basicScanTime and CurTime() < ply._basicScanTime then
    local scanW = ScreenScale(90)
    local scanH = ScreenScale(32)
    local scanX = ScreenScale(10)
    local scanY = ScrH() - ScreenScale(95)
    local elapsed = 16 - (ply._basicScanTime - CurTime())
    
    local alpha = 255
    if elapsed < 0.5 then alpha = (elapsed / 0.5) * 255
    elseif elapsed > 15.5 then alpha = (1 - (elapsed - 15.5) / 0.5) * 255
    end
    alpha = math.Clamp(alpha, 0, 255)
    
    local gx = 0
    if math.random(100) <= 10 then gx = math.random(-2, 2) end
    
    draw.RoundedBox(2, scanX + gx, scanY, scanW, scanH, Color(0, 5, 15, alpha * 0.75))
    draw.RoundedBox(2, scanX + gx, scanY, scanW, 1, Color(0, 230, 230, alpha * 0.5))
    surface.SetDrawColor(0, 230, 230, alpha * 0.5)
    surface.DrawRect(scanX + gx, scanY, 2, scanH)
    surface.DrawRect(scanX+scanW-2 + gx, scanY, 2, scanH)
    
    local scanLine = math.sin(CurTime() * 12) * scanW * 0.35 + scanW * 0.5
    surface.SetDrawColor(0, 230, 230, alpha * 0.3)
    surface.DrawRect(scanX + scanLine + gx, scanY, 1, scanH)
    
    if elapsed < 5 then
    draw.DrawText("BIOMETRIC SCAN INITIATED", "NL_Menu_Tiny", scanX + 6 + gx, scanY + 5, Color(0, 230, 230, alpha), TEXT_ALIGN_LEFT)
    draw.DrawText("ANALYZING VITALS...", "NL_Menu_Tiny", scanX + 6 + gx, scanY + 20, Color(0, 230, 230, alpha * 0.7), TEXT_ALIGN_LEFT)
    draw.DrawText("PLEASE WAIT...", "NL_Menu_Tiny", scanX + 6 + gx, scanY + 35, Color(0, 230, 230, alpha * 0.4), TEXT_ALIGN_LEFT)
else
    local blood = ply.organism and ply.organism.blood or 5000
    local pulse = ply.organism and ply.organism.heartbeat or 70
    local stamina = ply.organism and ply.organism.stamina and ply.organism.stamina[1] or 180
    local pain = ply.organism and ply.organism.pain or 0
    local adrenaline = ply.organism and ply.organism.adrenaline or 0
    
    draw.DrawText("SCAN COMPLETE", "NL_Menu_Tiny", scanX + 6 + gx, scanY + 5, Color(0, 255, 200, alpha), TEXT_ALIGN_LEFT)
    draw.DrawText("BLOOD: " .. math.Round(blood/50) .. "% | PULSE: " .. math.Round(pulse), "NL_Menu_Tiny", scanX + 6 + gx, scanY + 20, Color(0, 255, 200, alpha * 0.8), TEXT_ALIGN_LEFT)
    draw.DrawText("STAM: " .. math.Round(stamina) .. " | PAIN: " .. math.Round(pain) .. " | ADR: " .. string.format("%.1f", adrenaline), "NL_Menu_Tiny", scanX + 6 + gx, scanY + 35, Color(0, 255, 200, alpha * 0.7), TEXT_ALIGN_LEFT)
end
end
    
    if not ply._basicPopupTimer or CurTime() > ply._basicPopupTimer then
        ply._basicPopupTimer = CurTime() + math.Rand(90, 500)
        local ads = {
            "NEUROLINK v.3 - STABLE RELEASE",
            "OPTIC CALIBRATION COMPLETE",
            "ALL SYSTEMS OPERATIONAL",
            "FIRMWARE UP TO DATE",
            "BIOMETRIC SCAN: PASSED",
            "NEURAL SYNC: NOMINAL",
            "HAVE A SAFE DAY, USER",
            "REGISTERED TO: VALID LICENSE",
        }
        ply._basicPopupText = "/// " .. ads[math.random(#ads)] .. " ///"
        ply._basicPopupTime = CurTime() + 3
        ply._basicPopupSlide = -ScreenScale(20)
    end
    
    if ply._basicPopupTime and CurTime() < ply._basicPopupTime then
        local targetY = ScreenScale(50)
        local elapsed = 3 - (ply._basicPopupTime - CurTime())
        if elapsed < 0.3 then
            ply._basicPopupSlide = Lerp(elapsed/0.3, -ScreenScale(20), targetY)
        elseif elapsed > 2.7 then
            local fadeOut = (elapsed - 2.7) / 0.3
            ply._basicPopupSlide = Lerp(fadeOut, targetY, -ScreenScale(20))
        else
            ply._basicPopupSlide = targetY
        end
        
        local popupW = ScrW() * 0.4
        local popupH = ScreenScale(10)
        local popupX = (ScrW() - popupW) / 2
        
        draw.RoundedBox(2, popupX, ply._basicPopupSlide, popupW, popupH, Color(0, 8, 20, 180))
        draw.RoundedBox(2, popupX, ply._basicPopupSlide, popupW, 1, Color(0, 230, 230, 120))
        draw.RoundedBox(2, popupX, ply._basicPopupSlide+popupH-1, popupW, 1, Color(0, 230, 230, 120))
        surface.SetDrawColor(0, 230, 230, 120)
        surface.DrawRect(popupX, ply._basicPopupSlide, 2, popupH)
        surface.DrawRect(popupX+popupW-2, ply._basicPopupSlide, 2, popupH)
        
        draw.DrawText(ply._basicPopupText, "NL_Menu_Tiny", popupX + popupW/2, ply._basicPopupSlide + popupH/2 - 6,
            Color(0, 230, 230, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    drawHUD(ply, false)
end)

hook.Add("RenderScreenspaceEffects", "implant_neurolink_military", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_military") then return end
    
    if not ply._milInit then
        ply._milInit = true
        ply._milUserID = "OPERATOR_" .. math.random(1000, 9999)
        ply._milBioScanTimer = CurTime() + math.Rand(60, 120)
        ply._milAreaScanTimer = CurTime() + math.Rand(60, 120)
        ply._milNewsTimer = CurTime() + 8
        ply._milKills = ply._milKills or 0
    end
    
    if ply.organism and ply.organism.BerserkKills then
        ply._milKills = ply.BerserkKills or ply._milKills
    end
    
    surface.SetDrawColor(0, 0, 0, 20)
    for i = 0, ScrH(), 3 do surface.DrawRect(0, i, ScrW(), 1) end
    
    draw.DrawText("NEUROLINK MILITARY", "NL_Menu_Tiny", ScrW()-ScreenScale(8), ScrH()-ScreenScale(20), Color(255, 80, 80, 100), TEXT_ALIGN_RIGHT)
    draw.DrawText("COMBAT OS v2.1 | " .. ply._milUserID, "NL_Menu_Tiny", ScrW()-ScreenScale(8), ScrH()-ScreenScale(12), Color(255, 80, 80, 85), TEXT_ALIGN_RIGHT)
    draw.DrawText("KILLS: " .. (ply._milKills or 0), "NL_Menu_Tiny", ScreenScale(10), ScrH()-ScreenScale(8), Color(255, 50, 50, 70), TEXT_ALIGN_LEFT)
    
    local blood = ply.organism and ply.organism.blood or 5000
    local bloodPct = blood / 5000
    local wep = ply:GetActiveWeapon()
    local ammo = IsValid(wep) and wep.Clip1 and wep:Clip1() or 999
    
    if bloodPct < 0.3 then
        local pulse = math.sin(CurTime()*8)*100+155
        draw.DrawText("LOW BLOOD", "NL_Menu_Sub", ScrW()*0.5, ScrH()*0.7, Color(255,0,0,pulse), TEXT_ALIGN_CENTER)
    end
    if ammo <= 5 and ammo >= 0 then
        draw.DrawText("LOW AMMO: "..ammo, "NL_Menu_Tiny", ScrW()*0.5, ScrH()*0.75, Color(255,100,0,200), TEXT_ALIGN_CENTER)
    end
    
    if not ply._milNewsTimer or CurTime() > ply._milNewsTimer then
        ply._milNewsTimer = CurTime() + math.Rand(8, 20)
        local news = {
            "SEC-7: ALL CLEAR.", "INTEL: HOSTILE MOVEMENT IN SECTOR 9.", "COMMAND: REINFORCEMENTS DEPLOYED.",
            "WARNING: UNAUTHORIZED DRONE ACTIVITY.", "TREATY SIGNED BETWEEN EASTERN AND WESTERN BLOCS.",
            "CHROME PRICES UP 15%.", "TOXIC FOG WARNING.", "GANG ACTIVITY UP 30%.",
            "K/D: "..string.format("%.1f",(ply._milKills or 0)/math.max(1,(ply._milDeaths or 1))),
        }
        ply._milNewsText = "/// " .. news[math.random(#news)] .. " ///"
        ply._milNewsTime = CurTime() + 3
    end
    if ply._milNewsTime and CurTime() < ply._milNewsTime then
        local newsW = ScreenScale(100)
        local newsX = ScrW()-newsW-ScreenScale(5)
        local newsY = ScrH()*0.3
        local alpha = math.sin((CurTime()-(ply._milNewsTime-3))/3*math.pi)*180
        draw.RoundedBox(1, newsX, newsY, newsW, ScreenScale(10), Color(20,0,0,alpha*0.8))
        draw.DrawText(ply._milNewsText, "NL_Menu_Tiny", newsX+newsW/2, newsY+2, Color(255,150,150,alpha), TEXT_ALIGN_CENTER)
    end
    
    local oldColor = color_main
    color_main = Color(255, 50, 50, 220)
    color_glow = Color(200, 30, 30, 80)
    drawHUD(ply, true)
    color_main = oldColor
    color_glow = Color(0, 180, 180, 80)
    
    if IsValid(wep) and wep.Clip1 and wep:Clip1()>=0 then
        surface.SetFont("NLFontDefault")
        local _,bigH = surface.GetTextSize("0")
        drawBigStat(wep:Clip1(),"AMMO",ScrW()*0.9,ScrH()-16-bigH)
    end
    
    if not ply._milBioScanTimer or CurTime()>ply._milBioScanTimer then
        ply._milBioScanTimer = CurTime()+math.Rand(60,120)
        ply._milBioScanTime = CurTime()+16
    end
    if ply._milBioScanTime and CurTime()<ply._milBioScanTime then
        local scanW = ScreenScale(90)
        local scanH = ScreenScale(32)
        local scanX = ScreenScale(10)
        local scanY = ScrH()-ScreenScale(95)
        local elapsed = 16-(ply._milBioScanTime-CurTime())
        local alpha = 255
        if elapsed<0.5 then alpha=(elapsed/0.5)*255 elseif elapsed>15.5 then alpha=(1-(elapsed-15.5)/0.5)*255 end
        alpha = math.Clamp(alpha,0,255)
        local gx=0; if math.random(100)<=10 then gx=math.random(-2,2) end
        
        draw.RoundedBox(2,scanX+gx,scanY,scanW,scanH,Color(0,5,15,alpha*0.75))
        draw.RoundedBox(2,scanX+gx,scanY,scanW,1,Color(255,100,100,alpha*0.5))
        surface.SetDrawColor(255,100,100,alpha*0.5)
        surface.DrawRect(scanX+gx,scanY,2,scanH)
        surface.DrawRect(scanX+scanW-2+gx,scanY,2,scanH)
        local scanLine=math.sin(CurTime()*12)*scanW*0.35+scanW*0.5
        surface.SetDrawColor(255,100,100,alpha*0.3)
        surface.DrawRect(scanX+scanLine+gx,scanY,1,scanH)
        
        if elapsed<6 then
            draw.DrawText("BIOMETRIC SCAN","NL_Menu_Tiny",scanX+6+gx,scanY+5,Color(255,100,100,alpha),TEXT_ALIGN_LEFT)
            draw.DrawText("ANALYZING...","NL_Menu_Tiny",scanX+6+gx,scanY+20,Color(255,100,100,alpha*0.7),TEXT_ALIGN_LEFT)
        else
            local pulse=ply.organism and ply.organism.heartbeat or 70
            local stamina=ply.organism and ply.organism.stamina and ply.organism.stamina[1] or 180
            local pain=ply.organism and ply.organism.pain or 0
            local adr=ply.organism and ply.organism.adrenaline or 0
            draw.DrawText("SCAN COMPLETE","NL_Menu_Tiny",scanX+6+gx,scanY+5,Color(255,200,100,alpha),TEXT_ALIGN_LEFT)
            draw.DrawText("BLOOD:"..math.Round(blood/50).."% PULSE:"..math.Round(pulse),"NL_Menu_Tiny",scanX+6+gx,scanY+20,Color(255,200,100,alpha*0.8),TEXT_ALIGN_LEFT)
            draw.DrawText("STAM:"..math.Round(stamina).." PAIN:"..math.Round(pain).." ADR:"..string.format("%.1f",adr),"NL_Menu_Tiny",scanX+6+gx,scanY+35,Color(255,200,100,alpha*0.7),TEXT_ALIGN_LEFT)
        end
    end
    
    if not ply._milAreaScanTimer or CurTime()>ply._milAreaScanTimer then
        ply._milAreaScanTimer = CurTime()+math.Rand(60,120)
        ply._milAreaScanTime = CurTime()+6
    end
    if ply._milAreaScanTime and CurTime()<ply._milAreaScanTime then
        local scanW = ScreenScale(90)
        local scanH = ScreenScale(10)
        local scanX = ScreenScale(10)
        local scanY = ScrH()-ScreenScale(115)
        local elapsed = 6-(ply._milAreaScanTime-CurTime())
        local alpha = 255
        if elapsed<0.3 then alpha=(elapsed/0.3)*255 elseif elapsed>5.7 then alpha=(1-(elapsed-5.7)/0.3)*255 end
        alpha = math.Clamp(alpha,0,255)
        local playersNearby, npcsNearby = 0,0
        for _,ent in ipairs(ents.FindInSphere(ply:EyePos(),2000)) do
            if ent==ply then continue end
            if ent:IsPlayer() and ent:Alive() then playersNearby=playersNearby+1 end
            if ent:IsNPC() and ent:Alive() then npcsNearby=npcsNearby+1 end
        end
        draw.RoundedBox(2,scanX,scanY,scanW,scanH,Color(20,0,0,alpha*0.8))
        draw.RoundedBox(2,scanX,scanY,scanW,1,Color(255,100,100,alpha*0.5))
        draw.DrawText("AREA: "..playersNearby.." HOSTILES, "..npcsNearby.." ENTITIES","NL_Menu_Tiny",scanX+4,scanY+2,Color(255,100,100,alpha),TEXT_ALIGN_LEFT)
    end
end)

hook.Add("RenderScreenspaceEffects", "implant_neurolink_militaryplus", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_neurolink_militaryplus") then return end
    
    if not ply._milpInit then
        ply._milpInit = true
        ply._milpUserID = "GHOST_" .. math.random(100, 999)
        ply._milpBioScanTimer = CurTime() + math.Rand(60, 120)
        ply._milpAreaScanTimer = CurTime() + math.Rand(30, 60)
        ply._milpReportTimer = CurTime() + 2
        ply._milpEntitiesNearby = {}
        ply._milpKills = 0
        ply._milpReportHistory = {}
        ply._milpReportLines = {}
    end
    
    if ply.organism and ply.BerserkKills then ply._milpKills = ply.BerserkKills end
    
    local blood = ply.organism and ply.organism.blood or 5000
    local wep = ply:GetActiveWeapon()
    local ammo = 0
    if IsValid(wep) and wep.Clip1 then ammo = wep:Clip1() end
    local eyePos = ply:EyePos()
    local pulse = ply.organism and ply.organism.heartbeat or 70
    
    if blood/5000 < 0.3 then draw.DrawText("LOW BLOOD", "NL_Menu_Sub", ScrW()*0.5, ScrH()*0.7, Color(255,200,50,math.sin(CurTime()*8)*100+155), TEXT_ALIGN_CENTER) end
    if ammo <= 5 and ammo >= 0 then draw.DrawText("LOW AMMO: "..ammo, "NL_Menu_Tiny", ScrW()*0.5, ScrH()*0.75, Color(255,200,50,200), TEXT_ALIGN_CENTER) end
    
    surface.SetDrawColor(0,0,0,10)
    for i=0,ScrH(),6 do surface.DrawRect(0,i,ScrW(),1) end
    
    draw.DrawText("NEUROLINK MILITARY+", "NL_Menu_Tiny", ScrW()-ScreenScale(8), ScrH()-ScreenScale(24), Color(255,200,50,60), TEXT_ALIGN_RIGHT)
    draw.DrawText("GHOSTSHELL v4.2 | "..ply._milpUserID, "NL_Menu_Tiny", ScrW()-ScreenScale(8), ScrH()-ScreenScale(16), Color(255,200,50,45), TEXT_ALIGN_RIGHT)
    draw.DrawText("KILLS: "..(ply._milpKills or 0).." | EFF: "..string.format("%.1f",(ply._milpKills or 0)/math.max(1,(ply._milpDeaths or 1))), "NL_Menu_Tiny", ScreenScale(10), ScrH()-ScreenScale(8), Color(255,200,50,60), TEXT_ALIGN_LEFT)
    
    local radarX, radarY, radarSize = ScrW()-ScreenScale(70), ScreenScale(15), ScreenScale(55)
    local radarCenter = radarSize/2
    draw.RoundedBox(99,radarX,radarY,radarSize,radarSize,Color(0,5,0,180))
    draw.RoundedBox(99,radarX,radarY,radarSize,radarSize,Color(0,255,0,40))
    surface.SetDrawColor(0,255,0,15)
    surface.DrawLine(radarX+radarCenter,radarY,radarX+radarCenter,radarY+radarSize)
    surface.DrawLine(radarX,radarY+radarCenter,radarX+radarSize,radarY+radarCenter)
    local eyeAng = ply:EyeAngles().y
    for _,ent in ipairs(ents.FindInSphere(eyePos,1500)) do
        if ent==ply then continue end
        if not ent:Alive() and ent:IsPlayer() then continue end
        local delta = ent:GetPos()-eyePos
        local dist = delta:Length()
        local angle = math.deg(math.atan2(delta.y,delta.x))-eyeAng
        local radarDist = (dist/1500)*radarCenter
        local rx = radarX+radarCenter+math.sin(math.rad(angle))*radarDist
        local ry = radarY+radarCenter-math.cos(math.rad(angle))*radarDist
        if radarDist<=radarCenter then
            local color
            if ent:IsPlayer() then color=Color(255,50,50,200)
            elseif ent:IsNPC() then color=Color(255,150,50,200)
            elseif ent:IsWeapon() then color=Color(255,255,0,150) end
            if color then draw.RoundedBox(99,rx-1.5,ry-1.5,3,3,color) end
        end
    end
    draw.RoundedBox(99,radarX+radarCenter-2,radarY+radarCenter-2,4,4,Color(255,255,255,255))
    draw.RoundedBox(99,radarX+radarCenter,radarY+radarCenter-6,2,6,Color(255,255,255,150))
    
    if not ply._milpReportTimer or CurTime()>ply._milpReportTimer then
        ply._milpReportTimer = CurTime()+math.Rand(1.5,4)
        local now = CurTime()
        local lines = {
            "┌─ SYS.DIAG ──────────────┐",
            "│ CPU: "..math.random(22,45).."%  TEMP: "..math.random(38,52).."°C  │",
            "│ RAM: "..math.random(40,85).."%  FAN: "..math.random(2000,4000).."RPM │",
            "│ PWR: "..math.random(85,99).."%  VLT: 12."..math.random(1,9).."V  │",
            "│ NET: ENCRYPTED │ RELAY: 3 │",
            "│ BIO: HR "..math.Round(pulse).." │ BP: "..math.random(110,140).."/"..math.random(70,90).." │",
            "│ AM: "..ammo.." RDS │ WPN: ACTIVE │",
            "│ POS: "..math.random(10,99).."-"..math.random(10,99).." │ ELEV: "..math.Round(ply:GetPos().z/39.37).."M │",
            "│ TAC: "..(ply._milpAreaScanPlayers or 0).." CONTACTS IN AO │",
            "│ OPT: 0.02MM │ SENS: ACTIVE │",
            "├─ LOG ────────────────────┤",
            "│ "..os.date("%H:%M:%S").." SYS:ALL NOMINAL    │",
            "│ "..os.date("%H:%M:%S",now-20).." NET:HANDSHAKE OK │",
            "│ "..os.date("%H:%M:%S",now-45).." BIO:SCAN PASSED  │",
            "│ "..os.date("%H:%M:%S",now-90).." TAC:AO CLEAR     │",
            "└──────────────────────────┘",
        }
        ply._milpReportLines = lines
        ply._milpReportTime = CurTime()+3
    end
    
    if ply._milpReportLines then
        local repX = ScrW()-ScreenScale(115)
        local repY = ScrH()*0.35
        for i,line in ipairs(ply._milpReportLines) do
            draw.DrawText(line, "NL_Menu_Tiny", repX, repY+(i-1)*ScreenScale(7), Color(0,255,100,200-i*2), TEXT_ALIGN_LEFT)
        end
    end
    
    local currentEntities = {}
    for _,ent in ipairs(ents.FindInSphere(eyePos,1000)) do
        if ent==ply then continue end
        if ent:IsPlayer() and ent:Alive() then currentEntities[ent:EntIndex()]={name=ent:Nick(),type="PLAYER",dist=math.Round(eyePos:Distance(ent:GetPos())/39.37)}
        elseif ent:IsNPC() and ent:Alive() then currentEntities[ent:EntIndex()]={name=ent:GetClass(),type="NPC",dist=math.Round(eyePos:Distance(ent:GetPos())/39.37)} end
    end
    for id,data in pairs(currentEntities) do
        if not ply._milpEntitiesNearby[id] then
            ply._milpAlertText = (data.type=="PLAYER" and "HOSTILE" or "CONTACT")..": "..data.name.." AT "..data.dist.."M"
            ply._milpAlertTime = CurTime()+3
        end
    end
    ply._milpEntitiesNearby = currentEntities
    if ply._milpAlertTime and CurTime()<ply._milpAlertTime then
        local alpha=math.sin((CurTime()-(ply._milpAlertTime-3))/3*math.pi)*200
        draw.DrawText(ply._milpAlertText or "","NL_Menu_Tiny",ScrW()*0.5,ScreenScale(65),Color(255,150,100,alpha),TEXT_ALIGN_CENTER)
    end
    
    if not ply._milpBioScanTimer or CurTime()>ply._milpBioScanTimer then
        ply._milpBioScanTimer=CurTime()+math.Rand(60,120)
        ply._milpBioScanTime=CurTime()+16
    end
    if ply._milpBioScanTime and CurTime()<ply._milpBioScanTime then
        local scanW=ScreenScale(90)
        local scanH=ScreenScale(32)
        local scanX=ScreenScale(10)
        local scanY=ScrH()-ScreenScale(95)
        local elapsed=16-(ply._milpBioScanTime-CurTime())
        local alpha=255
        if elapsed<0.5 then alpha=(elapsed/0.5)*255 elseif elapsed>15.5 then alpha=(1-(elapsed-15.5)/0.5)*255 end
        alpha=math.Clamp(alpha,0,255)
        local gx=0; if math.random(100)<=10 then gx=math.random(-2,2) end
        draw.RoundedBox(2,scanX+gx,scanY,scanW,scanH,Color(0,5,15,alpha*0.75))
        draw.RoundedBox(2,scanX+gx,scanY,scanW,1,Color(255,200,50,alpha*0.5))
        surface.SetDrawColor(255,200,50,alpha*0.5)
        surface.DrawRect(scanX+gx,scanY,2,scanH)
        surface.DrawRect(scanX+scanW-2+gx,scanY,2,scanH)
        local scanLine=math.sin(CurTime()*12)*scanW*0.35+scanW*0.5
        surface.SetDrawColor(255,200,50,alpha*0.3)
        surface.DrawRect(scanX+scanLine+gx,scanY,1,scanH)
        if elapsed<6 then
            draw.DrawText("BIOMETRIC SCAN","NL_Menu_Tiny",scanX+6+gx,scanY+5,Color(255,200,50,alpha),TEXT_ALIGN_LEFT)
            draw.DrawText("ANALYZING...","NL_Menu_Tiny",scanX+6+gx,scanY+20,Color(255,200,50,alpha*0.7),TEXT_ALIGN_LEFT)
        else
            local stamina=ply.organism and ply.organism.stamina and ply.organism.stamina[1] or 180
            local pain=ply.organism and ply.organism.pain or 0
            local adr=ply.organism and ply.organism.adrenaline or 0
            draw.DrawText("SCAN COMPLETE","NL_Menu_Tiny",scanX+6+gx,scanY+5,Color(255,255,100,alpha),TEXT_ALIGN_LEFT)
            draw.DrawText("BLOOD:"..math.Round(blood/50).."% PULSE:"..math.Round(pulse),"NL_Menu_Tiny",scanX+6+gx,scanY+20,Color(255,255,100,alpha*0.8),TEXT_ALIGN_LEFT)
            draw.DrawText("STAM:"..math.Round(stamina).." PAIN:"..math.Round(pain).." ADR:"..string.format("%.1f",adr),"NL_Menu_Tiny",scanX+6+gx,scanY+35,Color(255,255,100,alpha*0.7),TEXT_ALIGN_LEFT)
        end
    end
    
    if not ply._milpAreaScanTimer or CurTime()>ply._milpAreaScanTimer then
        ply._milpAreaScanTimer=CurTime()+math.Rand(60,120)
        ply._milpAreaScanTime=CurTime()+6
    end
    if ply._milpAreaScanTime and CurTime()<ply._milpAreaScanTime then
        local scanW=ScreenScale(90)
        local scanH=ScreenScale(10)
        local scanX=ScreenScale(10)
        local scanY=ScrH()-ScreenScale(115)
        local elapsed=6-(ply._milpAreaScanTime-CurTime())
        local alpha=255
        if elapsed<0.3 then alpha=(elapsed/0.3)*255 elseif elapsed>5.7 then alpha=(1-(elapsed-5.7)/0.3)*255 end
        alpha=math.Clamp(alpha,0,255)
        local playersNearby,npcsNearby=0,0
        for _,ent in ipairs(ents.FindInSphere(eyePos,2000)) do
            if ent==ply then continue end
            if ent:IsPlayer() and ent:Alive() then playersNearby=playersNearby+1 end
            if ent:IsNPC() and ent:Alive() then npcsNearby=npcsNearby+1 end
        end
        ply._milpAreaScanPlayers = playersNearby
        draw.RoundedBox(2,scanX,scanY,scanW,scanH,Color(20,15,0,alpha*0.8))
        draw.RoundedBox(2,scanX,scanY,scanW,1,Color(255,200,50,alpha*0.5))
        draw.DrawText("AREA: "..playersNearby.." HOSTILES, "..npcsNearby.." ENTITIES","NL_Menu_Tiny",scanX+4,scanY+2,Color(255,200,50,alpha),TEXT_ALIGN_LEFT)
    end
    
    local oldColor=color_main; local oldGlow=color_glow
    color_main=Color(255,200,50,220); color_glow=Color(200,150,30,80)
    drawHUD(ply,true)
    color_main=oldColor; color_glow=oldGlow
    
    if IsValid(wep) and wep.Clip1 and wep:Clip1()>=0 then
        surface.SetFont("NLFontDefault")
        local _,bigH=surface.GetTextSize("0")
        drawBigStat(wep:Clip1(),"AMMO",ScrW()*0.9,ScrH()-16-bigH)
    end
    
    if nvg_enabled then
        local hasThermal=ply:GetNetVar("implant_thermal")
        local modeText=(hasThermal and thermalMode) and "THERMAL" or "NVG"
        local modeColor=(hasThermal and thermalMode) and Color(255,150,50,255) or color_main
        draw.DrawText(modeText,"NLFontSmall",ScrW()*0.5,ScrH()*0.02,modeColor,TEXT_ALIGN_CENTER)
    end
    
    if IsValid(wep) and wep.GetTrace then
        local tr=wep:GetTrace(true)
        if tr and tr.HitPos then
            local screen=tr.HitPos:ToScreen()
            if screen and screen.visible then pos_sight=LerpVector(FrameTime()*5,pos_sight,Vector(screen.x,screen.y,0)) end
        end
        draw.RoundedBox(0,pos_sight.x-1,pos_sight.y+2,2,6,color_main)
        draw.RoundedBox(0,pos_sight.x-1,pos_sight.y-8,2,6,color_main)
        draw.RoundedBox(0,pos_sight.x+2,pos_sight.y-1,6,2,color_main)
        draw.RoundedBox(0,pos_sight.x-8,pos_sight.y-1,6,2,color_main)
    end
end)

local compass_font_created = false
if not compass_font_created then
    surface.CreateFont("NL_Compass", {
        font = "Bahnschrift",
        size = ScreenScale(5),
        weight = 400,
        extended = true,
        antialias = true,
    })
    compass_font_created = true
end

local COMPASS_DIRS = {
    { label = "N",   ang = 0   },
    { label = "NE",  ang = 45  },
    { label = "E",   ang = 90  },
    { label = "SE",  ang = 135 },
    { label = "S",   ang = 180 },
    { label = "SW",  ang = 225 },
    { label = "W",   ang = 270 },
    { label = "NW",  ang = 315 },
}

local function drawCompass(ply, tier)
    local sw, sh = ScrW(), ScrH()
    local barW = sw * 0.4
    local barH = ScreenScale(8)
    local barX = sw * 0.5 - barW * 0.5
    local barY = ScreenScale(6)

    draw.RoundedBox(2, barX, barY, barW, barH, Color(0, 0, 0, 120))

    surface.SetDrawColor(color_main)
    surface.DrawLine(barX, barY, barX + barW, barY)
    surface.DrawLine(barX, barY + barH, barX + barW, barY + barH)

    surface.SetDrawColor(0, 230, 230, 8)
    for i = 0, barH, 2 do
        surface.DrawLine(barX, barY + i, barX + barW, barY + i)
    end

    local yaw = ply:EyeAngles().y
    yaw = ((-yaw) % 360)

    for _, dir in ipairs(COMPASS_DIRS) do
        local delta = (dir.ang - yaw + 540) % 360 - 180
        if math.abs(delta) < 90 then
            local frac = delta / 90
            local x = barX + barW * 0.5 + frac * barW * 0.5
            local isCardinal = dir.label == "N" or dir.label == "S" or dir.label == "E" or dir.label == "W"
            local col = isCardinal and color_main or color_glow
            local h = isCardinal and barH or barH * 0.5

            surface.SetDrawColor(col)
            surface.DrawLine(x, barY, x, barY + h)

            draw.DrawText(dir.label, "NL_Compass",
                x, barY + barH + 2,
                col, TEXT_ALIGN_CENTER)
        end
    end

    surface.SetDrawColor(color_main)
    surface.DrawLine(sw * 0.5, barY - 3, sw * 0.5, barY + barH + 3)

    if tier >= 2 then
        local eyePos = ply:EyePos()
        local range = tier == 3 and 2000 or 800

        for _, ent in ipairs(player.GetAll()) do
            if ent == ply then continue end
            if not ent:Alive() then continue end

            local dist = ent:GetPos():Distance(eyePos)
            if dist > range then continue end

            if tier == 2 then
                local tr = util.TraceLine({
                    start = eyePos,
                    endpos = ent:EyePos(),
                    filter = {ply}
                })
                if tr.Entity ~= ent then continue end
            end

            local dir = (ent:GetPos() - eyePos):GetNormalized()
            local entYaw = math.deg(math.atan2(dir.y, dir.x))
            entYaw = ((entYaw + 90) % 360 + 360) % 360

            local delta = (entYaw - yaw + 540) % 360 - 180
            if math.abs(delta) < 90 then
                local frac = delta / 90
                local x = barX + barW * 0.5 + frac * barW * 0.5
                local isEnemy = ent:IsPlayer()
                local dotColor = isEnemy and Color(255, 80, 80, 220) or Color(80, 255, 80, 220)
                draw.RoundedBox(99, x - 2, barY + barH * 0.5 - 2, 4, 4, dotColor)
            end
        end

        for _, ent in ipairs(ents.GetAll()) do
            if not ent:IsNPC() then continue end
            if not ent:Alive() then continue end

            local dist = (ent:GetPos() + Vector(0, 0, 40)):Distance(eyePos)
            if dist > range then continue end

            if tier == 2 then
                local tr = util.TraceLine({
                    start = eyePos,
                    endpos = ent:GetPos(),
                    filter = {ply}
                })
                if tr.Entity ~= ent then continue end
            end

            local dir = (ent:GetPos() + Vector(0, 0, 40) - eyePos)
            dir.z = 0
            dir:Normalize()
            local entYaw = math.deg(math.atan2(dir.y, dir.x))
            entYaw = ((-entYaw + 0) % 360 + 360) % 360

            local delta = (entYaw - yaw + 540) % 360 - 180
            if math.abs(delta) < 90 then
                local frac = delta / 90
                local x = barX + barW * 0.5 + frac * barW * 0.5
                draw.RoundedBox(99, x - 2, barY + barH * 0.5 - 2, 4, 4, Color(255, 165, 0, 220))
            end
        end
    end
end

hook.Add("HUDPaint", "implant_compass", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic", false) or
                         ply:GetNetVar("implant_neurolink_military", false) or
                         ply:GetNetVar("implant_neurolink_militaryplus", false)

    local tier
    if ply:GetNetVar("implant_compass_3", false) then tier = 3
    elseif ply:GetNetVar("implant_compass_2", false) then tier = 2
    elseif ply:GetNetVar("implant_compass_1", false) then tier = 1
    end
    
    if not tier then return end

    drawCompass(ply, tier)
end)

local function ShowImplantBoot()
    vgui.Create("ZC_ImplantLoading")
end

hook.Add("RenderScreenspaceEffects", "Neurolink_CrackRender", function()
    local ply = LocalPlayer()
    if not ply:Alive() then 
        hg.neurocrack = {}
        return 
    end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or 
                     ply:GetNetVar("implant_neurolink_military") or 
                     ply:GetNetVar("implant_neurolink_militaryplus") or
                     ply:GetNetVar("implant_neurolink_scrap") or
                     ply:GetNetVar("implant_neurolink_diy") or
                     ply:GetNetVar("implant_neurolink_blackmarket")
    
    if not hasNeurolink then return end
    if not hg.neurocrack or not hg.neurocrack.intensity then return end
    
    hg.neurocrack.intensity = Lerp(FrameTime() / 30, hg.neurocrack.intensity, 0)
    
    if hg.neurocrack.intensity < 0.001 then
        hg.neurocrack = {}
        return
    end
    
    local intensity = hg.neurocrack.intensity
    
    if math.random(1, 10) <= intensity * 10 then
        surface.SetDrawColor(0, 255, 255, intensity * 80)
        local y = math.random(0, ScrH())
        surface.DrawRect(0, y, ScrW(), math.random(1, 3))
    end
    
    if math.random(1, 15) <= intensity * 15 then
        surface.SetDrawColor(255, 50, 100, intensity * 60)
        local x = math.random(0, ScrW())
        local w = math.random(30, 150)
        surface.DrawRect(x, math.random(0, ScrH()), w, math.random(1, 3))
    end
    
    if ply:GetNetVar("implant_neurolink_militaryplus") and math.random(1, 20) <= intensity * 20 then
        local offsetX = math.random(-5, 5) * intensity
        local offsetY = math.random(-3, 3) * intensity
        surface.SetDrawColor(0, 255, 255, intensity * 30)
        surface.DrawRect(offsetX, offsetY, ScrW(), ScrH())
    end
    
    local CrackMat = Material("effects/shaders/zb_shattered_ps30")
    render.SetMaterial(CrackMat)
    render.UpdateScreenEffectTexture()
    CrackMat:SetFloat("$c0_x", hg.neurocrack.x)
    CrackMat:SetFloat("$c0_y", hg.neurocrack.y)
    CrackMat:SetFloat("$c1_x", 1 - (intensity ^ 0.001))
    CrackMat:SetFloat("$c1_y", 20)
    CrackMat:SetFloat("$c1_z", hg.neurocrack.rnd1)
    CrackMat:SetFloat("$c2_x", hg.neurocrack.rnd2)
    CrackMat:SetFloat("$c2_y", hg.neurocrack.rnd3)
    CrackMat:SetFloat("$c2_z", hg.neurocrack.rnd4)
    render.DrawScreenQuad()
end)

local grenadeWarning = {
    active = false,
    pos = Vector(0, 0, 0),
    alpha = 0,
}

hook.Add("Think", "Neurolink_GrenadeScanner", function()
    local ply = LocalPlayer()
    if not ply:Alive() then 
        grenadeWarning.active = false
        return 
    end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_military") or 
                         ply:GetNetVar("implant_neurolink_militaryplus")
    
    if not hasNeurolink then 
        grenadeWarning.active = false
        return 
    end
    
    local eyePos = ply:EyePos()
    local closestGrenade = nil
    local closestDist = 500
    
    for _, ent in ipairs(ents.FindInSphere(eyePos, closestDist)) do
        local class = ent:GetClass()
        if class == "npc_grenade_frag" or 
           class == "prop_combat_med" or
           class == "proj_grenade" or
           class:find("grenade") or
           class:find("proj") then
            
            local dist = eyePos:Distance(ent:GetPos())
            if dist < closestDist then
                closestDist = dist
                closestGrenade = ent
            end
        end
    end
    
    if IsValid(closestGrenade) then
        grenadeWarning.active = true
        grenadeWarning.pos = closestGrenade:GetPos()
        grenadeWarning.alpha = math.min(255, grenadeWarning.alpha + FrameTime() * 500)
        
        if grenadeWarning.alpha < 10 then
            surface.PlaySound("buttons/combine_button_locked.wav")
        end
    else
        grenadeWarning.active = false
        grenadeWarning.alpha = math.max(0, grenadeWarning.alpha - FrameTime() * 200)
    end
end)

hook.Add("HUDPaint", "Neurolink_GrenadeWarning", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_military") or 
                         ply:GetNetVar("implant_neurolink_militaryplus")
    
    if not hasNeurolink then return end
    if not grenadeWarning.active or grenadeWarning.alpha <= 0 then return end
    
    local screenPos = grenadeWarning.pos:ToScreen()
    if not screenPos.visible then return end
    
    local alpha = grenadeWarning.alpha
    local cx, cy = screenPos.x, screenPos.y
    local size = ScreenScale(12)
    local pulse = math.sin(CurTime() * 5) * 0.3 + 0.7
    
    draw.RoundedBox(99, cx - size * 2, cy - size * 2, size * 4, size * 4, 
        Color(255, 30, 30, alpha * 0.2 * pulse))
    
    local triColor = Color(255, 50 + math.sin(CurTime() * 8) * 50, 50, alpha)
    surface.SetDrawColor(triColor)
    surface.DrawPoly({
        {x = cx, y = cy - size},
        {x = cx - size, y = cy + size * 0.8},
        {x = cx + size, y = cy + size * 0.8},
    })
    
    draw.DrawText("THREAT", "NLFontSmall", cx, cy - size - ScreenScale(14),
        Color(255, 100, 100, alpha), TEXT_ALIGN_CENTER)
    
    local dist = math.Round(ply:GetPos():Distance(grenadeWarning.pos) / 39.37, 1)
    draw.DrawText(dist .. "m", "NLFontSmall", cx, cy + size + ScreenScale(4),
        Color(255, 150, 150, alpha * 0.8), TEXT_ALIGN_CENTER)
    
    if dist < 5 then
        local edgeAlpha = (1 - dist / 5) * alpha * 0.3 * pulse
        surface.SetDrawColor(255, 0, 0, edgeAlpha)
        surface.DrawRect(0, 0, ScrW(), ScreenScale(3))
        surface.DrawRect(0, ScrH() - ScreenScale(3), ScrW(), ScreenScale(3))
        surface.DrawRect(0, 0, ScreenScale(3), ScrH())
        surface.DrawRect(ScrW() - ScreenScale(3), 0, ScreenScale(3), ScrH())
    end
end)

local notifQueue = {}
local notifAlpha = 0
local notifText = ""

hook.Add("HUDPaint", "Neurolink_Notifications", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or 
                         ply:GetNetVar("implant_neurolink_military") or 
                         ply:GetNetVar("implant_neurolink_militaryplus")
    if not hasNeurolink then return end
    
    if #notifQueue > 0 and notifAlpha <= 0 then
        notifText = table.remove(notifQueue, 1)
        notifAlpha = 255
    end
    
    if notifAlpha > 0 then
        notifAlpha = notifAlpha - FrameTime() * 80
        
        local x = ScrW() * 0.5
        local y = ScrH() * 0.15
        
        draw.RoundedBox(2, x - 150, y - 10, 300, 30, Color(15, 3, 6, math.min(200, notifAlpha)))
        draw.RoundedBox(2, x - 150, y - 10, 300, 1, Color(255, 40, 60, notifAlpha))
        draw.RoundedBox(2, x - 150, y + 20, 300, 1, Color(255, 40, 60, notifAlpha * 0.5))
        
        surface.SetDrawColor(255, 40, 60, notifAlpha)
        surface.DrawRect(x - 150, y - 10, 2, 30)
        
        draw.DrawText(notifText, "NL_Menu_Sub", x, y + 2,
            Color(255, 40, 60, notifAlpha), TEXT_ALIGN_CENTER)
    end
end)

local scannerActive = false
local scanAlpha = 0
local scanHoldTime = 0
local SCAN_HOLD_DELAY = 0.3

hook.Add("Think", "Neurolink_Scanner", function()
    local ply = LocalPlayer()
    if not ply:Alive() then
        scannerActive = false
        scanAlpha = 0
        return
    end
    
    local hasScanner = ply:GetNetVar("implant_neurolink_military") or 
                       ply:GetNetVar("implant_neurolink_militaryplus")
    if not hasScanner then
        scannerActive = false
        scanAlpha = 0
        return
    end
    
    if scannerActive then
        scanAlpha = math.min(255, scanAlpha + FrameTime() * 600)
    else
        scanAlpha = math.max(0, scanAlpha - FrameTime() * 400)
    end
end)

concommand.Add("neurolink_scanner", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local hasScanner = ply:GetNetVar("implant_neurolink_military") or 
                       ply:GetNetVar("implant_neurolink_militaryplus")
    if not hasScanner then return end
    
    scannerActive = not scannerActive
    surface.PlaySound("scanner.wav")
end)

local WEAPON_NAMES = {
    ["weapon_glock17"] = "GLOCK 17",
    ["weapon_glock18c"] = "GLOCK 18C",
    ["weapon_glock26"] = "GLOCK 26",
    ["weapon_m1911"] = "M1911",
    ["weapon_deagle"] = "DESERT EAGLE",
    ["weapon_m9beretta"] = "M9 BERETTA",
    ["weapon_cz75"] = "CZ75",
    ["weapon_cz75a"] = "CZ75 AUTO",
    ["weapon_makarov"] = "MAKAROV",
    ["weapon_tokarev"] = "TOKAREV",
    ["weapon_browninghp"] = "BROWNING HP",
    ["weapon_fn45"] = "FN 45",
    ["weapon_pl15"] = "PL-15",
    ["weapon_px4beretta"] = "PX4 BERETTA",
    ["weapon_revolver2"] = "REVOLVER",
    ["weapon_revolver357"] = ".357 REVOLVER",
    ["weapon_osapb"] = "OSA PB",
    ["weapon_tec9"] = "TEC-9",
    ["weapon_p22"] = "P22",
    ["weapon_pm9"] = "PM9",
    ["weapon_zoraki"] = "ZORAKI",
    ["weapon_colt9mm"] = "COLT 9MM",
    
    ["weapon_mp5"] = "MP5",
    ["weapon_mp7"] = "MP7",
    ["weapon_uzi"] = "UZI",
    ["weapon_mac11"] = "MAC-11",
    ["weapon_tmp"] = "TMP",
    ["weapon_skorpion"] = "SKORPION",
    ["weapon_vector"] = "VECTOR",
    ["weapon_p90"] = "P90",
    
    ["weapon_akm"] = "AKM",
    ["weapon_ak74"] = "AK-74",
    ["weapon_ak74u"] = "AKS-74U",
    ["weapon_ak200"] = "AK-200",
    ["weapon_ak203"] = "AK-203",
    ["weapon_ar15"] = "AR-15",
    ["weapon_m16a2"] = "M16A2",
    ["weapon_m4a1"] = "M4A1",
    ["weapon_hk416"] = "HK416",
    ["weapon_sg552"] = "SG552",
    ["weapon_asval"] = "AS VAL",
    ["weapon_sks"] = "SKS",
    ["weapon_mini14"] = "MINI-14",
    ["weapon_ruger"] = "RUGER",
    ["weapon_winchester"] = "WINCHESTER",
    ["weapon_mosin"] = "MOSIN NAGANT",
    ["weapon_kar98"] = "KAR98K",
    ["weapon_svd"] = "SVD",
    ["weapon_sr25"] = "SR-25",
    ["weapon_vpo136"] = "VPO-136",
    ["weapon_vpo209"] = "VPO-209",
    ["weapon_osipr"] = "OSIPR",
    ["weapon_ab10"] = "AB-10",
    ["weapon_ac556"] = "AC-556",
    ["weapon_prdr"] = "PRDR",
    
    ["weapon_remington870"] = "REMINGTON 870",
    ["weapon_spas12"] = "SPAS-12",
    ["weapon_saiga12"] = "SAIGA-12",
    ["weapon_doublebarrel"] = "DOUBLE BARREL",
    ["weapon_toz106"] = "TOZ-106",
    ["weapon_ks23"] = "KS-23",
    ["weapon_m4super"] = "M4 SUPER",
    ["weapon_m590a1"] = "M590A1",
    ["weapon_xm1014"] = "XM1014",
    
    ["weapon_pkm"] = "PKM",
    ["weapon_rpk"] = "RPK",
    ["weapon_m249"] = "M249",
    ["weapon_m60"] = "M60",
    ["weapon_hk21"] = "HK21",
    ["weapon_kord"] = "KORD",
    
    ["weapon_hg_rpg"] = "RPG-7",
    ["weapon_hg_rebelrpg"] = "REBEL RPG",
    ["weapon_hg_crossbow"] = "CROSSBOW",
    ["weapon_breachcharge"] = "BREACH CHARGE",
    ["weapon_claymore"] = "CLAYMORE",
    ["weapon_taser"] = "TASER",
    ["weapon_tranquilizer"] = "TRANQUILIZER",
    
    ["weapon_medkit_sh"] = "MEDKIT",
    ["weapon_bandage_sh"] = "BANDAGE",
    ["weapon_bloodbag"] = "BLOOD BAG",
    ["weapon_tourniquet"] = "TOURNIQUET",
    ["weapon_morphine"] = "MORPHINE",
    ["weapon_adrenaline"] = "ADRENALINE",
    ["weapon_fury13"] = "FURY-13",
    ["weapon_fury16"] = "FURY-16",
    ["weapon_painkillers"] = "PAINKILLERS",
    ["weapon_betablock"] = "BETA BLOCKER",
    ["weapon_naloxone"] = "NALOXONE",
    ["weapon_fentanyl"] = "FENTANYL",
    ["weapon_mannitol"] = "MANNITOL",
    ["weapon_thiamine"] = "THIAMINE",
    
    ["weapon_hg_grenade_tpik"] = "GRENADE",
    ["weapon_hg_flashbang_tpik"] = "FLASHBANG",
    ["weapon_hg_smokemade_tpik"] = "SMOKE GRENADE",
    ["weapon_hg_moloto_v_tpik"] = "MOLOTOV",
    ["weapon_hg_pipebomb_tpik"] = "PIPE BOMB",
    ["weapon_hg_slam"] = "SLAM",
}

local function getWeaponName(class)
    if WEAPON_NAMES[class] then return WEAPON_NAMES[class] end
    local name = class:gsub("weapon_", ""):gsub("hg_", ""):gsub("_tpik", ""):gsub("_sh", ""):upper()
    return name
end

local WEAPON_DESCRIPTIONS = {
    ["weapon_glock17"] = "GLOCK 17\n9mm semi-auto.\nReliable. Standard issue for security forces.",
    ["weapon_glock18c"] = "GLOCK 18C\n9mm full-auto pistol.\nRare. Devastating at close range.",
    ["weapon_glock26"] = "GLOCK 26\n9mm subcompact.\nEasy to conceal. Backup weapon.",
    ["weapon_m1911"] = "M1911\n.45 ACP classic.\nOld but deadly. Stopping power unmatched.",
    ["weapon_deagle"] = "DESERT EAGLE\n.50 AE hand cannon.\nOne shot, one kill. Wrist breaker.",
    ["weapon_m9beretta"] = "M9 BERETTA\n9mm military sidearm.\nStandard NATO issue. Balanced.",
    ["weapon_cz75"] = "CZ75\n9mm Czech engineering.\nAccurate. Popular among mercenaries.",
    ["weapon_cz75a"] = "CZ75 AUTO\n9mm machine pistol.\nFull-auto conversion. Hard to control.",
    ["weapon_makarov"] = "MAKAROV\n9x18mm Soviet relic.\nCheap. Still works after decades.",
    ["weapon_tokarev"] = "TOKAREV\n7.62mm Soviet sidearm.\nFast round. Penetrates basic armor.",
    ["weapon_browninghp"] = "BROWNING HP\n9mm classic.\nHigh capacity for its era. Collector's item.",
    ["weapon_fn45"] = "FN 45\n.45 ACP tactical pistol.\nModern. Silencer-ready.",
    ["weapon_pl15"] = "PL-15\n9mm Russian modern.\nLightweight. Special forces choice.",
    ["weapon_px4beretta"] = "PX4 BERETTA\n9mm rotating barrel.\nReduced recoil. Police favorite.",
    ["weapon_revolver2"] = "REVOLVER\n.38 Special.\nSimple. Never jams. 6 shots.",
    ["weapon_revolver357"] = ".357 REVOLVER\n.357 Magnum.\nStops anything. Slow reload.",
    ["weapon_osapb"] = "OSA PB\n9mm integrally silenced.\nCovert operations. Whisper quiet.",
    ["weapon_tec9"] = "TEC-9\n9mm gangster special.\nCheap. Unreliable but intimidating.",
    ["weapon_p22"] = "P22\n.22 LR plinker.\nSmall caliber. Training weapon.",
    ["weapon_pm9"] = "PM9\n9mm budget pistol.\nAffordable. Gets the job done.",
    ["weapon_zoraki"] = "ZORAKI\nBlank/gas pistol.\nNon-lethal. Scares but won't kill.",
    ["weapon_colt9mm"] = "COLT 9MM\n9mm classic American.\nSimple. Reliable. Old school.",
    
    ["weapon_mp5"] = "MP5\n9mm legendary SMG.\nPrecision. SWAT teams worldwide.",
    ["weapon_mp7"] = "MP7\n4.6mm PDW.\nCompact. Penetrates body armor.",
    ["weapon_uzi"] = "UZI\n9mm Israeli SMG.\nCompact but heavy recoil.",
    ["weapon_mac11"] = "MAC-11\n.380 ACP bullet hose.\nExtreme fire rate. Empty in seconds.",
    ["weapon_tmp"] = "TMP\n9mm compact SMG.\nLight. Good for vehicle crews.",
    ["weapon_skorpion"] = "SKORPION\n.32 ACP Czech SMG.\nTiny. Tank crews loved it.",
    ["weapon_vector"] = "VECTOR\n.45 ACP modern SMG.\nRecoil mitigation system. Laser beam.",
    ["weapon_p90"] = "P90\n5.7mm bullpup PDW.\n50-round mag. Armor piercing.",
    
    ["weapon_akm"] = "AKM\n7.62mm Soviet workhorse.\nIndestructible. Every insurgent's dream.",
    ["weapon_ak74"] = "AK-74\n5.45mm Soviet evolution.\nLighter round. Less recoil than AKM.",
    ["weapon_ak74u"] = "AKS-74U\n5.45mm compact carbine.\nCQB monster. Loud as hell.",
    ["weapon_ak200"] = "AK-200\n5.45mm modern AK.\nPicatinny rails. 21st century AK.",
    ["weapon_ak203"] = "AK-203\n7.62mm modern AK.\nUpdated classic. Hits harder.",
    ["weapon_ar15"] = "AR-15\n5.56mm civilian rifle.\nCustomizable. America's rifle.",
    ["weapon_m16a2"] = "M16A2\n5.56mm military rifle.\n3-round burst. Vietnam veteran.",
    ["weapon_m4a1"] = "M4A1\n5.56mm carbine.\nFull-auto. Special ops standard.",
    ["weapon_hk416"] = "HK416\n5.56mm German engineering.\nKilled Bin Laden. Reliable piston.",
    ["weapon_sg552"] = "SG552\n5.56mm Swiss precision.\nCompact. Commando favorite.",
    ["weapon_asval"] = "AS VAL\n9x39mm integrally silenced.\nSpetsnaz choice. Subsonic death.",
    ["weapon_sks"] = "SKS\n7.62mm Soviet semi-auto.\nOld but gold. Stripper clips.",
    ["weapon_mini14"] = "MINI-14\n5.56mm ranch rifle.\nFudd gun. Actually decent.",
    ["weapon_ruger"] = "RUGER\n.22 LR target rifle.\nPlinking. Small game hunting.",
    ["weapon_winchester"] = "WINCHESTER\n.44 lever action.\nCowboy classic. 12 rounds of Yee-Haw.",
    ["weapon_mosin"] = "MOSIN NAGANT\n7.62x54R bolt action.\n120 years old. Still kills fascists.",
    ["weapon_kar98"] = "KAR98K\n7.92mm Mauser action.\nGerman sniper's tool. Smooth bolt.",
    ["weapon_svd"] = "SVD\n7.62x54R Dragunov.\nSoviet marksman rifle. Semi-auto sniper.",
    ["weapon_sr25"] = "SR-25\n7.62mm NATO DMR.\nAccurate. Long range precision.",
    ["weapon_vpo136"] = "VPO-136\n7.62mm civilian AK.\nSemi-auto only. Legal in most zones.",
    ["weapon_vpo209"] = "VPO-209\n.366 TKM civilian.\nWeird caliber. Russian loophole gun.",
    ["weapon_osipr"] = "OSIPR\nFictional pulse rifle.\nPrototype. Unreliable but cool.",
    ["weapon_ab10"] = "AB-10\n9mm budget carbine.\nPoor man's MP5. Works.",
    ["weapon_ac556"] = "AC-556\n.223 selective fire.\nMini-14's military brother.",
    ["weapon_prdr"] = "PRDR\nExperimental rifle.\nUnknown origin. High tech.",
    
    ["weapon_remington870"] = "REMINGTON 870\n12 gauge pump action.\nIconic. Breaches doors.",
    ["weapon_spas12"] = "SPAS-12\n12 gauge semi/pump.\nJurassic Park gun. Heavy.",
    ["weapon_saiga12"] = "SAIGA-12\n12 gauge AK shotgun.\nMag-fed. Room clearer.",
    ["weapon_doublebarrel"] = "DOUBLE BARREL\n12 gauge side-by-side.\nGrandpa's boomstick. 2 shots.",
    ["weapon_toz106"] = "TOZ-106\n20 gauge bolt-action.\nWeird Russian thing. Cheap.",
    ["weapon_ks23"] = "KS-23\n23mm riot shotgun.\nFires tear gas. Massive bore.",
    ["weapon_m4super"] = "M4 SUPER\n12 gauge semi-auto.\nBenelli quality. Fast cycling.",
    ["weapon_m590a1"] = "M590A1\n12 gauge military pump.\nHeavy barrel. Bayonet lug.",
    ["weapon_xm1014"] = "XM1014\n12 gauge semi-auto.\nMilitary issue. Reliable.",
    
    ["weapon_pkm"] = "PKM\n7.62mm Soviet MG.\nBelt-fed beast. Suppressing fire.",
    ["weapon_rpk"] = "RPK\n7.62mm AK-based LMG.\nBigger barrel. Drum mag.",
    ["weapon_m249"] = "M249\n5.56mm SAW.\nSquad support. Belt or mag.",
    ["weapon_m60"] = "M60\n7.62mm American MG.\nRambo's favorite. Heavy hitter.",
    ["weapon_hk21"] = "HK21\n7.62mm German MG.\nG3-based. Accurate fire.",
    ["weapon_kord"] = "KORD\n12.7mm heavy MG.\nAnti-material. Mounted only.",
    
    ["weapon_hg_rpg"] = "RPG-7\nRocket propelled grenade.\nAnti-tank. Backblast dangerous.",
    ["weapon_hg_rebelrpg"] = "REBEL RPG\nImprovised launcher.\nLess accurate. Still explodes.",
    ["weapon_hg_crossbow"] = "CROSSBOW\nSilent ranged weapon.\nMedieval but effective.",
    ["weapon_taser"] = "TASER\nElectroshock weapon.\nNon-lethal. Incapacitates.",
    ["weapon_tranquilizer"] = "TRANQUILIZER\nDart gun.\nPuts targets to sleep. Slow acting.",
    ["weapon_breachcharge"] = "BREACH CHARGE\nDoor breaching explosive.\nEntry team essential.",
    ["weapon_claymore"] = "CLAYMORE\nDirectional anti-personnel mine.\nFront toward enemy.",
    
    ["weapon_medkit_sh"] = "MEDKIT\nTrauma kit.\nStops bleeding. Field surgery.",
    ["weapon_bandage_sh"] = "BANDAGE\nSterile dressing.\nBasic wound care.",
    ["weapon_bloodbag"] = "BLOOD BAG\nIV transfusion.\nRestores blood volume. Universal donor.",
    ["weapon_tourniquet"] = "TOURNIQUET\nEmergency bleed control.\nStops arterial bleeding. Use fast.",
    ["weapon_morphine"] = "MORPHINE\nPain management.\nStrong analgesic. Addictive.",
    ["weapon_adrenaline"] = "ADRENALINE\nEmergency stimulant.\nRestarts heart. Fight response.",
    ["weapon_fury13"] = "FURY-13\nCombat stimulant.\nBerserker compound. Dangerous.",
    ["weapon_fury16"] = "FURY-16\nCombat stimulant.\nNoradrenaline surge. Cold rage.",
    ["weapon_painkillers"] = "PAINKILLERS\nMild analgesic.\nReduces pain. Non-addictive.",
    ["weapon_betablock"] = "BETA BLOCKER\nCardiac stabilizer.\nSteadies heart rate. Reduces tremor.",
    ["weapon_naloxone"] = "NALOXONE\nOpioid antagonist.\nReverses overdoses. Narcan.",
    ["weapon_fentanyl"] = "FENTANYL\nExtreme painkiller.\nMilitary grade. Micrograms kill.",
    ["weapon_mannitol"] = "MANNITOL\nBrain swelling reducer.\nTreats head trauma. Osmotic.",
    ["weapon_thiamine"] = "THIAMINE\nVitamin B1 supplement.\nPrevents brain damage. Alcoholics need.",
    
    ["weapon_hg_grenade_tpik"] = "GRENADE\nFragmentation grenade.\n5 second fuse. Take cover.",
    ["weapon_hg_flashbang_tpik"] = "FLASHBANG\nNon-lethal grenade.\nBlinds and deafens. Breach rooms.",
    ["weapon_hg_smokemade_tpik"] = "SMOKE GRENADE\nVisual obscuration.\nConceals movement. Signal use.",
    ["weapon_hg_moloto_v_tpik"] = "MOLOTOV\nImprovised incendiary.\nBurns everything. DIY weapon.",
    ["weapon_hg_pipebomb_tpik"] = "PIPE BOMB\nImprovised explosive.\nNails and gunpowder. Shrapnel.",
    ["weapon_hg_slam"] = "SLAM\nSelectable Lightweight Attack Munition.\nMulti-mode mine. Versatile.",
    
    ["weapon_hg_f1_tpik"] = "F1 GRENADE\nSoviet fragmentation.\nHeavy. Defensive use.",
    ["weapon_hg_rgd_tpik"] = "RGD-5 GRENADE\nSoviet offensive.\nLighter. Throw further.",
    ["weapon_hg_type59_tpik"] = "TYPE 59 GRENADE\nChinese frag.\nCheap mass-produced. Works.",
    ["weapon_hg_h2nade_tpik"] = "H2 GRENADE\nExperimental.\nUnknown effects. Handle with care.",
    
    ["weapon_bat"] = "BASEBALL BAT\nSporting goods.\nBlunt force trauma. Classic.",
    ["weapon_hatchet"] = "HATCHET\nSmall axe.\nChops wood and bone.",
    ["weapon_hg_axe"] = "FIRE AXE\nFull size axe.\nBreaches doors. Heavy swing.",
    ["weapon_hg_crowbar"] = "CROWBAR\nGordon Freeman's choice.\nOpens crates. Breaks skulls.",
    ["weapon_hg_sledgehammer"] = "SLEDGEHAMMER\nHeavy blunt.\nOne swing. Lights out.",
    ["weapon_hg_machete"] = "MACHETE\nLarge blade.\nCuts vegetation. Cuts people.",
    ["weapon_hg_shovel"] = "SHOVEL\nTrench tool.\nDigs graves. Fills them.",
    ["weapon_hg_spear"] = "SPEAR\nPointed stick.\nKeep distance. Primitive.",
    ["weapon_hg_stunstick"] = "STUNSTICK\nCombine issue.\nShocks targets. Non-lethal.",
    ["weapon_leadpipe"] = "LEAD PIPE\nHeavy metal.\nCommon street weapon.",
    ["weapon_chair_leg"] = "CHAIR LEG\nImprovised club.\nBar fight special.",
    ["weapon_brick"] = "BRICK\nConstruction debris.\nThrown or swung. Disposable.",
    ["weapon_hammer"] = "HAMMER\nTool.\nBlunt. Can also build things.",
    ["weapon_pocketknife"] = "POCKET KNIFE\nSmall blade.\nUtility. Last resort weapon.",
    ["weapon_ducttape"] = "DUCT TAPE\nNot a weapon.\nFixes everything. Including wounds.",
    ["weapon_pan"] = "PAN\nCooking utensil.\nPUBG legend. Clang.",
}

local function getWeaponDescription(class)
    return WEAPON_DESCRIPTIONS[class] or "UNKNOWN ITEM\nNo data available.\nScan incomplete."
end

local SCAN_DESCRIPTIONS = {
    ["npc_combine_s"] = "DANGER\nElite unit. Deadly accuracy.\nHeavy armor. Approach with caution.",
    ["npc_combine_e"] = "COMBINE ELITE\nShock trooper. Extremely dangerous.\nFull combat implants detected.",
    ["npc_metropolice"] = "Beat Cop\nStandard patrol unit.\nLight armor. Stunstick equipped.",
    ["npc_combine_camera"] = "COMBINE CAMERA\nSurveillance device.\nAlerts nearby units when triggered.",
    ["npc_turret_floor"] = "COMBINE TURRET\nAutomated defense system.\nHigh rate of fire. Vulnerable to grenades.",
    ["npc_manhack"] = "MANHACK\nFlying sawblade drone.\nFast but fragile. Melee only.",
    ["npc_scanner"] = "CITY SCANNER\nReconnaissance drone.\nTakes photos, drops mines.",
    ["npc_strider"] = "STRIDER\nHeavy assault synth.\nWarp cannon. Near unstoppable.",
    ["npc_helicopter"] = "HUNTER-CHOPPER\nAir superiority gunship.\nMinigun and rockets.",
    ["npc_rollermine"] = "ROLLERMINE\nProximity mine on wheels.\nShocks nearby targets.",
    ["npc_zombie"] = "SAVAGE\nINFECTED PERSON\nDANGEROUS. Fire effective.",
    ["npc_fastzombie"] = "SKINNED\nRAPID SAVAGE\nClimbs walls. Stay mobile.",
    ["npc_poisonzombie"] = "TOXIC SAVAGE\nCARRIES ROT SPORES.\nThrows poisonous parasites. Keep distance.",
    ["npc_headcrab"] = "HEADCRAB\nPARASITIC LIFEFORM.\nAttaches to one's head. If attached chances of survival are Zero.",
    ["npc_headcrab_black"] = "TOXIC HEADCRAB\nEVOLVED PARASITIC LIFEFORM\nInjects toxins when attached. Chances of survival: Zero.",
    ["npc_headcrab_fast"] = "FAST HEADCRAB\nFAST PARASITIC LIFEFORM\nAttaches to one's head, extremely fast. Survival: Zero.",
    ["npc_antlion"] = "ANTLION\nInsectoid predator. Burrows underground.\nSensitive to vibration.",
    ["npc_antlionguard"] = "ANTLION GUARD\nAlpha variant. Massive size.\nCharges at targets. Explosives advised.",
    ["npc_citizen"] = "CITIZEN\nCivilian.\nA registered citizen of some legal settlement.",
    ["npc_barney"] = "CITIZEN\nArmed civilian.\nA citizen with light augmentations.",
    ["item_healthkit"] = "HEALTH KIT\nRestores minor injuries.\nSingle use.",
    ["item_healthvial"] = "HEALTH VIAL\nQuick healing stim.\nMinor blood restoration.",
    ["item_ammo_pistol"] = "PISTOL AMMO\nStandard caliber rounds.\n9mm, 12 rounds.",
    ["item_ammo_smg1"] = "SMG AMMO\nMedium caliber rounds.\n30 round magazine.",
    ["item_box_buckshot"] = "SHOTGUN SHELLS\n12 gauge buckshot.\n6 shells per box.",
    ["prop_physics"] = "PHYSICS OBJECT\nMovable debris. Can be used\nas cover or thrown.",
}

local NPC_NAMES = {
    ["npc_combine_s"] = "SOLDIER",
    ["npc_combine_e"] = "ELITE SOLDIER",
    ["npc_metropolice"] = "BEAT COP",
    ["npc_combine_camera"] = "CAMERA",
    ["npc_turret_floor"] = "TURRET",
    ["npc_manhack"] = "MANHACK",
    ["npc_scanner"] = "SCANNER",
    ["npc_strider"] = "STRIDER",
    ["npc_helicopter"] = "GUNSHIP",
    ["npc_rollermine"] = "ROLLERMINE",
    ["npc_zombie"] = "SAVAGE",
    ["npc_fastzombie"] = "SKINNED",
    ["npc_poisonzombie"] = "TOXIC SAVAGE",
    ["npc_headcrab"] = "HEADCRAB",
    ["npc_headcrab_black"] = "TOXIC HEADCRAB",
    ["npc_headcrab_fast"] = "FAST HEADCRAB",
    ["npc_antlion"] = "ANTLION",
    ["npc_antlionguard"] = "ANTLION GUARD",
    ["npc_citizen"] = "CIVILIAN",
    ["npc_barney"] = "ARMED CIVILIAN",
    ["npc_kleiner"] = "SCIENTIST",
    ["npc_eli"] = "RESISTANCE LEADER",
    ["npc_monk"] = "MONK",
}

hook.Add("HUDPaint", "Neurolink_ScannerOverlay", function()
    if scanAlpha <= 5 then return end
    
    local ply = LocalPlayer()
    local hasMilPlus = ply:GetNetVar("implant_neurolink_militaryplus")
    local range = hasMilPlus and 3000 or 1500
    
    surface.SetDrawColor(0, 0, 0, scanAlpha * 0.5)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    surface.SetDrawColor(255, 15, 25, scanAlpha * 0.06)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    for i = 0, ScrH(), 3 do surface.SetDrawColor(0, 0, 0, scanAlpha * 0.15) surface.DrawRect(0, i, ScrW(), 1) end
    
    local waveY = (CurTime() * 120) % ScrH()
    surface.SetDrawColor(255, 60, 80, scanAlpha * 0.2) surface.DrawRect(0, waveY, ScrW(), 3)
    
    local glitchX = (math.random(1, 35) == 1 and math.random(-4, 4) or 0)
    local glitchY = (math.random(1, 35) == 1 and math.random(-3, 3) or 0)
    
    local cx, cy = ScrW() * 0.5 + glitchX, ScrH() * 0.5 + glitchY
    surface.SetDrawColor(255, 60, 80, scanAlpha * 0.9)
    surface.DrawRect(cx - 4, cy - 1, 2, 2) surface.DrawRect(cx + 2, cy - 1, 2, 2)
    surface.DrawRect(cx - 4, cy - 4, 8, 1) surface.DrawRect(cx - 4, cy + 3, 8, 1)
    
    local tr = util.TraceLine({start = ply:EyePos(), endpos = ply:EyePos() + ply:GetAimVector() * 10000, filter = {ply}})
    local aimDist = math.Round(tr.HitPos:Distance(ply:EyePos()) / 39.37, 1)
    local hitEnt = tr.Entity
    
    draw.DrawText("NEUROLINK SCANNER", "NL_Menu_Tiny", ScrW() - ScreenScale(15), ScreenScale(12), Color(255, 40, 60, scanAlpha), TEXT_ALIGN_RIGHT)
    draw.DrawText("SCANNING", "NL_Menu_Sub", cx, ScreenScale(30) + glitchY, Color(255, 60, 60, scanAlpha), TEXT_ALIGN_CENTER)

    if scannerActive then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.Clip1 then
            draw.DrawText("AMMO: " .. wep:Clip1(), "NL_Menu_Sub", ScrW()*0.5, ScreenScale(55), Color(255, 200, 50, scanAlpha), TEXT_ALIGN_CENTER)
        end
    end

if IsValid(hitEnt) and (hitEnt:IsPlayer() or hitEnt:IsNPC() or hitEnt:IsWeapon()) then
    if not ply._targetPanelShow then 
        ply._targetPanelShow = true
        ply._targetPanelGlitchTime = CurTime() + 0.1
    end
else
    ply._targetPanelShow = false
end

if ply._targetPanelShow and IsValid(hitEnt) then
    local panelW = ScreenScale(100)
    local panelH = ScreenScale(10)
    if hitEnt:IsPlayer() then
        panelH = panelH + ScreenScale(14) + ScreenScale(12)
        if hasMilPlus then
            for _, wep in ipairs(hitEnt:GetWeapons()) do
                if IsValid(wep) and wep.Clip1 then panelH = panelH + ScreenScale(20) end
            end
        end
    elseif hitEnt:IsNPC() then
        panelH = panelH + ScreenScale(14) + ScreenScale(10)
        local desc = SCAN_DESCRIPTIONS[hitEnt:GetClass()]
        if desc then
            local lines = 1
            for _ in desc:gmatch("\n") do lines = lines + 1 end
            panelH = panelH + ScreenScale(12) + ScreenScale(lines * 10)
        end
    elseif hitEnt:IsWeapon() then
        panelH = panelH + ScreenScale(14)
        local wepDesc = getWeaponDescription(hitEnt:GetClass())
        if wepDesc and wepDesc ~= "UNKNOWN ITEM\nNo data available.\nScan incomplete." then
            local lines = 1
            for _ in wepDesc:gmatch("\n") do lines = lines + 1 end
            panelH = panelH + ScreenScale(14) + ScreenScale(lines * 10)
        end
    end
    
    local panelX = ScrW() - panelW - ScreenScale(165)
    local panelY = ScrH() * 0.40
    
    local isGlitching = ply._targetPanelGlitchTime and CurTime() < ply._targetPanelGlitchTime
    local gX = isGlitching and math.random(-8, 8) or 0
    local gY = isGlitching and math.random(-5, 5) or 0
    
    draw.RoundedBox(3, panelX + gX, panelY + gY, panelW, panelH, Color(8, 2, 4, 230))
    draw.RoundedBox(3, panelX + gX, panelY + gY, panelW, 1, Color(255, 40, 60, 255))
    surface.SetDrawColor(255, 40, 60, 255)
    surface.DrawRect(panelX + gX, panelY + gY, 3, panelH)
    
    if isGlitching then
        for i = 1, math.random(2, 5) do
            surface.SetDrawColor(255, 40, 60, math.random(100, 255))
            surface.DrawRect(panelX + math.random(-10, panelW), panelY + math.random(0, panelH), math.random(10, 40), math.random(1, 2))
        end
    end
    
    local yOff = panelY + ScreenScale(6)
    local textX = panelX + ScreenScale(8) + gX
    
    if hitEnt:IsPlayer() then
        draw.DrawText(hitEnt:Nick(), "NL_Menu_Sub", textX, yOff + gY, Color(255, 200, 200, 255), TEXT_ALIGN_LEFT)
        yOff = yOff + ScreenScale(14)
        draw.DrawText(aimDist .. "m | HP: " .. math.Round(hitEnt:Health()), "NL_Scanner", textX, yOff + gY, Color(255, 150, 150, 255), TEXT_ALIGN_LEFT)
        if hasMilPlus then
            yOff = yOff + ScreenScale(4)
            for _, wep in ipairs(hitEnt:GetWeapons()) do
                if IsValid(wep) and wep.Clip1 then
                    yOff = yOff + ScreenScale(20)
                    draw.DrawText(getWeaponName(wep:GetClass()) .. " [" .. wep:Clip1() .. "]", "NL_Scanner", panelX + ScreenScale(14) + gX, yOff + gY, Color(255, 200, 100, 255), TEXT_ALIGN_LEFT)
                end
            end
        end
    elseif hitEnt:IsNPC() then
        local npcName = NPC_NAMES[hitEnt:GetClass()] or hitEnt:GetClass()
        draw.DrawText(npcName, "NL_Menu_Sub", textX, yOff + gY, Color(255, 150, 50, 255), TEXT_ALIGN_LEFT)
        yOff = yOff + ScreenScale(14)
        draw.DrawText(aimDist .. "m", "NL_Scanner", textX, yOff + gY, Color(255, 180, 180, 255), TEXT_ALIGN_LEFT)
        local desc = SCAN_DESCRIPTIONS[hitEnt:GetClass()]
        if desc then
            yOff = yOff + ScreenScale(12)
            draw.DrawText(desc, "NL_Scanner", textX, yOff + gY, Color(255, 200, 150, 255), TEXT_ALIGN_LEFT)
        end
    elseif hitEnt:IsWeapon() then
        local wepName = getWeaponName(hitEnt:GetClass())
        if hitEnt.Clip1 then wepName = wepName .. " [" .. hitEnt:Clip1() .. "]" end
        draw.DrawText(wepName, "NL_Menu_Sub", textX, yOff + gY, Color(255, 200, 50, 255), TEXT_ALIGN_LEFT)
        local wepDesc = getWeaponDescription(hitEnt:GetClass())
        if wepDesc then
            yOff = yOff + ScreenScale(14)
            draw.DrawText(wepDesc, "NL_Scanner", textX, yOff + gY, Color(255, 200, 150, 255), TEXT_ALIGN_LEFT)
        end
    end
end

    local eyePos = ply:EyePos()
    for _, ent in ipairs(ents.FindInSphere(eyePos, range)) do
        if ent == ply then continue end
        if ent == hitEnt then continue end
        if not ent:IsPlayer() and not ent:IsNPC() then continue end
        if not ent:Alive() and ent:IsPlayer() then continue end
        
        local trWall = util.TraceLine({start = eyePos, endpos = ent:GetPos() + Vector(0,0,50), filter = {ply}})
        if trWall.Hit and trWall.Entity ~= ent then continue end
        
        local screenPos = (ent:GetPos() + Vector(0, 0, 70)):ToScreen()
        if not screenPos.visible then continue end
        local dist = math.Round(eyePos:Distance(ent:GetPos()) / 39.37, 1)
        
        if ent:IsPlayer() then
            draw.DrawText(ent:Nick(), "NL_Scanner", screenPos.x, screenPos.y, Color(255, 180, 180, scanAlpha * 0.7), TEXT_ALIGN_CENTER)
            draw.DrawText(dist .. "m", "NL_Scanner", screenPos.x, screenPos.y + ScreenScale(10), Color(255, 120, 120, scanAlpha * 0.5), TEXT_ALIGN_CENTER)
        elseif ent:IsNPC() then
            local npcName = NPC_NAMES[ent:GetClass()] or ent:GetClass()
            draw.DrawText(npcName, "NL_Scanner", screenPos.x, screenPos.y, Color(255, 150, 50, scanAlpha * 0.6), TEXT_ALIGN_CENTER)
        end
    end
end)

local unconMatrixAlpha = 0
local unconMatrixText = {}
local unconMatrixInit = false

hook.Add("Think", "Neurolink_UnconMatrix", function()
    local ply = LocalPlayer()
    
    if not ply:Alive() then
        unconMatrixAlpha = 0
        return
    end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or 
                     ply:GetNetVar("implant_neurolink_military") or 
                     ply:GetNetVar("implant_neurolink_militaryplus") or
                     ply:GetNetVar("implant_neurolink_scrap") or
                     ply:GetNetVar("implant_neurolink_diy") or
                     ply:GetNetVar("implant_neurolink_blackmarket")
    if not hasNeurolink then
        unconMatrixAlpha = 0
        return
    end
    
    local isUncon = ply.organism and ply.organism.otrub
    
    if isUncon then
        unconMatrixAlpha = math.min(255, unconMatrixAlpha + FrameTime() * 80)
        
        if not unconMatrixInit then
            unconMatrixInit = true
            for x = 1, 60 do
                unconMatrixText[x] = {}
                for y = 1, 35 do
                    unconMatrixText[x][y] = math.random(0, 1) == 1 and "1" or "0"
                end
            end
        end
    else
        unconMatrixAlpha = math.max(0, unconMatrixAlpha - FrameTime() * 120)
        if unconMatrixAlpha <= 0 then
            unconMatrixInit = false
        end
    end
end)

hook.Add("HUDPaint", "Neurolink_UnconMatrixOverlay", function()
    if unconMatrixAlpha <= 5 then return end
    
    local cellW = ScrW() / 60
    local cellH = ScrH() / 35
    
    for x = 1, 60 do
        for y = 1, 35 do
            if math.random(1, 300) == 1 then
                unconMatrixText[x][y] = math.random(0, 1) == 1 and "1" or "0"
            end
            
            local alpha = math.abs(math.sin(CurTime() * 2 + x * 0.1 + y * 0.05)) * unconMatrixAlpha * 0.3
            
            draw.SimpleText(unconMatrixText[x][y], "NL_Menu_Tiny",
                cellW * (x-1), cellH * (y-1),
                Color(255, 40, 60, alpha))
        end
    end
    
    draw.DrawText("USER UNCONSCIOUS", "NL_Menu_Sub", ScrW() * 0.5, ScrH() * 0.5,
        Color(255, 60, 80, unconMatrixAlpha), TEXT_ALIGN_CENTER)
end)

hook.Add("HUDPaint", "implant_compass_scrap", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_compass_scrap") then return end
    
    local gx, gy = 0, 0
    if math.random(100) <= 30 then gx = math.random(-15, 15); gy = math.random(-3, 3) end
    
    local yaw = ply:EyeAngles().y + math.random(-45, 45)
    yaw = ((-yaw) % 360)
    
    local sw, sh = ScrW(), ScrH()
    local barW = sw * 0.4
    local barH = ScreenScale(8)
    local barX = sw * 0.5 - barW * 0.5 + gx
    local barY = ScreenScale(6) + gy
    
    draw.RoundedBox(2, barX, barY, barW, barH, Color(30, 0, 0, 180))
    surface.SetDrawColor(255, 50, 50, 80)
    surface.DrawLine(barX, barY, barX + barW, barY)
    surface.DrawLine(barX, barY + barH, barX + barW, barY + barH)
    
    if math.random(100) <= 20 then return end
    
    for _, dir in ipairs({{"N",0},{"NE",45},{"E",90},{"SE",135},{"S",180},{"SW",225},{"W",270},{"NW",315}}) do
        local delta = (dir[2] - yaw + 540) % 360 - 180
        if math.abs(delta) < 90 then
            local frac = delta / 90
            local x = barX + barW * 0.5 + frac * barW * 0.5
            local isCardinal = dir[1] == "N" or dir[1] == "S" or dir[1] == "E" or dir[1] == "W"
            local col = isCardinal and Color(255, 50, 50, 180) or Color(255, 80, 80, 80)
            surface.SetDrawColor(col)
            surface.DrawLine(x, barY, x, barY + (isCardinal and barH or barH * 0.5))
            local label = math.random(100) <= 25 and ({"NW","SE","N","S","W","E"})[math.random(6)] or dir[1]
            draw.DrawText(label, "NL_Compass", x + math.random(-2,2), barY + barH + 2 + math.random(-1,1), col, TEXT_ALIGN_CENTER)
        end
    end
    
    surface.SetDrawColor(255, 50, 50, 150)
    surface.DrawLine(sw * 0.5 + gx, barY - 3, sw * 0.5 + gx, barY + barH + 3)
end)

hook.Add("HUDPaint", "implant_compass_diy", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_compass_diy") then return end
    
    if not ply._diyCompassYaw then ply._diyCompassYaw = ply:EyeAngles().y end
    ply._diyCompassYaw = Lerp(FrameTime() * 2, ply._diyCompassYaw, ply:EyeAngles().y)
    
    local sw, sh = ScrW(), ScrH()
    local barW = sw * 0.4
    local barH = ScreenScale(8)
    local barX = sw * 0.5 - barW * 0.5
    local barY = ScreenScale(6)
    local yaw = ((-ply._diyCompassYaw) % 360)
    
    draw.RoundedBox(2, barX, barY, barW, barH, Color(20, 20, 0, 160))
    surface.SetDrawColor(255, 200, 50, 60)
    surface.DrawLine(barX, barY, barX + barW, barY)
    surface.DrawLine(barX, barY + barH, barX + barW, barY + barH)
    
    for _, dir in ipairs({{"N",0},{"NE",45},{"E",90},{"SE",135},{"S",180},{"SW",225},{"W",270},{"NW",315}}) do
        local delta = (dir[2] - yaw + 540) % 360 - 180
        if math.abs(delta) < 90 then
            local frac = delta / 90
            local x = barX + barW * 0.5 + frac * barW * 0.5
            local isCardinal = dir[1] == "N" or dir[1] == "S" or dir[1] == "E" or dir[1] == "W"
            local col = isCardinal and Color(255, 200, 50, 160) or Color(255, 180, 80, 60)
            surface.SetDrawColor(col)
            surface.DrawLine(x, barY, x, barY + (isCardinal and barH or barH * 0.5))
            draw.DrawText(dir[1], "NL_Compass", x, barY + barH + 2, col, TEXT_ALIGN_CENTER)
        end
    end
    
    surface.SetDrawColor(255, 200, 50, 120)
    surface.DrawLine(sw * 0.5, barY - 3, sw * 0.5, barY + barH + 3)
end)

hook.Add("HUDPaint", "implant_compass_blackmarket", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_compass_blackmarket") then return end
    
    local sw, sh = ScrW(), ScrH()
    local barW = sw * 0.4
    local barH = ScreenScale(8)
    local barX = sw * 0.5 - barW * 0.5
    local barY = ScreenScale(6)
    local yaw = ((-ply:EyeAngles().y) % 360)
           
    draw.RoundedBox(2, barX, barY, barW, barH, Color(0, 5, 10, 180))
    surface.SetDrawColor(0, 200, 255, 60)
    surface.DrawLine(barX, barY, barX + barW, barY)
    surface.DrawLine(barX, barY + barH, barX + barW, barY + barH)
    
    for _, dir in ipairs({{"N",0},{"NE",45},{"E",90},{"SE",135},{"S",180},{"SW",225},{"W",270},{"NW",315}}) do
        local delta = (dir[2] - yaw + 540) % 360 - 180
        if math.abs(delta) < 90 then
            local frac = delta / 90
            local x = barX + barW * 0.5 + frac * barW * 0.5
            local isCardinal = dir[1] == "N" or dir[1] == "S" or dir[1] == "E" or dir[1] == "W"
            local col = isCardinal and Color(0, 200, 255, 180) or Color(0, 150, 220, 60)
            surface.SetDrawColor(col)
            surface.DrawLine(x, barY, x, barY + (isCardinal and barH or barH * 0.5))
            draw.DrawText(dir[1], "NL_Compass", x, barY + barH + 2, col, TEXT_ALIGN_CENTER)
        end
    end
    
    surface.SetDrawColor(0, 200, 255, 120)
    surface.DrawLine(sw * 0.5, barY - 3, sw * 0.5, barY + barH + 3)
    
    for i = 1, math.random(1, 5) do
        local fakeAngle = math.random(-80, 80)
        local x = barX + barW * 0.5 + (fakeAngle / 90) * barW * 0.5
        local col = math.random(2) == 1 and Color(255, 50, 50, 100) or Color(50, 255, 50, 100)
        draw.RoundedBox(99, x - 2, barY + barH * 0.5 - 2, 4, 4, col)
    end
end)

concommand.Add("neurolink_scan", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    if ply:GetNetVar("implant_neurolink_militaryplus") then
        if not ply._milpInit then
            ply._milpBioScanTime = 0
            ply._milpAreaScanTime = 0
        end
        ply._milpBioScanTime = CurTime() + 16
        ply._milpBioScanTimer = CurTime() + 60
        ply._milpAreaScanTime = CurTime() + 6
        ply._milpAreaScanTimer = CurTime() + 60
        surface.PlaySound("scanner.wav")
    elseif ply:GetNetVar("implant_neurolink_military") then
        if not ply._milInit then
            ply._milBioScanTime = 0
            ply._milAreaScanTime = 0
        end
        ply._milBioScanTime = CurTime() + 16
        ply._milBioScanTimer = CurTime() + 60
        ply._milAreaScanTime = CurTime() + 6
        ply._milAreaScanTimer = CurTime() + 60
        surface.PlaySound("scanner.wav")
    elseif ply:GetNetVar("implant_neurolink_basic") then
        if not ply._basicScanTime then ply._basicScanTime = 0 end
        ply._basicScanTime = CurTime() + 16
        ply._basicScanTimer = CurTime() + 60
        surface.PlaySound("scanner.wav")
    end
end)

local mp3Playing = false
local mp3Station = nil
local mp3Playlist = {}
local mp3CurrentTrack = 0
local mp3Volume = 0.5
local mp3MenuOpen = false
local mp3MenuAlpha = 0
local mp3Stations = {}
local mp3CurrentStation = "Z-City Radio"
local mp3LastClick = 0
local mp3ScrollOffset = 0

local STATIONS = {
    ["CrueltyS"] = {folder = "Cruelty", color = Color(50, 255, 50)},
    ["Punk Radio"] = {folder = "Punk", color = Color(255, 50, 100)},
    ["Rap"] = {folder = "Rap", color = Color(100, 200, 255)},
    ["Chrome Beats"] = {folder = "Chrome", color = Color(255, 200, 50)},
    ["Dead Channel"] = {folder = "Dead", color = Color(200, 50, 50)},
    ["Vexelstrom"] = {folder = "Vexelstrom", color = Color(200, 50, 200)},
    ["The Dirge"] = {folder = "Dirge", color = Color(100, 150, 200)},
    ["Pacific"] = {folder = "Pacific", color = Color(50, 200, 150)},
    ["NY Station"] = {folder = "NY", color = Color(180, 140, 80)},
}

local STATION_ORDER = {
    "Punk Radio", "Rap", "Chrome Beats", "CrueltyS",
    "Dead Channel", "Vexelstrom", "The Dirge", "Pacific", "NY Station"
}

local function LoadPlaylist()
    mp3Stations = {}
    for _, stationName in ipairs(STATION_ORDER) do
        local stationData = STATIONS[stationName]
        if stationData then
            local folder = "sound/zcity_implants/music/" .. stationData.folder .. "/*.mp3"
            local files = file.Find(folder, "GAME")
            if #files > 0 then
                local tracks = {}
                for _, fname in ipairs(files) do
                    tracks[#tracks + 1] = stationData.folder .. "/" .. fname
                end
                mp3Stations[stationName] = {tracks = tracks, color = stationData.color}
            end
        end
    end
    if mp3Stations[mp3CurrentStation] then
        mp3Playlist = mp3Stations[mp3CurrentStation].tracks
    else
        mp3Playlist = {}
    end
end

function PlayTrack()
    if #mp3Playlist == 0 then return end
    if mp3CurrentTrack < 1 or mp3CurrentTrack > #mp3Playlist then mp3CurrentTrack = 1 end
    if IsValid(mp3Station) then mp3Station:Stop() end
    local path = "sound/zcity_implants/music/" .. mp3Playlist[mp3CurrentTrack]
    sound.PlayFile(path, "noblock", function(st)
        if IsValid(st) then st:SetVolume(mp3Volume) st:Play() mp3Station = st end
    end)
end

concommand.Add("implant_mp3", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_mp3") then return end
    if #mp3Playlist == 0 then LoadPlaylist() end
    if #mp3Playlist == 0 then chat.AddText(Color(255,100,100), "[MP3] No music found!") return end
    if mp3Playing then
        if IsValid(mp3Station) then mp3Station:Stop() mp3Station = nil end
        mp3Playing = false
    else
        if mp3CurrentTrack == 0 then mp3CurrentTrack = 1 end
        PlayTrack()
        mp3Playing = true
    end
end)

concommand.Add("implant_mp3_next", function() if not mp3Playing or #mp3Playlist == 0 then return end mp3CurrentTrack = mp3CurrentTrack % #mp3Playlist + 1 PlayTrack() end)
concommand.Add("implant_mp3_vol_up", function() mp3Volume = math.min(1, mp3Volume + 0.1) if IsValid(mp3Station) then mp3Station:SetVolume(mp3Volume) end end)
concommand.Add("implant_mp3_vol_down", function() mp3Volume = math.max(0, mp3Volume - 0.1) if IsValid(mp3Station) then mp3Station:SetVolume(mp3Volume) end end)

concommand.Add("implant_mp3_menu", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply:GetNetVar("implant_mp3") then return end
    if #mp3Playlist == 0 then LoadPlaylist() end
    mp3MenuOpen = not mp3MenuOpen
    mp3ScrollOffset = 0
    if mp3MenuOpen then gui.EnableScreenClicker(true) else gui.EnableScreenClicker(false) end
end)

hook.Add("Think", "MP3_MenuClick", function()
    if not mp3MenuOpen then return end
    if not input.IsMouseDown(MOUSE_LEFT) then return end
    if mp3LastClick and CurTime() - mp3LastClick < 0.2 then return end
    mp3LastClick = CurTime()
    
    local mx, my = input.GetCursorPos()
    local trackH = ScreenScale(14)
    local trackCols = 3
    local stnH = ScreenScale(18)
    local stnRows = 3
    local stnGap = ScreenScale(4)
    local stnAreaH = stnRows * (stnH + stnGap) + ScreenScale(8)
    local panelW = ScreenScale(300)
    local panelH = math.min(ScrH() * 0.85, ScreenScale(22) + stnAreaH + ScreenScale(280))
    local panelX = ScrW()/2 - panelW/2
    local panelY = ScrH()/2 - panelH/2
    
    if mx < panelX or mx > panelX + panelW or my < panelY or my > panelY + panelH then
        mp3MenuOpen = false; gui.EnableScreenClicker(false); return
    end
    
    local stnY = panelY + ScreenScale(18)
    local colW = (panelW - ScreenScale(16)) / 3
    
    if my >= stnY and my <= stnY + stnAreaH then
        for i, stnName in ipairs(STATION_ORDER) do
            if mp3Stations[stnName] then
                local row = math.floor((i-1) / 3)
                local col = (i-1) % 3
                local sX = panelX + ScreenScale(8) + col * colW
                local sY = stnY + row * (stnH + stnGap)
                if mx >= sX and mx <= sX + colW - ScreenScale(4) and my >= sY and my <= sY + stnH then
                    mp3CurrentStation = stnName
                    mp3Playlist = mp3Stations[stnName].tracks
                    mp3CurrentTrack = 1
                    if mp3Playing then PlayTrack() end
                    return
                end
            end
        end
        return
    end
    
    local trackStartY = stnY + stnAreaH
    local trackColW = (panelW - ScreenScale(16)) / trackCols
    
    if my >= trackStartY and my <= trackStartY + (math.ceil(#mp3Playlist / trackCols) * trackH) then
        local col = math.floor((mx - panelX - ScreenScale(10)) / trackColW)
        local row = math.floor((my - trackStartY) / trackH)
        if col >= 0 and col < trackCols then
            local idx = row * trackCols + col + 1
            if idx >= 1 and idx <= #mp3Playlist then
                mp3CurrentTrack = idx
                if mp3Playing then PlayTrack() else mp3Playing = true; PlayTrack() end
            end
        end
    end
end)

hook.Add("Think", "MP3_AutoNext", function()
    if not mp3Playing or #mp3Playlist == 0 then return end
    if IsValid(mp3Station) and mp3Station:GetState() ~= GMOD_CHANNEL_PLAYING then
        mp3CurrentTrack = mp3CurrentTrack % #mp3Playlist + 1
        PlayTrack()
    end
end)

hook.Add("HUDPaint", "MP3_HUD", function()
    local ply = LocalPlayer()
    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or ply:GetNetVar("implant_neurolink_military") or ply:GetNetVar("implant_neurolink_militaryplus") or ply:GetNetVar("implant_neurolink_scrap") or ply:GetNetVar("implant_neurolink_diy") or ply:GetNetVar("implant_neurolink_blackmarket")
    
    if mp3Playing and hasNeurolink then
        local trackName = mp3Playlist[mp3CurrentTrack] or "Unknown"
        trackName = trackName:gsub(".mp3", ""):gsub("/", " - ")
        local stnColor = mp3Stations[mp3CurrentStation] and mp3Stations[mp3CurrentStation].color or Color(255,200,50)
        draw.DrawText("♪ " .. mp3CurrentStation .. " - " .. trackName .. " [" .. math.Round(mp3Volume*100) .. "%]", "NL_Menu_Tiny", ScrW()*0.5, ScrH()*0.95, stnColor, TEXT_ALIGN_CENTER)
    end
    
    if not mp3MenuOpen then mp3MenuAlpha = math.max(0, mp3MenuAlpha - FrameTime() * 500) return end
    mp3MenuAlpha = math.min(255, mp3MenuAlpha + FrameTime() * 500)
    if mp3MenuAlpha < 5 then return end
    if not hasNeurolink then mp3MenuOpen = false mp3MenuAlpha = 0 return end
    
    local trackH = ScreenScale(14)
    local trackCols = 3
    local maxRows = math.ceil(#mp3Playlist / trackCols)
    local tracksH = maxRows * trackH + ScreenScale(12)
    
    local stnH = ScreenScale(18)
    local stnRows = 3
    local stnGap = ScreenScale(4)
    local stnAreaH = stnRows * (stnH + stnGap) + ScreenScale(8)
    
    local panelW = ScreenScale(300)
    local panelH = math.min(ScrH() * 0.85, ScreenScale(22) + stnAreaH + ScreenScale(280))
    local panelX = ScrW()/2 - panelW/2
    local panelY = ScrH()/2 - panelH/2
    
    local gX = mp3MenuAlpha < 255 and math.random(-3, 3) or 0
    local gY = mp3MenuAlpha < 255 and math.random(-2, 2) or 0
    
    draw.RoundedBox(4, panelX + gX, panelY + gY, panelW, panelH, Color(8, 2, 4, 235))
    draw.RoundedBox(4, panelX + gX, panelY + gY, panelW, 1, Color(255, 40, 60, 255))
    surface.SetDrawColor(255, 40, 60, 255)
    surface.DrawRect(panelX + gX, panelY + gY, 3, panelH)
    
    draw.DrawText("MP3 RADIO", "NL_Menu_Sub", panelX + panelW/2 + gX, panelY + ScreenScale(8) + gY, Color(255, 200, 50, 255), TEXT_ALIGN_CENTER)
    
    local stnY = panelY + ScreenScale(18)
    local colW = (panelW - ScreenScale(16)) / 3
    for i, stnName in ipairs(STATION_ORDER) do
        if mp3Stations[stnName] then
            local row = math.floor((i-1) / 3)
            local col = (i-1) % 3
            local sX = panelX + ScreenScale(8) + col * colW
            local sY = stnY + row * (stnH + stnGap)
            local isActive = (stnName == mp3CurrentStation)
            local stnColor = mp3Stations[stnName].color
            local bgColor = isActive and Color(stnColor.r, stnColor.g, stnColor.b, 200) or Color(30, 30, 30, 200)
            local txtColor = isActive and Color(255, 255, 255, 255) or Color(150, 150, 150, 255)
            draw.RoundedBox(2, sX, sY, colW - ScreenScale(4), stnH, bgColor)
            draw.DrawText(stnName, "NL_Menu_Tiny", sX + (colW - ScreenScale(4))/2, sY + stnH/2 - 1, txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    local trackStartY = stnY + stnAreaH
    local trackColW = (panelW - ScreenScale(16)) / trackCols
    local clipX = panelX
    local clipY = trackStartY
    local clipW = panelW
    local clipH = panelH - (trackStartY - panelY) - ScreenScale(4)
    
    render.SetScissorRect(clipX, clipY, clipX + clipW, clipY + clipH, true)
    
    for i, trackName in ipairs(mp3Playlist) do
        local col = (i-1) % trackCols
        local row = math.floor((i-1) / trackCols)
        local tX = panelX + ScreenScale(10) + col * trackColW
        local tY = trackStartY + row * trackH
        
        local displayName = trackName:gsub(".mp3", ""):gsub("/", " - ")
        if #displayName > 24 then displayName = string.sub(displayName, 1, 21) .. "." end
        local color = (i == mp3CurrentTrack and mp3Playing) and Color(255, 200, 50, 255) or Color(200, 200, 200, 200)
        local prefix = (i == mp3CurrentTrack) and "> " or "  "
        draw.DrawText(prefix .. displayName, "NL_Menu_Tiny", tX + gX, tY + gY, color, TEXT_ALIGN_LEFT)
    end
    
    render.SetScissorRect(0, 0, 0, 0, false)
end)

hook.Add("PreDrawHalos", "Neurolink_Scanner_Outline", function()
    if not scannerActive then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 10000,
        filter = ply
    })

    local ent = tr.Entity
    if not IsValid(ent) then return end

    if not (ent:IsPlayer() or ent:IsNPC() or ent:IsWeapon()) then return end

    outline.Add({ent}, Color(255, 60, 80), OUTLINE_MODE_VISIBLE)
end)

hook.Add("HUDPaint", "ChromaLoad_PsychosisHUD", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply.organism then return end
    
    local load = ply.chromaLoad or 0
    local timer = ply.organism.psychosisTimer or 0
    
    if load >= 100 and timer > 5 then
        local pct = math.Round(math.min(timer / 90 * 100, 100))
        
        draw.RoundedBox(2, ScrW()*0.35, ScrH()*0.92, ScrW()*0.3, ScreenScale(6), Color(10,2,3,200))
        draw.RoundedBox(2, ScrW()*0.35, ScrH()*0.92, ScrW()*0.3*(timer/90), ScreenScale(6), Color(255,50,50,220))
        draw.DrawText("PSYCHOSIS: "..pct.."%", "NL_Menu_Tiny", ScrW()*0.5, ScrH()*0.91, Color(255,100,100,200), TEXT_ALIGN_CENTER)
        
        if timer > 30 then
            draw.DrawText("TAKE MEDS", "NL_Menu_Sub", ScrW()*0.5, ScrH()*0.87, Color(255,200,50,math.sin(CurTime()*5)*100+155), TEXT_ALIGN_CENTER)
        end
        if timer > 60 then
            surface.SetDrawColor(255,0,0,40)
            surface.DrawRect(0,0,ScrW(),ScrH())
            draw.DrawText("SEEK HELP NOW", "NL_Menu_Sub", ScrW()*0.5, ScrH()*0.8, Color(255,0,0,255), TEXT_ALIGN_CENTER)
        end
    end
end)

hook.Add("radialOptions", "zc_inventory", function()
    local ply = LocalPlayer()
    if not ply:Alive() or (ply.organism and ply.organism.otrub) then return end
    if not input.IsKeyDown(KEY_LALT) and not input.IsKeyDown(KEY_RALT) then return end

    local inv = ply.Inventory or {}
    if #inv == 0 then
        hg.radialOptions[#hg.radialOptions + 1] = {
            function() end,
            "No Implants\nNo Organs"
        }
        return
    end

    local commands = {}
    for idx, item in ipairs(inv) do
        local label = (item.type == "implant" and "[I] " or "[O] ") .. item.name
        commands[#commands + 1] = {
            function()
                local actions = {
    {
        function()
            net.Start("DropImplant")
            net.WriteUInt(idx, 8)
            net.SendToServer()
        end,
        "Drop"
    },
    {
        function()
            net.Start("SellImplant")
            net.WriteUInt(idx, 8)
            net.SendToServer()
        end,
        "Sell"
    }
}
                hg.CreateRadialMenu(actions)
                return -1
            end,
            label
        }
    end

    hg.radialOptions[#hg.radialOptions + 1] = {
        function()
            hg.CreateRadialMenu(commands)
            return -1
        end,
        "inventory"
    }
end)

print("cl implants loaded")
net.Receive("SyncInventory", function()
    local ply = LocalPlayer()
    local json = net.ReadString()
    if json and json ~= "" then
        ply.Inventory = util.JSONToTable(json)
        print("[Inventory] Synced " .. #ply.Inventory .. " items")
    else
        ply.Inventory = {}
    end
end)

hook.Add("PlayerSpawn", "RequestInventory", function(ply)
    if ply ~= LocalPlayer() then return end
    net.Start("RequestInventory")
    net.SendToServer()
end)

timer.Simple(0.5, function()
    if IsValid(LocalPlayer()) then
        net.Start("RequestInventory")
        net.SendToServer()
    end
end)

print("cl_inventory_sync loaded")
if SERVER then return end

local currentTarget = nil
local qteActive = false
local qteData = nil
local cyberdeckScannerActive = false
local menuAlpha = 0
local menuSlideX = -300

local CYBERDECK_DEBUG = true
local function DebugPrint(...)
    if CYBERDECK_DEBUG then
        print("[Cyberdeck]", ...)
    end
end

net.Receive("ZC_RebootOptics", function()
    DebugPrint("Received RebootOptics effect")
    local glitch_dur = net.ReadFloat()
    local blind_dur = net.ReadFloat()
    
    local glitch_end = CurTime() + glitch_dur
    local blind_end = CurTime() + blind_dur
    
    hook.Add("RenderScreenspaceEffects", "cyberdeck_reboot_glitch", function()
        if CurTime() > glitch_end then
            hook.Remove("RenderScreenspaceEffects", "cyberdeck_reboot_glitch")
            return
        end
        
        DrawColorModify({
            ["$pp_colour_addr"] = math.sin(CurTime() * 20) * 0.02,
            ["$pp_colour_addg"] = math.cos(CurTime() * 23) * 0.02,
            ["$pp_colour_addb"] = math.sin(CurTime() * 17) * 0.02,
            ["$pp_colour_brightness"] = -0.1,
            ["$pp_colour_contrast"] = 1.3,
            ["$pp_colour_colour"] = 0.7,
        })
        
        if math.random(1, 15) == 1 then
            local x, y = math.random(100, ScrW() - 100), math.random(100, ScrH() - 100)
            draw.SimpleText("ERROR", "NL_Menu_Tiny", x, y, Color(255, 0, 0, 200), TEXT_ALIGN_CENTER)
        end
    end)
    
    if blind_dur > 0 then
        hook.Add("RenderScreenspaceEffects", "cyberdeck_reboot_blind", function()
            if CurTime() > blind_end then
                hook.Remove("RenderScreenspaceEffects", "cyberdeck_reboot_blind")
                return
            end
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end)
    end
end)

net.Receive("ZC_QTE_Start", function()
    DebugPrint("Received QTE_Start")
    local qte_id = net.ReadString()
    local qte_type = net.ReadString()
    local qte_time = net.ReadFloat()
    local is_my_turn = net.ReadBool()
    
    qteActive = true
    qteData = {
        id = qte_id,
        type = qte_type,
        time_left = qte_time,
        total_time = qte_time,
        is_my_turn = is_my_turn,
        button_pressed = false
    }
    
    surface.PlaySound("buttons/button15.wav")
end)

net.Receive("ZC_QTE_Result", function()
    DebugPrint("Received QTE_Result")
    local qte_id = net.ReadString()
    local failed_ply = net.ReadEntity()
    local result_type = net.ReadString()
    
    qteActive = false
    qteData = nil
    
    if result_type == "cyberpsychosis" then
        surface.PlaySound("zcity_implants/psycho_music.mp3")
    elseif result_type == "suicide_target" then
        surface.PlaySound("buttons/blip1.wav")
    elseif result_type == "suicide_hacker" then
        surface.PlaySound("physics/glass/glass_sheet_break3.wav")
    end
end)

net.Receive("ZC_QuickhackCast", function()
    DebugPrint("Received QuickhackCast")
    local hacker = net.ReadEntity()
    local target = net.ReadEntity()
    local hack_type = net.ReadString()
    
    if hacker == LocalPlayer() then return end
    
    local angle = 0
    hook.Add("HUDPaint", "cyberdeck_cast_indicator", function()
        if not IsValid(target) then
            hook.Remove("HUDPaint", "cyberdeck_cast_indicator")
            return
        end
        
        local scr = target:GetPos():ToScreen()
        if not scr.visible then return end
        
        angle = angle + 0.15
        local radius = 30 + math.sin(angle) * 5
        
        for i = 0, 360, 30 do
            local rad = math.rad(i + angle * 20)
            local x = scr.x + math.cos(rad) * radius
            local y = scr.y + math.sin(rad) * radius
            surface.SetDrawColor(255, 50, 50, 200)
            surface.DrawRect(x - 2, y - 2, 4, 4)
        end
        
        draw.SimpleText("HACKED", "NL_Menu_Tiny", scr.x, scr.y - 40, Color(255, 50, 50, 255), TEXT_ALIGN_CENTER)
    end)
end)

local function CanUseCyberdeck()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return false end
    
    local has_optics = ply:GetNetVar("implant_neurolink_military") or 
                       ply:GetNetVar("implant_neurolink_militaryplus") or
                       ply:GetNetVar("implant_neurolink_blackmarket")
    
    local has_deck = ply:GetNetVar("implant_cyberdeck_basic") or 
                     ply:GetNetVar("implant_cyberdeck_advanced") or
                     ply:GetNetVar("implant_cyberdeck_pro")
    
    return has_optics and has_deck
end

local QUICKHACKS = {
    { id = "short_circuit", name = "SHORT CIRCUIT", desc = "DAMAGE + STUN", cmd = "cyberdeck_short_circuit" },
    { id = "synapse_burnout", name = "SYNAPSE BURNOUT", desc = "HEAD DMG + FIRE", cmd = "cyberdeck_synapse_burnout" },
    { id = "cyberware_shutoff", name = "CYBERWARE SHUT-OFF", desc = "DISABLE IMPLANTS", cmd = "cyberdeck_cyberware_shutoff" },
    { id = "reboot_optics", name = "REBOOT OPTICS", desc = "GLITCH + BLIND", cmd = "cyberdeck_reboot_optics" },
    { id = "cyberpsychosis", name = "CYBERPSYCHOSIS", desc = "QTE - PSYCHOSIS", cmd = "cyberdeck_cyberpsychosis" },
    { id = "suicide", name = "SUICIDE", desc = "QTE - DEATH", cmd = "cyberdeck_suicide" }
}

for i, hack in ipairs(QUICKHACKS) do
    concommand.Add(hack.cmd, function(ply, cmd, args)
        DebugPrint("Command executed:", hack.cmd)
        
        if not CanUseCyberdeck() then
            DebugPrint("Cannot use cyberdeck - missing implants")
            return
        end
        if not cyberdeckScannerActive then
            DebugPrint("Scanner not active")
            return
        end
        if not currentTarget then
            DebugPrint("No target selected")
            return
        end
        if qteActive then
            DebugPrint("QTE active, blocking")
            return
        end
        
        DebugPrint("Sending quickhack:", hack.id, "to target:", currentTarget)
        
        net.Start("ZC_QuickhackCast")
            net.WriteEntity(currentTarget)
            net.WriteString(hack.id)
        net.SendToServer()
        
        local cooldown_key = "cyberdeck_cooldown_" .. hack.id
        LocalPlayer()[cooldown_key] = CurTime() + 10
        LocalPlayer()[cooldown_key .. "_start"] = CurTime()
    end)
end

local function DrawQuickhackMenu()
    if not cyberdeckScannerActive then return end
    if not CanUseCyberdeck() then return end
    if qteActive then return end
    
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    local ent = trace.Entity
    
    if not IsValid(ent) or (not ent:IsPlayer() and not ent:IsNPC()) then
        currentTarget = nil
        menuAlpha = math.max(0, menuAlpha - FrameTime() * 500)
        menuSlideX = math.max(-300, menuSlideX - FrameTime() * 800)
        return
    end
    
    if not ent:Alive() then
        currentTarget = nil
        menuAlpha = math.max(0, menuAlpha - FrameTime() * 500)
        menuSlideX = math.max(-300, menuSlideX - FrameTime() * 800)
        return
    end
    
    local dist = ply:GetPos():Distance(ent:GetPos())
    if dist > 1500 then
        currentTarget = nil
        menuAlpha = math.max(0, menuAlpha - FrameTime() * 500)
        menuSlideX = math.max(-300, menuSlideX - FrameTime() * 800)
        return
    end
    
    currentTarget = ent
    
    menuAlpha = math.min(255, menuAlpha + FrameTime() * 800)
    menuSlideX = math.min(0, menuSlideX + FrameTime() * 800)
    
    local baseX = ScrW() * 0.05
    local x = baseX + menuSlideX
    local y = ScrH() * 0.25
    local btn_w = 280
    local btn_h = 45
    local spacing = 4
    local num_hacks = #QUICKHACKS
    local totalH = (btn_h + spacing) * num_hacks
    
    local alpha = menuAlpha / 255
    
    local glitchX = 0
    if math.random(1, 20) == 1 then
        glitchX = math.Rand(-3, 3)
    end
    
    draw.RoundedBox(4, x + glitchX - 5, y - 5, btn_w + 10, totalH + 10, Color(15, 5, 5, 220 * alpha))
    surface.SetDrawColor(255, 50, 50, 200 * alpha)
    surface.DrawRect(x + glitchX - 5, y - 5, btn_w + 10, 2)
    draw.SimpleText("QUICKHACKS", "NL_Menu_Title", x + glitchX + btn_w/2, y - 3, Color(255, 80, 80, 255 * alpha), TEXT_ALIGN_CENTER)
    local target_name = ent:IsPlayer() and ent:Nick() or ent:GetClass()
    draw.SimpleText("TARGET: " .. target_name, "NL_Menu_Tiny", x + glitchX + btn_w/2, y + 18, Color(200, 80, 80, 200 * alpha), TEXT_ALIGN_CENTER)
    for i, hack_data in ipairs(QUICKHACKS) do
        local btn_x = x + glitchX
        local btn_y = y + 45 + (btn_h + spacing) * (i - 1)
        local cooldown_key = "cyberdeck_cooldown_" .. hack_data.id
        local cooldown_end = ply[cooldown_key] or 0
        local on_cooldown = cooldown_end > CurTime()
        local cooldown_pct = 0
        if on_cooldown then
            local cooldown_start = ply[cooldown_key .. "_start"] or (cooldown_end - 10)
            cooldown_pct = (cooldown_end - CurTime()) / (cooldown_end - cooldown_start)
            cooldown_pct = math.Clamp(cooldown_pct, 0, 1)
        end
        local bg_color = on_cooldown and Color(40, 20, 20, 180 * alpha) or Color(25, 10, 10, 180 * alpha)
        draw.RoundedBox(2, btn_x, btn_y, btn_w, btn_h, bg_color)
        
        if on_cooldown then
            draw.RoundedBox(2, btn_x, btn_y, btn_w * cooldown_pct, btn_h, Color(0, 0, 0, 100))
        end
        
        local name_color = on_cooldown and Color(120, 60, 60, 200 * alpha) or Color(255, 100, 100, 255 * alpha)
        draw.SimpleText(hack_data.name, "NL_Menu_Sub", btn_x + 8, btn_y + btn_h/2 - 1, name_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        
        local desc_color = on_cooldown and Color(80, 40, 40, 150 * alpha) or Color(200, 80, 80, 180 * alpha)
        draw.SimpleText(hack_data.desc, "NL_Menu_Tiny", btn_x + btn_w - 8, btn_y + btn_h/2 + 1, desc_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
    
    if math.random(1, 10) == 1 and alpha > 0.5 then
        local lineY = y + math.random(0, totalH)
        surface.SetDrawColor(255, 50, 50, 100 * alpha)
        surface.DrawRect(x + glitchX, lineY, btn_w, 1)
    end
end

local function DrawQTE()
    if not qteActive or not qteData then return end
    
    local x = ScrW() * 0.5
    local y = ScrH() * 0.6
    local bar_width = 400
    local bar_height = 25
    
    local pct = qteData.time_left / qteData.total_time
    local current_width = bar_width * pct
    
    draw.RoundedBox(4, x - bar_width/2 - 3, y - bar_height/2 - 3, bar_width + 6, bar_height + 6, Color(0, 0, 0, 200))
    draw.RoundedBox(2, x - bar_width/2, y - bar_height/2, bar_width, bar_height, Color(40, 10, 10, 255))
    
    local bar_color
    if pct > 0.5 then
        bar_color = Color(255, 50, 50, 255)
    elseif pct > 0.25 then
        bar_color = Color(255, 100, 50, 255)
    else
        bar_color = Color(255, 200, 50, 255)
    end
    
    draw.RoundedBox(2, x - bar_width/2, y - bar_height/2, current_width, bar_height, bar_color)
    
    local status_text = qteData.is_my_turn and "PRESS [E] NOW!" or "WAIT..."
    local status_color = qteData.is_my_turn and Color(255, 255, 255, 255) or Color(150, 150, 150, 200)
    
    draw.SimpleText(status_text, "NL_Menu_Sub", x, y - 35, status_color, TEXT_ALIGN_CENTER)
    
    local type_text = qteData.type == "cyberpsychosis" and "CYBERPSYCHOSIS" or "SUICIDE PROTOCOL"
    draw.SimpleText(type_text, "NL_Menu_Tiny", x, y + 22, Color(255, 100, 100, 200), TEXT_ALIGN_CENTER)
    
    local pulse = math.sin(CurTime() * 10) * 20 + 30
    surface.SetDrawColor(255, 100, 100, pulse)
    surface.DrawOutlinedRect(x - bar_width/2 - 2, y - bar_height/2 - 2, bar_width + 4, bar_height + 4, 2)
end

local function HandleQTEInput()
    if not qteActive or not qteData then return end
    
    if qteData.is_my_turn and not qteData.button_pressed then
        qteData.button_pressed = true
        
        net.Start("ZC_QTE_Input")
            net.WriteString(qteData.id)
            net.WriteBool(true)
        net.SendToServer()
    end
end

hook.Add("HUDPaint", "cyberdeck_quickhack_menu", function()
    DrawQuickhackMenu()
    DrawQTE()
end)

hook.Add("KeyPress", "cyberdeck_qte_e", function(ply, key)
    if key == KEY_E then
        HandleQTEInput()
    end
end)

concommand.Add("cyberdeck_toggle", function()
    cyberdeckScannerActive = not cyberdeckScannerActive
    DebugPrint("Scanner toggled:", cyberdeckScannerActive)
    if cyberdeckScannerActive then
        surface.PlaySound("buttons/button15.wav")
    else
        menuAlpha = 0
        menuSlideX = -300
        currentTarget = nil
    end
end)

concommand.Add("cyberdeck_status", function()
    local ply = LocalPlayer()
    print("=== CYBERDECK STATUS ===")
    print("Scanner Active:", cyberdeckScannerActive)
    print("Can Use:", CanUseCyberdeck())
    print("Has Military Optics:", ply:GetNetVar("implant_neurolink_military") or ply:GetNetVar("implant_neurolink_militaryplus"))
    print("Has Deck Basic:", ply:GetNetVar("implant_cyberdeck_basic"))
    print("Has Deck Advanced:", ply:GetNetVar("implant_cyberdeck_advanced"))
    print("Has Deck Pro:", ply:GetNetVar("implant_cyberdeck_pro"))
    print("Current Target:", currentTarget and currentTarget or "None")
    print("========================")
end)

print("[ZС Cyberware] Cyberdeck client module loaded")
print("[ZC Cyberware] Use 'cyberdeck_status' in console to debug")
surface.CreateFont("NL_OSLarge", {
    font = "Ari-W9500",
    size = ScreenScale(500),
    extended = true,
    weight = 400,
})

surface.CreateFont("NL_OSMedium", {
    font = "Ari-W9500",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
})

surface.CreateFont("NL_OSSmall", {
    font = "Ari-W9500",
    size = ScreenScale(5),
    extended = true,
    weight = 400,
})

surface.CreateFont("NL_OSMatrix", {
    font = "Ari-W9500",
    size = ScreenScale(10),
    extended = true,
    weight = 400,
})

local cyan      = Color(0, 230, 230)
local cyandark  = Color(0, 40, 50)
local cyanfaint = Color(0, 120, 140)
local cyanglow  = Color(0, 255, 255)
local gradient_l = Material("vgui/gradient-l")

local sw, sh = ScrW(), ScrH()

local PANEL = {}

local BootStages = {
    [1] = {"UNREGISTERED IMPLANT"},
    [2] = {"UNREGISTERED IMPLANT", "Initializing neural bridge..."},
    [3] = {"UNREGISTERED IMPLANT", "Initializing neural bridge...", "HARDWARE INTEGRITY CHECK:"},
    [4] = {
        "UNREGISTERED IMPLANT",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
    },
    [5] = {
        "UNREGISTERED IMPLANT",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ MODULE NOT FOUND",
        "  CYBERIMPLANT OUT ............ MODULE NOT FOUND",
    },
    [6] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ MODULE NOT FOUND",
        "  CYBERIMPLANT OUT ............ MODULE NOT FOUND",
        "Memory scan .................. COMPLETE",
    },
    [7] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ MODULE NOT FOUND",
        "  CYBERIMPLANT OUT ............ MODULE NOT FOUND",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... IN PROGRESS",
    },
    [8] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ LINK ESTABLISHED",
        "  CYBERIMPLANT OUT ............ LINK ESTABLISHED",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... COMPLETE",
    },
    [9] = {
        "IMPLANT REGISTERED",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ LINK ESTABLISHED",
        "  CYBERIMPLANT OUT ............ LINK ESTABLISHED",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... COMPLETE",
        "Binding organism table ...",
    },
    [10] = {
        "INITIALIZING",
        "Initializing neural bridge...",
        "HARDWARE INTEGRITY CHECK:",
        "  NEURAL INTERFACE ........... OK",
        "  BLOOD MONITOR .............. OK",
        "  CARDIAC SENSORS ............ OK",
        "  PAIN RECEPTORS ............. OK",
        "  SERVO ACTUATORS ............ OK",
        "  NEUROLINK IN ............ LINK ESTABLISHED",
        "  CYBERIMPLANT OUT ............ LINK ESTABLISHED",
        "Memory scan .................. COMPLETE",
        "Implant calibration .......... COMPLETE",
        "Binding organism table ...",
        "echo \"INSTALLATION FINISHED\"",
    },
}

function PANEL:Init()
    system.FlashWindow()

    sound.PlayFile("sound/zbattle/startup2.ogg", "", function() end)
    sound.PlayFile("sound/zbattle/startup_scan.ogg", "", function() end)
    timer.Simple(4.4, function()
    sound.PlayFile("sound/zbattle/scan_flash.ogg", "", function() end)
    end)

    self.progress   = 0
    self.alpha      = 255
    self.alphagrid  = 255
    self.blur       = 5
    self.done       = false
    self.flash      = 0
    self.initAnim   = 0
    self.initAnim2  = 0
    self.haveanicedayalpha = 0
    self.BootStage  = 1

    self:SetSize(sw, sh)
    self:RequestFocus()

    if IsValid(hg.implantload) then hg.implantload:Remove() end
    hg.implantload = self

    self:CreateAnimation(2.5, {
        index = 5,
        target = { blur = 0 },
        easing = "linear",
        bIgnoreConfig = true,
    })

    timer.Simple(2, function()
        if not IsValid(self) then return end
        self:CreateAnimation(0.5, {
            index = 10,
            target = { progress = math.Rand(0.01, 0.1) },
            easing = "outQuint",
            bIgnoreConfig = true,
            OnComplete = function()
                self:CreateAnimation(1.5, {
                    index = 11,
                    target = { progress = math.Rand(0.6, 0.9) },
                    easing = "linear",
                    bIgnoreConfig = true,
                    OnComplete = function()
                        self:CreateAnimation(1, {
                            index = 12,
                            target = { progress = 1 },
                            easing = "outQuint",
                            bIgnoreConfig = true,
                            OnComplete = function()
                                timer.Simple(0.5, function()
                                    if IsValid(self) then self:Close() end
                                end)
                            end
                        })
                    end
                })
            end
        })
    end)

    self:CreateAnimation(1, {
        index = 20,
        target = { initAnim = 1 },
        easing = "linear",
        bIgnoreConfig = true,
        OnComplete = function()
            self:CreateAnimation(10, {
                index = 21,
                target = { initAnim2 = 1 },
                easing = "linear",
                bIgnoreConfig = true,
            })
        end
    })

    local BootTimes = { 1, 2, 2.2, 2.5, 2.7, 4.2, 4.3, 4.9, 6.2, 6.5 }
    for k, v in ipairs(BootTimes) do
        timer.Simple(v, function()
            if IsValid(self) then self.BootStage = k end
        end)
    end

    self.matrixX      = 80
    self.matrixY      = 42 + 10
    self.CursorLength = 10

    self.TextArray = {}
    self.RandomAlpha = {}
    self.RandomFlash = {}
    self.RandomDelay = {}

    for x = 1, self.matrixX do
        self.RandomDelay[x] = RealTime() + 3 + math.Rand(0, 0.1)
        self.TextArray[x]   = {}
        self.RandomAlpha[x] = {}
        self.RandomFlash[x] = {}
        for y = 1, self.matrixY do
            self.TextArray[x][y]   = math.random(0, 2) == 2 and "1" or "0"
            self.RandomAlpha[x][y] = math.Rand(0.5, 1)
            self.RandomFlash[x][y] = math.random(1, 10) == 1 or nil
        end
    end

    timer.Simple(4.9, function()
        if not IsValid(self) then return end
        self.flash = 1
        for x = 1, self.matrixX do
            for y = 1, self.matrixY do
                if self.RandomFlash[x][y] then
                    self.TextArray[x][y] = self.TextArray[x][y] == "0" and "1" or "0"
                end
            end
        end
        self:CreateAnimation(2, {
            index = 40,
            target = { flash = 0 },
            easing = "outQuint",
            bIgnoreConfig = true
        })
    end)
end

function PANEL:Close()

    sound.PlayFile("sound/zbattle/login.wav", "", function() end)

    self.done = true
    self.alpha = 255
    self.haveanicedayalpha = 255

    timer.Simple(1, function()
        if not IsValid(self) then return end
        self:CreateAnimation(1, {
            index = 2,
            target = { alpha = 0 },
            easing = "linear",
            bIgnoreConfig = true,
            Think = function() self:SetAlpha(self.alpha) end,
            OnComplete = function()
                self:CreateAnimation(5, {
                    index = 4,
                    target = { haveanicedayalpha = 0 },
                    easing = "outQuint",
                    bIgnoreConfig = true,
                    Think = function() self:SetAlpha(self.alpha) end,
                    OnComplete = function() self:Remove() end
                })
            end
        })
    end)

    self:CreateAnimation(1, {
        index = 3,
        target = { alphagrid = 0 },
        easing = "linear",
        bIgnoreConfig = true,
    })
end

function PANEL:DrawMatrix()
    local init2          = self.initAnim2
    local BootUpProgress = self.progress
    local MatrixCursorPos = math.Round((1 - BootUpProgress) * (self.matrixY + 1))

    if self.alpha <= 0 then return end

    for x = 1, self.matrixX do
        for y = 1, self.matrixY do
            local posX = sw / self.matrixX * (x - 1)
            local posY = sh / (self.matrixY - self.CursorLength) * ((y - self.CursorLength) - 1)

            if posY > sh or posY < 0 then continue end

            local alpha = init2 * self.RandomAlpha[x][y]
            local pos   = MatrixCursorPos

            if y == pos then
                draw.GlowingText(self.TextArray[x][y], "NL_OSMatrix", posX, posY,
                    ColorAlpha(cyan, alpha * 255),
                    ColorAlpha(cyandark, alpha * 255),
                    ColorAlpha(cyanfaint, alpha * 255))
            else
                local color
               if y < pos then
                    color = ColorAlpha(cyandark, 8 * alpha)
               else
                 color = ColorAlpha(cyan, math.Clamp(180 - ((y - pos) * (180 / self.CursorLength)), 8, 180) * alpha)
            end
                draw.SimpleText(self.TextArray[x][y], "NL_OSMatrix", posX, posY, color)
            end

            if self.flash >= 0 and self.RandomFlash[x][y] then
                draw.GlowingText("▓", "NL_OSMatrix", posX, posY + ScreenScale(3),
                    ColorAlpha(cyan, self.flash * alpha * 255),
                    ColorAlpha(cyandark, self.flash * alpha * 255),
                    ColorAlpha(cyanfaint, self.flash * alpha * 255))
            end
        end
    end
end

function PANEL:Paint()
    local BootUpProgress = self.progress
    local init           = self.initAnim
    local init2          = self.initAnim2 * 10

    surface.SetDrawColor(0, 0, 0, init * 255)
    surface.DrawRect(-10, -10, sw + 10, sh + 10)

    local xbars, ybars = 17, 30
    surface.SetDrawColor(0, 180, 200, 0.6 * self.alphagrid / 255)
    for i = 1, ybars + 1 do
        surface.DrawRect((sw / ybars) * i - (CurTime() * 30 % (sw / ybars)), 0, ScreenScale(1), sh)
    end
    for i = 1, xbars + 1 do
        surface.DrawRect(0, (sh / xbars) * (i - 1) + (CurTime() * 30 % (sh / xbars)), sw, ScreenScale(1))
    end

    self:DrawMatrix()

    local text = "Scanning..."
    local trim = 12 + (math.Round(CurTime()) % 3)
    text = string.Left(text, trim)

    local rainbow = HSVToColor(CurTime() * 50 % 360, 0.6, 0.9)
    draw.GlowingText("NEUROLINK", "NL_OSLarge",
    sw * 0.5 + ScreenScale(1), sh * 0.3 + ScreenScale(1),
    ColorAlpha(rainbow, 80 * init2),
    ColorAlpha(rainbow, 10 * init2),
    ColorAlpha(rainbow, 2 * init2),
    TEXT_ALIGN_CENTER)
    draw.GlowingText("NEUROLINK", "NL_OSLarge",
    sw * 0.5, sh * 0.3,
    ColorAlpha(cyanglow, 255 * init2),
    ColorAlpha(cyan, 200 * init2),
    ColorAlpha(cyandark, 80 * init2),
    TEXT_ALIGN_CENTER)

    draw.GlowingText(text, "NL_OSMedium",
        sw * 0.4, sh * 0.485,
        ColorAlpha(cyan, 255 * init2),
        ColorAlpha(cyandark, 50 * init2),
        ColorAlpha(cyanfaint, 10 * init2))

    draw.GlowingText(math.Round(BootUpProgress * 100) .. "%", "NL_OSSmall",
        sw * 0.6, sh * 0.5,
        ColorAlpha(cyan, 255 * init2),
        ColorAlpha(cyandark, 50 * init2),
        ColorAlpha(cyanfaint, 10 * init2),
        TEXT_ALIGN_RIGHT)

    surface.SetDrawColor(ColorAlpha(color_black, 100 * init2))
    surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2, sh * 0.02)

    surface.SetDrawColor(ColorAlpha(cyan, 255 * init2))
    surface.DrawRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

    surface.SetDrawColor(0, 200, 220, 255 * init2)
    surface.SetMaterial(gradient_l)
    surface.DrawTexturedRect(sw * 0.4, sh * 0.52, sw * 0.2 * BootUpProgress, sh * 0.02)

    surface.SetDrawColor(ColorAlpha(cyan, 255 * init2))
    surface.DrawOutlinedRect(sw * 0.4 - 5, sh * 0.52 - 5, sw * 0.2 + 10, sh * 0.02 + 10)

    local stages = BootStages[self.BootStage] or BootStages[1]
    for i, line in ipairs(stages) do
        draw.SimpleText(line, "NL_OSSmall",
            sw * 0.012,
            sh * 0.05 + (i - 1) * ScreenScale(5),
            ColorAlpha(cyan, 255 * init2),
            TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

local pp_tab = {
    ["$pp_colour_brightness"] = 0,
    ["$pp_colour_contrast"]   = 1,
}

hook.Add("RenderScreenspaceEffects", "implantload_pp", function()
    if IsValid(hg.implantload) and hg.implantload.alpha ~= 255 then
        pp_tab["$pp_colour_brightness"] = hg.implantload.alpha / 255
        DrawColorModify(pp_tab)

        local alpha = hg.implantload.haveanicedayalpha
        draw.SimpleText("INSTALLATION COMPLETE.", "NL_OSMedium",
            sw * 0.5 + 2, sh * 0.8 + 2,
            ColorAlpha(color_black, 255 * alpha),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("INSTALLATION COMPLETE.", "NL_OSMedium",
            sw * 0.5, sh * 0.8,
            ColorAlpha(cyan, 255 * alpha),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)

vgui.Register("ZC_ImplantLoading", PANEL, "EditablePanel")

hook.Add("HUDPaint", "Neurolink_ChargeJumpBar", function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    if not ply.chargestart then return end
    
    local hasNeurolink = ply:GetNetVar("implant_neurolink_basic") or 
                         ply:GetNetVar("implant_neurolink_military") or 
                         ply:GetNetVar("implant_neurolink_militaryplus")
    if not hasNeurolink then return end
    
    local chargeTime = CurTime() - ply.chargestart
    local maxCharge = 3.0
    local progress = math.Clamp(chargeTime / maxCharge, 0, 1)
    
    local barW = ScrW() * 0.3
    local barH = ScreenScale(4)
    local barX = ScrW() * 0.5 - barW * 0.5
    local barY = ScrH() * 0.85
    
    draw.RoundedBox(2, barX, barY, barW, barH, Color(20, 5, 8, 200))
    
    local fillColor = progress >= 1 and Color(255, 180, 20, 255) or Color(255, 40, 60, 255)
    draw.RoundedBox(2, barX, barY, barW * progress, barH, fillColor)
    
    surface.SetDrawColor(255, 40, 60, 150)
    surface.DrawRect(barX, barY, barW, 1)
    surface.DrawRect(barX, barY + barH, barW, 1)
    
    if progress > 0.1 then
        draw.DrawText("CHARGING", "NL_Menu_Tiny", barX + barW * 0.5, barY - ScreenScale(6),
            Color(255, 100, 100, 200), TEXT_ALIGN_CENTER)
    end
end)

print("[ZC CYBERWARE] implant loading screen loaded")