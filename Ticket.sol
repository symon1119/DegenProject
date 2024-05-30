pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Degen is ERC20, Ownable {
    event TicketTransferred(address indexed from, address indexed to, uint256 amount);
    event TicketListingCreated(uint256 listingId, address indexed seller, uint256 ticketCount, uint256 price);
    event TicketPurchased(address indexed buyer, uint256 listingId, uint256 ticketCount, uint256 totalPrice);
    event TicketRedeemed(address indexed redeemer, uint256 ticketCount);

    struct TicketListing { address seller; uint256 ticketCount; uint256 price; }

    mapping(uint256 => TicketListing) public ticketListings;
    uint256 public listingCounter;

    constructor(address initialOwner) Ownable(initialOwner) ERC20("Degen", "DGN") {}

    function mint(address to, uint256 amount) external onlyOwner { _mint(to, amount); }

    function burn(uint256 amount) external { _burn(msg.sender, amount); }

    function transfer(address to, uint256 amount) public override returns (bool) { 
        _transfer(_msgSender(), to, amount); 
        emit TicketTransferred(_msgSender(), to, amount);
        return true; 
    }

    function redeemTickets(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient ticket balance");
        _burn(msg.sender, amount);
        emit TicketRedeemed(msg.sender, amount);
    }   

    function createTicketListing(uint256 ticketCount, uint256 price) external {
        require(ticketCount > 0, "Ticket count must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        uint256 listingId = listingCounter++; // Generate unique listing ID
        ticketListings[listingId] = TicketListing({
            seller: msg.sender,
            ticketCount: ticketCount,
            price: price
        });
        emit TicketListingCreated(listingId, msg.sender, ticketCount, price);
    }

    function purchaseTickets(uint256 listingId, uint256 ticketCount) external {
        TicketListing storage listing = ticketListings[listingId];
        require(listing.ticketCount >= ticketCount, "Insufficient tickets available");
        uint256 totalPrice = listing.price * ticketCount;
        require(balanceOf(msg.sender) >= totalPrice, "Insufficient balance to purchase tickets");

        _transfer(msg.sender, listing.seller, totalPrice);
        _transfer(listing.seller, msg.sender, ticketCount);
        listing.ticketCount -= ticketCount;
        emit TicketPurchased(msg.sender, listingId, ticketCount, totalPrice);
    }

    function getListing(uint256 listingId) external view returns (address seller, uint256 ticketCount, uint256 price) {
        TicketListing storage listing = ticketListings[listingId];
        return (listing.seller, listing.ticketCount, listing.price);
    }

    function checkTicketBalance(address account) external view returns (uint256) { 
        return balanceOf(account); 
    }
}
