

Feature: Tests for the home page

Background: Define URL
    Given url apiUrl
# comand to run only a certain test/scenario : mvn test -Dkarate.options="classpath:conduitApp/feature/HomePage.feature:8" 
Scenario: Get all tags
    Given path 'tags'
    When method Get
    Then status 200
    And match response.tags contains ['welcome', 'qui']
    And match response.tags !contains 'test-value-na'
    And match response.tags contains any ['ipsum', 'queit','manifest']
    # And match response.tags contains only ['ipsum', 'queit','manifest']
    And match response.tags == "#array" // check that tags field return an array type
    And match each response.tags == "#string" //check that the elements inside the array are all strings

# command to run all tests exept this one :  mvn test -Dkarate.options="--tags ~@skipme"
@skipme
Scenario: Get 10 articles from the page - v1
    Given param limit = 10
    Given param offset = 0
    Given path 'articles'
    When method Get
    Then status 200

# comand to run only this test : mvn test -Dkarate.options="--tags @smoke" 
#@smoke
Scenario: Get 10 articles from the page - v2
    * def timeValidator = read('classpath:helpers/timeValidator.js')
    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    And match response == {"articles": "#[10]", "articlesCount":"#number ? _ > 10"} /// check the array has size 10 ( 10 objects) #[10]
    And match each response.articles ==
    """
        {
            "slug": "#string",
            "title": "#string",
            "description": "#string",
            "body": "#string",
            "tagList": '#array',
            "createdAt": "#? timeValidator(_)",
            "updatedAt": "#? timeValidator(_)",
            "favorited": '#boolean',
            "favoritesCount": '#number',
            "author": {
                "username": "#string",
                "bio": '##string',
                "image": "#string",
                "following": '#boolean'
            }
        } 
    """

Scenario: Conditional logic
    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    * def favoritesCount = response.articles[0].favoritesCount
    * def article = response.articles[0]

    # * if (favoritesCount == 0) karate.call('classpath:helpers/AddLikes.feature', article)

    * def result = favoritesCount == 0 ? karate.call('classpath:helpers/AddLikes.feature', article).likesCount : favoritesCount

    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    And match response.articles[0].favoritesCount == result
  
Scenario: Retry call
    * configure retry = { count: 3, interval: 5000 }

    Given params {limit: 10, offset: 0}
    Given path 'articles'
    And retry until response.articles[0].favoritesCount == 1
    When method Get
    Then status 200
    

Scenario: Sleep call
    * def sleep = function(pause) { java.lang.Thread.sleep(pause) }

    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    * eval sleep(5000)
    Then status 200
  
Scenario: Number to string
    * def foo = 10
    * def json = {"bar": #(foo+'')}
    * match json == {"bar": '10'}
  
Scenario: String to number
    * def foo = '10'
    * def json = {"bar": #(foo*1)}
    * match json == {"bar": 10}   
    * def json2 = {"bar": #(~~parseInt(foo))}
    * match json2 == {"bar": 10}
