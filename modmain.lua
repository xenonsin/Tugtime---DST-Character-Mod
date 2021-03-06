-- This library function allows us to use a file in a specified location.
-- Allows use to call global environment variables without initializing them in our files.
modimport("libs/env.lua")

-- Actions Initialization.
use "data/actions/init"

-- Component Initialization.
use "data/components/init"

PrefabFiles = {
	"tugtime", "mask_one", "mask_two", "mask_three", "nightvision"
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/tugtime.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/tugtime.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/tugtime.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/tugtime.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/tugtime_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/tugtime_silho.xml" ),

    Asset( "IMAGE", "bigportraits/tugtime.tex" ),
    Asset( "ATLAS", "bigportraits/tugtime.xml" ),
	
	Asset( "IMAGE", "images/map_icons/tugtime.tex" ),
	Asset( "ATLAS", "images/map_icons/tugtime.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_tugtime.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_tugtime.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_tugtime.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_tugtime.xml" ),

}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.tugtime = "The Masked Shadow"
STRINGS.CHARACTER_NAMES.tugtime = "Tugtime"
STRINGS.CHARACTER_DESCRIPTIONS.tugtime = "*Cannot solve '1 + 1' without a mask\n*Not afraid of the dark\n*Loves staring at you because you are cute"
STRINGS.CHARACTER_QUOTES.tugtime = "\"Such is Life.\""

-- Custom speech strings
STRINGS.CHARACTERS.TUGTIME = require "speech_tugtime"

-- The character's name as appears in-game 
STRINGS.NAMES.TUGTIME = "Tugtime"

-- The default responses of examining the character
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TUGTIME = 
{
	GENERIC = "It's Tugtime!",
	ATTACKER = "That Tugtime looks shifty...",
	MURDERER = "Murderer!",
	REVIVER = "Tugtime, friend of ghosts.",
	GHOST = "Tugtime could use a heart.",
}

--Cursed Fuel
--GLOBAL.FUELTYPE.CURSED = "CURSED" 
--STRINGS.NAMES.CURSED_FUEL = "Cursed Fuel"
--GLOBAL.STRINGS.RECIPE_DESC.CURSED_FUEL = "Masks need fuel? Go figure."
--local Ingredient = GLOBAL.Ingredient 
--AddRecipe("cursed_fuel", {Ingredient("livinglog", 3)}, GLOBAL.RECIPETABS.MAGIC, GLOBAL.TECH.NONE, nil, nil, nil, nil, nil,
--"images/inventory/cursed_fuel.xml", "cursed_fuel.tex")

-- Surprised Mask
STRINGS.NAMES.MASK_ONE = "Surprised Mask"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MASK_ONE = "Surprise!"
GLOBAL.STRINGS.RECIPE_DESC.MASK_ONE = "Gives night light like other masks."	
local Ingredient = GLOBAL.Ingredient 
AddRecipe("mask_one", {Ingredient("livinglog", 4)}, GLOBAL.RECIPETABS.MAGIC, GLOBAL.TECH.NONE, nil, nil, nil, nil, nil,
"images/inventory/mask_one.xml", "mask_one.tex")

-- Happy Mask
STRINGS.NAMES.MASK_TWO = "Happy Mask"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MASK_TWO = "Smile!"
GLOBAL.STRINGS.RECIPE_DESC.MASK_TWO = "Auto loots."	
local Ingredient = GLOBAL.Ingredient 
AddRecipe("mask_two", {Ingredient("walrus_tusk", 2)}, GLOBAL.RECIPETABS.MAGIC, GLOBAL.TECH.NONE, nil, nil, nil, nil, nil,
"images/inventory/mask_two.xml", "mask_two.tex")

-- Sad Mask
STRINGS.NAMES.MASK_THREE = "Sad Mask"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MASK_THREE = "Aww..."
GLOBAL.STRINGS.RECIPE_DESC.MASK_THREE = " Adds sanity aura."	
local Ingredient = GLOBAL.Ingredient 
AddRecipe("mask_three", {Ingredient("bearger_fur", 2)}, GLOBAL.RECIPETABS.MAGIC, GLOBAL.TECH.NONE, nil, nil, nil, nil, nil,
"images/inventory/mask_three.xml", "mask_three.tex")

AddMinimapAtlas("images/map_icons/tugtime.xml")

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("tugtime", "NEUTRAL")

