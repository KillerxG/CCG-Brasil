-- Okami - Lechku and Nechku
-- Scripted by Leonardofake & Imp
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x444),4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--Maintain
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1)
	e0:SetCondition(s.mtcon)
	e0:SetOperation(s.mtop)
	c:RegisterEffect(e0)
	--Negate attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(0x444,lc,SUMMON_TYPE_XYZ,tp) 
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
--Maintain
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
--Negate attack
function s.filter(c)
    return c:IsFaceup() and (c:IsCode(444000000) or c:IsCode(444000050))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return tp~=Duel.GetTurnPlayer()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateAttack() then
        local tc=Duel.GetAttacker()
        if tc and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) then
            local dam=tc:GetAttack()/2
            Duel.Damage(1-tp,dam,REASON_EFFECT)
        end
    end
end

