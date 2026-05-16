--HI3rd, Ai Hyperion
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Change att and Special this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rvtg)
	e1:SetOperation(s.rvop)
	c:RegisterEffect(e1)
	--(2)Switch Locations
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
	--(3)Fusion Summon using materials from hand or field, including a "HI3rd" monster
	local params = {nil,nil,function(e,tp,mg) return nil,s.fcheck end}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
end
--(1)Change att and Special this card
function s.exfilter1(c,tp)
	return c:IsType(TYPE_FUSION) and not c:IsPublic() and Duel.IsExistingTarget(s.rvfilter2,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.exfilter2(c,oc)
	return c:IsType(TYPE_FUSION) and not c:IsPublic() and not c:IsAttribute(oc:GetAttribute())
end
function s.rvfilter1(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.exfilter2,tp,LOCATION_EXTRA,0,1,nil,c)
end
function s.rvfilter2(c,oc)
	return c:IsFaceup() and not c:IsAttribute(oc:GetAttribute())
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.rvfilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter1,tp,LOCATION_EXTRA,0,1,nil,tp) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.rvfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.exfilter2,tp,LOCATION_EXTRA,0,1,1,nil,tc)
		if #g>0 and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			local oc=g:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(oc:GetAttribute())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
		end
	end
end
--(2)Switch Locations
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x315b)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	if #g==0 then return end
	local swap_g=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,1))
	if #swap_g~=2 then return end
	Duel.HintSelection(swap_g,true)
	Duel.SwapSequence(swap_g:GetFirst(),swap_g:GetNext())
end
--(3)Fusion Summon using materials from hand or field, including a "HI3rd" monster
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x315)
end