class Array   # for holes
  def x; self[0]; end
  def y; self[1]; end
end


class Board < Array
  
  attr_accessor :origin, :parent
  attr_reader :hole1, :hole2, :possibilities
  
  def initialize(*args)
    super *args
    @origin = :initial
    @possibilities = []
    # process_movements
  end
  
  def deep_clone
    board = Board.new
    self.each do |row|
      board << row.clone
    end
    board
  end

  def possibilities
    return @possibilities if @possibilities.size > 0
    find_and_set_holes
    hole = @hole1
    oole = @hole2

    @possibilities += one_hole_movements(@hole2)
    @possibilities += one_hole_movements(@hole1)
    @possibilities += double_hole_movements(@hole1, @hole2)
    @possibilities.each { |p| p.parent = self }
  end

  def show_board
    puts "** #{origin} **"
    puts self
    puts
  end
  
  def show_possibilities
    possibilities.each do |board|
      board.show_board
    end
  end
  
  def show_board_and_possibilities
    show_board
    show_possibilities
  end
  
  protected

    def one_hole_movements(hole)
      possibilities = []
      # Movements with one hole
      # =======================
      # when :up
      if above(hole) == "o"
        b = deep_clone
        b.origin = :small_square_down
        b[hole.y]    [hole.x] = "o"
        b[hole.y - 1][hole.x] = " "
        possibilities << b
      elsif above(hole) == "|"
        b = deep_clone
        b.origin = :vertical_bar_down
        b[hole.y]    [hole.x] = "|"
        b[hole.y - 1][hole.x] = "I"
        b[hole.y - 2][hole.x] = " "
        possibilities << b
      end

      # when :down
      if below(hole) == "o"
        b = deep_clone
        b.origin = :small_square_up
        b[hole.y]    [hole.x] = "o"
        b[hole.y + 1][hole.x] = " "
        possibilities << b

      elsif below(hole) == "I"
        b = deep_clone
        b.origin = :vertical_bar_up
        b[hole.y]    [hole.x] = "I"
        b[hole.y + 1][hole.x] = "|"
        b[hole.y + 2][hole.x] = " "
        possibilities << b
      end

      # when :left
      if left(hole) == "o"
        b = deep_clone
        b.origin = :small_square_right
        b[hole.y][hole.x]     = "o"
        b[hole.y][hole.x - 1] = " "
        possibilities << b
      elsif left(hole) == "="
        b = deep_clone
        b.origin = :horizontal_bar_right
        b[hole.y][hole.x]     = "="
        b[hole.y][hole.x - 2] = " "
        possibilities << b
      end

      # when :right
      if right(hole) == "o"
        b = deep_clone
        b.origin = :small_square_left
        b[hole.y][hole.x]     = "o"
        b[hole.y][hole.x + 1] = " "
        possibilities << b
      elsif right(hole) == "="
        b = deep_clone
        b.origin = :horizontal_bar_left
        b[hole.y][hole.x]     = "="
        b[hole.y][hole.x + 2] = " "
        possibilities << b
      end
      possibilities
    end
    
    def double_hole_movements(hole, oole)
      possibilities = []
      
      # Movements with two holes
      if horizontal_neighbor?(hole, oole)
        if above(hole) == "=" && above(oole) == "="
          b = deep_clone
          b.origin = :horizontal_bar_down
          b[hole.y][hole.x] = "="
          b[oole.y][oole.x] = "="
          b[hole.y - 1][hole.x] = " "
          b[oole.y - 1][oole.x] = " "
          possibilities << b
        elsif above(hole) == "@" && above(oole) == "@"
          b = deep_clone
          b.origin = :square_up
          b[hole.y][hole.x] = "@"
          b[oole.y][oole.x] = "@"
          b[hole.y - 2][hole.x] = " "
          b[oole.y - 2][oole.x] = " "
          possibilities << b
        end
        if below(hole) == "=" && below(oole) == "="
          b = deep_clone
          b.origin = :horizontal_bar_up
          b[hole.y][hole.x] = "="
          b[oole.y][oole.x] = "="
          b[hole.y + 1][hole.x] = " "
          b[oole.y + 1][oole.x] = " "
          possibilities << b
        elsif below(hole) == "@" && below(oole) == "@"
          b = deep_clone
          b.origin = :square_up
          b[hole.y][hole.x] = "@"
          b[oole.y][oole.x] = "@"
          b[hole.y + 2][hole.x] = " "
          b[oole.y + 2][oole.x] = " "
          possibilities << b
        end 

      elsif vertical_neighbor?(hole, oole)
        if left(hole) == "I"    # hole.x is always lesser than oole.x
          b = deep_clone
          b.origin = :vertical_bar_right
          b[hole.y][hole.x] = "I"
          b[oole.y][oole.x] = "|"
          b[hole.y][hole.x - 1] = " "
          b[oole.y][oole.x - 1] = " "
          possibilities << b
        elsif left(hole) == "@" && left(oole) == "@"
          b = deep_clone
          b.origin = :square_right
          b[hole.y][hole.x] = "@"
          b[oole.y][oole.x] = "@"
          b[hole.y][hole.x - 2] = " "
          b[oole.y][oole.x - 2] = " "
          possibilities << b
        end
        if right(hole) == "I"   # hole.x is always lesser than oole.x
          b = deep_clone
          b.origin = :vertical_bar_left
          b[hole.y][hole.x] = "I"
          b[oole.y][oole.x] = "|"
          b[hole.y][hole.x + 1] = " "
          b[oole.y][oole.x + 1] = " "
          possibilities << b
        elsif right(hole) == "@" && right(oole) == "@"
          b = deep_clone
          b.origin = :square_left
          b[hole.y][hole.x] = "@"
          b[oole.y][oole.x] = "@"
          b[hole.y][hole.x + 2] = " "
          b[oole.y][oole.x + 2] = " "
          possibilities << b
        end
      end
      possibilities
    end

    def find_and_set_holes
      @hole1 = nil
      @hole2 = nil
      5.times do |y| 
        4.times do |x|
          @hole1 ? @hole2 = [x, y] : @hole1 = [x, y] if self[y][x] == 32
        end
      end
    end
    
    def above(hole); hole.y == 0 ? nil : self[hole.y - 1][hole.x].chr; end # rescue; puts self; 
    def below(hole); hole.y == 4 ? nil : self[hole.y + 1][hole.x].chr; end
    def left(hole);  hole.x == 0 ? nil : self[hole.y][hole.x - 1].chr; end
    def right(hole); hole.x == 3 ? nil : self[hole.y][hole.x + 1].chr; end
    
    def horizontal_neighbor?(hole, oole)
      hole.y == oole.y && (hole.x - oole.x).abs == 1
    end
    
    def vertical_neighbor?(hole, oole)
      hole.x == oole.x && (hole.y - oole.y).abs == 1
    end
    
end

class Game

  attr_accessor :initial_board
  
  def initialize(initial_board)
    @initial_board = Board.new(initial_board)
  end
  
  def search_board(level, final_board)
    @all_boards = []
    @counter = 0
    @counters = []
    @level = level
    puts "== #{@initial_board.origin} =="
    puts @initial_board
    puts
    recursive_search_board(level + 1, [@initial_board], final_board)
  end
  
  def show_possibilities
    @initial_board.show_board_and_possibilities
  end
  
  protected
  
    def recursive_search_board(level, boards, final_board)
      level -= 1
      return if level == 0
      possibilities = []
      for board in boards
        # @counters[@level - level] ? @counters[@level - level] += 1 : @counters[@level - level] = 1
        @counter += 1
        if board[0][1].chr == "@" && board[0][2].chr == "@"
          puts "FOUND! Movements: #{@level - level}"
          # board.show_board
          parent = board
          until parent == nil do
            parent.show_board
            parent = parent.parent
          end
          return true   # parar quando encontrar o estado final
        end
        possibilities += board.possibilities unless @all_boards.include?(board)
        @all_boards << board
      end
      puts "Level #{@level - level} :\t #{boards.size} movimentos calculados (#{@counter} no total)"
      @found = recursive_search_board(level, possibilities, final_board)
    end
  
end
  

game = Game.new [
  "I  I",
  "|oo|",
  "o==o",
  "I@@I", 
  "|@@|"
]

game.search_board(130, "")


