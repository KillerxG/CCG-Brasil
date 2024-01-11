-- Okami - Orochi
-- Scripted by Leonardofake & Imp
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x444),6,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
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
	--Inflict 200 Damage to the opponent when their card or effect is activated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
--Xyz Summon
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x444,lc,SUMMON_TYPE_XYZ,tp) and c:GetRank()==4
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
--Inflict 200 Damage to the opponent when their card or effect is activated
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(444000000) or c:IsCode(444000050))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET|RESET_CHAIN,0,1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and c:HasFlagEffect(id)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,400,REASON_EFFECT)
	else
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-tp,200,REASON_EFFECT)
	end
end