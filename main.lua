push = require 'push'
Class = require 'class'
require 'Heart'
require 'Paddle'

width = 1280
height = 720
local background = love.graphics.newImage('images/back.png')

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('BrutalPong')
    math.randomseed(os.time())

    fonts = {
        ['smallFont'] = love.graphics.newFont('fonts/Leokadia.ttf', 50),
        ['largeFont'] = love.graphics.newFont('fonts/Leokadia.ttf', 70),
        ['scoreFont'] = love.graphics.newFont('fonts/Leokadia.ttf', 110)
    }
    love.graphics.setFont(fonts['smallFont'])

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['applause'] = love.audio.newSource('sounds/applause.wav', 'static'),
        ['music'] = love.audio.newSource('sounds/back_music.wav', 'static')
    }
    local back_music = sounds['music']
    back_music:setLooping(true)
    back_music:setVolume(0.5)
    back_music:play()
    
    push:setupScreen(width, height, width, height, {
        vsync = true,
        canvas = false
    })
    paddleStartHeight = 140
    paddle_speed = 400
    player1 = Paddle(10, height / 2 - paddleStartHeight / 2, 10, paddleStartHeight)
    player2 = Paddle(width - 20, height / 2 - paddleStartHeight / 2, 10, paddleStartHeight)

    heart = Heart(width / 2, height / 2)

    player1Score = 0
    player2Score = 0
    winScore = 2

    servingPlayer = 1

    winningPlayer = 0

    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        heart.dy = math.random(-300, 300)
        if servingPlayer == 1 then
            heart.dx = -400
        else
            heart.dx = 400
        end
    elseif gameState == 'play' then
        if heart:collides(player1) then
            heart.dx = -heart.dx * 1.08
            heart.x = player1.x + player1.width
            if heart.dy < 0 then
                heart.dy = -math.random(10, 150)
            else
                heart.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if heart:collides(player2) then
            heart.dx = -heart.dx * 1.04
            heart.x = player2.x - heart.width
            if heart.dy < 0 then
                heart.dy = -math.random(10, 150)
            else
                heart.dy = math.random(10, 150)
            end
            sounds['paddle_hit']:play()
        end
        
        if heart.y <= 0 then
            heart.y = 0
            heart.dy = -heart.dy
            sounds['wall_hit']:play()
        end

        if heart.y >= height - heart.height then
            heart.y = height - heart.height
            heart.dy = -heart.dy
            sounds['wall_hit']:play()
        end

        if heart.x < -heart.width then
            servingPlayer = 1
            player2Score = player2Score + 1
            player2.height = player2.height * 0.85
            if player2Score == winScore then
                sounds['applause']:play()
                winningPlayer = 2
                gameState = 'done'
            else
                sounds['score']:play()
                gameState = 'serve'
                heart:reset()
            end
        end

        if heart.x > width then
            servingPlayer = 2
            player1Score = player1Score + 1
            player1.height = player1.height * 0.85
            if player1Score == winScore then
                sounds['applause']:play()
                winningPlayer = 1
                gameState = 'done'
            else
                sounds['score']:play()
                gameState = 'serve'
                heart:reset()
            end
        end
    end


    if love.keyboard.isDown('w') then
        player1.dy = -paddle_speed
    elseif love.keyboard.isDown('s') then
        player1.dy = paddle_speed
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -paddle_speed
    elseif love.keyboard.isDown('down') then
        player2.dy = paddle_speed
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        heart:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            heart:reset()
            player1Score = 0
            player2Score = 0
            player1.height = paddleStartHeight
            player2.height = paddleStartHeight
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
    push:start()

    love.graphics.draw(background, 0, 0)
    
    love.graphics.setFont(fonts['smallFont'])
    love.graphics.print('W S', 120, 10)
    love.graphics.print('Стрелки', width-310, 10)

    if gameState == 'start' then
        love.graphics.setFont(fonts['smallFont'])
        love.graphics.printf('Приветствуем мужицких мужиков в BRUTAL PONG!', 0, height - 145, width, 'center')
        love.graphics.printf('Нажмите Enter для начала бойни. Играем до ' .. tostring(winScore) .. ' очков', 0, height - 85, width, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(fonts['smallFont'])
        love.graphics.printf('Сердечный удар летит в сторону ' .. tostring(servingPlayer) .. ' игрока!', 0, height - 145, width, 'center')
        love.graphics.printf('Нажмите Enter, чтобы отбиваться', 0, height - 85, width, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(fonts['largeFont'])
        love.graphics.printf('Игрок ' .. tostring(winningPlayer) .. ' выиграл! Ты молодец!', 0, height - 145, width, 'center')
        love.graphics.setFont(fonts['smallFont'])
        love.graphics.printf('Нажмите Enter для реванша!', 0, height - 85, width, 'center')
    end

    love.graphics.setFont(fonts['scoreFont'])
    love.graphics.print(tostring(player1Score), width / 3 - 12, height / 3)
    love.graphics.print(tostring(player2Score), width - width / 3 + 13, height / 3)
    
    player1:render()
    player2:render()
    heart:render()

    push:finish()
end
