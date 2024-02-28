// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract NFTSocialMediaPlatform {
    address public owner;
    uint256 private tokenIdCounter;

    struct User {
        string username;
        bool registered;
    }
    
    struct NFT {
        address owner;
        string metadataURI;
        uint256 likes;
    }
    
    mapping(address => User) public users;
    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => mapping(address => bool)) public likes;

    event UserRegistered(address indexed userAddress, string username);
    event NFTCreated(uint256 indexed tokenId, address indexed owner);
    event CommentAdded(uint256 indexed tokenId, address indexed commenter, string comment);
    event NFTLiked(uint256 indexed tokenId, address indexed liker);
    event UserRoleSet(address indexed userAddress, string role);
    event ContentModerated(uint256 indexed tokenId);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }
    
    function register(string memory _username) public {
        require(!users[msg.sender].registered, "User already registered");
        
        users[msg.sender] = User({
            username: _username,
            registered: true
        });
        
        emit UserRegistered(msg.sender, _username);
    }
    
    function createNFT(string memory _metadataURI) public {
        tokenIdCounter++;
        uint256 tokenId = tokenIdCounter;
        nfts[tokenId] = NFT({
            owner: msg.sender,
            metadataURI: _metadataURI,
            likes: 0
        });

        emit NFTCreated(tokenId, msg.sender);
    }

    mapping(address => string) public userRoles;

    function setUserRole(address _userAddress, string memory _role) public onlyOwner {
        userRoles[_userAddress] = _role;
        emit UserRoleSet(_userAddress, _role);
    }
    
    function moderateContent(uint256 _tokenId) public onlyOwner {
        require(nfts[_tokenId].owner != address(0), "NFT does not exist");
        require(keccak256(bytes(userRoles[msg.sender])) == keccak256(bytes("Moderator")), "Only moderators can moderate content");
        emit ContentModerated(_tokenId);
    }

    struct Group {
        string name;
        address[] members;
    }
    
    mapping(string => Group) public groups;
    
    function createGroup(string memory _groupName) public {
        require(groups[_groupName].members.length == 0, "Group name already exists");
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = msg.sender;
        groups[_groupName] = Group({
            name: _groupName,
            members: initialMembers
        });
    }
    
    function joinGroup(string memory _groupName) public {
        require(groups[_groupName].members.length > 0, "Group does not exist");
        groups[_groupName].members.push(msg.sender);
    }

    function addComment(uint256 _tokenId, string memory _comment) public {
        require(nfts[_tokenId].owner != address(0), "NFT does not exist");
        emit CommentAdded(_tokenId, msg.sender, _comment);
    }

    function searchNFTs(string memory _keyword) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](tokenIdCounter);
        uint256 count = 0;

        for (uint256 i = 1; i <= tokenIdCounter; i++) {
            if (bytes(nfts[i].metadataURI).length > 0 && containsKeyword(nfts[i].metadataURI, _keyword)) {
                result[count] = i;
                count++;
            }
        }

        uint256[] memory finalResult = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            finalResult[i] = result[i];
        }

        return finalResult;
    }

    function containsKeyword(string memory _str, string memory _keyword) internal pure returns (bool) {
        bytes memory strBytes = bytes(_str);
        bytes memory keywordBytes = bytes(_keyword);

        uint256 keywordLength = keywordBytes.length;
        if (keywordLength == 0) {
            return false;
        }

        for (uint256 i = 0; i <= strBytes.length - keywordLength; i++) {
            bool found = true;
            for (uint256 j = 0; j < keywordLength; j++) {
                if (strBytes[i + j] != keywordBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }
        return false;
    }

    mapping(address => uint256) public nonces;
    event GaslessTransaction(address indexed user, uint256 indexed nonce);

    function gaslessTransaction(uint256 _nonce, bytes memory _signature) public {
        require(_nonce == nonces[msg.sender] + 1, "Invalid nonce");
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, _nonce));
        address recoveredAddress = recoverSigner(messageHash, _signature);
        require(recoveredAddress == msg.sender, "Invalid signature");
        nonces[msg.sender]++;
        emit GaslessTransaction(msg.sender, _nonce);
    }

    function recoverSigner(bytes32 _messageHash, bytes memory _signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        return ecrecover(_messageHash, v, r, s);
    }

    function likeNFT(uint256 _tokenId) public {
        require(nfts[_tokenId].owner != address(0), "NFT does not exist");
        require(!likes[_tokenId][msg.sender], "Already liked");
        likes[_tokenId][msg.sender] = true;
        nfts[_tokenId].likes++;
        emit NFTLiked(_tokenId, msg.sender);
    }
}
