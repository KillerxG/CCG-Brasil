--Fatale Succubus - Eternal Lilith
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	--Fusion Summon
	Fusion.AddProcMix(c,true,true,777003750,777003710)
	--(1)Take Control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ctrltg)
	e1:SetOperation(s.ctrlop)
	c:RegisterEffect(e1)
	--(2)Cannot be destroyed by battle or card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	--(3)Special Summon 1 Irya or 1 Lilith monster from your GY and place the other on the bottom of the Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e4:SetCost(Cost.SelfBanish)
	e4:SetTarget(s.sptdtg)
	e4:SetOperation(s.sptdop)
	c:RegisterEffect(e4)
end
s.listed_names={777003750,777003710}
--(1)Take Control
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end
--(2)Cannot be destroyed by battle or card effects
function s.indcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)
end
--(3)Special Summon 1 Irya or 1 Lilith monster from your GY and place the other on the bottom of the Deck
function s.sptdfilter(c,e,tp)
	return (c:IsCode(777003750) or c:IsCode(777003710)) and (c:IsCanBeSpecialSummoned(e,0,tp,true,true) or c:IsAbleToDeck())
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,777003750) and sg:IsExists(Card.IsCode,1,nil,777003710)
		and sg:IsExists(s.spchk,1,nil,e,tp,sg)
end
function s.spchk(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) and (#sg==1 or sg:IsExists(Card.IsAbleToDeck,1,c))
end
function s.sptdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.sptdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,0)
end
function s.sptdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if (#tg==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=tg:FilterSelect(tp,s.spchk,1,1,nil,e,tp,tg)
	if #sg>0 and Duel.SpecialSummon(sg,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)>0 and #tg==2 then
		local dg=tg-sg
		Duel.HintSelection(dg)
		Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end