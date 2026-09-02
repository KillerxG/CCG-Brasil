--
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Synchro Summon
	Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--(1)Place opponent's monster in their S/T Zone
	local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetCondition(aux.bdocon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
	--(2)Draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.drwcon)
	e2:SetTarget(s.drwtg)
	e2:SetOperation(s.drwop)
	c:RegisterEffect(e2)
end
s.material={777006250}
--Synchro Summon
function s.tunerfilter(c,lc,stype,tp)
	return c:IsSummonCode(lc,stype,tp,777006250) or c:IsHasEffect(777006280)
end
--(1)Place opponent's monster in their S/T Zone
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetFieldGroupCount(tp, 0, LOCATION_EXTRA) >= 3 
        and Duel.GetLocationCount(1 - tp, LOCATION_SZONE) > 0 end
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFieldGroupCount(tp, 0, LOCATION_EXTRA) < 3 or Duel.GetLocationCount(1 - tp, LOCATION_SZONE) <= 0 then return end    
    local ed = Duel.GetFieldGroup(tp, 0, LOCATION_EXTRA)
    local g = ed:RandomSelect(tp, 3)
    Duel.ConfirmCards(tp, g)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
    local tc = g:Select(tp, 1, 1, nil):GetFirst()    
    if tc then
        if Duel.MoveToField(tc, tp, 1 - tp, LOCATION_SZONE, POS_FACEUP, true) then            
            -- Imediatamente aplica o status de Magia Contínua nela
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
            tc:RegisterEffect(e1)
        end
    end
end
--(2)Draw 1 card
function s.drwconfilter(c,opp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsControler(opp) and c:IsReason(REASON_EFFECT)
end
function s.drwcon(e,tp,eg,ep,ev,re,r,rp)
	return re and eg:IsExists(s.drwconfilter,1,nil,1-tp)
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
