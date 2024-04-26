#[
    Important Note: 
        /!\ This program DOES look messy /!\

        I recently started learning Nim and wanted to implement as many Nim functionalities as possible into one short program.
        I'm indeed taking advice from experienced Nim developers.
    
    Description:
        "The Price is Right" implemented in Nim is an adaptation of the classic guessing game.
        In this game, a random number is generated by the program, and the player's objective is to guess this number correctly.
        The player enters their guess, and the program provides feedback, indicating whether the guess is too high or too low.
        Based on this feedback, the player refines their guess until they correctly identify the random number.
        The game continues until each player successfully guesses the number or chooses to end the game.

    Author:
        Github : @BassoNicolas

    Date:
        April 26 2024
    
    Usage:
        Compile AND run the code : nim c -r file.nim  # note that it compiles AND run the code, once done, you can simply call the program using ./file.(exe, elf ...)

        Compile the code : nim c file.nim  # outputs a binary file.(exe, elf ..)
        Run the program : ./file.exe

    Functionalities : 
        - Multi local players
        - Scoreboard
        - 3 difficulties

    WOW now you're all ready for your best parties using this impressive game woohoo ! 
]#


import std/[strutils, random, typetraits, strformat, algorithm, terminal]

randomize()

type 
    Game = ref object of RootObj
        difficulty: int

    Player = ref object of Game
        username: string
        tries: int = 0
        numberToGuess: int


var
    game: Game = Game()
    players: seq[Player]


method updateTries(this: Player): void {.base.} =
    discard """
    Adds +1 to the player tries.
    
    Args:
        this: Player object.
    """
    this.tries += 1
    
method getUsername(this: Player): void {.base.} = 
    discard """
    Get the player's username through user input.
        
    Args:
        this: Player object.
    """ 
    stdout.write("Enter your username : ")
    var username: string = stdin.readLine.strip
    this.username = username

proc setGameDifficulty(): void = 
    discard """
    Get the game's difficulty through user input.
    
    Raises:
        ValueError: If the given input is not a number.
    """ 
    try:
        stdout.write("Enter a level [1-3] : ")
        game.difficulty = stdin.readLine.parseInt
        echo fmt"Level {game.difficulty} set !"
    except ValueError:
        echo "Given value is not a number"
        setGameDifficulty()

method setDifficulty(this: Game): int {.base.} =
    discard """
    Generate a random number on a range depending on the game difficulty.
    
    Returns:
        int: random number between 0-100 || 0-1000 || 0-10000
    """ 
    case this.difficulty
    of 1:
        return rand(100)
    of 2:
        return rand(1000)
    of 3:
        return rand(10000)
    else:
        echo "Difficulty level must be set between 1 and 3"
        setGameDifficulty()

proc getNumber(): BiggestInt =
    discard """
    Parses the user input to assert it's a number.
    
    Returns:
        guess: BiggestInt = The user input as a number.

    Raises:
        ValueError: If the user input is not a number.
    """ 
    try:
        stdout.write("Enter a number : ")
        let guess: BiggestInt = stdin.readline.parseBiggestInt
        return guess
    except ValueError:
        echo "Given input is not a number !"
        getNumber()

proc getPlayers(): int = 
    discard """
    Get the number of players.
    
    Returns:
        noPlayer: int = The number of players.

    Raises:
        ValueError: If the user input is not a number.
    """ 
    try:
        stdout.write("How many players ? : ")
        let noPlayer: BiggestInt = stdin.readline.parseBiggestInt
        if noPlayer == 0: echo "Why do nobody wants to play this game :((("; system.quit() else: echo fmt"{noPlayer} selected."
        return noPlayer
    except ValueError:
        echo "Given input is not a number !"
        getPlayers()

proc setPlayers(noPlayer: int, players: var seq[Player]): void =
    discard """
    Take a username through user input for each player and stores them in a referenced sequence of Player objects.
    
    Args:
        noPlayer: int = The number of players.
        players: var seq[Player] = A referenced variable that is a sequence of Player objects.
    """ 
    for player in 1 .. noPlayer:
        stdout.write(fmt"Player n°{player} enter your username : ")
        var username: string = stdin.readLine.strip
        players.add(Player(username: username))
    

proc startGame(players: seq[Player]): void =
    discard """
    Loop through each player in the sequence and run the game until each of them finds the number.
    
    Args:
        players: seq[Player] = A sequence of player objects.
    """ 
    for player in players:
        eraseScreen()
        echo fmt"##### Your turn player : {player.username} #####"
        while true:
            player.updateTries()
            let guessed: int = getNumber()
            if guessed == player.numberToGuess:
                echo fmt"The correct number was {player.numberToGuess}"
                stdout.styledWriteLine({styleBlink}, "Press any key to continue")
                discard getch()
                break
            elif guessed < player.numberToGuess:
                echo "It's higher"
            elif guessed > player.numberToGuess:
                echo "It's lower"

proc initGame(): void =
    discard """
    Initializes the game settings.

    Asks for the user input and sets the number to guess for each player.
    """

    # Ew ugly indentation... Well, skill issue I guess (ᕗ ͠° ਊ ͠° )ᕗ
    echo """
##### Levels #####
1: 0-100
2: 0-1000
3: 0-10000
        """

    stdout.write("Enter a level [1-3] : ")
    game.difficulty = stdin.readLine.parseInt

    for player in players:
        player.numberToGuess = game.setDifficulty()

proc comparePlayers(player1: Player, player2: Player): int =
    discard """
    Compares two players based on their number of tries and usernames.
    
    Args:
        player1: Player = Player object representing the first player.
        player1: Player = Player object representing the second player.

    Returns:
        An integer representing the comparison result:
        - Less than 0 if player1 has fewer tries than player2 or if their usernames are alphabetically lower.
        - 0 if both players have the same number of tries and usernames.
        - Greater than 0 if player1 has more tries than player2 or if their usernames are alphabetically higher.
    """ 
    if player1.tries == player2.tries: return cmp(player1.username, player2.username) else: return player1.tries - player2.tries

proc getResults(): void =
    discard """
    Manages the result display after the game is finished.

    This procedure orchestrates the display of game results, including sorting the players based on their performance, displaying winners, and handling ties.
    """
    startGame(players)
    sort(players, proc (player1, player2: Player): int =
                    if player1.tries == player2.tries:
                        result = cmp(player1.username, player2.username)
                    else:
                        result = player1.tries - player2.tries,
                    Ascending)
    
    sort(players, comparePlayers, Ascending)
    eraseScreen()


    echo "##########"
    echo " WINNERS "
    echo "##########"

    var position: int = 0

    while position < players.len:
        var currentPosition: int = position

        while currentPosition < players.len and players[currentPosition].tries == players[position].tries:
            inc(currentPosition)

        for i in position ..< currentPosition:
            var tries: string = if players[i].tries == 1: "try" else: "tries"

            if position == 0:
                stdout.styledWriteLine(fgGreen, {styleBright}, fmt"1 : {players[i].username} won with {players[i].tries} {tries}!")
            else:
                echo fmt"{position + 1} : {players[i].username} with {players[i].tries} {tries}."

        position = currentPosition

proc main(): void =
    discard """
    Basically the main procedure to run the game.
    """
    eraseScreen()

    let noPlayers: int = getPlayers()
    setPlayers(noPlayers, players)

    initGame()

    getResults()

    echo "Thx for playing this game :)\nPress any key to exit the program."
    discard getch()
    
when isMainModule:
    discard """
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                    # idk tho
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⢀⣴⠟⠉⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣀⢀⣾⠿⠻⢶⣄⠀⠀⣠⣶⡿⠶⣄⣠⣾⣿⠗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⢻⣿⣿⡿⣿⠿⣿⡿⢼⣿⣿⡿⣿⣎⡟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠉⠛⢛⣛⡉⠀⠀⠙⠛⠻⠛⠑⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣧⣤⣴⠿⠿⣷⣤⡤⠴⠖⠳⣄⣀⣹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣀⣟⠻⢦⣀⡀⠀⠀⠀⠀⣀⡈⠻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⡿⠉⡇⠀⠀⠛⠛⠛⠋⠉⠉⠀⠀⠀⠹⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡟⠀⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠈⠑⠪⠷⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣦⣼⠛⢦⣤⣄⡀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠢⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⠴⠲⠖⠛⠻⣿⡿⠛⠉⠉⠻⠷⣦⣽⠿⠿⠒⠚⠋⠉⠁⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣾⠛⠁⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢣⠀⠀⠀
⠀⠀⠀⠀⣰⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠀
⠀⠀⠀⣰⣿⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣧⣄⠀⠀⠀⠀⠀⠀⢳⡀⠀
⠀⠀⠀⣿⡾⢿⣀⢀⣀⣦⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⣫⣿⡿⠟⠻⠶⠀⠀⠀⠀⠀⢳⠀
⠀⠀⢀⣿⣧⡾⣿⣿⣿⣿⣿⡷⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⢀⡴⢿⣿⣧⠀⡀⠀⢀⣀⣀⢒⣤⣶⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
⠀⠀⡾⠁⠙⣿⡈⠉⠙⣿⣿⣷⣬⡛⢿⣶⣶⣴⣶⣶⣶⣤⣤⠤⠾⣿⣿⣿⡿⠿⣿⠿⢿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
⠀⣸⠃⠀⠀⢸⠃⠀⠀⢸⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⠟⡉⠀⠀⠀⠈⠙⠛⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
⠀⣿⠀⠀⢀⡏⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠛⠉⠁⠀⠀⠀⠀⠀⠉⠠⠿⠟⠻⠟⠋⠉⢿⣿⣦⡀⢰⡀⠀⠀⠀⠀⠀⠀⠁
⢀⣿⡆⢀⡾⠀⠀⠀⠀⣾⠏⢿⣿⣿⣿⣯⣙⢷⡄⠀⠀⠀⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣿⣻⢿⣷⣀⣷⣄⠀⠀⠀⠀⢸⠀
⢸⠃⠠⣼⠃⠀⠀⣠⣾⡟⠀⠈⢿⣿⡿⠿⣿⣿⡿⠿⠿⠿⠷⣄⠈⠿⠛⠻⠶⢶⣄⣀⣀⡠⠈⢛⡿⠃⠈⢿⣿⣿⡿⠀⠀⠀⠀⠀⡀
⠟⠀⠀⢻⣶⣶⣾⣿⡟⠁⠀⠀⢸⣿⢅⠀⠈⣿⡇⠀⠀⠀⠀⠀⣷⠂⠀⠀⠀⠀⠐⠋⠉⠉⠀⢸⠁⠀⠀⠀⢻⣿⠛⠀⠀⠀⠀⢀⠇
⠀⠀⠀⠀⠹⣿⣿⠋⠀⠀⠀⠀⢸⣧⠀⠰⡀⢸⣷⣤⣤⡄⠀⠀⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡆⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⠀⢼⡇
⠀⠀⠀⠀⠀⠙⢻⠄⠀⠀⠀⠀⣿⠉⠀⠀⠈⠓⢯⡉⠉⠉⢱⣶⠏⠙⠛⠚⠁⠀⠀⠀⠀⠀⣼⠇⠀⠀⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⡇
⠀⠀⠀⠀⠀⠀⠻⠄⠀⠀⠀⢀⣿⠀⢠⡄⠀⠀⠀⣁⠁⡀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⢀⣐⡟⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

"""
    main()
    system.quit()