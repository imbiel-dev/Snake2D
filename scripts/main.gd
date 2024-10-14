extends Node

@export var snake_scene: PackedScene  #exported variable to hold the snake segment scene

#game variables
var score: int
var game_started: bool = false

#grid variables
var cells: int = 20 #number of cells in the grid
var cell_size: int = 50 #size of each cell

#food variables
var food_pos: Vector2
var regen_food: bool= true #flag to regenerate food

#snake variables
var old_data: Array #stores previous positions of snake segments
var snake_data: Array #stores current positions of snake segments
var snake: Array #stores the snake segment nodes

#movement variables
var start_pos= Vector2(9, 9) #starting position of the snake
var up= Vector2(0, -1)
var down= Vector2(0, 1)
var left= Vector2(-1, 0)
var right= Vector2(1, 0)
var move_direction: Vector2
var can_move: bool #flag to control if the snake can move

#called when the node is added to the scene
func _ready():
	new_game() #start a new game

#function to start a new game
func new_game():
	get_tree().paused= false  #unpause the game
	get_tree().call_group("segments", "queue_free") #free all snake segments
	$GameOverMenu.hide() #hide the game over menu
	score= 0 #reset the score
	$HUD.get_node("ScoreLabel").text= "SCORE: " + str(score) #update the score display
	move_direction= up #set the initial movement direction
	can_move= true #allow movement
	generate_snake() #generate the snake
	move_food() #move the food to a new position

#function to generate the snake
func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	#starting with the start_pos,create tail segments vertically down
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))

#function to add a segment to the snake
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment= snake_scene.instantiate()
	SnakeSegment.position= (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

#called every frame
func _process(_delta):
	move_snake()

#function to handle snake movement
func move_snake():
	if can_move:
		#update movement from keypresses
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
			if not game_started:
				start_game()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false
			if not game_started:
				start_game()

#function to start the game
func start_game():
	game_started= true
	$MoveTimer.start() #start the move timer

#called when the move timer times out
func _on_move_timer_timeout():
	#allow snake movement
	can_move = true
	#use the snake's previous position to move the segments
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		#move all the segments along by one
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds() #check if the snake is out of bounds
	check_self_eaten() #check if the snake has eaten itself
	check_food_eaten() #check if the snake has eaten the food
 
#function to check if the snake is out of bounds
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		end_game()

#function to check if the snake has eaten itself
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()

#function to check if the snake has eaten the food
func check_food_eaten():
	#if snake eats the food, add a segment and move the food
	if snake_data[0] == food_pos:
		score += 1
		$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score) #update the score display
		add_segment(old_data[-1]) #add a new segment to the snake
		move_food() #move the food to a new position

#function to move the food to a new position
func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * cell_size)+ Vector2(0, cell_size)
	regen_food = true

#function to end the game
func end_game():
	$GameOverMenu.show() #show the game over menu
	$MoveTimer.stop() #stop the move timer
	game_started= false
	get_tree().paused= true #pause the game

#function called when the game over menu restart button is pressed
func _on_game_over_menu_restart():
	new_game() #start a new game
