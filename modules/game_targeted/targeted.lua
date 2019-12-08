function init()
  connect(g_game, { onGameStart = refresh,
                    onGameEnd = hide })

  ProtocolGame.registerExtendedOpcode(57, function(protocol, opcode, buffer) onTargetedHealthChange(protocol, opcode, buffer) end)

  targetedWindow = g_ui.loadUI('targeted', modules.game_interface.getMapPanel())
  healthBar = targetedWindow:recursiveGetChildById('healthBar')
  portrait = targetedWindow:recursiveGetChildById('portrait')
  hide()
 end

function terminate()
  disconnect(g_game, { onGameStart = refresh,
                       onGameEnd = hide })


  targetedWindow:destroy()
end


function show()
  targetedWindow:show()
end

function hide()
  targetedWindow:hide()
end

function onTargetedHealthChange(protocol, opcode, buffer)
  local targetHealth = tonumber(buffer:explode('|')[2])
  local targetMaxHealth = tonumber(buffer:explode('|')[3])
  local targetName = ''
  if tostring(buffer:explode('|')[1]) == 'none' then
    targetName = 'nothing'
  else
    targetName = tostring(buffer:explode('|')[1])
  end
  if targetName == 'nothing' then
    hide()
  else
    show()
  end
  healthBar:setValue(targetHealth, 0, targetMaxHealth)
  healthBar:setText(targetHealth..'/'..targetMaxHealth)
  portrait:setImageSource('/images/game/pokemon/portraits/'..targetName)
end
