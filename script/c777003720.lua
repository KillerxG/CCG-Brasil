--West Royal Dragon Throne
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Ritual Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.spcost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
	--(2)Grant effect to "West Royal Dragon - Irya"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--(2.1)Grant effect to "West Royal Dragon - Irya"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.indval)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
s.listed_names={777003710,id}
--(1)Ritual Summon
function s.tkcostfilter(c)
	return c:IsRitualMonster() and c:IsSetCard(0x288) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tkcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.tkcostfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.lvfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(6)
end
function s.ritfilter(c, e, tp)
    return c:IsSetCard(0x288) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_RITUAL, tp, false, true)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local deck_count = Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
        local lv6_count = Duel.GetMatchingGroupCount(s.lvfilter, tp, LOCATION_DECK, 0, nil)
        return deck_count > 0 and lv6_count >= 2
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0)
    if ct == 0 then return end    
    local exc = Group.CreateGroup()
    local confirmed = 0    
    for i = 1, ct do
        local g = Duel.GetDecktopGroup(tp, i)
        local tc = g:Filter(function(c, grp) return not grp:IsContains(c) end, nil, exc):GetFirst()
        if not tc then break end        
        exc:AddCard(tc)        
        if tc:IsType(TYPE_MONSTER) and tc:IsLevelAbove(6) then
            confirmed = confirmed + 1
        end        
        if confirmed == 2 then break end
    end
    Duel.ConfirmDecktop(tp, #exc)    
    local mat = Group.CreateGroup()    
    if confirmed == 2 then
        local matg = exc:Filter(Card.IsType, nil, TYPE_MONSTER)
        local ritg = Duel.GetMatchingGroup(s.ritfilter, tp, LOCATION_HAND, 0, nil, e, tp)
        local sum_possible = false
        if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
            for rc in aux.Next(ritg) do
                if matg:CheckWithSumGreater(Card.GetLevel, rc:GetLevel()) then
                    sum_possible = true
                    break
                end
            end
        end
        if sum_possible and Duel.SelectYesNo(tp, aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local rc = ritg:FilterSelect(tp, function(c, mg) return mg:CheckWithSumGreater(Card.GetLevel, c:GetLevel()) end, 1, 1, nil, matg):GetFirst()
            if rc then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
                mat = matg:SelectWithSumGreater(tp, Card.GetLevel, rc:GetLevel())
                rc:SetMaterial(mat)
                Duel.SendtoGrave(mat, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL)
                Duel.BreakEffect()
                Duel.SpecialSummon(rc, SUMMON_TYPE_RITUAL, tp, tp, false, true, POS_FACEUP)
                rc:CompleteProcedure()
            end
        end
    end
    exc:Sub(mat)
    if #exc > 0 then
        Duel.SendtoDeck(exc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end
--(2)Grant effect to "West Royal Dragon - Irya"
function s.eftg(e,c)
    return c:IsFaceup() and c:IsCode(777003710) and c:IsType(TYPE_EFFECT)
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end