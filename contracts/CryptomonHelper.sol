pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./CryptomonFactory.sol";
import "./SafeMath.sol";
import "./SignedSafeMath.sol";

/**
 @title CryptomonHelper contract
 @author Selim Sahnoun / Fabrice Tapia
 @dev Contract which is a part of the Alyra's challenge 4
 */

contract CryptomonHelper is CryptomonFactory{

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    using SignedSafeMath for int;

    // Basic definition of "cryptoBalls" objects
    struct cryptoBalls{
        uint simpleCryptoballs;
        uint superCryptoballs;
        uint hyperCryptoballs;
    }

    // Basic definition of "Food" objects
    struct cryptoFood{
        uint simplePotion;
        uint superPotion;
        uint hyperPotion;
        uint fullRestore;
        uint maxRestore;
    }

    uint randNonce;

    // default fee needed to buy a cryptoball (can be set with setCryptoballFee() )
    uint cryptoballFee = 0.0001 ether;

    // default fee needed to buy a potion (can be set with setPotionFee() )
    uint potionFee = 0.0001 ether;

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
    @notice The game owner can modify the purchase fee of a potion
    @dev
            Just setting an amount to the potion variable
    @param _fee Fee's amount to setup
     */
    function setPotionFee(uint _fee) public onlyOwner {
        potionFee = _fee;
    }

    /**
    @notice Basic random function
    @dev
            This function needs a modulo to return a random number between 0 and modulo.
            It is used multiple time in the game
    @return Random number between 0 and modulo
    */
    function randomFunction(uint modulo) internal returns (uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % modulo;
    }


    // Returns number of existing cryptomons
    function getCountCryptomons() view internal returns(uint) {
        return cryptomons.length;
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


    /**
    @notice Players can purchase potions which depends on the type asked
    @dev
            This function needs a value (1,2,3,4,10)
            It can be called by the UI
            Depending on the param value, it increments the corresponding variable in the cryptoFood structure of the sender
    @param _typeof Type of the potion asked
     */
    function getFood(uint _typeof) public payable{

        require(msg.value == potionFee * _typeof);

        if(_typeof == 1){
            ownerToCryptofood[msg.sender].simplePotion++;
        }
        else if(_typeof == 2){
            ownerToCryptofood[msg.sender].superPotion++;
        }
        else if(_typeof == 3){
            ownerToCryptofood[msg.sender].hyperPotion++;
        }
        else if(_typeof == 4){
            ownerToCryptofood[msg.sender].fullRestore++;
        }
        else if(_typeof == 10){
            ownerToCryptofood[msg.sender].maxRestore++;
        }

    }


    /**
    @notice
    Players can feed potions which will affect the hunger of the cryptomon :
        - if hunger is above 100, it will hit the health point
        - if hunger is 0, it will prevent the cryptomon from fighting
        - The hunger drops by 1 pt every 4 hours = 14 400 sec
    @dev
            It can be called only by the cryptomon owner
            This function needs a value (1,2,3,4,10) to determin which potion to use
            We need a function to check the hunger that can be called by the user

    @param _cryptomonId cryptomon's id targetted for the update
     */
    function hungerUpdate (uint _cryptomonId) public view returns(uint) {
        require(cryptomonToOwner[_cryptomonId] == msg.sender);
        return ownerToCryptomon[msg.sender][_cryptomonId].hunger.sub((now.sub(ownerToCryptomon[msg.sender][_cryptomonId].lastMealTime)).div(14400));
    }


    function feed(uint _cryptomonId, uint _typeof) public {

        require(cryptomonToOwner[_cryptomonId] == msg.sender);
        ownerToCryptomon[msg.sender][_cryptomonId].hunger = hungerUpdate(_cryptomonId); //plus besoin de require hunger >0 puisque ça ne tue pas le cryptomon

        //We check the potion selected to the hunger, simplePotion : +20, super: +40, hyper: +60, max restore = full restore hunger + 5 bonus health points.
        if(_typeof == 1){
            require(ownerToCryptofood[msg.sender].simplePotion>0);
            ownerToCryptofood[msg.sender].simplePotion--;
            ownerToCryptomon[msg.sender][_cryptomonId].hunger += 20;
        }
        else if(_typeof == 2){
            require(ownerToCryptofood[msg.sender].superPotion>0);
            ownerToCryptofood[msg.sender].superPotion--;
            ownerToCryptomon[msg.sender][_cryptomonId].hunger += 40;
        }
        else if(_typeof == 3){
            require(ownerToCryptofood[msg.sender].hyperPotion>0);
            ownerToCryptofood[msg.sender].hyperPotion--;
            ownerToCryptomon[msg.sender][_cryptomonId].hunger += 60;
        }
        else if(_typeof == 4){
            require(ownerToCryptofood[msg.sender].fullRestore>0);
            ownerToCryptofood[msg.sender].fullRestore--;
            ownerToCryptomon[msg.sender][_cryptomonId].hunger += 100;
        }
        else if(_typeof == 10){
            require(ownerToCryptofood[msg.sender].maxRestore>0);
            ownerToCryptofood[msg.sender].maxRestore--;
            ownerToCryptomon[msg.sender][_cryptomonId].hunger = 100;
            cryptomonIdToHealth[_cryptomonId].healthBonus.add(5);
            cryptomonIdToHealth[_cryptomonId].totHealthPoint = cryptomonIdToHealth[_cryptomonId].healthBonus + cryptomonIdToHealth[_cryptomonId].healthPoint;
        }
        //Hunger can't exceed 100. The drawback is minus tothealthpoints
        if (ownerToCryptomon[msg.sender][_cryptomonId].hunger >100){
            cryptomonIdToHealth[_cryptomonId].totHealthPoint.sub(ownerToCryptomon[msg.sender][_cryptomonId].hunger - 100);
            ownerToCryptomon[msg.sender][_cryptomonId].hunger = 100;
        }
        cryptomons[_cryptomonId].lastMealTime = now;

    }





    /**
    @notice Each day, a player can ask for free objects. Basic F2P game stuff
    @dev
            This function checks if the last time the user asked free objects.
            If it's ok, update his last time he asks free objects and gives him in a random way objects with more or less probability

     */
    function getFreeObject() public {

        require(ownerToLastDateGetFreeObjects[msg.sender] == 0 || now - ownerToLastDateGetFreeObjects[msg.sender] >= 1 days );

        ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(3)+1);
        ownerToCryptofood[msg.sender].simplePotion.add(randomFunction(3)+1);

        if(randomFunction(100) > 50){
            ownerToCryptoballs[msg.sender].superCryptoballs.add(randomFunction(2)+1);
        }
        if(randomFunction(100) > 75){
            ownerToCryptoballs[msg.sender].hyperCryptoballs.add(randomFunction(1)+1);
        }
        if(randomFunction(100) > 50){
            ownerToCryptofood[msg.sender].superPotion.add(randomFunction(1)+1);
        }
        if(randomFunction(100) > 75){
            ownerToCryptofood[msg.sender].hyperPotion.add(randomFunction(1)+1);
        }
        if(randomFunction(100) > 90){
            ownerToCryptofood[msg.sender].fullRestore.add(randomFunction(1)+1);
        }
        ownerToLastDateGetFreeObjects[msg.sender] = now;

    }
}
