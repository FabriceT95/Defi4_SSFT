pragma solidity 0.4.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

/**
 @title CryptomonFactory contract
 @author Selim Sahnoun / Fabrice Tapia
 @dev Contract which is a part of the Alyra's challenge 4
 */

contract CryptomonFactory is Ownable {

    // Kind enum is useful for the function fight() in cryptomonCombat.sol (weakness and strength)
    enum Kind {WATER, FIRE, GRASS, ELECTRIK, NEUTRAL}

    // Basic definition of a cryptomon
    struct Cryptomon{
        uint idCryptomon;
        uint idInventory;
        string name;
        uint32 level;
        uint idSpell;
        Kind kind;
        uint lastExchange;
        uint actualExp;
        uint probabilityToCatch;
        int hungry;
        uint captureDate;
        int healthPoint;
        int totHealthPoint;
        uint dodgeRate;
        uint winCount;
        uint lossCount;
        int damageBonus;
        int healthBonus;
        uint8 idCryptomonEvolution;
        uint8 levelNeededForEvolution;
        int lastMealTime; //J'ai rajouté ça pour pouvoir avoir un repère pour la descente de la faim
    }

    // Basic definition of a spell linked to the cryptomon idSpell and damage
    struct SpellAndDamage{
        uint id;
        string spell;
        int damage;
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


    // List of existing cryptomon (array is filled in the constructor)
    Cryptomon[] public cryptomons;

    // List of existings spells (array is filled in the constructor)
    SpellAndDamage[] public spellAndDamage;

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

        cryptomons.push(Cryptomon(1,0,"cryptoChu", 1, 0,Kind.ELECTRIK,0,0,20,80,0,100,100,5,0,0,1,0,2,5,now));
        cryptomons.push(Cryptomon(2,0,"RaicryptoChu", 1, 4,Kind.ELECTRIK,0,0,20,80,0,150,150,5,0,0,1,0,0,0,now));

        cryptomons.push(Cryptomon(3,0,"cryptoMeche",1,1,Kind.FIRE,0,0,20,80,0,100,100,5,0,0,1,0,4,5,now));
        cryptomons.push(Cryptomon(4,0,"cryptoCel",1,5,Kind.FIRE,0,0,20,80,0,130,130,5,0,0,1,0,5,8,now));
        cryptomons.push(Cryptomon(5,0,"cryptoFeu",1,8,Kind.FIRE,0,0,20,80,0,180,180,5,0,0,1,0,0,0,now));

        cryptomons.push(Cryptomon(6,0,"cryptoPuce",1,2,Kind.WATER,0,0,20,80,0,100,100,5,0,0,1,0,7,5,now));
        cryptomons.push(Cryptomon(7,0,"cryptoBaffe",1,6,Kind.WATER,0,0,20,80,0,130,130,5,0,0,1,0,8,8,now));
        cryptomons.push(Cryptomon(8,0,"cryptoTank",1,9,Kind.WATER,0,0,20,80,0,180,180,5,0,0,1,0,0,0,now));

        cryptomons.push(Cryptomon(9,0,"cryptoZare",1,3,Kind.GRASS,0,0,20,80,0,100,100,5,0,0,1,0,10,5,now));
        cryptomons.push(Cryptomon(10,0,"cryptoBaffe",1,7,Kind.GRASS,0,0,20,80,0,130,130,5,0,0,1,0,11,8,now));
        cryptomons.push(Cryptomon(11,0,"cryptoTank",1,10,Kind.GRASS,0,0,20,80,0,180,180,5,0,0,1,0,0,0,now));

        spellAndDamage.push(SpellAndDamage(0,"Eclair", 5));
        spellAndDamage.push(SpellAndDamage(1,"Flammèche", 5));
        spellAndDamage.push(SpellAndDamage(2,"Ecume", 5));
        spellAndDamage.push(SpellAndDamage(3,"Fouet Liane", 5));


        spellAndDamage.push(SpellAndDamage(4,"Tonnerre", 15));
        spellAndDamage.push(SpellAndDamage(5,"Flammèche", 10));
        spellAndDamage.push(SpellAndDamage(6,"Pistolet à O", 10));
        spellAndDamage.push(SpellAndDamage(7,"Tranch'Herbe", 10));

        spellAndDamage.push(SpellAndDamage(8,"Lance-Flamme", 10));
        spellAndDamage.push(SpellAndDamage(9,"Hydrocanon", 10));
        spellAndDamage.push(SpellAndDamage(10,"Lance-Soleil", 10));

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


    /**
    @notice evolving your crytomon when his experience needed is reached
    @dev
            It modifies the content of the cryptomon object by his evolution (defined in the cryptomons array of structure Cryptomon).
            You can create new evolutions by adding more Cryptomon structures in the cryptomons array and adapting his "idCryptomonEvolution".
            Then you need to re-deploy all contracts after this one.
            Evolution emit will display on the UI

    @param _cryptomon cryptomon which reached his experience needed for evolution

     */
    function evolve(Cryptomon _cryptomon) external {
        Cryptomon memory evolCryptomon = cryptomons[_cryptomon.idCryptomonEvolution];
        _cryptomon.idCryptomon = evolCryptomon.idCryptomon;
        _cryptomon.name = evolCryptomon.name;
        _cryptomon.idSpell = evolCryptomon.idSpell;
        _cryptomon.healthPoint = evolCryptomon.healthPoint;
        _cryptomon.totHealthPoint = evolCryptomon.healthPoint + _cryptomon.healthBonus;
        _cryptomon.idCryptomonEvolution = evolCryptomon.idCryptomonEvolution;
        _cryptomon.levelNeededForEvolution = evolCryptomon.levelNeededForEvolution;
        emit Evolution(_cryptomon);
    }

}
