local dailyButton = nil

function init()
  connect(g_game, { onGameStart = online,
                    onGameEnd = onGameEnd })
  hide()
  ProtocolGame.registerExtendedOpcode(56, function(protocol, opcode, buffer) 
    local strings = string.explode(buffer, '@')
    show(strings[1], strings[2], strings[3], strings[4]) 
  end)
end

function online()
  dailyButton:setVisible(true)
end

function toggleButton()
	if dailyButton:isOn() then
		hide()
	else
		g_game.talk("/getZDailys")
		--dailyButton:setOn(true)
	end
end

--[[
function offline()
  dailysButton:setVisible(false)
  destroyWindows()
end]]

function terminate()
  disconnect(g_game, { onGameStart = online,
                       onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(56)
	if dailysWindow then
	dailysWindow:destroy()
	end
end

function onGameEnd()
	dailyButton:setVisible(false)
  if dailysWindow then
    dailysWindow:hide()
  end
	hide()
end

function sendConfirmationWindow(tipo, things, nu)
	if not confirmationWindow:isVisible() then
		addEvent(function() g_effects.fadeIn(confirmationWindow, 250) end)
	end
		local n, t
		n = string.explode(things, "|")
		t = string.explode(n[1], ";")
		local pokeT = string.explode(t[nu],",")
	confirmationWindow:setVisible(true)
	confirmationWindow:setHeight(100)
	confirmationWindow:show()
	confirmationWindow:raise()
	confirmationWindow:focus()
	confirmationWindow:getChildById('warnText'):setVisible(true)
	confirmationWindow:getChildById('warnText'):setText("VOCÊ NÃO PODERÁ TROCAR DEPOIS!")
	confirmationWindow:getChildById('warnText'):setColor('red')
	if tipo == "caught" then
		confirmationWindow:getChildById('accText'):setText("Você tem certeza que quer começar essa "..doCorrectString(tipo).." Daily de "..pokeT[1].." ?")
	else
		confirmationWindow:getChildById('accText'):setText("Você tem certeza que quer começar essa "..doCorrectString(tipo).." Daily de "..pokeT[2].." "..pokeT[1].." ?")
	end
	confirmationWindow.onEnter = function() g_game.talk('/startZDaily '..tipo..','.. nu) hideConfirmationWindow() end
	confirmationWindow:getChildById('accButton').onClick = function() g_game.talk('/startZDaily '..tipo..','.. nu) hideConfirmationWindow() end
			--startButton.onClick = function() g_game.talk('/startZDaily defeat,'.. pokespanel:getFocusedChild().n) end
	return true
end

function sendResetConfirmationWindow(tipo)
	if not confirmationWindow:isVisible() then
		addEvent(function() g_effects.fadeIn(confirmationWindow, 250) end)
	end
	confirmationWindow:setVisible(true)
	confirmationWindow:setHeight(80)
	confirmationWindow:show()
	confirmationWindow:raise()
	confirmationWindow:focus()
	confirmationWindow:getChildById('warnText'):setVisible(false)
	confirmationWindow:getChildById('accText'):setText("Você tem certeza que quer resetar essas "..doCorrectString(tipo).." Tasks por 1 Diamond ?")

	confirmationWindow.onEnter = function() g_game.talk('/resetZDaily '..tipo) hideConfirmationWindow() end
	confirmationWindow:getChildById('accButton').onClick = function() g_game.talk('/resetZDaily '..tipo) hideConfirmationWindow() end
			--startButton.onClick = function() g_game.talk('/startZDaily defeat,'.. pokespanel:getFocusedChild().n) end
	return true
end

function loading(tipo)
	local panel = defeatPanel
		local pokespanel = defeatPanel:getChildById('mypanel'):getChildById('pokespanel')
	if tipo == "defeat" then panel = defeatPanel elseif tipo == "caught" then panel = caughtPanel elseif tipo == "dungeon" then panel = dungeonPanel end
	panel:getChildById('load'):setVisible(true)
	panel:getChildById('mypanel'):setVisible(false)
	panel:getChildById('start'):setVisible(false)
	panel:getChildById('complete'):setVisible(false)
	panel:getChildById('complete2'):setVisible(false)
	panel:getChildById('reset'):setVisible(false)
	panel:getChildById('rewardpanel'):setVisible(false)
	panel:getChildById('completed'):setVisible(false)
end

function show(tipo, first, things, progress)
	if not dailysWindow then
  dailysWindow = g_ui.displayUI('dailys')

  tabBarStyles = dailysWindow:getChildById('stylesTabBar')
  tabBarStyles:setContentWidget(dailysWindow:getChildById('stylesTabContent'))

  if not dailysWindow:isVisible() then
    addEvent(function() g_effects.fadeIn(dailysWindow, 250) end)
  end
  dailysWindow:show()
  dailysWindow:raise()
  --dailysWindow:focus()

  defeatPanel = g_ui.loadUI('defeat')
  tabBarStyles:addTab('', defeatPanel, '/images/dailys/styles/defeat', 'defeat')

  caughtPanel = g_ui.loadUI('caught')
  tabBarStyles:addTab('', caughtPanel, '/images/dailys/styles/caught', 'caught')

  dungeonPanel = g_ui.loadUI('dungeon')
  tabBarStyles:addTab('', dungeonPanel, '/images/dailys/styles/dungeon', 'dungeon')

  confirmationWindow = g_ui.displayUI('confirmation')
confirmationWindow:hide()	
hideConfirmationWindow()
	end
	if dailysWindow then dailyButton:setOn(true) end
	tabBarStyles.onTabChange = function(self, focusedChild)
		loading(focusedChild:getId())
		g_game.talk("/getZDailys ".. focusedChild:getId())
		return true
	end
	refresh(tipo, things, progress)
	
  return true
end

function refresh(tipo, things, progress)
	if tipo == "defeat" then
		local n, t
		if not tonumber(things) then
		n = string.explode(things, "|")
		t = string.explode(n[1], ";")
		end
		defeatPanel:getChildById('load'):setVisible(false)
		local poket1 = string.explode(t[1], ",")
		local pokespanel = defeatPanel:getChildById('mypanel'):getChildById('pokespanel')
		local poke1 = pokespanel:getChildById('pokepanel1')
		local poke2 = pokespanel:getChildById('pokepanel2')
		local poke3 = pokespanel:getChildById('pokepanel3')
		local startButton = defeatPanel:getChildById('start')
		local completeButton = defeatPanel:getChildById('complete')
		local completeButton2 = defeatPanel:getChildById('complete2')
		local resetButton = defeatPanel:getChildById('reset')
		local xpReward = defeatPanel:getChildById('rewardpanel'):getChildById('rewardExp')
		local tokensReward = defeatPanel:getChildById('rewardpanel'):getChildById('rewardTokens')
		if tonumber(progress) == 3 then 
			startButton:setVisible(false)
			completeButton:setVisible(false)
			completeButton2:setVisible(false)
			resetButton:setVisible(false)
			defeatPanel:getChildById('mypanel'):setVisible(false)
			defeatPanel:getChildById('rewardpanel'):setVisible(false)
			defeatPanel:getChildById('completed'):setVisible(true)
			defeatPanel:getChildById('completed'):setText("Você já completou todas Defeat Tasks hoje.")
			return true
		else
			defeatPanel:getChildById('mypanel'):setVisible(true)
			defeatPanel:getChildById('rewardpanel'):setVisible(true)
			defeatPanel:getChildById('completed'):setVisible(false)
		end
		local circuitLevel = tonumber(n[2]) < 150 and "80~149" or "150~199"
		local d = (progress+1) +(tonumber(n[2]) < 150 and 0 or 1)
			local difficulty = d == 1 and "Easy" or d == 2 and "Medium" or d == 3 and "Hard" or d == 4 and "Insane" or "Easy"
			defeatPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setText(circuitLevel)
			if tonumber(n[2]) < 80 or circuitLevel == "150~199" and tonumber(n[2]) < 150 then
				defeatPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('red')
			elseif tonumber(n[2]) >= 200 then
				defeatPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('gray')
			else
				defeatPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('white')
			end
			defeatPanel:getChildById('mypanel'):getChildById('circuitProgress'):getChildById('value'):setText("["..progress.."/3]")
			defeatPanel:getChildById('mypanel'):getChildById('difficulty'):getChildById('value'):setText(difficulty)
			tokensReward:setItemId(13278)

		if t[2] then
			local poket2 = string.explode(t[2], ",")
			poke1:setVisible(true)
			poke2:setVisible(true)
			poke3:setVisible(false)
			poke1.n = 1
			poke2.n = 2
			poke1:getChildById('text'):setText(poket1[2].." "..doCorrectString(poket1[1]))
			poke2:getChildById('text'):setText(poket2[2].." "..doCorrectString(poket2[1]))
			poke1:setImageSource('/images/dailys/pokepanel'.. poket1[3])
			poke2:setImageSource('/images/dailys/pokepanel'.. poket2[3])
			poke1:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket1[1]))
			poke2:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket2[1]))
			poke1:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket1[3])
			poke2:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket2[3])

			xpReward:setText("+"..(pokespanel:getFocusedChild().n == 1 and poket1[4] or poket2[4]).." EXP")
			if pokespanel:getFocusedChild().n == 1 and tonumber(poket1[5]) > 0 or pokespanel:getFocusedChild().n == 2 and tonumber(poket2[5]) > 0 then
				tokensReward:setVisible(true)
				local count = pokespanel:getFocusedChild().n == 1 and poket1[5] or poket2[5]
				tokensReward:getChildById('count'):setText('+'..count)
			else
				tokensReward:setVisible(false)
			end
			
			startButton:setVisible(true)
			completeButton:setVisible(false)
			completeButton2:setVisible(false)
			resetButton:setVisible(true)

			startButton.onClick = function() sendConfirmationWindow(tipo, things, tonumber(pokespanel:getFocusedChild().n)) end -- g_game.talk('/startZDaily defeat,'.. pokespanel:getFocusedChild().n) end
			resetButton.onClick = function() sendResetConfirmationWindow(tipo) end

			pokespanel.onChildFocusChange = function(self, focusedChild)
				if focusedChild == nil then return end
				if pokespanel:getFocusedChild().n == 1 then
					xpReward:setText("+"..(poket1[4]).." EXP")
					if tonumber(poket1[5]) > 0 then
						tokensReward:setVisible(true)
						tokensReward:getChildById('count'):setText('+'..poket1[5])
					else
						tokensReward:setVisible(false)
					end
				else
					xpReward:setText("+"..(poket2[4]).." EXP")
					if tonumber(poket2[5]) > 0 then
						tokensReward:setVisible(true)
						tokensReward:getChildById('count'):setText('+'..poket2[5])
					else
						tokensReward:setVisible(false)
					end
				end
			end
		else
			poke1:setVisible(false)
			poke2:setVisible(false)
			poke3:setVisible(true)
			poke3:getChildById('name'):setText(doCorrectString(poket1[1]))
			poke3:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket1[1]))
			poke3:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket1[3])

			xpReward:setText("+"..poket1[4].." EXP")
			if tonumber(poket1[5]) > 0 then
				tokensReward:setVisible(true)
				tokensReward:getChildById('count'):setText('+'..poket1[5])
			else
				tokensReward:setVisible(false)
			end

			leftProgressBar = poke3:getChildById('leftBar')
			leftProgressBar:setValue((tonumber(n[3])*-1)+tonumber(poket1[2]), 0, tonumber(poket1[2]))
			leftProgressBar:setBackgroundColor('green')
			leftProgressBar:setText((tonumber(n[3])*-1)+tonumber(poket1[2])..'/'..tonumber(poket1[2]))

			startButton:setVisible(false)
			resetButton:setVisible(false)
			if tonumber(n[3]) > 0 then
				completeButton:setVisible(false)
				completeButton2:setVisible(true)
				completeButton2:setTooltip("Termine de derrotar todos "..doCorrectString(poket1[1]).." para receber sua premiação.")
			else
				completeButton:setVisible(true)
				completeButton2:setVisible(false)
			end
			completeButton.onClick = function() g_game.talk('/completeZDaily defeat') end
		end
	--addAnchor(AnchorRight, 'parent', AnchorRight)
		return true
	elseif tipo == "dungeon" then
		local n, t
		if not tonumber(things) then
		n = string.explode(things, "|")
		t = string.explode(n[1], ";")
		end
		local poket1 = string.explode(t[1], ",")
		dungeonPanel:getChildById('load'):setVisible(false)
		local pokespanel = dungeonPanel:getChildById('mypanel'):getChildById('pokespanel')
		local poke1 = pokespanel:getChildById('pokepanel1')
		local poke2 = pokespanel:getChildById('pokepanel2')
		local poke3 = pokespanel:getChildById('pokepanel3')
		local startButton = dungeonPanel:getChildById('start')
		local completeButton = dungeonPanel:getChildById('complete')
		local completeButton2 = dungeonPanel:getChildById('complete2')
		local resetButton = dungeonPanel:getChildById('reset')
		local xpReward = dungeonPanel:getChildById('rewardpanel'):getChildById('rewardExp')
		local tokensReward = dungeonPanel:getChildById('rewardpanel'):getChildById('rewardTokens')
		if tonumber(progress) == 3 then 
			startButton:setVisible(false)
			completeButton:setVisible(false)
			completeButton2:setVisible(false)
			resetButton:setVisible(false)
			dungeonPanel:getChildById('mypanel'):setVisible(false)
			dungeonPanel:getChildById('rewardpanel'):setVisible(false)
			dungeonPanel:getChildById('completed'):setVisible(true)
			dungeonPanel:getChildById('completed'):setText("Você já completou todas Dungeon Tasks hoje.")
			return true
		else
			dungeonPanel:getChildById('mypanel'):setVisible(true)
			dungeonPanel:getChildById('rewardpanel'):setVisible(true)
			dungeonPanel:getChildById('completed'):setVisible(false)
		end
		local circuitLevel = tonumber(n[2]) < 150 and "80~149" or "150~199"
		local d = (progress+1) +(tonumber(n[2]) < 150 and 0 or 1)
			local difficulty = d == 1 and "Easy" or d == 2 and "Medium" or d == 3 and "Hard" or d == 4 and "Insane" or "Easy"
			dungeonPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setText(circuitLevel)
			if tonumber(n[2]) < 80 or circuitLevel == "150~199" and tonumber(n[2]) < 150 then
				dungeonPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('red')
			elseif tonumber(n[2]) >= 200 then
				dungeonPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('gray')
			else
				dungeonPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('white')
			end
			dungeonPanel:getChildById('mypanel'):getChildById('circuitProgress'):getChildById('value'):setText("["..progress.."/3]")
			dungeonPanel:getChildById('mypanel'):getChildById('difficulty'):getChildById('value'):setText(difficulty)
			tokensReward:setItemId(15495)

		if t[2] then
			local poket2 = string.explode(t[2], ",")
			poke1:setVisible(true)
			poke2:setVisible(true)
			poke3:setVisible(false)
			poke1.n = 1
			poke2.n = 2
			poke1:getChildById('text'):setText(poket1[2].." "..doCorrectString(poket1[1]))
			poke2:getChildById('text'):setText(poket2[2].." "..doCorrectString(poket2[1]))
			poke1:setImageSource('/images/dailys/pokepanel'.. poket1[3])
			poke2:setImageSource('/images/dailys/pokepanel'.. poket2[3])
			poke1:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket1[6]))
			poke2:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket2[6]))
			poke1:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket1[3])
			poke2:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket2[3])

			xpReward:setText("+"..(pokespanel:getFocusedChild().n == 1 and poket1[4] or poket2[4]).." EXP")
			if pokespanel:getFocusedChild().n == 1 and tonumber(poket1[5]) > 0 or pokespanel:getFocusedChild().n == 2 and tonumber(poket2[5]) > 0 then
				tokensReward:setVisible(true)
				local count = pokespanel:getFocusedChild().n == 1 and poket1[5] or poket2[5]
				tokensReward:getChildById('count'):setText('+'..count)
			else
				tokensReward:setVisible(false)
			end
			
			startButton:setVisible(true)
			completeButton:setVisible(false)
			completeButton2:setVisible(false)
			resetButton:setVisible(true)

			startButton.onClick = function() sendConfirmationWindow(tipo, things, tonumber(pokespanel:getFocusedChild().n)) end -- g_game.talk('/startZDaily dungeon,'.. pokespanel:getFocusedChild().n) end
			resetButton.onClick = function() sendResetConfirmationWindow(tipo) end

			pokespanel.onChildFocusChange = function(self, focusedChild)
				if focusedChild == nil then return end
				if pokespanel:getFocusedChild().n == 1 then
					xpReward:setText("+"..(poket1[4]).." EXP")
					if tonumber(poket1[5]) > 0 then
						tokensReward:setVisible(true)
						tokensReward:getChildById('count'):setText('+'..poket1[5])
					else
						tokensReward:setVisible(false)
					end
				else
					xpReward:setText("+"..(poket2[4]).." EXP")
					if tonumber(poket2[5]) > 0 then
						tokensReward:setVisible(true)
						tokensReward:getChildById('count'):setText('+'..poket2[5])
					else
						tokensReward:setVisible(false)
					end
				end
			end
		else
			poke1:setVisible(false)
			poke2:setVisible(false)
			poke3:setVisible(true)
			poke3:getChildById('name'):setText(doCorrectString(poket1[1]))
			poke3:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket1[6]))
			poke3:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket1[3])

			xpReward:setText("+"..poket1[4].." EXP")
			if tonumber(poket1[5]) > 0 then
				tokensReward:setVisible(true)
				tokensReward:getChildById('count'):setText('+'..poket1[5])
			else
				tokensReward:setVisible(false)
			end

			leftProgressBar = poke3:getChildById('leftBar')
			leftProgressBar:setValue((tonumber(n[3])*-1)+tonumber(poket1[2]), 0, tonumber(poket1[2]))
			leftProgressBar:setBackgroundColor('green')
			leftProgressBar:setText((tonumber(n[3])*-1)+tonumber(poket1[2])..'/'..tonumber(poket1[2]))

			startButton:setVisible(false)
			resetButton:setVisible(false)

			if tonumber(n[3]) > 0 then
				completeButton:setVisible(false)
				completeButton2:setVisible(true)
				completeButton2:setTooltip("Termine de derrotar todos "..doCorrectString(poket1[1]).." para receber sua premiação.")
			else
				completeButton:setVisible(true)
				completeButton2:setVisible(false)
			end
			completeButton.onClick = function() g_game.talk('/completeZDaily dungeon') end
		end
	elseif tipo == "caught" then
		local n, t
		if not tonumber(things) then
		n = string.explode(things, "|")
		t = string.explode(n[1], ";")
		end
		caughtPanel:getChildById('load'):setVisible(false)
		local poket1 = string.explode(t[1], ",")
		local pokespanel = caughtPanel:getChildById('mypanel'):getChildById('pokespanel')
		local poke1 = pokespanel:getChildById('pokepanel1')
		local poke2 = pokespanel:getChildById('pokepanel2')
		local poke3 = pokespanel:getChildById('pokepanel3')
		local startButton = caughtPanel:getChildById('start')
		local completeButton = caughtPanel:getChildById('complete')
		local completeButton2 = caughtPanel:getChildById('complete2')
		local resetButton = caughtPanel:getChildById('reset')
		local xpReward = caughtPanel:getChildById('rewardpanel'):getChildById('rewardExp')
		local tokensReward = caughtPanel:getChildById('rewardpanel'):getChildById('rewardTokens')
		if tonumber(progress) == 3 then 
			startButton:setVisible(false)
			completeButton:setVisible(false)
			completeButton2:setVisible(false)
			resetButton:setVisible(false)
			caughtPanel:getChildById('mypanel'):setVisible(false)
			caughtPanel:getChildById('rewardpanel'):setVisible(false)
			caughtPanel:getChildById('completed'):setVisible(true)
			caughtPanel:getChildById('completed'):setText("Você já completou todas Caught Tasks hoje.")
			return true
		else
			caughtPanel:getChildById('mypanel'):setVisible(true)
			caughtPanel:getChildById('rewardpanel'):setVisible(true)
			caughtPanel:getChildById('completed'):setVisible(false)
		end
		local circuitLevel = tonumber(n[2]) < 150 and "80~149" or "150~199"
		local d = (progress+1) +(tonumber(n[2]) < 150 and 0 or 1)
			local difficulty = d == 1 and "Easy" or d == 2 and "Medium" or d == 3 and "Hard" or d == 4 and "Insane" or "Easy"
			caughtPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setText(circuitLevel)
			if tonumber(n[2]) < 80 or circuitLevel == "150~199" and tonumber(n[2]) < 150 then
				caughtPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('red')
			elseif tonumber(n[2]) >= 200 then
				caughtPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('gray')
			else
				caughtPanel:getChildById('mypanel'):getChildById('circuitLevel'):getChildById('value'):setColor('white')
			end
			caughtPanel:getChildById('mypanel'):getChildById('circuitProgress'):getChildById('value'):setText("["..progress.."/3]")
			caughtPanel:getChildById('mypanel'):getChildById('difficulty'):getChildById('value'):setText(difficulty)
			tokensReward:setItemId(15495)

		if t[2] then
			local poket2 = string.explode(t[2], ",")
			poke1:setVisible(true)
			poke2:setVisible(true)
			poke3:setVisible(false)
			poke1.n = 1
			poke2.n = 2
			poke1:getChildById('text'):setText("Caught "..doCorrectString(poket1[1]))
			poke2:getChildById('text'):setText("Caught "..doCorrectString(poket2[1]))
			poke1:setImageSource('/images/dailys/pokepanel'.. poket1[2])
			poke2:setImageSource('/images/dailys/pokepanel'.. poket2[2])
			poke1:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket1[1]))
			poke2:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket2[1]))
			poke1:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket1[2] ..'b')
			poke2:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket2[2] ..'b')

			xpReward:setText("+"..(pokespanel:getFocusedChild().n == 1 and poket1[3] or poket2[3]).." EXP")
			tokensReward:setVisible(false)
			
			startButton:setVisible(true)
			completeButton:setVisible(false)
			completeButton2:setVisible(false)
			resetButton:setVisible(true)

			startButton.onClick = function() sendConfirmationWindow(tipo, things, tonumber(pokespanel:getFocusedChild().n)) end -- g_game.talk('/startZDaily caught,'.. pokespanel:getFocusedChild().n) end
			resetButton.onClick = function() sendResetConfirmationWindow(tipo) end

			pokespanel.onChildFocusChange = function(self, focusedChild)
				if focusedChild == nil then return end
				if pokespanel:getFocusedChild().n == 1 then
					xpReward:setText("+"..(poket1[3]).." EXP")
				else
					xpReward:setText("+"..(poket2[3]).." EXP")
				end
			end

		else
			poke1:setVisible(false)
			poke2:setVisible(false)
			poke3:setVisible(true)
			poke3:getChildById('name'):setText(doCorrectString(poket1[1]))
			poke3:getChildById('image'):setImageSource('/images/game/pokedex/'.. string.lower(poket1[1]))
			poke3:getChildById('icon'):setImageSource('/images/dailys/miscellaneous/'.. poket1[2]..'b')

			xpReward:setText("+"..poket1[3].." EXP")
			tokensReward:setVisible(false)

			leftProgressBar = poke3:getChildById('leftBar')
			leftProgressBar:setValue((tonumber(n[3])*-1)+1, 0, 1)
			leftProgressBar:setBackgroundColor('green')
			leftProgressBar:setText((tonumber(n[3])*-1)+1 ..'/1')

			startButton:setVisible(false)
			resetButton:setVisible(false)
			if tonumber(n[3]) > 0 then
				completeButton:setVisible(false)
				completeButton2:setVisible(true)
				completeButton2:setTooltip("Capture o "..doCorrectString(poket1[1]).." para receber sua premiação.")
			else
				completeButton:setVisible(true)
				completeButton2:setVisible(false)
			end
			completeButton.onClick = function() g_game.talk('/completeZDaily caught') end
		end
	--addAnchor(AnchorRight, 'parent', AnchorRight)
		return true
	end

end
function hideConfirmationWindow()
	addEvent(function() g_effects.fadeOut(confirmationWindow, 250) end)
	scheduleEvent(function() confirmationWindow:hide() end, 250)
	return true
end

function hide()
	if dailysWindow then
	hideConfirmationWindow()
	dailysWindow:destroy()
	dailysWindow = nil
	dailyButton:setOn(false)
	end
end
