--Rockslash Confront
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Destroy an opponent's monster that declares an attack and inflict damage equal to its original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetTarget(s.destg1)
	e1:SetOperation(s.desop1)
	c:RegisterEffect(e1)
	--(2)Destroy an opponent's monster that activates an effect on the field and inflict damage equal to its original ATK
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.descond)
	e2:SetTarget(s.destg2)
	e2:SetOperation(s.desop2)
	c:RegisterEffect(e2)
	--(3)Can be activated from the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
end
--(1)Destroy an opponent's monster that declares an attack and inflict damage equal to its original ATK
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,tp,0)
	if at:GetBaseAttack()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,at:GetBaseAttack())
	end
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if not at:IsRelateToBattle() or Duel.Destroy(at,REASON_EFFECT)==0 then return end
	local atk=at:GetBaseAttack()
	if atk>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
--(2)Destroy an opponent's monster that activates an effect on the field and inflict damage equal to its original ATK
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_MZONE
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsDestructable() and rc:IsRelateToEffect(re) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,tp,0)
	if rc:GetBaseAttack()>0 then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,rc:GetBaseAttack())
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	if not rc:IsRelateToEffect(re) or Duel.Destroy(rc,REASON_EFFECT)==0 then return end
	local atk=rc:GetBaseAttack()
	if atk>0 then
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
--(3)Can be activated from the hand
function s.actfilter(c)
	return c:IsFaceup() and c:IsCode(777002010)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end