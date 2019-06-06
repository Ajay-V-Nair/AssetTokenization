pragma solidity 0.5.1;


/*
 * Math operations with safety checks
 */
 
contract Safemath{
    
    function safeMul(uint a,uint b) internal returns(uint){
        uint c = a * b;
        assert((c / b) == a|| a == 0);
        return c;
    }
    
    function safeDiv(uint a,uint b) internal returns(uint){
        assert(b > 0);
        uint c = a / b;
        assert(a == c * b + a % b);
        return c;
    }
    
    function safeAdd(uint a,uint b) internal returns(uint){
        uint c = a + b;
        assert(c > a && c > b);
        return c;
    }
    
    function safeSub(uint a,uint b) internal returns(uint){
        assert(b <= a);
        return (a - b);
    }
}

contract AssetToken is Safemath{
    string public assetTokenName;
    string public assetTokenSymbol;
    uint8 decimalUnits;
    uint totalSupply;
    address public owner;
   
   // Mapping of balances of all accounts. 
    mapping(address=>uint) public balanceOf;
    
    // Mapping of freezed tokens of accounts.
    mapping(address=>uint) public freezeOf;
    
    // Mapping of allowances provided to a spender to spend on behalf of the owner.
    mapping(address=>mapping(address=>uint)) public allowance;
    
    // This generates a public event on the blockchain that will notify clients. 
    event Transfer(address indexed from,address indexed to,uint amount);
    
    // This notifies clients about the amount burnt
    event Burn(address indexed from,uint amount);
    
    // This notifies clients about the amount frozen.
    event Freeze(address indexed from,uint amount);
    
    // This notifies clients about the amount unfrozen.
    event Unfreeze(address indexed from,uint amount);
    
    // Initializes contract with initial supply tokens to the owner of the asset.
    constructor(string memory _assetTokenName,string memory _assetTokenSymbol,uint8 _decimalUnits,uint _initialSupply,address _owner) public{
        assetTokenName = _assetTokenName;                   // Set the name for display purposes.
        assetTokenSymbol = _assetTokenSymbol;               // Set the symbol for display purposes.
        decimalUnits = _decimalUnits;                       // Amount of decimals for display purposes.
        totalSupply = _initialSupply;                       // Update total supply.
        owner = _owner;                                     //Assuming InvestoAsia is deploying the AssetToken contract.
        balanceOf[_owner] = _initialSupply;                 // Give the creator all initial tokens.
    }
    
    //Transfer tokens
    function transferToken(address _to,uint _amount) public returns(bool){
     require(_to != address(0));
     require(_amount > 0);
     require(balanceOf[msg.sender] >= _amount);
     require( (balanceOf[_to] + _amount) > balanceOf[_to]);
     
     balanceOf[msg.sender] = Safemath.safeSub(balanceOf[msg.sender], _amount);
     balanceOf[_to] = Safemath.safeAdd(balanceOf[_to],_amount);
     emit Transfer(msg.sender,_to,_amount);
    }
    
    // Approve allowance to a spender
    function approve(address _spender,uint _amount) public returns (bool){
        require(_amount > 0);
        require(balanceOf[msg.sender] >= _amount);
        allowance[msg.sender][_spender] = _amount;
        return true;
    }
    
    // Cancel allowance
    function cancelAllowance(address _spender, uint _amount) public returns(bool){
        require(_amount > 0);
        require(allowance[msg.sender][_spender] >= _amount);
        allowance[msg.sender][_spender] = Safemath.safeSub(allowance[msg.sender][_spender],_amount);
        return true;
    }
    
    // Function for spender to transfer tokens
    function transferFrom(address _from, address _to, uint _amount) public returns(bool){
        require(_to != address(0));
        require(_amount > 0);
        require(balanceOf[_from] >= _amount);
        require( (balanceOf[_to] + _amount) > balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _amount);
        balanceOf[_from] = Safemath.safeSub(balanceOf[_from],_amount);
        balanceOf[_to] = Safemath.safeAdd(balanceOf[_to],_amount);
        allowance[_from][msg.sender] = Safemath.safeSub(allowance[_from][msg.sender],_amount);
        emit Transfer(_from,_to,_amount);
    }
    
    // Burn tokens
    function burn(uint _amount) public returns(bool){
        require(balanceOf[msg.sender] >= _amount);
        require(_amount > 0);
        balanceOf[msg.sender] = Safemath.safeSub(balanceOf[msg.sender],_amount);
        totalSupply = Safemath.safeSub(totalSupply,_amount);
        emit Burn(msg.sender,_amount);
        return true;
    }
    
    // Freeze tokens
    function freeze(uint _amount) public returns(bool){
        require(balanceOf[msg.sender] >= _amount);
        require(_amount > 0);
        balanceOf[msg.sender] = Safemath.safeSub(balanceOf[msg.sender],_amount);
        freezeOf[msg.sender] = Safemath.safeAdd(freezeOf[msg.sender],_amount);
        emit Freeze(msg.sender,_amount);
        return true;
    } 
    
    // Unfreeze tokens
    function unfreeze(uint _amount) public returns(bool){
        require(_amount > 0);
        require(freezeOf[msg.sender] >= _amount);
        freezeOf[msg.sender] = Safemath.safeSub(freezeOf[msg.sender],_amount);
        balanceOf[msg.sender] = Safemath.safeAdd(balanceOf[msg.sender],_amount);
        emit Unfreeze(msg.sender,_amount);
        return true;
    }
    
    // transfer balance to owner
    function withdrawEther(uint _amount) public {
        require(msg.sender == owner);
        msg.sender.transfer(_amount);
    }
    
    // Deposit ether to contract
    function deposit() public payable{
        
    }
}
