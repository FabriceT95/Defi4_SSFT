pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

import "./CryptomonHelper.sol";

contract CryptomonCombat is CryptomonHelper{

    mapping(address => Cryptomon) ownerToCapture;
    mapping(address => fightStatus) ownerToFight;

    uint ExpPerFight = 20;
    uint passivExpPerFight = 5;
    uint hungryAfterFight = 2;

    struct fightStatus{
        address sender;
        uint cryptomonIdInventary;
        address opponent;
        uint opponentCryptomonInventary;
    }

    fightStatus fighting;
    fightStatus[] private fightings;
    fightStatus defaultFighting = fightStatus(address(0),0,address(0),0);

    event Capture(bool indexed success);
    event Endfight(bool indexed fightEnded);

    function spawnCryptomon() public returns (Cryptomon){
        uint rand = randomFunction(3);
        return cryptomons[rand];
    }

    function startCapture() public {
        ownerToCapture[msg.sender] = spawnCryptomon();
    }


    function capture(uint cryptoballType) public {
        // require(keccak256(bytes(ownerToCapture[msg.sender])) != keccak256(defaultCryptomon));
        require((ownerToCryptoballs[msg.sender].simpleCryptoballs > 0 || ownerToCryptoballs[msg.sender].superCryptoballs > 0 || ownerToCryptoballs[msg.sender].hyperCryptoballs > 0));
        uint probabilityToCatch = ownerToCapture[msg.sender].probabilityToCatch;
        uint catchCrypto = cryptoballType * probabilityToCatch;
        uint rand = randomFunction(100);
        if(catchCrypto > rand){
            ownerToCapture[msg.sender].captureDate = now;
            ownerToCapture[msg.sender].idInventory = ownerCryptomonCount[msg.sender];
            ownerToCapture[msg.sender].idCryptomon = uint(msg.sender)+uint(keccak256(abi.encodePacked(ownerToCapture[msg.sender].idInventory)));
            ownerCryptomonCount[msg.sender] = ownerCryptomonCount[msg.sender].add(1);
            ownerToCryptomon[msg.sender].push(ownerToCapture[msg.sender]);
            cryptomonToOwner[ownerToCapture[msg.sender].idCryptomon] = msg.sender;
            emit Capture(true);
        }else{
            delete ownerToCapture[msg.sender];
            emit Capture(false);
        }
    }

    function startFight(uint _cryptomonIdInventary, address _opponent, uint _opponentCryptomonInventary) public {
        // On vérifie que le cryptomon ne crève pas la dalle
        require(ownerToCryptomon[msg.sender][ownerToFight[msg.sender].cryptomonIdInventary].hungry > 0);
        ownerToFight[msg.sender] = fightStatus(msg.sender,_cryptomonIdInventary, _opponent, _opponentCryptomonInventary);

    }

    function fight() public {
        require(ownerToFight[msg.sender].sender != defaultFighting.sender);

        // Instance des deux cryptomons en combat : storage ou memory ?
        Cryptomon memory cryptomonFighter = ownerToCryptomon[msg.sender][ownerToFight[msg.sender].cryptomonIdInventary];
        Cryptomon memory cryptomonOpponent = ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].opponentCryptomonInventary];

        // Le owner attaque en premier
        uint randDodgeOpponent = randomFunction(100);
        if(cryptomonOpponent.dodgeRate >= randDodgeOpponent){
            cryptomonOpponent.totHealthPoint -= spellAndDamage[cryptomonFighter.idSpell].damage;
            cryptomonOpponent.totHealthPoint -= cryptomonFighter.damageBonus;
            if(cryptomonOpponent.totHealthPoint <= 0){
                cryptomonFighter.winCount = cryptomonFighter.winCount.add(1);
                cryptomonOpponent.lossCount = cryptomonOpponent.lossCount.add(1);
                if(cryptomonFighter.level < cryptomonOpponent.level){
                    cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(ExpPerFight*(cryptomonOpponent.level-cryptomonFighter.level));
                    if(cryptomonFighter.actualExp > levelToExpNeededToLevelUp[cryptomonFighter.level]){
                        cryptomonFighter.actualExp = levelToExpNeededToLevelUp[cryptomonFighter.level+1].sub(cryptomonFighter.actualExp);
                        cryptomonFighter.level = cryptomonFighter.level.add(1);
                        cryptomonFighter.damageBonus += randomFunction(2)+1;
                        cryptomonFighter.healthBonus += randomFunction(4)+1;
                        cryptomonFighter.totHealthPoint = cryptomonFighter.healthBonus + cryptomonFighter.healthPoint;
                        if(cryptomonFighter.level == cryptomonFighter.levelNeededForEvolution){
                            evolve(cryptomonFighter);
                        }
                    }
                }
                cryptomonFighter.hungry = cryptomonFighter.hungry.sub(hungryAfterFight);
                ownerToFight[msg.sender] = defaultFighting;
                emit Endfight(true);
            }
        }
        // L'opposant tape en second
        uint randDodge = randomFunction(100);
        if(cryptomonFighter.dodgeRate >= randDodge){
            cryptomonFighter.totHealthPoint -= spellAndDamage[cryptomonOpponent.idSpell].damage;
            cryptomonFighter.totHealthPoint -= cryptomonOpponent.damageBonus;
            if(cryptomonFighter.totHealthPoint <= 0){
                cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(passivExpPerFight);
                if(cryptomonOpponent.actualExp > levelToExpNeededToLevelUp[cryptomonOpponent.level]){
                    cryptomonOpponent.actualExp = levelToExpNeededToLevelUp[cryptomonOpponent.level+1].sub(cryptomonOpponent.actualExp);
                    cryptomonOpponent.level = cryptomonOpponent.level.add(1);
                    cryptomonOpponent.damageBonus += randomFunction(2)+1;
                    cryptomonOpponent.healthBonus += randomFunction(4)+1;
                    cryptomonOpponent.totHealthPoint = cryptomonOpponent.healthBonus + cryptomonOpponent.healthPoint;
                }
                ownerToFight[msg.sender] = defaultFighting;
                emit Endfight(true);
            }
            emit Endfight(false);
        }
    }
}
