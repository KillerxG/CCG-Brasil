-- Okami - Crinsom Helm
-- Scripted by Leonardofake
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Summon Procedure
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.ffilter,2)
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
    --Also treated as a FIRE monster while on the field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e0)
    --Avoid Destruction
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.desreptg)
    e2:SetOperation(s.desrepop)
    c:RegisterEffect(e2)
    --Send to GY
    local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end
--Fusion Summon Procedure 
function s.ffilter(c,fc,sumtype,tp)
    return c:IsSetCard(0x444,fc,sumtype,tp) and c:IsType(TYPE_MONSTER,fc,sumtype,tp)
end
function s.contactfil(tp)
    return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
    Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
    return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
 --Avoid Destruction
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:GetDefense()>=750 end
    return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:UpdateDefense(-750,RESET_EVENT+RESETS_STANDARD)
    c:UpdateAttack(750,RESET_EVENT+RESETS_STANDARD)
end
--Send to GY
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsSpellTrap() and c:IsAbleToGrave() and c:IsCanBeEffectTarget(e)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,11,aux.dncheck,1,tp,aux.Stringid(id,2))
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)
	end
end