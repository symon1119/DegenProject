# DegenProject
## Description
 Creating ERC20 Token and deploying it on the Avalanche network for Degen Gaming with different functions such as Minting, Transferring, Redeeming, Checking Balance, and Burning. The inspiration for this code is the prepaid load that we use daily, an example of that is the prepaid load in Globe Network because the user can redeem the point to have load.

## Getting Started

### Executing Program
To run this program, you can use Remix, an online Solidity IDE. To get started, go to the Remix website at https://remix.ethereum.org/.

Once you are on the Remix website, create a new file by clicking on the file icon in the left-hand sidebar. Save the file with a .sol extension (e.g., Degen.sol). Copy and paste the following code into the file:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Degen is ERC20, Ownable {
    event LoadTransferred(address indexed from, address indexed to, uint256 amount);
    event LoadListingCreated(uint256 indexed listingId, address indexed seller, uint256 loadAmount, uint256 price);
    event LoadPurchased(address indexed buyer, uint256 indexed listingId, uint256 loadAmount, uint256 totalPrice);
    event LoadRedeemed(address indexed redeemer, uint256 loadAmount);

    struct LoadListing { 
        address seller; 
        uint256 loadAmount; 
        uint256 price; 
    }

    mapping(uint256 => LoadListing) public loadListings;
    uint256 public listingCounter;

    constructor(address initialOwner) ERC20("PrepaidLoad", "PLD") Ownable(initialOwner) {}

    function mint(address to, uint256 amount) external onlyOwner { 
        _mint(to, amount); 
    }

    function burn(uint256 amount) external { 
        _burn(_msgSender(), amount); 
    }

    function transfer(address to, uint256 amount) public override returns (bool) { 
        _transfer(_msgSender(), to, amount); 
        emit LoadTransferred(_msgSender(), to, amount);
        return true; 
    }

    function redeemLoad(address to, uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient battle pass balance");
        _transfer(_msgSender(), to, amount); 
        emit LoadRedeemed(msg.sender, amount);
    }   

    function createLoadListing(uint256 loadAmount, uint256 price) external {
        require(loadAmount > 0, "Load amount must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        uint256 listingId = listingCounter++; // Generate unique listing ID
        loadListings[listingId] = LoadListing({
            seller: _msgSender(),
            loadAmount: loadAmount,
            price: price
        });
        emit LoadListingCreated(listingId, _msgSender(), loadAmount, price);
    }

    function purchaseLoad(uint256 listingId, uint256 loadAmount) external {
        LoadListing storage listing = loadListings[listingId];
        require(listing.loadAmount >= loadAmount, "Insufficient load available");
        uint256 totalPrice = listing.price * loadAmount;
        require(balanceOf(_msgSender()) >= totalPrice, "Insufficient balance to purchase load");

        _transfer(_msgSender(), listing.seller, totalPrice);
        _transfer(listing.seller, _msgSender(), loadAmount);
        listing.loadAmount -= loadAmount;
        emit LoadPurchased(_msgSender(), listingId, loadAmount, totalPrice);
    }

    function getListing(uint256 listingId) external view returns (address seller, uint256 loadAmount, uint256 price) {
        LoadListing storage listing = loadListings[listingId];
        return (listing.seller, listing.loadAmount, listing.price);
    }

    function checkLoadBalance(address account) external view returns (uint256) { 
        return balanceOf(account); 
    }
}

```

Once you paste the code, go to SOLIDITY COMPILER to appear in DEPLOY and RUN TRANSACTION to deploy. NOW YOU CAN ENTER THE AMOUNT YOU WANT!

## Authors

Junel Symon Closa Dela Cruz
8210225@ntc.edu.ph


## License

This project is licensed under the MIT License - see the LICENSE.md file for details

