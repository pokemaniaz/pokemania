guideLabels = {
[1] = 'Basic',
[2] = 'Intermediate',
}

subLabels = {
[1] = {
		{'Teste1', 'Description1 do Basic'},
		{'Teste2', 'Description2 do Basic'},
		{'Teste3', 'Description3 do Basic'}
	},
[2] = {
		{'Teste1', 'Description1 do Intermediate'},
		{'Teste2', 'Description2 do Intermediate'}
	},
}

function init()
  connect(g_game, { onGameEnd = hide })

  guideWindow = g_ui.displayUI('guide', modules.game_interface.getRootPanel())
  guidesList = guideWindow:recursiveGetChildById('guidesList')
  guideWelcome = guideWindow:recursiveGetChildById('guideWelcome')
  guideInfos = guideWindow:recursiveGetChildById('guideInfos')
  guideInfosImage = guideInfos:recursiveGetChildById('image')
  guideInfosText = guideInfos:recursiveGetChildById('text')
  guideWindow:hide()

  for i = 1, #guideLabels do
    local label = g_ui.createWidget('GuidesListLabel', guidesList)
    label.onMouseRelease = onGuideLabelMouseRelease
    label.id = i
    label.on = false
    label:setText(tr(guideLabels[i]))
  end

  guidesList.onChildFocusChange = onGuidesListChildFocusChange
  g_keyboard.bindKeyPress('Up', function() guidesList:focusPreviousChild(KeyboardFocusReason) end, guideWindow)
  g_keyboard.bindKeyPress('Down', function() guidesList:focusNextChild(KeyboardFocusReason) end, guideWindow)
end

function terminate()
  disconnect(g_game, { onGameEnd = hide })

  g_keyboard.bindKeyPress('Up')
  g_keyboard.bindKeyPress('Down')

  guideWindow:destroy()
end

function hide()
  guideWindow:hide()
end

function show()
  guideWindow:raise()
  guideWindow:focus()
  guideWindow:show()
end

function toggle()

end

function onGuideLabelMouseRelease(self, mousePos, mouseButton)
  if mouseButton == MouseLeftButton then
    local index = guidesList:getChildIndex(self)
    if self.on then
      for i = 1, #subLabels[self.id] do
        guidesList:getChildByIndex(index+1):destroy()
      end
      self.on = false
    else
      for i = 1, #subLabels[self.id] do
        local label = g_ui.createWidget('SubGuidesListLabel')
        label.id = i
        label.parentId = self.id
        label.parentName = guideLabels[self.id]:lower()
        guidesList:insertChild(index+i, label)
        label:setText(tr(subLabels[self.id][i][1]))
        if i == 1 then
          label:focus()
        end
      end
      self.on = true
    end
  end
end

function onGuidesListChildFocusChange(self, focusedChild)
  if not focusedChild then
    guideInfos:setVisible(false)
    guideWelcome:setVisible(true)
    return
  end
  guideInfos:setVisible(true)
  guideWelcome:setVisible(false)
  guideInfosImage:setImageSource('/images/game/guide/'..focusedChild.parentName..'/'..focusedChild.id)
  guideInfosText:setText(subLabels[focusedChild.parentId][focusedChild.id][2])
end
