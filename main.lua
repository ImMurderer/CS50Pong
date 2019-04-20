--Importa a biblioteca de classes e a do push
Class = require 'libs/class'
push = require 'libs/push'

--Importa os objetos Paddle e Ball
require './objects/Paddle'
require 'objects/Ball'

-- Dimensões da tela
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Dimensão virtual para o efeito pixelado
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- Velocidade da palhetas
PADDLE_SPEED = 200

-- Função chamada quando a tela inicia
function love.load()
    -- Define o filtro pixelado
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Seta a seed aleatoria para o tempo unix atual
    math.randomseed(os.time())

    -- Instancia as fontes
    smallFont = love.graphics.newFont('fonts/font.ttf', 8)
    largeFont = love.graphics.newFont('fonts/font.ttf', 16)
    scoreFont = love.graphics.newFont('fonts/font.ttf', 32)

    -- Cria a table com os sons utilizados
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    -- Altera o titulo da janela
    love.window.setTitle('Pong')

    -- Cria a janela com o tamanho virtual para o efeito e o tamanho real da janela
    -- Por ultimo uma tabela com as opções
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- Instancia paddles nas posições de tamanho 5 por 20
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- Inicia os scores
    player1Score = 0
    player2Score = 0

    -- Define o jogador a ceder a primeira rodada
    servingPlayer = 1

    -- Define o jogador vencedor
    winningPlayer = 0

    -- Instancia a bolinha no meio da tela com tamhno 4 por 4
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

-- Função chamada quando a tela é redimensionada
function love.resize(w, h)
    -- Faz o push redimensionar a tela virtual junto
    push:resize(w, h)
end

-- Função chamada toda vez que uma tecla é pressionada
function love.keypressed(key)
    -- Se esc é pressionado, fecha a janela
    if key == 'escape' then
        love.event.quit()
    -- Se enter é pressionado
    elseif key == 'return' then
        -- Se o estado por start ou done
        if gameState == 'start' or gameState=='done' then
            -- State = serve
            gameState = 'serve'
        -- Ou senão se o estado for serve
        elseif gameState == 'serve' then
            -- State = play
            gameState = 'play'

            -- Reseta a posição da bolinha
            ball:reset()
        end
    end
end

-- Função chamada quando a tela atualiza
function love.update(dt)
    -- Se o estado é serve
    if gameState == 'serve' then
        -- Randomiza o y da bolinha
        ball.dy = math.random(-50, 50)
        -- Se o 1 esta servindo
        if servingPlayer == 1 then
            -- A direção x da bolinha recebe um valor aleatorio entre 140 e 200
            ball.dx = math.random(140, 200)
        else
            -- Se o 2 esta servindo direção x recebe valor aleatorio negativo
            ball.dx = -math.random(140, 200)
        end
    -- Se o estado é done
    elseif gameState == 'done' then
        -- Reseta as pontuações
        player1Score = 0
        player2Score = 0

        -- Se o P1 venceu
        if winningPlayer == 1 then
            -- P2 serve
            servingPlayer = 2
        else
            -- Senão P1 serve
            servingPlayer = 1
        end
    -- Se o estado é play
    elseif gameState == 'play' then
        -- Verifica as teclas pressionadas
        -- Se W foi pressionado
        if love.keyboard.isDown('w') then
            -- P1 move para cima
            player1.dy = -PADDLE_SPEED
        -- Senão se o S foi pressionado
        elseif love.keyboard.isDown('s') then
            -- P1 move pra baixo
            player1.dy = PADDLE_SPEED
        -- Se nenhum dos dois esta pressionado
        else
            -- Não move
            player1.dy = 0
        end

        -- Se a seta pra cima esta pressionada
        if love.keyboard.isDown('up') then
            -- Move o P2 pra cima
            player2.dy = -PADDLE_SPEED

        -- Senão se a seta pra baixo esta pressionada
        elseif love.keyboard.isDown('down') then
            -- Move o p2 pra baixo
            player2.dy = PADDLE_SPEED
        -- Se nenhum dos dois esta pressionado
        else
            -- Não move
            player2.dy = 0
        end

        -- Atualiza os players
        player1:update(dt)
        player2:update(dt)
        -- Atualiza a bolinha
        ball:update(dt)

        -- Se a bolinha colidiu com o P1
        if ball:collides(player1) then
            -- Inverte e acelera o X da bolinha
            ball.dx = -ball.dx * 1.19
            -- Seta a posição da bolinha pra do P1 + 4
            ball.x = player1.x + 4
            -- Toca o som de batida na palheta
            sounds['paddle_hit']:play()
            -- Se a direção da bolinha esta pra cima
            if ball.dy < 0 then
                -- Randomiza uma direção pra cima
                ball.dy = -math.random(10, 150)
            -- Se esta pra baixo
            else
                -- Randomiza uma direção pra baixo
                ball.dy = math.random(10, 150)
            end
        end

        -- Se a bolinha colidiu com o P2
        if ball:collides(player2) then
            -- Inverte e acelera o x da bolinha
            ball.dx = -ball.dx * 1.19
            ball.x = player2.x - 4
            -- Toca o som de batida na palheta
            sounds['paddle_hit']:play()

            -- Se a direção da bolinha esta pra cima
            if ball.dy < 0 then
                -- Randomiza uma direção pra cima
                ball.dy = -math.random(10, 150)
            -- Se a bolinha esta pra baixo
            else
                -- Randomiza uma direção pra baixo
                ball.dy = math.random(10, 150)
            end
        end
        -- Se a bolinha colidiu com a parede esquerda
        if ball.x <= 0 then
            -- Player 1 serve
            servingPlayer = 1
            -- P2 marca 1 ponto
            player2Score = player2Score + 1
            -- Toca o som de pontuação
            sounds['score']:play()
            -- Se o P2 fez 3 pontos
            if player2Score == 3 then
                -- P2 Vence
                winningPlayer = 2
                -- Estado = 'done'
                gameState = 'done'
            -- Senão
            else
                -- Reseta a bolinha
                ball:reset()
                -- Estado = 'serve'
                gameState = 'serve'
            end
        end
    
        -- Se a bolinha colidiu com a parede direita
        if ball.x >= VIRTUAL_WIDTH then
            -- Player 2 serve
            servingPlayer = 2
            -- Toca o som de pontuação
            sounds['score']:play()
            -- P1 marca 1 ponto
            player1Score = player1Score + 1
            -- Se P1 fez 3 pontos
            if player1Score == 3 then
                -- P1 Vence
                winningPlayer = 1
                -- Estado = 'done'
                gameState = 'done'
            -- Senão
            else
                -- Reseta a bolinha
                ball:reset()
                -- Estado = 'serve'
                gameState = 'serve'
            end
        end
    end
end

function love.draw()
    -- Inicia o ciclo de update
    push:apply('start')

    -- Limpa a tela com a marrom escuro
    love.graphics.clear(.025, .02, .02, 1)

    -- Renderiza o estado
    renderState()

    -- Renderiza o estado de vitoria
    renderWinState()

    -- Renderiza as palhetas
    player1:render()
    player2:render()

    --Mostra a bolinha
    ball:render()

    --Mostra a pontuação
    renderScores()

    -- Mostra o fps
    displayFPS()
    
    -- Finaliza o ciclo de update atual
    push:apply('end')
end

-- Verifica se alguem ganho e renderiza
function renderWinState()
    -- Se o jogo acabou
    if gameState == 'done' then
        -- Utiliza a fonte grande
        love.graphics.setFont(largeFont)
        -- Imprime "Player x Wins!"
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' Wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        -- Utiliza a fonte pequena
        love.graphics.setFont(smallFont)
        -- Imprime a mensagem instruíndo o reinicio
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')

    end
end

-- Verifica o estado e renderiza
function renderState()
    -- Usa a fonte pequena
    love.graphics.setFont(smallFont)
    -- Se o estado for start
    if gameState == 'start' then
        -- Imprime "Hello Start State!"
        love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    -- Senão se o estado for 'serve'
    elseif gameState == 'serve' then
        -- Imprime qual jogador esta servindo e a instrução para começar
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    end
end

-- Utiliza a fonte de pontuação e renderiza as pontuações
function renderScores()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

-- Função que mostra o fps
function displayFPS()
    -- Utiliza a fonte pequena
    love.graphics.setFont(smallFont)
    -- Utiliza a cor verde
    love.graphics.setColor(0, 1, 0, 1)
    -- Imprime "FPS: " + fps
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end