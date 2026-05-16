-- Gem-Knight Legacy
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Cria o botão "Activate Skill"
    aux.AddSkillProcedure(c, 1, false, s.skillcon, s.skillop)
end

-- Filtro para encontrar o "Gem-Knight Master Diamond Dispersion"
function s.dispersion_filter(c)
    return c:IsFaceup() and c:IsCode(25342956) and (c:GetAttack() > 0 or c:GetDefense() > 0)
end

function s.skillcon(e,tp,eg,ep,ev,re,r,rp)
    if not aux.CanActivateSkill(tp) then return false end
    -- Checa se é "Once per turn" e se o monstro está no campo
    return Duel.GetFlagEffect(tp, id) == 0 
        and Duel.IsExistingMatchingCard(s.dispersion_filter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.skillop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP, tp, id|(1<<32))
    Duel.Hint(HINT_CARD, tp, id)
    
    -- Registra o limite de 1 vez por turno
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)

    -- Abre a janela para você selecionar o seu "Gem-Knight Master Diamond Dispersion"
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc = Duel.SelectMatchingCard(tp, s.dispersion_filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    
    if tc then
        local c = e:GetHandler()
        
        -- Reduz o ATK para 0
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        
        -- Reduz a DEF para 0
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        tc:RegisterEffect(e2)
        
        -- IDs oficiais e REAIS das Fusões Gem-Knight
        local fusions = {8692301, 67985943, 71616908, 76614340, 49597193, 13108445}
        
        -- Agrupa tudo e envia pro Extra Deck usando a Regra do Jogo
        local g = Group.CreateGroup()
        for _, fid in ipairs(fusions) do
            g:AddCard(Duel.CreateToken(tp, fid))
        end
        Duel.SendtoDeck(g, tp, SEQ_DECKTOP, REASON_RULE)
        
        -- Restrição: Para o resto do Duelo, só pode invocar do Extra Deck monstros "Gem-Knight"
        local e3 = Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetTargetRange(1,0)
        e3:SetTarget(s.splimit)
        Duel.RegisterEffect(e3, tp)
        
        -- Dica visual no ícone do jogador
        aux.RegisterClientHint(c, nil, tp, 1, 0, aux.Stringid(id, 1), nil)
    end
end

-- Lógica da Restrição do Extra Deck
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x47)
end