effectiveness = {{"Super Effective", 4}, {"Effective", 2}, {"Normal", 1}, {"Ineffective", 0.5}, {"Very Ineffective", 0.25}, {"Null", 0}}

pokemons = {}
seen = 0
catches = 0
viewShiny = nil
advancedSearchWindow = nil

function init()
  connect(g_game, { onGameEnd = hide })

  pokedexWindow = g_ui.displayUI('pokedex', modules.game_interface.getRootPanel())
  pokedexTabBar = pokedexWindow:recursiveGetChildById('pokedexTabBar')
  pokemonInfoPanel = pokedexWindow:recursiveGetChildById('pokemonInfoPanel')
  pokemonsPanel = pokedexWindow:recursiveGetChildById('pokemonsPanel')
  pokemonSearch = pokedexWindow:recursiveGetChildById('searchText')
  seenLabel = pokedexWindow:recursiveGetChildById('seenLabelValue')
  catchesLabel = pokedexWindow:recursiveGetChildById('catchesLabelValue')
  pokemonHide = pokedexWindow:recursiveGetChildById('hideUnseen')
  pokemonInfoPanel:getChildById('mapMark'):setVisible(false)
  pokedexTabContent = pokedexWindow:recursiveGetChildById('pokedexTabContent')
  advancedSearchWindow = pokedexWindow:recursiveGetChildById('advancedSearchWindow')
  pokedexTabBar:setContentWidget(pokedexTabContent)
  pokedexWindow:hide()

  movesPanel = g_ui.loadUI('moves')
  pokedexTabBar:addTab(tr('Moves'), movesPanel)

  effectivenessPanel = g_ui.loadUI('effectiveness')
  pokedexTabBar:addTab(tr('Effectiveness'), effectivenessPanel)

  lootsPanel = g_ui.loadUI('loots')
  pokedexTabBar:addTab(tr('Loots'), lootsPanel)

  for i = 1, 375 do
    local pokemonButton = g_ui.createWidget('PokemonButton', pokemonsPanel)
    pokemonButton.onMouseRelease = onPokemonButtonMouseRelease
    pokemonButton.id = i
    pokemonButton.see = false
    pokemonButton.catched = 0
    pokemonButton.name = pokemonId[i]
    if i < 10 then
      pokemonButton:setText('00'..i)
    elseif i >= 10 and i < 100 then
      pokemonButton:setText('0'..i)
    else
      pokemonButton:setText(i)
    end
    if i == 375 then
      pokemonButton:focus()
    end
	pokemonButton:setIconColor('black')
    pokemonButton:setIcon('/images/game/pokedex/icons/'..i)
    table.insert(pokemons, pokemonButton)
  end

  ProtocolGame.registerExtendedOpcode(60, function(protocol, opcode, buffer) onCheckPokedex(protocol, opcode, buffer) end)
  ProtocolGame.registerExtendedOpcode(62, function(protocol, opcode, buffer) onPokedexSelect(protocol, opcode, buffer) end)
  ProtocolGame.registerExtendedOpcode(63, function(protocol, opcode, buffer) getMapMarks(protocol, opcode, buffer) end)
  
  pokemonsPanel.onChildFocusChange = function(self, focusedChild) reloadPokemonsPanelInfo(focusedChild) end
  g_keyboard.bindKeyPress('Left', function() pokemonsPanel:focusPreviousChild(KeyboardFocusReason) end, pokedexWindow)
  g_keyboard.bindKeyPress('Right', function() pokemonsPanel:focusNextChild(KeyboardFocusReason) end, pokedexWindow)
  g_keyboard.bindKeyPress('Up', function() for i = 1, 4 do pokemonsPanel:focusPreviousChild(KeyboardFocusReason) end end, pokedexWindow)
  g_keyboard.bindKeyPress('Down', function() for i = 1, 4 do pokemonsPanel:focusNextChild(KeyboardFocusReason) end end, pokedexWindow)
end

function onPokedexSelect(protocol, opcode, buffer)
	local tabe = string.explode(buffer, "*")
	local mapMark = pokemonInfoPanel:getChildById('mapMark')
	reloadLoots(tabe[1])
	local pokemonDescription = pokemonInfoPanel:getChildById('pokemonDescription')
	pokemonDescription:setText(tabe[3])
	if tabe[2] == "false" then
		mapMark:setVisible(false)
	else
		mapMark:setVisible(true)
	end
end

function sendMapProtocolToServer(pokeName)
	local protocol = g_game.getProtocolGame()
	if protocol then
		if not pokeName:find('?') then
			protocol:sendExtendedOpcode(69, pokeName)
		end
	end
end

function getMapMarks(protocol, opcode, buffer)
	if buffer ~= "false" then
		assert(loadstring("mapInfo = "..tostring(buffer)))()
		for i, v in pairs(mapInfo) do
			addMapMarks(v['x'], v['y'], v['z'], v['imagem'], v['description'])
		end
	end
end

function addMapMarks(x, y, z, imagem, description)
	modules.game_minimap.setMonsterCave(x, y, z, imagem, description)
	scheduleEvent(function() modules.game_minimap.removeMonsterCave(x, y, z, imagem, description) end, 30*1000)
end

function reloadLoots(list)
	if list == "false" then
		return
	end
	assert(loadstring("itemInfo = "..tostring(list)))()
	local count = 1
	for p = 1, 10 do
		local loots = lootsPanel:getChildById('pokemonLoots'):getChildById("item"..p)
		local lootsLabel = lootsPanel:getChildById('pokemonLoots'):getChildById("item"..p.."label")
		loots:setVisible(false)
		lootsLabel:setText("")
	end
	for i, v in pairs(itemInfo) do
		local loots = lootsPanel:getChildById('pokemonLoots'):getChildById("item"..count)
		local lootsLabel = lootsPanel:getChildById('pokemonLoots'):getChildById("item"..count.."label")
		loots:setItemId(v['id'])
		loots:setItemCount(v['count'])
		lootsLabel:setText("Chance: "..v['chance'].."%")
		loots:setTooltip(v['name'])
		loots:setVisible(true)
		count = count +1
	end
end

function terminate()
  disconnect(g_game, { onGameEnd = hide })

  g_keyboard.unbindKeyPress('Left')
  g_keyboard.unbindKeyPress('Right')
  g_keyboard.unbindKeyPress('Up')
  g_keyboard.unbindKeyPress('Down')

  save()
  seen = 0
  catches = 0
  pokedexWindow:destroy()
end

function show(focus, shiny)
  local scrollBar = pokedexWindow:getChildById('pokedexScrollBar')
  if focus == 0 then
    pokemonSearch:clearText()
    pokemonSearch:focus()
    pokedexWindow:show()
    pokedexWindow:raise()
    pokedexWindow:focus()
    clearCheckBoxChecked()
    pokemonsPanel:getChildByIndex(1):focus()
    scrollBar:setValue(0)
    return
  end
  if shiny then
    pokemons[focus].shiny = true
  else
    pokemons[focus].shiny = false
  end
  pokemonSearch:clearText()
  pokemonSearch:focus()
  pokedexWindow:show()
  pokedexWindow:raise()
  pokedexWindow:focus()
  clearCheckBoxChecked()
  scrollBar:setValue(math.floor((focus-21)/4)*43)
  pokemonsPanel:getChildByIndex(focus):focus()
end

function hide()
  save()
  seen = 0
  catches = 0
  pokedexWindow:hide()
end

function load()
  local settings = g_settings.getNode('game_pokedex')
  settings.hideUnseen = settings.hideUnseen or false
  pokemonHide:setChecked(settings.hideUnseen)
  hideUnseen(pokemonHide:isChecked())
end

function save()
  local settings = {}
  settings.hideUnseen = pokemonHide:isChecked()
  g_settings.setNode('game_pokedex', settings)
end

function onPokemonButtonMouseRelease(self, mousePosition, mouseButton)
  if mouseButton == MouseRightButton then
    if not self.see or not haveShinyPokemon(self.name) then return end
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    if not viewShiny or pokemonsPanel:getFocusedChild() ~= self then
      menu:addOption('Shiny', function() self:focus() reloadShinyPokemonPanelInfo(self) end)
    elseif pokemonsPanel:getFocusedChild() == self then
      menu:addOption('Normal', function() self:focus() reloadPokemonsPanelInfo(self) end)
    end
    menu:display(mousePos)
  end
end

function onCheckPokedex(protocol, opcode, buffer)
  if string.find(buffer, 'reloadCatch') then
    local pokemonId = string.explode(buffer, '-')[1]
    local pokemon = pokemonsPanel:getChildByIndex(pokemonId)
	pokemon.catched = 1
    if pokemon.see then
      pokemon:getChildByIndex(1):setImageColor('white')
    end
    return
  end
  seen = 0
  catches = 0
  for i = 1, (#string.explode(buffer, '|')-1) do
    local pokemon = pokemonsPanel:getChildByIndex(i)
	if pokemon ~= nil then
		local pokemonSee = string.explode(string.explode(buffer, '|')[i], '-')[1]
		local pokemonCatched = string.explode(string.explode(buffer, '|')[i], '-')[2]
		pokemon.catched = tonumber(pokemonCatched)
		if pokemonSee == '0' then
			pokemon.see = false
			pokemon:setIconColor('black')
		else
			pokemon.see = true
			pokemon:setIconColor('white')
			pokemon:setVisible(true)
		end
		if pokemon.catched == 1 and pokemon.see then
			pokemon:getChildByIndex(1):setImageColor('white')
		else
			pokemon:getChildByIndex(1):setImageColor('alpha')
		end
		if pokemon.see then
			seen = seen + 1
		end
		if pokemon.catched == 1 then
		catches = catches + 1
		end
	end
  end
  seenLabel:setText(seen)
  catchesLabel:setText(catches)
  load()
end

function advancedSearch(checkBox)
  for b = 1, pokemonsPanel:getChildCount() do
    local pokemon = pokemonsPanel:getChildByIndex(b)
    local type1 = pokemonTypes[pokemon.name].type1
    local type2 = pokemonTypes[pokemon.name].type2 or 'none'
    local advancedSearchCondition = (getPokemonHaveCheckedSkills(pokemon) and pokemon.see)
    if getCatchedChecked() then
      advancedSearchCondition = pokemon.catched == 1 and advancedSearchCondition
    end
    if getTypesCheckBoxCheckedCount() == 1 then
      advancedSearchCondition = (string.find(getTypesChecked(), type1) or string.find(getTypesChecked(), type2)) and advancedSearchCondition
    elseif getTypesCheckBoxCheckedCount() == 2 then
      advancedSearchCondition = (string.find(getTypesChecked(), type1) and string.find(getTypesChecked(), type2)) and advancedSearchCondition
    elseif getTypesCheckBoxCheckedCount() >= 3 then
      advancedSearchCondition = false
    end
    if pokemonHide:isChecked() then
      advancedSearchCondition = (not checkBox:isChecked() and not haveCheckBoxChecked() and pokemon.see) or advancedSearchCondition
    else
      advancedSearchCondition = (not checkBox:isChecked() and not haveCheckBoxChecked()) or advancedSearchCondition
    end
    pokemon:setVisible(advancedSearchCondition)
  end
end

function getCatchedChecked()
  if advancedSearchWindow:getChildByIndex(2):isChecked() then
    return true
  end
  return false
end

function getPokemonHaveCheckedSkills(pokemon)
  local skills = getPokemonSkills(doCorrectString(pokemon.name)):lower()
  for i = 1, #getSkillsChecked() do
    if not string.find(skills, getSkillsChecked()[i]) then
      return false
    end
  end
  return true
end

function getSkillsChecked()
  local skillsChecked = {}
  for i = 7, 18 do
    local checkBox = advancedSearchWindow:getChildByIndex(i)
    if checkBox:isChecked() then
      table.insert(skillsChecked, checkBox:getText():lower())
    end
  end
  return skillsChecked
end

function getTypesChecked()
  local typesChecked = {}
  for i = 19, 36 do
    local checkBox = advancedSearchWindow:getChildByIndex(i)
    if checkBox:isChecked() then
      table.insert(typesChecked, checkBox:getText():lower()..',')
    end
  end
  return table.concat(typesChecked)
end

function getTypesCheckBoxCheckedCount()
  local typesChecked = 0
  for i = 19, 36 do
    local checkBox = advancedSearchWindow:getChildByIndex(i)
    if checkBox:isChecked() then
      typesChecked = typesChecked + 1
    end
  end
  return typesChecked
end

function clearCheckBoxChecked()
  for i = 2, #advancedSearchWindow:getChildren() do
    if i == 2 or i >= 7 then
      advancedSearchWindow:getChildByIndex(i):setChecked(false)
    end
  end
end

function haveCheckBoxChecked()
  for i = 2, #advancedSearchWindow:getChildren() do
    if i == 2 or i >= 7 then
      if advancedSearchWindow:getChildByIndex(i):isChecked() then
        return true
      end
    end
  end
  return false
end

function hideUnseen(value)
  if pokemonSearch:getText() ~= '' then return end
  for i = 1, pokemonsPanel:getChildCount() do
    local pokemon = pokemonsPanel:getChildByIndex(i)
    local visibleCondition = (not value) or (value and pokemon.see)
    pokemon:setVisible(visibleCondition)
  end
  clearCheckBoxChecked()
end

function searchPokemon()
  local searchFilter = pokemonSearch:getText():lower()
  for i = 1, pokemonsPanel:getChildCount() do
    local pokemon = pokemonsPanel:getChildByIndex(i)
    local searchCondition = (searchFilter ~= '' and string.find(pokemon.name, searchFilter) ~= nil and pokemon.see)
    if pokemonHide:isChecked() then
      searchCondition = (searchFilter == '' and pokemon.see) or searchCondition
    else
      searchCondition = (searchFilter == '') or searchCondition
    end
    pokemon:setVisible(searchCondition)
  end
  clearCheckBoxChecked()
end

function reloadPokemonsPanelInfo(button)
  if button.shiny then
    return reloadShinyPokemonPanelInfo(button)
  end
  local pokemonNameLabel = pokemonInfoPanel:getChildById('pokemonName')
  local pokemonImage = pokemonInfoPanel:getChildById('pokemonImage')
  local pokemonType1 = pokemonInfoPanel:getChildById('pokemonType1')
  local pokemonType2 = pokemonInfoPanel:getChildById('pokemonType2')
  local pokemonDescription = pokemonInfoPanel:getChildById('pokemonDescription')
  local pokemonSkills = pokemonInfoPanel:getChildById('pokemonSkills')
  viewShiny = false
  if button.see then
    pokemonNameLabel:setText('#'..button:getText()..' '..doCorrectString(button.name))
    pokemonImage:setImageColor('white')
	pokemonImage:setTooltip(tr('Description:')..'\n'..pokesDescription[button.name])
    pokemonSkills:setText(tr('Skills')..': '..getPokemonSkills(doCorrectString(button.name))..'.')
    pokemonType1:setVisible(true)
    pokemonType2:setVisible(true)
    pokedexTabContent:setVisible(true)
  else
    pokemonImage:setImageColor('black')
    pokemonNameLabel:setText('#'..button:getText()..' ??????')
    pokemonDescription:setText(tr('Description:')..'\n??????')
    pokemonSkills:setText(tr('Skills')..': ??????.')
    pokemonType1:setVisible(false)
    pokemonType2:setVisible(false)
    pokedexTabContent:setVisible(false)
  end
  pokemonImage:setImageSource('/images/game/pokemon/portraits/'..button.name)
  pokemonType1:setTooltip(string.upper(pokemonTypes[button.name].type1))
  pokemonType1:setImageSource('/images/game/elements/'..pokemonTypes[button.name].type1)
  if pokemonTypes[button.name].type2 and button.see then
    pokemonType2:setVisible(true)
    pokemonType2:setTooltip(string.upper(pokemonTypes[button.name].type2))
    pokemonType2:setImageSource('/images/game/elements/'..pokemonTypes[button.name].type2)
  else
    pokemonType2:setVisible(false)
  end

  for i = 1, 12 do
    movesPanel:getChildById('pokemonMoves'):getChildById('move'..i):setVisible(false)
  end
  reloadMoves(doCorrectString(button.name))
  reloadEffectiveness(button.name, pokemonTypes[button.name].type1, pokemonTypes[button.name].type2)
  local protocol = g_game.getProtocolGame()
  if protocol and button.see then
	protocol:sendExtendedOpcode(55, button.name.."*false")
  end
end

function reloadShinyPokemonPanelInfo(button)
  local pokemonNameLabel = pokemonInfoPanel:getChildById('pokemonName')
  local pokemonImage = pokemonInfoPanel:getChildById('pokemonImage')
  local pokemonType1 = pokemonInfoPanel:getChildById('pokemonType1')
  local pokemonType2 = pokemonInfoPanel:getChildById('pokemonType2')
  local pokemonDescription = pokemonInfoPanel:getChildById('pokemonDescription')
  local pokemonSkills = pokemonInfoPanel:getChildById('pokemonSkills')
  viewShiny = true
  button.shiny = false
  pokemonNameLabel:setText('#'..button:getText()..' Shiny '..doCorrectString(button.name))
  pokemonImage:setImageColor('white')
  pokemonDescription:setText(tr('Description:')..'\n'..pokesDescription['shiny '..button.name])
  pokemonSkills:setText(tr('Skills')..': '..getPokemonSkills('Shiny '..doCorrectString(button.name))..'.')
  pokemonType1:setVisible(true)
  pokemonType2:setVisible(true)
  pokedexTabContent:setVisible(true)
  pokemonImage:setImageSource('/images/game/pokemon/portraits/shiny '..button.name)
  pokemonType1:setTooltip(string.upper(pokemonTypes['shiny '..button.name].type1))
  pokemonType1:setImageSource('/images/game/elements/'..pokemonTypes['shiny '..button.name].type1)
  if pokemonTypes['shiny '..button.name].type2 and button.see then
    pokemonType2:setVisible(true)
    pokemonType2:setTooltip(string.upper(pokemonTypes['shiny '..button.name].type2))
    pokemonType2:setImageSource('/images/game/elements/'..pokemonTypes['shiny '..button.name].type2)
  else
    pokemonType2:setVisible(false)
  end
  reloadMoves('Shiny '..doCorrectString(button.name))
  reloadEffectiveness('shiny '..button.name, pokemonTypes[button.name].type1, pokemonTypes[button.name].type2)
  local protocol = g_game.getProtocolGame()
  if protocol and button.see then
	protocol:sendExtendedOpcode(55, button.name.."*true")
  end
end

function reloadMoves(pokemonName)
  for i = 1, getPokemonMovesCount(pokemonName) do
    local move = movesPanel:getChildById('pokemonMoves'):getChildById('move'..i)
    local moveInfo = getPokemonMoveIdInfo(pokemonName)[i]
    move:getChildByIndex(1):setImageSource('/images/game/moves/'..moveInfo.name..'_on')
    move:getChildByIndex(1):setText(moveInfo.cd)
    move:getChildByIndex(2):setText(moveInfo.name)
    move:getChildByIndex(3):setText('Level '..moveInfo.level)
    move:getChildByIndex(4):setImageSource('/images/game/elements/'..moveInfo.t)
    move:getChildByIndex(4):setTooltip(doCorrectString(moveInfo.t))
    move:setVisible(true)
  end
end

function reloadEffectiveness(pokemonName, type1, type2)
  local scrollPanel = effectivenessPanel:getChildById('pokemonEffectiveness')
  local first = 1

  for i = 1, #scrollPanel:getChildren()-1 do
    scrollPanel:getChildByIndex(2):destroy()
  end

  for i = 1, #effectiveness do
    local effePanel = g_ui.createWidget('EffectivenessPanel', scrollPanel)
    if i > first then
      effePanel:setMarginTop(5)
    end

    local effeTypesPanel1 = effePanel:getChildByIndex(2)
    local effeTypesPanel2 = effePanel:getChildByIndex(3)
    local effeType = string.explode(getEffectiveness(type1, type2, effectiveness[i][2]), '-')
    scrollPanel:getChildByIndex(1):setText(tr('Effectiveness against')..' '..doCorrectString(pokemonName)..':')
    effePanel:getChildByIndex(1):setText(tr(effectiveness[i][1])..':')

    for a = 1, #effeTypesPanel1:getChildren() do
      effeTypesPanel1:getChildByIndex(1):destroy()
    end
    for a = 1, #effeTypesPanel2:getChildren() do
      effeTypesPanel2:getChildByIndex(1):destroy()
    end

    if getEffectiveness(type1, type2, effectiveness[i][2]) ~= "" then
      for b = 1, #effeType-1 do
        if #effeTypesPanel1:getChildren() <= 14 then
          element = g_ui.createWidget('ElementButton', effeTypesPanel1)
        else
          effePanel:setHeight(49)
          element = g_ui.createWidget('ElementButton', effeTypesPanel2)
        end
        element:setTooltip(doCorrectString(effeType[b]))
        element:setImageSource('/images/game/elements/'..effeType[b])
      end
    else
      effePanel:destroy()
      first = first + 1
    end

  end
end

function advancedSearchShow()
  if advancedSearchWindow:isVisible() then
    scheduleEvent(function() advancedSearchWindow:hide() end, 1)
  else
    advancedSearchWindow:show()
    advancedSearchWindow:raise()
    advancedSearchWindow:focus()
  end
end