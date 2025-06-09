# Subasta en Solidity

## Descripción

Este contrato inteligente (`Auction.sol`) gestiona una **subasta simple** y segura en la red Ethereum. Permite a los usuarios pujar por un artículo, gestionar reembolsos parciales y finalizar la subasta devolviendo los depósitos a los participantes no ganadores, con una comisión del 2% para el dueño.


---

## ⚙️ Características Principales


✅ Subasta con artículo y duración definidos.  

✅ Incremento mínimo del 5% para superar la oferta más alta.  

✅ Extensión automática de la subasta si faltan menos de 10 minutos.  

✅ Gestión de reembolsos parciales para los oferentes que mejoran sus ofertas.  

✅ Evento para nueva oferta (`NewBid`).  

✅ Evento para subasta finalizada (`AuctionEnded`).  

✅ Reembolsos totales a oferentes no ganadores al finalizar.  

✅ Comisión del 2% para el dueño.  


---

## 📦 Variables Principales


| Variable           | Tipo      | Descripción                                                       |
|--------------------|-----------|-------------------------------------------------------------------|
| `owner`            | address   | Dueño de la subasta (creador del contrato).                       |
| `item`             | string    | Descripción del artículo subastado.                               |
| `auctionEndTime`   | uint      | Tiempo de finalización de la subasta (timestamp UNIX).            |
| `highestBid`       | uint      | Valor de la oferta más alta.                                      |
| `highestBidder`    | address   | Dirección del mejor oferente.                                     |
| `auctionActive`    | bool      | Estado de la subasta (activa o inactiva).                         |
| `FEE_PERCENT`      | uint      | Comisión fija del 2% para el dueño.                               |
| `userBids`         | mapping   | Ofertas realizadas por cada participante.                         |
| `partialRefunds`   | mapping   | Reembolsos parciales disponibles para los oferentes.              |
| `bidders`          | address[] | Lista de direcciones de oferentes.                                |


---

## 🚀 Funciones


### Constructor
* Inicializa la subasta con el artículo y duración en segundos.
  

### bid()
* Permite a los participantes hacer ofertas:

* La nueva oferta debe ser al menos un 5% mayor que la actual.

* Si es dentro de los últimos 10 minutos, extiende la subasta por 10 minutos.

* Gestiona reembolsos parciales para quienes mejoran su propia oferta.

* Emite el evento NewBid.
  

### withdrawPartialRefund()
* Permite a los oferentes recuperar el exceso de sus ofertas anteriores.


### viewWinner()
* Devuelve el actual ganador (dirección) y la oferta más alta.


### viewBids()
* Devuelve las direcciones de los oferentes y sus ofertas actuales.


### endAuction()
* Finaliza la subasta (solo el dueño puede ejecutarla):

* Cobra el 2% al dueño.

* Reembolsa las ofertas a los participantes no ganadores.

* Emite el evento AuctionEnded.


---

📢 Eventos


| Evento	      | Parámetros	                | Descripción                              |
|---------------|-----------------------------|------------------------------------------|
| NewBid      	| address bidder, uint amount	| Nueva oferta realizada.                  |
| AuctionEnded  |	address winner, uint amount |	Subasta finalizada y ganador confirmado. | 


---

👤 Permisos


* El dueño (owner) es la persona que despliega el contrato y tiene permisos especiales para:

* Finalizar la subasta.

* Recibir la comisión.


---

🔒 Seguridad y Recomendaciones


✅ Uso de modificadores (onlyOwner y auctionOngoing) para proteger funciones críticas.

✅ Validaciones estrictas para ofertas y tiempos de subasta.

✅ Control de reentradas al reembolsar depósitos (partialRefunds y userBids se ponen en cero antes del transfer).


---

📄 Despliegue


* Puedes desplegar y probar el contrato directamente en Remix IDE usando la red de prueba Sepolia o cualquier otra red compatible con EVM.


---

💼 Autor


* Gisela Celeste Yede

  Auction.sol - Contrato para subasta en Solidity.

