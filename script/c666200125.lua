--Cryostasis of Noct Frost
--Scripted by Imp
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Level 1 WATER monsters become "Noct Frost" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0)
	e1:SetTarget(function(_,c) return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(1) end)
	e1:SetValue(0x353)
	c:RegisterEffect(e1)
    --Treat Level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	--Return, then draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
--Treat Level
function s.spfilter(c)
	return c:IsSetCard(0x353) and c:IsType(TYPE_XYZ) and c:IsRankBelow(5)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabelObject():GetRank()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_XYZ_LEVEL)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(aux.TargetBoolFunction(s.xyzfilter))
    e3:SetValue(lv)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
	end
function s.xyzfilter(c)
	return c:IsSetCard(0x353) and c:IsType(TYPE_MONSTER)
end
--Return, then draw
function s.tdfilter(c,e)
	return c:IsSetCard(0x353) and c:IsMonster() and c:IsFaceup() and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc,e) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and aux.SelectUnselectGroup(g,e,tp,3,3,s.tdcheck,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.tdcheck,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	if #tg<=0 then return end
	Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
