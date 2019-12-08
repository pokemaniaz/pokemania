function init()
	connect(g_game, { onGameEnd = onGameEnd })
	ProtocolGame.registerExtendedOpcode(130, function(protocol, opcode, buffer)
	
	local strings = string.explode(buffer, '|')
	print(#strings)
	
	if not strings[36] or strings[36] ~= "true" then
		show(strings[1], strings[2], strings[3], strings[4], strings[5], strings[6], strings[7], strings[8], strings[9], strings[10], strings[11], strings[12], strings[13], strings[14], strings[15], strings[16], strings[17], strings[18], strings[19], strings[20], strings[21], strings[22], strings[23], strings[24], strings[25], strings[26], strings[27], strings[28], strings[29], strings[30], strings[31], strings[32], strings[33], strings[34], strings[35])
	end
	
	end)

	ProtocolGame.registerExtendedOpcode(131, function(protocol, opcode, buffer) local strings = string.explode(buffer, '|')  showWindow(strings[1], strings[2], strings[3], strings[4]) end)
	ProtocolGame.registerExtendedOpcode(132, function(protocol, opcode, buffer) local strings = string.explode(buffer, ':')  showDGShop(strings[1]) end)
  
	dpanelWindow = g_ui.displayUI('dpanel')
	dungeonWindow = g_ui.displayUI('dwindow')
	dgTimeLeft = g_ui.displayUI('timeleft')
	dgShop = g_ui.displayUI('shop')
	buyWindow = g_ui.displayUI('dobuy')
	dgTimeLeft:setParent(modules.game_interface.getMapPanel())
	connect(g_game, { onGameStart = function() dgTimeLeft:addAnchor(AnchorRight, 'parent', AnchorRight) dgTimeLeft:addAnchor(AnchorTop, 'parent', AnchorTop) dgTimeLeft:setMarginRight(3) dgTimeLeft:setMarginTop(3) end})
	hide()
	dgTimeLeft:setVisible(false)
	ProtocolGame.registerExtendedOpcode(133, function(protocol, opcode, buffer) setTimeLeft(buffer) end)
end

dungeonslevel = {
["01"] = 10,
["02"] = 14,
["03"] = 18,
["04"] = 22,
["05"] = 26,
["06"] = 30,
["07"] = 34,
["08"] = 38,
["09"] = 42,
["10"] = 46,
["11"] = 50,
["12"] = 54,
["13"] = 58,
["14"] = 62,
["15"] = 66,
["16"] = 70,
["17"] = 74,
["18"] = 78,
["19"] = 82,
["20"] = 86,
["21"] = 90,
["22"] = 94,
["23"] = 98,
["24"] = 102,
["25"] = 106,
["26"] = 110,
["27"] = 114,
["28"] = 118,
["29"] = 122,
["30"] = 126,
["31"] = 130,
["32"] = 134,
["33"] = 138,
}

function terminate()
	disconnect(g_game, { onGameEnd = onGameEnd })
	ProtocolGame.unregisterExtendedOpcode(130)
	ProtocolGame.unregisterExtendedOpcode(131)
	ProtocolGame.unregisterExtendedOpcode(132)
	ProtocolGame.unregisterExtendedOpcode(133)
	dpanelWindow:destroy()
	dungeonWindow:destroy()
	dgTimeLeft:destroy()
end

function onGameEnd()
	if dgTimeLeft:isVisible() then
		dgTimeLeft:hide()
	end
	hide()
	dgTimeLeft:setVisible(false)
	removeEvent(dgtlbeautyclock)
end

function show(thedpanel, level, clans, dungeon)

local painel = {
["Naturia"] = {panel = '/images/dungeons/dungeonpanelbase1'},
["Volcanic"] = {panel = '/images/dungeons/dungeonpanelbase1'}
}

local config = {
[1] = {
		name = "Rookie Forest Dungeon",
		img = '/images/dungeons/buttons/01on.png',
		imgoff = '/images/dungeons/buttons/01off.png',
		icon = 'dg1icon',
		levelacess = 10,
		clan = "Naturia"
	},
[2] = {
		name = "Outra Dungeon",
		img = '/images/dungeons/buttons/02on.png',
		imgoff = '/images/dungeons/buttons/02off.png',
		icon = 'dg2icon',
		levelacess = 25,
		clan = "Volcanic"
	}	
}

	if thedpanel == "false" then
		hide()
		return true
	end
	
	if not dpanelWindow:isVisible() then
		addEvent(function() g_effects.fadeIn(dpanelWindow, 250) end)
	end

	for a, b in pairs (painel) do
		if a == clans then
			dpanelWindow:show()
			dpanelWindow:setImageSource(b.panel)
		end	
	end
	
		dpanelWindow:raise()
		dpanelWindow:focus()
		level = tonumber(level)
		dg = tonumber(dungeon)
		
	for id, array in pairs(config) do	
		icone = dpanelWindow:getChildById(array.icon)
		if array.clan == clans then
			if dg == id then
				if level >= array.levelacess then
					icone:setVisible(true)
					icone:setTooltip(array.name)
					icone.onClick = function() g_game.talk("/opendgwindow 01,"..level..","..id) end
					icone:setImageSource(array.img)
				else
					icone:setVisible(true)
					icone:setImageSource(array.off)
					icone:setTooltip(array.name.."\n\nRequisitos:"..(level < array.levelacess and "\nVocê precisa ser do Level "..array.levelacess.."." or ""))
					icone.onClick = nil
				end
			end
		else
			icone:setVisible(false)
		end
	end
end

function showWindow(dungeonN, level, stars, timewait)

	if not dpanelWindow:isVisible() then 
		return true
	elseif not dungeonWindow:isVisible() then
		addEvent(function() g_effects.fadeIn(dungeonWindow, 250) end)
	end
	
	dungeonWindow:show()
	dungeonWindow:raise()
	dungeonWindow:focus()
	dungeonInfo = dungeonWindow:getChildById('dungeonInfo')
	dungeonInfo:setImageSource('/images/dungeons/infos/'..dungeonN..'.png')
	dungeonLevel = dungeonWindow:getChildById('dungeonLevel')
	level = tonumber(level)
	stars = tonumber(stars)
	
	if tonumber(dungeonN) <= 10 then
		if (dungeonslevel[dungeonN]+3) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'red.png')
		elseif (dungeonslevel[dungeonN]+10) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'orange.png')
		elseif (dungeonslevel[dungeonN]+20) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'yellow.png')
		elseif (dungeonslevel[dungeonN]+60) > level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'green.png')
		else
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'gray.png')
		end
	elseif tonumber(dungeonN) >= 11 and tonumber(dungeonN) <= 25 then
		if (dungeonslevel[dungeonN]+3) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'red.png')
		elseif (dungeonslevel[dungeonN]+10) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'orange.png')
		elseif (dungeonslevel[dungeonN]+30) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'yellow.png')
		elseif (dungeonslevel[dungeonN]+80) > level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'green.png')
		else
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'gray.png')
		end	
  elseif tonumber(dungeonN) >= 26 then
		if (dungeonslevel[dungeonN]+5) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'red.png')
		elseif (dungeonslevel[dungeonN]+15) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'orange.png')
		elseif (dungeonslevel[dungeonN]+40) >= level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'yellow.png')
		elseif (dungeonslevel[dungeonN]+100) > level then
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'green.png')
		else
			dungeonLevel:setImageSource('/images/dungeons/levels/'..dungeonN..'gray.png')
		end
  end
  
	dungeonStars = dungeonWindow:getChildById('stars')
	increaseStarsButton = dungeonWindow:getChildById('increaseStar')
	decreaseStarsButton = dungeonWindow:getChildById('decreaseStar')
  
	if stars == 2 then
		dungeonStars:setImageSource('/images/dungeons/starbutton/1a.png')
		increaseStarsButton:setImageSource('/images/dungeons/starbutton/+on.png')
	elseif stars >= 3 and stars <= 5 then
		dungeonStars:setImageSource('/images/dungeons/starbutton/1.png')
		increaseStarsButton:setImageSource('/images/dungeons/starbutton/+on.png')
	else
		dungeonStars:setImageSource('/images/dungeons/starbutton/1b.png')
		increaseStarsButton:setImageSource('/images/dungeons/starbutton/+off.png')
	end
  
	starselected = 1
	dungeonNumber = dungeonN
	totalstars = stars
  
	dungeonWindow:getChildById('item1'):setItemId(0)
	dungeonWindow:getChildById('item2'):setItemId(0)
	dungeonWindow:getChildById('item3'):setItemId(0)
	dungeonWindow:getChildById('item4'):setItemId(0)
	dungeonWindow:getChildById('item5'):setItemId(0)
	dungeonWindow:getChildById('item6'):setItemId(0)
	dungeonWindow:getChildById('item7'):setItemId(0)
	dungeonWindow:getChildById('item8'):setItemId(0)
	dungeonWindow:getChildById('item1'):setTooltip("")
	dungeonWindow:getChildById('item2'):setTooltip("")
	dungeonWindow:getChildById('item3'):setTooltip("")
	dungeonWindow:getChildById('item4'):setTooltip("")
	dungeonWindow:getChildById('item5'):setTooltip("")
	dungeonWindow:getChildById('item6'):setTooltip("")
	dungeonWindow:getChildById('item7'):setTooltip("")
	dungeonWindow:getChildById('item8'):setTooltip("")
  
	if dungeonN == "01" then
		dungeonWindow:getChildById('item1'):setItemId(15026)
		dungeonWindow:getChildById('item2'):setItemId(15009)
		dungeonWindow:getChildById('item3'):setItemId(15010)
		dungeonWindow:getChildById('item4'):setItemId(15011)
		dungeonWindow:getChildById('item5'):setItemId(12961)
		dungeonWindow:getChildById('item6'):setItemId(12963)
		dungeonWindow:getChildById('item1'):setTooltip("Bronze Ticket")
		dungeonWindow:getChildById('item2'):setTooltip("Magician Hat\nAddon para Pidgey")
		dungeonWindow:getChildById('item3'):setTooltip("Skeleton Mask\nAddon para Pidgey")
		dungeonWindow:getChildById('item4'):setTooltip("Zombie Mask\nAddon para Pidgey")
		dungeonWindow:getChildById('item5'):setTooltip("Wingeon Backpack")
		dungeonWindow:getChildById('item6'):setTooltip("Gardestrike Backpack")
	end
  
	local dgTimeWait = dungeonWindow:getChildById('dungeonTimeWait')
	
	if timewait and timewait ~= "already" and tonumber(timewait) and tonumber(timewait) > 0 then
		dgTimeWait:setVisible(true)
		removeEvent(dgtwbeautyclock)
		doBeautyClockmytimewait(tonumber(timewait))
	else
		dgTimeWait:setVisible(false)
		removeEvent(dgtwbeautyclock)
	end
	
end

function doBeautyClockmytimewait(timewait)
	if not dpanelWindow or not dungeonWindow or not dpanelWindow:isVisible() or not dungeonWindow:isVisible() then return true end
	local dgTimeWait = dungeonWindow:getChildById('dungeonTimeWait')
	if not dgTimeWait then return true elseif timewait <= 0 then dgTimeWait:setVisible(false) removeEvent(dgtwbeautyclock) return true end
	local tempo = getbeautymytempo(timewait)
	dgTimeWait:getChildById('hour1'):setImageSource('/images/dungeons/timeWait/'.. tempo.h1 ..'.png')
	dgTimeWait:getChildById('hour2'):setImageSource('/images/dungeons/timeWait/'.. tempo.h2 ..'.png')
	dgTimeWait:getChildById('minu1'):setImageSource('/images/dungeons/timeWait/'.. tempo.m1 ..'.png')
	dgTimeWait:getChildById('minu2'):setImageSource('/images/dungeons/timeWait/'.. tempo.m2 ..'.png')
	dgTimeWait:getChildById('sec1'):setImageSource('/images/dungeons/timeWait/'.. tempo.s1 ..'.png')
	dgTimeWait:getChildById('sec2'):setImageSource('/images/dungeons/timeWait/'.. tempo.s2 ..'.png')
	dgtwbeautyclock = scheduleEvent(function() doBeautyClockmytimewait(timewait-1) end,1000)
end

function setTimeLeft(timeleft)
	removeEvent(dgtlbeautyclock)
	if not timeleft or not tonumber(timeleft) or timeleft == "end" then
	--removeEvent(dgtlbeautyclock)
		dgTimeLeft:setVisible(false)
		--hideTimeLeft()
	else
		dgTimeLeft:show()
		dgTimeLeft:raise()
		--dgTimeLeft:setVisible(true)
		doBeautyClockmytimeleft(tonumber(timeleft))
	end
	return true
end

function doBeautyClockmytimeleft(timeleft)
	if not dgTimeLeft then return true elseif timeleft <= 0 then dgTimeLeft:setVisible(false) return true end
	local tempo = getbeautymytempo(timeleft)
	dgTimeLeft:getChildById('min1'):setImageSource('/images/game/timeLeft/'.. tempo.m1 ..'.png')
	dgTimeLeft:getChildById('min2'):setImageSource('/images/game/timeLeft/'.. tempo.m2 ..'.png')
	dgTimeLeft:getChildById('se1'):setImageSource('/images/game/timeLeft/'.. tempo.s1 ..'.png')
	dgTimeLeft:getChildById('se2'):setImageSource('/images/game/timeLeft/'.. tempo.s2 ..'.png')
	dgtlbeautyclock = scheduleEvent(function() doBeautyClockmytimeleft(timeleft-1) end,1000)
	return true
end

function getbeautymytempo(number)
local s2 = number
local s1 = 0
local m2 = 0
local m1 = 0
local h2 = 0
local h1 = 0
	for a = 1, math.floor(number/10) do
	if s2 <= 9 then
	return {h1 = h1, h2 = h2, m1 = m1, m2 = m2, s1 = s1, s2 = s2}
	else
	s2 = s2 - 10
	s1 = s1 + 1
	if s1 >= 6 then
		s1 = 0
		m2 = m2 + 1
		if m2 >= 10 then
			m2 = 0
			m1 = m1 + 1
			if m1 >= 6 then
				m1 = 0
				h2 = h2 + 1
				if h2 >= 10 then
					h2 = 0
					h1 = h1 + 1
				end
			end
		end
	end
	end
	end
	return {h1 = h1, h2 = h2, m1 = m1, m2 = m2, s1 = s1, s2 = s2}
end

function hideTimeLeft()
	addEvent(function() g_effects.fadeOut(dgTimeLeft, 250) end)
	scheduleEvent(function() dgTimeLeft:hide() end, 250)
end

function hideShop()
	addEvent(function() g_effects.fadeOut(dgShop, 250) end)
	scheduleEvent(function() dgShop:hide() end, 250)
	addEvent(function() g_effects.fadeOut(buyWindow, 250) end)
	scheduleEvent(function() buyWindow:hide() end, 250)
end

function hideBuyWindow()
	addEvent(function() g_effects.fadeOut(buyWindow, 250) end)
	scheduleEvent(function() buyWindow:hide() end, 250)
end

function hide()
	addEvent(function() g_effects.fadeOut(dpanelWindow, 250) end)
	scheduleEvent(function() dpanelWindow:hide() end, 250)
	addEvent(function() g_effects.fadeOut(dungeonWindow, 250) end)
	scheduleEvent(function() dungeonWindow:hide() end, 250)
	hideShop()
end

function increaseStar()

  if starselected >= 3 then return true end
  
	if starselected >= totalstars then return true end
		decreaseStarsButton:setImageSource('/images/dungeons/starbutton/-on.png')
	if starselected == 1 then
		if totalstars == 2 then
			dungeonStars:setImageSource('/images/dungeons/starbutton/2a.png')
		elseif totalstars >= 3 and totalstars <= 5 then
			dungeonStars:setImageSource('/images/dungeons/starbutton/2.png')
		end
	elseif starselected == 2 then
		dungeonStars:setImageSource('/images/dungeons/starbutton/3.png')
	end
	
	starselected = starselected+1
	
	if starselected >= totalstars or starselected >= 3 then
		increaseStarsButton:setImageSource('/images/dungeons/starbutton/+off.png')
	end
	
end

function decreaseStar()

	if starselected <= 1 then return true end
	increaseStarsButton:setImageSource('/images/dungeons/starbutton/+on.png')

	if starselected == 2 then
		if totalstars == 2 then
			dungeonStars:setImageSource('/images/dungeons/starbutton/1a.png')
		elseif totalstars >= 3 and totalstars <= 5 then
			dungeonStars:setImageSource('/images/dungeons/starbutton/1.png')
		end
	elseif starselected == 3 then
		dungeonStars:setImageSource('/images/dungeons/starbutton/2.png')
	end
	
	starselected = starselected-1

	if starselected <= 1 then
		decreaseStarsButton:setImageSource('/images/dungeons/starbutton/-off.png')
	end
	
end

function startDungeon()
g_game.talk("!startdg"..dungeonNumber.."star"..starselected.."")
hide()
end

function hideWindow()
  addEvent(function() g_effects.fadeOut(dungeonWindow, 250) end)
  scheduleEvent(function() dungeonWindow:hide() end, 250)
end

function showDGShop(dgcoins)
	if not dpanelWindow:isVisible() then 
		return true
	elseif not dgShop:isVisible() then
		addEvent(function() g_effects.fadeIn(dgShop, 250) end)
	end
	dgShop:show()
	dgShop:raise()
	dgShop:focus()
	dgCoinsQuant = dgShop:getChildById('count1')
    dgCoinsQuant:setText(dgcoins)
	return true
end

function doBuyDGShopItem(item)
	local itemToName = {
		["mysticstar"] = "a Mystic Star",
		["10bronzetickets"] = "10 Bronze Tickets",
		["10silvertickets"] = "10 Silver Tickets",
		["10goldtickets"] = "10 Gold Tickets",
		["30dungeontokens"] = "30 Dungeon Tokens",
		["65dungeontokens"] = "65 Dungeon Tokens",
		["100dungeontokens"] = "100 Dungeon Tokens",
		["volcanictapestry"] = "a Volcanic Tapestry",
		["seavelltapestry"] = "a Seavell Tapestry",
		["naturiatapestry"] = "a Naturia Tapestry",
		["raibolttapestry"] = "a Raibolt Tapestry",
		["gardestriketapestry"] = "a Gardestrike Tapestry",
		["wingeontapestry"] = "a Wingeon Tapestry",
		["oreboundtapestry"] = "an Orebound Tapestry",
		["psycrafttapestry"] = "a Psycraft Tapestry",
		["malefictapestry"] = "a Malefic Tapestry",
		["urnbox"] = "an Urn Box",
		["volcanicurn"] = "a Volcanic Urn",
		["seavellurn"] = "a Seavell Urn",
		["naturiaurn"] = "a Naturia Urn",
		["raibolturn"] = "a Raibolt Urn",
		["gardestrikeurn"] = "a Gardestrike Urn",
		["wingeonurn"] = "a Wingeon Urn",
		["oreboundurn"] = "an Orebound Urn",
		["psycrafturn"] = "a Psycraft Urn",
		["maleficurn"] = "a Malefic Urn",
	}
	if not itemToName[item] or not dgShop:isVisible() then print(item) return true
	elseif not buyWindow:isVisible() then
		addEvent(function() g_effects.fadeIn(buyWindow, 250) end)
	end
	buyWindow:show()
	buyWindow:raise()
	buyWindow:focus()
	buyWindow:setText("Buy Item")
	local msg = "Are you sure buy "..itemToName[item].." ?"
	buyWindow:getChildById('buyItemText'):setText(msg)
	buyWindow:getChildById('buyButton').onClick = function() g_game.talk("/buyDGShop "..item) hideBuyWindow() end
	return true
end