-- Gem-Knight Morions
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Mudar de Tipo e Embaralhar (Ignition Effect)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id) -- HOPT
    e1:SetCost(s.typecost)
    e1:SetTarget(s.typetg)
    e1:SetOperation(s.typeop)
    c:RegisterEffect(e1)
    
    -- Efeito 2: Special Summon do GY e mudar o nome (Trigger Effect)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, id + 1) -- HOPT
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- ====================================================================
-- Efeito 1: Change Type & Shuffle
-- ====================================================================
function s.typecfilter(c)
    -- Filtro: Carta "Gem-Knight" (0x47), de Fusão, não-Rocha e não revelada
    return c:IsSetCard(0x47) and c:IsType(TYPE_FUSION) and not c:IsRace(RACE_ROCK) and not c:IsPublic()
end

function s.typecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.typecfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.typecfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    -- Guarda o Tipo da carta revelada na memória temporária do efeito
    e:SetLabel(g:GetFirst():GetRace())
end

function s.typetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.shfilter(c)
    -- Filtro: Cartas "Gem-" (0x1047 abrange Gem-Knight e genéricos Gem-) que podem voltar pro Deck
    return c:IsSetCard(0x1047) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.typeop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        -- Muda o Tipo
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetValue(e:GetLabel())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        
        -- Opção de embaralhar
        local sg=Duel.GetMatchingGroup(s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
        if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local tg=sg:Select(tp,1,1,nil)
            Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end

-- ====================================================================
-- Efeito 2: Special Summon do GY
-- ====================================================================
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    -- Garante que foi enviada da mão ou do Deck
    return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end

function s.spcfilter(c)
    -- O SEGREDO: type(c.material)=="table" obriga a engine a puxar apenas Fusões que têm material listado por nome!
    return c:IsSetCard(0x47) and c:IsType(TYPE_FUSION) and type(c.material)=="table" and not c:IsPublic()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.ConfirmCards(1-tp,g)
    Duel.SetTargetCard(g) -- Marca a carta revelada como Alvo invisível para recuperar o nome no Operation
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        local tc=Duel.GetFirstTarget()
        -- Se o Special Summon for bem sucedido e a carta do Extra Deck ainda puder ser lida
        if tc and type(tc.material)=="table" then
            local codes={}
            -- Monta uma lista com os materiais listados na Fusão
            for _,code in ipairs(tc.material) do
                table.insert(codes,code)
            end
            local code=codes[1]
            -- Se a Fusão listar mais de um material específico, deixa o jogador escolher qual nome copiar
            if #codes>1 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
                code=Duel.AnnounceCard(tp,table.unpack(codes))
            end
            
            -- Copia o Nome
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(code)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
end