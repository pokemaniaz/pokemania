local pbid = 3282
local gbid = 3279
local subid = 3281
local ubid = 3280
local sabid = 11929
local zbid = 14559
local balls = {}
local abriu = 0

function init()
  connect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.registerExtendedOpcode(105, function(protocol, opcode, buffer)
  local strings = string.explode(buffer, '-')  

  show(strings[1], strings[2], strings[3], strings[4], strings[5], strings[6], strings[7], strings[8], strings[9], strings[10], strings[11])--, strings[10], strings[11], strings[12], strings[13], strings[14], strings[15], strings[16], strings[17], strings[18], strings[19]) 
  end)

  catchWindow = g_ui.displayUI('catch')
  catchWindow:hide()
end

function terminate()
  disconnect(g_game, { onGameEnd = onGameEnd })
  ProtocolGame.unregisterExtendedOpcode(105)

  catchWindow:destroy()
end

function onGameEnd()
  if catchWindow:isVisible() then
    catchWindow:hide()
  end
end

function toyById(id)
if id >= 11061 and id <= 11211 then return (id + 2389 - ((id-11061) * 2))
elseif id >= 10377 and id <= 10425 then return (id + 3172 - ((id-10377) * 2))
elseif id >= 10427 and id <= 10476 then return (id + 3073 - ((id-10427) * 2))
elseif id == 10228 then return 15105
elseif id == 10231 then return 15102
elseif id == 10234 then return 15140
elseif id == 10237 then return 15139
elseif id == 10240 then return 15141
elseif id == 10243 then return 15133
elseif id >= 10244 and id <= 10245 then return id+4870
elseif id == 10247 then return 15135
elseif id == 10251 then return 15116
elseif id == 10259 then return 15118
elseif id == 10266 then return 15101
elseif id == 10267 then return 15132
elseif id == 10268 then return 15117
elseif id == 10270 then return 15104
elseif id == 10271 then return 15160
elseif id == 10272 then return 15159
elseif id >= 10273 and id <= 10274 then return id+4833
elseif id == 10283 then return 15129
elseif id == 10284 then return 15142
elseif id == 10288 then return toyById(id+835)
elseif id == 10290 then return 15143
elseif id == 10293 then return 15123
elseif id == 10297 then return 15109
elseif id == 10298 then return 15138
elseif id == 10301 then return 15131
elseif id == 10308 then return 15100
elseif id == 10313 then return 15130
elseif id == 10314 then return 15119
elseif id == 10319 then return 15134
elseif id == 10322 then return 15127
elseif id >= 10323 and id <= 10324 then return id+4801
elseif id == 10325 then return 15103
elseif id == 10326 then return 15108
elseif id == 10329 then return 15137
elseif id == 10330 then return 15121
elseif id >= 10331 and id <= 10332 then return id+4813
elseif id == 10339 then return 15110
elseif id == 10341 then return 15128
elseif id == 10342 then return 15111
elseif id == 10348 then return 15112
elseif id == 10349 then return 15126
elseif id == 10350 then return 15136
elseif id == 10351 then return 15157
elseif id == 10352 then return 15156
elseif id == 10353 then return 15155
elseif id == 10354 then return 15154
elseif id == 10355 then return 15153
elseif id == 10357 then return 15152
elseif id == 10359 then return 15151
elseif id == 10360 then return 15150
elseif id == 10361 then return 15149
elseif id == 10368 then return toyById(id+835)
elseif id == 10372 then return 15148
elseif id == 10373 then return 15147
elseif id == 10374 then return toyById(id+835)
elseif id == 11427 then return 15146 --c.o
elseif id == 11428 then return 15166 --hitmontop
elseif id == 11429 then return 15169 --stantler
elseif id == 11430 then return 15171 --umbreon
elseif id == 11431 then return 15163 --espeon
elseif id == 11432 then return 15172 --politoed
elseif id == 11433 then return 15177 --ariados
elseif id == 11434 then return 15113 --rhydon
elseif id == 11435 then return 15158 --dodrio
elseif id == 11436 then return 15122 --magneton
elseif id == 11437 then return 15161 --ninetales
elseif id == 11438 then return 15120 --mime
elseif id == 15427 then return 15176
elseif id == 15428 then return 15179
elseif id == 15429 then return 15162
elseif id == 15430 then return 15178
elseif id == 15431 then return 15174
elseif id == 15432 then return 15173
elseif id == 15433 then return 15165
elseif id == 15434 then return 15164
elseif id == 15435 then return 15175
elseif id == 15436 then return 15170
elseif id >= 14601 and id <= 14602 then return toyById(id-3540)
elseif id >= 14603 and id <= 14604 then return toyById(id-3539)
elseif id >= 14605 and id <= 14606 then return toyById(id-3538)
elseif id >= 14607 and id <= 14608 then return toyById(id-3537)
elseif id >= 14609 and id <= 14610 then return toyById(id-3536)
elseif id == 14613 then return toyById(id-3528)
elseif id >= 14614 and id <= 14615 then return toyById(id-3488)
elseif id == 14616 then return toyById(id-3446)
end
end

function show(itemID, exp, pokemon, n, g, s, u, s2, z, first, tobag)
  if not catchWindow:isVisible() then
    addEvent(function() g_effects.fadeIn(catchWindow, 250) end)
  end
  balls = {}
  catchWindow:show()
  catchWindow:raise()
  catchWindow:focus()
  catchWindow:setImageSource('/images/catch/background1.png')
  --modules.game_interface.getRootPanel()
  catchWindow:setParent(modules.game_interface.getRootPanel())
  --catchWindow:addAnchor(AnchorRight, 'gameRightPanel', AnchorLeft)
  if abriu == 0 then
  catchWindow:addAnchor(AnchorBottom, 'gameMapPanel', AnchorBottom)
  abriu = 1
  end
  catchWindow:getChildById('portrait'):setItemId(tonumber(itemID))
  catchWindow:getChildById('toy'):setItemId(toyById(tonumber(itemID)))
  if tonumber(exp) > 0 and tonumber(first) == 1 then
  catchWindow:getChildById('firsticon'):setVisible(true)
  catchWindow:getChildById('firsticon'):setImageSource('/images/catch/first.png')
  catchWindow:getChildById('firsticon'):setTooltip("First Caught Achievement")
  catchWindow:getChildById('firstxp'):setText("+"..tonumber(exp).." EXP")
  catchWindow:getChildById('firstxp'):addAnchor(AnchorRight, 'parent', AnchorRight)
  else
  catchWindow:getChildById('firsticon'):setVisible(false)
  catchWindow:getChildById('firstxp'):setText("")
  end
  if tonumber(tobag) == 1 then
  catchWindow:getChildById('destino'):setImageSource('/images/catch/pokebag.png')
  else
  catchWindow:getChildById('destino'):setImageSource('/images/catch/depot.png')
  end
  if string.find(tostring(doCorrectString(pokemon)), "Shiny") then
      local newName = tostring(doCorrectString(pokemon)):match("Shiny (.*)")   
catchWindow:getChildById('textWindow'):getChildById('text'):setText(tr('Você capturou um Pokemon! (%s)', newName))	  
  elseif string.find(tostring(doCorrectString(pokemon)), "Crystal") then
      local newName = tostring(doCorrectString(pokemon)):match("Crystal (.*)")  
catchWindow:getChildById('textWindow'):getChildById('text'):setText(tr('Você capturou um Pokemon! (%s)', newName))
  else
  catchWindow:getChildById('textWindow'):getChildById('text'):setText(tr('Você capturou um Pokemon! (%s)', doCorrectString(pokemon)))
  end  
 
  n = tonumber(n)
  g = tonumber(g)
  s = tonumber(s)
  u = tonumber(u)
  s2 = tonumber(s2)
  z = tonumber(z)
  local t = {n,g,s,u,s2,z}
  local t2 = {pbid,gbid,subid,ubid,sabid,zbid}
  for x = 1, #t do
  if t[x] > 0 then
		table.insert(balls, t2[x]..",")
  end
  end
  
  local ball = string.explode(table.concat(balls), ',')  
   
  function countById(id)
  if id == pbid then return n
  elseif id == gbid then return g
  elseif id == subid then return s
  elseif id == ubid then return u
  elseif id == sabid then return s2
  elseif id == zbid then return z
  else return 0
  end
  end
  catchWindow:getChildById('ball1'):setItemId(ball[1])
  catchWindow:getChildById('ball1Label'):setText(countById(tonumber(ball[1])))
  if #ball > 2 then
  catchWindow:getChildById('ball2'):setItemId(ball[2])
  catchWindow:getChildById('ball2Label'):setText(countById(tonumber(ball[2])))
  if #ball > 3 then
  catchWindow:getChildById('ball3'):setItemId(ball[3])
  catchWindow:getChildById('ball3Label'):setText(countById(tonumber(ball[3])))
  if #ball > 4 then
  catchWindow:getChildById('ball4'):setItemId(ball[4])
  catchWindow:getChildById('ball4Label'):setText(countById(tonumber(ball[4])))
  else
  catchWindow:getChildById('ball4'):setItemId(0)
  catchWindow:getChildById('ball4Label'):setText("")
  end
  else
  catchWindow:getChildById('ball3'):setItemId(0)
  catchWindow:getChildById('ball4'):setItemId(0)
  catchWindow:getChildById('ball3Label'):setText("")
  catchWindow:getChildById('ball4Label'):setText("")
  end
  else
  catchWindow:getChildById('ball2'):setItemId(0)
  catchWindow:getChildById('ball3'):setItemId(0)
  catchWindow:getChildById('ball4'):setItemId(0)
  catchWindow:getChildById('ball2Label'):setText("")
  catchWindow:getChildById('ball3Label'):setText("")
  catchWindow:getChildById('ball4Label'):setText("")
  end
  
  catchWindow:getChildById('textSeta'):setImageSource('/images/catch/setas/seta.png')
 return true
end

function hide()
  addEvent(function() g_effects.fadeOut(catchWindow, 250) end)
  scheduleEvent(function() catchWindow:hide() end, 250)
end
