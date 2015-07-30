### Find out the water supplier in your area

A rails app that lets you find the water supplier in your area using your postcode.
Currently works only if the provider is either ***Affinity*** or ***Thameswater***.

Technical Details
================
The app uses [Mechanize](https://github.com/sparklemotion/mechanize)  to scrape content off of 2 different websites using the input postcode from the user.

There is no db involved in the whole process so all the outputs are ***non-persistent*** .
The scraping is done in parallel threads using the [parallel](https://github.com/grosser/parallel) gem which brings down the scraping time by a huge factor.

The version without parallel scraping can be tested. Checkout the ```app/suppliers/water.rb``` and the instruction to track the timing for ***non-parallel*** scraping approach can be found in the comments.

The code is ***NOT*** tested. No unit-test,  no integration-test ..... yet.

#### Room for improvement

1. Add tests.
2. Add proper error handling for parallel processes.
3. May be add some db involvement for persisting data when necessary. 