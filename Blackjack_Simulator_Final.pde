//IMPORTED LIBRARIES
import controlP5.*; //button library
import javax.swing.JOptionPane; //dialog box library
import java.io.BufferedWriter; //writing library
import java.io.FileWriter; //file writing library
import java.util.ArrayList; //imported library to have access to more ArrayList functions
import java.util.Collections; //imported library to have access to the shuffle method native to the Collections library
//the shuffle method is used to "shuffle" the deck
//Source: http://java2novice.com/java-collections-and-util/arraylist/shuffle/

//GLOBALS
ArrayList<Player> players = new ArrayList<Player>(); //ArrayList to hold all players in game
ArrayList<Card> deck = new ArrayList<Card>(); //ArrayList to hold all 52 cards
Dealer dealer = new Dealer();
//Player player = new Player();
ControlP5 cp5;
String fileName = "data.txt";
String numberOfPlayers;
String numberOfSimulations;
int numberOfPushes; //contains the number of "games" where no one wins
//Player inputs

//USER-SPECIFIED VARIABLES
//int playerAmount; //number of players in the game (will be user-specified)
//String otherCard; //will not be hardcoded in end, using for threshold 
String aceRule; //if player has at least one ace and a total >= to input, player stands
//int simulationNumber = 50; //number of simulations ran
//Ace rule is the total that denotes what the ace, if a user has one, is equal to (i.e. ace rule is 16, and the user has an ace and a 4, the ace is equal to 11)
String cardThreshold; //card total that is user-specified; denotes when the user hits
//Card Threshold is the total that denotes if the user hits (i.e. if the card threshold is 15, and the user has 14, they hit)

void setup() {
  size(1300, 800);
  background(0, 125, 0);
  frameRate(30);

  cp5 = new ControlP5(this); //instantiate new instance of ControlP5, used to create textfields and event triggers
  cp5.addTextfield("Number of simulations").setPosition(25, 625).setSize(70, 40).setAutoClear(false); //create textfield
  cp5.addTextfield("Number of players").setPosition(125, 625).setSize(70, 40).setAutoClear(false); //create other textfield
  cp5.addTextfield("Ace Rule").setPosition(225, 625).setSize(70, 40).setAutoClear(false); //create textfield
  cp5.addTextfield("Card Threshold").setPosition(325, 625).setSize(70, 40).setAutoClear(false); //create textfield
  cp5.addBang("submit").setPosition(800, 625).setSize(80, 40); //submit button to start simulation
}

void draw() {
  background(0, 125, 0);
  
  //Felt texture added to the table -- CODED BY DR. MORGAN -- DISABLE IF TOO SLOW FOR COMPUTER TO RUN
  randomSeed(10);
  for(int i = 0; i < 30000; i++) { //creating individual felt pieces
    stroke(0, 125 + random(-15,15), 0); //determines the color of the stroke based on the background  color
    float x = random(0, width); //starting x point
    float y = random(0, height); //starting y point
    float dx = random(-5,5); //end x point
    float dy = random(-5,5); //end y point
    line(x,y,x+dx,y+dy); //creating lines for the felt
  }
  
  fill(255);
  text("Instructions:", 5, 15);
  text("Input the number of simulations, number of players (2-6), the Ace Rule Threshold, and the Card Threshold", 5, 30);
  text("Ace Rule Instructions: The number you input is equal to the maximum total between the two cards that an Ace equals 11. Above that, it is equal to 1.", 5, 60);
  text("I.e. If you input 17, and you have an ace, any total below that will have an ace equal to 11.", 5, 75);
  text("Card Threshold Instructions: The number you input is representative of if you hit or not.", 5, 105);
  text("I.e. If you input 17, you will continue to hit until you have exceeded 17 as your card total.", 5, 120);
  text("NOTE: The dealer can have more wins than number of simulations due to playing against EACH PLAYER.", 5, 150);
  text("That means that the maximum number of wins is equal to number of simulations * number of players.", 5, 165);
  text("Dealer wins in current simulation: " + dealer.totalWins, 425, 665);
  for (int i = 0; i < players.size(); i++) { //shows the user's cards and the number of wins they have
    text("Player " + (i+1) + " wins: " + players.get(i).totalWins, 425, 600+(i*10));
  }
  text("Number of pushes: " + numberOfPushes, 425, 680); 
  text("NOTE: The cards displayed are the last hand. The program does not have code to show each hand.", 425, height/2+300);

  //this block of code is reserved for drawing the user's cards (use for loop, draw player's cards and dealer's cards

  //Should we display all of the cards (such as if a person hits and gets a third card? How should we do that?
  //NOTE: Reconstruct deck creation to have all cards get name, suit, and card image in one function

  for (int i = 0; i < players.size(); i++) { //iterate through the players arraylist to display cards
    int xpos = 100+(i*200); //integer value used to display cards, increases based on current i'th player
    image(players.get(i).hand.get(0).face, xpos, 250); //second card
    for (int j = 1; j < players.get(i).hand.size(); j++) {
      image(players.get(i).hand.get(j).face, xpos+(j*20), 250); //first card
      text("Player " + (i+1) + " hand", xpos+10, 410); //text to denote each hand
    }
  }

  if (dealer.hand.size() > 0) { //only print the cards if the hand actually has cards in it/hand arraylist is populated
    image(dealer.hand.get(0).face, 1000, 500); //hardcoded value location of dealer's first card
    for (int i = 1; i < dealer.hand.size(); i++) {
      //image(dealer.hand.get(1).face, 1020, 500); //hardcoded value location of dealer's second card
      image(dealer.hand.get(i).face, 1000+(i*20), 500);
      text("Dealer's hand", 1020, 660); //text of dealer's hand
    }
  }
}

void submit() { //function that is called whenever the submit button is pressed
  //Obtains the number of players and number of simulations submitted by the user
  numberOfPlayers = cp5.get(Textfield.class, "Number of players").getText();
  numberOfSimulations = cp5.get(Textfield.class, "Number of simulations").getText();
  aceRule = cp5.get(Textfield.class, "Ace Rule").getText();
  cardThreshold = cp5.get(Textfield.class, "Card Threshold").getText();

  if (numberOfPlayers.equals("") || numberOfSimulations.equals("") || aceRule.equals("") || cardThreshold.equals("") ||
    isNumeric(numberOfPlayers) == false || isNumeric(numberOfSimulations) == false || isNumeric(aceRule) == false || isNumeric(cardThreshold) == false
    || int(numberOfPlayers) < 0 || int(numberOfPlayers) > 6 || int(aceRule) < 2 || int(aceRule) > 21
    || int(cardThreshold) < 1 || int(cardThreshold) > 21
    ) {
    println("One or more of the fields have not been filled, or a field contained an invalid input.");
  } else {
    //for loop to start simulation
    players.clear();
    startSimulation(int(numberOfPlayers), int(numberOfSimulations));
    background(0, 125, 0); //call background to clear canvas
  }
}

//Function to determine how many simulations start, takes in number of players and number of simulations
void startSimulation (int howManyPlayers, int howManySimulations) { 
  dealer.totalWins = 0; //reset dealer wins so it only counts once the full amount of simulations has finished
  numberOfPushes = 0; //resets it so that it only counts when the simulation starts

  for (int i = 0; i < howManyPlayers; i++ ) { //populate players ArrayList
    players.add(new Player("Player " + i+1)); //add new Player object to ArrayList
    //pass in the String "Player" and the spot of the player (Player 1, Player 2, etc.)
  }

  for (int k = 0; k < howManySimulations; k++) { //for loop that runs the simulation the amount of times the user has specified
    createDeck(); //first create the deck (clears deck within the function)
    dealCards(); //deal out cards to begin game
    for (int j = 0; j < players.size(); j++) { //iterate through the player arraylist to have them choose whether to hit or stand
      players.get(j).decision(); //each person makes a decision
    }
    dealer.decision(); //dealer chooses whether to hit or stand
    checkWinner(); //determines who wins, player or dealer
  }
}


//Function for checking if user specified values are numerical
//Source: http://stackoverflow.com/questions/14206768/how-to-check-if-a-string-is-numeric
boolean isNumeric (String input) { //function found via Stackoverflow that returns a boolean based on whether or not a passed string is a number
  return input.matches("[-+]?\\d*\\.?\\d+");
  //the above uses the .matches function for regular expression to check if the passed string, when parsed through regex, is true
  //.matches returns a boolean variable, which is then returned by the function
}

void checkWinner() { //checks who wins and who loses
  //WIN CONDITIONS
  for (int i = 0; i < players.size(); i++) { //iterate through the players ArrayList
    if (players.get(i).total == 21 && dealer.total < 21) { //if the player has blackjack
      players.get(i).winCounter++;
      players.get(i).totalWins++;
      println("player " + i + "wins");
    } else if (dealer.total == 21 && players.get(i).total < 21) { //if the dealer has blackjack
      dealer.winCounter++;
      dealer.totalWins++;
      println("dealer wins");
    } else if (dealer.total == 21 && players.get(i).total == 21) { //push, no one wins
      println("No one wins");
      println("Dealer total: " + dealer.total);
      println("Player" + i + "'s total: " + players.get(i).total);
      numberOfPushes++;
    } else if (players.get(i).total == dealer.total) { //if the dealer and player have the same total; push
      println("No one wins");
      println("Dealer total: " + dealer.total);
      println("Player" + i + "'s total: " + players.get(i).total);
      numberOfPushes++;
    } else if (players.get(i).total > 21 && dealer.total > 21) { //if both the player and the dealer bust
      dealer.winCounter++;
      dealer.totalWins++;
      println("dealer wins");
    } else if (players.get(i).total < dealer.total && dealer.total < 21) { //if the player's total is less than the dealer's and the dealer doesn't have blackjack
      dealer.winCounter++;
      dealer.totalWins++;
      println("dealer wins");
    } else if (dealer.total < players.get(i).total && players.get(i).total < 21) { //if the dealer's total is less than the player's total and the player doesn't have blackjack
      players.get(i).winCounter++;
      players.get(i).totalWins++;
      println("player " + i + "wins");
    }
  }
}


void dealCards() { //setting up hands for the players and the dealer
  for (int i = 0; i < players.size(); i++) { //clear players' hands
    players.get(i).hand.clear();
  }
  dealer.hand.clear(); //clear dealer's hand

  for (int i = 0; i < players.size(); i++) { //first card dealt to each player
    players.get(i).hand.add(deck.get(0)); //access the player, then access the "top" card of the deck and give it to the player
    players.get(i).hand.get(0).visible = true; //card is face up
    players.get(i).hand.get(0).face = loadImage(players.get(i).hand.get(0).name + ".png"); //load the card associated with the name of the card
    /*
    example: if the card is ace of clubs, the card.name's value is "aceOfClubs"
     we have every card in a traditional deck named in such style (camelcase) in a folder (or same directory)
     then when we want to load the card's image, we just pass in the name of the card as the file name
     */
    deck.remove(0); //remove the 0'th card from the deck, because it's no longer accessible by the players
  }

  dealer.hand.add(deck.get(0)); //dealer is dealt 1 card
  dealer.hand.get(0).visible = true; //card is face up
  dealer.hand.get(0).face = loadImage(dealer.hand.get(0).name + ".png"); //load the dealer's first card's image
  deck.remove(0); //remove the top card


  for (int i = 0; i < players.size(); i++) { //second card dealt to each player
    players.get(i).hand.add(deck.get(0)); //give each player the top card of the deck
    players.get(i).hand.get(1).visible = true; //second card is face down
    players.get(i).hand.get(1).face = loadImage(players.get(i).hand.get(1).name + ".png"); //load faceup card because it's visible during the game
    deck.remove(0); //remove it so that other players can't have the same card
  }

  dealer.hand.add(deck.get(0)); //give the dealer the second card from the top of the deck
  dealer.hand.get(1).visible = false; //second card is face down
  dealer.hand.get(1).face = loadImage("facedown.png"); //load facedown card because it's not visible during the game
  deck.remove(0); //remove it from the deck
}


void createDeck() { //function called to reset deck
  deck.clear(); //clear the deck if it has any remaining cards in it
  for (int i = 0; i < 52; i++) { //iterate through the deck and add 52 Card objects
    deck.add(new Card());
  }

  for (int i = 0; i < deck.size(); i++) { //setting the suits of each card
    //as long as the integer i is less than the size of the deck, do the following:
    if (i >= 0 && i <= 12) { //first set of 13 cards of the deck
      deck.get(i).spade = true; //set them to spades
      //deck.get(i).name = deck.get(i).name + "OfSpades";
    }
    if (i >= 13 && i <= 25) { //second set of 13 cards of the deck
      deck.get(i).club = true; //set them to clubs
      //deck.get(i).name = deck.get(i).name + "OfClubs";
    }
    if (i >= 26 && i <= 38) { //third set of 13 cards of the deck
      deck.get(i).heart = true; //set them to hearts
      //deck.get(i).name = deck.get(i).name + "OfHearts";
    }
    if (i >= 39 && i <= 51) { //fourth set of 13 cards of the deck
      deck.get(i).diamond = true; //set them to diamonds
      //deck.get(i).name = deck.get(i).name + "OfDiamonds";
    }
  }

  for (int i = 0; i < deck.size(); i++) { 
    //**deck.size()-1 because the size is 52, so we need to subtract 1 from it to make sure it doesn't access a non-existant array index
    //as long as the integer i is less than the size of the deck (52), do the following
    if (i >= 0 && i <= 3) { //2 of ___
      deck.get(i).name = "2";
      deck.get(i).value = 2;
    }
    if (i >= 4 && i<= 7) { //3 of ___
      deck.get(i).name = "3";
      deck.get(i).value = 3;
    }
    if (i >=8 && i<= 11) { //4 of ___
      deck.get(i).name = "4";
      deck.get(i).value = 4;
    }
    if (i >= 12 && i<= 15) { //5 of ___
      deck.get(i).name = "5";
      deck.get(i).value = 5;
    }
    if (i >= 16 && i<= 19) { //6 of ___
      deck.get(i).name = "6";
      deck.get(i).value = 6;
    }
    if (i >= 20 && i<= 23) { //7 of ___
      deck.get(i).name = "7";
      deck.get(i).value = 7;
    }
    if (i >= 24 && i<= 27) { //8 of ___
      deck.get(i).name = "8";
      deck.get(i).value = 8;
    }
    if (i >= 28 && i<= 31) { //9 of ___
      deck.get(i).name = "9";
      deck.get(i).value = 9;
    }
    if (i >= 32 && i<= 35) { //10 of ___
      deck.get(i).name = "10";
      deck.get(i).value = 10;
    }
    if (i >= 36 && i<= 39) { //Jack of ___
      deck.get(i).name = "jack";
      deck.get(i).value = 10;
    }
    if (i >= 40 && i<= 43) { //Queen of ___
      deck.get(i).name = "queen";
      deck.get(i).value = 10;
    }
    if (i >= 44 && i<= 47) { //King of ___
      deck.get(i).name = "king";
      deck.get(i).value = 10;
    }
    if (i >= 48 && i<= 51) { //Ace of ___
      deck.get(i).name = "ace";
      deck.get(i).value = 11; 
      //hardcoded as 11 because the computer will change the ace value if the total is less than the threshold specified by the user in the simulation
    }
  }


  //ASSIGNMENT OF CARD NAMES
  for (int q = 0; q < deck.size(); q = q+4) { //starting on the 0th card and every 4th card after that
    deck.get(q).name = deck.get(q).name + "_of_clubs"; //make it a club
  }

  for (int w = 1; w < deck.size(); w = w+4) { //starting on the first card and every 4th card after that
    deck.get(w).name = deck.get(w).name + "_of_hearts"; //make it a heart
  }

  for (int e = 2; e < deck.size(); e = e+4) { //starting on the second card and every 4th card after that
    deck.get(e).name = deck.get(e).name + "_of_spades"; //make it a spade
  }

  for (int r = 3; r < deck.size(); r = r+4) { //starting on the third card and every 4th card after that
    deck.get(r).name = deck.get(r).name + "_of_diamonds"; //make it a diamond
  }

  for (int i = 0; i < 7; i++) { //shuffles the deck 7 times (assumes the deck is being shuffled riffle style, which mathematically requires 7 shuffles to be adequately shuffled
    Collections.shuffle(deck); //shuffles deck
  }

  for (int i = 0; i < deck.size(); i++) { //iterate through the deck and load the cards' image values
    deck.get(i).face = loadImage(deck.get(i).name + ".png");
  }
}

class Card {
  int value; //what number is the card
  boolean spade; //if the card is a spade
  boolean club; //if the card is a club
  boolean heart; //if the card is a heart
  boolean diamond; //if the card is a diamond
  String name; //name of card ("King of diamonds, 2 of hearts, etc.)
  boolean visible; //true = visible, false = face down
  PImage face; //image value used to contain the face of the card (whether it's face up or down)

  Card() { //constructor for card
    value = 0; //value starts at 0
    spade = false; //does not have a suit when created
    club = false; 
    heart = false; 
    diamond = false;
  }

  void drawCard() { //draws the card, checks the boolean variable of the card and draws accordingly based on name and suit and stuff
    strokeWeight(1); 
    stroke(0); 
    rectMode(CORNER);
  }
}


class Player {
  ArrayList<Card> hand = new ArrayList <Card>(); //container to hold player's hand
  int winCounter; //counter of how many times the person has won a game of Blackjack
  int totalWins; //number of wins out of entire simulation
  //arraylist of cards for user
  int total; //holds the total between the cards the user has
  boolean out = false; //boolean variable to decide if the player is in or out of a Blackjack game
  int aceIndex; //holds the index of an ace if there is one present, only is set to a number of the acePreset is true
  boolean acePresent = false; //true if player has an ace
  String name; //what player they are (player 1, player 2, etc.)

  Player (String ID) {
    name = ID;
  }

  void decision() { //decide to stand or hit
    total = 0; 
    for (int i = 0; i < hand.size(); i ++) { //find card total
      total += hand.get(i).value; //summates card total
      if (hand.get(i).name.equals("ace")) { //checking if there's an ace
        acePresent = true; //set boolean variable to true for further modification in numbers
        aceIndex = i;
      }
    }
    //check for presence of ace
    if (acePresent && total <= int(aceRule)) { //if the player has an ace AND the total is less than the specified number for if they should draw another card if they have an ace
      hand.get(aceIndex).value = 1; //setting value of ace to 1, then proceed to draw card
      hit(); //receive another card
    } else if (total < int(cardThreshold)) { //else, meaning their total is still less than the user-specified card threshold
      hit();
    }
  }

  void hit() { //hit - get another card from the dealer/deck
    total = 0;
    for (int i = 0; i < hand.size(); i ++) { //find card total
      total += hand.get(i).value; //summates card total
    }
    if (acePresent) {
      while (total <= int(aceRule)) {
        hand.add(deck.get(0)); //access the player's hand and add the top card from the deck to their hand
        total += deck.get(0).value;
        deck.remove(0); //remove the card from the deck because it has been given to a player
      }
    } else {
      while (total <= int(cardThreshold)) {
        hand.add(deck.get(0)); //access the player's hand and add the top card from the deck to their hand
        total += deck.get(0).value;
        deck.remove(0); //remove the card from the deck because it has been given to a player
      }
    }
  }
}

class Dealer {
  ArrayList<Card> hand = new ArrayList <Card>(); //container to hold player's hand
  int total; //holds the total between the cards the dealer has
  int winCounter; //counter of how many times the dealer has won a game of BlackJack
  int totalWins; //number of wins out of entire simulation
  boolean out = false; //boolean variable to decide if the dealer is in or out of a Blackjack game
  boolean acePresent = false; //true if player has an ace
  int aceIndex; //holds the index of an ace if there is one present, only is set to a number of the acePreset is true

  void decision() { //decide to take another card or not
    total = 0; //total card amount
    for (int i = 0; i < hand.size(); i ++) { //find card total
      total += hand.get(i).value; //summate cards in hand
      if (hand.get(i).name == "ace") {
        acePresent = true; 
        aceIndex = i;
      }
    }
    //check for presence of ace
    if (acePresent && total <= int(aceRule)) { //if the dealer has an ace and their total is less than the user-specified card threshold
      hand.get(aceIndex).value = 1; //set their ace value to 1
      hit(); //receive another card
    } else if (total < int(cardThreshold)) { //else, meaning their total is still less than the user-specified card threshold
      hit();
    }
  }

    void hit() { //hit - get another card from the dealer/deck
    total = 0;
    for (int i = 0; i < hand.size(); i ++) { //find card total
      total += hand.get(i).value; //summates card total
    }
    if (acePresent) {
      while (total <= int(aceRule)) {
        hand.add(deck.get(0)); //access the player's hand and add the top card from the deck to their hand
        total += deck.get(0).value;
        deck.remove(0); //remove the card from the deck because it has been given to a player
      }
    } else {
      while (total <= int(cardThreshold)) {
        hand.add(deck.get(0)); //access the player's hand and add the top card from the deck to their hand
        total += deck.get(0).value;
        deck.remove(0); //remove the card from the deck because it has been given to a player
      }
    }
  }
}