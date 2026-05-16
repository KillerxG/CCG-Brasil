--Noctavius Hurricane
local s,id=GetID()
function s.initial_effect(c)
    -- Efeito 1: Destrói 1 Winged Beast da mão ou campo, depois destrói até 2 Spells/Traps
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.destg1)
    e1:SetOperation(s.desop1)
    c:RegisterEffect(e1)
    -- Efeito 2: Do GY, se controla Xyz Winged Beast, invoca Zumbi no oponente e anexa esta carta
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.xyzcon)
    e2:SetTarget(s.xyztg)
    e2:SetOperation(s.xyzop)
    c:RegisterEffect(e2)
	--provide an effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.destg1)
	e3:SetOperation(s.desop1)
	c:RegisterEffect(e3)
end
--e1
function s.wbfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsDestructable()
end

function s.stfilter(c)
    return c:IsSpellTrap() and c:IsDestructable()
end

function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.wbfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end

function s.desop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectMatchingCard(tp,s.wbfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
    if #g1==0 or Duel.Destroy(g1,REASON_EFFECT)==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
    if #g2>0 then
        Duel.Destroy(g2,REASON_EFFECT)
    end
end
--e2
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_WINGEDBEAST) and c:IsType(TYPE_XYZ)
end

function s.zombiefilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
end

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.zombiefilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.zombiefilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if #g>0 and xyz then
        Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
        if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
            Duel.BreakEffect()
            Duel.Overlay(xyz,Group.FromCards(c))
        end
    end
end
--e3
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOriginalSetCard()==0x758
end
