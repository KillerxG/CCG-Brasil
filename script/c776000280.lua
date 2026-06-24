--Loki, Lord of the Aesir
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)	
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--Cannot be Normal Summoned/Set
	c:EnableReviveLimit()
	--You can only control 1
	c:SetUniqueOnField(1,0,id)
	--Synchro summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),2,99)
	--(2)Negate activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--(3)Flag registration
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.flgop)
	c:RegisterEffect(e2)
	--(3.1)Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	
end
--(2)Negate activation
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
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
--(3)Flag registration
function s.flgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if rp~=tp and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and (pos&POS_FACEUP)~=0 then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
--(3.1)Special Summon itself
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end        
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, PLAYER_ALL, LOCATION_GRAVE)
end
function s.thfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local g = Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_GRAVE, LOCATION_GRAVE, nil)  
        if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
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
--(5)Self Bomb
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
end
function s.gycon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetTurnPlayer()==tp 
        and c:GetFlagEffect(id)>0 
        and c:GetFlagEffectLabel(id)~=Duel.GetTurnCount()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        if c:IsAbleToGrave() then
            Duel.SendtoGrave(c,REASON_EFFECT)
        else
            Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
        end
    end
end