-- Creature-Warden Convocation
-- Scripted by Gemini
local s, id = GetID()

function s.initial_effect(c)
    -- Efeito 1: Invocação-Ritual do "Creature-Warden, Sarafaye"
    -- Usando a estrutura moderna de tabela com extrafil e extraop para permitir materiais do GY
    local e1 = Ritual.AddProcGreater(c, {
        filter = s.ritual_fil,
        location = LOCATION_HAND,
        extrafil = s.extrafil,
        extraop = s.extraop
    })
    -- Se quiser que a ativação da carta seja uma vez por turno, remova os traços abaixo:
    -- e1:SetCountLimit(1, {id, 1})
    
    -- Efeito 2: Banir do GY, pegar "Creature-Warden" do Deck e colocar no topo
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.toptg)
    e2:SetOperation(s.topop)   
    c:RegisterEffect(e2)
end

s.listed_series = {0x251}
s.listed_names = {777006030} -- ID do Creature-Warden, Sarafaye

-- ==========================================================
-- Efeito 1: Lógicas de Invocação e Materiais Extras
-- ==========================================================
function s.ritual_fil(c)
    return c:IsCode(777006030)
end

function s.gymatfilter(c)
    return c:IsSetCard(0x251) and c:IsMonster() and c:IsAbleToDeck()
end

function s.extrafil(e, tp, eg, ep, ev, re, r, rp, chk)
    return Duel.GetMatchingGroup(s.gymatfilter, tp, LOCATION_GRAVE, 0, nil)
end

function s.extraop(mat, e, tp, eg, ep, ev, re, r, rp, tc)
    -- 1. Isola e envia as cartas do GY para o Fundo do Deck (O jogo pedirá a ordem automaticamente)
    local gymat = mat:Filter(Card.IsLocation, nil, LOCATION_GRAVE)
    if #gymat > 0 then
        Duel.SendtoDeck(gymat, nil, SEQ_DECKBOTTOM, REASON_EFFECT | REASON_MATERIAL | REASON_RITUAL)
        mat:Sub(gymat)
    end
    
    -- 2. Tributa os materiais normais restantes da Mão/Campo
    if #mat > 0 then
        Duel.ReleaseRitualMaterial(mat)
    end
end

-- ==========================================================
-- Efeito 2: Colocar do Deck no Topo em qualquer ordem
-- ==========================================================
function s.deckfilter(c)
    return c:IsSetCard(0x251) and c:IsMonster()
end

function s.toptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.deckfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
end

function s.topop(e, tp, eg, ep, ev, re, r, rp)
    -- Conta quantos monstros o oponente possui no momento da resolução
    local ct = Duel.GetFieldGroupCount(tp, 0, LOCATION_MZONE)
    if ct == 0 then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 2))
    -- Puxa da lista um limite de no máximo "ct" cartas (número de monstros inimigos)
    local g = Duel.SelectMatchingCard(tp, s.deckfilter, tp, LOCATION_DECK, 0, 1, ct, nil)
    
    if #g > 0 then
        Duel.ShuffleDeck(tp) -- Embaralha antes para que os alvos fiquem com certeza nas primeiras posições
        for tc in aux.Next(g) do
            Duel.MoveSequence(tc, SEQ_DECKTOP)
        end
        -- Garante a organização visual e mecânica do jogador
        Duel.SortDecktop(tp, tp, #g)
    end
end