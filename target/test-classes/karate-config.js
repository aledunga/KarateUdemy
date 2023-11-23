function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    apiUrl: 'https://api.realworld.io/api/'
  }
  if (env == 'dev') {
    config.userEmail = 'test_ale_du@mail.com'
    config.userPwd = 'Pass1234'
  } 
  if (env == 'qa') {
    //mvn test -Dkarate.options="--tags ~@debug" -Dkarate.env="qa"
    config.userEmail = 'test_ale_du_qa@mail.com'
    config.userPwd = 'Pass1234qa'
  }
  
  var accessToken = karate.callSingle('classpath:helpers/CreateToken.feature', config).authToken
  karate.configure('headers', {Authorization: 'Token ' + accessToken})

  var userName = karate.callSingle('classpath:helpers/CreateToken.feature', config).userName
  config.userName = userName

  return config;
}