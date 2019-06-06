pragma solidity 0.5.1;

contract CustomerOnboarding{
    
    address _IAFOfficial;
    
    constructor () public {
        _IAFOfficial = msg.sender;
    }
    
    struct customer{
        bytes32 customerId;
        string customerName;
        string gender;
        bytes32 dateOfBirth;
        string addressOfCustomer;
        bytes32 emailId;
        bool amlRugulationComplianceConsent;
        uint kycValidity;
        bool kycApproval;
        address walletAddress;
        bytes32 publicKey;
    }
    
    struct customerNationality{
        string nationality;
        bytes32 passportNo;
        string scannedPassportHash;
        bytes32 panNo;
        string scannedPANCardHash;   
    }
    
    modifier onlyIAFOfficial {
        require(msg.sender == _IAFOfficial);
        _;
    }
    
    
    // Mapping customer to customerId
    mapping(bytes32=>customer) public customerById;     
    // Mapping customerNationality to customerId
    mapping(bytes32=>customerNationality) public customerNationalityDetails;
    
    // Array of cusotmerIds of verified ond onboarded customers.
    bytes32[] verifiedCustomers;
    mapping(bytes32=>uint) public customerIndexInVerifiedList;
    mapping(bytes32 => bool) public customerExists;
    
    // Add customer details.
    function addCustomerDetails(bytes32 customerId,string memory customerName,string memory gender,bytes32 dateOfBirth, string memory addressOfCustomer,bytes32 emailId,bool amlRugulationComplianceConsent) internal returns(bool){
        require(!customerExists[customerId],"Customer already exists.");
        customerById[customerId].customerId=customerId;
        customerById[customerId].customerName=customerName;
        customerById[customerId].gender=gender;
        customerById[customerId].dateOfBirth=dateOfBirth;
        customerById[customerId].addressOfCustomer=addressOfCustomer;
        customerById[customerId].emailId=emailId;
        customerById[customerId].amlRugulationComplianceConsent=amlRugulationComplianceConsent;
        customerExists[customerId] = true;
        return true;
    }
    
    // Update customer details
    function updateCustomerDetails(bytes32 customerId,string memory customerName,string memory gender,bytes32 dateOfBirth, string memory addressOfCustomer,bytes32 emailId,bool amlRugulationComplianceConsent) internal returns(bool){
        require(customerExists[customerId],"Customer does not exist.");
        customerById[customerId].customerId=customerId;
        customerById[customerId].customerName=customerName;
        customerById[customerId].gender=gender;
        customerById[customerId].dateOfBirth=dateOfBirth;
        customerById[customerId].addressOfCustomer=addressOfCustomer;
        customerById[customerId].emailId=emailId;
        customerById[customerId].amlRugulationComplianceConsent=amlRugulationComplianceConsent;
        return true;
    }
    
    // Add customer's uploaded nationality document details
    function addCustomerNationalityDetails(bytes32 customerId,string memory nationality,bytes32 passportNo,string memory scannedPassportHash,bytes32 panNo,string memory scannedPANCardHash) internal returns (bool){
        require(!customerExists[customerId],"Customer already exists.");
        customerNationalityDetails[customerId].nationality=nationality;
        customerNationalityDetails[customerId].passportNo=passportNo;
        customerNationalityDetails[customerId].scannedPassportHash=scannedPassportHash;
        customerNationalityDetails[customerId].panNo=panNo;
        customerNationalityDetails[customerId].scannedPANCardHash=scannedPANCardHash;
        return true;
    }
    
    // Update customer nationality details.
    function updateCustomerNationalityDetails(bytes32 customerId,string memory nationality,bytes32 passportNo,string memory scannedPassportHash,bytes32 panNo,string memory scannedPANCardHash) internal returns (bool){
        require(customerExists[customerId],"Customer does not exist.");
        customerNationalityDetails[customerId].nationality=nationality;
        customerNationalityDetails[customerId].passportNo=passportNo;
        customerNationalityDetails[customerId].scannedPassportHash=scannedPassportHash;
        customerNationalityDetails[customerId].panNo=panNo;
        customerNationalityDetails[customerId].scannedPANCardHash=scannedPANCardHash;
        return true;
    }
    
    function getCustomerDetails(bytes32 customerId) public view returns(string memory retCustomerName,string memory retGender,bytes32 retDateOfBirth, string memory retAddressOfCustomer,bytes32 retEmailId,bool retAmlRugulationComplianceConsent){
        retCustomerName=customerById[customerId].customerName;
        retGender=customerById[customerId].gender;
        retDateOfBirth=customerById[customerId].dateOfBirth;
        retAddressOfCustomer=customerById[customerId].addressOfCustomer;
        retEmailId=customerById[customerId].emailId;
        retAmlRugulationComplianceConsent=customerById[customerId].amlRugulationComplianceConsent;
    }
    
    function getCustomerNationalityDetails(bytes32 customerId) public view returns (string memory retNationality,bytes32 retPassportNo,string memory retScannedPassportHash,bytes32 retPanNo,string memory retScannedPANCardHash){
        retNationality=customerNationalityDetails[customerId].nationality;
        retPassportNo=customerNationalityDetails[customerId].passportNo;
        retScannedPassportHash=customerNationalityDetails[customerId].scannedPassportHash;
        retPanNo=customerNationalityDetails[customerId].panNo;
        retScannedPANCardHash=customerNationalityDetails[customerId].scannedPANCardHash;
    }
    
    // Onboard customer to the plaform and provide an account.
    function onboardCustomer(bytes32 customerId, bool kycApproval,address walletAddress,bytes32 publicKey) internal onlyIAFOfficial returns (bool){
        customerById[customerId].kycApproval=kycApproval;
        customerById[customerId].walletAddress=walletAddress;
        customerById[customerId].publicKey=publicKey;
        verifiedCustomers.push(customerId);
        customerIndexInVerifiedList[customerId]=verifiedCustomers.length-1;
        return true;
    }
    
    // offboard customer from the plaform.
    function offboardCustomer(bytes32 customerId) internal onlyIAFOfficial returns (bool){
        bytes32 movedCustomerId=verifiedCustomers[verifiedCustomers.length-1];
        verifiedCustomers[customerIndexInVerifiedList[customerId]]=verifiedCustomers[verifiedCustomers.length-1];
        customerIndexInVerifiedList[movedCustomerId]=customerIndexInVerifiedList[customerId];
        verifiedCustomers.length--;
        return true;
    }
    
}
