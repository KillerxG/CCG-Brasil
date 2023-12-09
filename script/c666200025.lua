--Cheat Code Kuraishoto
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x352),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Banish 
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e0:SetCountLimit(1,id)
	e0:SetCondition(function(_,tp,_,ep) return ep==1-tp end)
	e0:SetTarget(s.tmprmtg)
	e0:SetOperation(s.tmprmop)
	c:RegisterEffect(e0)
end
--Banish 
function s.exmfilter(c)
	return c:GetSequence()>=5
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end
function s.tmprmfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
function s.tmprmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tmprmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,2,tp,0)
end
function s.tmprmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==2 then
		aux.RemoveUntil(tg,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp)
   if Duel.IsExistingMatchingCard(s.exmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
end
end