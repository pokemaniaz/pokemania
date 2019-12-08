function init()
  connect(g_game, { onGameStart = show,
                    onGameEnd = hide })

  topButtonMenu = g_ui.loadUI('topbuttonmenu', modules.game_interface.getMapPanel())
  topWindowMenu = g_ui.displayUI('topwindowmenu', modules.game_interface.getMapPanel())
  show()
end

function terminate()
  disconnect(g_game, { onGameStart = show,
                       onGameEnd = hide })

  hide()
end

function show()
  if g_game.isOnline() then
    topButtonMenu:show()
    topWindowMenu:hide()
  else
    hide()
  end
end

function hide()
  topButtonMenu:hide()
  topWindowMenu:hide()
end

function showMenuWindow()
  topWindowMenu:show()
  topWindowMenu:focus()
  topWindowMenu:upper()
end
