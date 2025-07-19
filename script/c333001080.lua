-- Gigastone Slasher
local s,id=GetID()
local SET_MINOMUSHI=0x259
local MINOMUSHI_WARRIOR_CODE=46864967

function s.initial_effect(c)
   c:EnableReviveLimit()  
    
    -- (B) Este card também é tratado como "Minomushi Warrior" enquanto estiver no campo ou no Cemitério.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_ADD_CODE)
    e5:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e5:SetValue(MINOMUSHI_WARRIOR_CODE)
    c:RegisterEffect(e5)
    
    -- (1) Efeito 1: Do hand – Mire 1 "Minomushi Warrior" no seu GY e descarte este card; Special Summon o alvo
    -- (Se o alvo for um Ritual Monster, ele é tratado como Ritual Summoned) e, na sua próxima Standby Phase, retorne-o para a mão.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg1)
    e1:SetCost(Cost.SelfDiscard)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    
    -- (2) Efeito 2 (Quick-Effect): Do hand – Special Summon 1 monstro Normal Rocha da sua mão; se fizer isto,
    -- ele ganha ATK e DEF iguais ao seu DEF e é destruído na sua próxima Standby Phase.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    
    -- (3) Efeito 3: Se este card for enviado ao GY por efeito de um card "Minomushi" ou for Special Summoned por efeito de um card "Minomushi":
    -- Até o End Phase, todos os monstros Rocha que você controla ganham 500 ATK e 200 DEF e todos os "Minomushi Warrior"
    -- ganham 200 ATK e 500 DEF para cada "Minomushi Warrior" (no campo ou GY).
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,id+200)
    e3:SetCondition(s.boost_con)
    e3:SetOperation(s.boost_op)
    c:RegisterEffect(e3)
    
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1,id+200)
    e4:SetCondition(s.boost_con)
    e4:SetOperation(s.boost_op)
    c:RegisterEffect(e4)
end
s.listed_names={46864967}
 --(1)Return card(s) sent to GY
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- (1) Efeito 1: Special Summon 1 "Minomushi Warrior" do GY, descartando este card,
-- e retorna o monstro para a mão na sua próxima Standby Phase.
function s.spfilter1(c,e,tp)
    return c:IsCode(MINOMUSHI_WARRIOR_CODE) and (c:IsCanBeSpecialSummoned(e,0,tp,true,false) or c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)) 
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.GetFirstTarget()
		if sc:IsRitualMonster() and Duel.SpecialSummonStep(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
			local reset_ct=(Duel.IsTurnPlayer(tp) or Duel.IsPhase(PHASE_STANDBY)) and 2 or 1
			--Shuffle it into the Deck during your opponent's next End Phase
			aux.DelayedOperation(sc,PHASE_STANDBY,id,e,tp,function(ag) Duel.SendtoHand(ag,tp,REASON_EFFECT) end,function() return Duel.IsTurnPlayer(tp) end,nil,reset_ct,aux.Stringid(id,4))
			Duel.SpecialSummonComplete()
		elseif sc and Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
			local reset_ct=(Duel.IsTurnPlayer(tp) or Duel.IsPhase(PHASE_STANDBY)) and 2 or 1
			--Shuffle it into the Deck during your opponent's next End Phase
			aux.DelayedOperation(sc,PHASE_STANDBY,id,e,tp,function(ag) Duel.SendtoHand(ag,tp,REASON_EFFECT) end,function() return Duel.IsTurnPlayer(tp) end,nil,reset_ct,aux.Stringid(id,4))
		Duel.SpecialSummonComplete()
	end
end
	---if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	--local attr,code=e:GetLabel()
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
--	local tc=GetFirst()
--	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
--		--Return it to the hand during the End Phase
--		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end,nil,0,1,aux.Stringid(id,1))
--	end
--	Duel.SpecialSummonComplete()
--	end

--------------------------------------------------------------------------------
-- (2) Efeito 2: Quick Effect – Special Summon 1 monstro Normal Rocha da sua mão;
-- ele ganha ATK/DEF iguais ao seu DEF e é destruído na próxima Standby Phase.
function s.sp2filter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sp2filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.SelectMatchingCard(tp,s.sp2filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
    if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    local def_val=tg:GetBaseDefense()
    -- Aumenta ATK e DEF iguais ao DEF atual
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(def_val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tg:RegisterEffect(e1)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(def_val)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tg:RegisterEffect(e2)
   	local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetOwnerPlayer(tp)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		e3:SetCountLimit(1)
		tg:RegisterEffect(e3)
	end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
--------------------------------------------------------------------------------
-- (3) Efeito 3: Aplica boosts aos monstros enquanto durar até o End Phase.
function s.boost_con(e,tp,eg,ep,ev,re,r,rp)
    return re and (re:GetHandler():IsSetCard(SET_MINOMUSHI) or re:GetHandler():IsCode(46864967)) and re:GetHandler()~=e:GetHandler()
end
function s.boost_op(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,MINOMUSHI_WARRIOR_CODE)
    if ct<=0 then return end
    -- Boost para todos os monstros do Tipo Rocha que você controla: +500 ATK, +200 DEF
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
    e1:SetValue(500)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
    e2:SetValue(200)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
    -- Boost para todos os "Minomushi Warrior" que você controla: +200 ATK, +500 DEF
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,MINOMUSHI_WARRIOR_CODE))
    e3:SetValue(200*ct)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(aux.TargetBoolFunction(Card.IsCode,MINOMUSHI_WARRIOR_CODE))
    e4:SetValue(500*ct)
    e4:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e4,tp)
end