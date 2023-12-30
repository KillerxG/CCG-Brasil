--Grave Fusion
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Fusion summon 1 fusion monster by banishing monsters from GY, face-up, as material
	local e1=Fusion.CreateSummonEff(c,nil,s.matfilter,s.fextra,s.extraop,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
end
--(1)Fusion summon 1 fusion monster by banishing monsters from GY, face-up, as material
function s.matfilter(c,e,tp,check_or_run)
	return aux.SpElimFilter(c) and c:IsAbleToRemove(tp,POS_FACEUP)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		--
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
end