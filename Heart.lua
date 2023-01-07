Heart = Class{}

function Heart:init(x, y)
    self.image = love.graphics.newImage('images/heart.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    -- self.width = 40
    -- self.height = 30
    self.x = x
    self.y = y
    self.dy = 0
    self.dx = 0
end

function Heart:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 
    return true
end

function Heart:reset()
    self.x = width / 2
    self.y = height / 2
    self.dx = 0
    self.dy = 0
end

function Heart:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Heart:render()
    love.graphics.draw(self.image, self.x, self.y)
    -- local vertices = {
    --     self.x,                     self.y+self.height/4, 
    --     self.x+self.width/10,       self.y,
    --     self.x+3.5*(self.width/10), self.y,
    --     self.x+self.width/2,        self.y+self.height/4, 
    --     self.x+6.5*(self.width/10), self.y,
    --     self.x+9*(self.width/10),   self.y,
    --     self.x+self.width,          self.y+self.height/4,
    --     self.x+9*(self.width/10),   self.y+2*(self.height/3),
    --     self.x+self.width/2,        self.y+self.height,
    --     self.x+self.width/10,   self.y+2*(self.height/3)
    -- }
    -- r, g, b, a = love.graphics.getColor()
    -- love.graphics.setLineWidth(7)
    -- love.graphics.polygon("line", vertices)
    -- love.graphics.setColor(r, g, b, a)
end
