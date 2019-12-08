function init()
  connect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.registerExtendedOpcode(32, function(protocol, opcode, buffer)

  local strings = string.explode(buffer, '|')
	
	show(strings[1], strings[2], strings[3], strings[4], strings[5], strings[6], strings[7], strings[8], strings[9], strings[10], strings[11])
  end)
  
	ProtocolGame.registerExtendedOpcode(31, function(protocol, opcode, buffer)
		if buffer == "Buy" then
			setBuyCond()
		elseif buffer == "Tower" then
			doMsgTower()
		elseif buffer == "Tower2" then
			doCancelTower()
		elseif buffer == "NoRoom" then
			doCancelRoom()
		elseif buffer == "Finish" then
			doMsgFinish()
		else
			doCancelBuy()
		end
	end)
	
  panelWindow = g_ui.displayUI('towerpanel')

  hide()
end

function terminate()
  disconnect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(32)
  ProtocolGame.unregisterExtendedOpcode(31)
  
  panelWindow:destroy()
end

function onGameEnd()
	hide()
end

function show(painel, floor1, floor2, floor3, floor4, floor5, floor6, floor7, floor8, points, chance)

	if painel == "false" then
		hide()
		return true
	end
  
	if not panelWindow:isVisible() then
		addEvent(function() g_effects.fadeIn(panelWindow, 250) end)
	end

	panelWindow:show()
	panelWindow:raise()
	panelWindow:focus()  
 
	sto1 = tonumber(floor1)
	sto2 = tonumber(floor2)
	sto3 = tonumber(floor3)
	sto4 = tonumber(floor4)
	sto5 = tonumber(floor5)
	sto6 = tonumber(floor6)
	sto7 = tonumber(floor7)
	sto8 = tonumber(floor8)
	pontos = tonumber(points)
	chance = tonumber(chance)
	floor1 = panelWindow:getChildById('floor1')
	floor2 = panelWindow:getChildById('floor2')
	floor3 = panelWindow:getChildById('floor3')
	floor4 = panelWindow:getChildById('floor4')
	floor5 = panelWindow:getChildById('floor5')
	floor6 = panelWindow:getChildById('floor6')
	floor7 = panelWindow:getChildById('floor7')
	floor8 = panelWindow:getChildById('floor8')
	valor = panelWindow:getChildById('points')
	vez = panelWindow:getChildById('chance')	
	
	if sto1 >= 1 then
			floor1:setImageSource('/images/others/buttonfloor1')	
			floor1.onClick = function() g_game.talk("/entrar1") end
		else
			floor1:setImageSource('/images/others/buttonfloor1off')	
	end
	
	if sto2 >= 1 then
			floor2:setImageSource('/images/others/buttonfloor2')	
			floor2.onClick = function() g_game.talk("/entrar2") end
		else
			floor2:setImageSource('/images/others/buttonfloor2off')	
	end	
	
	if sto3 >= 1 then
			floor3:setImageSource('/images/others/buttonfloor3')
			floor3.onClick = function() g_game.talk("/entrar3") end	
		else
			floor3:setImageSource('/images/others/buttonfloor3off')	
	end	
	
	if sto4 >= 1 then
			floor4:setImageSource('/images/others/buttonfloor4')	
			floor4.onClick = function() g_game.talk("/entrar4") end
		else
			floor4:setImageSource('/images/others/buttonfloor4off')	
	end	
	
	if sto5 >= 1 then
			floor5:setImageSource('/images/others/buttonfloor5')	
			floor5.onClick = function() g_game.talk("/entrar5") end
		else
			floor5:setImageSource('/images/others/buttonfloor5off')	
	end	
	
	if sto6 >= 1 then
			floor6:setImageSource('/images/others/buttonfloor6')
			floor6.onClick = function() g_game.talk("/entrar6") end	
		else
			floor6:setImageSource('/images/others/buttonfloor6off')	
	end	
	
	if sto7 >= 1 then
			floor7:setImageSource('/images/others/buttonfloor7')
			floor7.onClick = function() g_game.talk("/entrar7") end	
		else
			floor7:setImageSource('/images/others/buttonfloor7off')	
	end	

	if sto8 >= 1 then
			floor8:setImageSource('/images/others/buttonfloor8')	
			floor8.onClick = function() g_game.talk("/entrar8") end
		else
			floor8:setImageSource('/images/others/buttonfloor8off')	
	end	
	
	if pontos then
		valor:setText(pontos)
	end
	
	if chance then
		vez:setText(chance)
	end	
		
	
end

function setBuyCond()
	buyWindow = g_ui.displayUI('atencion')
	local msg = "Atenção se você deseja comprar clique novamente, cuidado para não clicar em outro!"

		buyWindow:setText("Atenção")
		buyWindow:getChildById('atencionText'):setText(msg)
end

function doMsgTower()
	buyWindow = g_ui.displayUI('atencion')
	local msg = "Atenção perigo a vista, se você desejar proseguir clique novamente!"

		buyWindow:setText("Atenção")
		buyWindow:getChildById('atencionText'):setText(msg)
end

function doMsgFinish(valor)
	buyWindow = g_ui.displayUI('atencion')
	local msg = "Parabéns, você acaba de ganhar pontos por concluir a Tower."

		buyWindow:setText("Atenção")
		buyWindow:getChildById('atencionText'):setText(msg)
end

function doCancelTower()
	buyWindow = g_ui.displayUI('atencion')
	local msg = "Você já gastou todas as chances de entrar na Tower, até a proxima!"

		buyWindow:setText("Atenção")
		buyWindow:getChildById('atencionText'):setText(msg)
end

function doCancelRoom()
	buyWindow = g_ui.displayUI('atencion')
	local msg = "Não tem nenhuma sala da tower disponível no momento, tente mais tarde!"

		buyWindow:setText("Atenção")
		buyWindow:getChildById('atencionText'):setText(msg)
end

function doCancelBuy()
	buyWindow = g_ui.displayUI('atencion')
	local msg = "Você não tem pontos o suficiente para efetuar essa compra, volte assim que possível."

		buyWindow:setText("Atenção")
		buyWindow:getChildById('atencionText'):setText(msg)
end

function hide()
	addEvent(function() g_effects.fadeOut(panelWindow, 250) end)
	scheduleEvent(function() panelWindow:hide() end, 250)
	addEvent(function() g_effects.fadeOut(panelWindow, 250) end)
	scheduleEvent(function() panelWindow:hide() end, 250)
end

function hideMsg()
	addEvent(function() g_effects.fadeOut(buyWindow, 250) end)
	scheduleEvent(function() buyWindow:hide() end, 250)
	addEvent(function() g_effects.fadeOut(buyWindow, 250) end)
	scheduleEvent(function() buyWindow:hide() end, 250)
end

function hideWindow()
  addEvent(function() g_effects.fadeOut(panelWindow, 250) end)
  scheduleEvent(function() panelWindow:hide() end, 250)
end