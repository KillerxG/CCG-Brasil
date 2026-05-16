--Bestial Baron
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Xyz summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),4,2)
	    -- Special Summon self from Extra Deck if conditions are met
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Effect: Equip from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.eqcost)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end
-- Condição: Um monstro FIRE com equips ataca
function s.monfilter(c,tp)
    return c:IsControler(tp) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:GetEquipCount()>=2
        and (c:GetBaseAttack()<=1000 or c:GetBaseDefense()<=1000)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local atk=Duel.GetAttacker()
    return atk and s.monfilter(atk,tp)
end

-- Filtro para os equips válidos
function s.eqfilter(c,ec)
    return c:IsFaceup()
        and (c:IsSetCard(0x102c) or (c:IsType(TYPE_EQUIP) and c:IsSpell()))
        and c:GetEquipTarget()==ec
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local atk=Duel.GetAttacker()
    if chk==0 then
        return Duel.GetLocationCountFromEx(tp,tp,nil,e:GetHandler())>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_SZONE,0,2,nil,atk)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_SZONE,0,2,2,nil,atk)
    if #g==2 then
        g:KeepAlive()
        e:SetLabelObject(g)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=e:GetLabelObject()
    if not g or #g~=2 then return end
    local atk=Duel.GetAttacker()
    if not atk or not s.monfilter(atk,tp) then return end
    if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return end

    if Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.BreakEffect()
        c:SetMaterial(g)
        Duel.Overlay(c,g)
        c:CompleteProcedure()
    end
end
-- Cost: Detach 1 material
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- GY target: any monster, not forbidden (for equipping)
function s.gyfilter(c)
    return not c:IsForbidden()
end

-- Monster target: face-up, not Link, Warrior or FIRE
function s.monfilter(c)
    return c:IsFaceup() and not c:IsType(TYPE_LINK)
        and (c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE))
end

-- Target selection
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
            and Duel.IsExistingTarget(s.monfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g1=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g2=Duel.SelectTarget(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
end

-- Operation: Equip from GY to selected monster
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if #tg~=2 then return end
    local eqcard=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
    local target=tg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
    if not eqcard or not target or not eqcard:IsRelateToEffect(e) or not target:IsRelateToEffect(e)
        or not target:IsFaceup() then return end

    if not Duel.Equip(tp,eqcard,target,false) then return end

    -- Equip limit: only to this monster
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,c) return c==target end)
    eqcard:RegisterEffect(e1)

    -- E1: Negate & destroy when opponent activates an effect
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    eqcard:RegisterEffect(e2)
end

-- Condition: opponent activated a card or effect that can be negated
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainNegatable(ev)
end

-- Cost: send this card to GY
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

-- Target: the card on the chain
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

-- Operation: negate and destroy
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end