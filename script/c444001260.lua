-- Skill: Vampire Castle Reincarnation Ritual
local s, id = GetID()

function s.initial_effect(c)
    aux.AddSkillProcedure(c, 2, false, nil, nil)
    
    local e0 = Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_STARTUP)
    e0:SetCountLimit(1)
    e0:SetRange(0x5f)
    e0:SetOperation(s.startup_op)
    c:RegisterEffect(e0)
end

function s.startup_op(e, tp, eg, ep, ev, re, r, rp)
    -- Removemos o Flip daqui. A carta permanecerá setada face para baixo no início do duelo.
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(0x5f)
    e1:SetCondition(s.menu_con)
    e1:SetOperation(s.menu_op)
    Duel.RegisterEffect(e1, tp)
end

function s.boss_filter(c)
    return c:IsCode(444001010) or c:IsCode(444001020) -- Empress ou Princess
end

function s.menu_con(e, tp, eg, ep, ev, re, r, rp)
    if not aux.CanActivateSkill(tp) then return false end
    if Duel.GetFlagEffect(tp, id) > 0 then return false end -- 1 vez por duelo
    
    local has_boss = Duel.IsExistingMatchingCard(s.boss_filter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil)
    local low_lp = Duel.GetLP(tp) <= 4000
    local opp_strong_mon = Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:GetAttack() >= 3000 end, tp, 0, LOCATION_MZONE, 1, nil)
    
    return has_boss and (low_lp or opp_strong_mon)
end

function s.menu_op(e, tp, eg, ep, ev, re, r, rp)
    -- String 0 no CDB: "Activate Skill: Vampire Castle Reincarnation Ritual?"
    if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then 
        Duel.RegisterFlagEffect(tp, id, 0, 0, 0)
        
        -- É AQUI que a carta finalmente vira face para cima e o oponente vê o que aconteceu!
        Duel.Hint(HINT_SKILL_FLIP, tp, id | (1 << 32))
        Duel.Hint(HINT_CARD, tp, id)
        
        s.swap_field(e, tp)
    end
end

-- ====================================================================
-- OPERAÇÃO: DETECTA SE É ACTION DUEL OU DUELO NORMAL
-- ====================================================================
function s.swap_field(e, tp)
    if ActionDuel then
        -- [MODO ACTION DUEL] - ID 444001241
        local id_action = 444001241
        for p = 0, 1 do
            -- 1. Remove o campo Action antigo
            local old_af = Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_ACTION) and c.af end, p, LOCATION_FZONE, 0, nil):GetFirst()
            if old_af then
                local e_disable = Effect.CreateEffect(e:GetHandler())
                e_disable:SetType(EFFECT_TYPE_SINGLE)
                e_disable:SetCode(EFFECT_DISABLE)
                e_disable:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
                e_disable:SetReset(RESET_EVENT + RESETS_STANDARD)
                old_af:RegisterEffect(e_disable, true)
                Duel.SendtoDeck(old_af, nil, -2, REASON_RULE)
            end

            -- 2. Cria o novo Token de Action Field e aplica proteções globais
            local tc = Duel.CreateToken(p, id_action)
            
            local e1 = Effect.CreateEffect(tc)
            e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_LEAVE_FIELD)
            e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetOperation(function(ef) Duel.SendtoDeck(ef:GetHandler(), nil, -2, REASON_RULE) end)
            tc:RegisterEffect(e1)

            local e2 = Effect.CreateEffect(tc)
            e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            e2:SetCode(EVENT_CHAIN_END)
            e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetLabelObject(tc)
            e2:SetOperation(ActionDuel.returnop)
            Duel.RegisterEffect(e2, 0)

            local ea = Effect.CreateEffect(tc)
            ea:SetType(EFFECT_TYPE_SINGLE)
            ea:SetCode(EFFECT_CANNOT_TO_DECK)
            ea:SetRange(LOCATION_SZONE)
            ea:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
            tc:RegisterEffect(ea)

            local eb = ea:Clone()
            eb:SetCode(EFFECT_CANNOT_REMOVE)
            tc:RegisterEffect(eb)

            local ec = ea:Clone()
            ec:SetCode(EFFECT_CANNOT_TO_HAND)
            tc:RegisterEffect(ec)

            local ed = ea:Clone()
            ed:SetCode(EFFECT_CANNOT_TO_GRAVE)
            tc:RegisterEffect(ed)

            local ee = ea:Clone()
            ee:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            ee:SetValue(1)
            tc:RegisterEffect(ee)

            -- Move para a Field Zone dos DOIS jogadores
            Duel.MoveToField(tc, p, p, LOCATION_FZONE, POS_FACEUP, true)
        end
    else
        -- [MODO DUELO NORMAL] - ID 444001240
        local id_normal = 444001240
        
        -- Destrói a Field Spell atual do usuário (se houver)
        local fc = Duel.GetFieldCard(tp, LOCATION_FZONE, 0)
        if fc then Duel.SendtoGrave(fc, REASON_RULE) end
        
        -- Invoca direto na Field Zone do usuário
        local tc = Duel.CreateToken(tp, id_normal)
        Duel.MoveToField(tc, tp, tp, LOCATION_FZONE, POS_FACEUP, true)
    end
end