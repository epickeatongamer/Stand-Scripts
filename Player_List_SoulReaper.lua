--natives
util.require_natives("1640181023")

--folders
txt = menu.list(menu.my_root(), "Text RGB", {}, "", function(); end) 
background = menu.list(menu.my_root(), "Background RGB", {}, "", function(); end) 
border = menu.list(menu.my_root(), "Border RGB", {}, "", function(); end) 

--locals
local txtr = 1 --default red of text colour
local txtg = 1 --default green of text colour
local txtb = 1 --default blue of text colour
local backgroundr = 0 --default red of background colour
local backgroundg = 0 --default green of background colour
local backgroundb = 0 --default blue of background colour
local borderr = 255 --default red of border colour
local borderg = 0 --default green of border colour
local borderb = 255 --default blue of border colour

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

--text RGB
menu.slider(txt, "Red", {"borderr"}, "", 0, 255, 1, 1, function(txtcr)
	txtr = txtcr
end)
menu.slider(txt, "Green", {"borderg"}, "", 0, 255, 1, 1, function(txtcg)
	txtg = txtcg
end)
menu.slider(txt, "Blue", {"borderb"}, "", 0, 255, 1, 1, function(txtcb)
	txtb = txtcb
end)

--background RGB
menu.slider(background, "Red", {"backgroundrr"}, "", 0, 255, 0, 1, function(backgroundcr)
	backgroundr = backgroundcr
end)
menu.slider(background, "Green", {"backgroundg"}, "", 0, 255, 0, 1, function(backgroundcg)
	backgroundg = backgroundcg
end)
menu.slider(background, "Blue", {"backgroundb"}, "", 0, 255, 0, 1, function(backgroundcb)
	backgroundb = backgroundcb
end)

--border RGB
menu.slider(border, "Red", {"borderr"}, "", 0, 255, 255, 1, function(bordercr)
	borderr = bordercr
end)
menu.slider(border, "Green", {"borderg"}, "", 0, 255, 0, 1, function(bordercg)
	borderg = bordercg
end)
menu.slider(border, "Blue", {"borderb"}, "", 0, 255, 255, 1, function(bordercb)
	borderb = bordercb
end)

--show the current rgb values
menu.action(menu.my_root(), "Show current RGB values", {}, "", function()
	util.toast("Current RGB values\nText: "..txtr..", "..txtg..", "..txtb.."\nBackground: "..backgroundr..", "..backgroundg..", "..backgroundb.."\nBorder: "..borderr..", "..borderg..", "..borderb)
end)

menu.toggle(menu.my_root(), "GUI", {}, "", function(state)
    UItoggle = state
    while UItoggle do
        --settings colours
        local txtcolor = {r = txtr, g = txtg, b = txtb, a = 1.0}
        local backgroundcolor = {r = backgroundr, g = backgroundg, b = backgroundb, a = 1.0}
        local bordercolor = {r = borderr, g = borderg, b = borderb, a = 1.0}

        --making the main gui
        local player_table = players.list()
        local guix = 0.2
        local guiy = 0.1
        local guiw = 0.506
        local guih = 0.02
        for i, pid in pairs(player_table) do
            guih = guih + 0.02
        end
        guih = guih - 0.02

        --drawing gui
        border = draw_rect(guix - 0.0012, guiy - 0.022, guiw + 0.0024, guih + 0.024, bordercolor)
        titles = draw_rect(guix, guiy - 0.02, guiw, 0.02, backgroundcolor)
        background = draw_rect(guix, guiy, guiw, guih, backgroundcolor)

        --draw pid section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --setting player list coords
        draw_line(playerlistx - 0.002, playerlisty - 0.003, playerlistx + 0.5045, playerlisty - 0.003, bordercolor) --draw line under the titles
        draw_text(playerlistx, playerlisty - 0.02, "   Pid", txtcolor) --draw title
        for i, pid in pairs(player_table) do --creates it for all the players
            local player_table = players.list()
            local playername = players.get_name(pid)
            draw_text(playerlistx, playerlisty, "Pid: "..pid, txtcolor)
            draw_line(playerlistx - 0.002, playerlisty + 0.018, playerlistx + 0.5045, playerlisty + 0.018, bordercolor) --draw line under all the players
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.027, guiy - 0.02, playerlistx + 0.027, guiy + guih, bordercolor) --draw line to the right of pid section

        --draw username section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.03, playerlisty - 0.02, "        Rockstar Username", txtcolor)  --draw username title
        for i, pid in pairs(player_table) do --creates it for all the players
            local player_table = players.list()
            local playername = players.get_name(pid)
            draw_text(playerlistx + 0.03, playerlisty, "Username: "..playername, txtcolor)
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.127, guiy - 0.02, playerlistx + 0.127, guiy + guih, bordercolor)

        --draw rid section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.13, playerlisty - 0.02, "    Rockstar id", txtcolor)  --draw rid title
        for i, pid in pairs(player_table) do --creates it for all the players
            local player_table = players.list()
            local playerrid = players.get_rockstar_id(pid)
            draw_text(playerlistx + 0.13, playerlisty, "Rid: "..playerrid, txtcolor)
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.185, guiy - 0.02, playerlistx + 0.185, guiy + guih, bordercolor)

        --draw ping section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.188, playerlisty - 0.02, "     Ping", txtcolor)  --draw player ping title
        for i, pid in pairs(player_table) do --creates it for all the players
            local player_table = players.list()
            host = players.get_host()
            self = players.user()
            if pid == host then
                draw_text(playerlistx + 0.188, playerlisty, "Ping: HOST", txtcolor) --this only draws when the player is host as they are the one being connected to so they will always be at 0 ping to the lobby
            else
                if pid == self then
                    draw_text(playerlistx + 0.188, playerlisty, "Ping: SELF", txtcolor) --this only draws when player is yourself as your own ping always returns 0
                else
                ping = NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(pid)
                draw_text(playerlistx + 0.188, playerlisty, "Ping: "..math.floor(ping+0.5), txtcolor)
                end
            end
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.2269, guiy - 0.02, playerlistx + 0.2269, guiy + guih, bordercolor)

        --draw vehicle section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.229, playerlisty - 0.02, "        Vehicle Status", txtcolor)  --draw vehicle status title
        for i, pid in pairs(player_table) do --creates it for all the players
            playerinfo1 = players.get_vehicle_model(pid)
            if players.get_vehicle_model(pid) == 0 then
            draw_text(playerlistx + 0.2299, playerlisty, "Vehicle: Not in vehicle", txtcolor) --draws when player is not in a vehicle currently
            else
            draw_text(playerlistx + 0.2299, playerlisty, "Vehicle: "..VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(playerinfo1), txtcolor) --if player is in a vehicle this shows the vehicle model/spawn name
            end
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.307, guiy - 0.02, playerlistx + 0.307, guiy + guih, bordercolor)

        --draw ceo/mc section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.31, playerlisty - 0.02, "           CEO/MC", txtcolor)  --draw ceo/mc boss title
        for i, pid in pairs(player_table) do --creates it for all the players
            if players.get_boss(pid) == -1 then
            draw_text(playerlistx + 0.31, playerlisty, "Boss: Not in a CEO/MC", txtcolor) --draws when player is not in a ceo/mc currently
            else
            boss = players.get_boss(pid)
            draw_text(playerlistx + 0.31, playerlisty, "Boss: "..PLAYER.GET_PLAYER_NAME(boss), txtcolor) --shows the boss/leader of the players current ceo/mc
            end
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.385, guiy - 0.02, playerlistx + 0.385, guiy + guih, bordercolor)

        --draw interior section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.388, playerlisty - 0.02, "    Interior", txtcolor)  --draw interior status title
        for i, pid in pairs(player_table) do --creates it for all the players
            if players.is_in_interior(pid) == true then
            draw_text(playerlistx + 0.388, playerlisty, "State: True", txtcolor) --if state is true it means the player is in a interior
            else
            draw_text(playerlistx + 0.388, playerlisty, "State: False", txtcolor) --if state is not true it means the player is not in a interior
            end
            playerlisty = playerlisty + 0.02
        end
        draw_line(playerlistx + 0.43, guiy - 0.02, playerlistx + 0.43, guiy + guih, bordercolor)

        --draw state section
        local playerlistx, playerlisty = guix + 0.002, guiy + 0.002 --resetting player list coords
        draw_text(playerlistx + 0.433, playerlisty - 0.02, "              State", txtcolor)  --draw lobby connetion status title
        for i, pid in pairs(player_table) do --creates it for all the players
            if NETWORK.NETWORK_IS_PLAYER_ACTIVE(pid) == true then
            draw_text(playerlistx + 0.433, playerlisty, "Connected to lobby", txtcolor) --draws when player is connected to the lobby
            else
            draw_text(playerlistx + 0.433, playerlisty, "Connecting to lobby", txtcolor) --draws when player is connecting to the lobby
            end
            playerlisty = playerlisty + 0.02
        end
        util.yield() --this little yield here is VERY important if you don't want the game to insta crash, i have forgot this many many times
    end
end)

--keep script running
util.keep_running() 