// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "./titleNFT.sol";
contract MarketPlace {
    error notYours();
    error InvalidInput();

    titleNFT public nfts;
    
    uint public salesCount;
    struct NFTSale {
        uint _tokenId;
        uint _price;
        bool _sellActive;

    }
    mapping (uint => NFTSale) public saleDetails;
    
    constructor(address _titleNFT) {
        if(_titleNFT == address(0)) revert InvalidInput();
        nfts = titleNFT(_titleNFT);
        salesCount = 0;
            }

    function setNFTForSale(uint _id, uint sellPrice)external {
        if(nfts.ownerOf(_id)!=msg.sender) revert notYours();
        uint saleId = ++salesCount;
            NFTSale storage sale = saleDetails[saleId];
            sale._tokenId = _id;
            sale._price = sellPrice;
            sale._sellActive;
        }

    function setForRent() external {
        
    }

    function buyNFT() external  {
        
    }
    function rentNFT() external {
        
    }

}