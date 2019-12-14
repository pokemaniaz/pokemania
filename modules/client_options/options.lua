local defaultOptions = {
  vsync = false,
  fullscreen = false,
  classicControl = false,
  smartWalk = false,
  dashWalk = false,
  autoChaseOverride = true,
  showStatusMessagesInConsole = true,
  showEventMessagesInConsole = true,
  showInfoMessagesInConsole = true,
  showTimestampsInConsole = true,
  showLevelsInConsole = true,
  showPrivateMessagesInConsole = true,
  showPrivateMessagesOnScreen = true,
  foregroundFrameRate = 61,
  backgroundFrameRate = 201,
  consoleSize = 100,
  minimapSize = 100,
  painterEngine = 0,
  enableAudio = true,
  enableMusicSound = true,
  musicSoundVolume = 10,
  enableLights = true,
  ambientLight = 25,
  displayNames = true,
  displayHealth = true,
  displayMana = true,
  displayText = true,
  forcePokemonShortcuts = false,
  forceItemShortcuts = false,
  displayMinimap = true,
}

local optionsBackground
local optionsWindow
local optionsButton
local optionsTabBar
local options = {}
local generalPanel
local consolePanel
local graphicsPanel
local soundPanel

local function setupGraphicsEngines()
  local enginesRadioGroup = UIRadioGroup.create()
  local ogl1 = graphicsPanel:getChildById('opengl1')
  local ogl2 = graphicsPanel:getChildById('opengl2')
  local dx9 = graphicsPanel:getChildById('directx9')
  enginesRadioGroup:addWidget(ogl1)
  enginesRadioGroup:addWidget(ogl2)
  enginesRadioGroup:addWidget(dx9)

  if g_window.getPlatformType() == 'WIN32-EGL' then
    enginesRadioGroup:selectWidget(dx9)
    ogl1:setEnabled(false)
    ogl2:setEnabled(false)
    dx9:setEnabled(true)
  else
    ogl1:setEnabled(g_graphics.isPainterEngineAvailable(1))
    ogl2:setEnabled(g_graphics.isPainterEngineAvailable(2))
    dx9:setEnabled(false)
    if g_graphics.getPainterEngine() == 2 then
      enginesRadioGroup:selectWidget(ogl2)
    else
      enginesRadioGroup:selectWidget(ogl1)
    end

    if g_app.getOs() ~= 'windows' then
      dx9:hide()
    end
  end

  enginesRadioGroup.onSelectionChange = function(self, selected)
    if selected == ogl1 then
      setOption('painterEngine', 1)
    elseif selected == ogl2 then
      setOption('painterEngine', 2)
    end
  end

  if not g_graphics.canCacheBackbuffer() then
    graphicsPanel:getChildById('foregroundFrameRate'):disable()
    graphicsPanel:getChildById('foregroundFrameRateLabel'):disable()
  end
end

function init()
  for k,v in pairs(defaultOptions) do
    g_settings.setDefault(k, v)
    options[k] = v
  end

  optionsBackground = g_ui.displayUI('options')
  optionsWindow = optionsBackground:getChildById('optionsWindow')
  optionsButton = g_ui.displayUI('optionsbutton')
  optionsWindow:hide()
  optionsBackground:hide()

  optionsTabBar = optionsWindow:getChildById('optionsTabBar')
  optionsTabBar:setContentWidget(optionsWindow:getChildById('optionsTabContent'))

  g_keyboard.bindKeyDown('Ctrl+Shift+F', function() toggleOption('fullscreen') end)
  g_keyboard.bindKeyDown('Ctrl+N', toggleDisplays)

  generalPanel = g_ui.loadUI('game')
  optionsTabBar:addTab(tr('Game'), generalPanel, '/images/optionstab/game')

  consolePanel = g_ui.loadUI('console')
  optionsTabBar:addTab(tr('Chat'), consolePanel, '/images/optionstab/console')

  graphicsPanel = g_ui.loadUI('graphics')
  optionsTabBar:addTab(tr('Graphics'), graphicsPanel, '/images/optionstab/graphics')

  audioPanel = g_ui.loadUI('audio')
  optionsTabBar:addTab(tr('Audio'), audioPanel, '/images/optionstab/audio')

  generalPanel:recursiveGetChildById('changeLocale'):addOption(tr('English'), 'en')
  generalPanel:recursiveGetChildById('changeLocale'):addOption(tr('Portuguese'), 'pt')
  generalPanel:recursiveGetChildById('changeLocale'):setCurrentOptionByData(modules.client_locales.getCurrentLocale().name)
  generalPanel:recursiveGetChildById('changeLocale').onOptionChange = onLocaleChange

  addEvent(function() setup() end)
end

function terminate()
  g_keyboard.unbindKeyDown('Ctrl+Shift+F')
  g_keyboard.unbindKeyDown('Ctrl+N')
  optionsBackground:destroy()
  optionsButton:destroy()
end

function onLocaleChange(comboBox, option)
  modules.client_locales.selectFirstLocale(comboBox:getDataByOption(option))
end

function setup()
  setupGraphicsEngines()

  -- load options
  for k,v in pairs(defaultOptions) do
    if type(v) == 'boolean' then
      setOption(k, g_settings.getBoolean(k), true)
    elseif type(v) == 'number' then
      setOption(k, g_settings.getNumber(k), true)
    end
  end
end

function toggle()
  if optionsBackground:isVisible() then
    hide()
  else
    show()
  end
end

function show()
  optionsWindow:show()
  optionsWindow:raise()
  optionsBackground:focus()
  optionsBackground:show()
end

function hide()
  optionsWindow:hide()
  optionsBackground:hide()
end

function toggleDisplays()
  if options['displayNames'] and options['displayHealth'] and options['displayMana'] then
    setOption('displayNames', false)
  elseif options['displayHealth'] then
    setOption('displayHealth', false)
	setOption('displayMana', false)
  else
    if not options['displayNames'] and not options['displayHealth'] then
      setOption('displayNames', true)
    else
      setOption('displayHealth', true)
	  setOption('displayMana', true)
    end
  end
end

function toggleOption(key)
  setOption(key, not getOption(key))
end

function setOption(key, value, force)
  if not force and options[key] == value then return end
  local gameMapPanel = modules.game_interface.getMapPanel()

  if key == 'vsync' then
    g_window.setVerticalSync(value)
  elseif key == 'fullscreen' then
    g_window.setFullscreen(value)
  elseif key == 'enableAudio' then
    g_sounds.setAudioEnabled(value)
  elseif key == 'enableMusicSound' then
    g_sounds.getChannel(SoundChannels.Music):setEnabled(value)
  elseif key == 'musicSoundVolume' then
    g_sounds.getChannel(SoundChannels.Music):setGain(value/100)
    audioPanel:getChildById('musicSoundVolumeLabel'):setText(tr('Music volume: %d', value))
  elseif key == 'backgroundFrameRate' then
    local text, v = value, value
    if value <= 0 or value >= 201 then text = 'max' v = 0 end
    graphicsPanel:getChildById('backgroundFrameRateLabel'):setText(tr('Game framerate limit: %s', text))
    g_app.setBackgroundPaneMaxFps(v)
  elseif key == 'consoleSize' then
    local text, v = value .. '%', value
    local bottomPanel = modules.game_interface.getBottomPanel()
    local moveBottomPanel = modules.game_interface.getMoveBottomPanel()
    if value < 100 or value >= 300 then text = 'max' v = 0 end
    consolePanel:getChildById('consoleSizeLabel'):setText(tr('Console size: %s', text))
    bottomPanel:setHeight(100*(value/100))
    moveBottomPanel:setWidth(650*(value/100))
  elseif key == 'minimapSize' then
    if g_modules.getModule('game_minimap'):isLoaded() then
      local text, v = value .. '%', value
      local minimapWindow = modules.game_minimap.getMinimapWindow()
      if value < 100 or value >= 300 then text = 'max' v = 0 end
      generalPanel:getChildById('minimapSizeLabel'):setText(tr('Minimap size: %s', text))
      if generalPanel:getChildById('displayMinimap'):isChecked() then
        modules.game_interface.getRightPanel():setMarginBottom(125*(value/100)+20)
      else
        modules.game_interface.getRightPanel():setMarginBottom(10)
      end
      minimapWindow:setHeight(150*(value/100))
      minimapWindow:setWidth(250*(value/100))
      if modules.game_interface.getRightPanel():isVisible() then
        local children = modules.game_interface.getRightPanel():getChildren()
        if #children > 0 then
          for i=1,#children do
            children[i]:setParent(modules.game_interface.getRightPanel())
          end
        end
      end
    end
  elseif key == 'foregroundFrameRate' then
    local text, v = value, value
    if value <= 0 or value >= 61 then  text = 'max' v = 0 end
    graphicsPanel:getChildById('foregroundFrameRateLabel'):setText(tr('Interface framerate limit: %s', text))
    g_app.setForegroundPaneMaxFps(v)
  elseif key == 'enableLights' then
    gameMapPanel:setDrawLights(value and options['ambientLight'] < 100)
    graphicsPanel:getChildById('ambientLight'):setEnabled(value)
    graphicsPanel:getChildById('ambientLightLabel'):setEnabled(value)
  elseif key == 'ambientLight' then
    graphicsPanel:getChildById('ambientLightLabel'):setText(tr('Ambient light: %s%%', value))
    gameMapPanel:setMinimumAmbientLight(value/100)
    gameMapPanel:setDrawLights(options['enableLights'] and value < 100)
  elseif key == 'painterEngine' then
    g_graphics.selectPainterEngine(value)
  elseif key == 'displayNames' then
    gameMapPanel:setDrawNames(value)
  elseif key == 'displayHealth' then
    gameMapPanel:setDrawHealthBars(value)
  elseif key == 'displayMana' then
    gameMapPanel:setDrawManaBar(value)
  elseif key == 'displayText' then
    gameMapPanel:setDrawTexts(value)
  elseif key == 'displayMinimap' then
    if g_modules.getModule('game_minimap'):isLoaded() then
      modules.game_minimap.toggle(value)
    end
  end

  -- change value for keybind updates
  for _,panel in pairs(optionsTabBar:getTabsPanel()) do
    local widget = panel:recursiveGetChildById(key)
    if widget then
      if widget:getStyle().__class == 'UICheckBox' then
        widget:setChecked(value)
      elseif widget:getStyle().__class == 'UIScrollBar' then
        widget:setValue(value)
      end
      break
    end
  end

  g_settings.set(key, value)
  options[key] = value
end

function getOption(key)
  return options[key]
end

function addButton(name, func, icon)
  optionsTabBar:addButton(name, func, icon)
end
