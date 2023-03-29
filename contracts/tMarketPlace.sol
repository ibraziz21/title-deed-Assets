// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;
import "./buyingToken.sol";
import "./titleNFT.sol";
contract MarketPlace {
    error notYours();
    error InvalidInput();
    error InsufficientBal();
    error NotActive();
    error AlreadyOwned();
    error Forbidden();

    buyToken private token;
    titleNFT public nfts;
    
    uint public salesCount;
    uint public rentCount;
    struct NFTSale {
        uint _tokenId;
        uint _price;
        bool _sellActive;

    }
    struct NFTRent {
        uint64 _timeStamp;
        uint tokenId;
        uint rentPrice;
        bool _rentActive;
    }
    mapping (uint => NFTSale) public saleDetails;
    mapping (uint => NFTRent) public rentDetails;
    
    constructor(address _titleNFT, address _itkn) {
        if(_titleNFT == address(0) || _itkn == address(0)) revert InvalidInput();
        nfts = titleNFT(_titleNFT);
        token = buyToken(_itkn);
        salesCount = 0;
        rentCount = 0;
            }

    function setNFTForSale(uint _id, uint sellPrice)external {
        if(nfts.ownerOf(_id)!=msg.sender) revert notYours();
        uint saleId = ++salesCount;
            NFTSale storage sale = saleDetails[saleId];
            sale._tokenId = _id;
            sale._price = sellPrice;
            sale._sellActive;
        }

    function setForRent(uint _tokenId, uint rentPrice,uint64 _timePeriod) external {
        if(_tokenId == 0 || _timePeriod==0) revert InvalidInput();
        if(nfts.ownerOf(_tokenId)!=msg.sender) revert Forbidden();
        uint _rentID = ++rentCount;
        NFTRent storage rent = rentDetails[_rentID];
        rent.tokenId = _tokenId;
        rent._timeStamp = _timePeriod;
        rent.rentPrice = rentPrice;
        
    }

    function buyNFT(uint _id) external  {
        NFTSale memory sale = saleDetails[_id];
        uint _token = sale._tokenId;
        uint price = sale._price;
        bool active = sale._sellActive;
        address owner = nfts.ownerOf(_token);
        if (token.balanceOf(msg.sender)<price) revert InsufficientBal();
        if(owner== msg.sender) revert AlreadyOwned();
        if(!active) revert NotActive();

        token.transfer(address(this), price);
        nfts.transferFrom(owner, msg.sender, _id);

        
    }
    function rentNFT(uint _id ) external {
        NFTRent memory rent = rentDetails[_id];
        uint _token = rent.tokenId;
        uint price = rent.rentPrice;
        uint64 expiry = uint64(block.timestamp) + rent._timeStamp;
        bool active = rent._rentActive;
        address owner = nfts.ownerOf(_token);
        if (token.balanceOf(msg.sender)<price) revert InsufficientBal();
        if(owner== msg.sender) revert AlreadyOwned();
        if(!active) revert NotActive();
        token.transfer(address(this), price);

        nfts.setUser(_token, msg.sender, expiry);
    }

}