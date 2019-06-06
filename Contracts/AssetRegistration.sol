import "./AssetToken.sol";

pragma solidity 0.5.1;

contract AssetRegistration{
    
    address public InvestoAsia;
    
    constructor() public {
        InvestoAsia = msg.sender;
    }
  
    struct asset{
      bytes32 assetId;
      bytes32 ownerId;
      address ownerAddress;
      string encumbranceCertificateHash;
      string titleDeedDocumentHash;
      string taxReceiptDocumentHash;
      string assetDescription;
      string assetAddress;
      uint assetWorth;
  }
  
    struct registeredAsset{
        bytes32 assetId;  
        bytes32 custodianId;
        bytes ownerDigitalSignature;
        bytes custodianDigitalSignature;
        bytes _InvestoAsiaDigitalSignature;
        string auditDocumentHash;
        string hashOfNOC;
        string hashOfPOSCertificate;
        address assetContractAdress;
  }
    
    struct assetTokens{
        bytes32 assetId;
        string assetTokenName;
        string assetTokenSymbol;
        uint8 decimalUnits;
        uint initialSupply;
        address owner;
    }
    
    struct custodian{
        bytes32 custodianId;
        string custodianName;
        address custodianAddress;
    }
    
    // Mapping asset to assetId
    mapping(bytes32 => asset) public assetByAssetId;
    
    // Mapping registered asset to assetId
    mapping(bytes32 => registeredAsset) public registeredAssetByAssetId;
    
    // Mapping asset token details to assetId
    mapping(bytes32 => assetTokens) public assetTokensByAssetId;
    
    // Mapping custodian to custodianId
    mapping(bytes32 => custodian) public custodianByCustodianId;
    
    // Array of verified assets onboarded.
    bytes32[] registeredAssets;
    
    // Array of asset token contracts generated.
    address[] public assetIAFTokens;
    
    mapping(bytes32 => bool) public assetExists;
    
    mapping(bytes32 => uint) public assetIdIndexInRegisteredAssets;
    
    modifier onlyInvestoAsia {
        require(msg.sender == InvestoAsia);
        _;
    }
    
    // Registered customer uploads asset details.
    function uploadAssetDetails(bytes32 _assetId, bytes32 _ownerId,address _ownerAddress,string memory _encumbranceCertificateHash, string memory _titleDeedDocumentHash, string memory _taxReceiptDocumentHash,string memory _assetDescription, string memory _assetAddress, uint _assetWorth) internal returns (bool){
        require(msg.sender == _ownerAddress,"Only owner can upload asset details.");
        require(!assetExists[_assetId],"Asset already exists.");
        assetByAssetId[_assetId].assetId = _assetId;
        assetByAssetId[_assetId].ownerId = _ownerId;
        assetByAssetId[_assetId].ownerAddress = _ownerAddress;
        assetByAssetId[_assetId].encumbranceCertificateHash = _encumbranceCertificateHash;
        assetByAssetId[_assetId].titleDeedDocumentHash = _titleDeedDocumentHash;
        assetByAssetId[_assetId].taxReceiptDocumentHash = _taxReceiptDocumentHash;
        assetByAssetId[_assetId].assetDescription = _assetDescription;
        assetByAssetId[_assetId].assetAddress = _assetAddress;
        assetByAssetId[_assetId].assetWorth = _assetWorth;
        return true;
    }
    
    // Asset owner updates the asset details.
    function updateAssetDetails(bytes32 _assetId, bytes32 _ownerId,address _ownerAddress,string memory _encumbranceCertificateHash, string memory _titleDeedDocumentHash, string memory _taxReceiptDocumentHash,string memory _assetDescription, string memory _assetAddress, uint _assetWorth) internal returns (bool){
        require(msg.sender == _ownerAddress && msg.sender == assetByAssetId[_assetId].ownerAddress,"Only owner can update asset details.");
        require(assetExists[_assetId],"Asset does not exist.");
        assetByAssetId[_assetId].assetId = _assetId;
        assetByAssetId[_assetId].ownerId = _ownerId;
        assetByAssetId[_assetId].ownerAddress = _ownerAddress;
        assetByAssetId[_assetId].encumbranceCertificateHash = _encumbranceCertificateHash;
        assetByAssetId[_assetId].titleDeedDocumentHash = _titleDeedDocumentHash;
        assetByAssetId[_assetId].taxReceiptDocumentHash = _taxReceiptDocumentHash;
        assetByAssetId[_assetId].assetDescription = _assetDescription;
        assetByAssetId[_assetId].assetAddress = _assetAddress;
        assetByAssetId[_assetId].assetWorth = _assetWorth;
        return true;
    }
    
    // Adding custodian details by InvestoAsia
    function addCustodianDetails(bytes32 _custodianId,string memory _custodianName, address _custodianAddress) internal onlyInvestoAsia returns(bool){
        custodianByCustodianId[_custodianId].custodianId = _custodianId;
        custodianByCustodianId[_custodianId].custodianName = _custodianName;
        custodianByCustodianId[_custodianId].custodianAddress = _custodianAddress;
        return true;
    }
    
    //  signature methods.
    
    // Adding digital signature of the owner
    function addOwnerDigitalSignature(bytes32 _assetId,bytes memory _ownerDigitalSignature) internal returns (bool){
        require(msg.sender == assetByAssetId[_assetId].ownerAddress,"Only the owner should add digital signature.");
        registeredAssetByAssetId[_assetId].ownerDigitalSignature = _ownerDigitalSignature;
        return true;
    }
    
    // Adding digital signature of custodian
    function addCustodianDigitalSignature(bytes32 _assetId,bytes32 _custodianId,bytes memory _custodianDigitalSignature,bytes32 _message) internal returns (bool){
        require(msg.sender == custodianByCustodianId[_custodianId].custodianAddress,"Only the custodian should add the digital signature");
        bool ownerSignature = verifyDigitalSignature(assetByAssetId[_assetId].ownerAddress,_message,registeredAssetByAssetId[_assetId].ownerDigitalSignature);  // _message is the hash of the asset details object.
        require(ownerSignature);
        registeredAssetByAssetId[_assetId].custodianId = _custodianId;
        registeredAssetByAssetId[_assetId].custodianDigitalSignature = _custodianDigitalSignature;
        return true;
    }
    
    // Adding digital signature of InvestoAsia
    function addInvestoAsiaDigitalSignature(bytes32 _assetId,bytes32 _message, bytes memory _InvestoAsiaDigitalSignature) internal onlyInvestoAsia returns (bool){
        bool custodianSignature = verifyDigitalSignature(custodianByCustodianId[registeredAssetByAssetId[_assetId].custodianId].custodianAddress,_message,registeredAssetByAssetId[_assetId].custodianDigitalSignature);
        require(custodianSignature);
        registeredAssetByAssetId[_assetId]._InvestoAsiaDigitalSignature = _InvestoAsiaDigitalSignature;
        return true;
    }
    
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
    
    // Verify digital signature
    function verifyDigitalSignature(address _signerAddress,bytes32 _message,bytes memory _sig) public returns(bool) {
        address recoveredSigner = recoverSigner(_message,_sig);
        if(recoveredSigner == _signerAddress){
            return true;
        }
        return false;
    }
    
    // Add audit document details
    function addAuditDocument(bytes32 _assetId,string memory _auditDocumentHash,bytes32 _message) internal onlyInvestoAsia returns(bool){
        bool InvestoAsiaSignature = verifyDigitalSignature(InvestoAsia,_message,registeredAssetByAssetId[_assetId]._InvestoAsiaDigitalSignature);
        require(InvestoAsiaSignature);
        registeredAssetByAssetId[_assetId].auditDocumentHash =_auditDocumentHash;
        return true;
    }
    
    // Add NOC document details.
    function addNOCDetails(bytes32 _assetId, string memory _hashOfNOC) internal returns(bool){
        require(msg.sender == custodianByCustodianId[registeredAssetByAssetId[_assetId].custodianId].custodianAddress);
        registeredAssetByAssetId[_assetId].hashOfNOC = _hashOfNOC;
        return true;
    }
    
    // Add asset to verified asset list
    function registerAsset(bytes32 _assetId) internal onlyInvestoAsia returns (bool){
        registeredAssets.push(_assetId);
        assetIdIndexInRegisteredAssets[_assetId] = registeredAssets.length-1;
        return true;
    }
    
    // Add POS certificate details.
    function addPOSCertificate(bytes32 _assetId, string memory _hashOfPOSCertificate) internal onlyInvestoAsia returns(bool){
        registeredAssetByAssetId[_assetId].hashOfPOSCertificate = _hashOfPOSCertificate;
        return true;
    }
    
    // Remove asset from verified asset list.
    function removeAsset(bytes32 _assetId) internal onlyInvestoAsia returns(bool){
        bytes32 movedAssetId = registeredAssets[registeredAssets.length-1];
        registeredAssets[assetIdIndexInRegisteredAssets[_assetId]] = registeredAssets[registeredAssets.length-1];
        assetIdIndexInRegisteredAssets[movedAssetId]=assetIdIndexInRegisteredAssets[_assetId];
        registeredAssets.length--;
        return true;
    }
    
    // Generate IAF tokens.
    function tokenizeAsset(bytes32 _assetId,string memory _assetTokenName,string memory _assetTokenSymbol,uint8 _decimalUnits,uint _initialSupply,address _owner) internal onlyInvestoAsia returns (address assetContractAddress){
            
            assetTokensByAssetId[_assetId].assetId = _assetId;
            assetTokensByAssetId[_assetId].assetTokenName = _assetTokenName;
            assetTokensByAssetId[_assetId].assetTokenSymbol = _assetTokenSymbol;
            assetTokensByAssetId[_assetId].decimalUnits = _decimalUnits;
            assetTokensByAssetId[_assetId].initialSupply =_initialSupply;
            assetTokensByAssetId[_assetId].owner = _owner;
            
            AssetToken newAssetToken = new AssetToken(_assetTokenName,_assetTokenSymbol,_decimalUnits,_initialSupply,_owner);
            assetIAFTokens.push(address(newAssetToken));
            
            assetTokensByAssetId[_assetId].owner = address(newAssetToken);
            return(address(newAssetToken));
        }
}
