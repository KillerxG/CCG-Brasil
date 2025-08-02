--Attacker of the Team fins
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    -- E2: Gain ATK and extra attack when Ritual Summoned or declares attack vs monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.atktg)
    e1:SetCondition(s.atkcon1)
	e1:SetOperation(s.atkop1)
	c:RegisterEffect(e1)

    local e2=e1:Clone()
	e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(s.atkcon2)
	e2:SetOperation(s.atkop2)
    c:RegisterEffect(e2)

    -- E3: Recycle from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCondition(s.reccon)
    e3:SetTarget(s.rectg)
    e3:SetOperation(s.recop)
    e3:SetCountLimit(1,id)
    c:RegisterEffect(e3)
end
s.listed_names={333001300}
-- E2 Condition: Ritual Summon
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- E2 Condition: Attack declared against monster
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=c:GetBattleTarget()
    return tc and tc:IsControler(1-tp)
end

-- E2 Target
function s.tgfilter(c)
    return c:IsOnField()
end
function s.sendfilter(c)
    return c:IsAttribute(ATTRIBUTE_WATER) and c:IsMonster() and c:IsAbleToGrave()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then
            return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end
-- E2 Operation
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
		    local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil)
    local sc=g:GetFirst()
    if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local atk=sc:GetLevel()*100
        -- Gain ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local seq=e:GetLabel()
	    local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil)
    local sc=g:GetFirst()
    if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local atk=sc:GetLevel()*100
			Duel.ChainAttack()
        -- Gain ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
-- E3 Condition
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_EFFECT)
end
function s.fieldmonfilter(c)
    return c:IsMonster() and c:IsAbleToHand()
end
function s.finsgyfilter(c)
    return c:IsSetCard(0x1f1) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.fieldmonfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.IsExistingTarget(s.finsgyfilter,tp,LOCATION_GRAVE,0,1,nil)
            and c:IsAbleToHand()
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g1=Duel.SelectTarget(tp,s.fieldmonfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g2=Duel.SelectTarget(tp,s.finsgyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1+g2+c,3,0,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    if #g<2 or not c:IsRelateToEffect(e) then return end
    g:AddCard(c)
    Duel.SendtoHand(g,nil,REASON_EFFECT)
end
