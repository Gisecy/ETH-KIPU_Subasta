// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.2 < 0.9.0;

/**
 * @title Auction (Subasta).
 * @author Gisela Celeste Yede.
 * @notice Contrato para gestionar una subasta.
 */


contract Auction {

    //Variables públicas
    address public owner; // Dueño de la subasta.
    string public item;   // Articulo a subastar.
    uint public auctionEndTime; // Duración de la subasta.
    uint public highestBid;  // Mejor oferta.
    address public highestBidder;  // Mejor oferente.
    bool public auctionActive; // Estado de la subasta (activa/inactiva).

    // Constante pública
    uint public constant FEE_PERCENT = 2; // Comisión del 2%

    // Mapeos para el seguimiento de ofertas y los reembolsos parciales
    mapping(address => uint) public userBids;
    mapping(address => uint) public partialRefunds;
    address[] private bidders;

    
    // Eventos Nueva oferta y Subasta finalizada
    event NewBid(address indexed bidder, uint amount); // Nueva oferta con address del oferente y valor de la oferta.
    event AuctionEnded(address winner, uint amount); // Subasta finalizada con address del ganador y valor de la oferta.

    // Modificadores Solo el dueño y Subasta en curso
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo lo puede ejecutar el owner");
        _;
    }

    modifier auctionOngoing() {
        require(auctionActive, "Subasta inactiva");
        require(block.timestamp < auctionEndTime, "Subasta finalizada");
        _;
    }

    /**
     * @param _item Descripción del artículo.
     * @param _durationInSeconds Duración de la subasta en segundos.
     */
    constructor(string memory _item, uint _durationInSeconds) {
        owner = msg.sender;
        item = _item;
        auctionEndTime = block.timestamp + _durationInSeconds;
        auctionActive = true;
    }

    /**
     * @notice Permite realizar una oferta válida.
     */
    function bid() external payable auctionOngoing {
        uint minBid = highestBid == 0 ? 0 : (highestBid * 105) / 100;
        require(msg.value > minBid, "Oferta muy baja");

        // Reembolso parcial si ya ofertó antes
        if (userBids[msg.sender] > 0) {
            partialRefunds[msg.sender] += userBids[msg.sender];
        } else {
            bidders.push(msg.sender);
        }

        userBids[msg.sender] = msg.value;
        highestBid = msg.value;
        highestBidder = msg.sender;

        // Extender plazo de la subasta si faltan <=10 min
        if (auctionEndTime - block.timestamp <= 10 minutes) {
            auctionEndTime += 10 minutes;
        }

        emit NewBid(msg.sender, msg.value); // Emite el evento Nueva oferta.
    }

    /**
     * @notice Retirar reembolsos parciales acumulados.
     */
    function withdrawPartialRefund() external {
        uint amount = partialRefunds[msg.sender];
        require(amount > 0, "Sin reembolso parcial");
        partialRefunds[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    /**
     * @notice Devolver el ganador actual y su oferta.
     */
    function viewWinner() external view returns (address, uint) {
        return (highestBidder, highestBid);
    }

    /**
     * @notice Devuelve la lista de oferentes y sus ofertas.
     */
    function viewBids() external view returns (address[] memory, uint[] memory) {
        uint len = bidders.length;
        uint[] memory amounts = new uint[](len);
        for (uint i; i < len; ++i) {
            amounts[i] = userBids[bidders[i]];
        }
        return (bidders, amounts);
    }

    /**
     * @notice Finalizar la subasta y gestionar los depósitos.
     */
    function endAuction() external onlyOwner {
        require(auctionActive, "Subasta ya finalizada");
        require(block.timestamp >= auctionEndTime, "Aun activa");
        auctionActive = false;

        // Pago de la comisión al owner
        uint fee = (highestBid * FEE_PERCENT) / 100;
        payable(owner).transfer(fee);

        // Reembolso a los perdedores
        for (uint i; i < bidders.length; ++i) {
            address bidder = bidders[i];
            if (bidder != highestBidder) {
                uint refund = userBids[bidder]; 
                if (refund > 0) {
                    userBids[bidder] = 0;
                    payable(bidder).transfer(refund);
                }
            }
        }

        emit AuctionEnded(highestBidder, highestBid); // Emite el evento Subasta finalizada.
    }
}
