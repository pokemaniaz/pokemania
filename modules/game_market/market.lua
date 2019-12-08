Market = {}
local protocol = runinsandbox('marketprotocol')

marketWindow = nil
mainTabBar = nil
displaysTabBar = nil
offersTabBar = nil
selectionTabBar = nil
msgWindow = nil
marketOffersPanel = nil
browsePanel = nil
offerButton = nil
overviewPanel = nil
itemOffersPanel = nil
itemDetailsPanel = nil
itemStatsPanel = nil
myOffersPanel = nil
currentOffersPanel = nil
offerHistoryPanel = nil
itemsPanel = nil
selectedOffer = {}
selectedMyOffer = {}
LOADED = false

itemDescTable = nil
MyOfferTable = nil

nameLabel = nil
feeLabel = nil
balanceLabel = nil
totalPriceEdit = nil
piecePriceEdit = nil
amountEdit = nil
searchEdit = nil
categorySelect = nil
radioItemSet = nil
selectedItem = nil
selectedItemOffer = nil
offerTypeList = nil
categoryList = nil
subCategoryList = nil
slotFilterList = nil
createOfferButton = nil
buyButton = nil
sellButton = nil
anonymous = nil
filterButtons = {}

buyOfferTable = nil
sellOfferTable = nil
histTable = nil
detailsTable = nil
itemdetailsTable = nil
buyStatsTable = nil
sellStatsTable = nil

buyCancelButton = nil
sellCancelButton = nil
buyMyOfferTable = nil
sellMyOfferTable = nil

offerExhaust = {}
marketOffers = {}
marketItems = {}
information = {}
currentItems = {}
lastCreatedOffer = 0
fee = 0
averagePrice = 0

loaded = false

local function clearItems()
  currentItems = {}
  Market.refreshItemsWidget()
end

local function clearOffers()
  marketOffers[MarketAction.Buy] = {}
  marketOffers[MarketAction.Sell] = {}
  sellOfferTable:clearData()
  MyOfferTable:clearData()
  histTable:clearData()
  lastCounterArray = {}
  hlastCounterArray = {}
  hlastTimeStompArray = {}
  lastTimeStompArray = {}
end

local function clearMyOffers()
  sellMyOfferTable:clearData()
end

local function clearMyHist()
	
end

local function updateDesc(desc, itemId)
	if LOADED then
	itemDescTable:clearData()
	itemDescTable:setColor('#008b00')
	itemDescTable:setText(string.gsub(desc, "255", ""))
	--itemDescTable:setText(desc)
	selectedItemOffer:setItemId(itemId)
	local offer = selectedOffer[MarketAction.Buy]
	if offer:getPrice() == 0 then
		buyButton:disable()
	end
	end
end

local function clearFilters()
  for _, filter in pairs(filterButtons) do
    if filter and filter:isChecked() ~= filter.default then
      filter:setChecked(filter.default)
    end
  end
end

local function clearFee()
  feeLabel:setText('')
  fee = 20
end

local function refreshTypeList()
  --offerTypeList:clearOptions()
  --offerTypeList:addOption('Buy')

  if Market.isItemSelected() then
	  --createOfferButton:setEnabled(true)
  end
end
lastTimeStamp = nil
lastCounter = nil
local function addOffer(offer, offerType)
  if not offer then
    return false
  end
  local id = offer:getId()
  local player = offer:getPlayer()
  local amount = offer:getAmount()
  local price = offer:getPrice()
  local timestamp = offer:getTimeStamp()
  local itemName = offer.itemname
  local state = ""
  
  for i, v in pairs(MarketOfferState) do
	if v == offer:getState() then
		state = i
	end
  end
  sellOfferTable:toggleSorting(false)

  sellMyOfferTable:toggleSorting(false)

  if amount < 1 then return false end
  if offerType == MarketAction.Buy then
    if offer.warn then
      buyOfferTable:setColumnStyle('OfferTableWarningColumn', true)
    end

    if offer.warn then
      row:setTooltip(tr('This offer is 25%% below the average market price'))
      --buyOfferTable:setColumnStyle('OfferTableColumn', true)
    end
  else
    if offer.warn then
      sellOfferTable:setColumnStyle('OfferTableWarningColumn', true)
    end

    local row = nil
	local totalOfferPrice = ""
	local offerText = ""
	if price == 0 then
		offerText = "Offer"
	else
		offerText = price/100
	end
	if price == 0 then
		totalOfferPrice = "Offer"
	else
		totalOfferPrice = (price/100)*amount
	end
    if offer.var == MarketRequest.MyOffers then	
		if not isInArray(lastCounterArray, offer:getCounter()) and not isInArray(lastTimeStompArray, offer:getTimeStamp()) then 
			row = sellMyOfferTable:addRow({
				{text = itemName},
				{text = totalOfferPrice},
				{text = offerText},
				{text = amount},
				{text = string.gsub(os.date('%c', timestamp), " ", "  "), sortvalue = timestamp}
			})
			table.insert(lastCounterArray, offer:getCounter())
			table.insert(lastTimeStompArray, offer:getTimeStamp())
		end
	elseif offer.var == MarketRequest.MyHistory then
		if not isInArray(hlastCounterArray, offer:getCounter()) and not isInArray(hlastTimeStompArray, offer:getTimeStamp()) then 
			row = histTable:addRow({
				{text = itemName},
				{text = totalOfferPrice},
				{text = amount},
				{text = state},
				{text = string.gsub(os.date('%c', timestamp), " ", "  "), sortvalue = timestamp}
			})
			table.insert(hlastCounterArray, offer:getCounter())
			table.insert(hlastTimeStompArray, offer:getTimeStamp())
	  end
    else
		row = sellOfferTable:addRow({
			{text = itemName},
			{text = player},
			{text = amount},
			{text = totalOfferPrice},
			{text = offerText},
			{text = string.gsub(os.date('%c', timestamp), " ", "  "), sortvalue = timestamp}
		})
    end
	if row then
		row.ref = id
	end

    if offer.warn then
      row:setTooltip(tr('This offer is 25%% above the average market price'))
      sellOfferTable:setColumnStyle('OfferTableColumn', true)
    end
  end

  --buyOfferTable:toggleSorting(false)
  sellOfferTable:toggleSorting(false)
 -- buyOfferTable:sort()
  sellOfferTable:sort()

  --buyMyOfferTable:toggleSorting(false)
  sellMyOfferTable:toggleSorting(false)
  --buyMyOfferTable:sort()
  sellMyOfferTable:sort()
 -- Market.refreshMyOffers()
  return true
end

local function mergeOffer(offer)
  if not offer then
    return false
  end

  local id = offer:getId()
  local offerType = offer:getType()
  local amount = offer:getAmount()
  local replaced = false

  if offerType == MarketAction.Buy then
    if averagePrice > 0 then
      offer.warn = offer:getPrice() <= averagePrice - math.floor(averagePrice / 4)
    end

    for i = 1, #marketOffers[MarketAction.Buy] do
      local o = marketOffers[MarketAction.Buy][i]
      -- replace existing offer
      if o:isEqual(id) then
        marketOffers[MarketAction.Buy][i] = offer
        replaced = true
      end
    end
    if not replaced then
      table.insert(marketOffers[MarketAction.Buy], offer)
    end
  else
    if averagePrice > 0 then
      offer.warn = offer:getPrice() >= averagePrice + math.floor(averagePrice / 4)
    end

    for i = 1, #marketOffers[MarketAction.Sell] do
      local o = marketOffers[MarketAction.Sell][i]
      -- replace existing offer
      if o:isEqual(id) then
        marketOffers[MarketAction.Sell][i] = offer
        replaced = true
      end
    end
    if not replaced then
      table.insert(marketOffers[MarketAction.Sell], offer)
    end
  end
  return true
end
lastCounterArray = {}
lastTimeStompArray = {}
hlastCounterArray = {}
hlastTimeStompArray = {}
local actualPage = 1
local maxPerPage = 15
local function updateOffers(offers)
  if not sellOfferTable then
    return
  end
	balanceLabel:setColor('#bbbbbb')
	selectedOffer[MarketAction.Buy] = nil
	selectedOffer[MarketAction.Sell] = nil

	selectedMyOffer[MarketAction.Buy] = nil
	selectedMyOffer[MarketAction.Sell] = nil

	sellOfferTable:clearData()
	sellOfferTable:setSorting(4, TABLE_SORTING_ASC)

	buyButton:setEnabled(false)
	contactButton:disable()
	refuseButton:disable()
	sellCancelButton:setEnabled(false)
	for _, offer in pairs(offers) do
		mergeOffer(offer)
	end
	local counter = 0
	local itemCount = 0
	for type, offers in pairs(marketOffers) do
		for i = 1, #offers do
			if offers[i].amount <= 100 then
				if categorySelect:getText() == "All" then
					if searchEdit:getText():len() > 1 then
						if string.find(offers[i].itemname:lower(), searchEdit:getText():lower()) then
							addOffer(offers[i], type)
						end
					else
						if type == MarketAction.Sell and offers[i].var ~= MarketRequest.MyOffers and offers[i].var ~= MarketRequest.MyHistory then
							if itemCount >= (maxPerPage*actualPage)-maxPerPage and itemCount <= (maxPerPage*actualPage) then
								addOffer(offers[i], type)
							end
						else
							addOffer(offers[i], type)
						end
						itemCount = itemCount + 1
					end
				else
					if getCategoryById(offers[i]:getItem():getId()) == categorySelect:getText() then
						if searchEdit:getText():len() > 1 then
							if string.find(offers[i].itemname:lower(), searchEdit:getText():lower()) then
								addOffer(offers[i], type)
							end
						else
							if type == MarketAction.Sell and offers[i].var ~= MarketRequest.MyOffers and offers[i].var ~= MarketRequest.MyHistory then
								if itemCount >= (maxPerPage*actualPage)-maxPerPage and itemCount <= (maxPerPage*actualPage) then
									addOffer(offers[i], type)
								end
							else
								addOffer(offers[i], type)
							end
							itemCount = itemCount + 1
						end
					end
				end
			end
		end
		if counter >= #marketOffers then
			LOADED = true
		end
		counter = counter + 1
	end
end

function nextPage()
	actualPage = actualPage + 1
	refresh()
end

function backPage()
	if actualPage-1 > 0 then
		actualPage = actualPage - 1
		refresh()
	end
end

function getCategoryById(Id)
	local categorias = {
		['Pokemons'] = {19006, 19028, 19029, 19030, 19031, 19032, 18274, 18275, 18276, 18277, 18314, 18316, 18317, 18318, 18359, 14827, 12100, 12102, 12104, 12106, 12108, 12110, 12112, 12114, 12116, 12119, 12121, 12123, 12125, 12127, 12129, 12131, 12133, 12135, 12137, 12139, 12141, 12143, 12145, 12147, 12149, 12151, 12152, 12155, 12157, 12159, 12161, 12163, 12165, 12167, 12169, 12171, 12173, 12175, 12177, 12179, 12181, 12183, 12185, 12187, 12189, 12191, 12193, 12195, 12197, 12199, 12201, 12203, 12205, 12206, 12207, 12209, 12211, 12213, 12215, 12217, 12219, 12221, 12223, 12225, 12227, 12229, 12231, 12233, 12235, 12237, 12239, 12241, 12243, 12245, 12247, 12249, 12251, 12253, 12255, 12257, 12258, 12260, 12262, 12266, 12268, 12270, 12272, 12274, 12276, 12278, 12280, 12282, 12284, 12286, 12288, 12290, 12292, 12294, 12296, 12298, 12300, 12302, 12304, 12306, 12308, 12310, 12312, 12314, 12316, 12318, 12320, 12322, 12324, 12326, 12328, 12330, 12332, 12334, 12336, 12339, 12341, 12343, 12345, 12347, 12349, 12351, 12353, 12355, 12357, 12359, 12361, 12363, 12365, 12367, 12369, 12371, 12373, 12375, 12377, 12379, 12381, 12383, 12385, 12387, 12390, 12392, 12394, 12396, 12398, 12400, 12402, 12404, 12406, 12408, 12410, 12412, 12414, 12416, 12418, 12420, 12422, 12424, 12426, 12428, 12430, 12432, 12434, 12436, 12438, 12440, 12442, 12444, 12446, 12448, 12450, 12452, 12454, 12456, 12458, 12460, 12462, 12464, 12466, 12468, 12471, 12473, 12475, 12477, 12479, 12481, 12483, 12485, 12487, 12488, 12490, 12492, 12494, 12496, 12498, 12500, 12502, 12504, 12506, 12508, 12510, 12512, 12514, 12516, 12518, 12520, 12522, 12524, 12526, 12528, 12530, 12532, 12534, 12536, 12538, 12540, 12542, 12544, 12546, 12548, 12550, 12552, 12554, 12556, 12558, 12560, 12562, 12564, 12566, 12568, 12570, 12572, 12574, 12576, 12578, 12580, 12582, 12584, 12586, 12588, 12590, 12592, 12594, 12596, 12598, 12600, 12604, 12606, 12608, 12610, 12612, 12614, 12616, 12618, 12620, 12622, 12624, 12626, 12628, 12630, 12632, 12634, 12636, 12638, 12640, 12642, 12644, 12646, 12648, 12650, 12652, 12654, 12656, 12658, 12660, 12662, 12664, 12666, 12668, 12670, 12672, 12674, 12676, 12678, 12680, 12682, 12684, 12686, 12688, 12690, 12692, 12694, 12696, 12698, 12700, 12702, 12704, 12706, 12708, 12710, 12712, 12714, 12716, 12717, 12719, 12721, 12723, 12724, 12726, 12727, 12729, 12792, 12795, 12796, 12797, 12904, 12907, 12911, 12914, 12918, 12921, 12925, 12929, 12933, 12936, 12940, 12943, 12947, 12951, 12955, 12959, 12963, 12967, 12971, 12975, 12979, 12983, 12987, 12991, 12995, 12999, 13003, 13007, 13011, 13015, 13019, 13052, 13083, 13086, 13093, 13330, 1332, 13334, 13885, 13886, 13887, 13888, 13889, 13890, 13891, 13892, 13893, 13894, 13895, 13896, 13897, 13898, 13899, 13900, 13901, 13902, 13903, 13904, 13905, 13906, 13907, 13908, 13909, 13910, 13911, 13912, 13913, 13914, 13915, 13916, 13917, 13918, 13919, 13920, 13921, 13922, 13923, 13924, 13925, 13926, 13927, 13928, 13929, 13930, 13931, 13932, 13933, 13934, 13935, 13936, 13937, 13938, 13939, 13940, 13941, 13942, 13943, 13944, 13945, 13946, 13947, 13948, 13949, 13950, 13951, 13952, 13953, 13954, 13955, 13956, 13957, 13958, 14033, 14035, 14036, 14037, 14038, 14039, 14040, 14041, 14042, 14043, 14044}, 
		['Pokeballs'] = {3279, 3280, 3281, 3282, 14816, 14817, 14818, 14819, 14820, 14821, 14822, 14823, 14824, 14825, 14826}, 
		['Helds'] = {14632, 14633, 14634, 14635, 14636,  14637, 14638, 14639, 14640, 14641, 14642, 14643, 14644, 14645, 14646, 14647, 14648, 14649, 14650, 14651, 14652, 14653, 14654, 14655, 14656, 14657, 14658, 14659, 14660, 14661, 14662, 14663, 14665, 14666, 14667, 14668, 14669, 14670, 14671, 14672, 14673, 14674, 14675, 14676, 14677, 14678, 14679, 14680, 14681, 14682, 14683, 14684, 14685, 14686, 14687, 14688, 14689, 14690, 14691, 14692, 14693, 14694, 14695, 14696, 14697, 14698, 14699, 14700, 14701, 14702, 14703, 14704, 14705, 14706, 14707, 14708, 14709, 14710, 14711, 14712, 14713, 14714, 14715, 14716, 16508, 16509, 16510, 16511, 16512, 16513, 16513, 16332, 16333,16334,16335,16336,16337,16338,16339,16340,16341,16342,16343,16344,16345,16346,16347,16348,16349,16350,16351,16352,16353,16354,16355,16356,16357,16358,16359,16360,16361,16362,16363,16364,16365,16366,16367,16368,16369,16370,16371,16372,16373,16374,16375,16376,16377,16378,16379,16380,16381,16382,16383,16384,16385,16386,16387,16388,16389,16390,16391,16392,16393,16394,16395,16396,16397,16398,16399,16400,16401,16402,16403,16404,16405,16406,16407,16408,16409,16410,16411,16412,16413,16414,16415,16416,16417,16418,16419,16420,16421,16422,16423,16424,16425,16426,16427,16428,16429,16430,16431,16432,16433,16434,16435,16436,16437,16438,16439,16440,16441,16442,16443,16444,16445,16446,16447,16448,16449,16450,16451,16452,16453,16454,16455,16456,16457,16458,16459,16460,16461,16462,16463,16464,16465,16466,16467,16468,16469,16470,16471,16472,16473,16474,16475,16476,16477,16478,16479,16480,16481,16482,16483,16484,16485,16486,16487,16488,16489,16490,16491,16492,16493,16494,16495,16496,16497,16498,16499, 16500, 16501}, 
		['Cards'] = {18983, 18984, 18985, 18986, 18987, 18988, 18989, 18990, 18991, 3216},  
		['Stones'] = {18291, 10530, 10531, 10532, 10533, 10534, 10535, 10536, 10537, 10538, 10539, 10540, 10541, 10542, 10543, 18290, 11941}, 
		['Rubys'] = {2145}, 
		['Rare'] = {19046, 19045, 19044, 19043, 19042, 19041, 18996, 18997, 18998, 18999, 19000, 19001, 19002, 19003, 19004, 19005, 19009, 19010, 19011, 19012, 19013, 19014, 19015, 19016, 19017, 18294, 18360, 18361, 18362, 18363, 18364, 18365, 18366, 18367, 18368, 18369, 18370, 18371, 18372, 18373, 18374, 18375, 18376, 18377, 18378, 18379, 18380, 18381, 12382, 12383, 18407, 18408, 18409, 18406, 18412, 18413, 18414, 14147, 14148, 14149, 14150, 14151, 14152, 14153, 14154, 14155, 14156, 14208, 14209, 14210, 14211, 14212, 14213, 14214, 14215, 14216, 14217, 14218, 14251, 14252, 14253, 14254, 14255, 14256}, 
		['Decoration'] = {2845, 58789}
	}
	for i, v in pairs(categorias) do
		for u, p in pairs(v) do
			if p == Id then
				return i
			end
		end
	end
	return "Others"
end

local function updateDetails(itemId, descriptions, purchaseStats, saleStats)
  if not selectedItem then
    return
  end

  -- update item details
  detailsTable:clearData()
  for k, desc in pairs(descriptions) do
    local columns = {
      {text = getMarketDescriptionName(desc[1])..':'},
      {text = desc[2]}
    }
    detailsTable:addRow(columns)
  end

  -- update sale item statistics
  sellStatsTable:clearData()
  if table.empty(saleStats) then
    sellStatsTable:addRow({{text = 'No information'}})
  else
    local offerAmount = 0
    local transactions, totalPrice, highestPrice, lowestPrice = 0, 0, 0, 0
    for _, stat in pairs(saleStats) do
      if not stat:isNull() then
        offerAmount = offerAmount + 1
        transactions = transactions + stat:getTransactions()
        totalPrice = totalPrice + stat:getTotalPrice()
        local newHigh = stat:getHighestPrice()
        if newHigh > highestPrice then
          highestPrice = newHigh
        end
        local newLow = stat:getLowestPrice()
        -- ?? getting '0xffffffff' result from lowest price in 9.60 cipsoft
        if (lowestPrice == 0 or newLow < lowestPrice) and newLow ~= 0xffffffff then
          lowestPrice = newLow
        end
      end
    end

    if offerAmount >= 5 and transactions >= 10 then
      averagePrice = math.round(totalPrice / transactions)
    else
      averagePrice = 0
    end
	MyOfferTable:clearData()
    sellStatsTable:addRow({{text = 'Total Transations:'}, {text = transactions}})
    sellStatsTable:addRow({{text = 'Highest Price:'}, {text = highestPrice}})

    if totalPrice > 0 and transactions > 0 then
      sellStatsTable:addRow({{text = 'Average Price:'},
        {text = math.floor(totalPrice/transactions)}})
    else
      sellStatsTable:addRow({{text = 'Average Price:'}, {text = 0}})
    end

    sellStatsTable:addRow({{text = 'Lowest Price:'}, {text = lowestPrice}})
  end

  -- update buy item statistics
  buyStatsTable:clearData()
  if table.empty(purchaseStats) then
    buyStatsTable:addRow({{text = 'No information'}})
  else
    local transactions, totalPrice, highestPrice, lowestPrice = 0, 0, 0, 0
    for _, stat in pairs(purchaseStats) do
      if not stat:isNull() then
        transactions = transactions + stat:getTransactions()
        totalPrice = totalPrice + stat:getTotalPrice()
        local newHigh = stat:getHighestPrice()
        if newHigh > highestPrice then
          highestPrice = newHigh
        end
        local newLow = stat:getLowestPrice()
        -- ?? getting '0xffffffff' result from lowest price in 9.60 cipsoft
        if (lowestPrice == 0 or newLow < lowestPrice) and newLow ~= 0xffffffff then
          lowestPrice = newLow
        end
      end
    end

    buyStatsTable:addRow({{text = 'Total Transations:'},{text = transactions}})
    buyStatsTable:addRow({{text = 'Highest Price:'}, {text = highestPrice}})

    if totalPrice > 0 and transactions > 0 then
      buyStatsTable:addRow({{text = 'Average Price:'},
        {text = math.floor(totalPrice/transactions)}})
    else
      buyStatsTable:addRow({{text = 'Average Price:'}, {text = 0}})
    end

    buyStatsTable:addRow({{text = 'Lowest Price:'}, {text = lowestPrice}})
  end
end

local function updateBalance(balance)
  local balance = tonumber(balance)
  if not balance then
    return
  end

  if balance < 0 then balance = 0 end
  information.balance = balance

  balanceLabel:setText('Balance: '..(balance/100)..' dollar')
  balanceLabel:resizeToText()
end

local function updateFee(price, amount)
  fee = math.ceil(price / 100 * amount)
  if fee < 20 then
    fee = 20
  elseif fee > 1000 then
    fee = 1000
  end
  feeLabel:setText('Fee: '..(fee/100))
  feeLabel:resizeToText()
end

local function destroyAmountWindow()
  if amountWindow then
    amountWindow:destroy()
    amountWindow = nil
  end
   if msgWindow then
    msgWindow:destroy()
    msgWindow = nil
  end
end

local function cancelMyOffer(actionType)
  local offer = selectedMyOffer[actionType]
  MarketProtocol.sendMarketCancelOffer(offer:getTimeStamp(), offer:getCounter())
  Market.refreshMyOffers()
  Market.refreshMyHist()
  refresh()
end

local function openAmountWindow(callback, actionType, actionText)
  if not Market.isOfferSelected(actionType) then
    return
  end

  amountWindow = g_ui.createWidget('AmountWindow', rootWidget)
  amountWindow:lock()

  local offer = selectedOffer[actionType]
  local item = offer:getItem()

  local maximum = offer:getAmount()
  if actionType == MarketAction.Sell then

  else
    maximum = math.min(maximum, math.floor(information.balance / offer:getPrice()))
  end

  if item:isStackable() then
    maximum = math.min(maximum, MarketMaxAmountStackable)
  else
    maximum = math.min(maximum, MarketMaxAmount)
  end

  local itembox = amountWindow:getChildById('item')
  itembox:setItemId(item:getId())

  local scrollbar = amountWindow:getChildById('amountScrollBar')
  scrollbar:setText((offer:getPrice()/100)..'$')

  scrollbar.onValueChange = function(widget, value)
    widget:setText((value*(offer:getPrice()/100))..'$')
    itembox:setText(value)
  end

  scrollbar:setRange(1, maximum)
  scrollbar:setValue(1)

  local okButton = amountWindow:getChildById('buttonOk')
  if actionText then
    okButton:setText(actionText)
  end

  local okFunc = function()
    local counter = offer:getCounter()
    local timestamp = offer:getTimeStamp()
    callback(scrollbar:getValue(), timestamp, counter)
    destroyAmountWindow()
  end

  local cancelButton = amountWindow:getChildById('buttonCancel')
  local cancelFunc = function()
    destroyAmountWindow()
  end

  amountWindow.onEnter = okFunc
  amountWindow.onEscape = cancelFunc

  okButton.onClick = okFunc
  cancelButton.onClick = cancelFunc
end

local function onSelectSellOffer(table, selectedRow, previousSelectedRow)
  if LOADED then
  updateBalance()
  for _, offer in pairs(marketOffers[MarketAction.Sell]) do
    if offer:isEqual(selectedRow.ref) then
      selectedOffer[MarketAction.Buy] = offer
    end
  end
  local offer = selectedOffer[MarketAction.Buy]
	MarketProtocol.sendMarketItemDesc(offer:getTimeStamp(), offer:getCounter())
  if offer then
    local price = offer:getPrice()
	if price == 0 then
		offerButton:enable()
	end
	local player = g_game.getLocalPlayer()
    if price > information.balance then
      balanceLabel:setColor('#b22222') -- red
      buyButton:setEnabled(false)
    else
      local slice = (information.balance / 2)
      if (price/slice) * 100 <= 40 then
        color = '#008b00' -- green
      elseif (price/slice) * 100 <= 70 then
        color = '#eec900' -- yellow
      else
        color = '#ee9a00' -- orange
      end
      balanceLabel:setColor(color)
      buyButton:setEnabled(true)
    end
	
	if player:getName() == offer.player then
		buyButton:setEnabled(false)
	end
  end
  end
end
senderName = nil
senderMessage = nil
ItemName = nil
local function onSelectMyOffer(table, selectedRow, previousSelectedRow)
	if LOADED then
	senderName = selectedRow.sender
	senderMessage = selectedRow.message
	contactButton:enable()
	refuseButton:enable()
	end
end

function doContact()
	if senderName ~= nil then
		g_game.openPrivateChannel(senderName)
	end
end

function doRecuse()
	if senderName ~= nil then
		local protocol = g_game.getProtocolGame()
		if protocol then
			protocol:sendExtendedOpcode(73, senderName.."|"..senderMessage.."|"..ItemName)
			if selectedTimeStamp ~= nil then
				protocol:sendExtendedOpcode(72, selectedTimeStamp.."|"..selectedCounters)
			end
		end
		MyOfferTable:clearData()
	end
end
local function onSelectBuyOffer(table, selectedRow, previousSelectedRow)
  if LOADED then
	updateBalance()
	for _, offer in pairs(marketOffers[MarketAction.Buy]) do
		if offer:isEqual(selectedRow.ref) then
			selectedOffer[MarketAction.Sell] = offer
			MarketProtocol.sendMarketItemDesc(offer:getTimeStamp(), offer:getCounter())
		end
	end
  end
end

local function onSelectMyBuyOffer(table, selectedRow, previousSelectedRow)
	if LOADED then
  for _, offer in pairs(marketOffers[MarketAction.Buy]) do
    if offer:isEqual(selectedRow.ref) then
      selectedMyOffer[MarketAction.Buy] = offer
      --buyCancelButton:setEnabled(true)
    end
  end
  end
end
selectedTimeStamp = nil
selectedCounters = nil 
local function onSelectMySellOffer(table, selectedRow, previousSelectedRow)
if LOADED then
  for _, offer in pairs(marketOffers[MarketAction.Sell]) do
    if offer:isEqual(selectedRow.ref) then
      selectedMyOffer[MarketAction.Sell] = offer
      sellCancelButton:setEnabled(true)	  
	  local protocol = g_game.getProtocolGame()
	  ItemName = offer.itemname
	  if protocol then
		protocol:sendExtendedOpcode(72, offer:getTimeStamp().."|"..offer:getCounter())
	  end
	  contactButton:disable()
	  refuseButton:disable()
	  selectedTimeStamp = offer:getTimeStamp()
	  selectedCounters = offer:getCounter()
	  
    end
  end
  end
end

local function onChangeCategory(combobox, option)
 
end

local function onChangeSlotFilter(combobox, option)

end

local function onChangeOfferType(combobox, option)
  local item = selectedItem.item
  local maximum = item.thingType:isStackable() and MarketMaxAmountStackable or MarketMaxAmount

  if option == 'Sell' then
	maximum = selectedItem.count
    amountEdit:setMaximum(maximum)
  else
    amountEdit:setMaximum(maximum)
  end
end

local function onTotalPriceChange()
  local amount = amountEdit:getValue()
  local totalPrice = totalPriceEdit:getValue()
  local piecePrice = math.floor(totalPrice/amount)

  piecePriceEdit:setValue(piecePrice, true)
  if Market.isItemSelected() then
    updateFee(piecePrice, amount)
  end
end

local function onPiecePriceChange()
  local amount = amountEdit:getValue()
  local totalPrice = totalPriceEdit:getValue()
  local piecePrice = piecePriceEdit:getValue()

  totalPriceEdit:setValue(piecePrice*amount, true)
  if Market.isItemSelected() then
    updateFee(piecePrice, amount)
  end
end

local function onAmountChange()
  local amount = amountEdit:getValue()
  local piecePrice = piecePriceEdit:getValue()
  local totalPrice = piecePrice * amount

  totalPriceEdit:setValue(piecePrice*amount, true)
  if Market.isItemSelected() then
    updateFee(piecePrice, amount)
  end
end

local function onMarketMessage(messageMode, message)
  Market.displayMessage(message)
end

local function initMarketItems()

end

local function initInterface()
  -- TODO: clean this up
  -- setup main tabs
  mainTabBar = marketWindow:getChildById('mainTabBar')
  mainTabBar:setContentWidget(marketWindow:getChildById('mainTabContent'))

  -- setup 'Market Offer' section tabs
  marketOffersPanel = g_ui.loadUI('ui/marketoffers')
  mainTabBar:addTab(tr('Market Offers'), marketOffersPanel)

  selectionTabBar = marketOffersPanel:getChildById('leftTabBar')
  selectionTabBar:setContentWidget(marketOffersPanel:getChildById('leftTabContent'))

  displaysTabBar = marketOffersPanel:getChildById('rightTabBar')
  displaysTabBar:setContentWidget(marketOffersPanel:getChildById('rightTabContent'))

  itemStatsPanel = g_ui.loadUI('ui/marketoffers/itemstats')
  --displaysTabBar:addTab(tr('Statistics'), itemStatsPanel)

  itemDetailsPanel = g_ui.loadUI('ui/marketoffers/itemdetails')
  --displaysTabBar:addTab(tr('Details'), itemDetailsPanel)

  itemOffersPanel = g_ui.loadUI('ui/marketoffers/itemoffers')
  displaysTabBar:addTab(tr('Offers'), itemOffersPanel)
  displaysTabBar:selectTab(displaysTabBar:getTab(tr('Offers')))

  -- setup 'My Offer' section tabs
  myOffersPanel = g_ui.loadUI('ui/myoffers')
  mainTabBar:addTab(tr('My Offers'), myOffersPanel)

  offersTabBar = myOffersPanel:getChildById('offersTabBar')
  offersTabBar:setContentWidget(myOffersPanel:getChildById('offersTabContent'))

  currentOffersPanel = g_ui.loadUI('ui/myoffers/currentoffers')
  offersTabBar:addTab(tr('Current Offers'), currentOffersPanel)

  offerHistoryPanel = g_ui.loadUI('ui/myoffers/offerhistory')
  offersTabBar:addTab(tr('Offer History'), offerHistoryPanel)

  balanceLabel = marketWindow:getChildById('balanceLabel')

  -- setup offers
  buyButton = itemOffersPanel:getChildById('buyButton')
  buyButton.onClick = function() openAmountWindow(Market.acceptMarketOffer, MarketAction.Buy, 'Buy') end
  --sellButton = itemOffersPanel:getChildById('sellButton')
  --sellButton.onClick = function() openAmountWindow(Market.acceptMarketOffer, MarketAction.Sell, 'Sell') end

  -- setup selected item
  nameLabel = marketOffersPanel:getChildById('nameLabel')
  selectedItem = marketOffersPanel:getChildById('selectedItem')
  selectedItemOffer = marketOffersPanel:getChildById('selectedOfferItem')
  searchEdit = marketOffersPanel:getChildById('searchEdit')
  findLabel = marketOffersPanel:getChildById('findLabel')
  findLabel:resizeToText()
  categorySelect = marketOffersPanel:getChildById('CategorySelect')

  -- setup create new offer
  totalPriceEdit = marketOffersPanel:getChildById('totalPriceEdit')
  piecePriceEdit = marketOffersPanel:getChildById('piecePriceEdit')
  amountEdit = marketOffersPanel:getChildById('amountEdit')
  feeLabel = marketOffersPanel:getChildById('feeLabel')
  totalPriceEdit.onValueChange = onTotalPriceChange
  piecePriceEdit.onValueChange = onPiecePriceChange
  amountEdit.onValueChange = onAmountChange

  anonymous = marketOffersPanel:getChildById('anonymousCheckBox')
  onlyoffer = marketOffersPanel:getChildById('onlyOfferCheckBox')
  createOfferButton = marketOffersPanel:getChildById('createOfferButton')
  createOfferButton.onClick = Market.createNewOffer
  offerButton = itemOffersPanel:getChildById('sendOfferButton')
  offerButton.onClick = sendOffer
  Market.enableCreateOffer(false)
  createOfferButton:setEnabled(false)

  -- setup filters
  -- set filter default values
  clearFilters()

  -- hook filters

  -- setup tables
  histTable = offerHistoryPanel:recursiveGetChildById('myHistTable')
  itemDescTable = itemOffersPanel:recursiveGetChildById('itemdetailsTable')
  sellOfferTable = itemOffersPanel:recursiveGetChildById('sellingTable')
  detailsTable = itemDetailsPanel:recursiveGetChildById('detailsTable')
  buyStatsTable = itemStatsPanel:recursiveGetChildById('buyStatsTable')
  sellStatsTable = itemStatsPanel:recursiveGetChildById('sellStatsTable')
  sellOfferTable.onSelectionChange = onSelectSellOffer

  -- setup my offers
  sellMyOfferTable = currentOffersPanel:recursiveGetChildById('mySellingTable')
  sellMyOfferTable.onSelectionChange = onSelectMySellOffer
  
  MyOfferTable = currentOffersPanel:recursiveGetChildById('myBuyTable')
  MyOfferTable.onSelectionChange = onSelectMyOffer


  sellCancelButton = currentOffersPanel:getChildById('sellCancelButton')
  sellCancelButton.onClick = function() cancelMyOffer(MarketAction.Sell) end
  
  contactButton = currentOffersPanel:getChildById('contactButton')
  contactButton.onClick = doContact
  
  refuseButton = currentOffersPanel:getChildById('refuseButton')
  refuseButton.onClick = doRecuse

  buyStatsTable:setColumnWidth({120, 270})
  sellStatsTable:setColumnWidth({120, 270})
  detailsTable:setColumnWidth({80, 330})

  sellOfferTable:setSorting(4, TABLE_SORTING_ASC)

  sellMyOfferTable:setSorting(3, TABLE_SORTING_DESC)
  itemDescTable:setText(' ')
  selectedItemOffer:setItemId(0)
  onlyoffer:disable()
  	contactButton:disable()
	refuseButton:disable()
end

function onlyOffer()
	if onlyoffer:isChecked() then
		piecePriceEdit:setValue(0)
		piecePriceEdit:disable()
	else
		piecePriceEdit:enable()
	end
end

function sendOffer()
  if not Market.isOfferSelected(MarketAction.Buy) then
    return
  end

  msgWindow = g_ui.createWidget('MsgWindow', rootWidget)
  msgWindow:lock()

  local offer = selectedOffer[MarketAction.Buy]
  local textBox = msgWindow:getChildById('textBox')

  local okButton = msgWindow:getChildById('buttonOk')
  local okFunc = function()
    local protocol = g_game.getProtocolGame()
	if protocol then
		protocol:sendExtendedOpcode(71, offer:getPlayer()..'|'..textBox:getText()..'|'..offer.itemname.."|"..offer:getTimeStamp().."|"..offer:getCounter())
	end
    destroyAmountWindow()
  end

  local cancelButton = msgWindow:getChildById('buttonCancel')
  local cancelFunc = function()
    destroyAmountWindow()
  end

  msgWindow.onEnter = okFunc
  msgWindow.onEscape = cancelFunc

  okButton.onClick = okFunc
  cancelButton.onClick = cancelFunc
end

function init()
  g_ui.importStyle('market')
  g_ui.importStyle('ui/general/markettabs')
  g_ui.importStyle('ui/general/marketbuttons')
  g_ui.importStyle('ui/general/marketcombobox')
  g_ui.importStyle('ui/general/amountwindow')
  g_ui.importStyle('ui/general/msgwindow')

  offerExhaust[MarketAction.Sell] = 10
  offerExhaust[MarketAction.Buy] = 20
  
  mouseGrabberWidget = g_ui.createWidget('UIWidget')
  mouseGrabberWidget:setVisible(false)
  mouseGrabberWidget:setFocusable(false)
  mouseGrabberWidget.onMouseRelease = onChooseItemMouseRelease

  registerMessageMode(MessageModes.Market, onMarketMessage)
  protocol.initProtocol()
  connect(g_game, { onGameEnd = Market.reset })
  connect(g_game, { onGameEnd = Market.close })
  marketWindow = g_ui.createWidget('MarketWindow', rootWidget)
  marketWindow:hide()
  ProtocolGame.registerExtendedOpcode(96, updateMyOffer)
  ProtocolGame.registerExtendedOpcode(97, updateMyHist)
  actualPage = 1
  initInterface() -- build interface
end

function updateMyOffer(protocol, opcode, buffer)
	local data = string.split(buffer, "|")
	histTable:clearData()
	MyOfferTable:clearData()
	for i, v in pairs(data) do
		local row = nil
		local dataRef = string.split(v, "*")
		row = MyOfferTable:addRow({{text = dataRef[1]},{text = dataRef[2]}})
		row.sender = dataRef[1]
		row.message = dataRef[2]
	end
end

function updateMyHist(protocol, opcode, buffer)
	local data = string.split(buffer, "|")
	MyOfferTable:clearData()
	for i, v in pairs(data) do
		local row = nil
		local dataRef = string.split(v, "*")
		row = histTable:addRow({{text = dataRef[1]},{text = dataRef[2]},{text = dataRef[3]},{text = dataRef[4]}})
	end
end

function terminate()
  Market.close()

  unregisterMessageMode(MessageModes.Market, onMarketMessage)

  protocol.terminateProtocol()
  disconnect(g_game, { onGameEnd = Market.reset })
  disconnect(g_game, { onGameEnd = Market.close })

  destroyAmountWindow()
  marketWindow:destroy()
  actualPage = 1

  Market = nil
end

function Market.reset()
  balanceLabel:setColor('#bbbbbb')
  clearMyOffers()
  if not table.empty(information) then
    Market.updateCurrentItems()
  end
end

function Market.displayMessage(message)
  if marketWindow:isHidden() then return end

  local infoBox = displayInfoBox(tr('Market Error'), message)
  infoBox:lock()
end

function Market.clearSelectedItem()
  if Market.isItemSelected() then
    Market.resetCreateOffer(true)
    clearOffers()
    selectedItem:setItem(nil)
    selectedItem.item = nil
	if selectedItem.ref then
		selectedItem.ref:setChecked(false)
		selectedItem.ref = nil
	end

    detailsTable:clearData()
    buyStatsTable:clearData()
    sellStatsTable:clearData()
	MyOfferTable:clearData()
    Market.enableCreateOffer(false)
  end
end

function Market.isItemSelected()
  return selectedItem and selectedItem.item
end

function Market.isOfferSelected(type)
  return selectedOffer[type] and not selectedOffer[type]:isNull()
end

function Market.getDepotCount(itemId)
	local info = information.depotItems[itemId]
	if info then
		return info
	end
	return  0
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    else
      print(formatting .. v)
    end
  end
end

function Market.enableCreateOffer(enable)
  --offerTypeList:setEnabled(enable)
  totalPriceEdit:setEnabled(enable)
  piecePriceEdit:setEnabled(enable)
  amountEdit:setEnabled(enable)
  anonymous:setEnabled(enable)
  --createOfferButton:setEnabled(enable)

  local prevAmountButton = marketOffersPanel:recursiveGetChildById('prevAmountButton')
  local nextAmountButton = marketOffersPanel:recursiveGetChildById('nextAmountButton')

  prevAmountButton:setEnabled(enable)
  nextAmountButton:setEnabled(enable)
end

function Market.close(notify)
  if notify == nil then notify = true end
  if not marketWindow:isHidden() then
    marketWindow:hide()
    marketWindow:unlock()
    modules.game_interface.getRootPanel():focus()
    Market.clearSelectedItem()
    Market.reset()
    if notify then
      MarketProtocol.sendMarketLeave()
    end
  end
end

function Market.incrementAmount()
  amountEdit:setValue(amountEdit:getValue() + 1)
end

function Market.decrementAmount()
  amountEdit:setValue(amountEdit:getValue() - 1)
end

function Market.updateCurrentItems()
	MarketProtocol.sendMarketBrowse(5000)
	LOADED = false
end

function Market.resetCreateOffer(resetFee)
  piecePriceEdit:setValue(1)
  totalPriceEdit:setValue(1)
  amountEdit:setValue(1)
  refreshTypeList()

  if resetFee then
    clearFee()
  else
    updateFee(0, 0)
  end
end

function Market.refreshItemsWidget(selectItem)
  
end

function Market.refreshOffers()
    Market.refreshMyOffers()
end

function Market.refreshMyOffers()
  clearMyOffers()
  MarketProtocol.sendMarketBrowseMyOffers()
end

function Market.refreshMyHist()
	histTable:clearData()
	MarketProtocol.sendMarketBrowseMyHist()
	local protocol = g_game.getProtocolGame()
	if protocol then
		protocol:sendExtendedOpcode(74, "refresh")
	end
end


function Market.loadMarketItems(category)

end

local function updateSelectedItemSelecte(item)
  Market.resetCreateOffer()
  selectedItem.item = item:getId()
  selectedItem.pos = item:getPosition()
  selectedItem:setItemId(item:getId())
  selectedItem.count = item:getCount()
  selectedItem.stackPos = item:getStackPos() 
  Market.enableCreateOffer(true)
  onlyoffer:enable()
end

function startChooseItem()
  if g_ui.isMouseGrabbed() then return end
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
  local item = nil
  if mouseButton == MouseLeftButton then
    local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
    if clickedWidget then
      if clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        item = clickedWidget:getItem()
      end
    end
  end

  if item then
	updateSelectedItemSelecte(item)
	createOfferButton:setEnabled(true)
    --currentHotkeyLabel.itemId = item:getId()
  end
  g_mouse.popCursor('target')
  self:ungrabMouse()
  return true
end

function Market.createNewOffer()
  local type = MarketAction.Sell
  local pos = selectedItem.pos
  local spriteId = selectedItem.item
  local stackpos = selectedItem.stackPos
  local piecePrice = piecePriceEdit:getValue()
  local amount = amountEdit:getValue()
  local anonymous = anonymous:isChecked() and 1 or 0

  -- error checking
  local errorMsg = ''
  if type == MarketAction.Buy then
    if information.balance < ((piecePrice * amount) + fee) then
      errorMsg = errorMsg..'Not enough balance to create this offer.\n'
    end
  elseif type == MarketAction.Sell then
    if information.balance < fee then
      errorMsg = errorMsg..'Not enough balance to create this offer.\n'
    end
  end

  if piecePrice > piecePriceEdit.maximum then
    errorMsg = errorMsg..'Price is too high.\n'
  end
  
  if amount > selectedItem.count then
	errorMsg = errorMsg..'Amount is too high.\n'
  end

  if amount > amountEdit.maximum then
    errorMsg = errorMsg..'Amount is too high.\n'
  elseif amount < amountEdit.minimum then
    errorMsg = errorMsg..'Amount is too low.\n'
  end

  if amount * piecePrice > MarketMaxPrice then
    errorMsg = errorMsg..'Total price is too high.\n'
  end

  if information.totalOffers >= MarketMaxOffers then
    errorMsg = errorMsg..'You cannot create more offers.\n'
  end

  local timeCheck = os.time() - lastCreatedOffer
  if timeCheck < offerExhaust[type] then
    local waitTime = math.ceil(offerExhaust[type] - timeCheck)
    errorMsg = errorMsg..'You must wait '.. waitTime ..' seconds before creating a new offer.\n'
  end
  
  local blockItem = {19007, 11483, 2160, 2148, 2152, 12099, 12101, 12103, 12105, 12107, 12109, 12111, 12113, 12115, 12117, 12118, 12120, 12122, 12124, 12126, 12128, 12130, 12132, 12134, 12136, 12138, 12140, 12142, 12144, 12146, 12148, 12150, 12153, 12154, 12156, 12158, 12160, 12162, 12164, 12166, 12168, 12170, 12172, 12174, 12176, 12178, 12180, 12182, 12184, 12186, 12188, 12190, 12192, 12194, 12196, 12198, 12200, 12202, 12204, 12206, 12208, 12210, 12212, 12214, 12216, 12218, 12220, 12222, 12224, 12226, 12228, 12230, 12232, 12234, 12236, 12238, 12240, 12242, 12244, 12246, 12248, 12250, 12252, 12254, 12256, 12259, 12261, 12263, 12265, 12267, 12269, 12271, 12273, 12275, 12277, 12279, 12281, 12283, 12285, 12287, 12289, 12291, 12293, 12295, 12297, 12299, 12301, 12303, 12305, 12307, 12309, 12311, 12313, 12315, 12317, 12319, 12321, 12323, 12325, 12327, 12329, 12331, 12333, 12335, 12337, 12338, 12340, 12342, 12344, 12346, 12348, 12350, 12352, 12354, 12356, 12358, 12360, 12362, 12364, 12366, 12368, 12370, 12372, 12374, 12376, 12376, 12378, 12380, 12382, 12384, 12386, 12388, 12389, 12391, 12393, 12395, 12397, 12399, 12401, 12403, 12405, 12407, 12409, 12411, 12413, 12415, 12417, 12419, 12421, 12423, 12425, 12427, 12429, 12431, 12433, 12435, 12437, 12439, 12441, 12443, 12445, 12447, 12449, 12451, 12453, 12455, 12457, 12459, 12461, 12463, 12465, 12467, 12469, 12470, 12472, 12474, 12476, 12478, 12480, 12482, 12484, 12486, 12489, 12491, 12493, 12495, 12497, 12499, 12501, 12503, 12505, 12507, 12509, 12511, 12513, 12515, 12517, 12519, 12521, 12523, 12525, 12527, 12529, 12531, 12533, 12535, 12537, 12539, 12541, 12543, 12545, 12547, 12549, 12551, 12553, 12555, 12557, 12559, 12561, 12563, 12565, 12567, 12569, 12571, 12573, 12575, 12577, 12579, 12581, 12583, 12585, 12587, 12589, 12591, 12593, 12595, 12597, 12599, 12601, 12603, 12605, 12607, 12609, 12611, 12613, 12615, 12617, 12619, 12621, 12623, 12625, 12627, 12629, 12631, 12633, 12635, 12637, 12639, 12641, 12643, 12645, 12647, 12649, 12650, 12652, 12654, 12656, 12658, 12660, 12663, 12665, 12667, 12669, 12671, 12673, 12675, 12677, 12679, 12681, 12683, 12685, 12687, 12689, 12691, 12693, 12695, 12697, 12699, 12701, 12703, 12705, 12707, 12709, 12711, 12713, 12715, 12718, 12720, 12722, 12725, 12728, 12738, 12739, 12818, 12903, 12908, 12912, 12915, 12919, 12922, 12926, 12930, 12934, 12937, 12941, 12944, 12948, 12952, 12956, 12960, 12964, 12968, 12972, 12976, 12980, 12984, 12988, 12992, 12996, 13000, 13004, 13008, 13012, 13016, 13020, 13038, 13084, 13087, 13094, 13331, 13333, 13335, 13959, 13960, 13961, 13962, 13963, 13964, 13965, 13966, 13967, 13968, 13969, 13970, 13971, 13972, 13973, 13974, 13975, 13976, 13977, 13978, 13979, 13980, 13981, 13982, 13983, 13984, 13985, 13986, 13987, 13988, 13989, 13990, 13991, 13992, 13993, 13994, 13995, 13996, 13997, 13998, 13999, 14000, 14001, 14002, 14003, 14004, 14005, 14006, 14007, 14008, 14009, 14010, 14011, 14012, 14013, 14014, 14015, 14016, 14017, 14018, 14019, 14020, 14021, 14022, 14023, 14024, 14025, 14026, 14027, 14028, 14029, 14030, 14031, 14032, 14034, 14045, 14046, 14047, 14048, 14049, 14050, 14051, 14052, 14053, 14054, 14055, 14828, 16642, 16644, 16646, 16648, 16650, 16652, 16654, 16656, 16658, 16662, 16664, 16944, 16946, 16948, 16950, 16952, 16954, 16957, 16958, 16960, 17701, 18313, 18315, 18319, 18545, 18546, 18547, 18548, 18549, 18550, 18551, 18552, 18553, 18554, 18555, 18556, 18557, 18558, 18559, 18560, 18561, 18562, 18563, 18564, 18565, 18566, 18567, 18568, 18569, 18570, 18571, 18572, 18573, 18574, 18575, 18576, 18577, 18578, 18579, 18580, 18581, 18582, 18583, 18584, 18585, 18586, 18587, 18588, 18713, 18714, 18715, 19007}
  if isInArray(blockItem, spriteId) then
	errorMsg = errorMsg.."you can't sell this item\n"
  end

  if errorMsg ~= '' then
    Market.displayMessage(errorMsg)
    return
  end
  

  MarketProtocol.sendMarketCreateOffer(type, pos, spriteId, stackpos, amount, (piecePrice*100), anonymous)
  sellOfferTable:clearData()
  Market.refreshOffers()
  lastCreatedOffer = os.time()
  Market.refreshMyHist()
  Market.resetCreateOffer()
  refresh()
  createOfferButton:disable()
  onlyoffer:setChecked(false)
  piecePriceEdit:enable()
end

function Market.acceptMarketOffer(amount, timestamp, counter)
  if timestamp > 0 and amount > 0 then
    MarketProtocol.sendMarketAcceptOffer(timestamp, counter, amount)
    --Market.refreshOffers()
	Market.refreshMyHist()
  end
end

function Market.onItemBoxChecked(widget)

end

-- protocol callback functions

function Market.onMarketEnter(depotItems, offers, balance, vocation)
  if not loaded then
    initMarketItems()
    loaded = true
  end
  actualPage = 1
  itemDescTable:setText('')
  selectedItemOffer:setItemId(0)
  onlyoffer:disable()
  selectedItem:setItemId(0)
  updateBalance(balance)
  averagePrice = 0

  information.totalOffers = offers
  local player = g_game.getLocalPlayer()
  if player then
    information.player = player
  end
  if vocation == -1 then
    if player then
      information.vocation = player:getVocation()
    end
  else
    -- vocation must be compatible with < 950
    information.vocation = vocation
  end

  -- set list of depot items
  information.depotItems = depotItems

  -- update the items widget to match depot items
  if Market.isItemSelected() then
    local spriteId
    MarketProtocol.silent(true) -- disable protocol messages
    Market.refreshItemsWidget(spriteId)
    MarketProtocol.silent(false) -- enable protocol messages
  else
    Market.refreshItemsWidget()
  end


  if g_game.isOnline() then
    --marketWindow:lock()
    marketWindow:show()
	clearOffers()
	Market.refreshMyOffers()
    MarketProtocol.sendMarketBrowse(5000)
	LOADED = false
	Market.refreshMyHist()
  end
end

function refresh()
   	clearOffers()
	histTable:clearData()
	Market.refreshMyOffers()
    Market.refreshMyHist()
	LOADED = false
    MarketProtocol.sendMarketBrowse(5000)
end

function Market.onMarketLeave()
  Market.close(false)
end

function Market.onMarketDetail(itemId, descriptions, purchaseStats, saleStats)
  updateDetails(itemId, descriptions, purchaseStats, saleStats)
end

function Market.onMarketBrowse(offers)
  updateOffers(offers)
end

function Market.onMarketItemDesc(desc, itemId)
  updateDesc(desc, itemId)
end