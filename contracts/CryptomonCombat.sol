pragma solidity 0.4.0;
pragma experimental ABIEncoderV2;

import "./CryptomonHelper.sol";

/**
 @title CryptomonCombat contract
 @author Selim Sahnoun / Fabrice Tapia
 @dev Contract which is a part of the Alyra's challenge 4
 */

contract CryptomonCombat is CryptomonHelper{

    // Basic definition of a fight between 2 players and their cryptomon
    struct fightStatus{
        address sender;
        uint idCryptomon;
        address opponent;
        uint idCryptomonOpponent;
    }

    // Active cryptomon fighter will win this amount of experience after a win
    uint private ExpPerFight = 20;

    // Passiv cryptomon fighter will win this amount of experience after a win
    uint private passiveExpPerFight = 5;

    // Hungry value, after a fight, active cryptomon will lose this amount in its Cryptomon structure
    uint private hungryAfterFight = 4;

    // Mapping defining the player trying to capture a Cryptomon
    mapping(address => Cryptomon) private ownerToCapture;

    // Mapping defining the player and the fightStatus structure (it is a way to instanciate a fight)
    mapping(address => fightStatus) private ownerToFight;

    // Default fight used when a fight is ended
    fightStatus private defaultFighting = fightStatus(address(0),0,address(0),0);

    // Event used at the end of the capture() function. True = success and fight is done, False = miss capture but capture() can continue
    event Capture(bool indexed success);

    // Event used at the end of the fight() function. True = one of fighters is K.O. , False = fight continue
    event Endfight(bool indexed fightEnded);

    /**
    @notice Chose a random cryptomon available in the game
    @dev
            Using randomFunction(uint8 modulo) from CryptomonHelper.sol
    @return Cryptomon structure from the list cryptomons
    */
    function spawnCryptomon() internal returns (Cryptomon){
        uint rand = randomFunction(getCountCryptomons());
        return cryptomons[rand];
    }

    /**
    @notice Player starts a cryptomon capture
    @dev
            Calls spawnCryptomon and instantiates in the ownerToCapture mapping
            This way we can call ownerToCapture[msg.sender] for the capture() function
    */
    function startCapture() public {
        ownerToCapture[msg.sender] = spawnCryptomon();
    }


    /**
    @notice Player stops a cryptomon capture
    @dev
            Delete the ownerToCapture[msg.sender]
            capture() function is no more accessible from the UI
    */
    function stopCapture() public {
        delete ownerToCapture[msg.sender];
    }

    /**
    @notice Player throw a cryptoball to the actual cryptomon he is facing
    @dev
            Check if player has any kind of cryptoball (it should be check also on the UI)
            Calculate the probability to catch based on the cryptomon structure (probabilityToCatch) and the cryptoballType
            Basic randomFunction is called  and check success
                Then modify some value of the cryptomon structure. idCryptomon is defined by some parameters and hash
                Add the cryptomon structure in the player ownerToCryptomon array
                Ends by emit Capture which is over then stop capture
            Otherwise, failed capture and UI asks to continue
    @param cryptoballType number between 1 and 3 include specifying which cryptoball is used
    */
    function capture(uint cryptoballType) public {

        require((ownerToCryptoballs[msg.sender].simpleCryptoballs > 0 || ownerToCryptoballs[msg.sender].superCryptoballs > 0 || ownerToCryptoballs[msg.sender].hyperCryptoballs > 0) && ownerToCapture[msg.sender] != 0);

        uint probabilityToCatch = ownerToCapture[msg.sender].probabilityToCatch;
        uint catchCrypto = cryptoballType * probabilityToCatch;
        uint rand = randomFunction(100);
        if(catchCrypto > rand){
            ownerToCapture[msg.sender].captureDate = now;
            ownerToCapture[msg.sender].idInventory = ownerCryptomonCount[msg.sender];
            ownerToCapture[msg.sender].idCryptomon = uint(msg.sender)+uint(keccak256(abi.encodePacked(ownerToCapture[msg.sender].idInventory)));
            ownerCryptomonCount[msg.sender] = ownerCryptomonCount[msg.sender].add(1);
            //ownerToCryptomon[msg.sender].push(ownerToCapture[msg.sender]);
            ownerToCryptomon[msg.sender][idCryptomon] = ownerToCapture[msg.sender];
            cryptomonToOwner[ownerToCapture[msg.sender].idCryptomon] = msg.sender;
            emit Capture(true);
            stopCapture();
        }else{
            emit Capture(false);
        }

    }


    /**
    @notice Player starts a fight against a passive player
    @dev
            Check if the selected cryptomon is not hunger (in structure Cryptomon, hunger > 0)
            Instianciates a fightStatus in ownerToFight

    @param _cryptomonIdInventary
    */
    function startFight(uint _cryptomonId, address _opponent, uint _opponentCryptomonId) public {

        require(ownerToCryptomon[msg.sender][_cryptomonId].hunger > 0 && ownerToFight[msg.sender].sender == defaultFighting.sender);

        ownerToFight[msg.sender] = fightStatus(msg.sender,_cryptomonId, _opponent, _opponentCryptomonIdy);
    }


    /**
    @notice cryptomons are fighting, each time you decide to fight, each cryptomon hits one time
    @dev
            Check if not default fight, which means address(0) for the player (sender)
            Then instantiates both cryptomon fighters
            randomFunction() to allow the opponent to dodge
                Then damage are taken, totHealthPoint are substracts based on spell damage from SpellAndDamage strcture and damage bonus from Cryptomon structure
                Check if cryptomon is K.O.
                    Add win to player cryptomon
                    Add lose to opponent cryptomon
                    Check level difference and adapt the experience earned
                    Check level up based on the experience + experience earned, and the experience needed for level up
                        Add level and randomly value to stats (healthBonus and damageBonus)
                        Check if new level corresponds to the evolution level
                            Then evolve()
                    cryptomon player is losing some "hunger"
                    Check if he is hunger (hunger = 0)
                    ownerToFight is set to default
                    Emit fight has ended
            Otherwise, nothing happens and opponent hits
            He deals damages to player cryptomon, earned less experience because passive cryptomon and can level up and evolve aswell
    */
    function fight() public {
        require(ownerToFight[msg.sender].sender != defaultFighting.sender);

        Cryptomon memory cryptomonFighter = ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon];
        Cryptomon memory cryptomonOpponent = ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent];

        uint randDodgeOpponent = randomFunction(100);
        if(cryptomonOpponent.dodgeRate >= randDodgeOpponent){
            cryptomonOpponent.totHealthPoint -= spellAndDamage[cryptomonFighter.idSpell].damage;
            cryptomonOpponent.totHealthPoint -= cryptomonFighter.damageBonus;
            if(cryptomonOpponent.totHealthPoint <= 0){
                cryptomonFighter.winCount = cryptomonFighter.winCount.add(1);
                cryptomonOpponent.lossCount = cryptomonOpponent.lossCount.add(1);
                if(cryptomonFighter.level < cryptomonOpponent.level){
                    cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(ExpPerFight*(cryptomonOpponent.level-cryptomonFighter.level));
                }else{
                    cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(ExpPerFight);
                }
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
                cryptomonFighter.hunger = cryptomonFighter.hunger.sub(hungryAfterFight);
                ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon] = ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon].healthBonus + ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon].healthPoint;
                ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent] = ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent].healthBonus + ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent].healthPoint;

                ownerToFight[msg.sender] = defaultFighting;
                emit Endfight(true);
                break;
            }
        }

        uint randDodge = randomFunction(100);
        if(cryptomonFighter.dodgeRate >= randDodge){
            cryptomonFighter.totHealthPoint -= spellAndDamage[cryptomonOpponent.idSpell].damage;
            cryptomonFighter.totHealthPoint -= cryptomonOpponent.damageBonus;
            if(cryptomonFighter.totHealthPoint <= 0){
                cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(passiveExpPerFight);
                if(cryptomonOpponent.actualExp > levelToExpNeededToLevelUp[cryptomonOpponent.level]){
                    cryptomonOpponent.actualExp = levelToExpNeededToLevelUp[cryptomonOpponent.level+1].sub(cryptomonOpponent.actualExp);
                    cryptomonOpponent.level = cryptomonOpponent.level.add(1);
                    cryptomonOpponent.damageBonus += randomFunction(2)+1;
                    cryptomonOpponent.healthBonus += randomFunction(4)+1;
                    cryptomonOpponent.totHealthPoint = cryptomonOpponent.healthBonus + cryptomonOpponent.healthPoint;
                    if(cryptomonOpponent.level == cryptomonOpponent.levelNeededForEvolution){
                        evolve(cryptomonOpponent);
                    }
                }
                cryptomonFighter.hunger = cryptomonFighter.hunger.sub(hunger);
                ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon] = ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon].healthBonus + ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon].healthPoint;
                ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent] = ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent].healthBonus + ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent].healthPoint;
                ownerToFight[msg.sender] = defaultFighting;

                emit Endfight(true);
                break;
            }
            ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon] = cryptomonFighter;
            ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent] = cryptomonOpponent;
            emit Endfight(false);
        }
    }
}
