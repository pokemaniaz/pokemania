skillsWindow = nil
skillsButton = nil
kantovalue = nil

local imgs = {
   [-1] = "/modules/game_skills/img/trainer",
   [0] = "/modules/game_skills/img/trainer",
   [1] = "/modules/game_skills/img/volcanic",
   [2] = "/modules/game_skills/img/seavell",
   [3] = "/modules/game_skills/img/naturia",
   [4] = "/modules/game_skills/img/gardestrike",
   [5] = "/modules/game_skills/img/psycraft",
   [6] = "/modules/game_skills/img/malefic",
   [7] = "/modules/game_skills/img/raibolt",
   [8] = "/modules/game_skills/img/wingeon",
   [9] = "/modules/game_skills/img/orebound",
}

function init()
--ProtocolGame.registerExtendedOpcode(2, messageKanto)
  connect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
	onDungeonPointsChange = onDungeonPointsChange,
    onLevelChange = onLevelChange,
    onHealthChange = onHealthChange,
    onManaChange = onManaChange,
    onSoulChange = onSoulChange,
	--onKantoChange = onKantoChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onTotalCapacityChange = onTotalCapacityChange,
    onStaminaChange = onStaminaChange,
    onOfflineTrainingChange = onOfflineTrainingChange,
    onRegenerationChange = onRegenerationChange,
  --  onSpeedChange = onSpeedChange,
  --  onBaseSpeedChange = onBaseSpeedChange,
    onMagicLevelChange = onMagicLevelChange,
    onBaseMagicLevelChange = onBaseMagicLevelChange,
    onSkillChange = onSkillChange,
    onBaseSkillChange = onBaseSkillChange
  })
  connect(g_game, 'onTextMessage', onKantoChange)
  connect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline,
  })
  --connect(g_game, 'onTextMessage', getParams)
  connect(g_game, {onGameStart = changeImg})

 -- setSkillValue('dungeonpoints', 69)
  --setSkillValue('69', dungeonpoints)
  --skillsButton = modules.client_topmenu.addRightGameToggleButton('skillsButton', tr('Habilidades') .. ' (Ctrl+S)', '/images/topbuttons/skills', toggle)
  skillsButton = modules.game_pokemon.getbuttonsWindow():recursiveGetChildById('skillButton')
  skillsButton:setOn(true)
  skillsButton:setVisible(false)
  skillsWindow = g_ui.loadUI('skills', modules.game_interface.getRightPanel()) -- skills
  kantovalue = skillsWindow:recursiveGetChildById("kantovalue")

  g_keyboard.bindKeyDown('Ctrl+S', toggle)
  
  refresh()
  --ProtocolGame.registerExtendedOpcode(67, function(protocol, opcode, buffer) 
  --local buffer = buffer
  --refresh(buffer)
  --end)
  
  ProtocolGame.registerExtendedOpcode(67, function(protocol, opcode, buffer)
  local strings = string.explode(buffer, ':')  

  refresh(strings[1], strings[2], strings[3]) 
  end)
  
  ProtocolGame.registerExtendedOpcode(59, function(protocol, opcode, buffer)
  local strings = string.explode(buffer, ':')
	if g_map.getCreatureById(tonumber(strings[1])) then
	--	g_map.getCreatureById(tonumber(strings[1])):setMoveSpeed(tonumber(strings[2]))
		g_map.getCreatureById(tonumber(strings[1])):setMoveSpeed(tonumber(strings[2]))
		--g_map.getCreatureById(tonumber(strings[1])):setMoveSpeed(0)
		--g_map.getCreatureById(tonumber(strings[1])):setMoveSpeed(tonumber(strings[2]))
	end
 -- refreshMoveSpeed(tonumber(strings[1]), tonumber(strings[2])) 
  end)

  skillsWindow:setup()
end

function terminate()
--ProtocolGame.unregisterExtendedOpcode(2)
  disconnect(LocalPlayer, {
    onExperienceChange = onExperienceChange,
	onDungeonPointsChange = onDungeonPointsChange,
    onLevelChange = onLevelChange,
    onHealthChange = onHealthChange,
    onManaChange = onManaChange,
    onSoulChange = onSoulChange,
	--onKantoChange = onKantoChange,
    onFreeCapacityChange = onFreeCapacityChange,
    onTotalCapacityChange = onTotalCapacityChange,
    onStaminaChange = onStaminaChange,
    onOfflineTrainingChange = onOfflineTrainingChange,
    onRegenerationChange = onRegenerationChange,
 --   onSpeedChange = onSpeedChange,
  --  onBaseSpeedChange = onBaseSpeedChange,
    onMagicLevelChange = onMagicLevelChange,
    onBaseMagicLevelChange = onBaseMagicLevelChange,
    onSkillChange = onSkillChange,
    onBaseSkillChange = onBaseSkillChange
  })
  disconnect(g_game, 'onTextMessage', onKantoChange)
  disconnect(g_game, {
    onGameStart = refresh,
    onGameEnd = offline,
  })
 -- disconnect(g_game, 'onTextMessage', getParams)
  disconnect(g_game, {onGameStart = changeImg})
  
  g_keyboard.unbindKeyDown('Ctrl+S')
  ProtocolGame.unregisterExtendedOpcode(67)
  ProtocolGame.unregisterExtendedOpcode(60)
  skillsWindow:destroy()
  skillsButton:destroy()
end

function changeImg()
  local player = g_game.getLocalPlayer()
  if not player then return end
end

function getParams(mode, text)
if not g_game.isOnline() then return end
   if mode == MessageModes.Failure then 
      if text:find("#getSto#") then
         local icon = skillsWindow:recursiveGetChildById("clanicon")
         if icon then
            local t = string.explode(text, " ")
            icon:setImageSource(imgs[tonumber(t[2])])
         end
      end
   end
end

function expForLevel(level)
  return math.floor((50*level*level*level)/3 - 100*level*level + (850*level)/3 - 200)
end

function expToAdvance(currentLevel, currentExp)
  return expForLevel(currentLevel+1) - currentExp
end

function resetSkillColor(id)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor('#bbbbbb')
end

function setSkillBase(id, value, baseValue)
  if baseValue <= 0 or value < 0 then
    return
  end
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')

  if value > baseValue then
    widget:setColor('#008b00') -- green
    skill:setTooltip(baseValue .. ' +' .. (value - baseValue))
  elseif value < baseValue then
    widget:setColor('#b22222') -- red
    skill:setTooltip(baseValue .. ' ' .. (value - baseValue))
  else
    widget:setColor('#bbbbbb') -- default
    skill:removeTooltip()
  end
end

function setSkillValue(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setText(value)
end

function setSkillColor(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setColor(value)
end

function setSkillTooltip(id, value)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('value')
  widget:setTooltip(value)
end

function setSkillPercent(id, percent, tooltip)
  local skill = skillsWindow:recursiveGetChildById(id)
  local widget = skill:getChildById('percent')
  widget:setPercent(math.floor(percent))

  if tooltip then
    widget:setTooltip(tooltip)
  end
end

function checkAlert(id, value, maxValue, threshold, greaterThan)
  if greaterThan == nil then greaterThan = false end
  local alert = false

  -- maxValue can be set to false to check value and threshold
  -- used for regeneration checking
  if type(maxValue) == 'boolean' then
    if maxValue then
      return
    end

    if greaterThan then
      if value > threshold then
        alert = true
      end
    else
      if value < threshold then
        alert = true
      end
    end
  elseif type(maxValue) == 'number' then
    if maxValue < 0 then
      return
    end

    local percent = math.floor((value / maxValue) * 100)
    if greaterThan then
      if percent > threshold then
        alert = true
      end
    else
      if percent < threshold then
        alert = true
      end
    end
  end

  if alert then
    setSkillColor(id, '#b22222') -- red
  else
    resetSkillColor(id)
  end
end  
   
function update()
  local offlineTraining = skillsWindow:recursiveGetChildById('offlineTraining')
  if not g_game.getFeature(GameOfflineTrainingTime) then
    offlineTraining:hide()
  else
    offlineTraining:show()
  end

  local regenerationTime = skillsWindow:recursiveGetChildById('regenerationTime')
  if not g_game.getFeature(GamePlayerRegenerationTime) then
    regenerationTime:hide()
  else
    regenerationTime:show()
  end
end

function refresh(dgpoints, clan)
  local player = g_game.getLocalPlayer()
  if not player then return end
  skillsButton:setVisible(true)
  local icon = skillsWindow:recursiveGetChildById("clanicon")
  icon:setImageSource(imgs[tonumber(clan)])

  if expSpeedEvent then expSpeedEvent:cancel() end
  expSpeedEvent = cycleEvent(checkExpSpeed, 30*1000)

  onExperienceChange(player, player:getExperience())

  onDungeonPointsChange(player, dgpoints)
  onLevelChange(player, player:getLevel(), player:getLevelPercent())
  onHealthChange(player, player:getHealth(), player:getMaxHealth())
  onManaChange(player, player:getMana(), player:getMaxMana())
  onSoulChange(player, player:getSoul())
  --onKantoChange(player, player:messsage())
  onFreeCapacityChange(player, player:getFreeCapacity())
  onStaminaChange(player, player:getStamina())
  onMagicLevelChange(player, player:getMagicLevel(), player:getMagicLevelPercent())
  onOfflineTrainingChange(player, player:getOfflineTrainingTime())
  onRegenerationChange(player, player:getRegenerationTime())
  --onSpeedChange(player, player:getSpeed())

  for i=0,6 do
    onSkillChange(player, i, player:getSkillLevel(i), player:getSkillLevelPercent(i))
    onBaseSkillChange(player, i, player:getSkillBaseLevel(i))
  end

  update()

  local contentsPanel = skillsWindow:getChildById('contentsPanel')
  skillsWindow:setContentMinimumHeight(88)
  skillsWindow:setContentMaximumHeight(230)
end

function offline()
   skillsButton:setVisible(false)
end

function toggle()
  if skillsButton:isOn() then
    skillsWindow:close()
    skillsButton:setOn(false)
  else
    skillsWindow:open()
    skillsButton:setOn(true)
    skillsButton:setOpacity(1.0)
  end
end

function checkExpSpeed()
  local player = g_game.getLocalPlayer()
  if not player then return end
  
  local currentExp = player:getExperience()
  local currentTime = g_clock.seconds()
  if player.lastExps ~= nil then
    player.expSpeed = (currentExp - player.lastExps[1][1])/(currentTime - player.lastExps[1][2])
    onLevelChange(player, player:getLevel(), player:getLevelPercent())
  else
    player.lastExps = {}
  end
  table.insert(player.lastExps, {currentExp, currentTime})
  if #player.lastExps > 30 then
    table.remove(player.lastExps, 1)
  end
end

function onMiniWindowClose()
  skillsButton:setOn(false)
  skillsButton:setOpacity(0.5)
end

function onSkillButtonClick(button)
  local percentBar = button:getChildById('percent')
  if percentBar then
    percentBar:setVisible(not percentBar:isVisible())
    if percentBar:isVisible() then
      button:setHeight(21)
    else
      button:setHeight(21 - 6)
    end
  end
end

function onExperienceChange(localPlayer, value)
  setSkillValue('level', value)
end

function onDungeonPointsChange(localPlayer, value)
  setSkillValue('dungeonpoints', value)
end

function onLevelChange(localPlayer, value, percent)
  setSkillValue('experience', localPlayer:getName())
  setSkillValue('experiencee', value)
  local text = tr('You have %s percent to go', 100 - percent) .. '\n' ..
               tr('%s of experience left', expToAdvance(localPlayer:getLevel(), localPlayer:getExperience()))

  if localPlayer.expSpeed ~= nil then
     local expPerHour = math.floor(localPlayer.expSpeed * 3600)
     if expPerHour > 0 then
        local nextLevelExp = expForLevel(localPlayer:getLevel()+1)
        local hoursLeft = (nextLevelExp - localPlayer:getExperience()) / expPerHour
        local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft))*60)
        hoursLeft = math.floor(hoursLeft)
        text = text .. '\n' .. tr('%d of experience per hour', expPerHour)
        text = text .. '\n' .. tr('Next level in %d hours and %d minutes', hoursLeft, minutesLeft)
     end
  end

  local thelevel = skillsWindow:recursiveGetChildById("experiencee")
  setSkillPercent('level', percent, text)
  thelevel:setTooltip(text)
end

function onHealthChange(localPlayer, health, maxHealth)
  setSkillValue('health', health)
  checkAlert('health', health, maxHealth, 30)
end

function onManaChange(localPlayer, mana, maxMana)
  setSkillValue('mana', mana)
  checkAlert('mana', mana, maxMana, 30)
end

function onSoulChange(localPlayer, soul)
  setSkillValue('soul', soul)
end

--function onKantoChange(localPlayer, messsage)
  --setSkillValue('messsage', messsage)
--end

function onFreeCapacityChange(localPlayer, freeCapacity)
  setSkillValue('capacity', freeCapacity)
  checkAlert('capacity', freeCapacity, localPlayer:getTotalCapacity(), 20)
end

function onTotalCapacityChange(localPlayer, totalCapacity)
  checkAlert('capacity', localPlayer:getFreeCapacity(), totalCapacity, 20)
end

function onStaminaChange(localPlayer, stamina)
  local hours = math.floor(stamina / 60)
  local minutes = stamina % 60
  if minutes < 10 then
    minutes = '0' .. minutes
  end
  setSkillValue('stamina', hours .. ":" .. minutes)
end

function onOfflineTrainingChange(localPlayer, offlineTrainingTime)
  if not g_game.getFeature(GameOfflineTrainingTime) then
    return
  end
  local hours = math.floor(offlineTrainingTime / 60)
  local minutes = offlineTrainingTime % 60
  if minutes < 10 then
    minutes = '0' .. minutes
  end
  local percent = 100 * offlineTrainingTime / (12 * 60) -- max is 12 hours

  setSkillValue('offlineTraining', hours .. ":" .. minutes)
  setSkillPercent('offlineTraining', percent, tr('You have %s percent', percent))
end

function onRegenerationChange(localPlayer, regenerationTime)
  if not g_game.getFeature(GamePlayerRegenerationTime) or regenerationTime < 0 then
    return
  end
  local minutes = math.floor(regenerationTime / 60)
  local seconds = regenerationTime % 60
  if seconds < 10 then
    seconds = '0' .. seconds
  end

  setSkillValue('regenerationTime', minutes .. ":" .. seconds)
  checkAlert('regenerationTime', regenerationTime, false, 300)
end

function onSpeedChange(localPlayer, speed)
  setSkillValue('speed', speed)
  onBaseSpeedChange(localPlayer, localPlayer:getBaseSpeed())
end

function onBaseSpeedChange(localPlayer, baseSpeed)
  setSkillBase('speed', localPlayer:getSpeed(), baseSpeed)
end

function onMagicLevelChange(localPlayer, magiclevel, percent)
  setSkillValue('magiclevel', magiclevel)
  setSkillPercent('magiclevel', percent, tr('You have %s percent to go', 100 - percent))

  onBaseMagicLevelChange(localPlayer, localPlayer:getBaseMagicLevel())
end

function onBaseMagicLevelChange(localPlayer, baseMagicLevel)
  setSkillBase('magiclevel', localPlayer:getMagicLevel(), baseMagicLevel)
end

function onSkillChange(localPlayer, id, level, percent)
  if id ~= 3 then
	setSkillValue('skillId' .. id, level)
  end
  setSkillPercent('skillId2', percent, tr('You have %s percent to go', 100 - percent))
 -- setSkillPercent('skillId3', percent, tr('You have %s percent to go', 100 - percent))
  setSkillPercent('skillId4', percent, tr('You have %s percent to go', 100 - percent))
  setSkillPercent('skillId5', percent, tr('You have %s percent to go', 100 - percent))
  setSkillPercent('skillId6', percent, tr('You have %s percent to go', 100 - percent))

  onBaseSkillChange(localPlayer, id, localPlayer:getSkillBaseLevel(id))
end

function onBaseSkillChange(localPlayer, id, baseLevel)
  if id ~= 3 then
	setSkillBase('skillId'..id, localPlayer:getSkillLevel(id), baseLevel)
  end
end

function onKantoChange(mode, text)
if not g_game.isOnline() then return end
   if mode == MessageModes.Failure then 
      if string.find(text, '#getKanto#,') then
         local t = text:explode(',')
         local hp = tonumber(t[2])
         kantovalue:setText(hp)
         skillsWindow:recursiveGetChildById("kantoc"):setTooltip(kantoCaughtsTooltip, hp)
        -- kantovalue:setValue(hp)
      end
   end
end