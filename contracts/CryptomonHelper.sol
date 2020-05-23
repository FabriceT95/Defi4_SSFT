pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./CryptomonFactory.sol";
import "./SafeMath.sol";

/**
 @title CryptomonHelper contract
 @author Selim Sahnoun / Fabrice Tapia
 @dev Contract which is a part of the Alyra's challenge 4
 */

contract CryptomonHelper is CryptomonFactory{

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    // Basic definition of "cryptoBalls" objects
    struct cryptoBalls{
        int simpleCryptoballs;
        int superCryptoballs;
        int hyperCryptoballs;
    }

    struct cryptoFood{
        // SELIM
    }

    // default fee needed to buy a cryptoball (can be set with setCryptoballFee() )
    uint cryptoballFee = 0.0001 ether;

    // Mapping returning the cryptoBalls structure for each player
    mapping(address => cryptoBalls) ownerToCryptoballs;

    // Mapping returning the cryptoFood structure for each player
    mapping(address => cryptoFood) ownerToCryptofood;


    /**
    @notice The game owner can modify the purchase fee of a cryptoball
    @dev
            Just setting an amount to the cryptoballFee variable
    @param _fee Fee's amount to setup
     */
    function setCryptoballFee(uint _fee) public onlyOwner {
        cryptoballFee = _fee;
    }


    /**
    @notice Players can purchase cryptoball which depends on the type asked
    @dev
            This function needs a value (1,2,3)
            It can be called by the UI
            Depending on the param value, it increments the corresponding variable in the cryptoBalls structure of the sender
    @param _typeof Type of the cryptoball asked
     */

    function getCryptoball(uint _typeof) public payable {
        require(msg.value == cryptoballFee * _typeof);
        if(_typeof == 1){
            ownerToCryptoballs[msg.sender].simpleCryptoballs++;
        }
        else if(_typeof == 2){
            ownerToCryptoballs[msg.sender].superCryptoballs++;
        }
        else if(_typeof == 3){
            ownerToCryptoballs[msg.sender].hyperCryptoballs++;
        }

    }


    function getFood(uint _typeof) public payable{
        // SELIM
    }

    function feed(uint _cryptomonId, uint _typeof) public {
        // SELIM
    }


    /**
    @notice Basic random function
    @dev
            This function needs a modulo to return a random number between 0 and modulo.
            It is used multiple time in the game
    @return Random number between 0 and modulo
    */
    function randomFunction(uint8 modulo) internal view returns (uint8) {
        return uint8(blockhash(block.number-1)) % modulo;
    }

    function getCountCryptomons() view internal returns(uint) {
        return cryptomons.length;
    }


    /**
    @notice Each day, a player can ask for free objects. Basic F2P game stuff
    @dev
            This function checks if the last time the user asked free objects.
            If it's ok, update his last time he asks free objects and gives him in a random way objects with more or less probability

     */
    function getFreeObject() public {
        require(ownerToLastDateGetFreeObjects[msg.sender] == 0 || now - ownerToLastDateGetFreeObjects[msg.sender] >= 1 days );
        ownerToLastDateGetFreeObjects[msg.sender] = now;
        ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(3)+1);
        if(randomFunction(100) > 50){
            ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(2)+1);
        }
        if(randomFunction(100) > 75){
            ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(1)+1);
        }

        // AJOUTER DE LA NOURRITURE A OBTENIR DE FACON ALEATOIRE
    }
}
