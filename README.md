# open-core
Welcome to the Core. Take the red pill, and venture forth.

# See it running
http://open-core.meteor.com (temporary URL, server donation accepted :P)

# Run it locally

## Prerequisits

* Install [Meteor](http://meteor.com/install)
* Gain access to a stellar-core postgres database. You can set one up yourself. See [here](https://github.com/stellar/stellar-core/blob/master/INSTALL.md) for installation instructions.
* It also helps to be familiar with [Stellar](https://www.stellar.org/galaxy/)

## Clone and run

    git clone https://github.com/buhrmi/open-core.git
    cd open-core
    CORE_DB_URL=postgres://[username]:[password]/[address-of-core-db]/[databasename] meteor

Example on a mac using docker container:

    CORE_DB_URL=postgres://postgres:postgrespassword@192.168.99.100:5432/stellar HISTORY_DB_URL=postgres://postgres:postgrespassword@192.168.99.100:5432/horizon meteor

# I can't even...

If you have questions about any of this, join us in the Stellar developer chat over at [Slack](https://stellar-public.slack.com/messages/dev/)
