pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract CryptomonFactory is Ownable {
    enum Kind {WATER, FIRE, GRASS, ELECTRIK, NEUTRAL}

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
        uint hungry;
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

    }

    struct SpellAndDamage{
        uint id;
        string spell;
        int damage;
    }

    uint lastDateGetFreeObjects;


    Cryptomon[] public cryptomons;
    SpellAndDamage[] public spellAndDamage;

    event Evolution();

    mapping(address => Cryptomon[]) public ownerToCryptomon;
    mapping(uint => address) cryptomonToOwner;
    mapping(address => uint) public ownerCryptomonCount;

    mapping(uint => uint) levelToExpNeededToLevelUp;

    constructor() public {
        cryptomons.push(Cryptomon(1,0,"cryptoChu", 1, 0,Kind.ELECTRIK,0,0,20,80,0,100,100,5,0,0,1,0,2,5));
        cryptomons.push(Cryptomon(2,0,"RaicryptoChu", 1, 4,Kind.ELECTRIK,0,0,20,80,0,150,150,5,0,0,1,0,0,0));

        cryptomons.push(Cryptomon(3,0,"cryptoMeche",1,1,Kind.FIRE,0,0,20,80,0,100,100,5,0,0,1,0,4,5));
        cryptomons.push(Cryptomon(4,0,"cryptoCel",1,5,Kind.FIRE,0,0,20,80,0,130,130,5,0,0,1,0,5,8));
        cryptomons.push(Cryptomon(5,0,"cryptoFeu",1,8,Kind.FIRE,0,0,20,80,0,180,180,5,0,0,1,0,0,0));

        cryptomons.push(Cryptomon(6,0,"cryptoPuce",1,2,Kind.WATER,0,0,20,80,0,100,100,5,0,0,1,0,7,5));
        cryptomons.push(Cryptomon(7,0,"cryptoBaffe",1,6,Kind.WATER,0,0,20,80,0,130,130,5,0,0,1,0,8,8));
        cryptomons.push(Cryptomon(8,0,"cryptoTank",1,9,Kind.WATER,0,0,20,80,0,180,180,5,0,0,1,0,0,0));

        cryptomons.push(Cryptomon(9,0,"cryptoZare",1,3,Kind.GRASS,0,0,20,80,0,100,100,5,0,0,1,0,10,5));
        cryptomons.push(Cryptomon(10,0,"cryptoBaffe",1,7,Kind.GRASS,0,0,20,80,0,130,130,5,0,0,1,0,11,8));
        cryptomons.push(Cryptomon(11,0,"cryptoTank",1,10,Kind.GRASS,0,0,20,80,0,180,180,5,0,0,1,0,0,0));

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

    function evolve(Cryptomon cryptomon) internal {
        Cryptomon memory evolCryptomon = cryptomons[cryptomon.idCryptomonEvolution];
        cryptomon.idCryptomon = evolCryptomon.idCryptomon;
        cryptomon.name = evolCryptomon.name;
        cryptomon.idSpell = evolCryptomon.idSpell;
        cryptomon.healthPoint = evolCryptomon.healthPoint;
        cryptomon.totHealthPoint = evolCryptomon.healthPoint + cryptomon.healthBonus;
        cryptomon.idCryptomonEvolution = evolCryptomon.idCryptomonEvolution;
        cryptomon.levelNeededForEvolution = evolCryptomon.levelNeededForEvolution;
        emit Evolution();
    }

}
