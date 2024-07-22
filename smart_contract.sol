// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyNFT is ERC721Enumerable, Ownable {
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) private _tokenExists;
    mapping(uint256 => uint256) public nftPrices;
    mapping(uint256 => NFTType) public nftTypes;

    struct NFTType {
        string name;
        string ipfsDirectoryHash;
    }

    // Mapping to keep track of the current image index for each NFT type
    mapping(uint256 => uint256) private _currentImageIndex;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable(msg.sender) {
        setNFTTypes();
        setNFTPrices();
        mintAllNFTs();
    }

    function setNFTPrices() internal {
        nftPrices[1] = 0.00000000001 ether; // Tipo 1 - 10000000  
        nftPrices[2] = 0.0000000005 ether; // Tipo 2 - 500000000  

        // Add more types as needed
    }

    function setNFTTypes() internal {
        nftTypes[1] = NFTType("Tipo 1", "https://moccasin-chemical-pheasant-132.mypinata.cloud/ipfs/QmPKfNft7dJNB4LT4bYbsY6oSQiPA8HDYbyM3NdhXjJ8ML/");
        nftTypes[2] = NFTType("Tipo 2", "https://moccasin-chemical-pheasant-132.mypinata.cloud/ipfs/QmVGTKUt6jhRqdtCvzDGTK5juyS7FMFATY2ZcR7PXhXEtF/");

        // Add more types as needed
    }

    function mintAllNFTs() internal {
        uint256 tokenId = 1; // Start token ID from 1
        for (uint256 i = 1; i <= 2; i++) { // Mint all 2 types
            string memory baseURI = nftTypes[i].ipfsDirectoryHash;
            for (uint256 j = 1; j <= 5; j++) { // Each type has 5 NFTs
                _mint(address(this), tokenId);
                _setTokenURI(tokenId, string(abi.encodePacked(baseURI, "/", Strings.toString(j), ".json")));
                _tokenExists[tokenId] = true;
                _currentImageIndex[tokenId] = j; // Initialize the index
                tokenId++;
            }
        }
    }

    function buyNFT(uint256 nftType, uint256 value) public payable {
        require(nftPrices[nftType] > 0, "Tipo de NFT invalido");
        require(value >= nftPrices[nftType], "Valor insuficiente");

        uint256 tokenId = getAvailableTokenId(nftType);
        require(_tokenExists[tokenId], "NFT nao existe");

        // Transfer the NFT from the contract to the buyer
        _transfer(address(this), msg.sender, tokenId);
        _tokenExists[tokenId] = false;

        // Refund excess value
        if (value > nftPrices[nftType]) {
            payable(msg.sender).transfer(value - nftPrices[nftType]);
        }
    }

    function getAvailableTokenId(uint256 nftType) internal view returns (uint256) {
        for (uint256 i = 1; i <= 5; i++) { // Check all possible token IDs for the type
            uint256 tokenId = (nftType - 1) * 5 + i;
            if (_tokenExists[tokenId]) {
                return tokenId;
            }
        }
        revert("No more NFTs available for this type");
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_tokenExists[tokenId], "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function checkIfTokenExists(uint256 tokenId) public view returns (bool) {
        return _tokenExists[tokenId];
}
}