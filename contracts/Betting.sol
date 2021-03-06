// contracts/Betting.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";

contract Betting {
    uint256 public minimumBet;
    uint256 public totalBetsOne;
    uint256 public totalBetsTwo;
    uint256 public numberOfBets;
    uint256 public maximumAmountOfBets = 1000;

    address payable[] public players;

    struct Player {
        uint256 amountBet;
        uint16 teamSelected;
    }

    // Address of the player and => the user info
    mapping(address => Player) public playerInfo;

    constructor() {
        minimumBet = 100000000000000;
    }

    function checkPlayerExists(address player) public view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) return true;
        }
        return false;
    }

    function makeBet(uint8 _teamSelected) public payable {
        require(!checkPlayerExists(msg.sender), "You have already bet");
        require(msg.value >= minimumBet, "You must bet at least the minimum bet");

        //We set the player informations : amount of the bet and selected team
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].teamSelected = _teamSelected;

        //then we add the address of the player to the players array
        players.push(payable(msg.sender));

        //at the end, we increment the stakes of the team selected with the player bet
        if (_teamSelected == 1) {
            totalBetsOne += msg.value;
        } else {
            totalBetsTwo += msg.value;
        }
    }

    function distributePrizes(uint16 teamWinner) public {
        address payable[1000] memory winners;
        //We have to create a temporary in memory array with fixed size
        //Let's choose 1000
        uint256 count = 0; // This is the count for the array of winners
        uint256 loserBet = 0; //This will take the value of all losers bet
        uint256 winnerBet = 0; //This will take the value of all winners bet
        address add;
        uint256 bet;
        address payable playerAddress;

        //We loop through the player array to check who selected the winner team
        for (uint256 i = 0; i < players.length; i++) {
            playerAddress = players[i];
            //If the player selected the winner team
            //We add his address to the winners array
            if (playerInfo[playerAddress].teamSelected == teamWinner) {
                winners[count] = playerAddress;
                count++;
            }
        }
        //We define which bet sum is the Loser one and which one is the winner
        if (teamWinner == 1) {
            loserBet = totalBetsTwo;
            winnerBet = totalBetsOne;
        } else {
            loserBet = totalBetsOne;
            winnerBet = totalBetsTwo;
        }

        //We loop through the array of winners, to give ethers to the winners
        for (uint256 j = 0; j < count; j++) {
            // Check that the address in this fixed array is not empty
            if (winners[j] != address(0)) add = winners[j];
            bet = playerInfo[add].amountBet;
            //Transfer the money to the user
            winners[j].transfer(
                (bet * (10000 + ((loserBet * 10000) / winnerBet))) / 10000
            );
        }

        delete playerInfo[playerAddress]; // Delete all the players
        delete players; // Delete all the players array
        loserBet = 0; //reinitialize the bets
        winnerBet = 0;
        totalBetsOne = 0;
        totalBetsTwo = 0;
    }

    function AmountOne() public view returns (uint256) {
        return totalBetsOne;
    }

    function AmountTwo() public view returns (uint256) {
        return totalBetsTwo;
    }
}
