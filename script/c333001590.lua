--Mr.Polarity
local s, id = GetID()
local SET_MR = 0x215b
local POLARITY_AWAKENED = 333001590

function s.initial_effect(c)
    -- Ativação da Magia (Normal Spell)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
local s,id=GetID()
s.listed_card_types={TYPE_GEMINI}
-- ==========================================
-- Lógica Principal: Baralhar e Invocar
-- ==========================================
function s.filter1(c, e, tp)
    return c:IsFaceup() and c:IsLevel(5) and c:IsSetCard(SET_MR) and c:IsAbleToDeck()
        and Duel.IsExistingMatchingCard(s.filter2, tp, LOCATION_DECK, 0, 1, nil, e, tp, c:GetAttribute())
end

function s.filter2(c, e, tp, attr)
    return c:IsLevel(5) and c:IsSetCard(SET_MR) and c:GetAttribute() ~= attr
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter1(chkc, e, tp) end
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > -1
        and Duel.IsExistingTarget(s.filter1, tp, LOCATION_MZONE, 0, 1, nil, e, tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
        
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.filter2, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp, tc:GetAttribute())
        local sc = g:GetFirst()
        
        if sc and Duel.SpecialSummon(sc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            -- Shared marker: Hall of Reflections must not reset this awakened monster.
            sc:RegisterFlagEffect(POLARITY_AWAKENED, RESET_EVENT|RESETS_STANDARD, 0, 1)
            -- Transforma no Status de Gemini + Effect
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_GEMINI_STATUS)
            e1:SetValue(1)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            sc:RegisterEffect(e1)
            
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_ADD_TYPE)
            e2:SetValue(TYPE_MONSTER|TYPE_EFFECT|TYPE_GEMINI)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD)
            sc:RegisterEffect(e2)

            -- Atribui o Efeito de Acordo com o Atributo Original
            local attr = sc:GetOriginalAttribute()
            
            if attr == ATTRIBUTE_EARTH then
                -- Protecao por Nivel: efeito rapido original.
                local ep=Effect.CreateEffect(sc)
                ep:SetDescription(aux.Stringid(id, 0))
                ep:SetType(EFFECT_TYPE_QUICK_O)
                ep:SetCode(EVENT_FREE_CHAIN)
                ep:SetRange(LOCATION_MZONE)
                ep:SetCountLimit(1)
                ep:SetCost(s.earth_cost)
                ep:SetOperation(s.earth_op)
                ep:SetReset(RESET_EVENT|RESETS_STANDARD)
                sc:RegisterEffect(ep)

                -- 1) Protecao continua contra destruicao em batalha.
                local e3 = Effect.CreateEffect(sc)
                e3:SetType(EFFECT_TYPE_SINGLE)
                e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
                e3:SetValue(1)
                e3:SetReset(RESET_EVENT|RESETS_STANDARD)
                sc:RegisterEffect(e3)

                -- 2) Quando o controlador recebe dano numa batalha deste monstro,
                -- ele ganha ATK, e o adversario sobrevivente perde o mesmo ATK.
                local e4 = Effect.CreateEffect(sc)
                e4:SetDescription(aux.Stringid(id, 0))
                e4:SetCategory(CATEGORY_ATKCHANGE)
                e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
                e4:SetCode(EVENT_BATTLE_DAMAGE)
                e4:SetRange(LOCATION_MZONE)
                e4:SetCondition(s.earth_damagecon)
                e4:SetOperation(s.earth_damageop)
                e4:SetReset(RESET_EVENT|RESETS_STANDARD)
                sc:RegisterEffect(e4)

            elseif attr == ATTRIBUTE_FIRE then
                local e3 = Effect.CreateEffect(e:GetHandler())
                e3:SetDescription(aux.Stringid(id, 1))
                e3:SetCategory(CATEGORY_DAMAGE + CATEGORY_ATKCHANGE)
                e3:SetType(EFFECT_TYPE_QUICK_O)
                e3:SetCode(EVENT_FREE_CHAIN)
                e3:SetRange(LOCATION_MZONE)
                e3:SetCountLimit(1)
                e3:SetCost(s.fire_cost)
                e3:SetOperation(s.fire_op)
                e3:SetReset(RESET_EVENT + RESETS_STANDARD)
                sc:RegisterEffect(e3)
                
            elseif attr == ATTRIBUTE_WATER then
                local e3 = Effect.CreateEffect(e:GetHandler())
                e3:SetDescription(aux.Stringid(id, 2))
                e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
                e3:SetType(EFFECT_TYPE_QUICK_O)
                e3:SetCode(EVENT_FREE_CHAIN)
                e3:SetRange(LOCATION_MZONE)
                e3:SetCountLimit(1)
                e3:SetTarget(s.water_tg)
                e3:SetOperation(s.water_op)
                e3:SetReset(RESET_EVENT + RESETS_STANDARD)
                sc:RegisterEffect(e3)
                
            elseif attr == ATTRIBUTE_LIGHT then
                local e3 = Effect.CreateEffect(e:GetHandler())
                e3:SetDescription(aux.Stringid(id, 3))
                e3:SetCategory(CATEGORY_DESTROY)
                e3:SetType(EFFECT_TYPE_QUICK_O)
                e3:SetCode(EVENT_FREE_CHAIN)
                e3:SetRange(LOCATION_MZONE)
                e3:SetCountLimit(1)
                e3:SetCost(s.light_cost)
                e3:SetTarget(s.light_tg)
                e3:SetOperation(s.light_op)
                e3:SetReset(RESET_EVENT + RESETS_STANDARD)
                sc:RegisterEffect(e3)
            end
        end
    end
end

-- ==========================================
-- Efeito TERRA (protecao por Nivel + resistencia e contra-ataque)
-- ==========================================
function s.earth_cost_filter(c)
    local ng=c:IsAttribute(ATTRIBUTE_EARTH) and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
    return c:IsMonster() and (ng or c:IsSetCard(SET_MR)) and c:IsAbleToGraveAsCost()
end
function s.earth_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.earth_cost_filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.earth_cost_filter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        e:SetLabel(tc:GetLevel())
        Duel.SendtoGrave(tc,REASON_COST)
    end
end
function s.earth_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local level=e:GetLabel()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(function(e,re,rp)
        if not re then return true end
        local rc=re:GetHandler()
        return not (rc and rc:IsMonster() and rc:GetLevel()==e:GetLabel())
    end)
    e1:SetLabel(level)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)
end

function s.earth_opponent(c)
    local a = Duel.GetAttacker()
    local d = Duel.GetAttackTarget()
    if a == c then return d end
    if d == c then return a end
    return nil
end

function s.earth_damagecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return ep==tp and ev>0 and c:IsFaceup() and s.earth_opponent(c)~=nil
end

function s.earth_damageop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    local bc=s.earth_opponent(c)
    local dmg=ev
    if dmg<=0 then return end

    -- O ganho de ATK nao expira na End Phase; termina se sair do campo.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(dmg)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e1)

    -- Oponente que sobreviveu a batalha e ainda esta no campo perde ATK.
    if bc and bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE)
        and not bc:IsStatus(STATUS_BATTLE_DESTROYED) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(-dmg)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
        bc:RegisterEffect(e2)
    end
end

-- ==========================================
-- Efeito FOGO (Dano e ATK)
-- ==========================================
function s.fire_cost_filter(c)
    local is_fire_norm_gem = c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
    return (is_fire_norm_gem or c:IsSetCard(SET_MR)) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.fire_cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.fire_cost_filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_DECK, 0, 1, e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.fire_cost_filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_DECK, 0, 1, 1, e:GetHandler())
    Duel.SendtoGrave(g, REASON_COST)
    e:SetLabel(g:GetFirst():GetLevel())
end
function s.fire_op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dmg = e:GetLabel() * 200
    if Duel.Damage(1-tp, dmg, REASON_EFFECT) > 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(dmg)
        e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        c:RegisterEffect(e1)
    end
end

-- ==========================================
-- Efeito AGUA (reviver + declarar Tipo/Raca)
-- ==========================================
function s.water_sp_filter(c,e,tp)
    local ng=c:IsAttribute(ATTRIBUTE_WATER) and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
    return c:IsMonster() and (ng or c:IsSetCard(SET_MR))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.water_tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.water_sp_filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.water_op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.water_sp_filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
    local race=Duel.AnnounceRace(tp,1,RACE_ALL)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetValue(race)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)
end

-- ==========================================
-- Efeito LUZ (destruição por Atributo + ataque direto)
-- ==========================================
function s.light_cost_filter(c)
    local is_light_norm_gem = c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsType(TYPE_NORMAL) or c:IsType(TYPE_GEMINI))
    return (is_light_norm_gem or c:IsSetCard(SET_MR)) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.light_cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.light_cost_filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.light_cost_filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

-- Um Mr. do seu campo ou Cemitério precisa compartilhar ao menos um Atributo.
function s.light_mr_attr_filter(c, attr)
    return c:IsMonster() and c:IsSetCard(SET_MR) and bit.band(c:GetAttribute(), attr) ~= 0
end

function s.light_destroy_filter(c, tp)
    return c:IsFaceup() and c:IsMonster() and c:IsDestructable()
        and Duel.IsExistingMatchingCard(s.light_mr_attr_filter, tp,
            LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil, c:GetAttribute())
end

function s.light_tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.light_destroy_filter, tp, 0, LOCATION_MZONE, 1, nil, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 1-tp, LOCATION_MZONE)
end

function s.light_op(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.IsExistingMatchingCard(s.light_destroy_filter, tp, 0, LOCATION_MZONE, 1, nil, tp) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local dg = Duel.SelectMatchingCard(tp, s.light_destroy_filter, tp, 0, LOCATION_MZONE, 1, 1, nil, tp)
    if #dg == 0 or Duel.Destroy(dg, REASON_EFFECT) == 0 then return end

    -- Ataque direto com dano de batalha integral, somente neste turno.
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DIRECT_ATTACK)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(e1)
    end
end
