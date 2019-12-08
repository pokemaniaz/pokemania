minimapWidget = nil
minimapVisible = true
minimapWindow = nil
otmm = true
preloaded = false
fullmapView = false
oldZoom = nil
oldPos = nil

function init()
  local gameRootPanel = modules.game_interface.getRootPanel()
  minimapWindow = g_ui.loadUI('minimap', modules.game_interface.getMapPanel())

  minimapWidget = minimapWindow:recursiveGetChildById('minimap')

  minimapWidget:recursiveGetChildById('posLabel').onMouseRelease = onPositionMouseRelease

  g_keyboard.bindKeyPress('Alt+Left', function() minimapWidget:move(1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Right', function() minimapWidget:move(-1,0) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Up', function() minimapWidget:move(0,1) end, gameRootPanel)
  g_keyboard.bindKeyPress('Alt+Down', function() minimapWidget:move(0,-1) end, gameRootPanel)
  g_keyboard.bindKeyDown('Ctrl+Tab', toggleFullMap)
  g_keyboard.bindKeyDown('Ctrl+M', toggle)

  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })

  connect(LocalPlayer, {
    onPositionChange = updateCameraPosition
  })

  if g_game.isOnline() then
    online()
  end
end

function terminate()
  if g_game.isOnline() then
    saveMap()
  end

  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline,
  })

  disconnect(LocalPlayer, {
    onPositionChange = updateCameraPosition
  })

  local gameRootPanel = modules.game_interface.getRootPanel()
  g_keyboard.unbindKeyPress('Alt+Left', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Right', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Up', gameRootPanel)
  g_keyboard.unbindKeyPress('Alt+Down', gameRootPanel)
  g_keyboard.unbindKeyDown('Ctrl+Tab')
  g_keyboard.unbindKeyDown('Ctrl+M')

  minimapWindow:destroy()
end

function setMonsterCave(posx, posy, posz, icon, description)
	local pos = {}
	pos.x = posx
	pos.y = posy
	pos.z = posz
	minimapWidget:addFlag(pos, icon, description)
end


function removeMonsterCave(posx, posy, posz, icon, description)
	local pos = {}
	pos.x = posx
	pos.y = posy
	pos.z = posz
	minimapWidget:removeFlag(pos, icon, description)
end

function toggle(value)
  local options = modules.client_options
  if not value then
    minimapWindow:hide()
    options.setOption('minimapSize', options.getOption('minimapSize'), true)
  else
    minimapWindow:show()
    options.setOption('minimapSize', options.getOption('minimapSize'), true)
  end
end

function preload()
  loadMap(false)
  preloaded = true
end

function online()
  loadMap(not preloaded)
  updateCameraPosition()
end

function offline()
  saveMap()
end

function loadMap(clean)
  local clientVersion = g_game.getClientVersion()

  if clean then
    g_minimap.clean()
  end

  if otmm then
    local minimapFile = '/minimap.otmm'
    if g_resources.fileExists(minimapFile) then
      g_minimap.loadOtmm(minimapFile)
    end
  else
    local minimapFile = '/minimap_' .. clientVersion .. '.otcm'
    if g_resources.fileExists(minimapFile) then
      g_map.loadOtcm(minimapFile)
    end
  end
  minimapWidget:load()
end

function saveMap()
  local clientVersion = g_game.getClientVersion()
  if otmm then
    local minimapFile = '/minimap.otmm'
    g_minimap.saveOtmm(minimapFile)
  else
    local minimapFile = '/minimap_' .. clientVersion .. '.otcm'
    g_map.saveOtcm(minimapFile)
  end
  minimapWidget:save()
end

function updateCameraPosition()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  if not pos then return end
  if not minimapWidget:isDragging() then
    if not fullmapView then
      minimapWidget:setCameraPosition(player:getPosition())
    end
    minimapWidget:setCrossPosition(player:getPosition())
    minimapWidget:getChildById('posLabel'):setText('X:'..pos.x..' Y:'..pos.y..' Z:'..pos.z)
  end
end

function toggleFullMap()
  if not fullmapView then
    fullmapView = true
    minimapWindow:setVisible(false)
    minimapWidget:setParent(modules.game_interface.getRootPanel())
    minimapWidget:fill('parent')
    minimapWidget:setMarginRight(0)
    minimapWidget:setAlternativeWidgetsVisible(true)
    for i = 2, 5 do
      minimapWidget:getChildren()[i]:setVisible(true)
    end
  else
    fullmapView = false
    if modules.client_options.getOption('displayMinimap') then
      minimapWindow:setVisible(true)
    end
    minimapWidget:setParent(minimapWindow)
    minimapWidget:fill('parent')
    minimapWidget:setMarginRight(23)
    minimapWidget:setAlternativeWidgetsVisible(false)
    for i = 2, 5 do
      minimapWidget:getChildren()[i]:setVisible(false)
    end
  end

  local zoom = oldZoom or 0
  local pos = oldPos or minimapWidget:getCameraPosition()
  oldZoom = minimapWidget:getZoom()
  oldPos = minimapWidget:getCameraPosition()
  minimapWidget:setZoom(zoom)
  minimapWidget:setCameraPosition(pos)
end

function onPositionMouseRelease(self, mousePosition, mouseButton)
  if mouseButton == MouseRightButton then
    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)
    menu:addOption(tr('Copy Position'), function() g_window.setClipboardText(self:getText()) end)
    menu:display(mousePos)
  end
end

function getMinimapWindow()
  return minimapWindow
end
