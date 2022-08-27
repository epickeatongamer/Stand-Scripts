--natives
util.require_natives("1640181023")

--functions
local function draw_text(text_x, text_y, content, color)
    directx.draw_text(
    text_x,
    text_y,
    content,
    ALIGN_TOP_LEFT,
    0.4,
    color,
    false
    )
end
local function draw_rect(rect_x, rect_y, rect_w, rect_h, color)
    directx.draw_rect(
        rect_x,
        rect_y,
        rect_w,
        rect_h,
        color
        )
end
local function draw_line(line_x_1, line_y_1, line_x_2, line_y_2, color)
    directx.draw_line(
        line_x_1, 
        line_y_1, 
        line_x_2, 
        line_y_2, 
        color
        )
end
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
local function text_width_func(text)
    local text_og_width = directx.get_text_size(text, 0.4)
    local text_width = round(text_og_width, 3)
    return text_width
end
--from lance, ty
all_weapons = {}
temp_weapons = util.get_weapons()
for a,b in pairs(temp_weapons) do
    all_weapons[#all_weapons + 1] = {hash = b['hash'], label_key = b['label_key']}
end
function get_weapon_name_from_hash(hash) 
    for k,v in pairs(all_weapons) do 
        if v.hash == hash then 
            return util.get_label_text(v.label_key)
        end
    end
    return 'Unarmed'
end
local function dec_to_ipv4(ip)
	return string.format(
		"%i.%i.%i.%i", 
		ip >> 24 & 0xFF, 
		ip >> 16 & 0xFF, 
		ip >> 8  & 0xFF, 
		ip 		 & 0xFF
	)
end
local function bool_to_yes_no(bool)
    if bool then 
        return "Yes"
    else
        return "No"
    end
end
local function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end
--function from jay, ty
local function isFriend(PlayerId)
    return table.contains(players.list(false,true,false), PlayerId)
end
--these few functions are from nowiry, ty
read_global = {
	byte = function(global)
		local address = memory.script_global(global)
		return address ~= NULL and memory.read_byte(address) or nil
	end,
	int = function(global)
		local address = memory.script_global(global)
		return address ~= NULL and memory.read_int(address) or nil
	end,
	float = function(global)
		local address = memory.script_global(global)
		return address ~= NULL and memory.read_float(address) or nil
	end,
	string = function(global)
		local address = memory.script_global(global)
		return address ~= NULL and memory.read_string(address) or nil
	end
}
local function BitTest(bits, place)
	return (bits & (1 << place)) ~= 0
end
local function IsPlayerUsingOrbitalCannon(player)
    if player ~= -1 then
        local bits = read_global.int(2689235 + (player * 453 + 1) + 416)
        return BitTest(bits, 0)
    end
    return false
end
local function IsPlayerFlyingAnyDrone(player)
	local address = memory.script_global(1853348 + (player * 834 + 1) + 267 + 348)
	return BitTest(memory.read_int(address), 26)
end
local function IsPlayerInRcBandito(player)
    if player ~= -1 then
        local address = memory.script_global(1853348 + (player * 834 + 1) + 267 + 348)
        return BitTest(memory.read_int(address), 29)
    end
    return false
end
local function IsPlayerInRcTank(player)
    if player ~= -1 then
        local address = memory.script_global(1853348 + (player * 834 + 1) + 267 + 408 + 2)
        return BitTest(memory.read_int(address), 16)
    end
    return false
end
local function IsPlayerInRcPersonalVehicle(player)
    if player ~= -1 then
        local address = memory.script_global(1853348 + (player * 834 + 1) + 267 + 408 + 3)
        return BitTest(memory.read_int(address), 6)
    end
    return false
end

--locals
local overlay_x = 0.01
local overlay_y = 0.01

--ty lance for languages :)
local languages = {
    [0] = "English",
    [1] = "French",
    [2] = "German",
    [3] = "Italian",
    [4] = "Spanish",
    [5] = "Brazilian",
    [6] = "Polish",
    [7] = "Russian",
    [8] = "Korean",
    [9] = "Chinese (Traditional)",
    [10] = "Japanese",
    [11] = "Mexican",
    [12] = "Chinese (Simplified)"
}

--set location
menu.slider_float(menu.my_root(), "Overlay X", {"playerinfox"}, "", -1000, 1000, 0, 1, function(s)
    overlay_x = s * 0.001
end)
menu.slider_float(menu.my_root(), "Overlay Y", {"playerinfoy"}, "", -1000, 1000, 0, 1, function(s)
    overlay_y = s * 0.001
end)

--info overlay
menu.toggle(menu.my_root(), "Information Overlay", {}, "", function(state)
    UItoggle = state
    while UItoggle do
        if not util.is_session_transition_active() and NETWORK.NETWORK_IS_SESSION_STARTED() then
            local focused_tbl = players.get_focused()
            if focused_tbl[1] ~= nil and menu.is_open() then 
                --settings colours
                local txtcolor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
                local backgroundcolor = {r = 0.0, g = 0.0, b = 0.0, a = 1.0}
                local bordercolor = {r = 1.0, g = 0.0, b = 1.0, a = 1.0}

                --grabbing information on player
                local focused = focused_tbl[1]
                local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(focused)
                local mypos = players.get_position(players.user())
                local mypid = players.user()
                local playerpos = players.get_position(focused)
                local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                local script_host = players.get_script_host()
                local host = players.get_host()
                local text_width = 0
                local name = players.get_name(focused)
                local pid = focused
                local h = bool_to_yes_no(focused == host)
                local sh = bool_to_yes_no(focused == script_host)
                local rank = players.get_rank(focused)
                local rid1 = players.get_rockstar_id(focused)
                local rid2 = players.get_rockstar_id_2(focused)
                local rid = if rid1 == rid2 then rid1 else rid1.."/"..rid2
                local modder = bool_to_yes_no(players.is_marked_as_modder(focused))
                local godmode = bool_to_yes_no(players.is_godmode(focused))
                local friend = bool_to_yes_no(isFriend(focused))
                local language = languages[players.get_language(focused)]
                local health = tostring(ENTITY.GET_ENTITY_HEALTH(ped)).."/"..tostring(ENTITY.GET_ENTITY_MAX_HEALTH(ped))
                local armor = tostring(PED.GET_PED_ARMOUR(ped)).."/"..tostring(PLAYER.GET_PLAYER_MAX_ARMOUR(focused))
                local wanted = PLAYER.GET_PLAYER_WANTED_LEVEL(focused)
                local vehicle = players.get_vehicle_model(focused)
                if vehicle == 0 then 
                    vehicle_name = "N/A"
                    in_vehicle = "No"
                else
                    vehicle_name = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(vehicle))
                    in_vehicle = "Yes"
                end
                local vehicle = vehicle_name
                local interior = bool_to_yes_no(players.is_in_interior(focused))
                local distance = math.ceil(MISC.GET_DISTANCE_BETWEEN_COORDS(playerpos.x, playerpos.y, playerpos.z, mypos.x, mypos.y, mypos.z))
                local position = "X: "..math.floor(playerpos.x).." |  Y: "..math.floor(playerpos.y).." |  Z: "..math.floor(playerpos.z)
                local token = players.get_host_token(focused)
                local ip = dec_to_ipv4(players.get_connect_ip(focused))
                local wallet = "$"..format_int(players.get_wallet(focused))
                local bank = "$"..format_int(players.get_bank(focused))
                local total = "$"..format_int(players.get_money(focused))
                local weapon_hash = WEAPON.GET_SELECTED_PED_WEAPON(ped)
                local weapon = get_weapon_name_from_hash(weapon_hash)
                local tags = players.get_tags_string(focused)
                if tags == "" then
                    tags = "N/A"
                end
                if focused == host and focused == mypid then
                    ping = "Self and Host"
                elseif focused == host then
                    ping = "Host"
                elseif focused == mypid then
                    ping = "Self"
                else
                    latency = NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(focused)
                    ping = math.floor(latency+0.5).."ms"
                end
                if NETWORK.NETWORK_IS_PLAYER_ACTIVE(pid) then
                    state = "Connnected to lobby"
                else
                    state = "Connecting to lobby"
                end
                local aiming = bool_to_yes_no(PLAYER.IS_PLAYER_FREE_AIMING(focused))
                local orbital = bool_to_yes_no(IsPlayerUsingOrbitalCannon(focused))
                local rc_drone = bool_to_yes_no(IsPlayerFlyingAnyDrone(focused))
                local rc_bandito = bool_to_yes_no(IsPlayerInRcBandito(focused))
                local rc_tank = bool_to_yes_no(IsPlayerInRcTank(focused))
                local rc_personal = bool_to_yes_no(IsPlayerInRcPersonalVehicle(focused))
                local attacker = bool_to_yes_no(players.is_marked_as_attacker(focused))
                local kd = round(players.get_kd(focused), 2)

                --setting dimensions of the main gui
                local guix = overlay_x
                local guiy = overlay_y
                local guiw = 0.15
                local guih = -0.02
                for i = 1, 22 do
                    guih = guih + 0.02
                end

                --setting coords of overlay
                local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --setting info list coords

                --drawing gui
                border = draw_rect(guix - 0.0012, guiy - 0.022, guiw + 0.0024, guih + 0.024, bordercolor)
                titles = draw_rect(guix, guiy - 0.02, guiw, 0.02, backgroundcolor)
                background = draw_rect(guix, guiy, guiw, guih, backgroundcolor)
                divider1 = draw_line(playerlistx + guiw/2 - 0.002, playerlisty, playerlistx + guiw/2 - 0.002, playerlisty + 0.02*7, bordercolor)
                divider2 = draw_line(playerlistx + guiw/2 - 0.002, playerlisty + guih - 0.02*7, playerlistx + guiw/2 - 0.002, playerlisty + guih, bordercolor)

                --name
                local yoffset = 0.02
                local text_width = text_width_func(name)
                draw_text(playerlistx + guiw/2 - text_width/2, playerlisty - yoffset, name, txtcolor)

                --pid
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(pid)
                draw_text(playerlistx, playerlisty - yoffset, "PID: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, pid, txtcolor)

                --rid
                local text_width = text_width_func(rid)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "RID: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, rid, txtcolor)

                --rank
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(rank)
                draw_text(playerlistx, playerlisty - yoffset, "Rank: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, rank, txtcolor)

                --wanted level
                local text_width = text_width_func(wanted)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "Wanted Level: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, wanted, txtcolor)

                --ip
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(ip)
                draw_text(playerlistx, playerlisty - yoffset, "IP: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, ip, txtcolor)

                --ping
                local text_width = text_width_func(ping)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "Ping: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, ping, txtcolor)

                --language
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(language)
                draw_text(playerlistx, playerlisty - yoffset, "Language: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, language, txtcolor)

                --distance
                local text_width = text_width_func(distance)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "Distance: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, distance, txtcolor)

                --health
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(health)
                draw_text(playerlistx, playerlisty - yoffset, "Health: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, health, txtcolor)

                --armor
                local text_width = text_width_func(armor)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "Armor: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, armor, txtcolor)

                --wallet
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(wallet)
                draw_text(playerlistx, playerlisty - yoffset, "Wallet: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, wallet, txtcolor)

                --bank
                local text_width = text_width_func(bank)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "Bank: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, bank, txtcolor)

                --kd
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(kd)
                draw_text(playerlistx, playerlisty - yoffset, "KD: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, kd, txtcolor)

                --total money
                local text_width = text_width_func(total)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "Total: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, total, txtcolor)

                --vehicle
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(vehicle)
                draw_text(playerlistx, playerlisty - yoffset, "Vehicle: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, vehicle, txtcolor)

                -- --player tags
                -- local yoffset = yoffset + -0.02
                -- local text_width = text_width_func(tags)
                -- draw_text(playerlistx, playerlisty - yoffset, "Tags: ", txtcolor)
                -- draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, tags, txtcolor)
                
                --connection state
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(state)
                draw_text(playerlistx, playerlisty - yoffset, "Connection State: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, state, txtcolor)

                --host token
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(token)
                draw_text(playerlistx, playerlisty - yoffset, "Host Token: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, token, txtcolor)

                --position
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(position)
                draw_text(playerlistx, playerlisty - yoffset, "Position: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, position, txtcolor)

                --current weapon
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(weapon)
                draw_text(playerlistx, playerlisty - yoffset, "Current Weapon: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, weapon, txtcolor)
                
                --checks
                local yoffset = yoffset + -0.04
                local text_width = text_width_func("Checks")
                draw_text(playerlistx + guiw/2 - text_width/2, playerlisty - yoffset, "Checks", txtcolor)

                --host
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(h)
                draw_text(playerlistx, playerlisty - yoffset, "Is Host: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, h, txtcolor)

                --interior
                local text_width = text_width_func(interior)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In Interior: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, interior, txtcolor)

                --script host
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(sh)
                draw_text(playerlistx, playerlisty - yoffset, "Is Script Host: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, sh, txtcolor)

                --in orbital
                local text_width = text_width_func(orbital)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In Orbital: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, orbital, txtcolor)

                --attacker
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(attacker)
                draw_text(playerlistx, playerlisty - yoffset, "Is Attacker: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, attacker, txtcolor)

                --in vehicle
                local text_width = text_width_func(in_vehicle)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In Vehicle: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, in_vehicle, txtcolor)

                --friend
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(friend)
                draw_text(playerlistx, playerlisty - yoffset, "Is Friend: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, friend, txtcolor)

                --rc drone
                local text_width = text_width_func(rc_drone)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In RC Drone: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, rc_drone, txtcolor)

                --godmode
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(godmode)
                draw_text(playerlistx, playerlisty - yoffset, "Is Godmode: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, godmode, txtcolor)

                --rc bandito
                local text_width = text_width_func(rc_bandito)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In RC Bandito: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, rc_bandito, txtcolor)

                --modder
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(modder)
                draw_text(playerlistx, playerlisty - yoffset, "Is Modder: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, modder, txtcolor)

                --rc tank
                local text_width = text_width_func(rc_tank)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In RC Tank: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, rc_tank, txtcolor)

                --aiming
                local yoffset = yoffset + -0.02
                local text_width = text_width_func(aiming)
                draw_text(playerlistx, playerlisty - yoffset, "Is Aiming: ", txtcolor)
                draw_text(playerlistx + guiw/2 - text_width - 0.005, playerlisty - yoffset, aiming, txtcolor)

                --rc personal
                local text_width = text_width_func(rc_personal)
                draw_text(playerlistx + guiw/2, playerlisty - yoffset, "In RC Personal: ", txtcolor)
                draw_text(playerlistx + guiw - text_width - 0.005, playerlisty - yoffset, rc_personal, txtcolor)

                util.remove_handler(player_vehicle) --stop possible crash from too many handles
            end
        end
        util.yield()
    end
end)

--keep script running
util.keep_running() 