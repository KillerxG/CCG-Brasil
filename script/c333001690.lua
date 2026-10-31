-- Mr. Geyser Sky Washer
-- Mr. Sky shared mechanics. Standalone script generated for one monster.
local s,id=GetID()
local ORIGINAL=333001570
local ATTR=ATTRIBUTE_WATER
local RACE=RACE_AQUA
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
 e4:SetType(EFFECT_TYPE_IGNITION)
 e4:SetRange(LOCATION_GRAVE)
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
 e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
 e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetRange(LOCATION_MZONE)
 e1:SetCode(EVENT_TO_GRAVE)
 e1:SetCountLimit(1,{id,1})
 e1:SetCondition(s.destroyedcon)
 e1:SetCost(s.recovercost)
 e1:SetTarget(s.recovertg)
 e1:SetOperation(s.recoverop)
 c:RegisterEffect(e1)
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,3))
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,{id,2})
 e2:SetCost(s.allcost)
 e2:SetOperation(s.trackop)
 c:RegisterEffect(e2)
end
function s.destroyed(c,tp) return c:IsMonster() and c:IsAttribute(ATTR) and c:IsControler(tp) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) end
function s.destroyedcon(e,tp,eg) return eg:IsExists(s.destroyed,1,nil,tp) end
function s.banishfilter(c) return c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTR) and c:IsAbleToRemoveAsCost() end
function s.recovercost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
 local g=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
 Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.recovertg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
   and eg:IsExists(function(c) return s.destroyed(c,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,1,nil) end
 local g=eg:Filter(function(c) return s.destroyed(c,tp) end,nil)
 g:KeepAlive();e:SetLabelObject(g)
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.recoverop(e,tp,eg,ep,ev,re,r,rp)
 local g=e:GetLabelObject(); if not g then return end
 if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
  local sg=g:Filter(function(c) return c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end,nil)
  if #sg>0 then
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
   local tc=sg:Select(tp,1,1,nil):GetFirst()
   Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
  end
 end
 g:DeleteGroup()
end
function s.allcost(e,tp,eg,ep,ev,re,r,rp,chk)
 local c=e:GetHandler()
 if chk==0 then return c:GetOverlayCount()>0 end
 local g=c:GetOverlayGroup()
 Duel.SendtoGrave(g,REASON_COST)
end
function s.trackop(e,tp)
 -- Register a turn-long continuous watcher, independent of Sky Washer's location.
 -- Continuous, not Trigger_O: it does not expire after the first response.
 local watcher=Effect.GlobalEffect()
 watcher:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
 watcher:SetCode(EVENT_TO_GRAVE)
 watcher:SetOperation(s.watchop)
 watcher:SetReset(RESET_PHASE|PHASE_END)
 watcher:SetLabel(tp)
 Duel.RegisterEffect(watcher,tp)
end
function s.trackfilter(c)
 return c:IsMonster() and c:IsLocation(LOCATION_GRAVE)
end
function s.xyzother(c)
 return c:IsFaceup() and c:IsSetCard(SET_MR) and c:IsType(TYPE_XYZ)
  and c:GetOriginalCode()~=id
end
function s.watchop(e,tp,eg,ep,ev,re,r,rp)
 local player=e:GetLabel()
 local g=eg:Filter(s.trackfilter,nil)
 if #g==0 then return end
 if not Duel.IsExistingMatchingCard(s.xyzother,player,LOCATION_MZONE,0,1,nil) then
  return
 end
 if not Duel.SelectYesNo(player,aux.Stringid(id,4)) then
  return
 end
 Duel.Hint(HINT_SELECTMSG,player,HINTMSG_FACEUP)
 local xyz=Duel.SelectMatchingCard(player,s.xyzother,player,LOCATION_MZONE,0,1,1,nil):GetFirst()
 if not xyz then return end
 local eligible=g:Filter(s.trackfilter,nil)
 if #eligible==0 then return end
 Duel.Overlay(xyz,eligible)
end
