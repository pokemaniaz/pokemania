local image = nil
local dungeonWindow = nil
local dungeon1 = nil

function init()
  connect(g_game, { onGameEnd = onGameEnd })
  

  dungeonWindow = g_ui.displayUI('dungeon')
  dungeonWindow:hide()
 -- lootWindow:addAnchor(AnchorLeft, 'gameLeftPanel', AnchorRight)
 -- lootWindow:addAnchor(AnchorLeft, "gameMapPanel", AnchorRight)
  --lootWindow:addAnchor(AnchorTop, 'topMenu', AnchorBottom)
  --lootWindow:addAnchor(AnchorBottom, 'topMenu', AnchorBottom + 70)
  dungeonWindow:setHeight(475)
  dungeonWindow:setWidth(700)
  ProtocolGame.registerExtendedOpcode(68, function(protocol, opcode, buffer)
  local strings = string.explode(buffer, '-')  

  show(strings[1], strings[2])--, strings[3], strings[4], strings[5], strings[6], strings[7], strings[8], strings[9], strings[10], strings[11])--, strings[12], strings[13], strings[14], strings[15], strings[16], strings[17], strings[18], strings[19]) 
  end)
end

function terminate()
  disconnect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(68)

  dungeonWindow:destroy()
end

function onGameEnd()
  if dungeonWindow:isVisible() then
    dungeonWindow:hide()
  end
end

function show(image)
    addEvent(function() g_effects.fadeIn(dungeonWindow, 350) end)
	--fernanda = "/images/dungeons/Shiny Charizard"
  --scheduleEvent(function() dungeonWindow:setPhantom(false) end, 250)
 -- addEvent(lootWindow:setPhantom(false), 250)
  dungeonWindow:show()
  dungeonWindow:raise()
  dungeonWindow:focus()
  dungeonWindow:setImageSource('/images/dungeons/'..image..'.png')
 -- dungeonWindow:getChildById('dungeon1'):setImage("/images/dungeons/teste.png")
  
  --lootWindow:getChildById('loot1'):setParent(center)
  --catchWindow:getChildById('maguBall'):setItemId(15324) 
  --catchWindow:getChildById('soraBall'):setItemId(15325)  
  --catchWindow:getChildById('yumeBall'):setItemId(15326)  
  --catchWindow:getChildById('duskBall'):setItemId(15327)  
  --catchWindow:getChildById('taleBall'):setItemId(15330)  
  --catchWindow:getChildById('moonBall'):setItemId(15331)  
  --catchWindow:getChildById('netBall'):setItemId(15332)  
 -- catchWindow:getChildById('premierBall'):setItemId(15334)  
 -- catchWindow:getChildById('tinkerBall'):setItemId(15335)  
 -- catchWindow:getChildById('fastBall'):setItemId(15328)  
 -- catchWindow:getChildById('heavyBall'):setItemId(15329)  
  
 -- catchWindow:getChildById('text'):setText(tr('Congratulations!\nYou caught a %s!\nXP: %s', doCorrectString(pokemon), exp))
 -- catchWindow:getChildById('pokeballsLabel'):setText(n)
  --catchWindow:getChildById('greatballsLabel'):setText(g)
 -- catchWindow:getChildById('superballsLabel'):setText(s)
 -- catchWindow:getChildById('utraballsLabel'):setText(u)
 -- catchWindow:getChildById('saffariballsLabel'):setText(s2)
  --addEvent(function() g_effects.fadeOut(lootWindow,7000) end)
  
  scheduleEvent(function() g_effects.fadeOut(dungeonWindow, 500) end, 3000)
 -- scheduleEvent(function() lootWindow:setPhantom(true) end, 5000)
 -- scheduleEvent(function() lootWindow:hide() end, 6000)
  
 -- catchWindow:getChildById('maguBallsLabel'):setText(magu)
 -- catchWindow:getChildById('soraBallsLabel'):setText(sora)
 -- catchWindow:getChildById('yumeBallsLabel'):setText(yume)
 -- catchWindow:getChildById('duskBallsLabel'):setText(dusk)
 -- catchWindow:getChildById('taleBallsLabel'):setText(tale)
 -- catchWindow:getChildById('moonBallsLabel'):setText(moon)
 -- catchWindow:getChildById('netBallsLabel'):setText(net)
 -- catchWindow:getChildById('premierBallsLabel'):setText(premier)
 -- catchWindow:getChildById('tinkerBallsLabel'):setText(tinker)
 -- catchWindow:getChildById('fastBallsLabel'):setText(fast)
 -- catchWindow:getChildById('heavyBallsLabel'):setText(heavy)
-- lootWindow:show()
end

function hide()
  addEvent(function() g_effects.fadeOut(dungeonWindow, 250) end)
  scheduleEvent(function() dungeonWindow:hide() end, 250)
end
