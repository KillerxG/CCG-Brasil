--Raviel, Lord of Phantasms
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,id)
	--(1)Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
	--(3)Unaffected by your opponent's activated Spell/Trap effects and by activated effects from opponent's Link monsters and monsters whose original Level/Rank is lower than this card's current Level
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	--(4)Special Summon Tokens
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.tkcon)
	e3:SetTarget(s.tktg)
	e3:SetOperation(s.tkop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.tkcon)
	c:RegisterEffect(e4)
	--(5)Your opponent cannot activate cards or effects during the Battle Phase
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(s.actcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--(6)ATK Up
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e6:SetCountLimit(1)
	e6:SetCondition(s.atkcon)
	e6:SetCost(s.atkcost)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
end
s.listed_names={776000160}
--(2)Special Summon
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.TRUE,3,false,3,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,3,3,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
--(3)Unaffected by your opponent's activated Spell/Trap effects and by activated effects from opponent's Link monsters and monsters whose original Level/Rank is lower than this card's current Level
function s.immval(e,te)
	if not (te:GetOwnerPlayer()~=e:GetHandlerPlayer()) then return false end
	if te:IsSpellTrapEffect() then return true end
	local tc=te:GetHandler()
	local lv=e:GetHandler():GetLevel()
	if tc:HasLevel() then
		return tc:GetOriginalLevel()<10
	elseif tc:HasRank() then
		return tc:GetOriginalRank()<14
	elseif tc:IsLinkMonster() then
		return tc:IsLinkBelow(14)
	end
	return false
end
--(4)Special Summon Tokens
function s.filter(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and not c:IsSummonPlayer(tp)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e,tp)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,776000005,0x317,TYPES_TOKEN,2000,2000,4,RACE_ZOMBIE,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,776000005)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(5)Your opponent cannot activate cards or effects during the Battle Phase
function s.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return Duel.IsBattlePhase()
end
--(6)ATK Up
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
function s.atkfilter(c)
	return c:GetTextAttack()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.atkfilter,1,false,nil,c) end
	local g=Duel.SelectReleaseGroupCost(tp,s.atkfilter,1,1,false,nil,c)
	local atk=g:GetFirst():GetTextAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	Duel.Release(g,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end