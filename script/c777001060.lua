--Black Knight Xylia
--Scripted by KillerxG
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),s.matfilter)
	--(1)Gain ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--(2)Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
--Fusion Summon
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK)
end
--(1)Gain ATK
function s.atkfilter(c)
  return c:IsAttribute(ATTRIBUTE_DARK) and c:GetAttack()>0 and c:IsAbleToHand()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,s.atkfilter,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(tc:GetAttack()/2)
    e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    if tc:IsLocation(LOCATION_GRAVE) then
	  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      Duel.BreakEffect()
      Duel.SendtoHand(tc,nil,REASON_EFFECT)
      if tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1-tp,tc)
      end
    end
  end
end
--(2)Destroy
function s.vinciamaifilter(c,e,tp)
	return c:IsCode(777001070) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,e:GetHandler(),c)>0
end
function s.attachfilter(c,xyzc,tp)
	return c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
	and Duel.IsExistingMatchingCard(s.vinciamaifilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack()/2)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    local rec=tc:GetAttack()/2
    if rec<0 or tc:IsFacedown() then rec=0 end
    if Duel.Destroy(tc,REASON_EFFECT)~=0 then
      Duel.Recover(tp,rec,REASON_EFFECT)
	  if not c:IsRelateToEffect(e) then return end
		Duel.BreakEffect()
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
	  if c:IsLocation(LOCATION_EXTRA) and Duel.IsExistingMatchingCard(s.vinciamaifilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
			local tg=Duel.GetFirstMatchingCard(s.vinciamaifilter,tp,LOCATION_EXTRA,0,nil,e,tp)
			local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.attachfilter),tp,LOCATION_GRAVE,0,c,tc,tp)
			if tg then
				if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP) and #mg>1 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then					
					if #mg==0 then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
						local g=mg:Select(tp,2,2,nil)
							if #g>0 then
								Duel.HintSelection(g)
								Duel.Overlay(tg,g,true)
							end
				end
			end
		end
    end
  end
end



