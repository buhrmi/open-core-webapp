# open-core
The Core. For everyone.

# See it running
http://open-core.meteor.com (temporary URL, server donation accepted :P)

# Run it locally

## Prerequisits

* [Meteor](http://meteor.com/install)
* Access to a stellar core postgres database. See [here](https://github.com/stellar/stellar-core/blob/master/INSTALL.md) for installation instructions.

## Clone and run

    git clone https://github.com/buhrmi/open-core.git
    cd open-core
    CORE_DB_URL=postgres://[username]:[password]/[address-of-core-db]/[databasename] meteor
