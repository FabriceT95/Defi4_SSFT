pragma solidity 0.5.0;
pragma experimental ABIEncoderV2;

import "./CryptomonFactory.sol";
import "./SafeMath.sol";

contract CryptomonHelper is CryptomonFactory{

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    uint levelUpFee = 0.001 ether;
    uint feeCryptoball = 0.0001 ether;



    struct cryptoBalls{
        uint simpleCryptoballs;
        uint superCryptoballs;
        uint hyperCryptoballs;
    }

    struct cryptoFood{
        // SELIM
    }


    mapping(address => cryptoBalls) ownerToCryptoballs;

    mapping(address => cryptoFood) ownerToCryptofood;



    function getCryptoball(uint _typeof) public payable {
        require(msg.value == feeCryptoball * _typeof);
        if(_typeof == 0){
            ownerToCryptoballs[msg.sender].simpleCryptoballs++;
        }
        else if(_typeof == 1){
            ownerToCryptoballs[msg.sender].superCryptoballs++;
        }
        else if(_typeof == 2){
            ownerToCryptoballs[msg.sender].hyperCryptoballs++;
        }

    }

    function getFood(uint _typeof) public payable{
        // SELIM
    }

    function feed(uint _cryptomonId, uint _typeof) public {
        // SELIM
    }

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function levelUp(uint _cryptomonId) external payable{
        require(msg.value == levelUpFee);
        ownerToCryptomon[msg.sender][_cryptomonId].level = ownerToCryptomon[msg.sender][_cryptomonId].level.add(1);
    }

    function randomFunction(uint8 modulo) internal view returns (uint8) {
        return uint8(blockhash(block.number-1)) % modulo;
    }


    function getFreeObject() public {
        require(lastDateGetFreeObjects == 0 || lastDateGetFreeObjects - now > 1 days );
        lastDateGetFreeObjects = now;
        ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(3)+1);
        if(randomFunction(100) > 50){
            ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(2)+1);
        }
        if(randomFunction(100) > 75){
            ownerToCryptoballs[msg.sender].simpleCryptoballs.add(randomFunction(1)+1);
        }

        // AJOUTER DE LA NOURRITURE A OBTENIR DE FACON ALEATOIRE
    }
}
