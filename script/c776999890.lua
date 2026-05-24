-- Divine Hierarchy Test - Rank 2
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")

function s.initial_effect(c)
	DivineHierarchyMod.Register(c,2)
end