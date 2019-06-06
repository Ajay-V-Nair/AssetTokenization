import "./AssetToken.sol";

pragma solidity 0.5.1;

contract AssetTrading{
    
    address payable _IAFEscrowAccount;
    
    constructor () public {
        address _IAFEscrowAccount = msg.sender;
    }
    
    enum Status{Pending,Completed,Cancelled}
    
    struct sellOrder{
        uint orderId;
        uint buyOrderId;
        bytes32 assetId;
        address payable initiator;
        string orderType;
        uint amount;
        uint price;
        Status orderStatus;
    }
    
    // Mapping sellOrder to orderId
    mapping(uint => sellOrder) sellOrderByOrderId;
    
    struct buyOrder{
        uint orderId;
        uint sellOrderId;
        bytes32 assetId;
        address payable initiator;
        string orderType;
        uint amount;
        uint price;
        uint etherSent;
        Status orderStatus;
    }
    
    // mapping buyOrder to orderId
    mapping(uint => buyOrder) buyOrderByOrderId;
    
    uint[] sellOrders;
    uint[] buyOrders;
    
    // Token owner places sell order
    function placeSellOrder(address _assetTokenAddress, uint _orderId,uint _buyOrderId, bytes32 _assetId, address payable _initiator, string memory _orderType, uint _amount, uint _price) public returns (bool){
        AssetToken newAssetToken = AssetToken(_assetTokenAddress);
        sellOrderByOrderId[_orderId].orderId = _orderId;
        sellOrderByOrderId[_orderId].buyOrderId = _buyOrderId;
        sellOrderByOrderId[_orderId].assetId = _assetId;
        sellOrderByOrderId[_orderId].initiator = _initiator;
        sellOrderByOrderId[_orderId].orderType = _orderType;
        sellOrderByOrderId[_orderId].amount = _amount;
        sellOrderByOrderId[_orderId].price = _price;
        sellOrderByOrderId[_orderId].orderStatus = Status.Pending; 
        newAssetToken.approve(address(this),_amount);
        sellOrders.push(_orderId);
        return true;
    }
    
    // Cancel sell order
    function cancelSellOrder(address _assetTokenAddress, uint _orderId) public returns (bool){
        require(msg.sender == sellOrderByOrderId[_orderId].initiator,"Only the initiator could cancel the sell order.");
        AssetToken newAssetToken = AssetToken(_assetTokenAddress);
        sellOrderByOrderId[_orderId].orderStatus = Status.Cancelled;
        newAssetToken.cancelAllowance(address(this),sellOrderByOrderId[_orderId].amount);
        return true;
    }
    
    // Buyer places buy order
    function placeBuyOrder(uint _orderId,uint _sellOrderId, bytes32 _assetId, address payable _initiator, string memory _orderType, uint _amount, uint _price) public payable returns (bool){
        require(msg.value >= (_amount * _price));
        buyOrderByOrderId[_orderId].orderId = _orderId;
        buyOrderByOrderId[_orderId].sellOrderId = _sellOrderId;
        buyOrderByOrderId[_orderId].assetId = _assetId;
        buyOrderByOrderId[_orderId].initiator = _initiator;
        buyOrderByOrderId[_orderId].orderType = _orderType;
        buyOrderByOrderId[_orderId].amount = _amount;
        buyOrderByOrderId[_orderId].price = _price;
        buyOrderByOrderId[_orderId].orderStatus = Status.Pending;
        buyOrderByOrderId[_orderId].etherSent = msg.value;
        buyOrders.push(_orderId);
        return true;
    }
    
    // cancel buy order
    function cancelBuyOrder(uint _orderId) public returns (bool){
        require(msg.sender == buyOrderByOrderId[_orderId].initiator,"Only the initiator can cancel the buy order.");
        buyOrderByOrderId[_orderId].orderStatus = Status.Cancelled;
        msg.sender.transfer(buyOrderByOrderId[_orderId].etherSent);
        return true;
    }
    // InvestoAsia escrow account executes the trade.
    function tradeAsset(address _assetTokenAddress,uint _buyOrderId, uint _sellOrderId) internal returns(bool){
        require(msg.sender == _IAFEscrowAccount);
        uint ethValue = buyOrderByOrderId[_buyOrderId].amount * buyOrderByOrderId[_buyOrderId].price;
        AssetToken newAssetToken = AssetToken(_assetTokenAddress);
        sellOrderByOrderId[_sellOrderId].amount -= buyOrderByOrderId[_buyOrderId].amount;
        sellOrderByOrderId[_sellOrderId].orderStatus = Status.Completed;
        newAssetToken.transferFrom(sellOrderByOrderId[_sellOrderId].initiator,buyOrderByOrderId[_buyOrderId].initiator,buyOrderByOrderId[_buyOrderId].amount);
        buyOrderByOrderId[_buyOrderId].amount = 0;
        buyOrderByOrderId[_buyOrderId].orderStatus = Status.Completed;
        sellOrderByOrderId[_sellOrderId].initiator.transfer(ethValue);
        return true;
    }
    
    // Deposit ether to contract
    function depositEther() public payable{
        
    }
    
    
}
