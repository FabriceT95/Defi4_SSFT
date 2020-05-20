pragma solidity ^0.4.0;
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
        uint healthPoint;
        uint dodgeRate;
        uint winCount;
        uint lossCount;
        uint damage;

    }

    struct SpellAndDamage{
        uint id;
        string spell;
        uint8 damage;
    }


    Cryptomon[] public cryptomons;
    SpellAndDamage[] public spellAndDamage;


    mapping(address => Cryptomon[]) public ownerToCryptomon;
    mapping(uint => address) cryptomonToOwner;
    mapping(address => uint) public ownerCryptomonCount;

    mapping(uint => uint) levelToExpNeededToLevelUp;

    constructor() public {
        cryptomons.push(Cryptomon(0,0,"cryptoChu", 1, 0,Kind.ELECTRIK,0,0,20,80,0,100,5,0,0,1));
        cryptomons.push(Cryptomon(0,0,"cryptoMeche",1,1,Kind.FIRE,0,0,20,80,0,100,5,0,0,1));
        cryptomons.push(Cryptomon(0,0,"cryptoPuce",1,2,Kind.WATER,0,0,20,80,0,100,5,0,0,1));
        cryptomons.push(Cryptomon(0,0,"cryptoZare",1,3,Kind.GRASS,0,0,20,80,0,100,5,0,0,1));

        spellAndDamage.push(SpellAndDamage(0,"Tonnerre", 10));
        spellAndDamage.push(SpellAndDamage(1,"Lance-Flamme", 10));
        spellAndDamage.push(SpellAndDamage(2,"Hydrocanon", 10));
        spellAndDamage.push(SpellAndDamage(3,"Lance-Soleil", 10));

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
