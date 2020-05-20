pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

import "./CryptomonFactory.sol";
import "./SafeMath.sol";
import "./ERC721.sol";

contract CryptomonOwnership is CryptomonFactory, ERC721 {
    using SafeMath for uint256;

    mapping (uint => address) cryptomonApprovals;

    modifier onlyOwnerOf(uint _tokenid){
        require(cryptomonToOwner[_tokenid] == msg.sender);
        _;
    }

    /* function balanceOf(address _owner) external view returns (uint256) {
       return ownerZombieCount[_owner];
     }*/

    function ownerOf(uint256 _cryptomonId) public view returns (address) {
        return cryptomonToOwner[_cryptomonId];
    }

    function _transfer(address _from, address _to, uint256 _cryptomonId) private {

        Cryptomon memory cryptomonToTrade = getCryptomonByIdCryptomon(_from, _cryptomonId);
        cryptomonToTrade.lastExchange = now;
        ownerToCryptomon[_to].push(cryptomonToTrade);
        ownerCryptomonCount[_to] = ownerCryptomonCount[_to].add(1);
        ownerCryptomonCount[_from] = ownerCryptomonCount[_from].sub(1);
        cryptomonToOwner[_cryptomonId] = _to;
        emit Transfer(_from, _to, _cryptomonId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require (cryptomonToOwner[_tokenId] == msg.sender || cryptomonApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
        cryptomonApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function getCryptomonByIdCryptomon(address _from, uint _idCryptomon) private returns (Cryptomon) {
        for(uint i=0; i<ownerCryptomonCount[_from];i++){
            if(ownerToCryptomon[_from][i].idCryptomon == _idCryptomon){
                return ownerToCryptomon[_from][i];
            }
        }
    }

}
