--Gem-Knight Tanzanite
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--(1)Limit battle target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--(2)Prevent effect target
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atlimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--(2)Gemini status
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_GEMINI))
	e3:SetCode(EFFECT_GEMINI_STATUS)
	c:RegisterEffect(e3)
	--(3)Double this card's ATK
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
--Fusion Summon
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_GEM,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end
--(1)Limit battle target
--(2)Prevent effect target
function s.atkval(tp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,0x1047),tp,LOCATION_MZONE,0,nil)
	local _,val=g:GetMaxGroup(Card.GetAttack)
	return val
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1047) and c:GetAttack()<s.atkval(e:GetHandlerPlayer())
end
--(3)Double this card's ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:GetAttack()~=bc:GetBaseAttack()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE_CAL|RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,c:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--Double this card's ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end