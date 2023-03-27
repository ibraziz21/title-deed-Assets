// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC4907.sol";
contract titleNFT is ERC721, IERC4907{
    error InvalidInput();
    error NotAnApprover();
    error Forbidden();

    uint private counter;
    address public owner;


    // Only specific addresses, say a decentralized land commission can mint new title Deeds for users
   struct LandDetails {
    address nftOwner;
    uint landSize; //acres
    string location;
    string ownerName;
    bool Approved;
   }
   struct UserInfo {
    address user;
    uint64 expires;
   }
   
   mapping (uint => UserInfo) internal _users;
   mapping (address => bool) public approver;
   mapping (uint => LandDetails) public getDetails;

    constructor() ERC721("Title Deed","TD"){
        counter=0;
        owner = msg.sender;
    }
    modifier onlyOwner {
        if(msg.sender!= owner) revert Forbidden();
        _;
    }
    modifier onlyApprover {
        if(!approver[msg.sender]) revert NotAnApprover();
        _;
    }

    //function to set the approvers
    function setApprover(address _address) external onlyOwner {
        if(_address==address(0)) revert InvalidInput();
        approver[_address]= true;
    }

    // send land details to the approvers for them to validate and mint token;
    function seekTokenizationApproval(string memory OwnerName, string memory location, uint landsize) external{
        uint tokenID = ++counter;
        address caller = msg.sender;
        LandDetails storage details = getDetails[tokenID];
        details.ownerName = OwnerName;
        details.landSize = landsize;
        details.location = location;
        details.nftOwner = caller;
    }
    function approveAndMintNFT(uint _id, bool _approve) external onlyApprover {
        if(_id == 0) revert InvalidInput();
        LandDetails storage details = getDetails[_id];

        if(_approve) {
            details.Approved = true;
            address nftToOwn = details.nftOwner;
            _mint(nftToOwn, _id);
        }
    }
    function setUser(uint256 tokenId, address user, uint64 expires) external virtual{
        if(tokenId == 0 || user == address(0) || expires<block.timestamp) revert InvalidInput();
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external virtual view returns(address){
         if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) external virtual view returns(uint256){
        return _users[tokenId].expires;
    }
    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize

    ) internal virtual override{
        super._beforeTokenTransfer(from, to, tokenId,batchSize);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }
}