-- Mr. Megavolt Sky Charger
-- Mr. Sky shared mechanics. Standalone script generated for one monster.
local s,id=GetID()
local ORIGINAL=333001560
local ATTR=ATTRIBUTE_LIGHT
local RACE=RACE_THUNDER
local SET_MR=0x215b
function s.xyzfilter(c,xyz,sumtype,tp)
 return c:IsLevel(5) and c:IsAttribute(ATTR) and c:IsRace(RACE)
    and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
end
function s.original_mat(e)
 return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,ORIGINAL)
end
function s.attrfilter(e,c)
 return c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI)
end
function s.gyoriginal(c,e,tp)
 return c:IsCode(ORIGINAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rev_tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.gyoriginal,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.rev_cost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
 Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.rev_op(e,tp,eg,ep,ev,re,r,rp)
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectMatchingCard(tp,s.gyoriginal,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
 local tc=g:GetFirst()
 if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
 -- Original Mr. cards are printed Normal Monsters. Give them Effect status
 -- and the custom recovery effect, without changing their underlying database text.
 local eff=Effect.CreateEffect(tc)
 eff:SetType(EFFECT_TYPE_SINGLE)
 eff:SetCode(EFFECT_ADD_TYPE)
 eff:SetValue(TYPE_EFFECT)
 eff:SetReset(RESET_EVENT|RESETS_STANDARD)
 tc:RegisterEffect(eff)
 local ne=Effect.CreateEffect(tc)
 ne:SetDescription(aux.Stringid(id,2))
 ne:SetCategory(CATEGORY_SPECIAL_SUMMON)
 ne:SetType(EFFECT_TYPE_IGNITION)
 ne:SetRange(LOCATION_MZONE)
 ne:SetCountLimit(1,ORIGINAL+80000000)
 ne:SetTarget(s.ban_tg)
 ne:SetOperation(s.ban_op)
 ne:SetReset(RESET_EVENT|RESETS_STANDARD)
 tc:RegisterEffect(ne)
end
function s.banfilter(c,e,tp)
 return c:IsFaceup() and c:IsSetCard(SET_MR) and c:IsType(TYPE_XYZ)
  and not c:IsAttribute(ATTR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ban_tg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.ban_op(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
 if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
 local xyz=g:GetFirst()
 if xyz and Duel.SpecialSummon(xyz,0,tp,tp,false,false,POS_FACEUP)>0
  and xyz:IsFaceup() and xyz:IsType(TYPE_XYZ) and c:IsRelateToEffect(e) then
  Duel.Overlay(xyz,Group.FromCards(c))
 end
end
function s.init_common(c)
 Xyz.AddProcedure(c,s.xyzfilter,5,2)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetType(EFFECT_TYPE_SINGLE)
 e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
 e1:SetCode(EFFECT_CHANGE_CODE)
 e1:SetValue(ORIGINAL)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetType(EFFECT_TYPE_SINGLE)
 e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
 e2:SetRange(LOCATION_GRAVE)
 e2:SetCode(EFFECT_ADD_TYPE)
 e2:SetValue(TYPE_NORMAL)
 c:RegisterEffect(e2)
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_FIELD)
 e3:SetCode(EFFECT_ADD_ATTRIBUTE)
 e3:SetRange(LOCATION_MZONE)
 e3:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE)
 e3:SetCondition(s.original_mat)
 e3:SetTarget(s.attrfilter)
 e3:SetValue(ATTR)
 c:RegisterEffect(e3)
 local e4=Effect.CreateEffect(c)
 e4:SetDescription(aux.Stringid(id,1))
 e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e4:SetProperty(EFFECT_FLAG_DELAY)
 e4:SetCode(EVENT_TO_GRAVE)
 e4:SetCondition(function(e) return e:GetHandler():IsReason(REASON_DESTROY) end)
 e4:SetCountLimit(1,{id,0})
 e4:SetCost(s.rev_cost)
 e4:SetTarget(s.rev_tg)
 e4:SetOperation(s.rev_op)
 c:RegisterEffect(e4)
end


function s.initial_effect(c)
 s.init_common(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
 e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetRange(LOCATION_MZONE)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(s.spcon)
 e1:SetTarget(s.handtg)
 e1:SetOperation(s.handop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,3))
 e2:SetCategory(CATEGORY_DISABLE)
 e2:SetType(EFFECT_TYPE_QUICK_O)
 e2:SetCode(EVENT_CHAINING)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,{id,2})
 e2:SetCondition(s.negcon)
 e2:SetCost(s.negcost)
 e2:SetTarget(s.negtg)
 e2:SetOperation(s.negop)
 c:RegisterEffect(e2)
end
function s.spcon(e,tp,eg) return eg:IsExists(Card.IsAttribute,1,nil,ATTR) end
function s.lightnormal(c) return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTR) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) end
function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return s.lightnormal(chkc) end
 if chk==0 then return Duel.IsExistingTarget(s.lightnormal,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
 Duel.SelectTarget(tp,s.lightnormal,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
end
function s.lightcount() return Duel.GetMatchingGroupCount(Card.IsAttribute,0,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil,ATTR) end
function s.mrhandfilter(c) return c:IsSetCard(SET_MR) and c:IsAbleToHand() end
function s.handop(e,tp)
 local tc=Duel.GetFirstTarget()
 if not tc or not tc:IsRelateToEffect(e) then return end
 if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
  and s.lightcount()>=10 and Duel.IsExistingMatchingCard(s.mrhandfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
  and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
  if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
   local g=Duel.SelectMatchingCard(tp,s.mrhandfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
   if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT);Duel.ConfirmCards(1-tp,g) end
  end
 end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
 if not re:IsSpellTrapEffect() or not Duel.IsChainDisablable(ev) then return false end
 local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
 return tg and tg:IsExists(function(c) return c:IsControler(tp) and c:IsSetCard(SET_MR) end,1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
 e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return true end
 Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
 if not Duel.NegateActivation(ev) then return end
 local card=re:GetHandler()
 if card and card:IsRelateToEffect(re) and card:IsLocation(LOCATION_ONFIELD)
  and card:IsType(TYPE_SPELL|TYPE_TRAP) then
  local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_MR) and c:GetOriginalCode()~=id end,tp,LOCATION_MZONE,0,nil)
  if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   local xyz=g:Select(tp,1,1,nil):GetFirst()
   Duel.Overlay(xyz,Group.FromCards(card))
  end
 end
end
