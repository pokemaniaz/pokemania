battleWindow = nil
battlePanel = nil
filterPanel = nil
toggleFilterButton = nil
lastBattleButtonSwitched = nil
battleButtonsByCreaturesList = {}
creatureAgeList = {}

pokemon = nil
pokemonId = 0

mouseWidget = nil

hidePlayersButton = nil
hideNPCsButton = nil
hideMonstersButton = nil

function init()
  g_ui.importStyle('battlebutton')
  battleWindow = g_ui.loadUI('battle', modules.game_interface.getRightPanel())
  battleButton = modules.game_pokemon.getbuttonsWindow():recursiveGetChildById('battleButton')
  battleButton:setOn(true)
  g_keyboard.bindKeyDown('Ctrl+B', toggle)

  -- this disables scrollbar auto hiding
  local scrollbar = battleWindow:getChildById('miniwindowScrollBar')
  scrollbar:mergeStyle({ ['$!on'] = { }})

  battlePanel = battleWindow:recursiveGetChildById('battlePanel')

  filterPanel = battleWindow:recursiveGetChildById('filterPanel')
  toggleFilterButton = battleWindow:recursiveGetChildById('toggleFilterButton')

  hidePlayersButton = battleWindow:recursiveGetChildById('hidePlayers')
  hideNPCsButton = battleWindow:recursiveGetChildById('hideNPCs')
  hideMonstersButton = battleWindow:recursiveGetChildById('hideMonsters')

  mouseWidget = g_ui.createWidget('UIButton')
  mouseWidget:setVisible(false)
  mouseWidget:setFocusable(false)
  mouseWidget.cancelNextRelease = false

  battleWindow:setContentMinimumHeight(80)

  connect(Creature, {
    onSkullChange = updateCreatureSkull,
    onEmblemChange = updateCreatureEmblem,
    onOutfitChange = onCreatureOutfitChange,
    onHealthPercentChange = onCreatureHealthPercentChange,
    onPositionChange = onCreaturePositionChange,
    onAppear = onCreatureAppear,
    onDisappear = onCreatureDisappear
  })

  connect(LocalPlayer, {
    onPositionChange = onCreaturePositionChange
  })

  connect(g_game, {
    onAttackingCreatureChange = onAttack,
    onFollowingCreatureChange = onFollow,
    onGameEnd = removeAllCreatures
  })

  checkCreatures()
  battleWindow:setup()
end

function terminate()
  g_keyboard.unbindKeyDown('Ctrl+B')
  battleButtonsByCreaturesList = {}
  battleWindow:destroy()
  mouseWidget:destroy()

  disconnect(Creature, {
    onSkullChange = updateCreatureSkull,
    onEmblemChange = updateCreatureEmblem,
    onOutfitChange = onCreatureOutfitChange,
    onHealthPercentChange = onCreatureHealthPercentChange,
    onPositionChange = onCreaturePositionChange,
    onAppear = onCreatureAppear,
    onDisappear = onCreatureDisappear
  })

  disconnect(LocalPlayer, {
    onPositionChange = onCreaturePositionChange
  })

  disconnect(g_game, {
    onAttackingCreatureChange = onAttack,
    onFollowingCreatureChange = onFollow,
    onGameEnd = removeAllCreatures
  })
end

function toggle()
  if battleButton:isOn() then
    battleWindow:close()
    battleButton:setOn(false)
  else
    battleWindow:open()
    battleButton:setOn(true)
  end
end

function onMiniWindowClose()
  battleButton:setOn(false)
end

function checkCreatures()
  removeAllCreatures()

  if not g_game.isOnline() then
    return
  end

  local player = g_game.getLocalPlayer()
  local spectators = g_map.getSpectators(player:getPosition(), false)
  for _, creature in ipairs(spectators) do
    if doCreatureFitFilters(creature) then
      addCreature(creature)
    end
  end
end

function doCreatureFitFilters(creature)
  if creature:isLocalPlayer() then
    return false
  end

  local pos = creature:getPosition()
  if not pos then return false end

  local localPlayer = g_game.getLocalPlayer()
  if pos.z ~= localPlayer:getPosition().z or not creature:canBeSeen() then return false end

  local hidePlayers = hidePlayersButton:isChecked()
  local hideNPCs = hideNPCsButton:isChecked()
  local hideMonsters = hideMonstersButton:isChecked()

  if hidePlayers and creature:isPlayer() then
    return false
  elseif hideNPCs and creature:isNpc() then
    return false
  elseif hideMonsters and creature:isMonster() then
    return false
  elseif creature:getOutfit().type == 6 then
	return false
  end

  return true
end

function onCreatureHealthPercentChange(creature, health)
  local battleButton = battleButtonsByCreaturesList[creature:getId()]
  if battleButton then
    battleButton:setLifeBarPercent(creature:getHealthPercent())
  end
end

local function getDistanceBetween(p1, p2)
    return math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y))
end

function onCreaturePositionChange(creature, newPos, oldPos)
  if creature:isLocalPlayer() then
    if oldPos and newPos and newPos.z ~= oldPos.z then
      checkCreatures()
    else
      for _, battleButton in pairs(battleButtonsByCreaturesList) do
        addCreature(battleButton.creature)
      end
    end
  else
    local has = hasCreature(creature)
    local fit = doCreatureFitFilters(creature)
    if has and not fit then
      removeCreature(creature)
    elseif fit then
      addCreature(creature)
    end
  end
end

function onCreatureOutfitChange(creature, outfit, oldOutfit)
  if doCreatureFitFilters(creature) then
    addCreature(creature)
  else
    removeCreature(creature)
  end
end

function onCreatureAppear(creature)
  if creature:isLocalPlayer() then
    addEvent(function()
      updateStaticSquare()
    end)
  end

  if doCreatureFitFilters(creature) then
    addCreature(creature)
  end
end

function onCreatureDisappear(creature)
  removeCreature(creature)
end

function hasCreature(creature)
  return battleButtonsByCreaturesList[creature:getId()] ~= nil
end

function addCreature(creature)
  local creatureId = creature:getId()
  local battleButton = battleButtonsByCreaturesList[creatureId]

  -- Register when creature is added to battlelist for the first time
  if not creatureAgeList[creatureId] then
    creatureAgeList[creatureId] = os.time()
  end

  if not battleButton then
    battleButton = g_ui.createWidget('BattleButton')
    battleButton:setup(creature)

    battleButton.onHoverChange = onBattleButtonHoverChange
    battleButton.onMouseRelease = onBattleButtonMouseRelease

    battleButtonsByCreaturesList[creatureId] = battleButton

    if creature == g_game.getAttackingCreature() then
      onAttack(creature)
    end

    if creature == g_game.getFollowingCreature() then
      onFollow(creature)
    end

    if pokemonId and creatureId == pokemonId then
      battlePanel:insertChild(1, battleButton)
      battleButton:getChildById('myPokemon'):setVisible(true)
    else
      battlePanel:addChild(battleButton)
    end
  else
    battleButton:setLifeBarPercent(creature:getHealthPercent())
  end

  local localPlayer = g_game.getLocalPlayer()
  battleButton:setVisible(localPlayer:hasSight(creature:getPosition()) and creature:canBeSeen())
end

function removeAllCreatures()
  creatureAgeList = {}
  for _, battleButton in pairs(battleButtonsByCreaturesList) do
    removeCreature(battleButton.creature)
  end
end

function reallocateMyPokemon(pokeId)
  local battleButton = battleButtonsByCreaturesList[pokeId]
  local creature = battleButton:getCreature()
  if battleButton then
    removeCreature(creature)
  end
  pokemon = creature
  pokemonId = pokeId
  addCreature(creature)
end

function getMyPokemon()
  local battleButton = battleButtonsByCreaturesList[pokemonId]
  if battleButton then
    return pokemon
  end
  return false
end

function removeCreature(creature)
  if hasCreature(creature) then
    local creatureId = creature:getId()

    if lastBattleButtonSwitched == battleButtonsByCreaturesList[creatureId] then
      lastBattleButtonSwitched = nil
    end

    battleButtonsByCreaturesList[creatureId].creature:hideStaticSquare()
    battleButtonsByCreaturesList[creatureId]:destroy()
    battleButtonsByCreaturesList[creatureId] = nil
  end
end

function onBattleButtonMouseRelease(self, mousePosition, mouseButton)
  if mouseWidget.cancelNextRelease then
    mouseWidget.cancelNextRelease = false
    return false
  end
  if ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton)
    or (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
    mouseWidget.cancelNextRelease = true
    if self.creature:isPlayer() then
      modules.game_card.refresh(self.creature)
    else
      g_game.look(self.creature, true)
    end
    return true
  elseif mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
    if self.creature:isPlayer() then
      modules.game_card.refresh(self.creature)
    else
      g_game.look(self.creature, true)
    end
    return true
  elseif mouseButton == MouseRightButton and not g_mouse.isPressed(MouseLeftButton) then
    modules.game_interface.createThingMenu(mousePosition, nil, nil, self.creature)
    return true
  elseif mouseButton == MouseLeftButton and not g_mouse.isPressed(MouseRightButton) then
    if self.isTarget then
      g_game.cancelAttack()
    else
      g_game.attack(self.creature)
    end
    return true
  end
  return false
end

function onBattleButtonHoverChange(battleButton, hovered)
  if battleButton.isBattleButton then
    battleButton.isHovered = hovered
    updateBattleButton(battleButton)
  end
end

function onAttack(creature)
  local battleButton = creature and battleButtonsByCreaturesList[creature:getId()] or lastBattleButtonSwitched
  if battleButton then
    battleButton.isTarget = (creature and creature:getOutfit().type ~= 84) and true or false
    updateBattleButton(battleButton)
  end
end

function onFollow(creature)
  local battleButton = creature and battleButtonsByCreaturesList[creature:getId()] or lastBattleButtonSwitched
  if battleButton then
    battleButton.isFollowed = (creature and creature:getOutfit().type ~= 84) and true or false
    updateBattleButton(battleButton)
  end
end

function updateStaticSquare()
  for _, battleButton in pairs(battleButtonsByCreaturesList) do
    if battleButton.isTarget then
      battleButton:update()
    end
  end
end

function updateCreatureSkull(creature, skullId)
  local battleButton = battleButtonsByCreaturesList[creature:getId()]
  if battleButton then
    battleButton:updateSkull(skullId)
  end
end

function updateCreatureEmblem(creature, emblemId)
  local battleButton = battleButtonsByCreaturesList[creature:getId()]
  if battleButton then
    battleButton:updateSkull(emblemId)
  end
end

function updateBattleButton(battleButton)
  battleButton:update()
  if battleButton.isTarget or battleButton.isFollowed then
    -- set new last battle button switched
    if lastBattleButtonSwitched and lastBattleButtonSwitched ~= battleButton then
      lastBattleButtonSwitched.isTarget = false
      lastBattleButtonSwitched.isFollowed = false
      updateBattleButton(lastBattleButtonSwitched)
    end
    lastBattleButtonSwitched = battleButton
  end
end