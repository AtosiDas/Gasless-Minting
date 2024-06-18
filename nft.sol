//SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Token is
    EIP712("Gasless tx", "1"),
    Ownable(msg.sender),
    ERC721URIStorage
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct Txs {
        uint256 id;
        string name;
        string uri;
    }

    constructor() ERC721("MyToken", "MT") {}

    function safeMint(
        address to,
        Txs memory txs,
        bytes memory signature
    ) public {
        require(msg.sender == owner(), "Permission denied");
        require(check(txs, signature) == to, "Voucher invalid");
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, txs.uri);
    }
    function check(
        Txs memory txs,
        bytes memory signature
    ) public view returns (address) {
        return _verify(txs, signature);
    }
    function _verify(
        Txs memory txs,
        bytes memory signature
    ) internal view returns (address) {
        bytes32 digest = _hash(txs);
        return ECDSA.recover(digest, signature);
    }
    function _hash(Txs memory txs) public view returns (bytes32) {
        //return keccak256(abi.encode(keccak256("txs(uint256 id,string name)"),id,keccak256(bytes(name))));
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("Txs(uint256 id,string name,string uri)"),
                        txs.id,
                        keccak256(bytes(txs.name)),
                        keccak256(bytes(txs.uri))
                    )
                )
            );
    }
}
