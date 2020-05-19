pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract CryptomonFactory is Ownable {
    enum Kind {WATER, FIRE, GRASS, ELECTRIK, NEUTRAL}

    struct Cryptomon{
        string name;
        uint32 level;
        uint idSpell;
        Kind kind;
        uint lastExchange;
        uint actualExp;
        uint expNeededForLevelUp;
        uint probabilityToCatch;
        uint hungry;
        uint captureDate;
        uint healthPoint;
        uint dodgeRate;

    }

    struct SpellAndDamage{
        uint id;
        string spell;
        uint8 damage;
        uint8 cooldownSpell;
    }


    Cryptomon[] public cryptomons;
    SpellAndDamage[] public spellAndDamage;


    mapping(address => Cryptomon[]) public ownerToCryptomon;
    mapping(address => uint) public ownerCryptomonCount;

    constructor() public {
        cryptomons.push(Cryptomon("cryptoChu", 1, 0,Kind.ELECTRIK,0,0,10,20,80,0,100,5));
        cryptomons.push(Cryptomon("cryptoMeche",1,1,Kind.FIRE,0,0,10,20,80,0,100,5));
        cryptomons.push(Cryptomon("cryptoPuce",1,2,Kind.WATER,0,0,10,20,80,0,100,5));
        cryptomons.push(Cryptomon("cryptoZare",1,3,Kind.GRASS,0,0,10,20,80,0,100,5));

        spellAndDamage.push(SpellAndDamage(0,"Tonnerre", 10, 5));
        spellAndDamage.push(SpellAndDamage(1,"Lance-Flamme", 10, 5));
        spellAndDamage.push(SpellAndDamage(2,"Hydrocanon", 10, 5));
        spellAndDamage.push(SpellAndDamage(3,"Lance-Soleil", 10, 5));
    }

    function spawnCryptomon() public returns (Cryptomon){
        uint8 rand = uint8(blockhash(block.number-1)) % 3;
        return cryptomons[rand];
    }

}
