-- Cria a classe Paddle
Paddle = Class{}

-- Função construtora da Palheta
function Paddle:init(x, y, width, height)
    -- Variáveis de posição
    self.x = x
    self.y = y
    -- Variáveis de tamanho
    self.width = width
    self.height = height
end

-- Atualiza a posição da bolinha
function Paddle:update(dt)
    -- Se a direção é menor que 0
    if self.dy < 0 then
        -- Escolhe apenas uma posição maior que 0
        self.y = math.max(0, self.y + self.dy * dt)
    else -- Senão
        -- Escolhe uma posição menor que a altura da tela
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

-- Mostra/Renderiza a bolinha
function Paddle:render()
    -- Cria um retangulo preenchido na posição (x,y) de tamanho (w,h)
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end