pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

/**
 @title CryptomonFactory contract
 @author Selim Sahnoun / Fabrice Tapia
 @dev Contract which is a part of the Alyra's challenge 4
 */

contract CryptomonFactory is Ownable {

    // Basic definition of a cryptomon
    struct Cryptomon{
        uint idCryptomon;
        string name;
        uint level;
        uint idSpell;
        uint lastExchange;
        uint actualExp;
        uint probabilityToCatch;
        int16 hunger;
        uint captureDate;
        uint8 idCryptomonEvolution;
        uint8 levelNeededForEvolution;
        uint lastMealTime;
    }

    // Basic definition of a cryptomon combat stats
    struct Combat{
        uint idCryptomon;
        uint16 damageBonus;
        uint dodgeRate;
        int winCount;
        int lossCount;
    }

    // Basic definition of a cryptomon health stats
    struct Health{
        uint idCryptomon;
        uint16 totHealthPoint;
        uint16 healthPoint;
        uint16 healthBonus;
    }


    // Basic definition of a spell linked to the cryptomon idSpell and damage
    struct SpellAndDamage{
        uint id;
        string spell;
        uint damage;
    }

    // Mapping listing all cryptomons for each player
    //mapping(address => Cryptomon[]) internal ownerToCryptomon;
    mapping(address => mapping(uint => Cryptomon)) public ownerToCryptomon;

    // Mapping returning the owner of a particular cryptomon
    mapping(uint => address) public cryptomonToOwner;

    // Mapping returning number of cryptomons for each player
    mapping(address => uint) public ownerCryptomonCount;

    // Mapping defining the experience needed for each level (mapping is filled in the constructor)
    mapping(uint => uint) public levelToExpNeededToLevelUp;

    // Mapping returning the last time the player clamed the daily free objects pack
    mapping(address => uint) public ownerToLastDateGetFreeObjects;


    // Mapping returning the last time the player clamed the daily free objects pack
    mapping(uint => Combat) internal cryptomonIdToCombat;

    // Mapping returning the last time the player clamed the daily free objects pack
    mapping(uint => Health) internal cryptomonIdToHealth;

    // List of existing cryptomon (array is filled in the constructor)
    Cryptomon[] public cryptomons;

    // List of existings spells (array is filled in the constructor)
    SpellAndDamage[] public spellAndDamage;

    // List of existing cryptomon (array is filled in the constructor)
    Combat[] public combatCryptomons;

    // List of existing cryptomon (array is filled in the constructor)
    Health[] public healthCryptomons;

    // Event used at the end of the evolve() function
    event Evolution(Cryptomon indexed _cryptomon);


    /**
    @notice defining basic elements needed for the game
    @dev
            defining mapping and arrays used for the good use of the game.
            cryptomons array is filled of Cryptomon structures.
            spellAndDamage array is filled of SpellAndDamage structures.
            levelToExpNeededToLevelUp is filled of key and values.
            Basically you need this contract to deployed the others.
     */
    constructor() public {

        cryptomons.push(Cryptomon(1,"cryptoChu",1,0,0,0,40,80,0,2,5,now));
        cryptomons.push(Cryptomon(2,"RaicryptoChu",1,4,0,0,20,80,0,0,0,now));

        cryptomons.push(Cryptomon(3,"cryptoMeche",1,1,0,0,60,80,0,4,5,now));
        cryptomons.push(Cryptomon(4,"cryptoCel",1,5,0,0,40,80,0,5,8,now));
        cryptomons.push(Cryptomon(5,"cryptoFeu",1,8,0,0,20,80,0,0,0,now));

        cryptomons.push(Cryptomon(6,"cryptoPuce",1,2,0,0,60,80,0,7,5,now));
        cryptomons.push(Cryptomon(7,"cryptoBaffe",1,6,0,0,40,80,0,8,8,now));
        cryptomons.push(Cryptomon(8,"cryptoTank",1,9,0,0,20,80,0,0,0,now));

        cryptomons.push(Cryptomon(9,"BulbiCrypto",1,3,0,0,60,80,0,10,5,now));
        cryptomons.push(Cryptomon(10,"HerbiCrypto",1,7,0,0,40,80,0,11,8,now));
        cryptomons.push(Cryptomon(11,"FloriCrypto",1,10,0,0,20,80,0,0,0,now));

        healthCryptomons.push(Health(1,100,100,0));
        healthCryptomons.push(Health(2,150,150,0));

        healthCryptomons.push(Health(3,100,100,0));
        healthCryptomons.push(Health(4,130,130,0));
        healthCryptomons.push(Health(5,180,180,0));

        healthCryptomons.push(Health(6,100,100,0));
        healthCryptomons.push(Health(7,130,130,0));
        healthCryptomons.push(Health(8,180,180,0));

        healthCryptomons.push(Health(9,100,100,0));
        healthCryptomons.push(Health(10,130,130,0));
        healthCryptomons.push(Health(11,180,180,0));

        spellAndDamage.push(SpellAndDamage(1,"Eclair", 5));
        spellAndDamage.push(SpellAndDamage(2,"Flammèche", 5));
        spellAndDamage.push(SpellAndDamage(3,"Ecume", 5));
        spellAndDamage.push(SpellAndDamage(4,"Fouet Liane", 5));


        spellAndDamage.push(SpellAndDamage(5,"Tonnerre", 15));
        spellAndDamage.push(SpellAndDamage(6,"Flammèche", 10));
        spellAndDamage.push(SpellAndDamage(7,"Pistolet à O", 10));
        spellAndDamage.push(SpellAndDamage(8,"Tranch'Herbe", 10));

        spellAndDamage.push(SpellAndDamage(9,"Lance-Flamme", 10));
        spellAndDamage.push(SpellAndDamage(10,"Hydrocanon", 10));
        spellAndDamage.push(SpellAndDamage(11,"Lance-Soleil", 10));

        levelToExpNeededToLevelUp[1] = 20;
        levelToExpNeededToLevelUp[2] = 40;
        levelToExpNeededToLevelUp[3] = 60;
        levelToExpNeededToLevelUp[4] = 120;
        levelToExpNeededToLevelUp[5] = 240;
        levelToExpNeededToLevelUp[6] = 480;
        levelToExpNeededToLevelUp[7] = 960;
        levelToExpNeededToLevelUp[8] = 1920;
        levelToExpNeededToLevelUp[9] = 3840;

    }

}
