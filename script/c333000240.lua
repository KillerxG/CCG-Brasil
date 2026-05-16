--Aerial Feather Tempo
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Fusion Summon
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINGEDBEAST),aux.FALSE,s.fextra,Fusion.ShuffleMaterial)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
--(1)Fusion Summon
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)
end