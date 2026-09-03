-- Divine Hierarchy Test - Rank 2
local s,id=GetID()
Duel.LoadScript("proc_divine_hierarchy_mod.lua")

function s.initial_effect(c)
	DivineHierarchyMod.Register(c,2)
	--Gain ATK when another monster you control is destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Reduce this card's ATK to increase its Hierarchy Rank
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.hrcost)
	e2:SetOperation(s.hrop)
	c:RegisterEffect(e2)
end

function s.atkfilter(c,tp,hc)
	return c~=hc and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.atkfilter,nil,tp,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,math.max(tc:GetBaseAttack(),0))
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not c:IsFaceup()
		or not tc or not tc:IsRelateToEffect(e) then return end
	local atk=math.max(tc:GetBaseAttack(),0)
	if atk>0 then
		c:UpdateAttack(atk,RESET_EVENT|RESETS_STANDARD,c)
	end
end

function s.hrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:GetAttack()>=3000 end
	c:UpdateAttack(-3000,RESET_EVENT|RESETS_STANDARD,c)
end

function s.hrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		DivineHierarchyMod.IncreaseRank(c,1,RESET_EVENT|RESETS_STANDARD)
	end
end
