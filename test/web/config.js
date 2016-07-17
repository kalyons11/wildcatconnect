var config = {};

config.hasher = "dc4862c8-6a8b-49b4-a0e4-fe2bda364281";
config.appId = "U2FsdGVkX1++5zi8axe/UlYrVdFe06td8QxkJgqIDU0IF7TYd/2TEPHFv2UoZ3D1jX1Bu17qKzpc35UaQyjOwA=="; //fb577937-2edd-4d27-9854-0189dcaf37ad";
config.masterKey = "U2FsdGVkX1+3J8ZSlobAZz7PC+v0VahJ6PzoEJZN23dtvRG6+8eR/1imjJM+bBox0EBjr2hljP3mHt2Fip6gdA=="; //5de584ea-b1bb-4a75-818b-6e64ea156ebb";
config.serverURL = "https://test-wc-server-2.herokuapp.com/parse";
config.databaseUri = "mongodb://wc-test-db-user:16cat5conn@ds023704.mlab.com:23704/wc-test-db";
config.opLogUri = "mongodb://oplogger:opPass123@ds023704.mlab.com:23704/wc-test-db";
config.parseMount = "/parse";
config.logglyToken = "4e51ee0a-d0a5-4d24-90d7-16c1f4efdc20";
config.logglySubdomain = "wildcatconnect";
config.nodeTag = "web";
config.mongoTag = "database";
config.classNames = [ "TestClass" ];
config.secret = "15928efc-0135-47e5-b3cc-c02e8d58a88c";
config.pages = ['/.gitignore', '/config.js', '/Dockerfile', '/index.js', '/jsconfig.json', '/LICENSE', '/package.json', '/Procfile', '/cloud/*', '/controllers/*', '/node_modules/*', '/test/*', '/utils/*', '/views/*'];
config.customPages = ['group.post'];
config.IDdictionary = { 

    NewsArticleStructure : "articleID",

    CommunityServiceStructure: "communityServiceID",

    EventStructure: "ID",

    ExtracurricularUpdateStructure: "extracurricularUpdateID",

    ExtracurricularStructure: "extracurricularID",

    PollStructure: "pollID",

    ScholarshipStructure: "ID",

    Testing: "testingTwo"

};


module.exports = config;

//Separate into distinct files