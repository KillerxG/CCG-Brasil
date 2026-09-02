--
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	Pendulum.AddProcedure(c)
	--(1)Pendulum Effect
	--(1.1)Negate Monster effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.ngcon)
	e1:SetTarget(s.ngtg)
	e1:SetOperation(s.ngop)
	c:RegisterEffect(e1)
	--(1.2)Draw
	local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.drcost)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
	--(2)Monster Effect
	--(2.1)Recycle then Special Summon itself
	local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1, id + 2)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
--(1.1)Negate Monster effect
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsMonsterEffect()
		and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777006190),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--(1.2)Draw
function s.drfilter(c, tp)
    if not (c:IsRace(RACE_YOKAI) and c:HasLevel() and c:GetLevel() >= 4 and not c:IsPublic()) then return false end
    local draws = math.floor(c:GetLevel() / 4)
    return Duel.IsPlayerCanDraw(tp, draws)
end
function s.drcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.drfilter, tp, LOCATION_HAND, 0, 1, nil, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.drfilter, tp, LOCATION_HAND, 0, 1, 1, nil, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    local draws = math.floor(g:GetFirst():GetLevel() / 4)
    e:SetLabel(draws)
end
function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1) 
end
function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local draws = e:GetLabel()
    if draws > 0 then
        Duel.Draw(p, draws, REASON_EFFECT)
    end
end
--(2.1)Recycle then Special Summon itself
function s.thfilter(c)
    return c:IsFaceup() and (c:IsRace(RACE_YOKAI) or c:IsCode(777006270)) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end    
    local c = e:GetHandler()
    if chk == 0 then 
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
            and Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) 
    end    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)    
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget() 
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, tc)
        if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end