--Draconic Sorceress
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	--(1)Type Dragon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(RACE_DRAGON)
	c:RegisterEffect(e1)	
	--(2)Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--(3)ATK Up
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+1)
	e4:SetCost(s.atkcost)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
--(2)Special Summon
function s.descostfilter(c)
	return c:IsSetCard(0x300) and c:IsMonster() and c:IsDiscardable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.descostfilter,1,1,REASON_COST|REASON_DISCARD)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x300) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--(3)ATK Up
function s.atkfilter1(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost(POS_FACEUP) and c:IsAttackAbove(10)
end
function s.atkfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x300)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter1,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_MZONE,0,1,c) end
	local g=Duel.SelectMatchingCard(tp,s.atkfilter1,tp,LOCATION_EXTRA,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetBaseAttack())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel()/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,777000680),tp,LOCATION_ONFIELD,0,1,nil) 
			and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
			local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
			local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
				if not e:GetHandler():IsRelateToEffect(e) or #g1+#g2==0 then return end
					local op=Duel.SelectEffect(tp,
						{#g1>0,aux.Stringid(id,3)},
						{#g2>0,aux.Stringid(id,4)})
					local g=(op==1) and g1 or g2
						if op==2 then Duel.ConfirmCards(tp,g) end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
							local tg=g:FilterSelect(tp,aux.AND(Card.IsMonster,Card.IsAbleToRemove),1,1,nil)
								if #tg>0 then
									Duel.BreakEffect()
									Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
										if op==2 then Duel.ShuffleExtra(1-tp) end
								end
		end
	end
end