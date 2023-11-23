Feature: Dummy

Scenario: Dummy
    * def dataGenerator = Java.type('helpers.DataGenerator')
    * def username1 = dataGenerator.GetRandomUsername()
    * print username1