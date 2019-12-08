cardColor = {
['pokemon trainer'] = {'#75AA75', '#507550'},
['volcanic'] = {'#AA0000', '#750000'},
['seavell'] = {'#2575CC', '#0050AA'},
['wingeon'] = {'#FFFFFF', '#BBBBBB'},
['ironhard'] = {'#AAAAAA', '#808080'},
['malefic'] = {'#5000AA', '#500085'},
['naturia'] = {'#00AA00', '#007500'},
['raibolt'] = {'#FFFF00', '#BBBB00'},
['psycraft'] = {'#FF00FF', '#BB00BB'},
['orebound'] = {'#505050', '#404040'},
['gardestrike'] = {'#FF7500', '#AA5000'},
}

clansTitleMale = {
['volcanic'] = {'Spark', 'Flame', 'Firetamer', 'Pyromancer', 'Master', 'Master'},
['seavell'] = {'Drop', 'Icelake', 'Waterfall', 'Frost', 'King', 'King'},
['wingeon'] = {'Cloud', 'Wind', 'Sky', 'Falcon', 'Dragon', 'Dragon'},
['ironhard'] = {'Smither', 'Forge', 'Hammer', 'Metal', ' Titan', ' Titan'},
['malefic'] = {'Troublemaker', 'Venomancer', 'Spectre', 'Nigthwalker', 'Lord', 'Lord'},
['naturia'] = {'Seed', 'Sprout', 'Webhead', 'Woodtrunk', 'Keeper', 'Keeper'},
['raibolt'] = {'Shock', 'Watt', 'Electrician', 'Overcharged', 'Legend', 'Legend'},
['psycraft'] = {'Mind', 'Brain', 'Scholar', 'Telepath', 'Medium', 'Medium'},
['orebound'] = {'Sand', 'Rock', 'Solid', 'Hardskin', 'Hero', 'Hero'},
['gardestrike'] = {'Fist', 'Tamer', 'Fighter', 'Deathhand', 'Champion', 'Champion'},
}

clansTitleFemale = {
['volcanic'] = {'Spark', 'Flame', 'Firetamer', 'Pyromancer', 'Master', 'Master'},
['seavell'] = {'Drop', 'Icelake', 'Waterfall', 'Frost', 'Queen', 'Queen'},
['wingeon'] = {'Cloud', 'Wind', 'Sky', 'Falcon', 'Dragon', 'Dragon'},
['ironhard'] = {'Smither', 'Forge', 'Hammer', 'Metal', ' Titan', ' Titan'},
['malefic'] = {'Troublemaker', 'Venomancer', 'Spectre', 'Nigthwalker', 'Lady', 'Lady'},
['naturia'] = {'Seed', 'Sprout', 'Webhead', 'Woodtrunk', 'Keeper', 'Keeper'},
['raibolt'] = {'Shock', 'Watt', 'Electrician', 'Overcharged', 'Legend', 'Legend'},
['psycraft'] = {'Mind', 'Brain', 'Scholar', 'Telepath', 'Medium', 'Medium'},
['orebound'] = {'Sand', 'Rock', 'Solid', 'Hardskin', 'Heroine', 'Heroine'},
['gardestrike'] = {'Fist', 'Tamer', 'Fighter', 'Deathhand', 'Champion', 'Champion'},
}

badgesName = {'Boulder', 'Cascade', 'Thunder', 'Rainbow', 'Soul', 'Marsh', 'Volcano', 'Earth'}

pointsLeft = 5
wisdomPoints = 33
strenghtPoints = 45
vitalityPoints = 12
defensePoints = 15

showEvent = nil
hideEvent = nil

creature = nil

skillsDescription = {
['wisdomPanel'] = tr('Increasing your wisdom,\nyour pokemon will be more likely to use passive in battle.\nAt each point increased will be more 0.3%s chance of your pokemon use passive.', '%'),
['strenghtPanel'] = tr('Increasing your strength,\nyour Pokemon will be stronger to battle.\nAt each point increased his pokemon would be 0.15%s stronger.', '%'),
['vitalityPanel'] = tr('Increasing your vitality,\nyour pokemon will have more life.\nAt each point increased will be +20 life for your pokemon.'),
['defensePanel'] = tr('Increasing your defense,\nyour pokemon will be less vulnerable in battle.\nAt each point increased his pokemon would be 0.15%s less vulnerable.', '%'),
}

function init()
  connect(g_game, { onGameEnd = offline })

  connect(g_game, 'onTextMessage', onLookPlayer)

  cardWindow = g_ui.displayUI('card', modules.game_interface.getRootPanel())
  playerPokemonsPanel = cardWindow:recursiveGetChildById('playerPokemonsPanel')
  badgesPanel = cardWindow:recursiveGetChildById('badgesPanel')
  wisdomPanel = cardWindow:recursiveGetChildById('wisdomPanel')
  strenghtPanel = cardWindow:recursiveGetChildById('strenghtPanel')
  vitalityPanel = cardWindow:recursiveGetChildById('vitalityPanel')
  defensePanel = cardWindow:recursiveGetChildById('defensePanel')
  playerPokedex = cardWindow:recursiveGetChildById('playerPokedex')
  playerCatches = cardWindow:recursiveGetChildById('playerCatches')
  saveButton = cardWindow:recursiveGetChildById('saveButton')
  redistributeButton = cardWindow:recursiveGetChildById('redistributeButton')
  cardWindow:hide()

  wisdomPanel:getChildByIndex(1):setImageSource('/images/game/card/skills/wisdom')
  strenghtPanel:getChildByIndex(1):setImageSource('/images/game/card/skills/strenght')
  vitalityPanel:getChildByIndex(1):setImageSource('/images/game/card/skills/vitality')
  defensePanel:getChildByIndex(1):setImageSource('/images/game/card/skills/defense')

  wisdomPanel:getChildByIndex(1):setTooltip(skillsDescription[wisdomPanel:getId()])
  strenghtPanel:getChildByIndex(1):setTooltip(skillsDescription[strenghtPanel:getId()])
  vitalityPanel:getChildByIndex(1):setTooltip(skillsDescription[vitalityPanel:getId()])
  defensePanel:getChildByIndex(1):setTooltip(skillsDescription[defensePanel:getId()])

  wisdomPanel:getChildByIndex(2):setText(tr('Wisdom'))
  strenghtPanel:getChildByIndex(2):setText(tr('Strenght'))
  vitalityPanel:getChildByIndex(2):setText(tr('Vitality'))
  defensePanel:getChildByIndex(2):setText(tr('Defense'))
end

function terminate()
  disconnect(g_game, { onGameEnd = offline })

  disconnect(g_game, 'onTextMessage', onLookPlayer)

  cardWindow:destroy()
end

function refresh(player)

  if not player:isPlayer() then return end
  creature = player

  sendInfoToServer(162, tostring(player:getId()))

  cardWindow:getChildById('playerName'):setText(tr('Name')..': '..player:getName())
end

function show()
  g_effects.cancelFade(cardWindow)
  removeEvent(hideEvent)
  if not showEvent then
    showEvent = addEvent(function() g_effects.fadeIn(cardWindow, 250) end)
  end
  cardWindow:raise()
  cardWindow:focus()
  cardWindow:show()
end

function hide()
  hideEvent = scheduleEvent(function() cardWindow:hide() end, 250)
  addEvent(function() g_effects.fadeOut(cardWindow, 250) end)
  showEvent = nil
end

function offline()
  cardWindow:hide()
end

function doUpSkill(panel)
  local text = tr('Points')..': '
  local skillPoints = tonumber(string.explode(panel:getChildByIndex(4):getText(), text)[2])
  local points = tonumber(string.explode(cardWindow:getChildById('playerPoints'):getText(), text)[2])
  if skillPoints == 99 then
    panel:getChildByIndex(3):setVisible(false)
  end
  if points == 0 then return end
  points = points - 1
  cardWindow:getChildById('playerPoints'):setText(tr('Points')..': '..points)
  panel:getChildByIndex(4):setText(tr('Points')..': '..skillPoints+1)
end

function doSavePoints()
  local text = tr('Points')..': '
  pointsLeft = tonumber(string.explode(cardWindow:getChildById('playerPoints'):getText(), text)[2])
  wisdomPoints = tonumber(string.explode(wisdomPanel:getChildByIndex(4):getText(), text)[2])
  strenghtPoints = tonumber(string.explode(strenghtPanel:getChildByIndex(4):getText(), text)[2])
  vitalityPoints = tonumber(string.explode(vitalityPanel:getChildByIndex(4):getText(), text)[2])
  defensePoints = tonumber(string.explode(defensePanel:getChildByIndex(4):getText(), text)[2])
  cardWindow:getChildById('distributedPoints'):setText(tr('Distributed Points')..': '..wisdomPoints + strenghtPoints + vitalityPoints + defensePoints)
  if pointsLeft == 0 then
    wisdomPanel:getChildByIndex(3):setVisible(false)
    strenghtPanel:getChildByIndex(3):setVisible(false)
    vitalityPanel:getChildByIndex(3):setVisible(false)
    defensePanel:getChildByIndex(3):setVisible(false)

    redistributeButton:setVisible(false)
    saveButton:setVisible(false)
  end
  sendInfoToServer(162, 'savePoints|'..tostring(pointsLeft)..'|'..tostring(wisdomPoints)..'|'..tostring(strenghtPoints)..'|'..tostring(vitalityPoints)..'|'..tostring(defensePoints))
end

function doRedistributePoints()
  if wisdomPoints == 100 then
    wisdomPanel:getChildByIndex(3):setVisible(false)
  end
  if strenghtPoints == 100 then
    strenghtPanel:getChildByIndex(3):setVisible(false)
  end
  if vitalityPoints == 100 then
    vitalityPanel:getChildByIndex(3):setVisible(false)
  end
  if defensePoints == 100 then
    defensePanel:getChildByIndex(3):setVisible(false)
  end

  wisdomPanel:getChildByIndex(4):setText(tr('Points')..': '..wisdomPoints)
  strenghtPanel:getChildByIndex(4):setText(tr('Points')..': '..strenghtPoints)
  vitalityPanel:getChildByIndex(4):setText(tr('Points')..': '..vitalityPoints)
  defensePanel:getChildByIndex(4):setText(tr('Points')..': '..defensePoints)

  cardWindow:getChildById('playerPoints'):setText(tr('Points')..': '..pointsLeft)
end

function onLookPlayer(mode, text)
  if not getCodeBuffer(mode, 162, text) then return end
  local buffer1 = string.explode(getCodeBuffer(mode, 162, text), '/')[1]
  local buffer2 = string.explode(getCodeBuffer(mode, 162, text), '/')[2]
  gender = string.explode(buffer1, '|')[1] == '0' and 'female' or 'male'
  pointsLeft = tonumber(string.explode(buffer1, '|')[2])
  wisdomPoints = tonumber(string.explode(buffer1, '|')[3])
  strenghtPoints = tonumber(string.explode(buffer1, '|')[4])
  vitalityPoints = tonumber(string.explode(buffer1, '|')[5])
  defensePoints = tonumber(string.explode(buffer1, '|')[6])

  local visible = creature:isLocalPlayer()
  wisdomPanel:getChildByIndex(3):setVisible(visible)
  strenghtPanel:getChildByIndex(3):setVisible(visible)
  vitalityPanel:getChildByIndex(3):setVisible(visible)
  defensePanel:getChildByIndex(3):setVisible(visible)
  redistributeButton:setVisible(visible)
  saveButton:setVisible(visible)

  if wisdomPoints == 100 then
    wisdomPanel:getChildByIndex(3):setVisible(false)
  end
  if strenghtPoints == 100 then
    strenghtPanel:getChildByIndex(3):setVisible(false)
  end
  if vitalityPoints == 100 then
    vitalityPanel:getChildByIndex(3):setVisible(false)
  end
  if defensePoints == 100 then
    defensePanel:getChildByIndex(3):setVisible(false)
  end

  for i = 1, 6 do
    if string.explode(string.explode(buffer2, '|')[i], '-')[1]:lower() ~= 'none' then
      playerPokemonsPanel:getChildByIndex(i):setImageSource('/images/game/pokemon/icons/'..string.explode(string.explode(buffer2, '|')[i], '-')[1]:lower())
      playerPokemonsPanel:getChildByIndex(i):setTooltip(string.explode(string.explode(buffer2, '|')[i], '-')[1]..' +'..string.explode(string.explode(buffer2, '|')[i], '-')[2])
    else
      playerPokemonsPanel:getChildByIndex(i):setImageSource()
      playerPokemonsPanel:getChildByIndex(i):setTooltip()
    end
  end

  playerPokedex:setText('Pokedex: '..string.explode(buffer2, '|')[7])
  playerCatches:setText(tr('Catches')..': '..string.explode(buffer2, '|')[8])
  cardWindow:getChildById('playerPoints'):setText(tr('Points')..': '..pointsLeft)
  cardWindow:getChildById('distributedPoints'):setText(tr('Distributed Points')..': '..wisdomPoints + strenghtPoints + vitalityPoints + defensePoints)
  cardWindow:getChildById('playerGender'):setImageSource('/images/game/card/'..gender)

  for i = 1, 8 do
    if string.explode(buffer2, '|')[i+8] == '1' then
      badgesPanel:getChildByIndex(i):setImageColor('white')
      badgesPanel:getChildByIndex(i):setTooltip(badgesName[i]..' Badge')
    else
      badgesPanel:getChildByIndex(i):setImageColor('alpha')
      badgesPanel:getChildByIndex(i):setTooltip()
    end
  end

  local clan = string.explode(string.explode(buffer2, '|')[17], '-')[1]:lower()
  local rank = tonumber(string.explode(string.explode(buffer2, '|')[17], '-')[2])
  cardWindow:setImageColor(cardColor[clan][1])
  cardWindow:getChildById('clanIcon'):setImageSource('/images/game/pokemon/clan/'..clan)
  if clan ~= 'pokemon trainer' then
    if gender == 'male' then
      cardWindow:getChildById('clanIcon'):setTooltip(doCorrectString(clan)..' '..clansTitleMale[clan][rank])
    else
      cardWindow:getChildById('clanIcon'):setTooltip(doCorrectString(clan)..' '..clansTitleFemale[clan][rank])
    end
  else
    cardWindow:getChildById('clanIcon'):setTooltip('Pokemon Trainer')
  end
  cardWindow:getChildById('horizontalSeparator'):setImageColor(cardColor[clan][2])
  cardWindow:getChildById('verticalSeparator'):setImageColor(cardColor[clan][2])

  cardWindow:getChildById('playerLevel'):setText(tr('Level')..': '..string.explode(buffer2, '|')[18])

  wisdomPanel:getChildByIndex(4):setText(tr('Points')..': '..wisdomPoints)
  strenghtPanel:getChildByIndex(4):setText(tr('Points')..': '..strenghtPoints)
  vitalityPanel:getChildByIndex(4):setText(tr('Points')..': '..vitalityPoints)
  defensePanel:getChildByIndex(4):setText(tr('Points')..': '..defensePoints)

  if pointsLeft == 0 then
    wisdomPanel:getChildByIndex(3):setVisible(false)
    strenghtPanel:getChildByIndex(3):setVisible(false)
    vitalityPanel:getChildByIndex(3):setVisible(false)
    defensePanel:getChildByIndex(3):setVisible(false)

    redistributeButton:setVisible(false)
    saveButton:setVisible(false)
  end
  show()
end
