pragma solidity ^0.4.0;
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

    mapping(address => cryptoBalls) ownerToCryptoballs;

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

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function levelUp(uint _cryptomonId) external payable{
        require(msg.value == levelUpFee);
        ownerToCryptomon[msg.sender][_cryptomonId].level = ownerToCryptomon[msg.sender][_cryptomonId].level.add(1);
    }
}
