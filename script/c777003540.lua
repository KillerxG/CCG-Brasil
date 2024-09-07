--U.P.E. Landing Point
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--(1)ATK Up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tg)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--(2)Fusion Summon
	local e2=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.fuscon)
	c:RegisterEffect(e2)
end
--(3.2.3)ATK Up
function s.tg(e,c)
	return c:IsSetCard(0x274)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x274) and c:IsOriginalType(TYPE_MONSTER) and c:IsLocation(LOCATION_SZONE)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_SZONE,0,nil)*400
end
--(2)Fusion Summon
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,0x274)
end
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.NOT(Card.IsSummonPlayer),1,nil,tp)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.NecroValleyFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_MZONE,LOCATION_MZONE,nil),s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_PUBLIC)
end