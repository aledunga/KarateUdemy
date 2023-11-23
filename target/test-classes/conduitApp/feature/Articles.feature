
Feature: Articles

Background: Define URL
    * url apiUrl
    * def articleRequestBody = read('classpath:conduitApp/json/newArticleRequest.json')
    * def dataGenerator = Java.type('helpers.DataGenerator')
    * set articleRequestBody.article.title = dataGenerator.GetRandomArticleValues().title
    * set articleRequestBody.article.description = dataGenerator.GetRandomArticleValues().description
    * set articleRequestBody.article.body = dataGenerator.GetRandomArticleValues().body
    

Scenario: Create a new article
    Given path 'articles'
    And request articleRequestBody
    When method Post
    Then status 201
    And match response.article.title == articleRequestBody.article.title
    
Scenario: Create and delete a new article
    Given path 'articles'
    And request articleRequestBody
    When method Post
    Then status 201
    And match response.article.title == articleRequestBody.article.title
    * def articleId = response.article.slug

    
    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    And match response.articles[0].title == articleRequestBody.article.title


    Given path 'articles',articleId
    When method Delete
    Then status 204


    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    And match response.articles[0].title != articleRequestBody.article.title
