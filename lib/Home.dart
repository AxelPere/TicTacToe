import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Keeps track of the score of each player
  int scorePlayer1 = 0;
  int scorePlayer2 = 0;

  //Keeps track of whose turn it is
  //Also is used to know which player we are affecting (score, image, etc.)
  bool playerOneTurn = true;

  //Keeps track of the state of the board
  List<List<String>> board = [
    ["-", "-", "-"],
    ["-", "-", "-"],
    ["-", "-", "-"]
  ];

  //Images for each player
  File? xImage;
  File? oImage;

  //Allows the user to pick an image from their gallery
  final ImagePicker picker = ImagePicker();
  Future<void> pickImage(bool isPlayerOne) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (isPlayerOne) {
          xImage = File(pickedFile.path);
        } else {
          oImage = File(pickedFile.path);
        }
      }
    });
  }

  //Returns the image widget for the player.
  Widget getImage(String marker) {
    if (marker == "X" && xImage != null) {
      //Replaces X for player one with their image
      return Image.file(xImage!);
    } else if (marker == "O" && oImage != null) {
      //Replaces O for player two with their image
      return Image.file(oImage!);
    } else {
      //Default is their respective X or O if there is no image given by users
      return Text(
        marker,
        style: const TextStyle(fontSize: 25),
      );
    }
  }

  void makeMove(int i, int j) {
    if (board[i][j] == "-") {
      //Checks if default value in this cell, so we can't overwrite a move
      setState(() {
        board[i][j] =
            playerOneTurn ? "X" : "O"; //Sets the cell to the player's marker
        if (checkWinner()) {
          //If there is a winner, increment their score and show the winner
          incrementScore(playerOneTurn);
          showWinnerDialog(playerOneTurn ? "Player 1" : "Player 2");
        } else if (fullBoard()) {
          //If the board is full, it's a tie
          resetGame();
          playerOneTurn = true;
        } else {
          togglePlayerWidget(); //Switches to the other player
        }
      });
    }
  }

  bool fullBoard() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[i][j] == "-") {
          //If there is a cell with the default value, the board is not full
          return false;
        }
      }
    }
    return true;
  }

  void resetGame() {
    setState(() {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          board[i][j] =
              "-"; //Resets the board to the default value on all cells
        }
      }
      playerOneTurn = true; //Sets the first player to start
    });
  }

  void togglePlayerWidget() {
    setState(() {
      playerOneTurn =
          !playerOneTurn; //Switches the player, player one to player two and vice versa
    });
  }

  void incrementScore(bool playerOne) {
    setState(() {
      if (playerOne) {
        scorePlayer1++; //Increments player one's score
      } else {
        scorePlayer2++; //Increments player two's score
      }
    });
  }

  bool checkWinner() {
    for (int i = 0; i < 3; i++) {
      // Check rows
      if (board[i][0] != "-" &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        return true;
      }

      // Check columns
      if (board[0][i] != "-" &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        return true;
      }
    }

    // Check diagonals
    if (board[0][0] != "-" &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      return true;
    }
    if (board[0][2] != "-" &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      return true;
    }
    return false;
  }

  void showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //Shows a popup with the winner
          title: const Text("Game Over"),
          content: Text("$winner Wins!"),
          actions: [
            TextButton(
              onPressed: () {
                resetGame(); //Resets the game
                Navigator.of(context).pop(); //Closes the dialog
              },
              child: const Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tic Tac Toe"),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Player one score
                Row(children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      "Player 1 (X) score:",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Text(
                    "$scorePlayer1",
                    style: const TextStyle(fontSize: 15),
                  ),
                ]),
                // Player two score
                Row(children: [
                  const Text(
                    "Player 2 (O) score: ",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text(
                      "$scorePlayer2",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ]),
              ]),
          //Cells of the board
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < 3; j++)
                GestureDetector(
                  onTap: () {
                    makeMove(0, j); //Makes a move when a cell is tapped
                  },
                  child: Container(
                    //Cell container
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      //Border of the cell, like the table
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      //Displays the image/marker
                      child: getImage(board[0][j]),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            //Repeat two more times for the other two rows
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < 3; j++)
                GestureDetector(
                  onTap: () {
                    makeMove(1, j);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: getImage(board[1][j]),
                    ),
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int j = 0; j < 3; j++)
                GestureDetector(
                  onTap: () {
                    makeMove(2, j);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: getImage(board[2][j]),
                    ),
                  ),
                ),
            ],
          ),
          //Shows the player's turn
          Text(
            "Turn: " + (playerOneTurn ? "Player 1" : "Player 2"),
            style: const TextStyle(fontSize: 20),
          ),
          //Buttons to pick images for each player
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 100,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    pickImage(true);
                  },
                  backgroundColor: Colors.blue,
                  child: const Text(
                    "Pick Player 1's Image",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 20), //Space between the buttons
              Container(
                width: 100,
                height: 40,
                child: FloatingActionButton(
                  onPressed: () {
                    pickImage(false);
                  },
                  backgroundColor: Colors.red,
                  child: const Text(
                    "Pick Player 2's Image",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
