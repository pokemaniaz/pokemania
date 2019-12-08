function init()
  connect(g_game, { onGameStart = refresh,
                    onGameEnd = hide })
  
  targetedWindow = g_ui.loadUI('mypoke', modules.game_interface.getMapPanel())
  healthBar = targetedWindow:recursiveGetChildById('healthBar')
  portrait = targetedWindow:recursiveGetChildById('portrait')
  
   ProtocolGame.registerExtendedOpcode(104, function(protocol, opcode, buffer) onPokeHealthChange(protocol, opcode, buffer) end)
   ProtocolGame.registerExtendedOpcode(56, function(protocol, opcode, buffer) onPokeChange(protocol, opcode, buffer) end)
  refresh()
  hide()
end


function terminate()
  disconnect(g_game, { onGameStart = refresh,
                       onGameEnd = hide })

  ProtocolGame.unregisterExtendedOpcode(104)
  ProtocolGame.unregisterExtendedOpcode(56)

  targetedWindow:destroy()
end

function refresh()
  if g_game.isOnline() then
    if g_game.getAttackingCreature() then
      sendInfoToServer(153, tostring(g_game.getAttackingCreature():getId()))
    end
  end
end

function show()
  targetedWindow:show()
end

function hide()
  targetedWindow:hide()
end

function onPokeHealthChange(protocol, opcode, buffer)
  local mana = tonumber(string.explode(buffer, '|')[1])
  local maxMana = tonumber(string.explode(buffer, '|')[2])
  if maxMana <= 0 then
    healthBar:clearText()
	hide()
  else
    healthBar:setText(mana .. ' / ' .. maxMana)
  end
  healthBar:setValue(mana, 0, maxMana)
end

function onPokeChange(protocol, opcode, buffer)
	if buffer ~= "false" then
		portrait:setImageSource('/images/game/pokemon/portraits/'..buffer)
		show()
	else
		hide()
	end
end