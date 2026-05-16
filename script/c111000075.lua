-- Fairies Madness
-- Scripted by Gemini
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Condições individuais de cada opção
    local b1 = Duel.IsPlayerCanDraw(1-tp,2) -- Oponente pode comprar 2?
    local b2 = Duel.GetTurnPlayer()==tp -- É o seu turno para poder encerrá-lo?
    local b3 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 -- Você tem monstros para embaralhar?
    
    -- Para ativar, você precisa de pelo menos 1 carta na mão e poder resolver pelo menos 1 das opções
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 
        and (b1 or b2 or b3) end
        
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,ct,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Esvazia a mão (Descarte por Efeito)
    local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if #hg==0 then return end
    
    if Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)>0 then
        Duel.BreakEffect() -- A vírgula/then no texto obriga essa separação
        
        -- Checa novamente as condições na hora de resolver
        local b1 = Duel.IsPlayerCanDraw(1-tp,2)
        local b2 = Duel.GetTurnPlayer()==tp
        local b3 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
        
        -- Constrói o menu dinâmico
        local ops={}
        local opval={}
        local off=1
        
        if b1 then
            ops[off]=aux.Stringid(id,0) -- Representa o texto "Your opponent draws 2 cards"
            opval[off]=1
            off=off+1
        end
        if b2 then
            ops[off]=aux.Stringid(id,1) -- Representa o texto "End your turn"
            opval[off]=2
            off=off+1
        end
        if b3 then
            ops[off]=aux.Stringid(id,2) -- Representa o texto "Shuffle into the Deck..."
            opval[off]=3
            off=off+1
        end
        
        if off==1 then return end
        -- O jogador escolhe uma das opções válidas
        local op=Duel.SelectOption(tp,table.unpack(ops))
        local sel=opval[op+1]
        
        -- Executa a opção escolhida
        if sel==1 then
            Duel.Draw(1-tp,2,REASON_EFFECT)
            
        elseif sel==2 then
            local turnp=Duel.GetTurnPlayer()
            -- Pula as fases para forçar o encerramento do turno
            Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
            Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
            Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
            Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
            Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_BP)
            e1:SetTargetRange(1,0)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,turnp)
            
        elseif sel==3 then
            local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
            Duel.SendtoDeck(mg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end