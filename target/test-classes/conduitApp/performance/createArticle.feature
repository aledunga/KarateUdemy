
Feature: Articles

Background: Define URL
    * url apiUrl
    * def articleRequestBody = read('classpath:conduitApp/json/newArticleRequest.json')
    * def dataGenerator = Java.type('helpers.DataGenerator')
    * set articleRequestBody.article.title = dataGenerator.GetRandomArticleValues().title
    * set articleRequestBody.article.description = dataGenerator.GetRandomArticleValues().description
    * set articleRequestBody.article.body = dataGenerator.GetRandomArticleValues().body
    * def sleep = function(pause) { java.lang.Thread.sleep(pause) }
    * def pause = karate.get('__gatling.pause', sleep)
    
Scenario: Create and delete a new article
    Given path 'articles'
    And request articleRequestBody
    When method Post
    Then status 201
    And match response.article.title == articleRequestBody.article.title
    * def articleId = response.article.slug

    * pause(5000)

    Given path 'articles',articleId
    When method Delete
    Then status 204
