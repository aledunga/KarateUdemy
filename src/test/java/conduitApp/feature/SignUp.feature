@parallel=false 
Feature: Sign Up new user

    Background: Preconditions
        * def dataGenerator = Java.type('helpers.DataGenerator')
        * def randomEmail = dataGenerator.GetRandomEmail()
        * def randomUsername = dataGenerator.GetRandomUsername()
        * url apiUrl

    Scenario: New User SignUp
        # Given def userData = {"email":"aaa12@mail.com","username":"kar2122"}

        Given path 'users'
        * print randomEmail
        And request 
        """
        {
            "user":{
                "email": #(randomEmail),
                "password":"Pafdgfqa",
                "username":#(randomUsername)
                }
        }
        """
        When method Post
        Then status 201
        And match response ==
        """
            {
                "user": {
                    "email": #(randomEmail),
                    "username": #(randomUsername),
                    "bio": null,
                    "image": "#string",
                    "token": "#string"
                }
            }
        """
    # @parallel=false 
    Scenario Outline: Validate SignUp error messages
           

            Given path 'users'
            And request 
            """
            {
                "user":{
                    "email": "<email>",
                    "password":"<password>",
                    "username":"<username>"
                    }
            }
            """
            When method Post
            Then status 422
            And match response == <errorResponse>

            Examples: 
                | email                | password  | username                   | errorResponse                                                       |
                | #(randomEmail)       | Karate123 | KarateUser123              | {"errors":{"username":["has already been taken"]}}                  |
                | KarateUser1@test.com | Karate123 | #(randomUsername)          | {"errors":{"email":["has already been taken"]}}                     |
                | KarateUser1          | Karate123 | #(randomUsername)          | {"errors":{"email":["has already been taken"]}}                     |
                |                      | Karate123 | #(randomUsername)          | {"errors":{"email":["can't be blank"]}}                             |
                | #(randomEmail)       |           | #(randomUsername)          | {"errors":{"password":["can't be blank"]}}                          |
                | #(randomEmail)       | Karate123 |                            | {"errors":{"username":["can't be blank"]}}                          |