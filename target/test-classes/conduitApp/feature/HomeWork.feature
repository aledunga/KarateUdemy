@parallel=false @debug
Feature: Home Work

Background: Preconditions
    * url apiUrl 
    * def timeValidator = read('classpath:helpers/timeValidator.js')
    * def commentRequestBody = read('classpath:conduitApp/json/newCommentRequest.json')
    * def commentText = commentRequestBody.comment.body
    * def favoriteArticleResponseBody = read('classpath:conduitApp/json/favoriteArticleResponse.json')
    * def ArticleResponseBody = read('classpath:conduitApp/json/articleResponse.json')
    * def CommentResponseBody = read('classpath:conduitApp/json/commentResponse.json')
Scenario: Favorite articles
    
    # Step 1: Get atricles of the global feed
    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    # Step 2: Get the favorites count and slug ID for the first arice, save it to variables
    * def favCount = response.articles[0].favoritesCount
    * def slugId = response.articles[0].slug
    # Step 3: Make POST request to increse favorites count for the first article
    Given path 'articles/' + slugId + '/favorite'
    When method Post
    Then status 200
    # Step 4: Verify response schema
    And match response == favoriteArticleResponseBody
    # Step 5: Verify that favorites article incremented by 1
        * match response.article.favoritesCount == favCount + 1
    # Step 6: Get all favorite articles
    Given params {favorited: #(userName),limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    # Step 7: Verify response schema
    And match each response.articles == ArticleResponseBody
    # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
    And match response.articles[0].slug contains '#(slugId)'
    #Delete favorite
    Given path 'articles/' + slugId + '/favorite'
    When method Delete
    Then status 200

Scenario: Comment articles
    # Step 1: Get articles of the global feed
    Given params {limit: 10, offset: 0}
    Given path 'articles'
    When method Get
    Then status 200
    # Step 2: Get the slug ID for the first article, save it to variable
    * def slugId = response.articles[0].slug
    # Step 3: Make a GET call to 'comments' end-point to get all comments
    Given path 'articles/' + slugId + '/comments'
    When method Get
    Then status 200
    # Step 4: Verify response schema
    And match response ==
    """
        {
            "comments":'#array'
         }
    """
    # Step 5: Get the count of the comments array lentgh and save to variable
        #Example
        * def responseWithComments = response.comments
        * def commentsCount = responseWithComments.length
    # Step 6: Make a POST request to publish a new comment
    Given path 'articles/' + slugId + '/comments'
    And request commentRequestBody
    When method Post
    Then status 200
    # Step 7: Verify response schema that should contain posted comment text
    And match response == CommentResponseBody
    # Step 8: Get the list of all comments for this article one more time
    Given path 'articles/' + slugId + '/comments'
    When method Get
    Then status 200
    # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
    * def initialCount = commentsCount
    * def commentsArray = response.comments
    * def finalCount = commentsArray.length
    * match finalCount == initialCount + 1
    # Step 10: Make a DELETE request to delete comment
    * def commentId = response.comments[0].id
    Given path 'articles/' + slugId + '/comments/' + commentId
    When method Delete
    Then status 200
    # Step 11: Get all comments again and verify number of comments decreased by 1
    Given path 'articles/' + slugId + '/comments'
    When method Get
    Then status 200
    * def initialCount = finalCount
    * def commentsArray = response.comments
    * def finalCountAfterDelete = commentsArray.length
    * match finalCountAfterDelete == initialCount - 1