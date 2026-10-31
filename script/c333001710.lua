-- Mr. Volcano Sky Burner
-- Mr. Sky shared mechanics. Standalone script generated for one monster.
local s,id=GetID()
local ORIGINAL=31477025 -- Official Mr. Volcano; custom artwork uses this alias.
local ATTR=ATTRIBUTE_FIRE
local RACE=RACE_PYRO
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
 -- Burn whenever this Xyz is Special Summoned
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DAMAGE)
 e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 e1:SetProperty(EFFECT_FLAG_DELAY)
 e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 e1:SetCountLimit(1,{id,1})
 e1:SetTarget(s.burntg)
 e1:SetOperation(s.burnop)
 c:RegisterEffect(e1)
 -- Destroy a FIRE Normal on field to revive one from your GY
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,3))
 e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
 e2:SetType(EFFECT_TYPE_IGNITION)
 e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
 e2:SetRange(LOCATION_MZONE)
 e2:SetCountLimit(1,{id,2})
 e2:SetCost(s.detcost)
 e2:SetTarget(s.destg)
 e2:SetOperation(s.desop)
 c:RegisterEffect(e2)
end

function s.firecountfilter(c)
 return c:IsMonster() and c:IsAttribute(ATTR)
  and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.burntg(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return true end
 Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.burnop(e,tp,eg,ep,ev,re,r,rp)
 local ct=Duel.GetMatchingGroupCount(s.firecountfilter,tp,
  LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,nil)
 if ct>0 then Duel.Damage(1-tp,ct*200,REASON_EFFECT) end
end

function s.detcost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
 e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.fieldnormal(c)
 return c:IsFaceup() and c:IsAttribute(ATTR) and c:IsType(TYPE_NORMAL)
end
function s.gynormal(c,e,tp)
 return c:IsAttribute(ATTR) and c:IsType(TYPE_NORMAL)
  and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
 if chkc then return (chkc:IsOnField() and s.fieldnormal(chkc)) or (chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.gynormal(chkc,e,tp)) end
 if chk==0 then
  return Duel.IsExistingTarget(s.fieldnormal,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
   and Duel.IsExistingTarget(s.gynormal,tp,LOCATION_GRAVE,0,1,nil,e,tp)
 end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
 local g1=Duel.SelectTarget(tp,s.fieldnormal,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 local g2=Duel.SelectTarget(tp,s.gynormal,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
 Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
 Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,tp,LOCATION_GRAVE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
 local g=Duel.GetTargetCards(e)
 local gy=g:Filter(function(c) return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) end,nil):GetFirst()
 if not gy then return end
 local fg=g:Filter(function(c) return c:IsOnField() end,nil)
 local fc=fg:GetFirst()
 if not fc then return end
 if Duel.Destroy(fc,REASON_EFFECT)>0 and gy:IsRelateToEffect(e)
  and gy:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
  Duel.SpecialSummon(gy,0,tp,tp,false,false,POS_FACEUP)
 end
end
