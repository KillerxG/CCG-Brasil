--Frost Pawn Psychessman
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Move 1 monster to an adjacent zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.SelfDiscardCost)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	--(2)Special Summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetValue(s.hspval)
	c:RegisterEffect(e2)
end
--(1)Move 1 monster to an adjacent zone
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c~=chkc and chkc:IsLocation(LOCATION_MZONE) and chkc:CheckAdjacent() end
	if chk==0 then return Duel.IsExistingTarget(Card.CheckAdjacent,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.CheckAdjacent,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		tc:MoveAdjacent(tp)
	end
end
--(2)Special Summon itself
s.sclawfilter=aux.FaceupFilter(Card.IsSetCard,0x262)
function s.hspval(e,c)
	local zone=0
	local left_right=0
	local tp=c:GetControler()
	local lg=Duel.GetMatchingGroup(s.sclawfilter,tp,LOCATION_MZONE,0,nil)
	for tc in lg:Iter() do
		left_right=tc:IsInMainMZone() and 1 or 0
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,left_right,left_right,tp))
	end
	return 0,zone&0x1f
end