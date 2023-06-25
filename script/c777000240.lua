--Azur Lane Confront
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
--(1)Negate
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x283) and c:IsType(TYPE_XYZ)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        local tc=eg:GetFirst()
        local seq=tc:GetSequence()
        local zone=0
        if tc:IsLocation(LOCATION_MZONE) then
            zone=0x10000
            while seq>0 do
                zone=zone*2
                seq=seq-1
            end
        elseif tc:IsLocation(LOCATION_SZONE) or tc:GetLocation()==0x0 then
            if seq<5 then--and (not tc:IsType(TYPE_PENDULUM) or not (seq==0 or seq==4)) then
                zone=0x1000000
                while seq>0 do
                    zone=zone*2
                    seq=seq-1
                end
            end
        end
		if Duel.Destroy(eg,REASON_EFFECT) and zone>0 then
            e:SetLabel(zone)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_DISABLE_FIELD)
            e1:SetOperation(s.disop)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e1:SetLabel(e:GetLabel())
            Duel.RegisterEffect(e1,tp)
        end
	end
end
function s.disop(e,tp)
    return e:GetLabel()
end