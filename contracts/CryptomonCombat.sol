pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

import "./CryptomonHelper.sol";

contract CryptomonCombat is CryptomonHelper{

    mapping(address => Cryptomon) ownerToFight;
    Cryptomon cryptomonSummoning;
    Cryptomon defaultCryptomon = Cryptomon("",0,0, Kind.NEUTRAL,0,0,0,0,0,0,0,0);

    struct fightStatus{
        address sender;
        uint idCryptomon;
        address opponent;
        uint idOpponentCryptomon;
    }

    event Capture(bool indexed success);

    function startCapture() public {
        cryptomonSummoning = spawnCryptomon();
        ownerToFight[msg.sender] = cryptomonSummoning;
    }


    function capture(uint cryptoballType) public {
        // require(keccak256(bytes(ownerToFight[msg.sender])) != keccak256(defaultCryptomon));
        require((ownerToCryptoballs[msg.sender].simpleCryptoballs > 0 || ownerToCryptoballs[msg.sender].superCryptoballs > 0 || ownerToCryptoballs[msg.sender].hyperCryptoballs > 0));
        uint probabilityToCatch = cryptomonSummoning.probabilityToCatch;
        uint catchCrypto = cryptoballType * probabilityToCatch;
        uint rand = uint8(blockhash(block.number-1)) % 100;
        if(catchCrypto > rand){
            cryptomonSummoning.captureDate = now;
            ownerToCryptomon[msg.sender].push(cryptomonSummoning);
            emit Capture(true);
        }else{
            cryptomonSummoning = defaultCryptomon;
            emit Capture(false);
        }
    }

    function startFight() public {

    }

    function fight(uint _cryptomonId, address _opponent, uint _opponentCryptomon) public {

    }
}
