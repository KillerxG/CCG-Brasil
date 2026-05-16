--West Royal Dragon Legacy
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rittg)
    e1:SetOperation(s.ritop)
    c:RegisterEffect(e1)
	--(2)Grant effect to "Weast Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.refcon)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_names={777003710,id}
--(1)Ritual Summon
function s.matfilter(c)
    return c:IsMonster() and c:GetLevel()>0 and c:IsAbleToRemove()
end
function s.ritfilter(c, e, tp, mg)
    if not (c:IsRace(RACE_DRAGON|RACE_FIEND) and c:IsType(TYPE_RITUAL) and c:IsMonster()) then return false end
    if not c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true) then return false end
    return mg:CheckWithSumGreater(Card.GetLevel, c:GetLevel())
end
function s.rittg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil)
        return Duel.IsExistingMatchingCard(s.ritfilter, tp, LOCATION_HAND, 0, 1, nil, e, tp, mg)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, PLAYER_ALL, LOCATION_GRAVE)
end
function s.ritop(e, tp, eg, ep, ev, re, r, rp)
    local mg = Duel.GetMatchingGroup(s.matfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tg = Duel.SelectMatchingCard(tp, s.ritfilter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp, mg)
    local tc = tg:GetFirst()
    if tc then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
        local mat = mg:SelectWithSumGreater(tp, Card.GetLevel, tc:GetLevel())
        if #mat > 0 then
            tc:SetMaterial(mat)
            Duel.Remove(mat, POS_FACEUP, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end
--(2)Grant effect to "Weast Royal Dragon - Irya"
function s.eftg(e,c)
    return c:IsFaceup() and c:IsCode(777003710) and c:IsType(TYPE_EFFECT)
end
function s.refcon(e,re,val,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end