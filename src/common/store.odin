package common


BuyingItem :: enum {
	SETTELMENT = 1,
	CITY,
	ROAD,
	CARD,
}
costs: [BuyingItem][5]ResourceType = {
	.ROAD       = {.WOOD, .CLAY, nil, nil, nil},
	.SETTELMENT = {.WOOD, .CLAY, .SHEEP, .WHEAT, nil},
	.CITY       = {.STONE, .STONE, .STONE, .WHEAT, .WHEAT},
	.CARD       = {.STONE, .SHEEP, .WHEAT, nil, nil},
}
