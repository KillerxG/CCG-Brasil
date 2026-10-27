--Hallowferno Tombstone Soul
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	Pendulum.AddProcedure(c)
	--(1)Pendulum Effect
	--(1.1)Negate Spell/Trap or effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--(1.2)Change Scale
	local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1, id+1)
    e2:SetTarget(s.sctg)
    e2:SetOperation(s.scop)
    c:RegisterEffect(e2)
	--(2)Monster Effect
	--(2.1)Recycle it self then can recycle another
	local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_EXTRA)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.thcon3)
    e3:SetTarget(s.thtg3)
    e3:SetOperation(s.thop3)
    c:RegisterEffect(e3)
end
--(1.1)Negate Spell/Trap or effect
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsSpellTrapEffect() and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777006190),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
--(1.2)Change Scale
function s.scfilter(c,scale)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:HasLevel()
		and c:GetLevel()~=scale
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local scale=e:GetHandler():GetScale()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.scfilter(chkc,scale) end
	if chk==0 then return Duel.IsExistingTarget(s.scfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,scale) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.scfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,scale)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e)
		or not tc:IsFaceup() or not tc:HasLevel() then return end
	local lvl=tc:GetLevel()
	if lvl==c:GetScale() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetValue(lvl)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e2)
end
--(2.1)Recycle it self then can recycle another
function s.thcon3(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsFaceup()
end
function s.thtg3(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, tp, LOCATION_EXTRA)
end
function s.exfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thop3(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c, nil, REASON_EFFECT) > 0 and c:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, c)
        local g = Duel.GetMatchingGroup(s.exfilter, tp, LOCATION_EXTRA, 0, nil)
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 4)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)            
            local sg = g:Select(tp, 1, 1, nil)
            if #sg > 0 then
                Duel.SendtoHand(sg, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, sg)
            end
        end
    end
end