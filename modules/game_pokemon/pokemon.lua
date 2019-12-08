local colors = {
[1] = "#59B200",
[2] = "#00CCFF",
[3] = "#FF0000",
[4] = "#F5B325",
[5] = "#00FF00"
}

HOTKEY_MANAGER_NOUSE = nil
HOTKEY_MANAGER_USEONSELF = 1
HOTKEY_MANAGER_USEINMYPOKEMON = 2
HOTKEY_MANAGER_USEWITH = 3
HOTKEY_MANAGER_MOVETOHAND = 4
HOTKEY_MANAGER_ONLYUSE = 5

InventorySlotStyles = {
  [InventorySlotHead] = "HeadSlot",
  [InventorySlotNeck] = "NeckSlot",
  [InventorySlotBack] = "BackSlot",
  [InventorySlotBody] = "BodySlot",
  [InventorySlotRight] = "RightSlot",
  [InventorySlotLeft] = "LeftSlot",
  [InventorySlotLeg] = "LegSlot",
  [InventorySlotFeet] = "FeetSlot",
  [InventorySlotFinger] = "FingerSlot",
  [InventorySlotAmmo] = "AmmoSlot"
}

function init()
  connect(LocalPlayer, { onHealthChange = onHealthChange,
                         onInventoryChange = onInventoryChange,
                         onLevelChange = onLevelChange })

  connect(g_game, { onGameStart = refresh,
                    onGameEnd = hide })

  bottomPanel = g_ui.loadUI('pokemon', modules.game_interface.getRootPanel())
  movesBarWindow = bottomPanel:getChildByIndex(1)
  playerWindow = bottomPanel:recursiveGetChildById('playerWindow')
  buttonsWindow = bottomPanel:recursiveGetChildById('menuWindow')
  playerHealth = movesBarWindow:recursiveGetChildById('playerHealth')
  playerExp = movesBarWindow:recursiveGetChildById('playerExp')
  
  ProtocolGame.registerExtendedOpcode(71, function(protocol, opcode, buffer) onClanChange(protocol, opcode, buffer) end)
  ProtocolGame.registerExtendedOpcode(72, function(protocol, opcode, buffer) onSexChange(protocol, opcode, buffer) end)
  
  g_keyboard.bindKeyPress("Ctrl+i", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end g_game.useInventoryItem(player:getInventoryItem(3):getId()) end)
  g_keyboard.bindKeyPress("Ctrl+z", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end safeUseInventoryItemWith(player:getInventoryItem(2):getId()) end)
  g_keyboard.bindKeyPress("Ctrl+d", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end startChoosePos() end)

  g_keyboard.bindKeyPress("r", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end g_game.useInventoryItem(player:getInventoryItem(8):getId()) end)
  g_keyboard.bindKeyPress("1", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end useSlotItem(10, 8) end)
  g_keyboard.bindKeyPress("2", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end useSlotItem(9, 8) end)
  g_keyboard.bindKeyPress("3", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end useSlotItem(7, 8) end)
  g_keyboard.bindKeyPress("4", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end useSlotItem(6, 8) end)
  g_keyboard.bindKeyPress("5", function()  local player = g_game.getLocalPlayer() if modules.game_console.consoleMode == 1 then return end useSlotItem(1, 8) end)
  movesBarWindow:recursiveGetChildById('slot1').onMouseRelease = onSlotItemMouseRelease
  movesBarWindow:recursiveGetChildById('slot9').onMouseRelease = onSlotItemMouseRelease
  movesBarWindow:recursiveGetChildById('slot10').onMouseRelease = onSlotItemMouseRelease
  movesBarWindow:recursiveGetChildById('slot7').onMouseRelease = onSlotItemMouseRelease
  movesBarWindow:recursiveGetChildById('slot6').onMouseRelease = onSlotItemMouseRelease
  refresh()
end

function onClanChange(protocol, opcode, buffer)
  playerWindow:getChildById('clan'):setImageSource('/images/game/pokemon/clan/'..buffer)
end

function useVara()
	local player = g_game.getLocalPlayer() 
	safeUseInventoryItemWith(player:getInventoryItem(2):getId())
end

function useInventory()
	local player = g_game.getLocalPlayer() 
	g_game.useInventoryItem(player:getInventoryItem(3):getId())
end

function useOrder()
	local player = g_game.getLocalPlayer() 
	g_game.useInventoryItem(player:getInventoryItem(3):getId())
end

function startChoosePos()
  if g_ui.isMouseGrabbed() then return end

  local mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)
  mouseGrabberWidget.onMouseRelease = onClickWithMouse

  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
end

function onClickWithMouse(self, mousePosition, mouseButton)
	if mouseButton == MouseLeftButton or mouseButton == MouseMidButton then
		local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
		if clickedWidget then
			local protocol = g_game.getProtocolGame()
			if clickedWidget:getClassName() == 'UIGameMap' then
				local tile = clickedWidget:getTile(mousePosition)
				local pos = tile:getPosition()
				if tile then
					local thing = tile:getTopMoveThing()
					if thing:isCreature() then
						if protocol then
							protocol:sendExtendedOpcode(53, thing:getId())
						end
						if thing:isLocalPlayer() then
							modules.game_pokedex.show(0)
						elseif thing:isMonster() then
							if string.find(getPokemonNameByOutfit(tile:getTopCreature():getOutfit().type), 'Shiny') then
								modules.game_pokedex.show(getPokemonIdByName(string.lower(string.explode(getPokemonNameByOutfit(tile:getTopCreature():getOutfit().type), 'Shiny ')[2])), true)
							else
								modules.game_pokedex.show(getPokemonIdByName(string.lower(getPokemonNameByOutfit(tile:getTopCreature():getOutfit().type))), false)
							end
							print(tile:getTopCreature():getOutfit().type)
						end
					end
				end
			elseif clickedWidget:getClassName() == 'UICreatureButton' then
				local creature = clickedWidget:getCreature()
				protocol:sendExtendedOpcode(53, creature:getId())
			end
		end
  end
  g_mouse.popCursor('target')
  self:ungrabMouse()
  self:destroy()
  return true
end

function onSexChange(protocol, opcode, buffer)
  if tonumber(buffer) == 0 then 
	buffer = "female" 
  elseif tonumber(buffer) == 1 then 
    buffer = "male" 
  end
  playerWindow:getChildById('portrait'):setImageSource('/images/game/card/'..buffer)
end

function terminate()
  disconnect(LocalPlayer, { onHealthChange = onHealthChange,
                            onInventoryChange = onInventoryChange,
                            onLevelChange = onLevelChange,
                            })

  disconnect(g_game, { onGameStart = refresh,
                       onGameEnd = hide })
  save()
  bottomPanel:destroy()
end

function refresh()
  local player = g_game.getLocalPlayer()
  if g_game.isOnline() then
    onHealthChange(player, player:getHealth(), player:getMaxHealth())
    onLevelChange(player, player:getLevel(), player:getLevelPercent())
    bottomPanel:show()
	load()
  else
    bottomPanel:hide()
  end
  for i = 1, 10 do
    if g_game.isOnline() then
      onInventoryChange(player, i, player:getInventoryItem(i))
    else
      onInventoryChange(player, i, nil)
    end
  end
end

function hide()
  g_keyboard.unbindKeyDown('Ctrl+D')
  g_keyboard.unbindKeyDown('Ctrl+Z')
  save()
  bottomPanel:hide()
end

function expForLevel(level)
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200)
end

function expToAdvance(currentLevel, currentExp)
  return expForLevel(currentLevel+1) - currentExp
end

function useSlotItem(slot, slot2)
  if not g_game.isOnline() then return end
  local item = g_game.getLocalPlayer():getInventoryItem(slot)
  local myPokemon = g_game.getLocalPlayer():getInventoryItem(8)
  if not item then return end
  if modules.game_console.getConsoleEnabled() and not modules.client_options.getOption('forceItemShortcuts') then return end
  if movesBarWindow:getChildById('slot'..slot).useType == HOTKEY_MANAGER_NOUSE then return end
  if item:isMultiUse() then
    if movesBarWindow:getChildById('slot'..slot).useType == HOTKEY_MANAGER_USEONSELF then
      g_game.useInventoryItemWith(item:getId(), g_game.getLocalPlayer())
    elseif movesBarWindow:getChildById('slot'..slot).useType == HOTKEY_MANAGER_USEINMYPOKEMON then
      g_game.useInventoryItemWith(item:getId(), myPokemon)
    else
      modules.game_interface.startUseWith(item)
    end
  else
  end
end

function save()
  local settings = {}
  
  settings.useType1 = movesBarWindow:getChildById('slot10').useType
  settings.useType2 = movesBarWindow:getChildById('slot9').useType
  settings.useType3 = movesBarWindow:getChildById('slot1').useType
  settings.useType4 = movesBarWindow:getChildById('slot7').useType
  settings.useType5 = movesBarWindow:getChildById('slot6').useType
  g_settings.setNode('game_pokemon', settings)
end

function load()
  local settings = g_settings.getNode('game_pokemon')
  for i = 1, 10 do
	if i ~= 8 then
		movesBarWindow:getChildById('slot'..i).useType = HOTKEY_MANAGER_NOUSE
		movesBarWindow:getChildById('slot'..i):setImageColor('#FF2525')
	end
  end
  if settings.useType1 then
    movesBarWindow:getChildById('slot10').useType = settings.useType1
    movesBarWindow:getChildById('slot10'):setImageColor(colors[settings.useType1])
  end
  if settings.useType2 then
    movesBarWindow:getChildById('slot9').useType = settings.useType2
    movesBarWindow:getChildById('slot9'):setImageColor(colors[settings.useType2])
  end
  if settings.useType3 then
    movesBarWindow:getChildById('slot1').useType = settings.useType3
    movesBarWindow:getChildById('slot1'):setImageColor(colors[settings.useType3])
  end
  if settings.useType4 then
    movesBarWindow:getChildById('slot7').useType = settings.useType4
    movesBarWindow:getChildById('slot7'):setImageColor(colors[settings.useType4])
  end
  if settings.useType5 then
    movesBarWindow:getChildById('slot6').useType = settings.useType5
    movesBarWindow:getChildById('slot6'):setImageColor(colors[settings.useType5])
  end
end

function onSlotItemMouseRelease(self, mousePosition, mouseButton)
  local item = self:getItem()
  if mouseButton ~= MouseMidButton and g_keyboard.isAltPressed() then
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
	if item:isMultiUse() then
		menu:addOption(tr('Use object on yourself'), function() self.useType = HOTKEY_MANAGER_USEONSELF self:setImageColor('#59B200') end)
		menu:addOption(tr('Use object in my Pokeball'), function() self.useType = HOTKEY_MANAGER_USEINMYPOKEMON self:setImageColor('#00CCFF') end)
		menu:addOption(tr('Use object with crosshair'), function() self.useType = HOTKEY_MANAGER_USEWITH self:setImageColor('#FF0000') end)
		menu:addSeparator()
		menu:addOption(tr('No use object'), function() self.useType = HOTKEY_MANAGER_NOUSE self:setImageColor('#AAAAAA') end)
	else
		menu:addOption(tr('Use'), function() self.useType = HOTKEY_MANAGER_ONLYUSE self:setImageColor('#00FF00') end)
		menu:addSeparator()
		menu:addOption(tr('No use object'), function() self.useType = HOTKEY_MANAGER_NOUSE self:setImageColor('#AAAAAA') end)
	end
    menu:display(mousePos)
  else
    if item then
      modules.game_interface.processMouseAction(mousePosition, mouseButton, nil, item, item, nil, nil)
    end
  end
end

function moveItemToSlot(slotItem, SlotGo)
	local backPackPos = {x = 65535, y = 5, z = 0}
	local goPos = {x = 65535, y = SlotGo, z = 0}
	if g_game.isOnline() then
		local player = g_game.getLocalPlayer()
		local slotGoItem = player:getInventoryItem(SlotGo)
		local slotOldItem = player:getInventoryItem(slotItem)
		if slotGoItem then
			g_game.move(slotGoItem, backPackPos, slotGoItem:getCount())
		end
		if slotOldItem then
			g_game.move(slotOldItem, goPos, slotOldItem:getCount())
		end
		scheduleEvent(function() local player = g_game.getLocalPlayer() local oldPos = {x = 65535, y = slotItem, z = 0}  g_game.move(player:getInventoryItem(5), oldPos, player:getInventoryItem(5):getCount()) end, 200)
	end
end

function onLevelChange(localPlayer, value, percent)
  local player = g_game.getLocalPlayer()
    local text = tr(string.format('You have %s percent to go', 100 - percent)) .. '\n' ..
               tr(string.format('%s of experience left', expToAdvance(player:getLevel(), localPlayer:getLevel())))

  if player.expSpeed ~= nil then
     local expPerHour = math.floor(player.expSpeed * 3600)
     if expPerHour > 0 then
        local nextLevelExp = expForLevel(player:getLevel()+1)
        local hoursLeft = (nextLevelExp - player:getExperience()) / expPerHour
        local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
        hoursLeft = math.floor(hoursLeft)
        text = text .. '\n' .. tr(string.format('%d of experience per hour', expPerHour))
        text = text .. '\n' .. tr(string.format('Next level in %d hours and %d minutes', hoursLeft, minutesLeft))
     end
  end
  playerWindow:getChildById('levelLabel'):setText(tr('Lv')..'. '..value)
  playerWindow:getChildById('levelLabel'):setTooltip(tr('Level')..' '..value)
  local nextLevelExp = expForLevel(player:getLevel()+1)
  -- playerExp:setValue(player:getExperience(), 0, nextLevelExp)
  playerExp:setPercent(math.floor(percent))
  -- playerExp:setText(math.floor(percent).."%")
  playerExp:setTooltip(text)
end

function safeUseInventoryItemWith(itemId)
    local player = g_game.getLocalPlayer()
	local item = Item.create(itemId)
    modules.game_interface.startUseWith(item)
  return true
end

function useSlotWith(slot)  
	local player = g_game.getLocalPlayer() 
	if modules.game_console.consoleMode == 1 then 
		return 
	end 
	safeUseInventoryItemWith(player:getInventoryItem(slot):getId()) 
end

function onInventoryChange(player, slot, item, oldItem)
	local itemWidget = movesBarWindow:getChildById('slot'..slot)
	if item then
		itemWidget:setItem(item)
	else
		itemWidget:setItem(nil)
	end
end

function onHealthChange(localPlayer, health, maxHealth)
  playerHealth:setText(health..' / '..maxHealth)
  playerHealth:setValue(health, 0, maxHealth)
end

function getPokemon()
  return pokemon
end

function getPlayerWindow()
  return playerWindow
end

function getbuttonsWindow()
  return buttonsWindow
end