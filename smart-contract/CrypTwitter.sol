// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

struct Tweet {
    address author;
    string text;
    uint timestamp;
    string username;
}

contract CrypTwitter {
    uint public nextId = 0;

    uint public constant PAGE_SIZE = 10;

    uint public tweetsPerPage = PAGE_SIZE; // Defina um valor inicial

    // Mapeamento para retornar os tweets criado
    mapping(uint => Tweet) public tweets;

    // Mapeamento para retornar os usuários
    mapping(address => string) public users;

    // Mapeamento para rastrear os IDs dos tweets de cada usuário
    mapping(address => uint[]) public userTweets;

    // Novo mapeamento para fotos de perfil
    mapping(address => string) public userPhotos;

    // Somente o administrador pode chamar esta função
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // Defina o endereço do administrador do contrato
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    // Função para definir o número de tweets exibidos por página
    function setTweetsPerPage(uint _tweetsPerPage) public onlyAdmin {
        require(_tweetsPerPage > 0, "Tweets per page must be greater than 0");
        tweetsPerPage = _tweetsPerPage;
    }

    function addTweet(string calldata text) public {
        Tweet memory newTweet;
        newTweet.text = text;
        newTweet.author = msg.sender;
        newTweet.timestamp = block.timestamp;

        nextId++;
        tweets[nextId] = newTweet;

        // Atualiza o mapeamento de tweets do usuário
        userTweets[msg.sender].push(nextId);
    }

    // retorna a lista de twitter de um usuário
    function getUserTweets(address user) public view returns (Tweet[] memory) {
        uint[] memory tweetIds = userTweets[user];
        uint userTweetCount = tweetIds.length;

        Tweet[] memory userTweetList = new Tweet[](userTweetCount);

        for (uint i = 0; i < userTweetCount; i++) {
            userTweetList[i] = tweets[tweetIds[i]];
            userTweetList[i].username = users[userTweetList[i].author];
        }

        return userTweetList;
    }

    function changeUsername(string calldata newName) public {
        users[msg.sender] = newName;
    }

    function setUserPhoto(string calldata photoUrl) public {
        userPhotos[msg.sender] = photoUrl;
    }

    function getUserPhoto(address user) public view returns (string memory) {
        return userPhotos[user];
    }

    function getLastTweets(uint page) public view returns (Tweet[] memory) {
        if (page < 1) page = 1;
        uint startIndex = (tweetsPerPage * (page - 1)) + 1;

        Tweet[] memory lastTweets = new Tweet[](tweetsPerPage);

        for (uint i = 0; i < tweetsPerPage; i++) {
            if (startIndex + i > nextId) {
                break;
            }

            lastTweets[i] = tweets[startIndex + i];
            lastTweets[i].username = users[lastTweets[i].author];
        }

        return lastTweets;
    }
}
