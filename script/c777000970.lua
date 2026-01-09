--Phantom Gunners Scout
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
    --(1)Special Summon it self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--(2)Deck Out
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.immcon)
	e2:SetTarget(s.dktg)
	e2:SetOperation(s.dkop)
	c:RegisterEffect(e2)
	--(3)Equip it self
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)	
	--(4)Draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
--(1)Special Summon it self
function s.eqfilter(c)
	return c:IsSetCard(0x302) and c:IsType(TYPE_MONSTER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		and aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,chk)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_EQUIP)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local g=Duel.GetTargetCards(e)
		g=g:Filter(Card.IsRelateToEffect,nil,e):Filter(Card.IsType,nil,TYPE_MONSTER):Filter(Card.IsSetCard,nil,0x302)
		if ft<#g then return end
		Duel.BreakEffect()
		for tc in aux.Next(g) do
			Duel.Equip(tp,tc,c,false)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
--(2)Deck Out
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.DiscardDeck(1-tp,2,REASON_EFFECT) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
		--(2.1)Lock Summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,4),nil)
		--(2.2)Lizard check
		aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
	end
end
--(2.1)Lock Summon
function s.splimit(e,c)
	return not (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK)) and c:IsLocation(LOCATION_EXTRA)
end
--(2.2)Lizard check
function s.lizfilter(e,c)
	return not (c:IsOriginalRace(RACE_WARRIOR) and c:IsOriginalAttribute(ATTRIBUTE_DARK))
end
--(3)Equip it self
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x302) and c:IsType(TYPE_MONSTER)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(tc)
	e1:SetValue(s.eqplimit)
	c:RegisterEffect(e1)
end
function s.eqplimit(e,c)
	return c==e:GetLabelObject()
end
--(4)Draw
function s.cfilter1(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(777000960)
end
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end