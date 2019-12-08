HOTKEY_MANAGER_USE = nil
HOTKEY_MANAGER_USEONSELF = 1
HOTKEY_MANAGER_USEINMYPOKEMON = 2
HOTKEY_MANAGER_USEWITH = 3

HotkeyColors = {
  text = '#888888',
  textAutoSend = '#FFFFFF',
  itemUse = '#8888FF',
  itemUseSelf = '#00FF00',
  itemUsePokemon = '#00CCFF',
  itemUseWith = '#F5B325',
}

defaultComboKeysTable = {
  [1] = {key = 'F1', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m1'},
  [2] = {key = 'F2', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m2'},
  [3] = {key = 'F3', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m3'},
  [4] = {key = 'F4', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m4'},
  [5] = {key = 'F5', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m5'},
  [6] = {key = 'F6', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m6'},
  [7] = {key = 'F7', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m7'},
  [8] = {key = 'F8', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m8'},
  [9] = {key = 'F9', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m9'},
  [10] = {key = 'F10', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m10'},
  [11] = {key = 'F11', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m11'},
  [12] = {key = 'F12', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s m12'},
  [13] = {key = 'Shift+W', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t1'},
  [14] = {key = 'Shift+D', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t2'},
  [15] = {key = 'Shift+S', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t3'},
  [16] = {key = 'Shift+A', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t4'},
  [17] = {key = 'Ctrl+Up', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t1'},
  [18] = {key = 'Ctrl+Right', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t2'},
  [19] = {key = 'Ctrl+Down', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t3'},
  [20] = {key = 'Ctrl+Left', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t4'},
  [21] = {key = 'Ctrl+Numpad8', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t1'},
  [22] = {key = 'Ctrl+Numpad6', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t2'},
  [23] = {key = 'Ctrl+Numpad2', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t3'},
  [24] = {key = 'Ctrl+Numpad4', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s t4'},
  [25] = {key = 'PageUp', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s h1'},
  [26] = {key = 'PageDown', autoSend = true, itemId = nil, subType = nil, useType = nil, value = '#s h2'},
  [27] = {key = 'MouseMiddle', autoSend = false, itemId = 2550, subType = nil, useType = 3, value = nil},
}

local keysLocked = {'1', '2', '3', '4', 'Shift+1', 'Shift+2', 'Shift+3', 'Shift+4', 'Shift+5', 'Shift+6'}

hotkeysManagerLoaded = false
hotkeysWindow = nil
currentHotkeyLabel = nil
currentItemPreview = nil
itemWidget = nil
addHotkeyButton = nil
removeHotkeyButton = nil
hotkeyText = nil
hotKeyTextLabel = nil
sendAutomatically = nil
selectObjectButton = nil
clearObjectButton = nil
useOnSelf = nil
useInMyPokemon = nil
useWith = nil
defaultComboKeys = nil
perServer = true
perCharacter = true
mouseGrabberWidget = nil
useRadioGroup = nil
currentHotkeys = nil
boundCombosCallback = {}
hotkeysList = {}

-- public functions
function init()
  g_keyboard.bindKeyDown('Ctrl+K', toggle)
  hotkeysWindow = g_ui.displayUI('hotkeys_manager')
  hotkeysWindow:setVisible(false)

  currentHotkeys = hotkeysWindow:getChildById('currentHotkeys')
  currentItemPreview = hotkeysWindow:getChildById('itemPreview')
  addHotkeyButton = hotkeysWindow:getChildById('addHotkeyButton')
  removeHotkeyButton = hotkeysWindow:getChildById('removeHotkeyButton')
  hotkeyText = hotkeysWindow:getChildById('hotkeyText')
  hotKeyTextLabel = hotkeysWindow:getChildById('hotKeyTextLabel')
  sendAutomatically = hotkeysWindow:getChildById('sendAutomatically')
  selectObjectButton = hotkeysWindow:getChildById('selectObjectButton')
  clearObjectButton = hotkeysWindow:getChildById('clearObjectButton')
  useOnSelf = hotkeysWindow:getChildById('useOnSelf')
  useInMyPokemon = hotkeysWindow:getChildById('useInMyPokemon')
  useWith = hotkeysWindow:getChildById('useWith')

  useRadioGroup = UIRadioGroup.create()
  useRadioGroup:addWidget(useOnSelf)
  useRadioGroup:addWidget(useInMyPokemon)
  useRadioGroup:addWidget(useWith)
  useRadioGroup.onSelectionChange = function(self, selected) onChangeUseType(selected) end

  mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)
  mouseGrabberWidget.onMouseRelease = onChooseItemMouseRelease

  currentHotkeys.onChildFocusChange = function(self, hotkeyLabel) onSelectHotkeyLabel(hotkeyLabel) end
  g_keyboard.bindKeyPress('Down', function() currentHotkeys:focusNextChild(KeyboardFocusReason) end, hotkeysWindow)
  g_keyboard.bindKeyPress('Up', function() currentHotkeys:focusPreviousChild(KeyboardFocusReason) end, hotkeysWindow)

  connect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })

  load()
end

function terminate()
  disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline
  })

  g_keyboard.unbindKeyDown('Ctrl+K')

  unload()

  hotkeysWindow:destroy()
  mouseGrabberWidget:destroy()
end

function configure(savePerServer, savePerCharacter)
  perServer = savePerServer
  perCharacter = savePerCharacter
  reload()
end

function online()
  reload()
  hide()
end

function offline()
  unload()
  hide()
end

function show()
  if not g_game.isOnline() then
    return
  end
  hotkeysWindow:show()
  hotkeysWindow:raise()
  hotkeysWindow:focus()
end

function hide()
  hotkeysWindow:hide()
end

function toggle()
  if not hotkeysWindow:isVisible() then
    show()
  else
    hide()
  end
end

function ok()
  save()
  hide()
end

function cancel()
  reload()
  hide()
end

function load(forceDefaults)
  hotkeysManagerLoaded = false

  local hotkeySettings = g_settings.getNode('game_hotkeys')
  local hotkeys = {}

  if not table.empty(hotkeySettings) then hotkeys = hotkeySettings end
  if perServer and not table.empty(hotkeys) then hotkeys = hotkeys[G.host] end
  if perCharacter and not table.empty(hotkeys) then hotkeys = hotkeys[g_game.getCharacterName()] end

  hotkeyList = {}
  if not forceDefaults then
    if not table.empty(hotkeys) then
      for keyCombo, setting in pairs(hotkeys) do
        keyCombo = tostring(keyCombo)
        addKeyCombo(keyCombo, setting)
        hotkeyList[keyCombo] = setting
      end
    end
  end

  if currentHotkeys:getChildCount() == 0 then
    loadDefautComboKeys()
  end

  hotkeysManagerLoaded = true
end

function unload()
  for keyCombo,callback in pairs(boundCombosCallback) do
    if keyCombo ~= 'MouseMiddle' then
      g_keyboard.unbindKeyPress(keyCombo, callback)
    end
  end
  boundCombosCallback = {}
  currentHotkeys:destroyChildren()
  currentHotkeyLabel = nil
  updateHotkeyForm(true)
  hotkeyList = {}
end

function reset()
  unload()
  load(true)
end

function reload()
  unload()
  load()
end

function save()
  local hotkeySettings = g_settings.getNode('game_hotkeys') or {}
  local hotkeys = hotkeySettings

  if perServer then
    if not hotkeys[G.host] then
      hotkeys[G.host] = {}
    end
    hotkeys = hotkeys[G.host]
  end

  if perCharacter then
    local char = g_game.getCharacterName()
    if not hotkeys[char] then
      hotkeys[char] = {}
    end
    hotkeys = hotkeys[char]
  end

  table.clear(hotkeys)

  for _,child in pairs(currentHotkeys:getChildren()) do
    hotkeys[child.keyCombo] = {
      autoSend = child.autoSend,
      itemId = child.itemId,
      subType = child.subType,
      useType = child.useType,
      value = child.value
    }
  end

  hotkeyList = hotkeys
  g_settings.setNode('game_hotkeys', hotkeySettings)
  g_settings.save()
end

function loadDefautComboKeys()
  if not defaultComboKeys then
    local keySettings = {}
    local hotkeySettings = g_settings.getNode('game_hotkeys') or {}
    local hotkeys = hotkeySettings
    for i = 1, #defaultComboKeysTable do
      keySettings.autoSend = defaultComboKeysTable[i].autoSend
      keySettings.itemId = defaultComboKeysTable[i].itemId
      keySettings.subType = defaultComboKeysTable[i].subType
      keySettings.useType = defaultComboKeysTable[i].useType
      keySettings.value = defaultComboKeysTable[i].value
      addKeyCombo(defaultComboKeysTable[i].key, keySettings)
      hotkeys[defaultComboKeysTable[i].key] = {
        autoSend = keySettings.autoSend,
        itemId = keySettings.itemId,
        subType = keySettings.subType,
        useType = keySettings.useType,
        value = keySettings.value
      }
      hotkeyList = hotkeys
    end
  else
    for keyCombo, keySettings in pairs(defaultComboKeys) do
      addKeyCombo(keyCombo, keySettings)
      modules.game_textmessage.displayBroadcastMessage(tostring(defaultComboKeys))
    end
  end
end

function setDefaultComboKeys(combo)
  defaultComboKeys = combo
end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIGameMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
          local thing = tile:getTopMoveThing()
          if thing and thing:isItem() then
            item = thing
          end
        end
      elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      elseif clickedWidget:getClassName() == 'UIWidget' and clickedWidget:getId() == 'order' then
        currentHotkeyLabel.itemId = 2550
        currentHotkeyLabel.useType = HOTKEY_MANAGER_USEWITH
        currentHotkeyLabel.value = nil
        currentHotkeyLabel.autoSend = false
        updateHotkeyLabel(currentHotkeyLabel)
        updateHotkeyForm(true)
      end
    end
  end

  if item and currentHotkeyLabel then
    currentHotkeyLabel.itemId = item:getId()
    if item:isFluidContainer() then
      currentHotkeyLabel.subType = item:getSubType()
    end
    if item:isMultiUse() then
      currentHotkeyLabel.useType = HOTKEY_MANAGER_USEWITH
    else
      currentHotkeyLabel.useType = HOTKEY_MANAGER_USE
    end
    currentHotkeyLabel.value = nil
    currentHotkeyLabel.autoSend = false
    updateHotkeyLabel(currentHotkeyLabel)
    updateHotkeyForm(true)
  end

  show()

  g_mouse.popCursor('target')
  self:ungrabMouse()
  return true
end

function startChooseItem()
  if g_ui.isMouseGrabbed() then return end
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
  hide()
end

function clearObject()
  currentHotkeyLabel.itemId = nil
  currentHotkeyLabel.subType = nil
  currentHotkeyLabel.useType = nil
  currentHotkeyLabel.autoSend = nil
  currentHotkeyLabel.value = nil
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm(true)
end

function addHotkey()
  local assignWindow = g_ui.createWidget('HotkeyAssignWindow', rootWidget)
  assignWindow:grabKeyboard()

  local comboLabel = assignWindow:getChildById('comboPreview')
  comboLabel.keyCombo = ''
  assignWindow.onKeyDown = hotkeyCaptureKey
  assignWindow.onMousePress = hotkeyCaptureMouse
end

function addKeyCombo(keyCombo, keySettings, focus)
  if keyCombo == nil or #keyCombo == 0 then return end
  if not keyCombo then return end
  local hotkeyLabel = currentHotkeys:getChildById(keyCombo)
  if not hotkeyLabel then
    hotkeyLabel = g_ui.createWidget('HotkeyListLabel')
    hotkeyLabel:setId(keyCombo)

    local children = currentHotkeys:getChildren()
    children[#children+1] = hotkeyLabel
    table.sort(children, function(a,b)
      if a:getId():len() < b:getId():len() then
        return true
      elseif a:getId():len() == b:getId():len() then
        return a:getId() < b:getId()
      else
        return false
      end
    end)
    for i=1,#children do
      if children[i] == hotkeyLabel then
        currentHotkeys:insertChild(i, hotkeyLabel)
        break
      end
    end

    if keySettings then
      currentHotkeyLabel = hotkeyLabel
      hotkeyLabel.keyCombo = keyCombo
      hotkeyLabel.autoSend = toboolean(keySettings.autoSend)
      hotkeyLabel.itemId = tonumber(keySettings.itemId)
      hotkeyLabel.subType = tonumber(keySettings.subType)
      hotkeyLabel.useType = tonumber(keySettings.useType)
      if keySettings.value then hotkeyLabel.value = tostring(keySettings.value) end
    else
      hotkeyLabel.keyCombo = keyCombo
      hotkeyLabel.autoSend = false
      hotkeyLabel.itemId = nil
      hotkeyLabel.subType = nil
      hotkeyLabel.useType = nil
      hotkeyLabel.value = ''
    end

    updateHotkeyLabel(hotkeyLabel)

    boundCombosCallback[keyCombo] = function() doKeyCombo(keyCombo) end
    if hotkeyLabel.keyCombo == 'MouseMiddle' then
      g_mouse.bindPress(rootWidget, boundCombosCallback[keyCombo], MouseMidButton)
    else
      g_keyboard.bindKeyPress(keyCombo, boundCombosCallback[keyCombo])
    end
  end

  if focus then
    currentHotkeys:focusChild(hotkeyLabel)
    currentHotkeys:ensureChildVisible(hotkeyLabel)
    updateHotkeyForm(true)
  end
end

function doKeyCombo(keyCombo)
  if not g_game.isOnline() then return end
  local hotKey = hotkeyList[keyCombo]
  if not hotKey then return end
  if hotKey.itemId == nil then
    if not hotKey.value or #hotKey.value == 0 then return end
    if hotKey.autoSend then
      modules.game_console.sendMessage(hotKey.value)
    else
      modules.game_console.setTextEditText(hotKey.value)
    end
  elseif hotKey.useType == HOTKEY_MANAGER_USE then
    if g_game.getClientVersion() < 780 or hotKey.subType then
      local item = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if item then
        g_game.use(item)
      end
    else
      g_game.useInventoryItem(hotKey.itemId)
    end
  elseif hotKey.useType == HOTKEY_MANAGER_USEONSELF then
    if g_game.getClientVersion() < 780 or hotKey.subType then
      local item = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if item then
        g_game.useWith(item, g_game.getLocalPlayer())
      end
    else
      g_game.useInventoryItemWith(hotKey.itemId, g_game.getLocalPlayer())
    end
  elseif hotKey.useType == HOTKEY_MANAGER_USEINMYPOKEMON then
    local myPokemon = modules.game_battle.getMyPokemon()
    if not myPokemon then
      local item = Item.create(hotKey.itemId)
      if g_game.getClientVersion() < 780 or hotKey.subType then
        local tmpItem = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
        if not tmpItem then return end
        item = tmpItem
      end

      modules.game_interface.startUseWith(item)
      return
    end

    if not myPokemon:getTile() then return end
    if g_game.getClientVersion() < 780 or hotKey.subType then
      local item = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if item then
        g_game.useWith(item, myPokemon)
      end
    else
      g_game.useInventoryItemWith(hotKey.itemId, myPokemon)
    end
  elseif hotKey.useType == HOTKEY_MANAGER_USEWITH then
    local item = Item.create(hotKey.itemId)
    if g_game.getClientVersion() < 780 or hotKey.subType then
      local tmpItem = g_game.findPlayerItem(hotKey.itemId, hotKey.subType or -1)
      if not tmpItem then return true end
      item = tmpItem
    end
    if hotKey.itemId == 2550 then
	  local player = g_game.getLocalPlayer()
      safeUseInventoryItemWith(player:getInventoryItem(4):getId())
    else
      modules.game_interface.startUseWith(item)
    end
  end
end

function useOrder()
	local player = g_game.getLocalPlayer()
	safeUseInventoryItemWith(player:getInventoryItem(4):getId())
end

function safeUseInventoryItemWith(itemId)
    local player = g_game.getLocalPlayer()
	local item = Item.create(itemId)
    modules.game_interface.startUseWith(item)
  return true
end

function updateHotkeyLabel(hotkeyLabel)
  if not hotkeyLabel then return end
  if hotkeyLabel.useType == HOTKEY_MANAGER_USEONSELF then
    hotkeyLabel:setText(tr('%s: (use object on yourself)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUseSelf)
  elseif hotkeyLabel.useType == HOTKEY_MANAGER_USEINMYPOKEMON then
    hotkeyLabel:setText(tr('%s: (use object in my pokemon)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUsePokemon)
  elseif hotkeyLabel.useType == HOTKEY_MANAGER_USEWITH then
    hotkeyLabel:setText(tr('%s: (use object with crosshair)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUseWith)
  elseif hotkeyLabel.itemId ~= nil then
    hotkeyLabel:setText(tr('%s: (use object)', hotkeyLabel.keyCombo))
    hotkeyLabel:setColor(HotkeyColors.itemUse)
  else
    local text = hotkeyLabel.keyCombo .. ': '
    if hotkeyLabel.value then
      text = text .. hotkeyLabel.value
    end
    hotkeyLabel:setText(text)
    if hotkeyLabel.autoSend then
      hotkeyLabel:setColor(HotkeyColors.autoSend)
    else
      hotkeyLabel:setColor(HotkeyColors.text)
    end
  end
end

function updateHotkeyForm(reset)
  if currentHotkeyLabel then
    removeHotkeyButton:enable()
    if currentHotkeyLabel.itemId ~= nil then
      hotkeyText:clearText()
      hotkeyText:disable()
      hotKeyTextLabel:disable()
      sendAutomatically:setChecked(false)
      sendAutomatically:disable()
      selectObjectButton:disable()
      clearObjectButton:enable()
      currentItemPreview:setItemId(currentHotkeyLabel.itemId)
      if currentHotkeyLabel.subType then
        currentItemPreview:setItemSubType(currentHotkeyLabel.subType)
      end
      if currentItemPreview:getItem():isMultiUse() then
        if currentHotkeyLabel.itemId == 2550 then
          useOnSelf:disable()
          useInMyPokemon:disable()
          useWith:enable()
        else
          useOnSelf:enable()
          useInMyPokemon:enable()
          useWith:enable()
        end
        if currentHotkeyLabel.useType == HOTKEY_MANAGER_USEONSELF then
          useRadioGroup:selectWidget(useOnSelf)
        elseif currentHotkeyLabel.useType == HOTKEY_MANAGER_USEINMYPOKEMON then
          useRadioGroup:selectWidget(useInMyPokemon)
        elseif currentHotkeyLabel.useType == HOTKEY_MANAGER_USEWITH then
          useRadioGroup:selectWidget(useWith)
        end
      else
        useOnSelf:disable()
        useInMyPokemon:disable()
        useWith:disable()
        useRadioGroup:clearSelected()
      end
    else
      useOnSelf:disable()
      useInMyPokemon:disable()
      useWith:disable()
      useRadioGroup:clearSelected()
      hotkeyText:enable()
      hotkeyText:focus()
      hotKeyTextLabel:enable()
      if reset then
        hotkeyText:setCursorPos(-1)
      end
      hotkeyText:setText(currentHotkeyLabel.value)
      sendAutomatically:setChecked(currentHotkeyLabel.autoSend)
      sendAutomatically:setEnabled(currentHotkeyLabel.value and #currentHotkeyLabel.value > 0)
      selectObjectButton:enable()
      clearObjectButton:disable()
      currentItemPreview:clearItem()
    end
  else
    removeHotkeyButton:disable()
    hotkeyText:disable()
    sendAutomatically:disable()
    selectObjectButton:disable()
    clearObjectButton:disable()
    useOnSelf:disable()
    useInMyPokemon:disable()
    useWith:disable()
    hotkeyText:clearText()
    useRadioGroup:clearSelected()
    sendAutomatically:setChecked(false)
    currentItemPreview:clearItem()
  end
end

function removeHotkey()
  if currentHotkeyLabel == nil then return end
  if currentHotkeyLabel.keyCombo ~= 'MouseMiddle' then
    g_keyboard.unbindKeyPress(currentHotkeyLabel.keyCombo, boundCombosCallback[currentHotkeyLabel.keyCombo])
  end
  boundCombosCallback[currentHotkeyLabel.keyCombo] = nil
  currentHotkeyLabel:destroy()
  currentHotkeyLabel = nil
end

function onHotkeyTextChange(value)
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  currentHotkeyLabel.value = value
  if value == '' then
    currentHotkeyLabel.autoSend = false
  end
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onSendAutomaticallyChange(autoSend)
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  if not currentHotkeyLabel.value or #currentHotkeyLabel.value == 0 then return end
  currentHotkeyLabel.autoSend = autoSend
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onChangeUseType(useTypeWidget)
  if not hotkeysManagerLoaded then return end
  if currentHotkeyLabel == nil then return end
  if useTypeWidget == useOnSelf then
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USEONSELF
  elseif useTypeWidget == useInMyPokemon then
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USEINMYPOKEMON
  elseif useTypeWidget == useWith then
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USEWITH
  else
    currentHotkeyLabel.useType = HOTKEY_MANAGER_USE
  end
  updateHotkeyLabel(currentHotkeyLabel)
  updateHotkeyForm()
end

function onSelectHotkeyLabel(hotkeyLabel)
  currentHotkeyLabel = hotkeyLabel
  updateHotkeyForm(true)
end

function hotkeyCaptureKey(assignWindow, keyCode, keyboardModifiers)
  local keyCombo = determineKeyComboDesc(keyCode, keyboardModifiers)
  local comboPreview = assignWindow:getChildById('comboPreview')
  for i = 1, #keysLocked do
    if keysLocked[i] == keyCombo then return end
  end
  comboPreview:setText(tr('Current hotkey to add: %s', keyCombo))
  comboPreview.keyCombo = keyCombo
  comboPreview:resizeToText()
  assignWindow:getChildById('addButton'):enable()
  return true
end

function hotkeyCaptureMouse(assignWindow, mousePosition, mouseButton)
  if mouseButton == MouseMidButton then
    local comboPreview = assignWindow:getChildById('comboPreview')
    comboPreview:setText(tr('Current hotkey to add: %s', 'MouseMiddle'))
    comboPreview.keyCombo = 'MouseMiddle'
    comboPreview:resizeToText()
    assignWindow:getChildById('addButton'):enable()
  end
  return true
end

function hotkeyCaptureOk(assignWindow, keyCombo)
  addKeyCombo(keyCombo, nil, true)
  assignWindow:destroy()
end
