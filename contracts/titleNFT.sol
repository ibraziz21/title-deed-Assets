// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract titleNFT is ERC721{
    error InvalidInput();
    error NotAnApprover();
    error Forbidden();

    uint counter;
    address owner;


    // Only specific addresses, say a decentralized land commission can mint new title Deeds for users
   struct LandDetails {
    address nftOwner;
    uint landSize; //acres
    string location;
    string ownerName;
    bool Approved;
   }
   
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
}