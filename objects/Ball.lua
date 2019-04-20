-- Instancia a class
Ball = Class{}

-- Função construtora
function Ball:init(x, y, width, height)
    -- Variaveis de posição
    self.x = x
    self.y = y
    -- Variaveis de tamanho
    self.width = width
    self.height = height
    -- Variaveis de velocidade
    -- dx começa -100 ou 100 aleatoriamente
    self.dx = math.random(2) == 1 and -100 or 100
    -- dy começa com um valor entre -50 e 50
    self.dy = math.random(-50, 50)
end

-- Função que coloca a bola no meio da tela e escolhe novamente as velocidades
function Ball:reset()
    self.x = VIRTUAL_WIDTH /2-2
    self.y = VIRTUAL_HEIGHT /2 - 2

    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end

-- Função que atualiza a posição da bolinha de acordo com o deltaTime(dt)
function Ball:update(dt)
    -- Posição n recebe velocidade * tempo
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- Se a bolinha passar do topo
    if ball.y <= 0 then
        -- Seta a posição para a do topo
        ball.y = 0
        -- Inverte a direção/velocidade
        ball.dy = -ball.dy
        -- Toca o som de batida na parede
        sounds['wall_hit']:play()
    end
    
    -- Se a bolinha toca o chão
    if ball.y >= VIRTUAL_HEIGHT -4 then
        -- Seta a posição para a do chão menos 4(tamanho da bola)
        ball.y = VIRTUAL_HEIGHT - 4
        -- Inverte a direção da bolinha
        ball.dy = -ball.dy

        --Toca o som de batida na parede
        sounds['wall_hit']:play()
    end
end

-- Mostra/Renderiza a bolinha
function Ball:render()
    -- Cria um retângulo preenchido na posição (x,y) de largura e altura z
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

-- Verifica se a bolinha colidiu com as palhetas
function Ball:collides(paddle)
    -- Se o x da bolinha é maior que a posição+largura da palheta
    -- Ou se o x da palheta é maior que a posição+largura da bolinha não bateu
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- Se o y da bolinha é maior que a posição+altura da palheta
    -- Ou se o y da palheta é maior que a posição+altura da bolinha não bateu
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- Se os casos acima são falsos, então a bolinha bateu
    return true
end