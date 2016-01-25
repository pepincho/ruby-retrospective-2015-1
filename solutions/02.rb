def move(snake, direction)
  grow(snake, direction).drop(1)
end

def grow(snake, direction)
  snake + [position_in_front_of_snake(snake_head(snake), direction)]
end

def new_food(food, snake, dimensions)
  xs, ys = (0...dimensions[:width]).to_a, (0...dimensions[:height]).to_a
  all_positions = xs.product(ys)
  empty_positions = all_positions - (food + snake)

  empty_positions.sample
end

def obstacle_ahead?(snake, direction, dimensions)
  next_position = position_in_front_of_snake(snake_head(snake), direction)
  not in_bounds?(next_position, dimensions) or
    body_ahead?(next_position, snake)
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
    obstacle_ahead?(move(snake, direction), direction, dimensions)
end

def snake_head(snake)
  snake.last
end

def position_in_front_of_snake(head, direction)
  head_x, head_y = head
  direction_x, direction_y = direction

  [head_x + direction_x, head_y + direction_y]
end

def in_bounds?(position, dimensions)
  x, y = position
  width = dimensions[:width]
  height = dimensions[:height]

  x.between?(0, width - 1) and y.between?(0, height - 1)
end

def body_ahead?(position, snake)
  snake.include?(position)
end
