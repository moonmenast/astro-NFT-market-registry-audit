// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";



contract StarRegistryV1 is ERC721Upgradeable,OwnableUpgradeable,ReentrancyGuardUpgradeable{

    address  public _owner;

    address public tokenAddress;
    
    uint256 public ownerCutAST;
    
    uint256 public creatorCutAST;

    mapping(uint256=>address) public tokenCreators;

    mapping(uint256=>uint256) public tokenPriceinWEI;

    mapping(uint256=>uint256) private highestCurrentBid;

    mapping(uint256 => address) public highestBidder;

    mapping(address=>bool) private approvedMinters;
    
    mapping(uint256=>uint256) public createdTime;
    
    mapping (uint256=>uint256) public bidTimeLimit;
    
     using SafeMathUpgradeable for uint256;


     function initialize(address _ASTaddress,uint256 ownerCut,uint256 CCcut) public initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        ERC721Upgradeable.__ERC721_init("Star registry", "STR");
        _setBaseURI("https://ipfs.io/ipfs/");
        tokenAddress = _ASTaddress;
        ownerCutAST = ownerCut;
        creatorCutAST = CCcut;
    }

    function setOwnerCut(uint256 ownerCutpercent) public{
        require(msg.sender == _owner);
        ownerCutAST = ownerCutpercent;//percentage
    }

    function setCreatorCut(uint256 CreatorCutpercent) public{
        require(msg.sender == _owner);
        creatorCutAST = CreatorCutpercent;
    }

    function approveMinter(address minter) public  {
        require(msg.sender == _owner);
        approvedMinters[minter] = true;
    }

    function createNFT(uint256 price,string memory uri) public {
        require(msg.sender==_owner || approvedMinters[msg.sender] == true,"Not approved Minter" );
        uint256 id = totalSupply()+1;
        _safeMint(msg.sender, id);
        _setTokenURI(id,uri);
        tokenPriceinWEI[id] = price;
        tokenCreators[id] = msg.sender;
        
    }
    

    function bid(uint256 id,uint256 bidAmt) public {
        require(IERC20Upgradeable(tokenAddress).balanceOf(msg.sender)>=bidAmt,"Low AST balance to bid");
        require(now-createdTime[id] < bidTimeLimit[id],"Cannot Bid,Auction Time over");
        require(msg.sender != ownerOf(id),"Token owner cannot bid");
        if(bidAmt > highestCurrentBid[id]){
            highestCurrentBid[id] = bidAmt;
            highestBidder[id] = msg.sender;
        }else{
            revert();
        }
    }
    
    function placeSellorder(uint256 id,uint256 timeInDays) public {
        require(_exists(id));
        require(ownerOf(id)==msg.sender);
        super.approve(address(this),id);
        createdTime[id] = now;
        bidTimeLimit[id] = SafeMathUpgradeable.mul(timeInDays,86400);
    }

    function buy(uint256 id) external {
        require(_exists(id));
        uint256 Ocut = ceilDiv(tokenPriceinWEI[id]*ownerCutAST,100);
        uint256 Ccut = ceilDiv(tokenPriceinWEI[id]*creatorCutAST,100);
        IERC20Upgradeable(tokenAddress).transferFrom(msg.sender,_owner,Ocut);
        IERC20Upgradeable(tokenAddress).transferFrom(msg.sender,tokenCreators[id],Ccut);
        IERC20Upgradeable(tokenAddress).transferFrom(msg.sender,ownerOf(id),tokenPriceinWEI[id]-Ocut-Ccut);
        IERC721Upgradeable(address(this)).safeTransferFrom(ownerOf(id),msg.sender,id);

    }

    function acceptBid(uint256 id) external {
        require(now-createdTime[id]<bidTimeLimit[id],"cannot Accept bid,Time Limit over");
        require(msg.sender == ownerOf(id));
        uint256 Ocut = ceilDiv(tokenPriceinWEI[id]*ownerCutAST,100);
        uint256 Ccut = ceilDiv(tokenPriceinWEI[id]*creatorCutAST,100);
        IERC20Upgradeable(tokenAddress).transferFrom(highestBidder[id],_owner,Ocut);
        IERC20Upgradeable(tokenAddress).transferFrom(highestBidder[id],tokenCreators[id],Ccut);
        IERC20Upgradeable(tokenAddress).transferFrom(highestBidder[id],ownerOf(id),tokenPriceinWEI[id]-Ocut-Ccut);
        safeTransferFrom(ownerOf(id), highestBidder[id],id);
    }
    
    function setBaseUri(string memory baseUri) public {
        require(msg.sender == _owner);
        _setBaseURI(baseUri);
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}