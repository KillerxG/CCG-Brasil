-- Divine Hierarchy Test - Rank 1
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")

function s.initial_effect(c)
	DivineHierarchyMod.Register(c,1)
end