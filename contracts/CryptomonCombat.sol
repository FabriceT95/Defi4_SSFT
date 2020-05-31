pragma solidity 0.5.16;
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

    // Nonce for random cryptomon id
    uint private nonce;

    // Hungry value, after a fight, active cryptomon will lose this amount in its Cryptomon structure
    int private hungryAfterFight = 4;

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
    function spawnCryptomon() private returns (Cryptomon memory){
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

        require((ownerToCryptoballs[msg.sender].simpleCryptoballs > 0 || ownerToCryptoballs[msg.sender].superCryptoballs > 0 || ownerToCryptoballs[msg.sender].hyperCryptoballs > 0) /*&& ownerToCapture[msg.sender] != 0*/);

        uint probabilityToCatch = ownerToCapture[msg.sender].probabilityToCatch;
        uint catchCrypto = cryptoballType * probabilityToCatch;
        uint rand = randomFunction(100);
        if(catchCrypto > rand){
            ownerToCapture[msg.sender].captureDate = now;
            //ownerToCapture[msg.sender].idInventory = ownerCryptomonCount[msg.sender];
            ownerToCapture[msg.sender].idCryptomon = uint(msg.sender)+uint(keccak256(abi.encodePacked(nonce,now)));
            nonce++;
            cryptomonIdToHealth[ownerToCapture[msg.sender].idCryptomon] = healthCryptomons[ownerToCapture[msg.sender].idCryptomon-1];
            cryptomonIdToCombat[ownerToCapture[msg.sender].idCryptomon] = Combat(ownerToCapture[msg.sender].idCryptomon, 0,5,0,0);
            ownerCryptomonCount[msg.sender] = ownerCryptomonCount[msg.sender].add(1);
            ownerToCryptomon[msg.sender][ownerToCapture[msg.sender].idCryptomon] = ownerToCapture[msg.sender];
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

    @param _cryptomonId cryptomon's id of the user which is called for the fight
    @param _opponent opponent address
    @param _opponentCryptomonId cryptomon's id of the opponent which is called for the fight

    */
    function startFight(uint _cryptomonId, address _opponent, uint _opponentCryptomonId) public {

        require(ownerToCryptomon[msg.sender][_cryptomonId].hunger > 0 && ownerToFight[msg.sender].sender == defaultFighting.sender);

        ownerToFight[msg.sender] = fightStatus(msg.sender,_cryptomonId, _opponent, _opponentCryptomonId);
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
        if(cryptomonIdToCombat[cryptomonOpponent.idCryptomon].dodgeRate >= randDodgeOpponent){
            inflictDamages(cryptomonFighter, cryptomonOpponent);
            if(cryptomonIdToHealth[cryptomonOpponent.idCryptomon].totHealthPoint <= 0){
                cryptomonIdToCombat[cryptomonFighter.idCryptomon].winCount = cryptomonIdToCombat[cryptomonFighter.idCryptomon].winCount.add(1);
                cryptomonIdToCombat[cryptomonOpponent.idCryptomon].lossCount = cryptomonIdToCombat[cryptomonOpponent.idCryptomon].lossCount.add(1);
                if(cryptomonFighter.level < cryptomonOpponent.level){
                    cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(ExpPerFight*(cryptomonOpponent.level-cryptomonFighter.level));
                }else{
                    cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(ExpPerFight);
                }
                if(cryptomonFighter.actualExp > levelToExpNeededToLevelUp[cryptomonFighter.level]){
                    levelUp(cryptomonFighter);
                    if(cryptomonFighter.level == cryptomonFighter.levelNeededForEvolution){
                        evolve(cryptomonFighter);
                    }
                }
                cryptomonFighter.hunger = cryptomonFighter.hunger.sub(hungryAfterFight);
                restoreHealth(cryptomonFighter, cryptomonOpponent);
                ownerToFight[msg.sender] = defaultFighting;
                emit Endfight(true);
                return;
            }
        }

        uint randDodge = randomFunction(100);
        if(cryptomonIdToCombat[cryptomonFighter.idCryptomon].dodgeRate >= randDodge){
            inflictDamages(cryptomonOpponent, cryptomonFighter);
            if(cryptomonIdToHealth[cryptomonFighter.idCryptomon].totHealthPoint <= 0){
                cryptomonFighter.actualExp = cryptomonFighter.actualExp.add(passiveExpPerFight);
                if(cryptomonOpponent.actualExp > levelToExpNeededToLevelUp[cryptomonOpponent.level]){
                    levelUp(cryptomonOpponent);
                    if(cryptomonOpponent.level == cryptomonOpponent.levelNeededForEvolution){
                        evolve(cryptomonOpponent);
                    }
                }
                cryptomonFighter.hunger = cryptomonFighter.hunger.sub(hungryAfterFight);
                restoreHealth(cryptomonFighter, cryptomonOpponent);
                ownerToFight[msg.sender] = defaultFighting;
                emit Endfight(true);
                return;
            }
            ownerToCryptomon[msg.sender][ownerToFight[msg.sender].idCryptomon] = cryptomonFighter;
            ownerToCryptomon[ownerToFight[msg.sender].opponent][ownerToFight[msg.sender].idCryptomonOpponent] = cryptomonOpponent;
            emit Endfight(false);
        }
    }

    /**
    @notice manage variable in structs when level up
    @dev
            It modifies the content of the cryptomon object, combat and health structures.
            Randomly add damageBonus and healthBonus to the corresponding structure, then updating total health points

    @param cryptomon cryptomon leveling up

     */
    function levelUp(Cryptomon memory cryptomon) private {
        cryptomon.actualExp = levelToExpNeededToLevelUp[cryptomon.level+1].sub(cryptomon.actualExp);
        cryptomon.level = cryptomon.level.add(1);
        cryptomonIdToCombat[cryptomon.idCryptomon].damageBonus += randomFunction(2)+1;
        cryptomonIdToHealth[cryptomon.idCryptomon].healthBonus += randomFunction(4)+1;
        cryptomonIdToHealth[cryptomon.idCryptomon].totHealthPoint = cryptomonIdToHealth[cryptomon.idCryptomon].healthBonus + cryptomonIdToHealth[cryptomon.idCryptomon].healthPoint;
    }

    /**
    @notice manage total health at the end of a fight
    @dev
            Reset totHealthPoint variable to the max = basic health + bonus health

    @param fighter1 one of the fighters at the end of a fight
    @param fighter2 one of the fighters at the end of a fight

     */
    function restoreHealth(Cryptomon memory fighter1, Cryptomon memory fighter2) private {
        cryptomonIdToHealth[fighter1.idCryptomon].totHealthPoint = cryptomonIdToHealth[fighter1.idCryptomon].healthBonus + cryptomonIdToHealth[fighter1.idCryptomon].healthPoint;
        cryptomonIdToHealth[fighter2.idCryptomon].totHealthPoint = cryptomonIdToHealth[fighter2.idCryptomon].healthBonus + cryptomonIdToHealth[fighter2.idCryptomon].healthPoint;

    }

    /**
    @notice manage damages dealt during a fight
    @dev
            Substracts basic damage from SpellAndDamage structure and bonus damage from cryptomon Combat structure

    @param cryptomonFrom cryptomon dealing damages
    @param cryptomonTo cryptomon taking damages

    */
    function inflictDamages(Cryptomon memory cryptomonFrom,Cryptomon memory cryptomonTo) private {
        cryptomonIdToHealth[cryptomonTo.idCryptomon].totHealthPoint.sub(spellAndDamage[cryptomonFrom.idSpell].damage);
        cryptomonIdToHealth[cryptomonTo.idCryptomon].totHealthPoint.sub(cryptomonIdToCombat[cryptomonFrom.idCryptomon].damageBonus);
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
    function evolve(Cryptomon memory _cryptomon) internal {
        Cryptomon memory evolCryptomon = cryptomons[_cryptomon.idCryptomonEvolution];
        _cryptomon.idCryptomon = evolCryptomon.idCryptomon;
        _cryptomon.name = evolCryptomon.name;
        _cryptomon.idSpell = evolCryptomon.idSpell;
        cryptomonIdToHealth[_cryptomon.idCryptomon].healthPoint = healthCryptomons[evolCryptomon.idCryptomon-1].healthPoint;
        cryptomonIdToHealth[_cryptomon.idCryptomon].totHealthPoint = healthCryptomons[evolCryptomon.idCryptomon-1].healthPoint + cryptomonIdToHealth[_cryptomon.idCryptomon].healthBonus;
        _cryptomon.idCryptomonEvolution = evolCryptomon.idCryptomonEvolution;
        _cryptomon.levelNeededForEvolution = evolCryptomon.levelNeededForEvolution;
        emit Evolution(_cryptomon);
    }
}
