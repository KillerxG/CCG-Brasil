-- Mr. Hall of Reflections
-- Main Deck GY effects cannot activate; Extra Deck and Ritual monsters exempt.
-- Card ID: 333001640 | Archetype setcode: 0x215b
local s,id=GetID()
local MR_SETCODE=0x215b

function s.initial_effect(c)
    -- Activate Field Spell
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetTarget(s.activation_target)
    e0:SetOperation(s.activation_operation)
    c:RegisterEffect(e0)

    -- Non-Gemini monsters receive Normal + Gemini type (needed for re-summoning).
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_TYPE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.normal_target)
    e1:SetValue(TYPE_MONSTER|TYPE_NORMAL|TYPE_GEMINI)
    c:RegisterEffect(e1)

    -- Non-Gemini monsters in both GYs become Normal Monsters.
    local e2=e1:Clone()
    e2:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
    e2:SetTarget(s.grave_target)
    e2:SetValue(TYPE_MONSTER|TYPE_NORMAL)
    c:RegisterEffect(e2)

    -- A type change in the GY does NOT automatically stop GY effects.
    -- Explicitly prevent activations of affected monsters in either GY.
    -- Fusion/Synchro/Xyz/Link monsters remain exempt, as agreed.
    local e2b=Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD)
    e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2b:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2b:SetRange(LOCATION_FZONE)
    e2b:SetTargetRange(1,1)
    e2b:SetValue(s.gy_activation_limit)
    c:RegisterEffect(e2b)

    -- Original monster effects are negated until the second Normal Summon.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.disable_target)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_DISABLE_EFFECT)
    c:RegisterEffect(e4)

    -- Prevent monster effects from being activated before Gemini Summon.
    local e4b=e3:Clone()
    e4b:SetCode(EFFECT_CANNOT_TRIGGER)
    c:RegisterEffect(e4b)

    -- The EDOPro Gemini re-summon permission is installed directly
    -- on each monster. A field-wide permission was unreliable here.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetRange(LOCATION_FZONE)
    e5:SetOperation(s.adjust)
    c:RegisterEffect(e5)

    -- Detect Gemini Normal Summons performed under this field spell.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetRange(LOCATION_FZONE)
    e6:SetOperation(s.on_summon)
    c:RegisterEffect(e6)
end
local s,id=GetID()
s.listed_card_types={TYPE_GEMINI}
-- Activation requires a legal Special Summon from the Deck.
-- a monster currently on either field or in either GY.
function s.field_attributes()
    local g=Duel.GetMatchingGroup(Card.IsMonster,0,LOCATION_MZONE|LOCATION_GRAVE,
        LOCATION_MZONE|LOCATION_GRAVE,nil)
    local attrs=0
    for mc in aux.Next(g) do attrs=attrs|mc:GetAttribute() end
    return attrs
end
function s.deck_mr_filter(c,e,tp,attrs)
    return c:IsMonster() and c:IsSetCard(MR_SETCODE)
        and (c:GetAttribute()&attrs)~=0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activation_target(e,tp,eg,ep,ev,re,r,rp,chk)
    local attrs=s.field_attributes()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and attrs~=0
        and Duel.IsExistingMatchingCard(s.deck_mr_filter,tp,LOCATION_DECK,0,1,nil,e,tp,attrs) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activation_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local attrs=s.field_attributes()
    if attrs==0 or not Duel.IsExistingMatchingCard(s.deck_mr_filter,tp,LOCATION_DECK,0,1,nil,e,tp,attrs) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.deck_mr_filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,attrs)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

-- Extra Deck monster categories are entirely exempt from this Field Spell.
-- Their type, effects and summoning rules remain unchanged.
function s.is_non_gemini(c)
    local original_type=c:GetOriginalType()
    local extra_types=TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_RITUAL
    return (original_type&TYPE_MONSTER)~=0
        and (original_type&TYPE_GEMINI)==0
        and (original_type&extra_types)==0
end
function s.normal_target(e,c)
    return c:IsFaceup() and s.is_non_gemini(c)
        and c:GetFlagEffect(id)==0
        and not c:IsGeminiState()
end
function s.normal_filter(c)
    return s.normal_target(nil,c)
end
-- Native Normal Monsters already have no monster effects to negate.
-- Avoid the unnecessary crossed-out effect icon on those cards.
function s.disable_target(e,c)
    return s.normal_target(e,c) and (c:GetOriginalType()&TYPE_EFFECT)~=0
end
function s.grave_target(e,c)
    return s.is_non_gemini(c)
end

-- Equivalent in scope to a selective Soul Drain for GY activations.
-- GetActivateLocation checks where the effect was activated (not where
-- the card ends up during resolution).
function s.gy_activation_limit(e,re,tp)
    if re:GetActivateLocation()~=LOCATION_GRAVE then return false end
    local rc=re:GetHandler()
    return rc and s.is_non_gemini(rc)
        and (rc:GetOriginalType()&TYPE_EFFECT)~=0
end
-- Apply summonable state on each monster, refreshing only when required.
-- The reference to this Field Spell controls its expiry via a field effect;
-- an auxiliary flag prevents repeated registrations during EVENT_ADJUST.
function s.adjust(e,tp,eg,ep,ev,re,r,rp)
    -- This also catches Gemini states on engines where the summon event
    -- is delivered before the new state is completely established.
    local all=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    for tc in aux.Next(all) do
        if s.is_non_gemini(tc) then
            if tc:GetFlagEffect(id)==0 and tc:IsGeminiState() then
                s.mark_awakened(tc)
            elseif s.normal_filter(tc) and tc:GetFlagEffect(id+1)==0 then
                tc:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD,0,1)
                local ge=Effect.CreateEffect(e:GetHandler())
                ge:SetType(EFFECT_TYPE_SINGLE)
                ge:SetCode(EFFECT_GEMINI_SUMMONABLE)
                ge:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                ge:SetReset(RESET_EVENT|RESETS_STANDARD)
                tc:RegisterEffect(ge)
            end
        end
    end
end

function s.is_mr(c)
    return c:IsSetCard(MR_SETCODE)
end

function s.mark_awakened(tc)
    if tc:GetFlagEffect(id)>0 then return end
    tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
    if (tc:GetOriginalType()&TYPE_NORMAL)~=0 then
        s.awaken(tc)
    end
end

function s.on_summon(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        if tc:IsFaceup() and s.is_non_gemini(tc)
            and (tc:IsGeminiState() or tc:IsSummonType(SUMMON_TYPE_GEMINI)) then
            s.mark_awakened(tc)
        end
    end
end

function s.awaken(c)
    -- Persist independently of the Field Spell until the monster leaves/sets.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_TYPE)
    e0:SetValue(TYPE_MONSTER|TYPE_EFFECT)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e0)
    s.give_bonus(c)
end

-- All bonus effects are separate from the monster's printed/Gemini effects.
-- They survive Hall leaving the field and end when the monster leaves/sets.
function s.give_bonus(c)
    if c:GetFlagEffect(id+3)>0 then return end
    local att=c:GetOriginalAttribute()
    if att~=ATTRIBUTE_FIRE and att~=ATTRIBUTE_WATER and att~=ATTRIBUTE_EARTH
       and att~=ATTRIBUTE_LIGHT and att~=ATTRIBUTE_WIND and att~=ATTRIBUTE_DARK then return end
    c:RegisterFlagEffect(id+3,RESET_EVENT|RESETS_STANDARD,0,1)
    if att==ATTRIBUTE_FIRE then s.give_fire(c)
    elseif att==ATTRIBUTE_WATER then s.give_water(c)
    elseif att==ATTRIBUTE_EARTH then s.give_earth(c)
    elseif att==ATTRIBUTE_LIGHT then s.give_light(c)
    elseif att==ATTRIBUTE_WIND then s.give_wind(c)
    elseif att==ATTRIBUTE_DARK then s.give_dark(c) end
end

-- FIRE: 100 damage for each distinct Attribute of Normal Monsters in your GY.
function s.fire_cond(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return ep==1-tp and ((a and a:IsControler(tp) and s.is_mr(a))
        or (d and d:IsControler(tp) and s.is_mr(d)))
end
function s.fire_op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_NORMAL)
    local mask=0
    for tc in aux.Next(g) do mask=mask|tc:GetAttribute() end
    local n=0
    for _,att in ipairs({ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,
        ATTRIBUTE_WIND,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK,ATTRIBUTE_DIVINE}) do
        if (mask&att)~=0 then n=n+1 end
    end
    if n>0 then Duel.Damage(1-tp,n*100,REASON_EFFECT) end
end
function s.give_fire(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,0))
    e:SetCategory(CATEGORY_DAMAGE)
    e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
    e:SetCode(EVENT_BATTLE_DAMAGE)
    e:SetRange(LOCATION_MZONE)
    e:SetCondition(s.fire_cond)
    e:SetOperation(s.fire_op)
    e:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e)
end

-- WATER: on Normal Summon of a Mr. monster, bounce a Spell/Trap.
function s.water_cond(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(tc) return s.is_mr(tc) and tc:IsSummonType(SUMMON_TYPE_NORMAL) end,1,nil)
end
function s.water_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL|TYPE_TRAP) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,
        LOCATION_ONFIELD,1,nil,TYPE_SPELL|TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,
        LOCATION_ONFIELD,1,1,nil,TYPE_SPELL|TYPE_TRAP)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.water_op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
function s.give_water(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,1))
    e:SetCategory(CATEGORY_TOHAND)
    e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
    e:SetCode(EVENT_SUMMON_SUCCESS)
    e:SetRange(LOCATION_MZONE)
    e:SetCondition(s.water_cond)
    e:SetTarget(s.water_target)
    e:SetOperation(s.water_op)
    e:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e)
end

-- EARTH: Redirect a legal single-target card effect to itself.
function s.earth_cond(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    return tg and #tg==1 and not tg:IsContains(c)
        and tg:IsExists(function(tc) return tc:IsControler(tp) and s.is_mr(tc) end,1,nil)
        and c:IsCanBeEffectTarget(re)
end
function s.earth_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsCanBeEffectTarget(re) then
        Duel.ChangeTargetCard(ev,Group.FromCards(c))
    end
end
function s.earth_attack_cond(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttackTarget()
    return tc and tc~=c and tc:IsControler(tp) and s.is_mr(tc)
        and c:IsFaceup()
end
function s.earth_attack_op(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChangeAttackTarget(e:GetHandler())
end
function s.give_earth(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,2))
    e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_QUICK_O)
    e:SetCode(EVENT_CHAINING)
    e:SetRange(LOCATION_MZONE)
    e:SetCondition(s.earth_cond)
    e:SetOperation(s.earth_op)
    e:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.earth_attack_cond)
    e2:SetOperation(s.earth_attack_op)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e2)
end

-- LIGHT: Prevent opponent activation while a Mr. monster attacks.
-- NOTE: this is a prototype; precise Damage Step timing must be tested.
function s.light_cond(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    return a and a:IsControler(tp) and s.is_mr(a)
end
function s.light_op(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
    Duel.RegisterEffect(e1,tp)
end
function s.give_light(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,4))
    e:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
    e:SetCode(EVENT_ATTACK_ANNOUNCE)
    e:SetRange(LOCATION_MZONE)
    e:SetCondition(s.light_cond)
    e:SetOperation(s.light_op)
    e:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e)
end

-- WIND: attach this monster as material to your Xyz Monster.
function s.wind_xyz_filter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.wind_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE)
        and s.wind_xyz_filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.wind_xyz_filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.wind_xyz_filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.wind_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local xyz=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and c:IsFaceup() and xyz
        and xyz:IsRelateToEffect(e) and xyz:IsFaceup() and xyz:IsType(TYPE_XYZ) then
        Duel.Overlay(xyz,Group.FromCards(c))
    end
end
function s.give_wind(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,5))
    e:SetType(EFFECT_TYPE_IGNITION)
    e:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e:SetRange(LOCATION_MZONE)
    e:SetCountLimit(1)
    e:SetTarget(s.wind_target)
    e:SetOperation(s.wind_operation)
    e:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e)
end

-- DARK: send this card to GY as cost; revive a Normal Monster.
function s.dark_spfilter(c,e,tp)
    return c:IsMonster() and c:IsType(TYPE_NORMAL)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dark_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.dark_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.dark_spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.dark_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.dark_spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end
function s.give_dark(c)
    local e=Effect.CreateEffect(c)
    e:SetDescription(aux.Stringid(id,6))
    e:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e:SetType(EFFECT_TYPE_IGNITION)
    e:SetRange(LOCATION_MZONE)
    e:SetCountLimit(1)
    e:SetCost(s.dark_cost)
    e:SetTarget(s.dark_target)
    e:SetOperation(s.dark_operation)
    e:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e)
end
