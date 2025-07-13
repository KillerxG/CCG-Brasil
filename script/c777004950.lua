--Everlasting Soul Scythe
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--(2)Redirect to banish
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,0xff)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rm2tg)
	c:RegisterEffect(e2)
	--(3)Force your opponent pays 800 LP Damage when the opponent Special Summons from the Extra Deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.lpcon)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
	--(4)Recycle
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e4:SetCountLimit(1,id)
	e4:SetCost(Cost.SelfBanish)
	e4:SetTarget(s.thdtg)
	e4:SetOperation(s.thdop)
	c:RegisterEffect(e4)
end
--(2)Redirect to banish
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(777004920)
end
function s.rmcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.rm2tg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
--(3)Force your opponent pays 800 LP Damage when the opponent Special Summons from the Extra Deck
function s.damfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(1-tp,800) then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.PayLPCost(1-tp,800)
	end
end
--(4)Recycle
function s.thdfilter(c,e)
	return (c:IsSetCard(0x258) and c:IsContinuousTrap() and not c:IsCode(id)) and (c:IsAbleToHand() or not c:IsForbidden())
		and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAbleToHand,nil)>=1
		and sg:FilterCount(Card.IsContinuousTrap,nil)>=1 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.thdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.thdfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,1))
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		if #hg==0 or Duel.SendtoHand(hg,nil,REASON_EFFECT)==0 then return end
		Duel.ConfirmCards(1-tp,hg)
		local dg=g-hg
		if #dg==0 then return end
		Duel.HintSelection(dg,true)
		Duel.SSet(tp,dg)
	end
end