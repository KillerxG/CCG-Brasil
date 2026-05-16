--Speed Spell - Ritual Summon
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Ritual Summon
	local e1=Ritual.CreateProc(c,RITPROC_GREATER,aux.FilterBoolFunction(Card.IsType,TYPE_RITUAL),nil,1057)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
--(1)Ritual Summon
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	return tc and tc:GetCounter(0x91)>1
end
