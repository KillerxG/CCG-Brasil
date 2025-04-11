--East Wings Warrior, Chloe
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)	
	--(1)Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--(2)Set 1 "East Wings" or "Sinful Spoils"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--(3)Effect Gain: Place
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.gypltg)
	e3:SetOperation(s.gyplop)
	e3:SetValue(1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(function(e) return e:GetHandler():IsContinuousSpell() end)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
--(1)Special Summon itself
function s.tgfilter(c,tp,bool)
	local tg_check=nil
	if bool then
		tg_check=c:IsAbleToHand() and c:IsFaceup() and c:IsMonsterCard() and c:IsContinuousSpell()
	else
		tg_check=c:IsAbleToHandAsCost() and c:IsFaceup() and c:IsMonsterCard() and c:IsContinuousSpell()
	end
	return tg_check and Duel.GetMZoneCount(tp,c)>0
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp,false)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,tp,REASON_COST)
	g:DeleteGroup()
end
--(2)Set 1 "East Wings" or "Sinful Spoils"
function s.setfilter(c)
	return c:IsSetCard(0x314) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
--(3)Effect Gain: Place
function s.eftg(e,c)
	local g=e:GetHandler():GetColumnGroup(0,0)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x314) and c:GetSequence()<5 and g:IsContains(c)
end
function s.gyplfilter(c)
	return c:IsSetCard(0x314) and c:IsMonster() and not c:IsForbidden()
end
function s.gypltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyplfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.gyplfilter,tp,LOCATION_GRAVE,0,1,nil)	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyplfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.gyplop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		s.stplace(tc,tp,c)  
	end
end
function s.stplace(c,tp,rc)
	if not Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEUP,c:IsMonsterCard()) then return end
	--Treated as a Continuous Spell
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
	c:RegisterEffect(e1)
	return true
end