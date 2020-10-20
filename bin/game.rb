require 'ruby2d'
require 'pry'


set background: 'navy'
set fps_cap: 15

# width = 640 / 20 = 32
# height = 480 / 20 = 24

GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

class Ship # maybe to be moved to it's own file
    attr_accessor :position, :direction, :healthpoints
    def initialize
        @position = [16, 20]
        @direction = nil
        @healthpoints = 5
    end

    def draw # draws the ship in correct location and displays hp
        Square.new(x: @position[0] * GRID_SIZE, y: @position[1] * GRID_SIZE, size: GRID_SIZE, color: 'green')
        # I want to add more to the ship but can be done later
        # Triangle.new(
            #     x1: 50,  y1: 0,
        #     x2: 100, y2: 100,
        #     x3: 0,   y3: 100,
        #     color: 'red',
        #     z: 100
        #   )
        Text.new("HP: #{@healthpoints}", color: 'red', x: 10, y: 10, size: 25)
    end

    def move # logic for moving the ship 
        case @direction
        when 'left'
            if !(@position[0] <= 0) # stops ship from moving through th left wall
                @position[0] -= 1
            end
        when 'right'
            if !(@position[0] >= GRID_WIDTH - 1) # stops ship from moving through th right wall
                @position[0] += 1
            end
        end
    end # move

    # def asteroid_hit_ship(asteroid) # returns true if the asteroid and ship occupy the same space
    #     asteroid.rock.contains?(@position[0] * GRID_SIZE, @position[1] * GRID_SIZE)
    # end
    
    def record_hit # loosing life
        @healthpoints -= 1
    end
    
    # access to position of the ship at a given time
    def x
        @position[0] * GRID_SIZE
    end

    def y
        @position[1] * GRID_SIZE
    end
    
end # ship

class Asteroid
    attr_accessor :rock, :collided

    @@all = []

    def initialize(rock_x=rand(GRID_WIDTH), rock_y=rand(4))
        @rock_x = rock_x
        @rock_y = rock_y
        # @speed = rand(1..3)
        @rock = nil
        @collided = false
        @@all << self
    end

    def draw
        @rock = Square.new(x: @rock_x * GRID_SIZE, y: @rock_y * GRID_SIZE, size: (GRID_SIZE - 1) * 2, color: 'red')
    end

    def move
        @rock_y += 1 # @speed
        if @rock_y >= GRID_HEIGHT # logic to respawn asteroid at top of screen
            @rock_y = 0
            @rock_x = rand(GRID_WIDTH)
            # @speed = rand(1..3)
            @collided = false
        end
    end

    def asteroid_hit_ship(ship) # returns true if the asteroid and ship occupy the same space
        if !@collided # will only return true the first time the asteroid hits the ship
            if self.rock.contains?(ship.x, ship.y)
                @collided = true
                return true
            end
        end
    end
    
    # access to position of the asteroid at a given time
    def x
        @rock_x * GRID_SIZE
    end
    
    def y
        @rock_y * GRID_SIZE
    end
    
end # asteroid

🚀 = Ship.new
🌑 = []
3.times do
    🌑 << Asteroid.new
end

update do # actual logic of the game, runs every frame (speed controlled by fps_cap)
    clear

    unless 🚀.healthpoints <= 0 # stops the player and asteroid
        🚀.move
        🌑.each{|x| x.move}
    end
    
    🚀.draw
    🌑.each{|x| x.draw}

    
    # binding.pry
    🌑.each do |x|
        if x.asteroid_hit_ship(🚀) # tracks the collision and lowers hp
            🚀.record_hit
        end
    end
end

# events to catch user input, going to need to abstract these for the 2 player functionality
on :key_held do |event|
    if ['left', 'right'].include?(event.key)
        🚀.direction = event.key
    end
end

on :key_up do
    🚀.direction = nil
  end

show