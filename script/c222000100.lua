-- Prysm Beast - Aurora Castle of the Glacial Lands
-- ID 222000100 | Prysm Beast setcode: 0x100b
-- Field Spell. All thresholds count "Prysm Beast" cards in your Spell/Trap Zones.
local s,id=GetID()
local SET_PRYSM=0x100b

function s.initial_effect(c)
    -- Field Spell activation
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- 1+: This card cannot be destroyed by card effects.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(function(e,re,rp) return s.count(e:GetHandlerPlayer())>=1 end)
    c:RegisterEffect(e1)

    -- 2+: Once per turn (either turn), optionally halve battle damage taken.
    -- Choice is made before damage calculation; reduction takes effect at
    -- EVENT_PRE_BATTLE_DAMAGE, where the engine permits changing battle damage.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    -- 3+: Respond to the activation of a Spell/Trap Card.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- 4+: Once per turn during your Main Phase, draw 1.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.drawcon)
    e4:SetTarget(s.drawtg)
    e4:SetOperation(s.drawop)
    c:RegisterEffect(e4)

    -- 5+: Once per turn during your Main Phase, Special Summon a "Prysm Beast"
    -- monster card currently in your Spell/Trap Zone.
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end
s.listed_series={SET_PRYSM}

function s.count(tp)
    -- Count face-up Prysm Beast cards in the Spell/Trap Zones.
    -- Include our own Field Spell exactly once, even on engine builds
    -- where LOCATION_SZONE excludes the dedicated Field Zone.
    -- Set (face-down) cards never count.
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsFaceup() and c:IsSetCard(SET_PRYSM)
    end,tp,LOCATION_SZONE,0,nil)
    local ct=#g
    local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
    if fc and fc:IsFaceup() and fc:IsSetCard(SET_PRYSM)
        and not g:IsContains(fc) then
        ct=ct+1
    end
    return ct
end
function s.valid(e,n)
    return e:GetHandler():IsFaceup() and e:GetHandler():IsLocation(LOCATION_FZONE)
        and s.count(e:GetHandlerPlayer())>=n
end

-- Battle damage reduction.
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return s.valid(e,2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    if not s.valid(e,2) then return end
    local eff=Effect.CreateEffect(e:GetHandler())
    eff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    eff:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    eff:SetLabel(tp)
    eff:SetOperation(s.halfdamage)
    eff:SetReset(RESET_PHASE|PHASE_DAMAGE)
    Duel.RegisterEffect(eff,tp)
end
function s.halfdamage(e,tp,eg,ep,ev,re,r,rp)
    local player=e:GetLabel()
    -- Must still meet the 2+ threshold when the damage is calculated.
    if s.count(player)<2 then return end
    local damage=Duel.GetBattleDamage(player)
    if damage>0 then Duel.ChangeBattleDamage(player,math.floor(damage/2)) end
    e:Reset()
end

-- Spell/Trap activation negate: no once-per-turn restriction.
function s.sendfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_PRYSM)
        and c:IsAbleToGraveAsCost()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return s.valid(e,3) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
        and re:GetHandler():IsSpellTrap() and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if not s.valid(e,3) then return end
    if Duel.NegateActivation(ev) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- Draw.
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
    return s.valid(e,4)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    if s.valid(e,4) then Duel.Draw(tp,1,REASON_EFFECT) end
end

-- Summon only monster cards; a Spell/Trap cannot normally be Special Summoned.
function s.spfilter(c,e,tp)
    return c:IsFaceup() and c:IsSetCard(SET_PRYSM)
        and (c:GetOriginalType()&TYPE_MONSTER)~=0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return s.valid(e,5)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE)
        and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not s.valid(e,5) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.spfilter(tc,e,tp) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
