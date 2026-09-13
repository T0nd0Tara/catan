package common


BuyingItem :: enum {
	SETTELMENT = 1,
	CITY,
	ROAD,
	CARD,
}
costs: [BuyingItem][dynamic; 5]ResourceType = {
	.ROAD       = {.WOOD, .CLAY },
	.SETTELMENT = {.WOOD, .CLAY, .SHEEP, .WHEAT },
	.CITY       = {.STONE, .STONE, .STONE, .WHEAT, .WHEAT},
	.CARD       = {.STONE, .SHEEP, .WHEAT },
}
