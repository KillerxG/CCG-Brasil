-- Divine Hierarchy Test - Rank 2
--[[ Effects: 
	E0: Cannot be Normal Summoned/Set. This card's Divine Hierarchy Rank is 2.
	E1: 
	E2: 
	E3: 
	E4:
]]
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Divine Hierarchy 2
	DivineHierarchyMod.Register(c,2)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()