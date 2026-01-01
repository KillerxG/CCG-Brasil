--Earthbound Mystic Linewalker
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Double Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(s.condition)
	c:RegisterEffect(e1)
	--(2)Extra Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1021))
	c:RegisterEffect(e2)
	--(3)Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--(3)Grant effect when used as tribute for "Earthbound Immortal" Monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.efcon)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
	--(4)Disable your "Earthbound Immortal"
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.discon)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1021))
	c:RegisterEffect(e5)
end
--(1)Double Tribute
function s.condition(e,c)
	return c:IsSetCard(0x1021)
end
--(3)Special Summon itself
function s.cffilter(c)
	return c:IsSetCard(0x1021) and not c:IsPublic()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.cffilter,tp,LOCATION_HAND,0,e:GetHandler())
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.GetMatchingGroup(s.cffilter,tp,LOCATION_HAND,0,e:GetHandler())
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_CONFIRM,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	g:DeleteGroup()
end
--(3)Grant effect when used as tribute for "Earthbound Immortal" Monster
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsSetCard(0x1021) and r==REASON_SUMMON
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()	
	--Unaffected
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immval)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	--Give Type Effect
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
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
--(4)Disable your "Earthbound Immortal"
function s.negfilter(c)
	return c:IsFaceup() and (c:IsOriginalLevel(10) or c:IsOriginalLevel(11) or c:IsOriginalLevel(12) or c:IsOriginalLevel(13))
end
function s.discon(e)
	local ph=Duel.GetCurrentPhase()
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.negfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end