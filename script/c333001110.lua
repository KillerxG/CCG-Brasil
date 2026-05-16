--Block Dragon Set
--Script fixed by KillerxG
local s,id=GetID()
function s.initial_effect(c)    
    --(1)Equip to a Rock
    aux.AddEquipProcedure(c,nil,s.equip_filter)    
    --(2)ATK/DEF Up
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(500)
    c:RegisterEffect(e2)    
    --(3)Treat equipped mosnter as "Minomushi Warrior"
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_ADD_CODE)
    e3:SetValue(46864967)
    e3:SetCondition(s.eqcon)
    c:RegisterEffect(e3)
    --(4)Effect Gain: Excavate 
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.quick_target)
    e4:SetOperation(s.quick_operation)
    --(4.1)Excavate
    local e_grant=Effect.CreateEffect(c)
    e_grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e_grant:SetRange(LOCATION_SZONE)
    e_grant:SetTargetRange(LOCATION_MZONE,0)
    e_grant:SetTarget(s.grant_filter)
    e_grant:SetLabelObject(e4)
    c:RegisterEffect(e_grant)
    --(5)Ritual Summon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetCountLimit(1,id+1)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_series={0x259}
--(1)Equip to a Rock
function s.equip_filter(c)
    return c:IsRace(RACE_ROCK)
end
 --(3)Treat equipped mosnter as "Minomushi Warrior"
function s.eqcon(e)
    return e:GetHandler():IsSetCard(0x259)
end
--(4)Effect Gain: Excavate 
function s.grant_filter(e,c)
    return c==e:GetHandler():GetEquipTarget() and (c:IsSetCard(0x259) or c:IsCode(46864967))
end
function s.quick_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) >= 5 end
end
function s.quick_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) < 5 then return end
    Duel.ConfirmDecktop(tp,5)
    local g = Duel.GetDecktopGroup(tp,5)
    if g:GetCount()~=5 then return end
    -- Filtra os cards "Minomushi" (Setcode 0x259)
    local mg=g:Filter(function(c) return (c:IsSetCard(0x259) or c:IsCode(46864967)) end, nil)
    -- Filtra os monstros Normais do Tipo Rocha
    local rg=g:Filter(function(c) return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_ROCK) end, nil)
    local sel1, sel2 = nil, nil
    if mg:GetCount()>0 and rg:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
        sel1 = mg:Select(tp,1,1,nil):GetFirst()
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
        sel2 = rg:Select(tp,1,1,nil):GetFirst()
        local addGroup = Group.FromCards(sel1, sel2)
        if addGroup:GetCount()>0 then
            Duel.SendtoHand(addGroup, nil, REASON_EFFECT)
            Duel.ConfirmCards(1-tp, addGroup)
            g:Sub(addGroup)
        end
    end
    Duel.SendtoGrave(g, REASON_EFFECT)
end
--(5)Ritual Summon
function s.spfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsRitualMonster() and (c:IsLevel(7) and c:IsRace(RACE_ROCK)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function s.tgfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()==LOCATION_SZONE and not c:IsReason(REASON_LOST_TARGET)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end