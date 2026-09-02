--
--Scripted by KillerxG
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")
function s.initial_effect(c)
	--Divine Hierarchy Rank 1
	DivineHierarchyMod.Register(c,1)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--(1)Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--(2)Excavate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(s.excavtg)
	e3:SetOperation(s.excavop)
	c:RegisterEffect(e3)
	--(3)Trigger RPG Event
	local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_RECOVER + CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.reccon)
    e4:SetTarget(s.rectg)
    e4:SetOperation(s.recop)
    c:RegisterEffect(e4)
	--(4)Trigger RPG Event v2
	local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
	--(5)Act Limit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_FZONE)
	e6:SetOperation(s.chainop)
	c:RegisterEffect(e6)
end
--(1)Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetDrawCount(tp)>0
end
function s.thfilter(c)
	return c:IsRace(RACE_YOKAI) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local dt=Duel.GetDrawCount(tp)
	if dt==0 then return false end
	_replace_count=1
	_replace_max=dt
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	e1:SetValue(0)
	Duel.RegisterEffect(e1,tp)
	if _replace_count>_replace_max or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--(2)Excavate
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.excavspfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_YOKAI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,5)
	local excavg=Duel.GetDecktopGroup(tp,5)
	local remaining_count=#excavg
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local g=excavg:Match(s.excavspfilter,nil,e,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.DisableShuffleCheck()
				remaining_count=remaining_count-1
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	if remaining_count>0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>remaining_count then
			Duel.MoveToDeckBottom(remaining_count,tp)
		end
		Duel.SortDeckbottom(tp,tp,remaining_count)
	end
end
--(3)Trigger RPG Event
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>=100
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,4000)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if Duel.Recover(tp,4000,REASON_EFFECT)>0 then
		local token = Duel.CreateToken(tp, 776000000)
        if token and Duel.SendtoHand(token, nil, REASON_EFFECT) > 0 then
            Duel.ConfirmCards(1 - tp, token)
            if Duel.GetTurnPlayer() == 1 - tp then
                Duel.SkipPhase(1 - tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1)
                Duel.SkipPhase(1 - tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
            end
        end
	end
end
--(4)Trigger RPG Event v2
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local token = Duel.CreateToken(tp, 776000000)    
    if token and Duel.SendtoHand(token, nil, REASON_EFFECT) > 0 then
        Duel.ConfirmCards(1 - tp, token)
    end    
    -- "...also for the rest of this turn, you take no battle or effect damage."
    local c = e:GetHandler()    
    -- 1. Zera o dano de batalha para você (tp)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1, 0)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(e1, tp)    
    -- 2. Zera o dano de efeito para você clonando a estrutura anterior
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(e2, tp)
end
--(5)Act Limit
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRace(RACE_YOKAI) and re:IsMonsterEffect() and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end